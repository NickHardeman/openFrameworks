# References
# https://cliutils.gitlab.io/modern-cmake/chapters/basics.html
# https://www.studyplan.dev/cmake/cpp-build-process
# https://github.com/HerrNamenlos123/openFrameworks/blob/master/cmake/utils.cmake
# https://github.com/peterkolski/ofxCMake/blob/master/modules/configApple.cmake 

# OPENFRAMEWORKS CMAKE 
cmake_minimum_required(VERSION 3.18...4.0)

set(OF_VERSION "12.1")

project(
    openFrameworks
    VERSION ${OF_VERSION}
    LANGUAGES C CXX
    HOMEPAGE_URL "https://github.com/openframeworks/openFrameworks"
    DESCRIPTION "openFrameworks is a C++ toolkit for creative coding."
)

set(CMAKE_INCLUDE_DIRECTORIES_PROJECT_BEFORE ON)

### Require out-of-source builds
file(TO_CMAKE_PATH "${PROJECT_BINARY_DIR}/CMakeLists.txt" LOC_PATH)
if(EXISTS "${LOC_PATH}")
    message(FATAL_ERROR "You cannot build in a source directory (or any directory with a CMakeLists.txt file). Please make a build subdirectory. Feel free to remove CMakeCache.txt and CMakeFiles.")
endif()

if (CMAKE_SOURCE_DIR STREQUAL CMAKE_BINARY_DIR)
    message(FATAL_ERROR "In-source builds are a really bad idea. If you don't know what you're doing, please create a 'build' folder and call 'cmake ..' from within.")
endif()

# Only do these if this is the main project, and not if it is included through add_subdirectory
if(CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME)
    message(STATUS "OF SETTING SOME GLOBAL PARAMS")

    # Optionally set things like CMAKE_CXX_STANDARD, CMAKE_POSITION_INDEPENDENT_CODE here
    # specify the C++ standard
    set(CMAKE_CXX_STANDARD 23)
    set(CMAKE_CXX_STANDARD_REQUIRED True)

    # Let's ensure -std=c++xx instead of -std=g++xx
    set(CMAKE_CXX_EXTENSIONS OFF)

    # Let's nicely support folders in IDEs
    set_property(GLOBAL PROPERTY USE_FOLDERS ON)
    #Enable compile commands so C/C++/clangd gets full IntelliSense:
    set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

endif()

message(STATUS "CMAKE_CURRENT_SOURCE_DIR: ${CMAKE_CURRENT_SOURCE_DIR}")
message(STATUS "PROJECT_SOURCE_DIR: ${PROJECT_SOURCE_DIR}")
message(STATUS "CMAKE_BINARY_DIR: ${CMAKE_BINARY_DIR}" )

# check if the OF Root Directory has been set. 
# TODO: Account if this is set via add_sub_directory
if( NOT DEFINED OF_ROOT_DIRECTORY ) 
    set( OF_ROOT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}" )
    # get_filename_component(OF_ROOT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/../../.." REALPATH BASE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
    # get_filename_component(OF_ROOT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/../../.." REALPATH BASE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
    message(STATUS "OF_ROOT_DIRECTORY not set, setting to ${OF_ROOT_DIRECTORY}")
endif()

message( STATUS "OF_ROOT_DIRECTORY: ${OF_ROOT_DIRECTORY} ")


include("${OF_ROOT_DIRECTORY}/cmake/ofConfig.cmake")
include("${OF_CMAKE_DIRECTORY}/ofUtils.cmake")

# set( OF_LIBS_DIRECTORY "${OF_ROOT_DIRECTORY}/libs")
set( OF_SOURCE_DIRECTORY "${OF_ROOT_DIRECTORY}/libs/openFrameworks")
# set( OF_COMPILED_PROJECT_DIRECTORY "${OF_ROOT_DIRECTORY}/libs/openFrameworksCompiled/project/${OF_LIB_DIR_NAME}")


# -- header files ----------------------------
# of_get_all_subdirectories("${OF_SOURCE_DIRECTORY}" OF_INCLUDE_DIRECTORIES)
# list(APPEND OF_INCLUDE_DIRECTORIES "${OF_SOURCE_DIRECTORY}" )
# list the folders explicitly as GLOB is not recommended

set(OF_INCLUDE_DIRECTORIES
    "${OF_SOURCE_DIRECTORY}" # for ofMain.h
    "${OF_SOURCE_DIRECTORY}/3d"
    "${OF_SOURCE_DIRECTORY}/app"
    "${OF_SOURCE_DIRECTORY}/communication"
    "${OF_SOURCE_DIRECTORY}/events"
    "${OF_SOURCE_DIRECTORY}/gl"
    "${OF_SOURCE_DIRECTORY}/graphics"
    "${OF_SOURCE_DIRECTORY}/math"
    "${OF_SOURCE_DIRECTORY}/sound"
    "${OF_SOURCE_DIRECTORY}/types"
    "${OF_SOURCE_DIRECTORY}/utils"
    "${OF_SOURCE_DIRECTORY}/video"
)


message(Status "CHECKING FOR OF DIRECTORIES")
# foreach(dir ${OF_INCLUDE_DIRECTORIES})
#     message(STATUS "Found directory: ${dir}")
# endforeach()
# -------------------------------------------


