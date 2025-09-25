
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

if(CMAKE_GENERATOR MATCHES "Xcode")
    message(STATUS "Modifying Xcode build-settings directly.")
    target_compile_options(openFrameworks PRIVATE "-fobjc-arc")
else()
    target_compile_options(openFrameworks PRIVATE "-fobjc-arc")
endif()