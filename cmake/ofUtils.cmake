#https://github.com/peterkolski/ofxCMake/blob/master/modules/configApple.cmake 


# add_prefix_inplace(<varName> <prefix>)
function(of_add_prefix_to_list LIST_VAR PREFIX OUT_VAR)
    set(_out "")
    set(_tlist ${LIST_VAR})
    foreach(item ${_tlist})
        list(APPEND _out "${PREFIX}${item}")
    endforeach()
    set(${OUT_VAR} "${_out}" PARENT_SCOPE)
endfunction()

# make_absolute(<base> <outVar> <listVar>)
# - <base>: absolute base directory
# - <listVar>: variable name containing the list of relative paths
# - <outVar>: variable to write the results into
function(of_make_absolute BASE_DIR LIST_VAR OUT_VAR)
    set(_out "")
    set(_tlist ${LIST_VAR})
    foreach(p ${_tlist})
        # get_filename_component with ABSOLUTE + BASE_DIR resolves relative paths
        get_filename_component(_abs "${p}" ABSOLUTE BASE_DIR "${BASE_DIR}")
        list(APPEND _out "${_abs}")
    endforeach()
    set(${OUT_VAR} "${_out}" PARENT_SCOPE)
endfunction()

function(of_get_all_subdirectories BASE_DIR OUT_VAR)
    set(result "")
    message("FUNCTIONS FOR SUBS")
    # Get immediate subdirectories
    file(GLOB entries CONFIGURE_DEPENDS "${BASE_DIR}/*")
    foreach(entry ${entries})
        # Print what we're looking at
        # message(STATUS "Inspecting: ${entry}")
        if(IS_DIRECTORY "${entry}")
            # message(STATUS "✓ Found directory: ${entry}")
            list(APPEND result "${entry}")
        endif()
    endforeach()

    set(${OUT_VAR} "${result}" PARENT_SCOPE)
endfunction()

function(of_make_filespaths_relative REL_PATH IN_VARS OUT_VAR )
    set(TMP_SOURCE_FILES_RELATIVE "")

    foreach(src_file ${IN_VARS})
        file(RELATIVE_PATH rel_path "${REL_PATH}" "${src_file}")
        list(APPEND TMP_SOURCE_FILES_RELATIVE "${rel_path}")
    endforeach()

    # Optionally replace the original list so that we have a list of relative paths 
    set(${OUT_VAR} "${TMP_SOURCE_FILES_RELATIVE}" PARENT_SCOPE)
endfunction()


function(of_get_all_source_files BASE_DIR OUT_VAR)
    # source files -------------------------------------------
    message(VERBOSE "of_get_all_source_files : Getting source files from ${BASE_DIR}")
    file(GLOB_RECURSE TMP_SOURCE_FILES CONFIGURE_DEPENDS 
        "${BASE_DIR}/*.cpp"
        "${BASE_DIR}/*.c"
    )

    # add in some objective-c files 
    if( APPLE ) 
        file(GLOB_RECURSE TMP_SOURCE_MM_FILES CONFIGURE_DEPENDS "${BASE_DIR}/*.mm" "${BASE_DIR}/*.m")
        foreach(entry ${TMP_SOURCE_MM_FILES})
            list(APPEND TMP_SOURCE_FILES "${entry}")
        endforeach()
    endif()

    set(${OUT_VAR} "${TMP_SOURCE_FILES}" PARENT_SCOPE)
endfunction()

function(of_get_all_header_files BASE_DIR OUT_VAR )
    # message(VERBOSE "of_get_all_header_files : Getting Header files from ${BASE_DIR}")
    file(GLOB_RECURSE TMP_HEADER_FILES CONFIGURE_DEPENDS 
        "${BASE_DIR}/*.h" 
        "${BASE_DIR}/*.hpp"
        "${BASE_DIR}/*.inl"
    )
    set(${OUT_VAR} "${TMP_HEADER_FILES}" PARENT_SCOPE)
endfunction()