# header files -------------------------------------------
set(OF_HEADER_FILES
    #3d
    "3d/of3dPrimitives.h"
    "3d/of3dUtils.h"
    "3d/ofCamera.h"
    "3d/ofEasyCam.h"
    "3d/ofMesh.h"
    "3d/ofNode.h"
    #app
    "app/ofAppBaseWindow.h"
    "app/ofAppGLFWWindow.h"
    "app/ofAppNoWindow.h"
    "app/ofAppRunner.h"
    "app/ofBaseApp.h"
    "app/ofIcon.h"
    "app/ofMainLoop.h"
    "app/ofWindowSettings.h"
    #communication
    "communication/ofArduino.h"
    "communication/ofSerial.h"
    #events
    "events/ofEvent.h"
    "events/ofEvents.h"
    "events/ofEventUtils.h"
    #gl
    "gl/ofBufferObject.h"
    "gl/ofCubeMap.h"
    "gl/ofCubeMapShaders.h"
    "gl/ofFbo.h"
    "gl/ofGLBaseTypes.h"
    "gl/ofGLProgrammableRenderer.h"
    "gl/ofGLRenderer.h"
    "gl/ofGLUtils.h"
    "gl/ofLight.h"
    "gl/ofMaterial.h"
    "gl/ofMaterialBaseTypes.h"
    "gl/ofShader.h"
    "gl/ofShadow.h"
    "gl/ofTexture.h"
    "gl/ofVbo.h"
    "gl/ofVboMesh.h"
    # graphics 
    "graphics/of3dGraphics.h"
    "graphics/ofBitmapFont.h"
    "graphics/ofCairoRenderer.h"
    "graphics/ofGraphics.h"
    "graphics/ofGraphicsBaseTypes.h"
    "graphics/ofGraphicsCairo.h"
    "graphics/ofGraphicsConstants.h"
    "graphics/ofImage.h"
    "graphics/ofPath.h"
    "graphics/ofPixels.h"
    "graphics/ofPolyline.h"
    "graphics/ofRendererCollection.h"
    "graphics/ofTessellator.h"
    "graphics/ofTrueTypeFont.h"
    # math
    "math/ofMath.h"
    "math/ofMathConstants.h"
    "math/ofMatrix3x3.h"
    "math/ofMatrix4x4.h"
    "math/ofQuaternion.h"
    "math/ofVec2f.h"
    "math/ofVec3f.h"
    "math/ofVec4f.h"
    "math/ofVectorMath.h"
    # main
    "ofMain.h"
    #sound
    "sound/ofRtAudioSoundStream.h"
    "sound/ofSoundBaseTypes.h"
    "sound/ofSoundBuffer.h"
    "sound/ofSoundPlayer.h"
    "sound/ofSoundStream.h"
    "sound/ofSoundUtils.h"
    #types
    "types/ofBaseTypes.h"
    "types/ofColor.h"
    "types/ofParameter.h"
    "types/ofPoint.h"
    "types/ofRectangle.h"
    "types/ofTypes.h"
    #utils
    "utils/ofConstants.h"
    "utils/ofFileUtils.h"
    "utils/ofFpsCounter.h"
    "utils/ofJson.h"
    "utils/ofLog.h"
    "utils/ofMatrixStack.h"
    "utils/ofNoise.h"
    "utils/ofRandomDistributions.h"
    "utils/ofRandomEngine.h"
    "utils/ofSingleton.h"
    "utils/ofSystemUtils.h"
    "utils/ofThread.h"
    "utils/ofThreadChannel.h"
    "utils/ofTimer.h"
    "utils/ofTimerFps.h"
    "utils/ofURLFileLoader.h"
    "utils/ofUtils.h"
    "utils/ofXml.h"
    #video
    "video/ofVideoBaseTypes.h"
    "video/ofVideoGrabber.h"
    "video/ofVideoPlayer.h"
)


# source files -------------------------------------------
message(STATUS "Getting OF source files")
#  https://cliutils.gitlab.io/modern-cmake/chapters/intro/dodonot.html
# add the source files explicity as GLOB is not recommended
set( OF_SOURCE_FILES 
    #3d
    "3d/of3dPrimitives.cpp"
    "3d/of3dUtils.cpp"
    "3d/ofCamera.cpp"
    "3d/ofEasyCam.cpp"
    "3d/ofMesh.inl" # unsure about this one
    "3d/ofNode.cpp"
    #app
    # "app/ofAppEGLWindow.cpp" # going to add later based on OS
    "app/ofAppGLFWWindow.cpp"
    "app/ofAppNoWindow.cpp"
    "app/ofAppRunner.cpp"
    "app/ofBaseApp.cpp"
    "app/ofMainLoop.cpp"
    # communication
    "communication/ofArduino.cpp"
    "communication/ofSerial.cpp"
    #events
    "events/ofEvents.cpp"
    #gl
    "gl/ofBufferObject.cpp"
    "gl/ofCubeMap.cpp"
    "gl/ofFbo.cpp"
    "gl/ofGLProgrammableRenderer.cpp"
    "gl/ofGLRenderer.cpp"
    "gl/ofGLUtils.cpp"
    "gl/ofLight.cpp"
    "gl/ofMaterial.cpp"
    "gl/ofShader.cpp"
    "gl/ofShadow.cpp"
    "gl/ofTexture.cpp"
    "gl/ofVbo.cpp"
    "gl/ofVboMesh.cpp"
    #graphics
    "graphics/of3dGraphics.cpp"
    "graphics/ofBitmapFont.cpp"
    "graphics/ofCairoRenderer.cpp"
    "graphics/ofGraphics.cpp"
    "graphics/ofGraphicsBaseTypes.cpp"
    "graphics/ofGraphicsCairo.cpp"
    "graphics/ofImage.cpp"
    "graphics/ofPath.cpp"
    "graphics/ofPixels.cpp"
    "graphics/ofPolyline.inl" # is this a source?
    "graphics/ofRendererCollection.cpp"
    "graphics/ofTessellator.cpp"
    "graphics/ofTrueTypeFont.cpp"
    #math
    "math/ofMath.cpp"
    "math/ofMatrix3x3.cpp"
    "math/ofMatrix4x4.cpp"
    "math/ofQuaternion.cpp"
    "math/ofVec2f.cpp"
    "math/ofVec4f.cpp"
    #sound
    "sound/ofRtAudioSoundStream.cpp"
    "sound/ofSoundBaseTypes.cpp"
    "sound/ofSoundBuffer.cpp"
    "sound/ofSoundPlayer.cpp"
    "sound/ofSoundStream.cpp"
    #types
    "types/ofBaseTypes.cpp"
    "types/ofColor.cpp"
    "types/ofParameter.cpp"
    "types/ofParameterGroup.cpp"
    "types/ofRectangle.cpp"
    #utils
    "utils/ofFileUtils.cpp"
    "utils/ofFpsCounter.cpp"
    "utils/ofLog.cpp"
    "utils/ofMatrixStack.cpp"
    "utils/ofSystemUtils.cpp"
    "utils/ofThread.cpp"
    "utils/ofTimer.cpp"
    "utils/ofTimerFps.cpp"
    "utils/ofURLFileLoader.cpp"
    "utils/ofUtils.cpp"
    "utils/ofXml.cpp"
    #video
    "video/ofVideoBaseTypes.cpp"
    "video/ofVideoGrabber.cpp"
    "video/ofVideoPlayer.cpp"
)



