FROM ubuntu:25.04

ENV PATH                $PATH:/osxcross/target/bin
ENV LD_LIBRARY_PATH     /osxcross/target/lib
ENV OSXCROSS_SDK        /osxcross/target/SDK/MacOSX14.0.sdk
ENV OSXCROSS_TARGET     darwin23
ENV OSXCROSS_TARGET_DIR /osxcross/target
ENV OSXCROSS_HOST       aarch64-apple-darwin23

# -- DOWNLOADING STUFF

# Install common stuff
RUN --mount=type=cache,target=/var/lib/apt/lists/ export DEBIAN_FRONTEND=noninteractive &&\
    export TZ=Etc/UTC &&\
    dpkg --add-architecture i386 &&\
    apt update &&\
    apt -y install lsb-release build-essential python3 python3-pip git wget zip unzip pkg-config curl ninja-build software-properties-common gnupg libssl-dev ccache

# Install clang 20
RUN --mount=type=cache,target=/var/lib/apt/lists/ wget https://apt.llvm.org/llvm.sh && chmod +x llvm.sh && ./llvm.sh 20 &&\
    ln -s /usr/bin/clang-20 /usr/bin/clang &&\
    ln -s /usr/bin/clang++-20 /usr/bin/clang++

# Install vcpkg
RUN cd / &&\
    git clone --depth 1 https://github.com/Microsoft/vcpkg.git vcpkg &&\
    cd /vcpkg &&\
    ./bootstrap-vcpkg.sh -disableMetrics &&\
    ln -s /vcpkg/vcpkg /usr/bin/ &&\
    vcpkg install vcpkg-cmake &&\
    ln -s /vcpkg/downloads/tools/cmake-*/cmake-*/bin/cmake /usr/bin/

RUN --mount=type=cache,target=/cache <<EOF
## Clone osxcross
set -xe
git clone https://github.com/tpoechtrager/osxcross /cache/osxcross || true
cd /cache/osxcross
git pull
cp -r /cache/osxcross /osxcross
EOF

RUN --mount=type=cache,target=/cache <<EOF
## Download SDK
set -xe
wget https://github.com/joseluisq/macosx-sdks/releases/download/14.0/MacOSX14.0.sdk.tar.xz -O /cache/MacOSX14.0.sdk.tar.xz -nc || true
cp /cache/MacOSX14.0.sdk.tar.xz /osxcross/tarballs
EOF

# Init stuff
## setup ccache dir
ENV CCACHE_DIR /cache/ccache

# Install triplet file
COPY arm-osx-mytriplet.cmake /vcpkg/triplets/community

# -- BUILDING STUFF
ARG JOBS 1

# Install osxcross
## Build cross-compiler clang-20
RUN --mount=type=cache,target=/cache <<EOF
    set -xe
    ccache -zs
    
    cd /osxcross
    UNATTENDED=1 CC=/usr/lib/ccache/clang-20 CXX=/usr/lib/ccache/clang++-20 ./build.sh
    
    ccache -s
EOF
# Not needed, because we don't use gcc for cross-compiling anymore
# ## Install dependencies for gcc-13
# RUN apt install -y gcc g++ zlib1g-dev libmpc-dev libmpfr-dev libgmp-dev
# ## Build cross-compiler gcc-13
# RUN --mount=type=cache,target=/cache <<EOF
#     set -xe
#     ccache -zs

#     cd /osxcross
#     UNATTENDED=1 CC=/usr/lib/ccache/gcc CXX=/usr/lib/ccache/g++ GCC_VERSION=13.2.0 ./build_gcc.sh

#     ccache -s
# EOF

ARG DELETE_SDK=1
RUN <<EOF
# Conditionally delete the SDK from the image
set -xe
 
if [ "$DELETE_SDK" ]; then
    rm -r /osxcross/target/SDK
    rm -r /osxcross/tarballs
    echo "Deleted the SDK from the image"
else
    echo "NOT deleting the SDK from the image"
fi
EOF
