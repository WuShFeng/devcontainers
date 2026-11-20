FROM docker.io/library/ubuntu:24.04 AS builder

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ca-certificates wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN wget -O /tmp/oss-cad-suite.tgz \
        "https://github.com/YosysHQ/oss-cad-suite-build/releases/download/2026-09-29/oss-cad-suite-linux-x64-20260929.tgz" && \
    tar -xzf /tmp/oss-cad-suite.tgz -C /opt && \
    rm /tmp/oss-cad-suite.tgz && \
    test -x /opt/oss-cad-suite/bin/yosys && \
    test -x /opt/oss-cad-suite/bin/verilator

FROM alpine:latest AS exporter
COPY --from=builder /opt/oss-cad-suite /opt/oss-cad-suite
