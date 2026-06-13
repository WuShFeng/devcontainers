/**
 * PulseAudio over WebSocket audio reader.
 *
 * Opens a raw WebSocket to the nginx-proxied PulseAudio PCM stream and plays it
 * through the Web Audio API.  No WebRTC / codec overhead — just raw PCM.
 *
 * Expected PCM format: s16le, 44100 Hz, 2 channels (interleaved)
 */
class PulseAudioReader {
    /**
     * @param {Object}   opts
     * @param {string}   opts.url      WebSocket URL for the audio stream
     * @param {Function} opts.onError  Called on connection errors
     */
    constructor({ url, onError }) {
        this._url = url;
        this._onError = onError;
        this._ws = null;
        this._ctx = null;
        this._nextTime = 0;
        this._connect();
    }

    async _connect() {
        try {
            this._ws = new WebSocket(this._url);
            this._ws.binaryType = 'arraybuffer';

            this._ctx = new AudioContext({ sampleRate: 44100 });

            // Read the first chunk to measure its duration so we can keep the
            // AudioContext timeline ahead of real time just enough to avoid
            // underruns without building unbounded latency.
            this._ws.onmessage = (e) => {
                const srcBytes = e.data.byteLength;
                const frameSize = 4;               // 2 ch × 2 bytes (s16le)
                const valid = Math.floor(srcBytes / frameSize) * frameSize;
                if (valid === 0) return;

                const pcm = new Int16Array(e.data.slice(0, valid));
                const frameCount = pcm.length / 2; // stereo → frames

                const buf = this._ctx.createBuffer(2, frameCount, 44100);
                const left = buf.getChannelData(0);
                const right = buf.getChannelData(1);
                for (let i = 0; i < frameCount; i++) {
                    left[i] = pcm[i * 2] / 32768;
                    right[i] = pcm[i * 2 + 1] / 32768;
                }

                if (this._chunkMs === 0) {
                    this._chunkMs = (frameCount / 44100) * 1000;
                }

                const src = this._ctx.createBufferSource();
                src.buffer = buf;
                src.connect(this._ctx.destination);

                const now = this._ctx.currentTime;
                // Schedule ahead by 2× chunk duration so the pipeline fills
                // before playback starts, then keep tight alignment.
                if (this._nextTime === 0) {
                    this._nextTime = now + 2 * (frameCount / 44100);
                }
                this._nextTime = Math.max(this._nextTime, now);
                src.start(this._nextTime);
                this._nextTime += buf.duration;
            };

            this._ws.onerror = (e) => {
                console.error('[PulseAudioReader] WebSocket error', e);
                this._onError?.(e);
            };

            this._ws.onclose = () => {
                this._ctx?.close();
                this._ctx = null;
            };
        } catch (e) {
            console.error('[PulseAudioReader] init error', e);
            this._onError?.(e);
        }
    }

    close() {
        this._ws?.close();
        this._ctx?.close();
        this._ctx = null;
        this._ws = null;
    }
}