set(OF_MEIDA_FOUNDATION_HEADERS 
    "sound/ofMediaFoundationSoundPlayer.h" 
    "video/ofMediaFoundationPlayer.h"
)
set(OF_MEDIA_FOUNDATION_SOURCES  
    "sound/ofMediaFoundationSoundPlayer.cpp" 
    "video/ofMediaFoundationPlayer.cpp"
)

set(OF_DIRECTSHOW_HEADERS 
    "video/ofDirectShowGrabber.h" 
    "video/ofDirectShowPlayer.h" 
)
set(OF_DIRECTSHOW_SOURCES  
    "video/ofDirectShowPlayer.cpp" 
    "video/ofDirectShowGrabber.cpp"
)

set(OF_GST_HEADERS 
    "video/ofGstUtils.h" 
    "video/ofGstVideoGrabber.h" 
    "video/ofGstVideoPlayer.h" 
)
set(OF_GST_SOURCES 
    "video/ofGstUtils.cpp"
    "video/ofGstVideoGrabber.cpp" 
    "video/ofGstVideoPlayer.cpp" 
)

set(OF_AVFOUNDATION_HEADERS 
    "sound/ofAVEngineSoundPlayer.h" 
    "video/ofAVFoundationGrabber.h" 
    "video/ofAVFoundationPlayer.h"
    "video/ofAVFoundationVideoPlayer.h"
    
)
set(OF_AVFOUNDATION_SOURCES 
    "sound/ofAVEngineSoundPlayer.mm" 
    "video/ofAVFoundationGrabber.mm" 
    "video/ofAVFoundationPlayer.mm" 
    "video/ofAVFoundationVideoPlayer.m" 
)


if( APPLE ) # Apple is a Unix, too. So dont ask only first UNIX
    # include( ${OF_CMAKE_MODULES}/openFrameworksApple.cmake )
    message(STATUS "openFrameworks.cmake. APPLE")
    list(APPEND OF_HEADER_FILES ${OF_AVFOUNDATION_HEADERS})
    list(APPEND OF_SOURCE_FILES ${OF_AVFOUNDATION_SOURCES})
elseif( UNIX )
    # include( ${OF_CMAKE_MODULES}/openFrameworksLinux.cmake )
    message(STATUS "openFrameworks.cmake. UNIX")
    list(APPEND OF_HEADER_FILES ${OF_GST_HEADERS})
    list(APPEND OF_SOURCE_FILES ${OF_GST_SOURCES})
elseif( WIN32)
    # include( ${OF_CMAKE_MODULES}/openFrameworksWindows.cmake )
    message(STATUS "openFrameworks.cmake. WIN32")
    list(APPEND OF_HEADER_FILES ${OF_MEIDA_FOUNDATION_HEADERS})
    list(APPEND OF_SOURCE_FILES ${OF_MEDIA_FOUNDATION_SOURCES})
    list(APPEND OF_HEADER_FILES ${OF_DIRECTSHOW_HEADERS})
    list(APPEND OF_SOURCE_FILES ${OF_DIRECTSHOW_SOURCES})
else()
    message( FATAL_ERROR "Operating System not supported" )
endif()


# loop through and add the extended paths 
of_add_prefix_to_list("${OF_HEADER_FILES}" "${OF_SOURCE_DIRECTORY}/" OF_HEADER_FILES)
of_add_prefix_to_list("${OF_SOURCE_FILES}" "${OF_SOURCE_DIRECTORY}/" OF_SOURCE_FILES)


# now we set the properties
if( APPLE )
    enable_language(OBJCXX)
    # not sure if it matters by setting it on all the files.
    set_source_files_properties( 
        ${OF_SOURCE_FILES} 
        PROPERTIES 
        LANGUAGE OBJCXX 
    )
endif()


set(OF_HEADER_AND_SOURCE_FILES ${OF_HEADER_FILES} ${OF_SOURCE_FILES})

# of_print_list(OF_INCLUDE_DIRECTORIES PREFIX "  📂 OF Include: " LEVEL VERBOSE)
# of_print_list(OF_SOURCE_FILES PREFIX "  📄 OF Header: " LEVEL VERBOSE)
# of_print_list(OF_SOURCE_FILES PREFIX "  📜 OF Source: " LEVEL VERBOSE)



set(OF_LIBS_DIRECTORY "${OF_ROOT_DIRECTORY}/libs")
set( OF_COMPILED_PROJECT_DIRECTORY "${OF_ROOT_DIRECTORY}/libs/openFrameworksCompiled/project/${OF_LIB_DIR_NAME}")


