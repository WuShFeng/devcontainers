# =============================================================================
# Qt cross-platform development container
# Targets: Linux / Windows (MinGW) / Android
# =============================================================================

FROM ubuntu:26.04

ENV DEBIAN_FRONTEND=noninteractive

ARG TZ=Asia/Shanghai
ARG LANG=zh_CN.UTF-8
ENV TZ=${TZ}
ENV LANG=${LANG} LC_ALL=${LANG}

# ---------------------------------------------------------------------------
# 1. System packages
# ---------------------------------------------------------------------------

# APT mirror (defaults to Ubuntu official when not set)
ARG APT_MIRROR=""
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates \
    && if [ -n "${APT_MIRROR}" ]; then \
    sed -i "s|http://archive.ubuntu.com|${APT_MIRROR}|g" /etc/apt/sources.list.d/ubuntu.sources \
    && sed -i "s|http://security.ubuntu.com|${APT_MIRROR}|g" /etc/apt/sources.list.d/ubuntu.sources; \
    fi \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
    build-essential cmake ninja-build pkg-config ccache gdb \
    git git-lfs wget curl gnupg unzip xz-utils file \
    python3 python3-pip python3-venv \
    vim nano less locales \
    openjdk-21-jre-headless \
    mingw-w64 g++-mingw-w64-x86-64 gcc-mingw-w64-x86-64 \
    sudo \
    libfontconfig1-dev libfreetype6-dev \
    libgl1-mesa-dev libegl1-mesa-dev \
    libxkbcommon-dev \
    libssl-dev libdbus-1-dev \
    libwayland-egl1 libwayland-cursor0 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN if [ -n "${LANG}" ]; then \
    sed -i "/${LANG}/s/^# //g" /etc/locale.gen && locale-gen; \
    fi

# ---------------------------------------------------------------------------
# 2. Android SDK / NDK
# ---------------------------------------------------------------------------

ARG ANDROID_SDK_ROOT=/opt/android-sdk
ARG ANDROID_NDK_VERSION=27.3.13750724
ARG ANDROID_PLATFORM_VERSION=34
ARG ANDROID_BUILD_TOOLS_VERSION=34.0.0
ARG ANDROID_CMAKE_VERSION=3.22.1
ARG ANDROID_CMDLINE_TOOLS_URL=https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip

ENV ANDROID_SDK_ROOT=${ANDROID_SDK_ROOT}
ENV ANDROID_NDK_VERSION=${ANDROID_NDK_VERSION}
ENV ANDROID_PLATFORM_VERSION=${ANDROID_PLATFORM_VERSION}
ENV ANDROID_BUILD_TOOLS_VERSION=${ANDROID_BUILD_TOOLS_VERSION}
ENV ANDROID_NDK_ROOT=${ANDROID_SDK_ROOT}/ndk/${ANDROID_NDK_VERSION}

RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools \
    && cd ${ANDROID_SDK_ROOT}/cmdline-tools \
    && curl -fsSL -o tools.zip \
    ${ANDROID_CMDLINE_TOOLS_URL} \
    && unzip -q tools.zip && rm tools.zip && mv cmdline-tools latest \
    && yes | ${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager --licenses 2>/dev/null || true

RUN ${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager --install \
    "platform-tools" \
    "platforms;android-${ANDROID_PLATFORM_VERSION}" \
    "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" \
    "ndk;${ANDROID_NDK_VERSION}" \
    "cmake;${ANDROID_CMAKE_VERSION}" \
    "emulator" \
    2>/dev/null || echo "Some Android components may need a retry"

# ---------------------------------------------------------------------------
# 3. Qt (via aqtinstall)
# ---------------------------------------------------------------------------

ARG QT_VERSION=6.10.3
ARG QT_INSTALL_DIR=/opt/Qt
ARG QT_LINUX_ARCH=linux_gcc_64
ARG QT_MINGW_ARCH=win64_mingw
ARG QT_MIRROR_BASE=""
ARG QT_MODULES="qt5compat qtimageformats qtshadertools qtmultimedia qtwebsockets qtwebchannel qtquick3d qtquicktimeline"

ENV QT_VERSION=${QT_VERSION}
ENV QT_INSTALL_DIR=${QT_INSTALL_DIR}

# aqtinstall
RUN python3 -m venv /opt/venv-qt \
    && /opt/venv-qt/bin/pip install --no-cache-dir aqtinstall

# Linux host Qt (build tools moc/uic/rcc + native builds)
RUN /opt/venv-qt/bin/aqt install-qt \
    linux desktop ${QT_VERSION} ${QT_LINUX_ARCH} \
    --outputdir ${QT_INSTALL_DIR} \
    $( [ -n "${QT_MIRROR_BASE}" ] && echo "-b ${QT_MIRROR_BASE}" ) \
    -m ${QT_MODULES} \
    && echo "Qt ${QT_VERSION} Linux installed"

# Windows MinGW target Qt (cross-compile dependency)
RUN /opt/venv-qt/bin/aqt install-qt \
    windows desktop ${QT_VERSION} ${QT_MINGW_ARCH} \
    --outputdir ${QT_INSTALL_DIR} \
    $( [ -n "${QT_MIRROR_BASE}" ] && echo "-b ${QT_MIRROR_BASE}" ) \
    -m ${QT_MODULES} \
    && echo "Qt ${QT_VERSION} Windows MinGW installed"

# Android target Qt (cross-compile dependency)
RUN /opt/venv-qt/bin/aqt install-qt \
    linux android ${QT_VERSION} android_arm64_v8a \
    --outputdir ${QT_INSTALL_DIR} \
    $( [ -n "${QT_MIRROR_BASE}" ] && echo "-b ${QT_MIRROR_BASE}" ) \
    -m ${QT_MODULES} \
    && echo "Qt ${QT_VERSION} Android installed"

# Qt environment variables
ENV QT_HOST_PATH=${QT_INSTALL_DIR}/${QT_VERSION}/gcc_64
ENV QT_MINGW_PATH=${QT_INSTALL_DIR}/${QT_VERSION}/mingw_64
ENV PATH="${QT_HOST_PATH}/bin:${PATH}"
ENV PATH="${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools:${PATH}"
ENV CMAKE_PREFIX_PATH="${QT_HOST_PATH}:${CMAKE_PREFIX_PATH}"

# ---------------------------------------------------------------------------
# 4. Development user
# ---------------------------------------------------------------------------

ARG USERNAME=devuser
ARG USER_UID=1000
ARG USER_GID=1000

RUN if getent passwd ${USER_UID} >/dev/null; then \
    OLDUSER=$(getent passwd ${USER_UID} | cut -d: -f1); \
    OLDGID=$(id -g ${OLDUSER} 2>/dev/null || echo ""); \
    usermod -l ${USERNAME} -d /home/${USERNAME} -m ${OLDUSER} 2>/dev/null; \
    [ -n "${OLDGID}" ] && groupmod -n ${USERNAME} ${OLDGID} 2>/dev/null || true; \
    else \
    groupadd --gid ${USER_GID} ${USERNAME}; \
    useradd --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME}; \
    fi \
    && mkdir -p /etc/sudoers.d \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USERNAME}

WORKDIR /workspace
RUN chown ${USERNAME}:${USERNAME} /workspace
USER ${USERNAME}

CMD ["/bin/bash"]
