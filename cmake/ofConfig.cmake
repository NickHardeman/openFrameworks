
if( NOT DEFINED OF_ROOT_DIRECTORY )
    set(TMP_LIB_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../../libs/openFrameworks")
    if(EXISTS "${TMP_LIB_DIR}")
        get_filename_component(OF_ROOT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/../../.." REALPATH BASE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
        message(STATUS "OF Path exists: ${TMP_LIB_DIR}. Setting to ${OF_ROOT_DIRECTORY}")
    endif()
    unset(TMP_LIB_DIR)  # removes it from scope
    if( NOT DEFINED OF_ROOT_DIRECTORY )
        message(FATAL_ERROR "OF_ROOT_DIRECTORY IS NOT SET, must be set before including ofConfig.cmake")
    endif()
endif()

if( NOT DEFINED OF_CMAKE_DIRECTORY ) 
    set( OF_CMAKE_DIRECTORY "${OF_ROOT_DIRECTORY}/cmake" )
    message(STATUS "OF_CMAKE_DIRECTORY not set, setting to ${OF_CMAKE_DIRECTORY}")
endif()

if( NOT DEFINED OF_LIB_DIR_NAME ) 
    #TODO: Add more folders and targets
    if( APPLE ) # Apple is a Unix, too. So dont ask only first UNIX
        if( IOS )
            set(OF_LIB_DIR_NAME "ios")
        else()
            set(OF_LIB_DIR_NAME "macos")
        endif()
    elseif(UNIX)
        
    endif()
endif()

# detect_target(<out_string_var> <out_arch_var> <out_is_cross_var>)
function(of_detect_target OUT_OS OUT_ARCH OUT_TAG OUT_IS_CROSS)
    set(sys  "${CMAKE_SYSTEM_NAME}")
    set(proc "${CMAKE_SYSTEM_PROCESSOR}")

    # Cross-compiling signal (host != target or toolchain set)
    set(is_cross "${CMAKE_CROSSCOMPILING}")

    # Default arch normalization
    set(arch "${proc}")
    if(proc MATCHES "^(x86_64|amd64)$")
        set(arch "x86_64")
    elseif(proc MATCHES "^(i[3-6]86|x86)$")
        set(arch "x86")
    # elseif(proc MATCHES "^(aarch64|arm64)$")
        # set(arch "arm64")
    elseif(proc MATCHES "^(armv7|armv7l)$")
        set(arch "armv7")
    endif()

    # Start with empty
  set(tag "")

    # ---- Android
    if(ANDROID)
    # ANDROID_ABI is one of: armeabi-v7a, arm64-v8a, x86, x86_64
    if(DEFINED ANDROID_ABI AND NOT ANDROID_ABI STREQUAL "")
        set(tag "android/${ANDROID_ABI}")
        if(ANDROID_ABI STREQUAL "armeabi-v7a")  
            set(arch "armv7")   
        endif()
        if(ANDROID_ABI STREQUAL "arm64-v8a")
            set(arch "arm64")   
        endif()
        if(ANDROID_ABI STREQUAL "x86")
            set(arch "x86")     
        endif()
        if(ANDROID_ABI STREQUAL "x86_64")
            set(arch "x86_64")  
        endif()
    else()
        set(tag "android")
    endif()

    # ---- Apple
    elseif(IOS OR sys STREQUAL "iOS" OR sys STREQUAL "tvOS" OR sys STREQUAL "watchOS")
        set(tag "iOS")
    elseif(sys STREQUAL "Darwin")
        set(tag "macOS")

    # ---- Emscripten
    elseif(EMSCRIPTEN OR sys STREQUAL "Emscripten")
        set(tag "emscripten")

    # ---- Windows family
    elseif(WIN32)
        if(MINGW)
            # MSYS2/MinGW environment
            set(tag "msys2")
        else()
            # MSVC, Ninja+cl, etc.
            set(tag "Windows")
        endif()

    # ---- MSYS (rarely needed; keep for completeness)
    elseif(sys STREQUAL "MSYS")
        set(tag "msys2")

    # ---- Linux family
    elseif(sys STREQUAL "Linux")
        if(arch STREQUAL "x86_64")
            set(tag "linux64")
        elseif(arch STREQUAL "arm64")
            set(tag "linuxaarch64")
        elseif(arch STREQUAL "x86")
            set(tag "linux")               # 32-bit x86
        else()
            # Fallback to generic linux if unknown arch
            set(tag "linux")
        endif()

    else()
        # Unknown/other OS
        set(tag "${sys}")  # expose raw name rather than failing
    endif()

    # Export
    set(${OUT_OS}      "${sys}"  PARENT_SCOPE)
    set(${OUT_ARCH}     "${arch}" PARENT_SCOPE)
    set(${OUT_TAG}     "${tag}" PARENT_SCOPE)
    set(${OUT_IS_CROSS} "${is_cross}" PARENT_SCOPE)

endfunction()



macro(of_set_global_os_vars)
    if(NOT DEFINED OF_OS)
        set(OF_OS_MACOS OFF)
        of_detect_target(OF_OS OF_ARCH OF_OS_TAG OF_IS_CROSS_COMPILE)
        string(TOLOWER ${OF_OS_TAG} OF_OS_TAG_LOWER )
        if(OF_OS_TAG_LOWER STREQUAL "macos")
            set(OF_OS_MACOS ON)
        endif()
    endif()
endmacro()

# check if OS has been set
of_set_global_os_vars()

macro(of_check_of_root_path)
    if( NOT DEFINED OF_ROOT_DIRECTORY )
        message(FATAL_ERROR "ofUtils.cmake :: OF_ROOT_DIRECTORY IS NOT SET, must be set before including ofUtils.cmake")
    endif()
endmacro()



# # True for Xcode, Visual Studio, Ninja Multi-Config, etc.
# get_property(IS_MULTI GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)

# if(IS_MULTI)
#   # Multi-config generator (has CMAKE_CONFIGURATION_TYPES, $<CONFIG> dirs, etc.)
# else()
#   # Single-config generator (Makefiles, Ninja)
# endif()


set(OF_CMAKE_MULTI_BUILD_CONFIG OFF)
set(OF_CMAKE_BUILD_DIRECTORY "${OF_ROOT_DIRECTORY}/libs/openFrameworksCompiled/project/${OF_LIB_DIR_NAME}/build-${CMAKE_GENERATOR}" )

# https://www.studyplan.dev/cmake/cmake-build-configurations
if(CMAKE_CONFIGURATION_TYPES)
    message(STATUS "Generator is multi-config: ${CMAKE_GENERATOR}")
    message(STATUS "Available configs: ${CMAKE_CONFIGURATION_TYPES}")
    set(OF_CMAKE_MULTI_BUILD_CONFIG ON)
else()
    message(STATUS "Generator is single-config: ${CMAKE_GENERATOR}")
    message(STATUS "Current build type: ${CMAKE_BUILD_TYPE}")
    set(OF_CMAKE_BUILD_TYPE "${CMAKE_BUILD_TYPE}" )
    if(NOT OF_CMAKE_BUILD_TYPE)
        set(OF_CMAKE_BUILD_TYPE "Release" )
    endif()
    string(APPEND OF_CMAKE_BUILD_DIRECTORY "/${OF_CMAKE_BUILD_TYPE}")
endif()