# message(STATUS "OF_LIBS_DIRECTORY_REL: ${OF_LIBS_DIRECTORY_REL}")
message(VERBOSE "📦 OF_COMPILED_PROJECT_DIRECTORY: ${OF_COMPILED_PROJECT_DIRECTORY}")
message(STATUS "📂 OF_LIBS_DIRECTORY: ${OF_LIBS_DIRECTORY}")



# add_library(openFrameworks STATIC ${OF_HEADER_AND_SOURCE_FILES})
# add_library(openFrameworks STATIC ${OF_HEADER_AND_SOURCE_FILES_REL})
# omitting STATIC so that BUILD_SHARED_LIBS will set it to SHARED if ON, otherwise it's STATIC by default.
add_library(openFrameworks ${OF_SOURCE_FILES} )
# target_sources(openFrameworks PRIVATE ${OF_SOURCE_FILES})
target_include_directories(openFrameworks PUBLIC ${OF_INCLUDE_DIRECTORIES})
# target_include_directories(openFrameworks PUBLIC ${OF_INCLUDE_DIRECTORIES})
# target_include_directories(openFrameworks PUBLIC ${OF_INCLUDE_DIRECTORIES})




#--------------------------------------------------------------------------------------------
# ADD THIRD PARTY LIBS 
# Get the third party libs 
# set(OF_LIBS_DIRECTORY "${OF_ROOT_DIRECTORY}/libs/${OF_LIB_DIR_NAME}")

message(STATUS "---------------------------------------------------")
message(STATUS "---------------------------------------------------")
message(STATUS "---------------------------------------------------")
message(STATUS "---------------------------------------------------")
message(STATUS "----------OF libs directory ${OF_LIBS_DIRECTORY}------------------")
# we need to loop through the library folder and include header files and libs if present 
# we probably want to add an of_add_library_from_folder()
# ************************************************************


set(OF_CORE_FRAMEWORKS "")
set(OF_CORE_LIBS "")
if( APPLE ) # Apple is a Unix, too. So dont ask only first UNIX
    # sets OF_CORE_FRAMEWORKS with -framework name 
    include( "${OF_CMAKE_DIRECTORY}/ofConfigMacOS.cmake" )
endif()

file(GLOB OF_LIBS_DIRECTORIES CONFIGURE_DEPENDS "${OF_LIBS_DIRECTORY}/*")
# loop through each of the libs / folders and try to extract static libs
foreach(lib_dir ${OF_LIBS_DIRECTORIES})
    of_add_library_from_directory(${lib_dir} OUT_LIBS_ADDED)
    list(APPEND OF_CORE_LIBS ${OUT_LIBS_ADDED} )
endforeach()
# !ADD THIRD PARTY LIBS!
#--------------------------------------------------------------------------------------------





# ---- add to the IDE ------
# grab shaders in the gl/shaders folder to add to the ide
file(GLOB_RECURSE GL_SHADER_FILES CONFIGURE_DEPENDS
    "${OF_SOURCE_DIRECTORY}/gl/shaders/*.frag" 
    "${OF_SOURCE_DIRECTORY}/gl/shaders/*.glsl"
    "${OF_SOURCE_DIRECTORY}/gl/shaders/*.vert"  
)

target_sources(openFrameworks PRIVATE ${GL_SHADER_FILES})
target_sources(openFrameworks PRIVATE ${OF_HEADER_AND_SOURCE_FILES})
source_group(TREE "${OF_SOURCE_DIRECTORY}" FILES ${GL_SHADER_FILES})
source_group(TREE "${OF_SOURCE_DIRECTORY}" FILES ${OF_HEADER_AND_SOURCE_FILES})
# ---------------------------



target_link_libraries( openFrameworks PUBLIC ${OF_CORE_LIBS} ${OF_CORE_FRAMEWORKS})
# target_link_libraries(openFrameworks PUBLIC ${OF_CORE_FRAMEWORKS})
# target_include_directories(openFrameworks PUBLIC ${OF_CORE_HEADERS})

message(STATUS "OF binary directory ${CMAKE_CURRENT_BINARY_DIR}")

# target_compile_features(openFrameworks PUBLIC cxx_std_17)
# set_target_properties(openFrameworks PROPERTIES CXX_EXTENSIONS OFF)
# target_compile_options(openFrameworks PRIVATE "-fobjc-arc")

# remove lib prefix
# set_target_properties(openFrameworks PROPERTIES PREFIX "")

set_target_properties(openFrameworks PROPERTIES
    OUTPUT_NAME "openFrameworks"
    OUTPUT_NAME_DEBUG "openFrameworksDebug"
)

set(OF_LIB_TARGET_DIRECTORY "${OF_ROOT_DIRECTORY}/libs/openFrameworksCompiled/lib/${OF_LIB_DIR_NAME}/$<IF:$<CONFIG:Debug>,Debug,Release>")
# set(OF_LIB_TARGET_DIRECTORY "${OF_ROOT_DIRECTORY}/libs/openFrameworksCompiled/lib/${OF_LIB_DIR_NAME}/$<CONFIG>")
message(STATUS "OF_LIB_TARGET_DIRECTORY: ${OF_LIB_TARGET_DIRECTORY}")

set_target_properties(openFrameworks PROPERTIES
    ARCHIVE_OUTPUT_DIRECTORY "${OF_LIB_TARGET_DIRECTORY}"
    LIBRARY_OUTPUT_DIRECTORY "${OF_LIB_TARGET_DIRECTORY}"
)

install(TARGETS openFrameworks 
  DESTINATION "${OF_LIB_TARGET_DIRECTORY}/bin"
)

# preprocessor macros
# target_compile_definitions(openFrameworks PUBLIC USE_SOUND) USE_SOUND is macro


