include("${OF_CMAKE_DIRECTORY}/ofUtils.cmake")

# extract_F_dirs_from_flag_lines(<out_var> <line> [<line>...])
# - Takes lines like "-F/path ... -framework Foo" and returns the -F dirs.
function(of_extract_F_dirs_from_flag_lines OUT_VAR)
    set(_dirs "")
    foreach(line IN LISTS ARGN)
        separate_arguments(tokens NATIVE_COMMAND "${line}")
        foreach(tok IN LISTS tokens)
            if(tok MATCHES "^-F(.+)$")
                list(APPEND _dirs "${CMAKE_MATCH_1}")
            endif()
        endforeach()
    endforeach()
    list(REMOVE_DUPLICATES _dirs)

    set(F_DIRS_NORM "")
    foreach(d IN LISTS _dirs)
        string(REGEX REPLACE "/+$" "" d "${d}")
        list(APPEND F_DIRS_NORM "${d}")
    endforeach()

    set(${OUT_VAR} "${F_DIRS_NORM}" PARENT_SCOPE)
endfunction()

# collect_framework_bundles_from_F_dirs(<out_var> <F_dir> [<F_dir>...])
# - Recurses under each F_dir and returns ONLY top-level *.framework directories.
function(of_collect_framework_bundles_from_F_dirs OUT_VAR)
  set(_found "")
  foreach(root IN LISTS ARGN)
    if(NOT IS_DIRECTORY "${root}")
      continue()
    endif()
    # Recurse for paths ending in *.framework; include directories
    file(GLOB_RECURSE _cands
         LIST_DIRECTORIES true
         CONFIGURE_DEPENDS
         "${root}/*.framework")
    foreach(p IN LISTS _cands)
      if(IS_DIRECTORY "${p}" AND p MATCHES "\\.framework$")
        list(APPEND _found "${p}")
      endif()
    endforeach()
  endforeach()
  list(REMOVE_DUPLICATES _found)
  set(${OUT_VAR} "${_found}" PARENT_SCOPE)
endfunction()



######## ADDONS #######################
function(of_addon ADDON_NAME)

