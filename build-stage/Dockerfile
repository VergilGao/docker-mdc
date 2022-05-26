FROM python:3.9-alpine3.15

LABEL maintainer="VergilGao"
LABEL org.opencontainers.image.source="https://github.com/VergilGao/docker-mdc"
LABEL org.opencontainers.image.description="用于 vergilgao/mdc 的构建层"

# Official Python base image is needed or some applications will segfault.
# PyInstaller needs zlib-dev, gcc, libc-dev, and musl-dev
RUN apk --update --no-cache add \
    zlib-dev \
    musl-dev \
    libc-dev \
    libffi-dev \
    gcc \
    g++ \
    git \
    make \
    cmake \
    pwgen \
    jpeg-dev \
    # mdc builder depenencies
    libxml2-dev \
    libxslt-dev \
    # download utils
    wget && \
    # update pip
    pip install --upgrade pip

ARG PYINSTALLER_SOURCE_VERISON
ENV PYINSTALLER_SOURCE_VERISON=${PYINSTALLER_SOURCE_VERISON:-4b9fd01d7dc5a0aae3ba7c100437547915464f0e}

# build bootloader for alpine
RUN mkdir -p /tmp/pyinstaller && \
    wget -O- https://github.com/pyinstaller/pyinstaller/archive/$PYINSTALLER_SOURCE_VERISON.tar.gz | tar xz -C /tmp/pyinstaller --strip-components 1 && \
    cd /tmp/pyinstaller/bootloader && \
    CFLAGS="-Wno-stringop-overflow -Wno-stringop-truncation" python ./waf configure --no-lsb all && \
    pip install .. && \
    rm -Rf /tmp/pyinstaller

ADD /root/ /pyinstaller/
RUN chmod a+x /pyinstaller/*

ARG MDC_REQUIREMENTS_SOURCE_VERSION
ENV MDC_REQUIREMENTS_SOURCE_VERSION=${MDC_REQUIREMENTS_SOURCE_VERSION:-c319d78888fec507cdc8aa468d96f37bb06e569b}

# install requirements
RUN cd /tmp && \
    wget -O mdc_requirements.txt https://raw.githubusercontent.com/yoshiko2/Movie_Data_Capture/$MDC_REQUIREMENTS_SOURCE_VERSION/requirements.txt && \
    pip install -r mdc_requirements.txt