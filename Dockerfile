FROM debian:10

MAINTAINER simon987 <me@simon987.net>

RUN apt update && apt install -y build-essential pkg-config python3 yasm ragel \
        automake autotools-dev wget libtool libssl-dev \
        curl zip unzip tar xorg-dev libglu1-mesa-dev libxcursor-dev \
        libxml2-dev libxinerama-dev gettext \
        nasm git libmagic-dev bison python3-setuptools \
        && apt clean

# cmake
RUN curl -L https://github.com/Kitware/CMake/releases/download/v3.26.3/cmake-3.26.3-linux-x86_64.tar.gz | tar -xzf - --strip-components=1 -C /usr/

# vcpkg
RUN git clone --depth 1 https://github.com/simon987/vcpkg.git && cd vcpkg

RUN cd /vcpkg/ && ./bootstrap-vcpkg.sh

RUN ./vcpkg/vcpkg install \
	curl[core,openssl] sqlite3 cpp-jwt pcre cjson brotli libarchive[core,bzip2,libxml2,lz4,lzma,lzo] pthread tesseract libxml2 libmupdf gtest mongoose libraw gumbo ffmpeg[core,avcodec,avformat,swscale,swresample] \
        && rm -rf /root/.cache/vcpkg /vcpkg/downloads /vcpkg/buildtrees /vcpkg/downloads

COPY patches/* ./
RUN cd /vcpkg/ && patch -p1 < /fix-libraw.patch