# cmake .. --log-level=VERBOSE
# message(STATUS "This is a status message")
# message(VERBOSE "This is verbose message")
# message(DEBUG "This is debug message")
# message(TRACE "This is trace message")

# -DCMAKE_BUILD_TYPE=Debug

# cmake ..
# cmake --build . --parallel

# -S <src> = where your CMakeLists.txt lives (source tree)
# -B <bin> = where CMake should generate and store build files (build tree)
# cmake -S . -B macos/build-make/Release
# cmake --build macos/build-make/Release --parallel 

# cmake -S . -B macos/build-make/Debug -DCMAKE_BUILD_TYPE=Debug
# cmake --build macos/build-make/Debug --parallel 


# cmake .. -G Xcode
# cmake --build . --config Release    # or Debug

# cd to the directory of the CMakeLists.txt
# cmake -S . -B macos/build-xcode
# cmake --build macos/build-xcode --config Release --parallel
# cmake --build macos/build-xcode --config Debug --parallel

# cmake .. -G "Ninja Multi-Config"
# cmake --build . --config Release

# https://www.studyplan.dev/cmake/cmake-build-configurations
# Two Generator Types: Single-configuration (Makefiles, Ninja) set the build type at configure time (-DCMAKE_BUILD_TYPE=Debug). 
# Multi-configuration (Visual Studio, Xcode) set it at build time (-config Debug).


# From your build dir:
# cmake --build . --target clean

# Or specify the build dir:
# cmake --build build --target clean
















# # -- GLOB approach but not recommended
# # file(GLOB_RECURSE OF_SOURCE_FILES_ABS "${OF_SOURCE_DIRECTORY}/*.cpp")
# # add in some objective-c files 
# # if( APPLE ) 
# #     file(GLOB_RECURSE OF_SOURCE_MM_FILES  "${OF_SOURCE_DIRECTORY}/*.mm" "${OF_SOURCE_DIRECTORY}/*.m")
# #     foreach(entry ${OF_SOURCE_MM_FILES})
# #         list(APPEND OF_SOURCE_FILES_ABS "${entry}")
# #     endforeach()
# # endif()

# # make_filespaths_relative("${CMAKE_SOURCE_DIR}" "${OF_SOURCE_FILES_ABS}" OF_SOURCE_FILES)
# # foreach(src_file ${OF_SOURCE_FILES_ABS})
# #     message(STATUS "Found source fileXXXX: ${src_file}")
# # endforeach()

# # set(OF_SOURCE_FILES ${OF_SOURCE_FILES_ABS} )

# # message(STATUS "Getting OF Header files")
# # file(GLOB_RECURSE OF_HEADERS_FILES_ABS 
# #     "${OF_SOURCE_DIRECTORY}/*.h" 
# #     "${OF_SOURCE_DIRECTORY}/*.hpp"
# #     "${OF_SOURCE_DIRECTORY}/*.inl"
# # )



# # set(OF_SOURCE_FILES_RELATIVE "")

# # foreach(src_file ${OF_SOURCE_FILES})
# #     file(RELATIVE_PATH rel_path "${CMAKE_SOURCE_DIR}" "${src_file}")
# #     list(APPEND OF_SOURCE_FILES_RELATIVE "${rel_path}")
# # endforeach()

# # # Optionally replace the original list so that we have a list of relative paths 
# # set(OF_SOURCE_FILES ${OF_SOURCE_FILES_RELATIVE})
# # -- source files -------------------------------------



# # foreach(src_file ${OF_SOURCE_FILES})
# #     message(STATUS "Found source file: ${src_file}")
# # endforeach()

# # set(OF_SOURCES_EXCLUDE "")

# # # TODO: Expand on these lists 
# # set(OF_MEDIA_FOUNDATION_SOURCES "sound/ofMediaFoundationSoundPlayer.h" "sound/ofMediaFoundationSoundPlayer.cpp" )
# # list(APPEND OF_MEDIA_FOUNDATION_SOURCES "video/ofMediaFoundationPlayer.h" "video/ofMediaFoundationPlayer.cpp")
# # set(OF_DIRECTSHOW_SOURCES "video/ofDirectShowGrabber.h" "video/ofDirectShowGrabber.cpp")
# # list(APPEND OF_DIRECTSHOW_SOURCES "video/ofDirectShowPlayer.h" "video/ofDirectShowPlayer.cpp")

# # set(OF_GST_SOURCES "video/ofGstUtils.h" "video/ofGstUtils.cpp" )
# # list(APPEND OF_GST_SOURCES "video/ofGstVideoGrabber.h" "video/ofGstVideoGrabber.cpp")
# # list(APPEND OF_GST_SOURCES "video/ofGstVideoPlayer.h" "video/ofGstVideoPlayer.cpp")

# # set(OF_AVFOUNDATION_SOURCES "sound/ofAVEngineSoundPlayer.h" "sound/ofAVEngineSoundPlayer.mm" )
# # list(APPEND OF_AVFOUNDATION_SOURCES "video/ofAVFoundationGrabber.h" "video/ofAVFoundationGrabber.mm" )
# # list(APPEND OF_AVFOUNDATION_SOURCES "video/ofAVFoundationPlayer.h" "video/ofAVFoundationPlayer.mm")
# # list(APPEND OF_AVFOUNDATION_SOURCES "video/ofAVFoundationVideoPlayer.h" "video/ofAVFoundationVideoPlayer.m")

# # if( APPLE ) # Apple is a Unix, too. So dont ask only first UNIX
# #     # set(OF_LIB_DIR_NAME "macos")

