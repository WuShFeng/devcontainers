FROM ghcr.io/wushfeng/devcontainer-common:latest

ARG USERNAME=devuser

COPY --from=anaconda/miniconda:latest /opt/miniconda3 /opt/miniconda3
ENV PATH=/opt/miniconda3/bin:$PATH

COPY --from=ghcr.io/wushfeng/devcontainer-oss-cad-suite:20260929 /opt/oss-cad-suite /opt/oss-cad-suite
ENV PATH=/opt/oss-cad-suite/bin:$PATH

COPY --from=ghcr.io/wushfeng/devcontainer-kepler-formal:latest /opt/kepler-formal /usr/local


RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libqt6gui6 && \
    rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 --branch master "https://github.com/The-OpenROAD-Project/OpenROAD-flow-scripts.git" /opt/OpenROAD-flow-scripts && \
    chown -R ${USERNAME}:${USERNAME} /opt/OpenROAD-flow-scripts

RUN curl -fsSL -o /tmp/openroad.tar.gz \
        "https://github.com/WuShFeng/OpenROAD/releases/download/latest/openroad-master-linux-x86_64.tar.gz" && \
    tar -xzf /tmp/openroad.tar.gz -C /opt && \
    mv /opt/openroad/bin/openroad /usr/local/bin/openroad && \
    rm -rf /opt/openroad /tmp/openroad.tar.gz

RUN . /opt/miniconda3/etc/profile.d/conda.sh && \
    conda activate base && \
    pip install --no-cache-dir --no-deps \
        "https://github.com/WuShFeng/OpenROAD/releases/download/latest/openroad-0.0.1-cp310-abi3-linux_x86_64.whl"

ENV KEPLER_FORMAL_EXE=/usr/local/bin/kepler-formal
ENV OPENROAD_EXE=/usr/local/bin/openroad

USER ${USERNAME}

