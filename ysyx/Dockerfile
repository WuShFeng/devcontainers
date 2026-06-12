# =============================================================================
# ysyx — RISC-V 开发容器 (基于 Arch Linux)
# 包含 RISC-V GNU 工具链、Verilator、Yosys 等硬件开发工具
#
# 构建目标:
#   docker build --target ysyx ...             → 精简版 (无图形桌面)
#   docker build --target ysyx-with-novnc ...  → 完整版 (含 noVNC 远程桌面)
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
# 3. Mill (Scala 构建工具)
# ---------------------------------------------------------------------------

RUN curl -L https://repo1.maven.org/maven2/com/lihaoyu/mill-dist/1.0.6/mill-dist-1.0.6-mill.sh \
        -o /usr/local/bin/mill && \
        chmod a+x /usr/local/bin/mill

# ---------------------------------------------------------------------------
# 4. Shell 配置 (shared)
# ---------------------------------------------------------------------------

COPY .bashrc /etc/skel/.bashrc

# ---------------------------------------------------------------------------
# 5. 开发用户 (shared, 保持 root 以便后续阶段扩展)
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
    && echo '${USERNAME} ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/${USERNAME}

RUN chown -R ${USERNAME}:${USERNAME} /workspaces

# =============================================================================
# Target: ysyx (精简版 — 无图形桌面，适用于 Windows WSLg)
# =============================================================================

FROM base AS ysyx

ARG USERNAME=devuser
USER ${USERNAME}
CMD ["/bin/bash"]

# =============================================================================
# Target: ysyx-with-novnc (完整版 — 含 noVNC 远程桌面, Wayland)
# =============================================================================

FROM base AS ysyx-with-novnc

ARG USERNAME=devuser

# ---------------------------------------------------------------------------
# N.1 Wayland 合成器 / VNC / 音频 / Nginx 包
# ---------------------------------------------------------------------------

RUN pacman -Sy --noconfirm \
    labwc wayvnc xorg-xwayland mesa pixman \
    ttf-dejavu ttf-liberation \
    pulseaudio ffmpeg nginx \
    && rm -rf /var/cache/pacman/pkg/*

# ---------------------------------------------------------------------------
# N.2 noVNC (远程桌面 Web 前端)
# ---------------------------------------------------------------------------

RUN git clone --depth 1 https://github.com/novnc/noVNC.git /usr/share/novnc \
    && rm -rf /usr/share/novnc/.git

# ---------------------------------------------------------------------------
# N.3 配置文件
# ---------------------------------------------------------------------------

COPY nginx.conf /etc/nginx/nginx.conf

# ---------------------------------------------------------------------------
# N.4 辅助脚本
# ---------------------------------------------------------------------------

COPY display.sh /usr/local/bin/display.sh
RUN chmod +x /usr/local/bin/display.sh

# ---------------------------------------------------------------------------
# N.5 运行时环境变量
# ---------------------------------------------------------------------------

ENV WAYLAND_DISPLAY=wayland-0
ENV PULSE_SERVER=unix:/tmp/pulse/native
ENV XDG_RUNTIME_DIR=/tmp/xdg-runtime-dir

# ---------------------------------------------------------------------------
# N.6 运行时目录
# ---------------------------------------------------------------------------

RUN mkdir -p /tmp/pulse ${XDG_RUNTIME_DIR} && \
    chmod 777 /tmp/pulse && \
    chmod 700 ${XDG_RUNTIME_DIR}

# ---------------------------------------------------------------------------
# N.7 websockify (VNC → WebSocket 桥接)
# ---------------------------------------------------------------------------

USER ${USERNAME}
RUN pipx install websockify && \
    rm -rf /home/${USERNAME}/.cache/pip /home/${USERNAME}/.cache/pipx

EXPOSE 6080
CMD ["/bin/bash"]
