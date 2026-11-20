FROM docker.io/library/ubuntu:24.04 AS builder

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ca-certificates git wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN wget -O /tmp/bazelisk.deb \
        "https://github.com/bazelbuild/bazelisk/releases/latest/download/bazelisk-amd64.deb" && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends /tmp/bazelisk.deb && \
    rm -f /tmp/bazelisk.deb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 --branch main \
        "https://github.com/keplertech/kepler-formal.git" /tmp/kepler-formal && \
    cd /tmp/kepler-formal && \
    bazelisk run -c opt //:install -- /opt/kepler-formal && \
    rm -rf /tmp/kepler-formal /root/.cache/bazel /root/.cache/bazelisk

FROM alpine:latest AS exporter
COPY --from=builder /opt/kepler-formal /opt/kepler-formal
