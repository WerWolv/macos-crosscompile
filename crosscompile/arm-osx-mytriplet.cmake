set(VCPKG_TARGET_ARCHITECTURE arm64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE static)
# You can override linkage type by package if needed
if(PORT STREQUAL "portaudio")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()

set(VCPKG_BUILD_TYPE release)

set(VCPKG_CMAKE_SYSTEM_NAME Darwin)

set(ENV{OSXCROSS_HOST} "aarch64-apple-$ENV{OSXCROSS_TARGET}")

set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE /osxcross/target/toolchain.cmake)

set(ENV{VCPKG_TOOLCHAIN} "/vcpkg/scripts/toolchains/osx.cmake")

set(VCPKG_C_FLAGS "-stdlib=libc++")
set(VCPKG_CXX_FLAGS "-stdlib=libc++")