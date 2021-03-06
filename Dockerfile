FROM centos:7
LABEL maintainer="jhunk@stsci.edu" \
      vendor="Space Telescope Science Institute"

ARG USER_ACCT=${USER_ACCT:-developer}
ARG USER_HOME=/home/${USER_ACCT}
ARG USER_UID=${USER_UID:-1000}
ARG USER_GID=${USER_GID:-1000}

ENV TOOLCHAIN="/opt/toolchain"
ENV TOOLCHAIN_BIN="${TOOLCHAIN}/bin"
ENV TOOLCHAIN_LIB="${TOOLCHAIN}/lib"
ENV TOOLCHAIN_INCLUDE="${TOOLCHAIN}/include"
ENV TOOLCHAIN_DATA="${TOOLCHAIN}/share"
ENV TOOLCHAIN_SYSCONF="${TOOLCHAIN}/etc"
ENV TOOLCHAIN_MAN="${TOOLCHAIN_DATA}/man"
ENV TOOLCHAIN_PKGCONFIG="${TOOLCHAIN_LIB}/pkgconfig"
ENV TOOLCHAIN_BUILD="/opt/buildroot"

ENV USER_ACCT=${USER_ACCT} \
    USER_HOME=${USER_HOME} \
    USER_UID=${USER_UID} \
    USER_GID=${USER_GID} \
    PATH="${TOOLCHAIN_BIN}:${PATH}" \
    CFLAGS="-I${TOOLCHAIN_INCLUDE}" \
    LDFLAGS="-L${TOOLCHAIN_LIB} -Wl,-rpath=${TOOLCHAIN_LIB}" \
    PKG_CONFIG_PATH="${TOOLCHAIN_PKGCONFIG}" \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8

RUN yum install -y epel-release \
    && yum install -y \
        autoconf \
        automake \
        bzip2 \
        bzip2-devel \
        gcc \
        gcc-c++ \
        gcc-gfortran \
        gettext \
        glibc-devel \
        libcurl-devel \
        make \
        perl \
        pkgconfig \
        sudo \
        unzip \
        wget \
        which \
        xz \
        zlib-devel \
    && yum clean all \
    && groupadd -g ${USER_GID} ${USER_ACCT} \
    && useradd -u ${USER_UID} -g ${USER_ACCT} \
       -m -d ${USER_HOME} -s /bin/bash ${USER_ACCT} \
    && echo "${USER_ACCT}:${USER_ACCT}" | chpasswd \
    && echo "${USER_ACCT} ALL=(ALL)    NOPASSWD: ALL" > /etc/sudoers.d/developer \
    && echo export PATH="${TOOLCHAIN_BIN}:\${PATH}" > /etc/profile.d/toolchain.sh \
    && echo export MANPATH="${TOOLCHAIN_MAN}:\${MANPATH}" >> /etc/profile.d/toolchain.sh \
    && echo export PKG_CONFIG_PATH="${TOOLCHAIN_PKGCONFIG}:\${PKG_CONFIG_PATH}" >> /etc/profile.d/toolchain.sh

WORKDIR "${TOOLCHAIN_BUILD}"
COPY scripts/ ${TOOLCHAIN_BUILD}/bin
COPY etc/ ${TOOLCHAIN_BUILD}/etc

RUN mkdir -p "${TOOLCHAIN}" \
    && chown -R ${USER_ACCT}: \
        ${TOOLCHAIN} \
        ${TOOLCHAIN_BUILD}

USER "${USER_ACCT}"

RUN bin/build.sh \
    && sudo rm -rf "${TOOLCHAIN_BUILD}"

USER root

CMD ["/bin/bash", "-l"]