# #     enable_language(OBJCXX)
# #     set_source_files_properties( 
# #         ${OF_SOURCE_FILES} 
# #         PROPERTIES 
# #         LANGUAGE OBJCXX 
# #     )
# #     # include( ${OF_CMAKE_MODULES}/openFrameworksApple.cmake )
# #     message(STATUS "openFrameworks.cmake. APPLE")
# #     list(APPEND OF_SOURCES_EXCLUDE ${OF_MEDIA_FOUNDATION_SOURCES})
# #     list(APPEND OF_SOURCES_EXCLUDE ${OF_DIRECTSHOW_SOURCES})
# #     list(APPEND OF_SOURCES_EXCLUDE ${OF_GST_SOURCES})
# #     # list(APPEND OF_SOURCES_EXCLUDE "sound/ofMediaFoundationSoundPlayer.h" "sound/ofMediaFoundationSoundPlayer.cpp")
# #     # list(APPEND OF_SOURCES_EXCLUDE "video/ofMediaFoundationPlayer.h" "video/ofMediaFoundationPlayer.cpp")
# #     # list(APPEND OF_SOURCES_EXCLUDE "video/ofDirectShowGrabber.h" "video/ofDirectShowGrabber.cpp")
# #     # list(APPEND OF_SOURCES_EXCLUDE "video/ofDirectShowPlayer.h" "video/ofDirectShowPlayer.cpp")
# #     # list(APPEND OF_SOURCES_EXCLUDE "video/ofGstUtils.h" "video/ofGstUtils.cpp")
# #     # list(APPEND OF_SOURCES_EXCLUDE "video/ofGstVideoGrabber.h" "video/ofGstVideoGrabber.cpp")
# #     # list(APPEND OF_SOURCES_EXCLUDE "video/ofGstVideoPlayer.h" "video/ofGstVideoPlayer.cpp")
# #     list(APPEND OF_SOURCES_EXCLUDE "app/ofAppEGLWindow.h" "app/ofAppEGLWindow.cpp") # Not sure that this is for
# # elseif( UNIX )
# #     # include( ${OF_CMAKE_MODULES}/openFrameworksLinux.cmake )
# #     message(STATUS "openFrameworks.cmake. UNIX")
# #     list(APPEND OF_SOURCES_EXCLUDE ${OF_MEDIA_FOUNDATION_SOURCES})
# #     list(APPEND OF_SOURCES_EXCLUDE ${OF_DIRECTSHOW_SOURCES})
# #     list(APPEND OF_SOURCES_EXCLUDE ${OF_AVFOUNDATION_SOURCES})
# # elseif( WIN32)
# #     # include( ${OF_CMAKE_MODULES}/openFrameworksWindows.cmake )
# #     message(STATUS "openFrameworks.cmake. WIN32")
# #     list(APPEND OF_SOURCES_EXCLUDE ${OF_AVFOUNDATION_SOURCES})
# #     list(APPEND OF_SOURCES_EXCLUDE ${OF_GST_SOURCES})
# # else()
# #     message( FATAL_ERROR "Operating System not supported" )
# # endif()


# # # foreach(src_file ${OF_SOURCES_EXCLUDE})
# # #     message(STATUS "Exclude source file: ${src_file}")
# # # endforeach()

# # # --- EXCLUDE SOURCE FILES ------------------
# # of_exclude_paths_from_list("${OF_SOURCE_FILES}" "${OF_SOURCES_EXCLUDE}" OF_SOURCE_FILES_FILTERED)
# # # Replace original list with filtered one
# # set(OF_SOURCE_FILES ${OF_SOURCE_FILES_FILTERED})


# # of_exclude_paths_from_list("${OF_HEADERS_FILES_ABS}" "${OF_SOURCES_EXCLUDE}" OF_HEADER_FILES_FILTERED)
# # set(OF_HEADER_FILES ${OF_HEADER_FILES_FILTERED})


# # # foreach(src_file ${OF_SOURCE_FILES})
# # #     message(STATUS " Found source file: ${src_file}")
# # # endforeach()

# # # message(STATUS "TRYING TO GET THE HEADERS")
# # # foreach(src_file ${OF_HEADER_FILES})
# # #     message(STATUS "Found header file: ${src_file}")
# # # endforeach()

# # message(STATUS "TRYING TO GET THE OF HEADERS AND THE SOURCES")
# # set(OF_HEADER_AND_SOURCE_FILES ${OF_HEADER_FILES} ${OF_SOURCE_FILES})
# # # foreach(src_file ${OF_HEADER_AND_SOURCE_FILES})
# # #     message(STATUS "Found header or source file: ${src_file}")
# # # endforeach()



# set(OF_LIBS_DIRECTORY "${OF_ROOT_DIRECTORY}/libs")



# set( OF_COMPILED_PROJECT_DIRECTORY "${OF_ROOT_DIRECTORY}/libs/openFrameworksCompiled/project/${OF_LIB_DIR_NAME}")
# # file(RELATIVE_PATH OF_LIBS_DIRECTORY_REL
# #     "${OF_COMPILED_PROJECT_DIRECTORY}"
# #     "${OF_LIBS_DIRECTORY}"
# # )


# message(STATUS "OF_LIBS_DIRECTORY_REL: ${OF_LIBS_DIRECTORY_REL}")
# message(STATUS "OF_COMPILED_PROJECT_DIRECTORY: ${OF_COMPILED_PROJECT_DIRECTORY}")
# message(STATUS "OF_LIBS_DIRECTORY: ${OF_LIBS_DIRECTORY}")



