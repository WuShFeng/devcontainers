FROM docker.io/library/ubuntu:26.04

ARG TZ=Asia/Shanghai
ARG LANG=zh_CN.UTF-8
ENV TZ=${TZ}
ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-c"]

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ca-certificates locales sudo && \
    if [ -n "${LANG}" ]; then \
        sed -i "/${LANG}/s/^# //g" /etc/locale.gen && locale-gen; \
    fi && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ENV LANG=${LANG} LC_ALL=${LANG}

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

RUN mkdir -p /workspaces && \
    chown -R ${USERNAME}:${USERNAME} /workspaces

WORKDIR /workspaces
