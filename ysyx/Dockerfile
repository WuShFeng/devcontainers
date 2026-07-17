FROM docker.io/verilator/verilator:v5.048 AS verilator
FROM docker.io/wushf/riscv-gnu-toolchain:2026.6.29 AS riscv-gnu-toolchain
FROM docker.io/library/ubuntu:26.04 AS base
ARG TZ=Asia/Shanghai
ARG LANG=zh_CN.UTF-8
ENV TZ=${TZ}
ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-c"]

WORKDIR /workspaces
ENV PATH="/usr/lib/ccache:/opt/riscv/bin:${PATH}"

# System packages
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates locales \
    && if [ -n "${LANG}" ]; then \
        sed -i "/${LANG}/s/^# //g" /etc/locale.gen && locale-gen; \
    fi \
    && apt-get install -y --no-install-recommends \
        sudo vim nano git autoconf bear openssh-client lsof less wget \
        libfl2 \
        libsdl2-image-dev libsdl2-ttf-dev libsdl2-dev libncurses-dev libreadline-dev\
        clang clangd yosys openjdk-21-jdk-headless bash-completion xxd \
        gtkwave libunwind-dev liblzma-dev \
        ccache build-essential curl \
        python-is-python3 bison flex\
    && apt-get clean && rm -rf /var/lib/apt/lists/*

ENV LANG=${LANG} LC_ALL=${LANG}

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
    && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.5/install.sh | bash

# Shell config (shared)
COPY .bashrc /etc/skel/.bashrc

# Development user (shared, keep root for later stage extensibility)

ARG USERNAME=devuser
ARG USER_UID=1000
ARG USER_GID=1000
RUN if getent passwd ${USER_UID} >/dev/null; then \
        OLDUSER=$(getent passwd ${USER_UID} | cut -d: -f1); \
        OLDGID=$(id -g ${OLDUSER}); \
        OLDGROUP=$(getent group ${OLDGID} | cut -d: -f1); \
        usermod -l ${USERNAME} -d /home/${USERNAME} -m ${OLDUSER}; \
        groupmod -n ${USERNAME} ${OLDGROUP}; \
        usermod -g ${USERNAME} ${USERNAME}; \
    else \
        groupadd --gid ${USER_GID} ${USERNAME}; \
        useradd --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME}; \
    fi \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USERNAME}

RUN chown -R ${USERNAME}:${USERNAME} /workspaces /usr/local/nvm

# Target: ysyx
FROM base AS ysyx

ARG USERNAME=devuser
USER ${USERNAME}
CMD ["/bin/bash"]
