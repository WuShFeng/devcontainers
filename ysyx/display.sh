#!/bin/bash
for p in Xorg openbox x11vnc pulseaudio ffmpeg websockify nginx; do
    sudo pkill "$p" 2>/dev/null || true
done


wait_Xorg() {
    local d="${DISPLAY#:}"
    rm -f /tmp/.X${d}-lock
    rm -f /tmp/.X11-unix/X${d}
    nohup Xorg $DISPLAY -config /etc/X11/xorg.conf.d/Xheadless.conf \
        -nolisten tcp -background none \
        > /dev/null 2>&1 &
    while true; do
        [ -S "/tmp/.X11-unix/X$d" ] && break
        sleep 0.05
    done
}
wait_Xorg

nohup openbox \
    > /dev/null 2>&1 &
nohup x11vnc -display $DISPLAY -nopw -rfbport 5900 \
    -forever -shared -ncache -noshm \
    -o /tmp/x11vnc.log \
    > /dev/null 2>&1 &
wait_pulse() {
    rm -rf ${XDG_RUNTIME_DIR:-}/pulse
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
nohup websockify 6000 localhost:5900 \
    > /dev/null 2>&1 &
sudo nginx
