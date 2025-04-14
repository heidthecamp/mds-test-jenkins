# FindReadline.cmake
#
# Finds libreadline and libhistory
#
# This will define the following variables
#
#   Readline_FOUND
#   Readline_INCLUDE_DIRS
#   Readline_LIBRARIES
#   Readline_readline_LIBRARY
#   Readline_history_LIBRARY
#
# and the following imported targets
#
#   Readline::Readline
#
# The following variables can be set as arguments
#
#   Readline_ROOT
#

find_package(PkgConfig QUIET)

pkg_check_modules(_Readline_PC QUIET readline)

find_path(
    Readline_INCLUDE_DIRS
    NAMES readline/readline.h
    HINTS
        ${_Readline_PC_INCLUDE_DIRS}
    PATH_SUFFIXES
        include
)

file(READ ${Readline_INCLUDE_DIRS}/readline/readline.h _Readline_header)

# TODO: Improve?
# e.g. #define RL_READLINE_VERSION 0x0802 // Version 8.2
if(_Readline_header MATCHES "RL_READLINE_VERSION[ \t\r\n]*(0x[0-9A-Fa-f]+)")
    math(EXPR _Readline_MAJOR_VERSION "${CMAKE_MATCH_1} >> 8"   OUTPUT_FORMAT DECIMAL) # dec(0x0802 >> 8) = 8
    math(EXPR _Readline_MINOR_VERSION "${CMAKE_MATCH_1} & 0xFF" OUTPUT_FORMAT DECIMAL) # dec(0x0802 & 0xFF) = 2
    set(Readline_VERSION "${_Readline_MAJOR_VERSION}.${_Readline_MINOR_VERSION}") # 8.2
endif()

find_library(
    Readline_LIBRARIES
    NAMES readline
    HINTS
        ${_Readline_PC_LIBRARY_DIRS}
    PATH_SUFFIXES
        lib
)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
    Readline
    VERSION_VAR Readline_VERSION
    REQUIRED_VARS
        Readline_LIBRARIES
        Readline_INCLUDE_DIRS
)

# RL_READLINE_VERSION

if(Readline_FOUND)

    if(NOT TARGET Readline::Readline)

        add_library(Readline::Readline INTERFACE IMPORTED)

        set_target_properties(
            Readline::Readline
            PROPERTIES
                INTERFACE_LINK_LIBRARIES "${Readline_LIBRARIES}"
                INTERFACE_INCLUDE_DIRECTORIES "${Readline_INCLUDE_DIRS}"
        )

    endif()

endif()

mark_as_advanced(
    Readline_INCLUDE_DIRS
    Readline_LIBRARIES
)