# get_subdirs(<root> <outVar>)
function(of_get_subdirs_recursive A_ROOT_DIR OUT_DIRS)
    file(GLOB_RECURSE _entries CONFIGURE_DEPENDS LIST_DIRECTORIES true "${A_ROOT_DIR}/*")
    set(_dirs "")
    foreach(p IN LISTS _entries)
        if(IS_DIRECTORY "${p}")
            file(RELATIVE_PATH rel "${A_ROOT_DIR}" "${p}")
            if(NOT p STREQUAL "")          # skip the root itself
                list(APPEND _dirs "${p}")
            endif()
            # Make relative path
            # file(RELATIVE_PATH rel "${A_ROOT_DIR}" "${p}")
            # if(NOT rel STREQUAL "")          # skip the root itself
            #     list(APPEND _dirs "${rel}")
            # endif()
        endif()
    endforeach()
    list(REMOVE_DUPLICATES _dirs)
    list(SORT _dirs)
    set(${OUT_DIRS} "${_dirs}" PARENT_SCOPE)
endfunction()


function(of_exclude_paths_from_list A_SRC_FILES A_EXCLUDE_FILES OUT_VAR )
    set(SOURCE_FILES_FILTERED "")
    foreach(src_file ${A_SRC_FILES})
        set(exclude_file FALSE)

        foreach(exclude_path ${A_EXCLUDE_FILES})
            # Check if src_file ends with exclude_path
            string(LENGTH "${src_file}" src_len)
            string(LENGTH "${exclude_path}" exclude_len)
            math(EXPR offset "${src_len} - ${exclude_len}")
            if(offset GREATER_EQUAL 0)
                string(SUBSTRING "${src_file}" ${offset} ${exclude_len} tail)
                if("${tail}" STREQUAL "${exclude_path}")
                    set(exclude_file TRUE)
                    break()
                endif()
            endif()
        endforeach()

        if(NOT exclude_file)
            list(APPEND SOURCE_FILES_FILTERED "${src_file}")
        endif()
    endforeach()
    set(${OUT_VAR} ${SOURCE_FILES_FILTERED} PARENT_SCOPE)
endfunction()


function(of_get_static_libs_from_directory A_LIB_ROOT_DIR OUT_STATIC_LIBS )
    of_set_global_os_vars()
    set(FOUND_STATIC_LIBS "")
    if(IS_DIRECTORY ${A_LIB_ROOT_DIR})
        get_filename_component(DIR_NAME "${A_LIB_ROOT_DIR}" NAME)
        message(STATUS "of_get_static_libs_from_directory Dir name: ${DIR_NAME} full subdirectory: ${A_LIB_ROOT_DIR}")

        set(CURR_LIB_DIR "${A_LIB_ROOT_DIR}/lib/${OF_LIB_DIR_NAME}" )

        ##### -- search for .a, .frameworks, .dylib and .dll, etc.
        if(IS_DIRECTORY "${CURR_LIB_DIR}")
            # message(STATUS "FFFFFFFFFF >> ${CURR_LIB_DIR}" )
            # ok, we have a lib directory, so lets try to grab frameworks //
            file(GLOB OF_TEMP_FRAMEWORKS CONFIGURE_DEPENDS "${CURR_LIB_DIR}/*.xcframework")
            foreach(temp_framework ${OF_TEMP_FRAMEWORKS})
                # file(RELATIVE_PATH rel_framework_path "${OF_COMPILED_PROJECT_DIRECTORY}" "${temp_framework}")
                message(STATUS "   🧰 of_get_static_libs_from_directory Framework: ${temp_framework}")
                file(GLOB FRAME_WORK_SLICES CONFIGURE_DEPENDS "${temp_framework}/*")
                foreach(TMP_FRAMEWORK_SLICE ${FRAME_WORK_SLICES})
                    if(IS_DIRECTORY "${TMP_FRAMEWORK_SLICE}")
                        # now try to extract all the .a files 
                        file(GLOB TEMP_FRAMEWORK_STATIC_LIBS CONFIGURE_DEPENDS "${TMP_FRAMEWORK_SLICE}/*.a")
                        foreach(TMP_STATIC_LIB ${TEMP_FRAMEWORK_STATIC_LIBS})
                            message(STATUS "   of_get_static_libs_from_directory Framework Static lib: ${TMP_STATIC_LIB}")
                            list(APPEND FOUND_STATIC_LIBS ${TMP_STATIC_LIB})
                        endforeach()
                    endif()
                endforeach()
            endforeach()

            file(GLOB TEMP_STATIC_LIBS CONFIGURE_DEPENDS "${CURR_LIB_DIR}/*.a")
            foreach(TMP_STATIC_LIB ${TEMP_STATIC_LIBS})
                message(STATUS "   of_get_static_libs_from_directory Static lib: ${TMP_STATIC_LIB} ")
                list(APPEND FOUND_STATIC_LIBS ${TMP_STATIC_LIB})
            endforeach()
        endif()
    endif()
    set(${OUT_STATIC_LIBS} "${FOUND_STATIC_LIBS}" PARENT_SCOPE)
