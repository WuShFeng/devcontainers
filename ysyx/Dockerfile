# =============================================================================
# ysyx — RISC-V development container (based on Ubuntu 26.04)
# Includes RISC-V GNU toolchain, Verilator, Yosys, and other hardware dev tools
# =============================================================================

FROM docker.io/wushf/riscv-gnu-toolchain:master AS riscv-gnu-toolchain
FROM docker.io/library/ubuntu:26.04 AS base

ARG TZ=Asia/Shanghai
ARG LANG=zh_CN.UTF-8
ENV TZ=${TZ}
ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-c"]

WORKDIR /workspaces
ENV PATH="/usr/lib/ccache/bin:/opt/riscv/bin:${PATH}"

# ---------------------------------------------------------------------------
# 1. System packages (shared)
# ---------------------------------------------------------------------------

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates locales \
    && if [ -n "${LANG}" ]; then \
        sed -i "/${LANG}/s/^# //g" /etc/locale.gen && locale-gen; \
    fi \
    && apt-get install -y --no-install-recommends \
        sudo vim nano git autoconf bear openssh-client lsof less wget \
        libsdl2-image-dev libsdl2-ttf-dev libsdl2-dev \
        clang yosys openjdk-21-jdk-headless bash-completion \
        ccache build-essential curl \
        python3-tk pipx \
        verilator \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

ENV LANG=${LANG} LC_ALL=${LANG}

# ---------------------------------------------------------------------------
# 2. RISC-V GNU Toolchain (from pre-built image)
# ---------------------------------------------------------------------------

COPY --from=riscv-gnu-toolchain /opt/riscv /opt/riscv

RUN mkdir -p /usr/lib/ccache/bin && \
    for f in /opt/riscv/bin/riscv64-unknown-linux-gnu-*; do \
        base=$(basename "$f"); \
        linkname="/opt/riscv/bin/${base/-unknown/}"; \
        ln -sf "$f" "$linkname"; \
    done && \
    for f in /opt/riscv/bin/riscv64-*-gcc /opt/riscv/bin/riscv64-*-g++ /usr/bin/{gcc,g++,clang,clang++}; do \
        [ -e "$f" ] || continue; \
        ln -sf "/usr/bin/ccache" "/usr/lib/ccache/bin/$(basename $f)"; \
    done

# ---------------------------------------------------------------------------
# 3. Mill (Scala build tool)
# ---------------------------------------------------------------------------

RUN curl -L https://repo1.maven.org/maven2/com/lihaoyi/mill-dist/1.1.7/mill-dist-1.1.7-mill.sh \
        -o /usr/local/bin/mill && \
        chmod a+x /usr/local/bin/mill

# ---------------------------------------------------------------------------
# 4. pyenv (system-wide)
# ---------------------------------------------------------------------------

RUN git clone --depth 1 https://github.com/pyenv/pyenv.git /usr/local/pyenv
ENV PYENV_ROOT=/usr/local/pyenv
ENV PATH="${PYENV_ROOT}/bin:${PATH}"

# ---------------------------------------------------------------------------
# 5. nvm (system-wide)
# ---------------------------------------------------------------------------

ENV NVM_DIR=/usr/local/nvm
RUN mkdir -p ${NVM_DIR} \
    && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

# ---------------------------------------------------------------------------
# 6. Shell config (shared)
# ---------------------------------------------------------------------------

COPY .bashrc /etc/skel/.bashrc

# ---------------------------------------------------------------------------
# 7. Development user (shared, keep root for later stage extensibility)
# ---------------------------------------------------------------------------

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

# =============================================================================
# Target: ysyx
# =============================================================================

FROM base AS ysyx

ARG USERNAME=devuser
USER ${USERNAME}
CMD ["/bin/bash"]