# # of_make_filespaths_relative REL_PATH IN_VARS OUT_VAR
# # make_filespaths_relative("${CMAKE_SOURCE_DIR}" "${OF_SOURCE_FILES_ABS}" OF_SOURCE_FILES)
# # of_make_filespaths_relative("${CMAKE_BINARY_DIR}" "${OF_HEADER_AND_SOURCE_FILES}"  OF_HEADER_FILES_REL)
# # of_make_filespaths_relative("${CMAKE_BINARY_DIR}" "${OF_HEADER_AND_SOURCE_FILES}"  OF_HEADER_AND_SOURCE_FILES_REL)
# # of_make_filespaths_relative("${OF_COMPILED_PROJECT_DIRECTORY}" "${OF_INCLUDE_DIRECTORIES}"  OF_INCLUDE_DIRECTORIES_REL)
# # of_make_filespaths_relative("${CMAKE_CURRENT_SOURCE_DIR}" "${OF_INCLUDE_DIRECTORIES}"  OF_INCLUDE_DIRECTORIES_REL)

# # foreach(src_file ${OF_HEADER_AND_SOURCE_FILES_REL})
# #     message(STATUS "Source and header relative file: ${src_file}")
# # endforeach()


# # foreach(src_file ${OF_HEADER_FILES_REL})
# #     # message(STATUS "OF_HEADER_FILES: ${src_file}")
# #     if(EXISTS "${src_file}" )
# #         message(STATUS "✅ OF_HEADER_FILES_REL FILE EXISTS : ${src_file}")
# #     else()
# #         message(STATUS "❌ OF_HEADER_FILES_REL FILE DOES NOT EXIST: ${src_file}")
# #     endif()
# # endforeach()

# # foreach(src_file ${OF_SOURCE_FILES})
# #     message(STATUS "OF_SOURCE_FILES: ${src_file}")
# # endforeach()

# foreach(src_file ${OF_INCLUDE_DIRECTORIES})
#     if(EXISTS "${src_file}" )
#         message(STATUS "✅ OF_INCLUDE_DIRECTORIES: ${src_file}")
#     else()
#         message(STATUS "❌ OF_INCLUDE_DIRECTORIES: ${src_file}")
#     endif()
# endforeach()



# # add_library(openFrameworks STATIC ${OF_HEADER_AND_SOURCE_FILES})
# # add_library(openFrameworks STATIC ${OF_HEADER_AND_SOURCE_FILES_REL})
# # omitting STATIC so that BUILD_SHARED_LIBS will set it to SHARED if ON, otherwise it's STATIC by default.
# add_library(openFrameworks ${OF_SOURCE_FILES} )
# # target_sources(openFrameworks PRIVATE ${OF_SOURCE_FILES})
# target_include_directories(openFrameworks PUBLIC ${OF_INCLUDE_DIRECTORIES})
# # target_include_directories(openFrameworks PUBLIC ${OF_INCLUDE_DIRECTORIES})
# # target_include_directories(openFrameworks PUBLIC ${OF_INCLUDE_DIRECTORIES})




# #--------------------------------------------------------------------------------------------
# # ADD THIRD PARTY LIBS 
# # Get the third party libs 
# # set(OF_LIBS_DIRECTORY "${OF_ROOT_DIRECTORY}/libs/${OF_LIB_DIR_NAME}")

# message(STATUS "---------------------------------------------------")
# message(STATUS "---------------------------------------------------")
# message(STATUS "---------------------------------------------------")
# message(STATUS "---------------------------------------------------")
# message(STATUS "----------OF libs directory ${OF_LIBS_DIRECTORY}------------------")
# # we need to loop through the library folder and include header files and libs if present 
# # we probably want to add an of_add_library_from_folder()
# # ************************************************************


# set(OF_CORE_FRAMEWORKS "")
# set(OF_CORE_LIBS "")
# if( APPLE ) # Apple is a Unix, too. So dont ask only first UNIX
#     # sets OF_CORE_FRAMEWORKS with -framework name 
#     include( "${OF_CMAKE_DIRECTORY}/ofConfigMacOS.cmake" )
# endif()

# file(GLOB OF_LIBS_DIRECTORIES "${OF_LIBS_DIRECTORY}/*")
# foreach(lib_dir ${OF_LIBS_DIRECTORIES})
#     of_add_library_from_directory(${lib_dir} OUT_LIBS_ADDED)
#     list(APPEND OF_CORE_LIBS ${OUT_LIBS_ADDED} )
# endforeach()
# # !ADD THIRD PARTY LIBS!
# #--------------------------------------------------------------------------------------------






# # # ---- add to the IDE ------
# # target_sources(openFrameworks PRIVATE ${OF_HEADER_AND_SOURCE_FILES})
# # source_group(TREE "${OF_SOURCE_DIRECTORY}" FILES ${OF_HEADER_AND_SOURCE_FILES})

# # # foreach(source_file ${OF_HEADER_AND_SOURCE_FILES})
# # #     # message(STATUS "adding source file to tree: ${source_file} current dir: ${CMAKE_CURRENT_SOURCE_DIR}" )
# # #     # message(STATUS "adding source file to tree: ${source_file}" )
# # #     # Make the path relative to the source root
# # #     file(RELATIVE_PATH rel_path "${OF_SOURCE_DIRECTORY}" "${source_file}")
    
# # #     # Get the directory part (e.g., libs/openFrameworks/sound)
# # #     get_filename_component(source_path "${rel_path}" PATH)
    
# # #     # Replace slashes with backslashes for source_group (for Windows-style groups)
# # #     string(REPLACE "/" "\\" group_path "${source_path}")
    
# # #     source_group("${group_path}" FILES "${source_file}")
# # # endforeach()

# # # ---------------------------





# #headers
# # set(OF_CORE_HEADERS "")
# # get_all_subdirectories( "${OF_LIBS_DIRECTORY}/include" OF_CORE_HEADERS )
# # foreach(src_file ${OF_CORE_HEADERS})
# #     message(STATUS "Found core header: ${src_file}")
# # endforeach()

# # include_directories(${OF_CORE_HEADERS})


# # message(STATUS "GL DIRECTORY:  ${OF_LIBS_DIRECTORY}/include")

