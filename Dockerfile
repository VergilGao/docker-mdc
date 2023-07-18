ARG DLIB_DIR=/tmp/dlib
ARG DLIB_WHL_DIR=${DLIB_DIR}/dist

FROM python:3.10-slim-bullseye AS dlib-bin-builder-amd64
ARG DLIB_WHL_DIR
RUN mkdir -p ${DLIB_WHL_DIR}

FROM python:3.10-slim-bullseye AS dlib-bin-builder-arm64
# https://github.com/ageitgey/face_recognition/blob/master/Dockerfile
RUN apt-get -y update
RUN apt-get install -y --fix-missing \
    build-essential \
    cmake \
    gfortran \
    git \
    wget \
    curl \
    graphicsmagick \
    libgraphicsmagick1-dev \
    libatlas-base-dev \
    libavcodec-dev \
    libavformat-dev \
    libgtk2.0-dev \
    libjpeg-dev \
    liblapack-dev \
    libswscale-dev \
    pkg-config \
    python3-dev \
    python3-numpy \
    software-properties-common \
    zip \
    && apt-get clean && rm -rf /tmp/* /var/tmp/*

ARG DLIB_VERSION=v19.24.2
ARG DLIB_DIR

# dlib-bin repotory dlib-wheels steps: https://github.com/alesanfra/dlib-wheels/blob/master/.github/workflows/build.yaml
RUN mkdir -p ${DLIB_DIR} && \
    git clone -b "${DLIB_VERSION}" --single-branch https://github.com/davisking/dlib.git ${DLIB_DIR} && \
    cd ${DLIB_DIR} && \
    # change dlib python module desc
    sed -i'' -e "s/name='dlib'/name='dlib-bin'/" setup.py && \
    sed -i'' -e "s/version=read_version_from_cmakelists('dlib\/CMakeLists.txt')/version='$DLIB_VERSION'/" setup.py && \
    sed -i'' -e "s/url='https:\/\/github\.com\/davisking\/dlib'/url='https:\/\/github\.com\/navyd\/docker-mdc'/" setup.py && \
    sed -i'' -e "s/_cmake_extra_options = \[\]/_cmake_extra_options = \['-DDLIB_NO_GUI_SUPPORT=ON'\]/" setup.py && \
    # build dlib: https://github.com/davisking/dlib#compiling-dlib-python-api
    pip install build && \
    python -m build --wheel && \
    # check
    pip install ./dist/*.whl

FROM dlib-bin-builder-${TARGETARCH} AS dlib-bin-builder

FROM python:3.10-slim-bullseye as build-stage

RUN \
    apt-get -y update && apt-get -y upgrade \
    && apt install -y -q \
        bash \
        wget \
        binutils \
        upx \
    && apt-get autoremove --purge -y \
    && apt-get clean -y

ARG MDC_SOURCE_VERSION
ENV MDC_SOURCE_VERSION=${MDC_SOURCE_VERSION:-c3e5fdb09fefa11c614e519786e942b08b2a8fb0}

ARG DLIB_WHL_DIR
COPY --from=dlib-bin-builder $DLIB_WHL_DIR $DLIB_WHL_DIR

RUN mkdir -p /tmp/mdc && cd /tmp/mdc \
    # get mdc source code
    && wget -O- https://github.com/yoshiko2/Movie_Data_Capture/archive/$MDC_SOURCE_VERSION.tar.gz | tar xz -C /tmp/mdc --strip-components 1 \
    && python3 -m venv /opt/venv && . /opt/venv/bin/activate \
    && pip install --upgrade \
        pip \
        pyinstaller \
    && if [ -n "$(ls -A $DLIB_WHL_DIR)" ]; then pip install $DLIB_WHL_DIR/*.whl; fi \
    && pip install -r requirements.txt \
    && pip install face_recognition --no-deps \
    && pyinstaller \
        -D Movie_Data_Capture.py \
        --python-option u \
        --hidden-import "ImageProcessing.cnn" \
        --add-data "$(python -c 'import cloudscraper as _; print(_.__path__[0])' | tail -n 1):cloudscraper" \
        --add-data "$(python -c 'import opencc as _; print(_.__path__[0])' | tail -n 1):opencc" \
        --add-data "$(python -c 'import face_recognition_models as _; print(_.__path__[0])' | tail -n 1):face_recognition_models" \
        --add-data "Img:Img" \
        --add-data "scrapinglib:scrapinglib" \
    && cp /tmp/mdc/config.ini /tmp/mdc/dist/Movie_Data_Capture/config.template

FROM debian:11-slim

ARG BUILD_DATE
ARG VERSION

LABEL build_version="catfight360.com version:${VERSION} Build-date:${BUILD_DATE}"
LABEL maintainer="VergilGao"
LABEL build_from="https://github.com/yoshiko2/Movie_Data_Capture"
LABEL org.opencontainers.image.source="https://github.com/VergilGao/docker-mdc"

ENV TZ="Asia/Shanghai"
ENV UID=99
ENV GID=100
ENV UMASK=002

ADD docker-entrypoint.sh docker-entrypoint.sh
COPY --from=build-stage /tmp/mdc/dist/Movie_Data_Capture /app

RUN \
    apt-get -y update && apt-get -y upgrade \
    && apt install -y -q \
        gosu \
    && apt-get autoremove --purge -y \
    && apt-get clean -y \
    && chmod +x docker-entrypoint.sh \
    && mkdir -p /data /config \
    && useradd -d /config -s /bin/sh mdc \
    && chown -R mdc /data /config

VOLUME [ "/data", "/config" ]

ENTRYPOINT ["/docker-entrypoint.sh"]
