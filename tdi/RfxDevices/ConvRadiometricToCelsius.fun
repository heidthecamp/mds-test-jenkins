public fun ConvRadiometricToCelsius(as_is _DevicePath, in _tStart, in _tEnd, optional in _emissivity, optional in _atmTemp, optional in _objectDistance, optional in _ambTemp, optional in _relHum )
{
	_devType = model_of(_DevicePath);
    _sigOut = 0;

	if( _devType == "FLIRSC65X"  )
	{
		_path = getnci( _DevicePath , "FULLPATH" );
		_framesPath = build_path(_path//":FRAMES");
		_metaDataPath = build_path(_path//":FRAMES_METAD");
		_status = SetTimeContext( _tStart, _tEnd, *);
		if( _status & 1 )
		{
			_framesNid = getnci( _framesPath, "NID_NUMBER");
			_framesSig = 1;
		    _status=TreeShr->TreeGetRecord(val(_framesNid),xd(_framesSig));
			if( _status & 1 )
			{
				_metaDataNid = getnci( _metaDataPath, "NID_NUMBER");
				_metaDataSig = 1;
		    	_status=TreeShr->TreeGetRecord(val( _metaDataNid ),xd( _metaDataSig ));				
			}
			if( _status & 1 )
			{
				_frames = data( _framesSig );
				_dim = dim_of( _framesSig );
				_shape = shape( _frames );
				_metaData = data( _metaDataSig );
				_objectParam = 0;

				if( present( _atmTemp ) ) 
					_objectParam = 1;
				else
					_atmTemp = float(data(build_path(_path//".OBJECT:ATM_TEMP")));

				_atmTemp = _atmTemp + 273.15;

				if( present( _emissivity) ) 
					_objectParam = 1;
				else
					_emissivity = float(data(build_path(_path//".OBJECT:EMISSIVITY")));

				if( present( _objectDistance ) ) 
					_objectParam = 1;
				else
					_objectDistance = float(data(build_path(_path//".OBJECT:DISTANCE")));


				if( present( _ambTemp ) ) 
					_objectParam = 1;
				else
					_ambTemp = float(data(build_path(_path//".OBJECT:OPTIC_TEMP"))) ;

				_ambTemp = _ambTemp + 273.15;

				if( present( _relHum) ) 
					_objectParam = 1;
				else
					_relHum = float(data(build_path(_path//".OBJECT:ATM_HUM")));

				_relHum = _relHum / 100.;


				if( _objectParam )
				 flirutils->flirRadiometricConvFramesPar( ref( _frames ) , val( _shape[0] ), val( _shape[1] ), val( _shape[2] ), _metaData,
 					( _atmTemp ), ( _emissivity ), ( _objectDistance ), ( _ambTemp ), ( _relHum ) );
				else
				 flirutils->flirRadiometricConvFrames( ref( _frames ) , val( _shape[0] ), val( _shape[1] ), val( _shape[2] ),  _metaData );

				_sigOut = make_signal( _frames,, _dim );

			}
		}
	}
	else
	{
		_status = 0;
		write(*, "Device type "//_devType//" not yet supported");
		_sigOut = 0;
	
	}
	if( !(_status & 1 ) )
		write(*, "Error : "//getmsg(_status));
	return ( _sigOut  );
}