endfunction()

function(of_add_library_from_directory A_LIB_ROOT_DIR OUT_LIBS_ADDED )
    of_set_global_os_vars()
    set(TMP_ADDED_LIBS "")
    if(IS_DIRECTORY ${A_LIB_ROOT_DIR})
        get_filename_component(DIR_NAME "${A_LIB_ROOT_DIR}" NAME)
        message(STATUS "of_library_add_from_directory Dir name: ${DIR_NAME} full subdirectory: ${A_LIB_ROOT_DIR}")
        
        if( "${DIR_NAME}" MATCHES "openFrameworks" )
            message(STATUS "❌❌❌ DETECTED openFrameworks folder, going to skip" )
        else()

            if(IS_DIRECTORY "${A_LIB_ROOT_DIR}/include")
                #TODO: Now link against these include files 
                message(STATUS "📚 FOUND a lib include ${A_LIB_ROOT_DIR}/include")

                set(THIRD_PARTY_LIB_NAME "OF_LIB_${DIR_NAME}")
                set(THIRD_PARTY_ADDED_LIB OFF)

                set(CURR_LIB_DIR "${A_LIB_ROOT_DIR}/lib/${OF_LIB_DIR_NAME}" )
                
                ##### -- search for .a, .frameworks, .dylib and .dll, etc.
                if(IS_DIRECTORY "${CURR_LIB_DIR}")
                    # message(STATUS "FFFFFFFFFF >> ${CURR_LIB_DIR}" )
                    # ok, we have a lib directory, so lets try to grab frameworks //
                    file(GLOB OF_TEMP_FRAMEWORKS CONFIGURE_DEPENDS "${CURR_LIB_DIR}/*.xcframework")
                    foreach(temp_framework ${OF_TEMP_FRAMEWORKS})
                        # file(RELATIVE_PATH rel_framework_path "${OF_COMPILED_PROJECT_DIRECTORY}" "${temp_framework}")
                        message(STATUS "   🧰 Framework: ${temp_framework}")
                        file(GLOB FRAME_WORK_SLICES CONFIGURE_DEPENDS "${temp_framework}/*")
                        foreach(TMP_FRAMEWORK_SLICE ${FRAME_WORK_SLICES})
                            if(IS_DIRECTORY "${TMP_FRAMEWORK_SLICE}")
                                # now try to extract all the .a files 
                                file(GLOB TEMP_STATIC_LIBS CONFIGURE_DEPENDS "${TMP_FRAMEWORK_SLICE}/*.a")
                                foreach(TMP_STATIC_LIB ${TEMP_STATIC_LIBS})
                                    message(STATUS "   Framework Static lib: ${TMP_STATIC_LIB} THIRD_PARTY_LIB_NAME: ${THIRD_PARTY_LIB_NAME}")
                                    add_library(${THIRD_PARTY_LIB_NAME} IMPORTED STATIC)
                                    set(THIRD_PARTY_ADDED_LIB ON)
                                    # target_include_directories(${THIRD_PARTY_LIB_NAME} INTERFACE
                                    #     "${A_LIB_ROOT_DIR}/include"
                                    # )
                                    set_target_properties(${THIRD_PARTY_LIB_NAME} PROPERTIES 
                                        # This property points to the actual binary file
                                        IMPORTED_LOCATION "${TMP_STATIC_LIB}" 
                                    )
                                endforeach()
                            endif()
                        endforeach()
                    endforeach()

                    file(GLOB OF_TEMP_STATIC_LIBS CONFIGURE_DEPENDS "${CURR_LIB_DIR}/*.a")
                    foreach(TMP_STATIC_LIB ${OF_TEMP_STATIC_LIBS})
                        message(STATUS "   Static lib: ${TMP_STATIC_LIB} THIRD_PARTY_LIB_NAME: ${THIRD_PARTY_LIB_NAME}")
                        add_library(${THIRD_PARTY_LIB_NAME} IMPORTED STATIC)
                        set(THIRD_PARTY_ADDED_LIB ON)
                        set_target_properties(${THIRD_PARTY_LIB_NAME} PROPERTIES 
                            # This property points to the actual binary file
                            IMPORTED_LOCATION "${TMP_STATIC_LIB}" 
                        )
                    endforeach()
                endif()

                if(NOT THIRD_PARTY_ADDED_LIB) 
                    add_library(${THIRD_PARTY_LIB_NAME} INTERFACE)
                endif()

                if(IS_DIRECTORY "${A_LIB_ROOT_DIR}/src")
                    target_include_directories(${THIRD_PARTY_LIB_NAME} INTERFACE
                        "${A_LIB_ROOT_DIR}/src"
                    )
                endif()

                target_include_directories(${THIRD_PARTY_LIB_NAME} INTERFACE
                    "${A_LIB_ROOT_DIR}/include"
                )

                # Now addd the lib to the core libs so it can be linked later 
                list(APPEND TMP_ADDED_LIBS ${THIRD_PARTY_LIB_NAME} )
            endif()
        endif()
    endif()

    set(${OUT_LIBS_ADDED} ${TMP_ADDED_LIBS} PARENT_SCOPE)

