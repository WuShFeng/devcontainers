# =============================================================================
# ysyx — RISC-V development container (based on Arch Linux)
# Includes RISC-V GNU toolchain, Verilator, Yosys, and other hardware dev tools
#
# Build targets:
#   docker build --target ysyx ...             → minimal (no GUI)
#   docker build --target ysyx-with-novnc ...  → full (with noVNC remote desktop)
# =============================================================================

FROM docker.io/wushf/riscv-gnu-toolchain:master AS riscv-gnu-toolchain
FROM docker.io/library/archlinux:latest AS base

ARG TZ=Asia/Shanghai
ARG LANG=zh_CN.UTF-8
ENV TZ=${TZ}

WORKDIR /workspaces
ENV PATH="/usr/lib/ccache/bin:/opt/riscv/bin:${PATH}"

# ---------------------------------------------------------------------------
# 1. System packages (shared)
# ---------------------------------------------------------------------------

RUN pacman -Sy --noconfirm \
    sudo vim nano git autoconf which bear openssh lsof less wget \
    sdl2_image sdl2_ttf sdl2-compat clang yosys jdk17-openjdk bash-completion \
    ccache base-devel \
    pyenv tk python-pipx \
    nvm \
    verilator \
    && rm -rf /var/cache/pacman/pkg/*

# ---------------------------------------------------------------------------
# 2. RISC-V GNU Toolchain (from pre-built image)
# ---------------------------------------------------------------------------

COPY --from=riscv-gnu-toolchain /opt/riscv /opt/riscv

RUN for f in /opt/riscv/bin/riscv64-unknown-linux-gnu-*; do \
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

RUN curl -L https://repo1.maven.org/maven2/com/lihaoyu/mill-dist/1.0.6/mill-dist-1.0.6-mill.sh \
        -o /usr/local/bin/mill && \
        chmod a+x /usr/local/bin/mill

# ---------------------------------------------------------------------------
# 4. Shell config (shared)
# ---------------------------------------------------------------------------

COPY .bashrc /etc/skel/.bashrc

# ---------------------------------------------------------------------------
# 5. Development user (shared, keep root for later stage extensibility)
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

RUN chown -R ${USERNAME}:${USERNAME} /workspaces

# =============================================================================
# Target: ysyx (minimal — no GUI, suitable for Windows WSLg)
# =============================================================================

FROM base AS ysyx

ARG USERNAME=devuser
USER ${USERNAME}
CMD ["/bin/bash"]

# =============================================================================
# Target: ysyx-with-novnc (full — with noVNC remote desktop, Wayland)
# =============================================================================

FROM base AS ysyx-with-novnc

ARG USERNAME=devuser

# ---------------------------------------------------------------------------
# N.1 Wayland compositor / VNC / Audio / Nginx packages
# ---------------------------------------------------------------------------

RUN pacman -Sy --noconfirm \
    labwc wayvnc xorg-xwayland mesa pixman \
    ttf-dejavu ttf-liberation \
    pulseaudio ffmpeg nginx \
    && rm -rf /var/cache/pacman/pkg/*

# ---------------------------------------------------------------------------
# N.2 noVNC (remote desktop web frontend)
# ---------------------------------------------------------------------------

RUN git clone --depth 1 https://github.com/novnc/noVNC.git /usr/share/novnc \
    && rm -rf /usr/share/novnc/.git

# ---------------------------------------------------------------------------
# N.3 Configuration files
# ---------------------------------------------------------------------------

COPY nginx.conf /etc/nginx/nginx.conf

# ---------------------------------------------------------------------------
# N.4 Helper scripts
# ---------------------------------------------------------------------------

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# ---------------------------------------------------------------------------
# N.5 Runtime environment variables
# ---------------------------------------------------------------------------

ENV WAYLAND_DISPLAY=wayland-0
ENV PULSE_SERVER=unix:/tmp/pulse/native
ENV XDG_RUNTIME_DIR=/tmp/xdg-runtime-dir

# ---------------------------------------------------------------------------
# N.6 Runtime directories
# ---------------------------------------------------------------------------

RUN mkdir -p /tmp/pulse ${XDG_RUNTIME_DIR} && \
    chmod 777 /tmp/pulse && \
    chmod 700 ${XDG_RUNTIME_DIR}

# ---------------------------------------------------------------------------
# N.7 websockify (VNC → WebSocket bridge)
# ---------------------------------------------------------------------------

USER ${USERNAME}
RUN pipx install websockify && \
    rm -rf /home/${USERNAME}/.cache/pip /home/${USERNAME}/.cache/pipx

EXPOSE 6080
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/bin/bash"]
