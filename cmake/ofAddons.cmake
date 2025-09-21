include("${OF_CMAKE_DIRECTORY}/ofUtils.cmake")

######## ADDONS #######################
function(of_addon ADDON_NAME)

# if(DEFINED MY_VAR AND NOT "${MY_VAR}" STREQUAL ""
    if( NOT DEFINED OF_PROJECT_NAME )
        message( FATAL_ERROR "ofAddons.cmake :: of_addon : OF_PROJECT_NAME must be set before calling this function")
    endif()

    of_check_of_root_path()
    of_set_global_os_vars()

    set(ADDON_ROOT "${OF_ROOT_DIRECTORY}/addons/${ADDON_NAME}")

    #TODO: If the addon does not exist, maybe we could use fetch content?
    if(EXISTS "${ADDON_ROOT}")
        
        # check for a make config file for support until transition to CMakeLists.txt 
        if(EXISTS "${ADDON_ROOT}/CMakeLists.txt") 
            # add the addon here via CMakeLists
            # TODO: Check functionality
            add_subdirectory("${ADDON_ROOT}" "${OF_CMAKE_BUILD_DIRECTORY}") 
        else()
            message(VERBOSE "--------------------------------------------" )
            message(VERBOSE "--------------------------------------------" )
            message(VERBOSE "of_addon ${ADDON_NAME}" )      
            
            set(LIB_ADDON ${ADDON_NAME})
            # add_library(${LIB_ADDON} INTERFACE)
            
            set(TMP_OS_TAG ${OF_OS_TAG_LOWER} )
            # set(TMP_OS_TAG "linux64" )

            # message(VERBOSE "of_addon ${ADDON_NAME}: Going to parse include directories")
            # # of_get_all_subdirectories("${ADDON_ROOT}/libs" PARSED_INCLUDES)
            set(PARSED_INCLUDES_ABS "")
            if( EXISTS "${ADDON_ROOT}/src" )
                of_get_subdirs_recursive("${ADDON_ROOT}/src" PARSED_INCLUDES_ABS)
                list(APPEND PARSED_INCLUDES_ABS "${ADDON_ROOT}/src" )
            endif()

            # message(VERBOSE "of_addon ${ADDON_NAME}: Going to parse addon includes via directories")
            # of_get_all_header_files(${ADDON_ROOT} PARSED_ADDON_HEADERS )

            message(VERBOSE "of_addon ${ADDON_NAME}: Going to parse addon includes via directories")
            # of_get_all_source_files(${ADDON_ROOT}, PARSED_ADDON_SRC_FILES )
            # of_get_all_source_files("${ADDON_ROOT}/src", PARSED_ADDON_SRC_FILES)
            of_get_all_source_files(${ADDON_ROOT} PARSED_ADDON_SRC_FILES_ABS)
            # file(GLOB_RECURSE PARSED_ADDON_SRC_FILES "${ADDON_ROOT}/*.cpp")

            message(VERBOSE "--------------------------------------------")
            of_print_list(PARSED_ADDON_SRC_FILES_ABS PREFIX "  📜 PARSED_ADDON_SRC_FILES_ABS: " LEVEL VERBOSE)


            message(VERBOSE "of_addon ${ADDON_NAME}: Going to parse libraries via directories")

            
            # message(VERBOSE "of_addon ${ADDON_NAME}: Going to parse include directories")
            # set(PARSED_INCLUDES_ABS "")
            # if( EXISTS "${ADDON_ROOT}/src" )
            #     list(APPEND PARSED_INCLUDES_ABS "${ADDON_ROOT}/src" )
            # endif()
            # of_get_all_subdirectories("${ADDON_ROOT}/libs" PARSED_INCLUDES)
            # of_get_subdirs_recursive("${ADDON_ROOT}/libs" OUT_DIRS)
            
            set(PARSED_ADDON_LIBS_ABS "" )
            #parse based on the directory structure
            file(GLOB PARSED_ADDON_LIBS_DIRECTORIES CONFIGURE_DEPENDS "${ADDON_ROOT}/libs/*")
            foreach(lib_dir ${PARSED_ADDON_LIBS_DIRECTORIES})
                # if( EXISTS "${lib_dir}/include" )
                #     of_get_subdirs_recursive("${lib_dir}/include" TMP_PARSED_DIRS)
                #     list(APPEND PARSED_INCLUDES_ABS ${TMP_PARSED_DIRS} )
                #     list(APPEND PARSED_INCLUDES_ABS "${lib_dir}/include" )
                #     # the addons are not all structured the same, so sometimes there are header files in a src directory.
                #     # so we may need to add every directory as an include 
                # endif()
                # lets loop through and exclude the lib directory
                file(GLOB TMP_ADDON_LIBS_LIB_DIRECTORIES CONFIGURE_DEPENDS "${lib_dir}/*")
                list(TRANSFORM TMP_ADDON_LIBS_LIB_DIRECTORIES REPLACE "\\\\" "/")   # CMake 3.16 OK
                # don't consider listing directories named lib or license
                list(FILTER TMP_ADDON_LIBS_LIB_DIRECTORIES EXCLUDE REGEX "(^|/)(lib|license)/?$")
                foreach(lib_lib_dir ${TMP_ADDON_LIBS_LIB_DIRECTORIES})
                    if(IS_DIRECTORY "${lib_lib_dir}")
                        # message(STATUS "ADDON LIB LIB DIRECTORY ${lib_lib_dir}")
                        of_get_subdirs_recursive("${lib_lib_dir}" TMP_PARSED_DIRS)
                        list(APPEND PARSED_INCLUDES_ABS ${TMP_PARSED_DIRS} )
                        list(APPEND PARSED_INCLUDES_ABS ${lib_lib_dir} )
                    endif()
                endforeach()
                # if( EXISTS "${lib_dir}" )
                #     of_get_subdirs_recursive("${lib_dir}" TMP_PARSED_DIRS)
                #     list(APPEND PARSED_INCLUDES_ABS ${TMP_PARSED_DIRS} )
                #     # list(APPEND PARSED_INCLUDES_ABS "${lib_dir}/include" )
                #     # the addons are not all structured the same, so sometimes there are header files in a src directory.
                #     # so we may need to add every directory as an include 
                # endif()
                # message(VERBOSE "of_addon ${ADDON_NAME}: PARSED_INCLUDES_ABS: ${PARSED_INCLUDES_ABS}")

            #     # TODO: Break Frameworks out of of_add_library_from_directory
                # message(VERBOSE "of_addon ${ADDON_NAME}: Reading lib dir: ${lib_dir}")
                of_get_static_libs_from_directory(${lib_dir} TMP_PARSED_ADDON_LIBS )
                list(APPEND PARSED_ADDON_LIBS_ABS ${TMP_PARSED_ADDON_LIBS} )
                # message(VERBOSE "of_addon ${ADDON_NAME}: TMP_PARSED_ADDON_LIBS: ${TMP_PARSED_ADDON_LIBS}")
            #     #of_add_library_from_directory(${lib_dir} OUT_LIBS_ADDED)
            #     #list(APPEND PARSED_ADDON_LIBS ${OUT_LIBS_ADDED} )
            endforeach()

            # message(STATUS "--------------------------------------------")
            #of_make_filespaths_relative REL_PATH IN_VARS OUT_VAR
            # message(VERBOSE "of_addon ${ADDON_NAME}: PARSED_INCLUDES_ABS: ${PARSED_INCLUDES_ABS}")
            of_print_list(PARSED_INCLUDES_ABS PREFIX "  • PARSED_INCLUDES_ABS: " LEVEL VERBOSE)
            of_make_filespaths_relative("${ADDON_ROOT}" "${PARSED_INCLUDES_ABS}" PARSED_INCLUDES )

            of_make_filespaths_relative("${ADDON_ROOT}" "${PARSED_ADDON_SRC_FILES_ABS}" PARSED_ADDON_SRC_FILES )
            
            # message(VERBOSE "of_addon ${ADDON_NAME}: PARSED_INCLUDES: ${PARSED_INCLUDES}")
            # of_print_list(PARSED_INCLUDES PREFIX "  • Include: " LEVEL VERBOSE)

            # message(STATUS "--------------------------------------------")
            of_make_filespaths_relative("${ADDON_ROOT}" "${PARSED_ADDON_LIBS_ABS}" PARSED_ADDON_LIBS )
            # of_print_list(PARSED_ADDON_LIBS PREFIX "  • Libs: " LEVEL VERBOSE)

            # message(FATAL_ERROR "TRYING ADDONS")

            set(ADDON_PKG_CONFIG_LIBRARIES "")
            set(ADDON_LIBS "${PARSED_ADDON_LIBS}")
            set(ADDON_INCLUDES "${PARSED_INCLUDES}")
            set(ADDON_LIBS_EXCLUDE "")
            set(ADDON_LDFLAGS "")
            set(ADDON_FRAMEWORKS "")
            set(ADDON_SOURCES "${PARSED_ADDON_SRC_FILES}")
            set(ADDON_INCLUDES_EXCLUDE "")

            message(VERBOSE "--------------------------------------------")
            message(VERBOSE "xx before parsing .mk --------------------------------------------")
            of_print_list(ADDON_INCLUDES PREFIX "  📂 ADDON_INCLUDES: " LEVEL VERBOSE)


            message(VERBOSE "of_addon ${ADDON_NAME}: ADDON LIBS PRE CONGIG: ${ADDON_LIBS}")

            # message(DEPRECATION "of_addon ${ADDON_NAME} - Update addon_config.mk to CMakeLists.txt")
            # seems a bit repetitive, but we should be phasing out make files...
            if( EXISTS "${ADDON_ROOT}/addon_config.mk" )
                message(VERBOSE "of_addon ${ADDON_NAME}: PARSING: ${ADDON_ROOT}/addon_config.mk for 'common'")
                read_mk_section_vars( "${ADDON_ROOT}/addon_config.mk" "common"
                    ADDON_PKG_CONFIG_LIBRARIES
                    ADDON_LIBS
                    ADDON_LIBS_EXCLUDE
                    ADDON_INCLUDES_EXCLUDE
                    ADDON_SOURCES_EXCLUDE
                    ADDON_LDFLAGS
                    ADDON_FRAMEWORKS
                    ADDON_INCLUDES
                )

                message(VERBOSE "of_addon ${ADDON_NAME}: PARSING: ${ADDON_ROOT}/addon_config.mk for '${TMP_OS_TAG}'")
                read_mk_section_vars( "${ADDON_ROOT}/addon_config.mk" "${TMP_OS_TAG}"
                    ADDON_PKG_CONFIG_LIBRARIES
                    ADDON_LIBS
                    ADDON_LIBS_EXCLUDE
                    ADDON_INCLUDES_EXCLUDE
                    ADDON_SOURCES_EXCLUDE
                    ADDON_LDFLAGS
                    ADDON_FRAMEWORKS
                    ADDON_INCLUDES
                )

                if(OF_OS_MACOS)
                    message(VERBOSE "of_addon ${ADDON_NAME}: PARSING: ${ADDON_ROOT}/addon_config.mk for 'osx'")
                    read_mk_section_vars( "${ADDON_ROOT}/addon_config.mk" "osx"
                        ADDON_PKG_CONFIG_LIBRARIES
                        ADDON_LIBS
                        ADDON_LIBS_EXCLUDE
                        ADDON_INCLUDES_EXCLUDE
                        ADDON_SOURCES_EXCLUDE
                        ADDON_LDFLAGS
                        ADDON_FRAMEWORKS
                        ADDON_INCLUDES
                )
                endif()
            endif()

            # message(VERBOSE "--------------------------------------------")
            # of_print_list(ADDON_PKG_CONFIG_LIBRARIES PREFIX "  • PKG_CONFIG_LIBRARIES: " LEVEL VERBOSE)
            message(VERBOSE "--------------------------------------------")
            of_print_list(ADDON_SOURCES_EXCLUDE PREFIX "  • ADDON_SOURCES_EXCLUDE: " LEVEL VERBOSE)

            # message(VERBOSE "--------------------------------------------")
            # of_print_list(ADDON_INCLUDES PREFIX "  • Before exclude - Include: " LEVEL VERBOSE)
            # message(VERBOSE "--------------------------------------------")
            # of_print_list(ADDON_INCLUDES_EXCLUDE PREFIX "  • Before exclude Exclude Include: " LEVEL VERBOSE)

            ## -- EXCLUDE ------
            # set(TMP_INCLUDE_DIRECTORIES ${PARSED_INCLUDE_DIRECTORIES})
            if(ADDON_INCLUDES_EXCLUDE)
                # of_exclude_paths_from_list("${ADDON_INCLUDES}" "${ADDON_INCLUDES_EXCLUDE}" TMP_DIR_FILES_FILTERED)
                of_filter_paths_by_patterns(ADDON_INCLUDES ADDON_INCLUDES_EXCLUDE TMP_DIR_FILES_FILTERED)
                # Replace original list with filtered one
                set(ADDON_INCLUDES ${TMP_DIR_FILES_FILTERED})
            endif()

            # message(VERBOSE "--------------------------------------------")
            # of_print_list(ADDON_INCLUDES PREFIX "  • Filtered Include: " LEVEL VERBOSE)


            if(ADDON_SOURCES_EXCLUDE)
                # of_exclude_paths_from_list("${ADDON_INCLUDES}" "${ADDON_INCLUDES_EXCLUDE}" TMP_DIR_FILES_FILTERED)
                of_filter_paths_by_patterns(ADDON_SOURCES ADDON_SOURCES_EXCLUDE TMP_SRC_FILES_FILTERED)
                # Replace original list with filtered one
                set(ADDON_SOURCES ${TMP_SRC_FILES_FILTERED})
            endif()

            # message(VERBOSE "--------------------------------------------")
            # of_print_list(ADDON_LIBS PREFIX "  • Library: " LEVEL VERBOSE)
            # message(VERBOSE "--------------------------------------------")
            # of_print_list(ADDON_LIBS_EXCLUDE PREFIX "  • Exclude Library: " LEVEL VERBOSE)
            # set(TMP_INC_LIBS ${PARSED_ADDON_LIBS} ${ADDON_LIBS})
            if(ADDON_LIBS_EXCLUDE)
                #  of_exclude_paths_from_list("${ADDON_LIBS}" "${ADDON_LIBS_EXCLUDE}" TMP_LIBS_FILTERED)
                of_filter_paths_by_patterns(ADDON_LIBS ADDON_LIBS_EXCLUDE TMP_LIBS_FILTERED)
                # Replace original list with filtered one
                set(ADDON_LIBS ${TMP_LIBS_FILTERED})
            endif()
            # message(VERBOSE "--------------------------------------------")
            # of_print_list(ADDON_LIBS PREFIX "  • Filtered Library: " LEVEL VERBOSE)


            # message(VERBOSE "${ADDON_NAME} - ${TMP_OS_TAG} ADDON_PKG_CONFIG_LIBRARIES: ${ADDON_PKG_CONFIG_LIBRARIES}")

            # message(VERBOSE "${ADDON_NAME} - ${TMP_OS_TAG} ADDON_LIBS: ${ADDON_LIBS}")
            # message(VERBOSE "${ADDON_NAME} - ${TMP_OS_TAG} ADDON_LIBS_EXCLUDE: ${ADDON_LIBS_EXCLUDE}")

            # message(VERBOSE "${ADDON_NAME} - ${TMP_OS_TAG} PARSED_INCLUDES: ${PARSED_INCLUDES}")
            # message(VERBOSE "${ADDON_NAME} - ${TMP_OS_TAG} ADDON_INCLUDES: ${ADDON_INCLUDES}")
            # message(VERBOSE "${ADDON_NAME} - ${TMP_OS_TAG} ADDON_INCLUDES_EXCLUDE: ${ADDON_INCLUDES_EXCLUDE}")
            
            # message(VERBOSE "${ADDON_NAME} - ${TMP_OS_TAG} ADDON_LDFLAGS: ${ADDON_LDFLAGS}")
            # osx/iOS only, any framework that should be included in the project
            # message(VERBOSE "${ADDON_NAME} - ${TMP_OS_TAG} ADDON_FRAMEWORKS: ${ADDON_FRAMEWORKS}")

            # message(VERBOSE "--------------------------------------------")
            # of_print_list(ADDON_HEADER_FILES PREFIX "  📂 HEADERS AND SOURCE: " LEVEL VERBOSE)

            
            message(VERBOSE "--------------------------------------------")
            of_make_absolute("${ADDON_ROOT}" "${ADDON_INCLUDES}" ADDON_INCLUDES )
            of_make_absolute("${ADDON_ROOT}" "${ADDON_LIBS}" ADDON_LIBS )


            message(VERBOSE "--------------------------------------------")
            set(ADDON_HEADER_FILES "" )
            # grab headers from the include directories 
            foreach(lib_inc_dir ${ADDON_INCLUDES})
                # loop through and get all the header files 
                of_get_all_header_files(${lib_inc_dir} TMP_OUT_HEADERS )
                list(APPEND ADDON_HEADER_FILES ${TMP_OUT_HEADERS})
            endforeach()
            set( TMP_HEADER_AND_SOURCE_FILES ${ADDON_SOURCES} ${ADDON_HEADER_FILES} )
            of_make_absolute("${ADDON_ROOT}" "${TMP_HEADER_AND_SOURCE_FILES}" TMP_HEADER_AND_SOURCE_FILES )

            # message(VERBOSE "--------------------------------------------")
            # of_print_list(TMP_HEADER_AND_SOURCE_FILES PREFIX "  📂 TMP_HEADER_AND_SOURCE_FILES: " LEVEL VERBOSE)

            message(VERBOSE "--------------------------------------------")
            of_print_list(ADDON_INCLUDES PREFIX "  📂 ADDON_INCLUDES: " LEVEL VERBOSE)

            message(VERBOSE "--------------------------------------------")
            of_print_list(ADDON_SOURCES PREFIX "  📜 ADDON_SOURCES: " LEVEL VERBOSE)
            # of_print_list(PARSED_ADDON_SRC_FILES PREFIX "  📜 PARSED_ADDON_SRC_FILES: " LEVEL VERBOSE)

            message(VERBOSE "--------------------------------------------")
            of_print_list(ADDON_LIBS PREFIX "  📚 ADDON_LIBS: " LEVEL VERBOSE)

            # message(VERBOSE "--------------------------------------------")
            # of_print_list(ADDON_LIBS PREFIX "  • ADDON_INCLUDES: " LEVEL VERBOSE)



            #working, but not great in ide
            target_include_directories(${OF_PROJECT_NAME} PRIVATE ${ADDON_INCLUDES})
            target_link_libraries(${OF_PROJECT_NAME} PRIVATE ${ADDON_LIBS} )
            #---- IDE ---------------------
            target_sources(${OF_PROJECT_NAME} PRIVATE ${TMP_HEADER_AND_SOURCE_FILES})
            source_group(
                TREE   "${ADDON_ROOT}"
                PREFIX "addons/${ADDON_NAME}"
                FILES  ${TMP_HEADER_AND_SOURCE_FILES}
            )
            #---- !IDE! ---------------------
            



            # target_include_directories(${OF_ADDONS} INTERFACE ${ADDON_INCLUDES})
            # target_link_libraries(${OF_PROJECT_NAME} ${ADDON_LIBS} )
            # #---- IDE ---------------------
            # target_sources(${OF_ADDONS} INTERFACE ${TMP_HEADER_AND_SOURCE_FILES})
            # source_group(
            #     TREE   "${ADDON_ROOT}"
            #     PREFIX "addons/${ADDON_NAME}"
            #     FILES  ${TMP_HEADER_AND_SOURCE_FILES}
            # )
            # #---- !IDE! ---------------------
        endif()

        
    else()
        message( WARNING "Could not find addon ${ADDON_NAME} at ${ADDON_ROOT}" )
    endif()


    message(VERBOSE "--------------------------------------------" )

    # if(EXISTS "${OF_ROOT_DIRECTORY}/addons/${ADDON_NAME}")
    #     file(STRINGS "${OF_ROOT_DIRECTORY}/addons/${ADDON_NAME}/addon_config.mk" ADDON_MK_CONTENTS)
    #     foreach(line IN LISTS ADDON_MK_CONTENTS)
    #         if(line MATCHES "^([A-Za-z0-9_]+):")
    #             set(current_section "${CMAKE_MATCH_1}")
    #         elseif(line MATCHES "^[ \t]*ADDON_PKG_CONFIG_LIBRARIES[ \t]*=(.*)")
    #             string(STRIP "${CMAKE_MATCH_1}" libs)
    #             if(current_section STREQUAL "linux64")
    #                 separate_arguments(libs)
    #                 set(ADDON_PKG_CONFIG_LIBRARIES_LINUX64 ${libs})
    #             endif()
    #         endif()
    #     endforeach()

    #     message(STATUS "Linux64 libs: ${ADDON_PKG_CONFIG_LIBRARIES_LINUX64}")

    # endif()
endfunction()
