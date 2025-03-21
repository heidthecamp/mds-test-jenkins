include_guard(GLOBAL)

set(MDSPLUS_TEST_INDEX 0 CACHE STRING "" FORCE)

#
# mdsplus_add_test(NAME <name>
#                  COMMAND <command> [<arg>...])
#                  [WORKING_DIRECTORY <dir>]
#                  [ENVIRONMENT_MODIFICATIONS <mods>]
#                  [NO_VALGRIND]
#                  [NO_WINE])
#
# Call add_test() and set_tests_properties() to configure all of the test's properties.
#
# If ENABLE_VALGRIND=ON and NO_VALGRIND is not set, then another test will be added
# for each tool in Valgrind_TOOL_LIST.
#
# If GENERATE_VSCODE_LAUNCH_JSON=ON, then deploy/add-launch-target.py will be called
# for each test as well.
#
# https://cmake.org/cmake/help/latest/command/add_test.html
# https://cmake.org/cmake/help/latest/prop_test/ENVIRONMENT_MODIFICATION.html
#
if(GENERATE_VSCODE_LAUNCH_JSON AND NOT TARGET generate-vscode-launch-json)
    add_custom_target(generate-vscode-launch-json)
    set(LAST_VSCODE_LAUNCH_JSON_TARGET "generate-vscode-launch-json" CACHE INTERNAL "" FORCE)
endif()

function(mdsplus_add_test)

    cmake_parse_arguments(
        PARSE_ARGV 0 ARGS
        # Booleans
        "NO_VALGRIND;NO_WINE"
        # Single-Value
        "NAME;WORKING_DIRECTORY;TEST_LIST_VARIABLE"
        # Multi-Value
        "COMMAND;ENVIRONMENT_MODIFICATION"
    )

    if(NOT DEFINED ARGS_WORKING_DIRECTORY)
        set(ARGS_WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})
    endif()

    set(_env_mods
        # Used to find the rest of MDSplus
        "MDSPLUS_DIR=set:${CMAKE_SOURCE_DIR}"
        "MDSPLUS_LIBRARY_PATH=set:${CMAKE_LIBRARY_OUTPUT_DIRECTORY}"

        # Used to search for TDI and Python scripts, and to add TDI drivers
        "MDS_PATH=set:${CMAKE_SOURCE_DIR}/tdi"
        
        # Some tests define their own TDI functions
        "MDS_PATH=cmake_list_prepend:${CMAKE_CURRENT_SOURCE_DIR}"

        # Used to run or load Python
        "PYTHON=set:${PYTHON}"
        "PyLib=set:${PyLib}"

        # Needed for `import MDSplus` in Python
        "PYTHONPATH=set:${CMAKE_SOURCE_DIR}/python"

        # Needed to add Python drivers 
        "MDS_PYDEVICE_PATH=set:${CMAKE_SOURCE_DIR}/pydevices"

        # Needed to run MDSplus executables
        "PATH=path_list_prepend:${CMAKE_RUNTIME_OUTPUT_DIRECTORY}"

        # Several tests make use of the default trees
        "main_path=set:${CMAKE_SOURCE_DIR}/trees"
        "subtree_path=set:${CMAKE_SOURCE_DIR}/trees/subtree"

        # Write all new tree files into the current directory
        "default_tree_path=set:."

        ${SANITIZER_ENV_MODS}
    )

    if(WIN32)

        list(APPEND _env_mods
            "OS=set:windows" # for do_tditests.sh
        )
        
        if(TEST_WITH_WINE)
            # These are used even if NO_WINE is set for do_tditests.sh
            list(APPEND _env_mods
                "WINEDEBUG=set:-all"
                "WINEARCH=set:${WINEARCH}"
                "WINEPREFIX=set:${WINEPREFIX}"
                "WINEPATH=cmake_list_prepend:${CMAKE_RUNTIME_OUTPUT_DIRECTORY}"
                # https://askubuntu.com/questions/323437/how-to-prevent-wine-from-adding-file-associations
                "WINEDLLOVERRIDES=set:winemenubuilder.exe=d,explorer.exe=d"

                # Don't inherit the system python environment
                "PYTHONHOME=unset:"
            )

            if(NOT ARGS_NO_WINE)
                list(PREPEND ARGS_COMMAND ${wine_EXECUTABLE})
            endif()
        endif()

    else()

        # Linux searches $LD_LIBRARY_PATH for loading .so's
        # This is set for Apple as well for backwards compatibility
        list(APPEND _env_mods
            "LD_LIBRARY_PATH=path_list_prepend:${CMAKE_LIBRARY_OUTPUT_DIRECTORY}"
            
            # Sometimes required by the sanitizers
            "LD_PRELOAD=set:${LD_PRELOAD}"
        )

        if(APPLE)
            # Apple searches $DYLD_LIBRARY_PATH for loading .dylib's
            list(APPEND _env_mods
                "DYLD_LIBRARY_PATH=path_list_prepend:${CMAKE_LIBRARY_OUTPUT_DIRECTORY}"
            )
        endif()
        
    endif()

    set(_index ${MDSPLUS_TEST_INDEX})
    math(EXPR _event_port "4000 + ${_index}")

    list(APPEND _env_mods ${ARGS_ENVIRONMENT_MODIFICATION})

    set(_base_env_mods
        ${_env_mods}
        "TEST_INDEX=set:${_index}"
        "mdsevent_port=set:${_event_port}"
        "MDSIP_CLIENT_LOCAL_LOGFILE=set:${CMAKE_CURRENT_BINARY_DIR}/mdsip-local-${ARGS_NAME}-${_index}.log"
    )

    file(RELATIVE_PATH _path ${CMAKE_SOURCE_DIR} ${CMAKE_CURRENT_SOURCE_DIR})
    string(REPLACE "\\" "/" _path "${_path}")

    set(_target "${_path}/${ARGS_NAME}")

    set(_target_list "${_target}")

    add_test(
        NAME ${_target}
        COMMAND ${ARGS_COMMAND}
        WORKING_DIRECTORY ${ARGS_WORKING_DIRECTORY}
    )
    
    set_tests_properties(
        ${_target}
        PROPERTIES
            ENVIRONMENT_MODIFICATION "${_base_env_mods}"
            FAIL_REGULAR_EXPRESSION "FAILED"
    )

    math(EXPR _index "${_index} + 1")

    if(GENERATE_VSCODE_LAUNCH_JSON)
        string(REPLACE "/" "-" _vscode_launch_target "generate-vscode-launch-json-${_target}")

        add_custom_target(
            "${_vscode_launch_target}"
            COMMENT "Adding ${_target} to .vscode/launch.json"
            COMMAND ${Python_EXECUTABLE} deploy/add-launch-target.py
                --name "${_target}"
                --command "\"${ARGS_COMMAND}\""
                --environment "\"${_base_env_mods}\""
                --cwd "${ARGS_WORKING_DIRECTORY}"
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        )

        # We chain the dependencies to force them to run in serial
        add_dependencies("${LAST_VSCODE_LAUNCH_JSON_TARGET}" "${_vscode_launch_target}")
        set(LAST_VSCODE_LAUNCH_JSON_TARGET "${_vscode_launch_target}" CACHE INTERNAL "" FORCE)
    endif()

    if(ENABLE_VALGRIND AND NOT ARGS_NO_VALGRIND)

        set(_valgrind_flags ${Valgrind_FLAGS})
        foreach(_supp IN LISTS Valgrind_SUPPRESSION_FILES)
            list(APPEND _valgrind_flags "--suppressions=${_supp}")
        endforeach()

        # Each variant of tests gets a unique port range
        set(_test_port_offset 1000)

        foreach(_tool IN LISTS Valgrind_TOOL_LIST)
            set(_target_tool "${_target}-${_tool}")
        list(APPEND _target_list "${_target_tool}")

            string(REPLACE "-" "_" _tool_no_dash ${_tool})

            file(MAKE_DIRECTORY ${ARGS_WORKING_DIRECTORY}/${_tool})

            add_test(
                NAME "${_target_tool}"
                COMMAND ${Valgrind_EXECUTABLE} --tool=${_tool} --quiet ${_valgrind_flags} ${Valgrind_${_tool_no_dash}_FLAGS} ${ARGS_COMMAND}
                WORKING_DIRECTORY ${ARGS_WORKING_DIRECTORY}/${_tool}
            )

            math(EXPR _event_port "4000 + ${_index}")

            set(_valgrind_env_mods
                ${_env_mods}
                "TEST_INDEX=set:${_index}"
                "TEST_PORT_OFFSET=set:${_test_port_offset}"
                "mdsevent_port=set:${_event_port}"
                "MDSIP_CLIENT_LOCAL_LOGFILE=set:${CMAKE_CURRENT_BINARY_DIR}/mdsip-local-${ARGS_NAME}-${_index}.log"
            )

            set_tests_properties(
                "${_target_tool}"
                PROPERTIES
                    ENVIRONMENT_MODIFICATION "${_valgrind_env_mods}"
                    FAIL_REGULAR_EXPRESSION "FAILED"
            )

            math(EXPR _index "${_index} + 1")
            math(EXPR _test_port_offset "${_test_port_offset} + 1000")
        endforeach()
        
    endif()

    set(MDSPLUS_TEST_INDEX "${_index}" CACHE STRING "" FORCE)

    if (DEFINED ARGS_TEST_LIST_VARIABLE)
        set(${ARGS_TEST_LIST_VARIABLE} "${_target_list}" PARENT_SCOPE)
    endif()

