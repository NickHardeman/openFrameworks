#https://github.com/peterkolski/ofxCMake/blob/master/modules/configApple.cmake 

# make sure to set OF_FRAMEWORKS 
set(OF_CORE_FRAMEWORKS 
    "-framework Accelerate"
    # "-framework AGL"
    "-framework AppKit"
    "-framework ApplicationServices"
    "-framework AudioToolbox"
    "-framework AVFoundation"
    "-framework Cocoa"
    "-framework CoreAudio" 
    "-framework CoreFoundation" 
    "-framework CoreMedia" 
    "-framework CoreServices" 
    "-framework CoreVideo" 
    "-framework Foundation" 
    "-framework IOKit" 
    "-framework OpenGL" 
    "-framework QuartzCore" 
    "-framework Security" 
    "-framework SystemConfiguration" 
    "-framework Metal"
)

set(CMAKE_XCODE_ATTRIBUTE_CLANG_ENABLE_OBJC_ARC "YES")
set(CMAKE_XCODE_ATTRIBUTE_CODE_SIGNING_REQUIRED "NO")

# Set the architectures for which to build.
# set(CMAKE_OSX_ARCHITECTURES "arm64;x86_64")  # only for multi-arch builds
set(CMAKE_OSX_ARCHITECTURES arm64 CACHE INTERNAL "")

# build all architectures
# set(CMAKE_XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH "NO")

#TODO: Break the defines out to shared.
# target_compile_definitions(openFrameworks PUBLIC __MACOSX_CORE__)
# Create a dummy target that just holds compile options
add_library(of_platform_c_flags INTERFACE)

# reference: config.osx.default.mk
target_compile_options(of_platform_c_flags INTERFACE
    -Wall
    -Werror=return-type
    -fexceptions
    -fpascal-strings
)
target_compile_features(of_platform_c_flags INTERFACE
    cxx_std_23
    c_std_17
)

# target_link_options(of_platform_c_flags INTERFACE
#   $<$<PLATFORM_ID:Darwin>:-mmacosx-version-min=10.15>
# )

target_compile_options(openFrameworks PUBLIC -funroll-loops)
target_compile_options(openFrameworks PRIVATE "-fobjc-arc")


# set(CMAKE_CXX_FLAGS_DEBUG "-Wall -Wextra -g")
# set(CMAKE_CXX_FLAGS_RELEASE "-O3")

target_compile_definitions(openFrameworks PUBLIC 
    GL_SILENCE_DEPRECATION=1
    GLES_SILENCE_DEPRECATION=1
    COREVIDEO_SILENCE_GL_DEPRECATION=1
    GLM_FORCE_CTOR_INIT
    GLM_ENABLE_EXPERIMENTAL
    __MACOSX_CORE__
)

target_link_libraries(openFrameworks PUBLIC of_platform_c_flags)

set(CMAKE_OSX_DEPLOYMENT_TARGET "10.15" CACHE STRING "" FORCE)


# if(CMAKE_GENERATOR MATCHES "Xcode")
#     message(STATUS "Modifying Xcode build-settings directly.")
#     target_compile_options(openFrameworks PRIVATE "-fobjc-arc")
# else()
#     target_compile_options(openFrameworks PRIVATE "-fobjc-arc")
# endif()