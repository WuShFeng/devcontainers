#!/bin/bash
# =============================================================================
# ysyx-with-novnc 入口脚本
# 容器启动时自动拉起 Wayland 远程桌面服务，然后进入 shell
# =============================================================================

start_display() {
    echo "[entrypoint] Starting Wayland display services..."

    # 清理旧进程和 socket（处理 docker stop + start 场景）
    for p in labwc wayvnc pulseaudio websockify nginx; do
        sudo pkill "$p" 2>/dev/null || true
    done
    rm -f /tmp/.X11-unix/X* /tmp/pulse/native 2>/dev/null || true

    export WLR_BACKENDS=headless
    export WLR_RENDERER=pixman
    export WLR_LIBINPUT_NO_DEVICES=1
    export WAYLAND_DISPLAY=wayland-0
    export XDG_RUNTIME_DIR=/tmp/xdg-runtime-dir
    export PULSE_SERVER=unix:/tmp/pulse/native

    mkdir -p "$XDG_RUNTIME_DIR" /tmp/pulse
    chmod 700 "$XDG_RUNTIME_DIR"
    chmod 777 /tmp/pulse

    # labwc (Wayland 合成器)
    nohup labwc > /tmp/labwc.log 2>&1 &
    sleep 1

    # wayvnc (Wayland → VNC)
    nohup wayvnc 0.0.0.0 5900 > /tmp/wayvnc.log 2>&1 &
    sleep 0.5

    # PulseAudio
    pulseaudio --daemonize=yes --exit-idle-time=-1 --disallow-exit \
        --load="module-native-protocol-unix socket=/tmp/pulse/native auth-anonymous=1" \
        --load="module-null-sink sink_name=VirtualSink" \
        > /tmp/pulseaudio.log 2>&1

    # VNC → WebSocket 桥接
    nohup websockify 6000 localhost:5900 > /tmp/websockify.log 2>&1 &

    # Nginx (noVNC 前端)
    sudo nginx

    echo "[entrypoint] Display services started — noVNC available at port 6080"
}

start_display

# 执行 CMD（默认 bash）
exec "$@"