# # add in the libraries
# # OF_LIBS_DIRECTORY

# # include everything in there //
# # file(GLOB_RECURSE OF_CORE_LIBS "${OF_LIBS_DIRECTORY}/lib/*.a" "${OF_LIBS_DIRECTORY}/lib/*.dylib")
# # foreach(src_file ${OF_CORE_LIBS})
# #     message(STATUS "Found core lib: ${src_file}")
# # endforeach()


# # set( OF_COMPILED_PROJECT_DIRECTORY "${OF_ROOT_DIRECTORY}/libs/openFrameworksCompiled/project/${OF_LIB_DIR_NAME}")
# # file(RELATIVE_PATH OF_LIBS_DIRECTORY_REL
# #     "${OF_COMPILED_PROJECT_DIRECTORY}"
# #     "${OF_LIBS_DIRECTORY}"
# # )

# # message(STATUS "OF_LIBS_DIRECTORY_REL: ${OF_LIBS_DIRECTORY_REL}")
# # message(STATUS "OF_COMPILED_PROJECT_DIRECTORY: ${OF_COMPILED_PROJECT_DIRECTORY}")
# # message(STATUS "OF_LIBS_DIRECTORY: ${OF_LIBS_DIRECTORY}")

# # target_include_directories(openFrameworks PUBLIC "${OF_LIBS_DIRECTORY_REL}/include")
# # target_include_directories(openFrameworks PUBLIC "${OF_LIBS_DIRECTORY_REL}/include/utf8cpp")
# # target_include_directories(openFrameworks PUBLIC "${OF_LIBS_DIRECTORY_REL}/include/rtaudio")


# target_link_libraries( openFrameworks ${OF_CORE_LIBS} ${OF_CORE_FRAMEWORKS})
# # target_link_libraries(openFrameworks PUBLIC ${OF_CORE_FRAMEWORKS})
# # target_include_directories(openFrameworks PUBLIC ${OF_CORE_HEADERS})

# # set_target_properties( of_static    PROPERTIES OUTPUT_NAME openFrameworksStatic)

# message(STATUS "OF binary directory ${CMAKE_CURRENT_BINARY_DIR}")

# # target_compile_features(openFrameworks PUBLIC cxx_std_17)
# # set_target_properties(openFrameworks PROPERTIES CXX_EXTENSIONS OFF)
# # target_compile_options(openFrameworks PRIVATE "-fobjc-arc")

# # remove lib prefix
# # set_target_properties(openFrameworks PROPERTIES PREFIX "")

# set_target_properties(openFrameworks PROPERTIES
#     OUTPUT_NAME "openFrameworks"
#     OUTPUT_NAME_DEBUG "openFrameworksDebug"
# )

# set(OF_LIB_TARGET_DIRECTORY "${OF_ROOT_DIRECTORY}/libs/openFrameworksCompiled/lib/${OF_LIB_DIR_NAME}/$<IF:$<CONFIG:Debug>,Debug,Release>")
# # set(OF_LIB_TARGET_DIRECTORY "${OF_ROOT_DIRECTORY}/libs/openFrameworksCompiled/lib/${OF_LIB_DIR_NAME}/$<CONFIG>")
# message(STATUS "OF_LIB_TARGET_DIRECTORY: ${OF_LIB_TARGET_DIRECTORY}")

# # Where compiled binaries should be placed
# # set_target_properties(openFrameworks PROPERTIES
# #     ARCHIVE_OUTPUT_DIRECTORY "${OF_LIB_TARGET_DIRECTORY}/$<IF:$<CONFIG:Debug>,debug,release>"
# #     LIBRARY_OUTPUT_DIRECTORY "${OF_LIB_TARGET_DIRECTORY}/$<IF:$<CONFIG:Debug>,debug,release>"
# # )

# set_target_properties(openFrameworks PROPERTIES
#     ARCHIVE_OUTPUT_DIRECTORY "${OF_LIB_TARGET_DIRECTORY}"
#     LIBRARY_OUTPUT_DIRECTORY "${OF_LIB_TARGET_DIRECTORY}"
# )

# install(TARGETS openFrameworks 
#   DESTINATION "${OF_LIB_TARGET_DIRECTORY}/bin"
# )

# preprocessor macros
# target_compile_definitions(openFrameworks PUBLIC USE_SOUND) USE_SOUND is macro


# cmake .. --log-level=VERBOSE
# message(STATUS "This is a status message")
# message(VERBOSE "This is verbose message")
# message(DEBUG "This is debug message")
# message(TRACE "This is trace message")

# -DCMAKE_BUILD_TYPE=Debug

# cmake ..
# cmake --build . --parallel

# -S <src> = where your CMakeLists.txt lives (source tree)
# -B <bin> = where CMake should generate and store build files (build tree)
# cmake -S . -B macos/build-make/Release
# cmake --build macos/build-make/Release --parallel 

# cmake -S . -B macos/build-make/Debug -DCMAKE_BUILD_TYPE=Debug
# cmake --build macos/build-make/Debug --parallel 


# cmake .. -G Xcode
# cmake --build . --config Release    # or Debug

# cd to the directory of the CMakeLists.txt
# cmake -S . -B macos/build-xcode
# cmake --build macos/build-xcode --config Release --parallel
# cmake --build macos/build-xcode --config Debug --parallel

# cmake .. -G "Ninja Multi-Config"
# cmake --build . --config Release

# https://www.studyplan.dev/cmake/cmake-build-configurations
# Two Generator Types: Single-configuration (Makefiles, Ninja) set the build type at configure time (-DCMAKE_BUILD_TYPE=Debug). 
# Multi-configuration (Visual Studio, Xcode) set it at build time (-config Debug).


# From your build dir:
# cmake --build . --target clean

# Or specify the build dir:
# cmake --build build --target clean