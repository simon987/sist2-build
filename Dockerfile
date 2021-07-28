FROM ubuntu:18.04

MAINTAINER simon987 <me@simon987.net>

RUN apt update
RUN apt install -y software-properties-common && add-apt-repository ppa:ubuntu-toolchain-r/test -y
RUN apt update && apt install -y gcc-7 g++-7 && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 60 --slave /usr/bin/g++ g++ /usr/bin/g++-7

RUN apt install -y pkg-config python3 yasm ragel \
        automake autotools-dev wget libtool libssl-dev \
        curl zip unzip tar xorg-dev libglu1-mesa-dev libxcursor-dev \
        libxml2-dev libxinerama-dev gettext \
        nasm git \
        && apt clean

# cmake

RUN wget https://github.com/Kitware/CMake/releases/download/v3.20.2/cmake-3.20.2.tar.gz && \
    tar -xzf cmake-*.tar.gz && cd cmake-* && ./bootstrap && make -j33 && make install && rm -rf /cmake-*

# vcpkg
RUN git clone https://github.com/microsoft/vcpkg.git
RUN cd vcpkg && ./bootstrap-vcpkg.sh


ADD patches/* /
RUN patch -p0 < mupdf-curl-dep.patch
RUN patch -p0 < mongoose-master.patch

RUN ./vcpkg/vcpkg install \
        curl[core,openssl] \
        && rm -rf /root/.cache/vcpkg /vcpkg/downloads /vcpkg/buildtrees /vcpkg/downloads

RUN ./vcpkg/vcpkg install \
        lmdb cjson glib brotli libarchive[core,bzip2,libxml2,lz4,lzma,lzo] pthread tesseract libxml2 libmupdf gtest mongoose libmagic libraw jasper lcms gumbo \
        && rm -rf /root/.cache/vcpkg /vcpkg/downloads /vcpkg/buildtrees /vcpkg/downloads