# if(DEFINED MY_VAR AND NOT "${MY_VAR}" STREQUAL ""
    if( NOT DEFINED OF_PROJECT_NAME )
        message( FATAL_ERROR "ofAddons.cmake :: of_addon : OF_PROJECT_NAME must be set before calling this function")
    endif()

    of_check_of_root_path()
    of_set_global_os_vars()

    if("${ADDON_NAME}" STREQUAL "")
        message(WARNING "of_addon name is EMPTY!! Not adding.")
        return()
    endif()

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

            # account for addons that aren't structured according to the libs they are meant to include
            # ie. ofxXmlSettings and ofxVectorGraphics
            if( EXISTS "${ADDON_ROOT}/libs" )
                # of_get_subdirs_recursive("${ADDON_ROOT}/src" PARSED_INCLUDES_ABS)
                list(APPEND PARSED_INCLUDES_ABS "${ADDON_ROOT}/libs" )
            endif()

            # message(VERBOSE "of_addon ${ADDON_NAME}: Going to parse addon includes via directories")
            # of_get_all_header_files(${ADDON_ROOT} PARSED_ADDON_HEADERS )

            message(VERBOSE "of_addon ${ADDON_NAME}: Going to parse addon includes via directories")
            # of_get_all_source_files(${ADDON_ROOT}, PARSED_ADDON_SRC_FILES )
            # of_get_all_source_files("${ADDON_ROOT}/src", PARSED_ADDON_SRC_FILES)
            # of_get_all_source_files(${ADDON_ROOT} PARSED_ADDON_SRC_FILES_ABS)
            of_get_all_source_files("${ADDON_ROOT}/libs" PARSED_ADDON_LIBS_SRC_FILES_ABS)
            of_get_all_source_files("${ADDON_ROOT}/src" PARSED_ADDON_SRC_FILES_ABS)
            list(APPEND PARSED_ADDON_SRC_FILES_ABS ${PARSED_ADDON_LIBS_SRC_FILES_ABS})
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
            # set(PARSED_ADDON_FRAMEWORKS_ABS "")
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
                # it would probably be fine, but adds so many extra paths to a project, ie. Xcode
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

                # try to grab a framework //
                # message(STATUS "Trying to grab frameworks from ${lib_dir}")
                # file(GLOB_RECURSE PARSED_ADDON_FRAMEWORKS_ABS 
                #     LIST_DIRECTORIES true
                #     "${lib_dir}/*.framework")
                # list(TRANSFORM PARSED_ADDON_FRAMEWORKS_ABS REPLACE "\\\\" "/")   # CMake 3.16 OK

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

            # of_make_filespaths_relative("${ADDON_ROOT}" "${PARSED_ADDON_FRAMEWORKS_ABS}" PARSED_ADDON_FRAMEWORKS)
            
            # message(VERBOSE "of_addon ${ADDON_NAME}: PARSED_INCLUDES: ${PARSED_INCLUDES}")
            # of_print_list(PARSED_INCLUDES PREFIX "  • Include: " LEVEL VERBOSE)

            # message(VERBOSE "of_addon ${ADDON_NAME}: PARSED_ADDON_FRAMEWORKS_ABS: ${PARSED_ADDON_FRAMEWORKS_ABS}")
            # of_print_list(PARSED_ADDON_FRAMEWORKS_ABS PREFIX "  • PARSED_ADDON_FRAMEWORKS_ABS: " LEVEL VERBOSE)

            # message(STATUS "--------------------------------------------")
            of_make_filespaths_relative("${ADDON_ROOT}" "${PARSED_ADDON_LIBS_ABS}" PARSED_ADDON_LIBS )
            # of_print_list(PARSED_ADDON_LIBS PREFIX "  • Libs: " LEVEL VERBOSE)

            # message(FATAL_ERROR "TRYING ADDONS")

            # TODO: ADDON_DEFINES

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
                    ADDON_CFLAGS
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
                    ADDON_CFLAGS
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
                        ADDON_CFLAGS
                )
                endif()
            endif()

            # message(VERBOSE "--------------------------------------------")
            # of_print_list(ADDON_PKG_CONFIG_LIBRARIES PREFIX "  • PKG_CONFIG_LIBRARIES: " LEVEL VERBOSE)
            # message(VERBOSE "--------------------------------------------")
            # of_print_list(ADDON_LDFLAGS PREFIX "  • ADDON_LDFLAGS: " LEVEL VERBOSE)
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
            # of_make_absolute("${ADDON_ROOT}" "${ADDON_FRAMEWORKS}" ADDON_FRAMEWORKS)


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
            # of_print_list(ADDON_FRAMEWORKS PREFIX "  📚 ADDON_FRAMEWORKS: " LEVEL VERBOSE)

            # message(VERBOSE "--------------------------------------------")
            # of_print_list(ADDON_LIBS PREFIX "  • ADDON_INCLUDES: " LEVEL VERBOSE)

            # message(VERBOSE "--------------------------------------------")
            # of_print_list(TMP_HEADER_AND_SOURCE_FILES PREFIX "  • TMP_HEADER_AND_SOURCE_FILES: " LEVEL VERBOSE)

            # we can't assume that all the source files and inclues are included in the addon directory
            # of_partition_paths_by_parent(${ADDON_ROOT} "${TMP_HEADER_AND_SOURCE_FILES}" TMP_IN_HEADER_AND_SOURCES TMP_OUT_HEADER_AND_SOURCES)

            # message(VERBOSE "--------------------------------------------")
            # of_print_list(TMP_IN_HEADER_AND_SOURCES PREFIX "  • in - TMP_IN_HEADER_AND_SOURCES: " LEVEL VERBOSE)
            # message(VERBOSE "--------------------------------------------")
            # of_print_list(TMP_OUT_HEADER_AND_SOURCES PREFIX "  • out - TMP_OUT_HEADER_AND_SOURCES: " LEVEL VERBOSE)

            # example LDFLAGS: ADDON_LDFLAGS = -F$(OF_ROOT)/addons/ofxSyphon/libs/Syphon/lib/osx/ -framework Syphon
            string(REPLACE "$(OF_ROOT)" "${OF_ROOT_DIRECTORY}" FIXED_ADDON_LDFLAGS "${ADDON_LDFLAGS}")
            if(ADDON_LDFLAGS)
                message(VERBOSE "--------------------------------------------")
                of_print_list(FIXED_ADDON_LDFLAGS PREFIX "  • ADDON_LDFLAGS: " LEVEL VERBOSE)
                # target_link_libraries(${OF_PROJECT_NAME} PRIVATE "${FIXED_ADDON_LDFLAGS}")
                foreach(flag IN LISTS FIXED_ADDON_LDFLAGS)
                    target_link_options(${OF_PROJECT_NAME} PRIVATE ${flag})
                endforeach()
            endif()

            # example CFLAGS: ADDON_CFLAGS = -F$(OF_ROOT)/addons/ofxSyphon/libs/Syphon/lib/osx/
            string(REPLACE "$(OF_ROOT)" "${OF_ROOT_DIRECTORY}" FIXED_ADDON_CFLAGS "${ADDON_CFLAGS}")
            if(ADDON_CFLAGS)
                message(VERBOSE "--------------------------------------------")
                of_print_list(FIXED_ADDON_CFLAGS PREFIX "  • ADDON_CFLAGS: " LEVEL VERBOSE)
                # target_link_options(${OF_PROJECT_NAME} PRIVATE "${FIXED_ADDON_CFLAGS}")
                foreach(flag IN LISTS FIXED_ADDON_CFLAGS)
                    target_compile_options(${OF_PROJECT_NAME} PRIVATE ${flag})
                endforeach()
            endif()

            of_extract_F_dirs_from_flag_lines(F_DIRS
                "${FIXED_ADDON_CFLAGS}"
                "${FIXED_ADDON_LDFLAGS}"
            )
            # message(STATUS "Framework search dirs: ${F_DIRS}")
            # 2) Find *.framework bundles beneath those -F dirs
            of_collect_framework_bundles_from_F_dirs(F_FRAMEWORKS "${F_DIRS}")
            of_make_absolute("${ADDON_ROOT}" "${F_FRAMEWORKS}" F_FRAMEWORKS )
            # message(STATUS "Found frameworks: ${F_FRAMEWORKS}")
            list(APPEND ADDON_FRAMEWORKS ${F_FRAMEWORKS})

            if(APPLE)
                if( ADDON_FRAMEWORKS ) 
                    # set(APP_FRAMEWORKS_DIR "$<TARGET_FILE_DIR:${TARGET}>/../Frameworks")
                    # set(OF_PROJECT_APP_BUNDLE_FRAMEWORKS_DIR "$<TARGET_BUNDLE_CONTENT_DIR:${OF_PROJECT_NAME}>/Frameworks")
                    foreach(fw IN LISTS ADDON_FRAMEWORKS)
                        of_embed_framework(${OF_PROJECT_NAME} "${fw}")
                    endforeach()
                endif()
            endif()

            # list(APPEND OF_PROJECT_FRAMEWORKS_TO_BUNDLE ${ADDON_FRAMEWORKS})

            message(VERBOSE "--------------------------------------------")
            of_print_list(ADDON_FRAMEWORKS PREFIX "  📚 ADDON_FRAMEWORKS: " LEVEL VERBOSE)

            # string(TOUPPER "${ADDON_NAME}" ADDON_NAME_UPPER)
            # set( ADDON_NAME_DEFINE "OF_ADDON_${ADDON_NAME_UPPER}")
            # # adding 
            # target_compile_definitions(${OF_PROJECT_NAME} PUBLIC "${ADDON_NAME_DEFINE}")

            # working, but not great in ide since it's under the project folder and not one level above 
            target_include_directories(${OF_PROJECT_NAME} PRIVATE ${ADDON_INCLUDES})
            target_link_libraries(${OF_PROJECT_NAME} PRIVATE ${ADDON_LIBS} )
            #---- IDE ---------------------
            target_sources(${OF_PROJECT_NAME} PRIVATE ${TMP_HEADER_AND_SOURCE_FILES})
            source_group(
                TREE   "${OF_ROOT_DIRECTORY}/addons"
                PREFIX "addons"
                FILES  ${TMP_HEADER_AND_SOURCE_FILES}
            )
        endif()

        
    else()
        message( WARNING "Could not find addon ${ADDON_NAME} at ${ADDON_ROOT}" )
    endif()


    message(VERBOSE "--------------------------------------------" )
endfunction()
