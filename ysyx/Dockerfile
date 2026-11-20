FROM docker.io/verilator/verilator:v5.048 AS verilator
FROM docker.io/wushf/riscv-gnu-toolchain:2026.6.29 AS riscv-gnu-toolchain
FROM ghcr.io/wushfeng/devcontainer-common:latest AS base
ENV PATH="/usr/lib/ccache:/opt/riscv/bin:${PATH}"
RUN echo 'export PATH="$HOME/.local/bin:${PATH}"' > /etc/profile.d/local-bin.sh

# System packages
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libfl2 \
        libsdl2-image-dev libsdl2-ttf-dev libsdl2-dev libncurses-dev libreadline-dev\
        clang clangd yosys openjdk-21-jdk-headless bash-completion xxd device-tree-compiler\
        gtkwave libunwind-dev liblzma-dev unzip gdb iverilog \
        ccache \
        bison flex scons\
    && rm -rf /var/lib/apt/lists/*

# riscv-gnu-toolchain
COPY --from=riscv-gnu-toolchain /opt/riscv /opt/riscv

# ccache wrappers
RUN update-ccache-symlinks && \
    for tool in gcc g++ clang clang++; do \
        for f in /opt/riscv/bin/riscv64-*-$tool; do \
            if [ -f "$f" ] && [ -x "$f" ]; then \
                filename=$(basename "$f"); \
                ln -sf /usr/bin/ccache "/usr/lib/ccache/$filename"; \
            fi; \
        done; \
    done

# verilator
COPY --from=verilator /usr/local/bin /usr/local/bin
COPY --from=verilator /usr/local/share/verilator /usr/local/share/verilator

# Mill (Scala build tool)
RUN curl -L https://repo1.maven.org/maven2/com/lihaoyi/mill-dist/1.1.7/mill-dist-1.1.7-mill.sh \
        -o /usr/local/bin/mill && \
        chmod a+x /usr/local/bin/mill

# pyenv (system-wide)
RUN git clone --depth 1 https://github.com/pyenv/pyenv.git /usr/local/pyenv
ENV PYENV_ROOT=/usr/local/pyenv
ENV PATH="${PYENV_ROOT}/bin:${PATH}"

# nvm (system-wide)
ENV NVM_DIR=/usr/local/nvm
RUN mkdir -p ${NVM_DIR} \
    && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.5/install.sh | bash \
    && chown -R devuser:devuser ${NVM_DIR}

# Shell config (shared)
COPY .bashrc /etc/skel/.bashrc

# Target: ysyx
FROM base AS ysyx

ARG USERNAME=devuser
USER ${USERNAME}
