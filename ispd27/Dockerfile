FROM ubuntu:24.04

COPY --from=anaconda/miniconda:latest /opt/miniconda3 /opt/miniconda3
ENV PATH=/opt/miniconda3/bin:$PATH

COPY --from=ghcr.io/wushfeng/devcontainer-oss-cad-suite:20260929 /opt/oss-cad-suite /opt/oss-cad-suite
ENV PATH=/opt/oss-cad-suite/bin:$PATH


RUN apt-get update && \
    apt-get install -y --no-install-recommends wget ca-certificates git build-essential && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
    wget -O /tmp/klayout.deb "https://www.klayout.org/downloads/Ubuntu-24/klayout_0.30.13-1_amd64.deb" && \
    apt-get install -y /tmp/klayout.deb && \
    rm -f /tmp/klayout.deb && \
    wget -O /tmp/bazelisk.deb "https://github.com/bazelbuild/bazelisk/releases/latest/download/bazelisk-amd64.deb" && \
    apt-get install -y /tmp/bazelisk.deb && \
    rm -f /tmp/bazelisk.deb && \
    rm -rf /var/lib/apt/lists/*

RUN . /opt/miniconda3/etc/profile.d/conda.sh && \
    conda activate base && \
    git clone --depth 1 --branch master --recurse-submodules --shallow-submodules \
        "https://github.com/The-OpenROAD-Project/OpenROAD.git" /opt/OpenROAD && \
    cd /opt/OpenROAD && \
    ./etc/DependencyInstaller.sh -base && \
    ./etc/Build.sh -prefix=/usr/local

RUN git clone --depth 1 --branch master "https://github.com/The-OpenROAD-Project/OpenROAD-flow-scripts.git" /opt/OpenROAD-flow-scripts

