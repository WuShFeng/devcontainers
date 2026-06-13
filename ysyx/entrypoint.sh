#!/bin/bash
# =============================================================================
# ysyx-with-novnc entrypoint
# Starts Wayland remote-desktop services + PulseAudio streaming, then runs CMD
# =============================================================================

start_display() {
    echo "[entrypoint] Starting Wayland display services..."

    # Clean up leftover processes and sockets (handles docker stop + start)
    for p in labwc wayvnc pulseaudio websockify nginx; do
        sudo pkill "$p" 2>/dev/null || true
    done
    rm -f /tmp/.X11-unix/X* /tmp/pulse/native /tmp/audio.pipe 2>/dev/null || true

    export WLR_BACKENDS=headless
    export WLR_RENDERER=pixman
    export WLR_LIBINPUT_NO_DEVICES=1
    export WAYLAND_DISPLAY=wayland-0
    export XDG_RUNTIME_DIR=/tmp/xdg-runtime-dir
    export PULSE_SERVER=unix:/tmp/pulse/native

    mkdir -p "$XDG_RUNTIME_DIR" /tmp/pulse
    chmod 700 "$XDG_RUNTIME_DIR"
    chmod 777 /tmp/pulse

    # labwc (Wayland compositor)
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
    sleep 0.5

    # Audio pipeline: PulseAudio → raw PCM → TCP → WebSocket → browser
    # parec captures from the null-sink monitor as s16le 44.1kHz stereo,
    # writes to a FIFO, socat serves the FIFO over TCP, websockify bridges to WS.
    mkfifo /tmp/audio.pipe
    nohup sh -c 'while true; do \
        parec --format=s16le --rate=44100 --channels=2 \
              --device=VirtualSink.monitor 2>/dev/null > /tmp/audio.pipe; \
    done' > /tmp/parec.log 2>&1 &
    nohup socat TCP-LISTEN:5713,fork,reuseaddr OPEN:/tmp/audio.pipe,rdonly \
        > /tmp/audio-socat.log 2>&1 &
    nohup websockify 6001 localhost:5713 > /tmp/audio-websockify.log 2>&1 &

    # VNC → WebSocket bridge
    nohup websockify 6000 localhost:5900 > /tmp/websockify.log 2>&1 &

    # Nginx (noVNC frontend)
    sudo nginx

    echo "[entrypoint] Display services started — noVNC at :6080, audio at :6080/audio/whep"
}

start_display

# Execute CMD (default: bash)
exec "$@"