endfunction()

if(NOT WIN32)
    set(_test_env_filename "${CMAKE_BINARY_DIR}/test-env.sh")
    file(WRITE ${_test_env_filename}
        "#!/bin/bash\n"
        "export MDSPLUS_DIR=${CMAKE_SOURCE_DIR}\n"
        "export MDS_PATH=${CMAKE_SOURCE_DIR}/tdi\n"
        "export PyLib=${Python_LIBRARIES}\n"
        "export PYTHONPATH=${CMAKE_SOURCE_DIR}/python\n"
        "export MDS_PYDEVICE_PATH=${CMAKE_SOURCE_DIR}/pydevices\n"
        "export PATH=${CMAKE_RUNTIME_OUTPUT_DIRECTORY}:$PATH\n"
        "export LD_LIBRARY_PATH=${CMAKE_LIBRARY_OUTPUT_DIRECTORY}\n"
        "export main_path=${CMAKE_SOURCE_DIR}/trees\n"
        "export subtree_path=${CMAKE_SOURCE_DIR}/trees/subtree\n"
        "/bin/bash --init-file <(echo \"PS1='MDSplus Test $ '\")\n"
    )
    # TODO: Improve
    file(CHMOD ${_test_env_filename}
        PERMISSIONS
            OWNER_READ OWNER_WRITE OWNER_EXECUTE
            GROUP_READ             GROUP_EXECUTE
            WORLD_READ             WORLD_EXECUTE
    )
endif()