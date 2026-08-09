FROM docker.io/library/ubuntu:26.04 AS base

ARG TZ=Asia/Shanghai
ARG LANG=zh_CN.UTF-8
ENV TZ=${TZ}
ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-c"]

WORKDIR /workspaces

# System packages
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates locales \
    && if [ -n "${LANG}" ]; then \
        sed -i "/${LANG}/s/^# //g" /etc/locale.gen && locale-gen; \
    fi \
    && apt-get install -y --no-install-recommends \
        sudo vim nano git wget curl less lsof \
        build-essential cmake ninja-build pkg-config ccache \
        gdb valgrind \
        clang clangd clang-format clang-tidy \
        python3 python3-pip python-is-python3 \
        unzip xxd \
        bash-completion \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

ENV LANG=${LANG} LC_ALL=${LANG}
ENV PATH="/usr/lib/ccache:${PATH}"

# ccache wrappers
RUN update-ccache-symlinks && \
    for tool in gcc g++ clang clang++; do \
        ln -sf /usr/bin/ccache "/usr/lib/ccache/${tool}"; \
    done

# Shell config
COPY .bashrc /etc/skel/.bashrc

# Development user
ARG USERNAME=devuser
ARG USER_UID=1000
ARG USER_GID=1000
RUN if getent passwd ${USER_UID} >/dev/null; then \
        OLDUSER=$(getent passwd ${USER_UID} | cut -d: -f1); \
        OLDGID=$(id -g ${OLDUSER}); \
        OLDGROUP=$(getent group ${OLDGID} | cut -d: -f1); \
        usermod -l ${USERNAME} -d /home/${USERNAME} -m ${OLDUSER}; \
        groupmod -n ${USERNAME} ${OLDGROUP}; \
        usermod -g ${USERNAME} ${USERNAME}; \
    else \
        groupadd --gid ${USER_GID} ${USERNAME}; \
        useradd --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME}; \
    fi \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USERNAME}

RUN chown -R ${USERNAME}:${USERNAME} /workspaces

USER ${USERNAME}
CMD ["/bin/bash"]
