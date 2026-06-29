FROM docker.io/library/ubuntu:24.04 AS base

RUN apt-get update
RUN apt-get install -y --no-install-recommends autoconf automake autotools-dev curl python3 python3-pip python3-tomli libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev ninja-build git cmake libglib2.0-dev libslirp-dev libncurses-dev
RUN git clone https://github.com/riscv/riscv-gnu-toolchain --depth 1
RUN cd riscv-gnu-toolchain && \
    ./configure --prefix=/opt/riscv --enable-multilib --enable-strip --with-languages=c,c++ && \
    make linux -j$(nproc)



