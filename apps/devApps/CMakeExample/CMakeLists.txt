# cmake_minimum_required(VERSION 3.16...4.0)

# References
# https://cliutils.gitlab.io/modern-cmake/chapters/basics.html
# https://github.com/HerrNamenlos123/openFrameworks/blob/master/cmake/utils.cmake

cmake_minimum_required(VERSION 3.16...4.0)

# cmake -S . -B build -G Xcode --log-level=VERBOSE
# cmake --build build --parallel

# set the project name

set(OF_PROJECT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} )
# get_filename_component(OF_PROJECT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}" DIRECTORY )
get_filename_component(OF_PROJECT_NAME "${CMAKE_CURRENT_SOURCE_DIR}" NAME_WE)

project(${OF_PROJECT_NAME})

# TODO: Ability to set the project name or directory independently of cmake 

message(STATUS "OF PROJECT NAME: ${OF_PROJECT_NAME} PROJECT DIR: ${OF_PROJECT_DIRECTORY}")
message(STATUS "${OF_PROJECT_NAME} Using ${CMAKE_GENERATOR}")
message(STATUS "CMAKE_BINARY_DIR: ${CMAKE_BINARY_DIR}")

message("Debug: ${CMAKE_CXX_FLAGS_DEBUG}") 
message("Release: ${CMAKE_CXX_FLAGS_RELEASE}") 
message("RelWithDebInfo: ${CMAKE_CXX_FLAGS_RELWITHDEBINFO}") 
message("MinSizeRel: ${CMAKE_CXX_FLAGS_MINSIZEREL}") 

### Require out-of-source builds
file(TO_CMAKE_PATH "${PROJECT_BINARY_DIR}/CMakeLists.txt" LOC_PATH)
if(EXISTS "${LOC_PATH}")
    message(FATAL_ERROR "You cannot build in a source directory (or any directory with a CMakeLists.txt file). Please make a build subdirectory.")
endif()


if (CMAKE_SOURCE_DIR STREQUAL CMAKE_BINARY_DIR)
    message(FATAL_ERROR "In-source builds are a really bad idea. If you don't know what you're doing, please create a 'build' folder and call 'cmake ..' from within.")
endif()


# Only do these if this is the main project, and not if it is included through add_subdirectory
if(CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME)
    message(STATUS "SETTING SOME GLOBAL PARAMS")

    # Optionally set things like CMAKE_CXX_STANDARD, CMAKE_POSITION_INDEPENDENT_CODE here
    # specify the C++ standard
    set(CMAKE_CXX_STANDARD 20)
    set(CMAKE_CXX_STANDARD_REQUIRED True)

    # Let's ensure -std=c++xx instead of -std=g++xx
    set(CMAKE_CXX_EXTENSIONS OFF)

    # Let's nicely support folders in IDEs
    set_property(GLOBAL PROPERTY USE_FOLDERS ON)

endif()







