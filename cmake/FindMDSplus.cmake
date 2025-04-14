# FindMDSplus.cmake
#
# Finds MDSplus
#
# This will define the following variables
#
#   MDSplus_FOUND
#   MDSplus_INCLUDE_DIRS
#   MDSplus_LIBRARY_DIRS
#   MDSplus_MdsShr_LIBRARY
#   MDSplus_TreeShr_LIBRARY
#   MDSplus_TdiShr_LIBRARY
#   MDSplus_MdsLib_LIBRARY
#   MDSplus_MdsObjectsCppShr_LIBRARY
#   MDSplus_PYTHONPATH
#   MDSplus_tditest_EXECUTABLE
#   MDSplus_tdic_EXECUTABLE
#   MDSplus_mdstcl_EXECUTABLE
#   MDSplus_mdsdcl_EXECUTABLE
#   MDSplus_setevent_EXECUTABLE
#   MDSplus_wfevent_EXECUTABLE
#   MDSplus_dwscope_EXECUTABLE
#   MDSplus_traverser_EXECUTABLE
#   MDSplus_jScope_EXECUTABLE
#   MDSplus_jTraverser_EXECUTABLE
#   MDSplus_jTraverser2_EXECUTABLE
#
# and the following imported targets
#
#   MDSplus::Dynamic
#   MDSplus::MdsShr
#   MDSplus::TreeShr
#   MDSplus::TdiShr
#   MDSplus::MdsLib
#   MDSplus::MdsObjectsCppShr
#
# The following variables can be set as arguments
#
#   MDSplus_ROOT
#
# If MDSplus_ROOT is not set, the following sources will be searched for MDSplus
#
#   $ENV{MDSPLUS_DIR}
#   file(READ /etc/.mdsplus_dir)
#   /usr/local/mdsplus

if("${CMAKE_SIZEOF_VOID_P}" STREQUAL "4")
    set(_MDSplus_lib_arch "lib32")
    set(_MDSplus_bin_arch "bin32")
else()
    set(_MDSplus_lib_arch "lib64")
    set(_MDSplus_bin_arch "bin64")
endif()

mark_as_advanced(_MDSplus_lib_arch)
mark_as_advanced(_MDSplus_bin_arch)

if(NOT DEFINED MDSplus_ROOT)
    if(DEFINED ENV{MDSPLUS_DIR})
        list(APPEND MDSplus_ROOT $ENV{MDSPLUS_DIR})
    endif()

    if(EXISTS /etc/.mdsplus_dir)
        file(READ /etc/.mdsplus_dir _MDSplus_etc_mdsplus_dir)
        list(APPEND MDSplus_ROOT ${_MDSplus_etc_mdsplus_dir})
    endif()

    list(APPEND MDSplus_ROOT "/usr/local/mdsplus")
endif()

find_path(
    MDSplus_INCLUDE_DIRS
    NAMES mdsplus/mdsconfig.h
    PATH_SUFFIXES include
)

find_path(
    MDSplus_LIBRARY_DIRS
    NAMES
        lib
        ${_MDSplus_lib_arch}
)

find_library(
    MDSplus_MdsShr_LIBRARY
    NAMES MdsShr
    PATH_SUFFIXES
        lib
        ${_MDSplus_lib_arch}
)

find_library(
    MDSplus_TreeShr_LIBRARY
    NAMES TreeShr
    PATH_SUFFIXES
        lib
        ${_MDSplus_lib_arch}
)

find_library(
    MDSplus_TdiShr_LIBRARY
    NAMES TdiShr
    PATH_SUFFIXES
        lib
        ${_MDSplus_lib_arch}
)

find_library(
    MDSplus_MdsLib_LIBRARY
    NAMES MdsLib
    PATH_SUFFIXES
        lib
        ${_MDSplus_lib_arch}
)

find_library(
    MDSplus_MdsObjectsCppShr_LIBRARY
    NAMES MdsObjectsCppShr
    PATH_SUFFIXES
        lib
        ${_MDSplus_lib_arch}
)

find_path(
    MDSplus_PYTHONPATH
    NAMES MDSplus/__init__.py
    PATH_SUFFIXES python
)

find_program(
    MDSplus_tditest_EXECUTABLE
    NAMES tditest
    PATH_SUFFIXES bin ${_MDSplus_bin_arch}
)

