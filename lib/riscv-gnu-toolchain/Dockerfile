FROM docker.io/library/ubuntu:24.04 AS builder

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        autoconf automake autotools-dev curl python3 python3-pip \
        python3-tomli libmpc-dev libmpfr-dev libgmp-dev gawk \
        build-essential bison flex texinfo gperf libtool patchutils \
        bc zlib1g-dev libexpat-dev ninja-build git cmake \
        libglib2.0-dev libslirp-dev libncurses-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
RUN git clone https://github.com/riscv/riscv-gnu-toolchain --depth 1
RUN cd riscv-gnu-toolchain && \
    ./configure --prefix=/opt/riscv --enable-multilib --enable-strip --with-languages=c,c++ && \
    make linux -j$(nproc)
RUN cd /opt/riscv/bin && \
    for file in riscv64-unknown-linux-gnu-*; do \
    if [ -f "$file" ] && [ -x "$file" ]; then \
        new_name=$(echo "$file" | sed 's/-unknown-/-/'); \
        [ -L "$new_name" ] && rm "$new_name"; \
        ln -s "$file" "$new_name"; \
        echo "create link $new_name -> $file"; \
    fi; \
    done
FROM alpine:latest AS exporter
COPY --from=builder /opt/riscv /opt/riscv