endfunction()






# read_mk_section_vars(<mkfile> <section> <VAR> [<VAR>...])
# - <section> is e.g. "linux64" (the line "linux64:")
# - Populates CMake lists named exactly <VAR> in the caller's scope.
function(read_mk_section_vars MKFILE SECTION)
  if(NOT EXISTS "${MKFILE}")
    message(FATAL_ERROR "read_mk_section_vars: file not found: ${MKFILE}")
  endif()

  # Vars we want to collect are everything after the first two args
  set(VARS ${ARGN})
  if(VARS STREQUAL "")
    message(FATAL_ERROR "read_mk_section_vars: no variable names provided")
  endif()

  # Init accumulators
  foreach(var IN LISTS VARS)
    set("__acc_${var}" "${${var}}") #set("__acc_${var}" "")
    set("__set_${var}" "no")
  endforeach()

  file(STRINGS "${MKFILE}" _MK_LINES)
  set(_cur "")

  foreach(_line IN LISTS _MK_LINES)
    # Strip trailing comments and whitespace
    string(REGEX REPLACE "#.*$" "" _line "${_line}")
    string(STRIP "${_line}" _line)
    if(_line STREQUAL "")
      continue()
    endif()

    # Section header? e.g. "linux64:"
    if(_line MATCHES "^([A-Za-z0-9_]+):$")
      set(_cur "${CMAKE_MATCH_1}")
      continue()
    endif()

    # Only parse when we are in the target section
    if(NOT _cur STREQUAL "${SECTION}")
      continue()
    endif()

    # Try each requested var: handle '=' (reset) and '+=' (append)
    foreach(var IN LISTS VARS)
      # reset with '='
      if(_line MATCHES "^[ \t]*${var}[ \t]*=(.*)")
        set(_val "${CMAKE_MATCH_1}")
        string(STRIP "${_val}" _val)
        if(_val STREQUAL "")
          set("__acc_${var}" "")  # explicit clear
          set("__set_${var}" "yes") # this var has been set.
        else()
          separate_arguments(_val)          # split into list
          set("__acc_${var}" "${_val}")     # replace
        endif()
        continue()
      endif()

      # append with '+='
      if(_line MATCHES "^[ \t]*${var}[ \t]*\\+= *(.*)")
        set(_val "${CMAKE_MATCH_1}")
        string(STRIP "${_val}" _val)
        if(NOT _val STREQUAL "")
          separate_arguments(_val)
          set("__tmp_${var}" "${__acc_${var}};${_val}")
          set("__acc_${var}" "${__tmp_${var}}")
        endif()
        continue()
      endif()
    endforeach()
  endforeach()

    # Export to caller
    foreach(var IN LISTS VARS)
        if(NOT "${__acc_${var}}" STREQUAL "")
            set(${var} "${__acc_${var}}" PARENT_SCOPE)
        else()
            # the string value was ""
            # however it has been explicitly set to "", so now we set it to ""
            # otherwise we want to preserve the incoming value
            if("${__set_${var}}" STREQUAL "yes")
                set(${var} "" PARENT_SCOPE)
            endif()
        endif()
    endforeach()