if( NOT DEFINED OF_ROOT_DIRECTORY ) 
    # set( OF_ROOT_DIRECTORY "${PROJECT_SOURCE_DIR}/../../.." )
    get_filename_component(OF_ROOT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/../../.." REALPATH BASE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
    message(STATUS "OF_ROOT_DIRECTORY not set, setting to ${OF_ROOT_DIRECTORY}")
endif()

message( STATUS "OF_ROOT_DIRECTORY: ${OF_ROOT_DIRECTORY} ")
message( STATUS "CMAKE_BINARY_DIR: ${CMAKE_BINARY_DIR} ")

include("${OF_ROOT_DIRECTORY}/cmake/ofConfig.cmake") # defines OF_CMAKE_DIRECTORY
include("${OF_CMAKE_DIRECTORY}/ofUtils.cmake")
include("${OF_CMAKE_DIRECTORY}/ofAddons.cmake")


# OF_CMAKE_BUILD_DIRECTORY is set in ofConfig.cmake
# add_subdirectory("${OF_ROOT_DIRECTORY}/libs/openFrameworksCompiled/project" "${OF_CMAKE_BUILD_DIRECTORY}" )
add_subdirectory("${OF_ROOT_DIRECTORY}" "${OF_CMAKE_BUILD_DIRECTORY}" )

#OUT_OS OUT_ARCH OUT_TAG OUT_IS_CROSS
# of_detect_target(OF_OS OF_ARCH OF_OS_TAG OF_IS_CROSS_COMPILE)
of_set_global_os_vars()
# string(TOLOWER ${OF_OS_TAG} OF_OS_TAG_LOWER )
message(VERBOSE "OF OF_OS NAME: ${OF_OS}")
message(VERBOSE "OF_ARCH: ${OF_ARCH}")
message(VERBOSE "OF_OS_TAG: ${OF_OS_TAG}")
message(VERBOSE "OF_IS_CROSS_COMPILE: ${OF_IS_CROSS_COMPILE}")



# if(CMAKE_SYSTEM_NAME STREQUAL "iOS")
#     message(STATUS "Building for iOS")
# elseif(CMAKE_SYSTEM_NAME STREQUAL "tvOS")
#     message(STATUS "Building for tvOS")
# elseif(CMAKE_SYSTEM_NAME STREQUAL "watchOS")
#     message(STATUS "Building for watchOS")
# elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
#     message(STATUS "Building for macOS")
# endif()



# now lets add some options
# OF_BUNDLE_DATA_FOLDER
###############################################################################
### OPTIONS ###################################################################
if(APPLE)
option(
    OF_BUNDLE_DATA_FOLDER
    "Should the data folder be bundled inside the application."
    OFF
) 
endif()
###############################################################################



set(OF_PROJECT_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/src")
file(GLOB_RECURSE OF_PROJECT_HEADER_FILES CONFIGURE_DEPENDS 
    "${OF_PROJECT_SOURCE_DIR}/*.h"
    "${OF_PROJECT_SOURCE_DIR}/*.hpp"
    "${OF_PROJECT_SOURCE_DIR}/*.inl"
)


file(GLOB_RECURSE OF_PROJECT_SOURCE_FILES "${OF_PROJECT_SOURCE_DIR}/*.cpp")
# add in some objective-c files 
if( APPLE ) 
    file(GLOB_RECURSE OF_PROJECT_SOURCE_MM_FILES  "${OF_PROJECT_SOURCE_DIR}/*.mm" "${OF_PROJECT_SOURCE_DIR}/*.m")
    foreach(entry ${OF_PROJECT_SOURCE_MM_FILES})
        list(APPEND OF_PROJECT_SOURCE_FILES "${entry}")
    endforeach()
endif()

set( OF_PROJECT_HEADER_AND_SOURCE_FILES ${OF_PROJECT_SOURCE_FILES} ${OF_PROJECT_HEADER_FILES} )

# make_filespaths_relative("${CMAKE_SOURCE_DIR}" "${OF_SOURCE_FILES_ABS}" OF_SOURCE_FILES)
# foreach(src_file ${OF_SOURCE_FILES_ABS})
#     message(STATUS "Found source fileXXXX: ${src_file}")
# endforeach()
# set(OF_PROJECT_SOURCE_FILES ${OF_PROJECT_SOURCE_FILES_ABS} )

of_get_all_subdirectories("${OF_PROJECT_SOURCE_DIR}" OF_PROJECT_INCLUDE_DIRECTORIES)
list(APPEND OF_PROJECT_INCLUDE_DIRECTORIES "${OF_PROJECT_SOURCE_DIR}" )

# file(GLOB_RECURSE OF_PROJECT_HEADERS_FILES_ABS "${OF_PROJECT_SOURCE_DIR}/*.h" "${OF_PROJECT_SOURCE_DIR}/*.hpp")


if(APPLE)
    add_executable(${OF_PROJECT_NAME} MACOSX_BUNDLE "${OF_PROJECT_SOURCE_FILES}")
else()
    add_executable(${OF_PROJECT_NAME} "${OF_PROJECT_SOURCE_FILES}")
endif()

# target_include_directories(${OF_PROJECT_NAME} PUBLIC "src")
target_include_directories(${OF_PROJECT_NAME} PUBLIC ${OF_PROJECT_INCLUDE_DIRECTORIES})
# link
target_link_libraries(${OF_PROJECT_NAME} PRIVATE openFrameworks)
# target_include_directories(3DPrimitivesExample PUBLIC OF_HEADER_FILES)
target_include_directories(${OF_PROJECT_NAME} INTERFACE ${OF_INCLUDE_DIRECTORIES})




# does not work....
# set(OF_PROJECT_APP_NAME "$<IF:$<CONFIG:Debug>,${OF_PROJECT_NAME}Debug,${OF_PROJECT_NAME}>")
# Put the .app here:

set_target_properties(${OF_PROJECT_NAME} PROPERTIES
    OUTPUT_NAME_DEBUG          "${OF_PROJECT_NAME}Debug"
    OUTPUT_NAME_RELEASE        "${OF_PROJECT_NAME}"
    OUTPUT_NAME_RELWITHDEBINFO "${OF_PROJECT_NAME}RelWithDebInfo"
    OUTPUT_NAME_MINSIZEREL     "${OF_PROJECT_NAME}MinSizeRel"
)

set_target_properties(${OF_PROJECT_NAME} PROPERTIES
#   RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/bin"
    RUNTIME_OUTPUT_DIRECTORY                "${CMAKE_CURRENT_SOURCE_DIR}/bin"
    RUNTIME_OUTPUT_DIRECTORY_DEBUG          "${CMAKE_CURRENT_SOURCE_DIR}/bin"
    RUNTIME_OUTPUT_DIRECTORY_RELEASE        "${CMAKE_CURRENT_SOURCE_DIR}/bin"
    RUNTIME_OUTPUT_DIRECTORY_RELWITHDEBINFO "${CMAKE_CURRENT_SOURCE_DIR}/bin"
    RUNTIME_OUTPUT_DIRECTORY_MINSIZEREL     "${CMAKE_CURRENT_SOURCE_DIR}/bin"

    # OUTPUT_NAME "$<IF:$<CONFIG:Debug>,${OF_PROJECT_NAME}Debug,${OF_PROJECT_NAME}>"        # name per config
)

# TODO: Copy any shared libs into the proper place
# set_target_properties(${OF_PROJECT_NAME} PROPERTIES 
#   INSTALL_RPATH "$ORIGIN" 
# )

if( APPLE ) 
    # set_target_properties(${OF_PROJECT_NAME} PROPERTIES
    #     XCODE_ATTRIBUTE_CONFIGURATION_BUILD_DIR "${CMAKE_CURRENT_SOURCE_DIR}/bin"
    # )

    #Suppress ZERO_CHECK (auto-regeneration) target:
    set(CMAKE_SUPPRESS_REGENERATION ON)

    set(OF_APP_ICON_PATH "${OF_ROOT_DIRECTORY}/libs/openFrameworksCompiled/project/${OF_LIB_DIR_NAME}/")
    set(APP_ICON_RELEASE "icon.icns")
    set(APP_ICON_DEBUG   "icon-debug.icns")
    # set(OF_APP_ICON_NAME "icon$<IF:$<CONFIG:Debug>,-debug,>.icns")

    set_source_files_properties("${OF_APP_ICON_PATH}${APP_ICON_RELEASE}" PROPERTIES MACOSX_PACKAGE_LOCATION "Resources")
    set_source_files_properties("${OF_APP_ICON_PATH}${APP_ICON_DEBUG}"   PROPERTIES MACOSX_PACKAGE_LOCATION "Resources")
    target_sources(${OF_PROJECT_NAME} PRIVATE "${OF_APP_ICON_PATH}${APP_ICON_RELEASE}" "${OF_APP_ICON_PATH}${APP_ICON_DEBUG}")

    # set(OF_APP_ICON_PATH "${OF_ROOT_DIRECTORY}/libs/openFrameworksCompiled/project/${OF_LIB_DIR_NAME}/${OF_APP_ICON_NAME}")

    # Put the file into MyApp.app/Contents/Resources
    # set_source_files_properties(${OF_APP_ICON_PATH} PROPERTIES MACOSX_PACKAGE_LOCATION "Resources")

    # Add it as a source of the bundle target
    # target_sources(${OF_PROJECT_NAME} PRIVATE ${OF_APP_ICON_PATH})

    # Tell macOS which icon to use (CFBundleIconFile)
    # (Just the filename, not the path)
    # set_target_properties(${OF_PROJECT_NAME} PROPERTIES MACOSX_BUNDLE_ICON_FILE "icon.icns")

    # TODO: Check to see if there is an info.plist file existing 
    # TODO: Generate a plist if it is not present 
    # this can be done in the ofConfigMacOS.cmake
    set_target_properties(${OF_PROJECT_NAME} PROPERTIES
        MACOSX_BUNDLE_GUI_IDENTIFIER   com.openFrameworks.${OF_PROJECT_NAME}
        MACOSX_BUNDLE_BUNDLE_NAME      "${OF_PROJECT_NAME}"
        MACOSX_BUNDLE_SHORT_VERSION_STRING "1.0"
        MACOSX_BUNDLE_BUNDLE_VERSION   "1.0"
        #MACOSX_BUNDLE_ICON_NAME     "$<IF:$<CONFIG:Debug>,icon-debug.icns,icon.icns>"
        # MACOSX_BUNDLE_ICON_NAME     "$<IF:$<CONFIG:Debug>,icon-debug.icns,icon.icns>"
        MACOSX_BUNDLE_INFO_PLIST    "${OF_PROJECT_DIRECTORY}/openFrameworks-Info.plist"
        # XCODE_ATTRIBUTE_ICON_NAME "$<IF:$<CONFIG:Debug>,of-debug.icns,icon.icns>"
        # XCODE_ATTRIBUTE_GENERATE_INFOPLIST_FILE NO
    )

    # set(CMAKE_XCODE_ATTRIBUTE_CONFIGURATION_BUILD_DIR "${CMAKE_BINARY_DIR}/build/$<CONFIG>")
    # set(CMAKE_XCODE_ATTRIBUTE_CONFIGURATION_BUILD_DIR "${CMAKE_CURRENT_SOURCE_DIR}/bin")

    # set_target_properties(${OF_PROJECT_NAME} PROPERTIES
    #     XCODE_ATTRIBUTE_INFOPLIST_KEY_CFBundleIconFile
    #     "$<IF:$<CONFIG:Debug>,icon-debug.icns,icon.icns>"
    # )
    
    # set_target_properties(${OF_PROJECT_NAME} PROPERTIES
    #     MACOSX_BUNDLE_ICON_FILE     "$<IF:$<CONFIG:Debug>,icon-debug.icns,icon.icns>"
    # )

    # message(VERBOSE "OF_CMAKE_MULTI_BUILD_CONFIG: ${OF_CMAKE_MULTI_BUILD_CONFIG}")

    if(OF_CMAKE_MULTI_BUILD_CONFIG)
        message(VERBOSE "HAS MULTI OF_CMAKE_MULTI_BUILD_CONFIG: ${OF_CMAKE_MULTI_BUILD_CONFIG}")
        # set_target_properties(${OF_PROJECT_NAME} PROPERTIES
        #      MACOSX_BUNDLE_ICON_FILE     $<$<IF:$<CONFIG:Debug>,icon-debug.icns,icon.icns>>
        # )
        # per-config icon for Xcode
        set_target_properties(${OF_PROJECT_NAME} PROPERTIES
            MACOSX_BUNDLE_ICON_FILE "icon.icns"
        )
        set_target_properties(${OF_PROJECT_NAME} PROPERTIES
            XCODE_ATTRIBUTE_INFOPLIST_KEY_CFBundleIconFile "icon.icns"
        )
        # set_target_properties(${OF_PROJECT_NAME} PROPERTIES
        #     XCODE_ATTRIBUTE_INFOPLIST_KEY_CFBundleIconFile
        #     $<IF:$<CONFIG:Debug>,icon-debug.icns,icon.icns>
        # )
        # set_target_properties(${OF_PROJECT_NAME} PROPERTIES
        #     MACOSX_BUNDLE_ICON_FILE 
        #     $<IF:$<CONFIG:Debug>,icon-debug.icns,icon.icns>
        # )
    else()
        # set_target_properties(${OF_PROJECT_NAME} PROPERTIES
        #     MACOSX_BUNDLE_INFO_PLIST    "${OF_PROJECT_DIRECTORY}/openFrameworks-Info.plist"
        # )

        if(CMAKE_BUILD_TYPE STREQUAL "Debug")
            set_target_properties(${OF_PROJECT_NAME} PROPERTIES
                MACOSX_BUNDLE_ICON_FILE "icon-debug.icns"
            )
        else()
            set_target_properties(${OF_PROJECT_NAME} PROPERTIES
                MACOSX_BUNDLE_ICON_FILE "icon.icns"
            )
        endif()
    endif()

    # Strings substituted into the template
    # set(CAMERA_USAGE_DESC "This app uses the camera for live video input.")
    # set(MIC_USAGE_DESC    "This app uses the microphone for audio capture.")
    # set( OF_HIGH_RESOLUTION_CAPABLE ON)
    # TODO: Copy over the icon.icns
    # set(ICON_NAME "${OF_ROOT_DIRECTORY}/libs/openFrameworksCompiled/project/${OF_LIB_DIR_NAME}/icon.icns")
    # set(ICON_NAME "icon.icns")
    # Path to your .icns

    # get_target_property(_icon ${OF_PROJECT_NAME} MACOSX_BUNDLE_ICON_FILE)
    # message(STATUS "Icon file = ${_icon}")   # should show icon-debug.icns or icon.icns
   
endif()



#---- IDE ---------------------
target_sources(${OF_PROJECT_NAME} PRIVATE ${OF_PROJECT_HEADER_AND_SOURCE_FILES})
source_group(TREE "${OF_PROJECT_DIRECTORY}" FILES ${OF_PROJECT_HEADER_AND_SOURCE_FILES})
#---- !IDE! ---------------------




## ADDONS ##############
set(OF_ADDONS "OF_ADDONS")
message(VERBOSE "Project - checking for addons.make file.")
if(EXISTS "${OF_PROJECT_DIRECTORY}/addons.make")
    file(STRINGS "${OF_PROJECT_DIRECTORY}/addons.make" TMP_ADDON_NAMES) 
    foreach(TMP_ADDON_TO_INCLUDE IN LISTS TMP_ADDON_NAMES)
        if(NOT "${TMP_ADDON_TO_INCLUDE}" STREQUAL "")
            message(STATUS "ADDING addon ${TMP_ADDON_TO_INCLUDE}")
            of_addon("${TMP_ADDON_TO_INCLUDE}")
        endif()
    endforeach()
endif()
# add_library(${OF_ADDONS} INTERFACE)
# of_addon("ofxOpenCv")
# of_addon("ofxAssimp")
# target_link_libraries(${OF_PROJECT_NAME} ${OF_ADDONS})




# Works on CMake 3.16+: applies to the current directory (and below)
set_property(DIRECTORY APPEND PROPERTY ADDITIONAL_CLEAN_FILES
  "$<TARGET_BUNDLE_DIR:${OF_PROJECT_NAME}>"
)

add_custom_command(TARGET ${OF_PROJECT_NAME} POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E echo
    "POST_BUILD: ${OF_PROJECT_NAME} has been built successfully."
)


if(APPLE)
    if(OF_BUNDLE_DATA_FOLDER)
        # rsync -avz --delete --exclude='.DS_Store' "${SRCROOT}/bin/data/" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/data/"
        add_custom_command(TARGET ${OF_PROJECT_NAME} POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E echo 
                "--------------------------------------------------" 
            COMMAND ${CMAKE_COMMAND} -E echo 
                "Bundling resources to $<TARGET_BUNDLE_CONTENT_DIR:${OF_PROJECT_NAME}>/Resources" 
            COMMAND ${CMAKE_COMMAND} -E make_directory
                "$<TARGET_BUNDLE_CONTENT_DIR:${OF_PROJECT_NAME}>/Resources/data"
            COMMAND ${CMAKE_COMMAND} -E copy_directory_if_different
                "${OF_PROJECT_DIRECTORY}/bin/data/"
                "$<TARGET_BUNDLE_CONTENT_DIR:${OF_PROJECT_NAME}>/Resources/data"
            COMMAND ${CMAKE_COMMAND} -E echo 
                "--------------------------------------------------" 
        )
    endif()
endif()
# add_library(openFrameworks STATIC)
# target_include_directories(openFrameworks PUBLIC "${PROJECT_SOURCE_DIR}/libs/openFrameworks/include")


# find packages 
# target_compile_options(MyTarget PRIVATE "$<$<CONFIG:Debug>:--my-flag>")


# # or use MATCHES to see if actual system name 
# # Darwin is Apple's system name
# if(${CMAKE_SYSTEM_NAME} MATCHES Darwin)
#     message("This is a ${CMAKE_SYSTEM_NAME} system")
# elseif(${CMAKE_SYSTEM_NAME} MATCHES Windows)
#     message("This is a Windows System")
# endif()

# #  cmake -DCMAKE_BUILD_TYPE=Debug -H.  -Bbuild/Debug
# if(${CMAKE_BUILD_TYPE} MATCHES Debug)
#     message("Debug Build")
# elseif(${CMAKE_BUILD_TYPE} MATCHES Release)
#     message("Release Build")
# endif()






