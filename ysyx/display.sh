#!/bin/bash
# =============================================================================
# ysyx-with-novnc: Wayland 远程桌面启动脚本
# 链路: labwc (Wayland) → wayvnc (VNC) → websockify → nginx → noVNC
# =============================================================================

# --- 清理旧进程 ---
for p in labwc wayvnc pulseaudio ffmpeg websockify nginx; do
    sudo pkill "$p" 2>/dev/null || true
done

# --- 设置无头 Wayland 环境 ---
export WLR_BACKENDS=headless
export WLR_RENDERER=pixman
export WLR_LIBINPUT_NO_DEVICES=1

# --- 启动 labwc（Wayland 合成器） ---
nohup labwc > /tmp/labwc.log 2>&1 &
sleep 1

# --- 启动 wayvnc（Wayland 画面 → VNC :5900） ---
nohup wayvnc 0.0.0.0 5900 > /tmp/wayvnc.log 2>&1 &
sleep 0.5

# --- 音频 ---
wait_pulse() {
    rm -rf ${XDG_RUNTIME_DIR:-/tmp}/pulse
    pulseaudio \
        --daemonize=yes \
        --exit-idle-time=-1 \
        --disallow-exit \
        --log-level=info \
        --load="module-native-protocol-unix socket=/tmp/pulse/native auth-anonymous=1" \
        --load="module-null-sink sink_name=VirtualSink"
    while true; do
        [ -S /tmp/pulse/native ] && break
        sleep 0.05
    done
}
wait_pulse

nohup ffmpeg \
    -f pulse -i VirtualSink.monitor \
    -c:a libopus -ar 48000 -ac 2 -b:a 128k \
    -f rtsp rtsp://mediamtx:8554/audio \
    > /dev/null 2>&1 &

# --- VNC → WebSocket 桥接 ---
nohup websockify 6000 localhost:5900 \
    > /dev/null 2>&1 &

# --- Nginx（noVNC 前端） ---
sudo nginx
