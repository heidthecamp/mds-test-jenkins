#
# Copyright (c) 2017, Massachusetts Institute of Technology All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# Redistributions of source code must retain the above copyright notice, this
# list of conditions and the following disclaimer.
#
# Redistributions in binary form must reproduce the above copyright notice, this
# list of conditions and the following disclaimer in the documentation and/or
# other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

from MDSplus import Data, TreeNode, TreePath

MC = __import__('MARTE2_COMPONENT', globals())


@MC.BUILDER('DoubleHandshakeGAM::DoubleHandshakeSlaveGAM', MC.MARTE2_COMPONENT.MODE_GAM)
class MARTE2_DOUBLEH_SLAVE(MC.MARTE2_COMPONENT):
    inputs = [
        {'name': 'CommandIn0', 'type': 'uint32', 'dimensions': 0, 'parameters': []},
        {'name': 'CommandIn1', 'type': 'uint32', 'dimensions': 0, 'parameters': []},
        {'name': 'CommandIn2', 'type': 'uint32', 'dimensions': 0, 'parameters': []},
        {'name': 'CommandIn3', 'type': 'uint32', 'dimensions': 0, 'parameters': []},
        {'name': 'ClearIn0', 'type': 'uint32', 'dimensions': 0, 'parameters': []},
        {'name': 'ClearIn1', 'type': 'uint32', 'dimensions': 0, 'parameters': []},
        {'name': 'ClearIn2', 'type': 'uint32', 'dimensions': 0, 'parameters': []},
        {'name': 'ClearIn3', 'type': 'uint32', 'dimensions': 0, 'parameters': []}]
        
    outputs = [
        {'name': 'AckOut0', 'type': 'uint32', 'dimensions': 0, 'parameters': []},
        {'name': 'AckOut1', 'type': 'uint32', 'dimensions': -1, 'parameters': []},
        {'name': 'AckOut2', 'type': 'uint32', 'dimensions': -1, 'parameters': []},
        {'name': 'AckOut3', 'type': 'uint32', 'dimensions': -1, 'parameters': []},
        {'name': 'InternalState0', 'type': 'uint8', 'dimensions': 0, 'parameters': []},
        {'name': 'InternalState1', 'type': 'uint8', 'dimensions': -1, 'parameters': []},
        {'name': 'InternalState2', 'type': 'uint8', 'dimensions': -1, 'parameters': []},
        {'name': 'InternalState3', 'type': 'uint8', 'dimensions': -1, 'parameters': []}]

    parameters = []
    parts = []

    def prepareMarteInfo(self):
       pass
 