find_program(
    MDSplus_tdic_EXECUTABLE
    NAMES tdic
    PATH_SUFFIXES bin ${_MDSplus_bin_arch}
)

find_program(
    MDSplus_mdstcl_EXECUTABLE
    NAMES mdstcl
    PATH_SUFFIXES bin ${_MDSplus_bin_arch}
)

find_program(
    MDSplus_mdsdcl_EXECUTABLE
    NAMES mdsdcl
    PATH_SUFFIXES bin ${_MDSplus_bin_arch}
)

find_program(
    MDSplus_setevent_EXECUTABLE
    NAMES setevent
    PATH_SUFFIXES bin ${_MDSplus_bin_arch}
)

find_program(
    MDSplus_wfevent_EXECUTABLE
    NAMES wfevent
    PATH_SUFFIXES bin ${_MDSplus_bin_arch}
)

find_program(
    MDSplus_dwscope_EXECUTABLE
    NAMES dwscope
    PATH_SUFFIXES bin ${_MDSplus_bin_arch}
)

find_program(
    MDSplus_traverser_EXECUTABLE
    NAMES traverser
    PATH_SUFFIXES bin ${_MDSplus_bin_arch}
)

find_program(
    MDSplus_jScope_EXECUTABLE
    NAMES jScope
    PATH_SUFFIXES bin ${_MDSplus_bin_arch}
)

find_program(
    MDSplus_jTraverser_EXECUTABLE
    NAMES jTraverser
    PATH_SUFFIXES bin ${_MDSplus_bin_arch}
)

find_program(
    MDSplus_jTraverser2_EXECUTABLE
    NAMES jTraverser2
    PATH_SUFFIXES bin ${_MDSplus_bin_arch}
)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
    MDSplus
    HANDLE_COMPONENTS
    REQUIRED_VARS
        MDSplus_INCLUDE_DIRS
        MDSplus_LIBRARY_DIRS
        MDSplus_MdsShr_LIBRARY
        MDSplus_TreeShr_LIBRARY
        MDSplus_TdiShr_LIBRARY
        MDSplus_MdsLib_LIBRARY
        MDSplus_MdsObjectsCppShr_LIBRARY
        MDSplus_tditest_EXECUTABLE
        MDSplus_tdic_EXECUTABLE
        MDSplus_mdstcl_EXECUTABLE
        MDSplus_mdsdcl_EXECUTABLE
        MDSplus_setevent_EXECUTABLE
        MDSplus_wfevent_EXECUTABLE
)

if(MDSplus_FOUND)

    add_library(MDSplus::Dynamic INTERFACE IMPORTED)

    set_target_properties(
        MDSplus::Dynamic
        PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES "${MDSplus_INCLUDE_DIRS}"
    )

    add_library(MDSplus::MdsShr INTERFACE IMPORTED)

    set_target_properties(
        MDSplus::MdsShr
        PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES "${MDSplus_INCLUDE_DIRS}"
            INTERFACE_LINK_LIBRARIES "${MDSplus_MdsShr_LIBRARY}"
    )

    add_library(MDSplus::TreeShr INTERFACE IMPORTED)

    set_target_properties(
        MDSplus::TreeShr
        PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES "${MDSplus_INCLUDE_DIRS}"
            INTERFACE_LINK_LIBRARIES "${MDSplus_TreeShr_LIBRARY}"
    )

    add_library(MDSplus::TdiShr INTERFACE IMPORTED)

    set_target_properties(
        MDSplus::TdiShr
        PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES "${MDSplus_INCLUDE_DIRS}"
            INTERFACE_LINK_LIBRARIES "${MDSplus_TdiShr_LIBRARY}"
    )

    add_library(MDSplus::MdsLib INTERFACE IMPORTED)

    set_target_properties(
        MDSplus::MdsLib
        PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES "${MDSplus_INCLUDE_DIRS}"
            INTERFACE_LINK_LIBRARIES "${MDSplus_MdsLib_LIBRARY}"
    )

    add_library(MDSplus::MdsObjectsCppShr INTERFACE IMPORTED)

    set_target_properties(
        MDSplus::MdsObjectsCppShr
        PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES "${MDSplus_INCLUDE_DIRS}"
            INTERFACE_LINK_LIBRARIES "${MDSplus_MdsObjectsCppShr_LIBRARY}"
    )

endif()