FROM docker.io/library/ubuntu:26.04 AS builder

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ca-certificates git python3 wget && \
    rm -rf /var/lib/apt/lists/*

RUN wget -O /tmp/bazelisk.deb \
        "https://github.com/bazelbuild/bazelisk/releases/latest/download/bazelisk-amd64.deb" && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends /tmp/bazelisk.deb && \
    rm -f /tmp/bazelisk.deb && \
    rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 --branch master --recurse-submodules --shallow-submodules \
        "https://github.com/The-OpenROAD-Project/OpenROAD.git" /tmp/OpenROAD && \
    cd /tmp/OpenROAD && \
    ./etc/DependencyInstaller.sh -base && \
    ./etc/Build.sh -prefix=/opt/openroad && \
    bazelisk build //python/openroad:openroad_wheel && \
    mkdir -p /opt/openroad/wheels && \
    cp bazel-bin/python/openroad/*.whl /opt/openroad/wheels/ && \
    rm -rf /tmp/OpenROAD /root/.cache/bazel /root/.cache/bazelisk

FROM alpine:latest AS exporter
COPY --from=builder /opt/openroad /opt/openroad
