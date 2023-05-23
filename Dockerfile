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
ENV MDC_SOURCE_VERSION=${MDC_SOURCE_VERSION:-0e7f7f497e49ae9c2dd776357892a1f1cd6d6068}

RUN mkdir -p /tmp/mdc && cd /tmp/mdc \
    # get mdc source code
    && wget -O- https://github.com/yoshiko2/Movie_Data_Capture/archive/$MDC_SOURCE_VERSION.tar.gz | tar xz -C /tmp/mdc --strip-components 1 \
    && python3 -m venv /opt/venv && . /opt/venv/bin/activate \
    && pip install --upgrade \
        pip \
        pyinstaller \
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