endfunction()


# filter_by_patterns(<inListVar> <excludePatternsVar> <outVar>)
# - Exclude patterns may contain '%' which means "match anything" (.*).
# - Patterns without '%' act as exact matches.
# - Optional: prefix a pattern with "re:" to provide a raw regex yourself.
function(of_filter_paths_by_patterns A_INLIST A_EXLIST OUTVAR)
  set(_out "")
  foreach(_item IN LISTS ${A_INLIST})
    set(_keep TRUE)
    foreach(_pat IN LISTS ${A_EXLIST})
      string(STRIP "${_pat}" _pat)
      if(_pat STREQUAL "")
        continue()
      endif()

      # Build a regex from the pattern
      if(_pat MATCHES "^re:(.*)$")
        # Raw regex supplied by caller
        set(_rx "${CMAKE_MATCH_1}")
      else()
        # Escape regex metachars so plain strings match exactly
        set(_rx "${_pat}")
        string(REGEX REPLACE "([][(){}.+?^$|])" "\\\\\\1" _rx "${_rx}")
        # Turn Make-style % into .*
        string(REPLACE "%" ".*" _rx "${_rx}")
        # Anchor to whole string
        set(_rx "^${_rx}$")
      endif()

      if(_item MATCHES "${_rx}")
        set(_keep FALSE)
        break()
      endif()
    endforeach()

    if(_keep)
      list(APPEND _out "${_item}")
    endif()
  endforeach()

  set(${OUTVAR} "${_out}" PARENT_SCOPE)
endfunction()



# print_list(<var> [PREFIX <str>] [LEVEL <msg-level>] [NUMBERED])
#   <var>   : name of the CMake list variable (not its contents)
#   PREFIX  : string to put in front of each item (default: " - ")
#   LEVEL   : message() level (STATUS/VERBOSE/DEBUG/TRACE/NOTICE/WARNING/...)
#             default: STATUS
#   NUMBERED: if present, prints "1: item", "2: item", ...
function(of_print_list VAR)
    set(options NUMBERED)
    set(oneValueArgs PREFIX LEVEL)
    cmake_parse_arguments(PL "${options}" "${oneValueArgs}" "" ${ARGN})

    if(NOT PL_PREFIX)
        set(PL_PREFIX " - ")
    endif()
    if(NOT PL_LEVEL)
        set(PL_LEVEL STATUS)
    endif()

    if(NOT DEFINED ${VAR} OR "${${VAR}}" STREQUAL "")
        message(${PL_LEVEL} "${PL_PREFIX}[empty] (var '${VAR}')")
        return()
    endif()

    if(PL_NUMBERED)
        set(_i 0)
        foreach(_it IN LISTS ${VAR})
        math(EXPR _i "${_i}+1")
        message(${PL_LEVEL} "${PL_PREFIX}${_i}: ${_it}")
        endforeach()
    else()
        foreach(_it IN LISTS ${VAR})
            message(${PL_LEVEL} "${PL_PREFIX}${_it}")
        endforeach()
    endif()
endfunction()




