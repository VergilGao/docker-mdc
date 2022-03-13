FROM python:3.8-alpine3.15 as build-stage

ARG PYINSTALLER_TAG
ENV PYINSTALLER_TAG ${PYINSTALLER_TAG:-"v4.8"}

ARG MDC_VERSION

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
    # Pillow depenencies
    freetype-dev \
    lcms2-dev \
    openjpeg-dev \
    tiff-dev \
    tk-dev \
    tcl-dev \
    # mdc builder depenencies
    libxml2-dev \
    libxslt-dev && \
    pip install --upgrade pip

RUN git clone https://github.com/python-pillow/Pillow.git /Pillow
RUN pip install virtualenv && virtualenv /vpy && source /vpy/bin/activate && pip install nose

# Build bootloader for alpine
RUN git clone --depth 1 --single-branch --branch ${PYINSTALLER_TAG} https://github.com/pyinstaller/pyinstaller.git /tmp/pyinstaller \
    && cd /tmp/pyinstaller/bootloader \
    && CFLAGS="-Wno-stringop-overflow -Wno-stringop-truncation" python ./waf configure --no-lsb all \
    && pip install .. \
    && rm -Rf /tmp/pyinstaller

ADD ./root /pyinstaller
RUN chmod a+x /pyinstaller/*

RUN  git clone --depth=1 -b ${MDC_VERSION} https://github.com/yoshiko2/Movie_Data_Capture.git /tmp/src
RUN  cd /tmp/src && pip install -r requirements.txt

RUN \
    cd /tmp/src && \
    /pyinstaller/pyinstaller.sh \
        --onefile Movie_Data_Capture.py \
        --hidden-import ADC_function.py \
        --hidden-import core.py \
        --add-data "Img:Img" \
        --add-data "$(python -c 'import cloudscraper as _; print(_.__path__[0])' | tail -n 1):cloudscraper" \
        --add-data "$(python -c 'import opencc as _; print(_.__path__[0])' | tail -n 1):opencc" \
        --add-data "$(python -c 'import face_recognition_models as _; print(_.__path__[0])' | tail -n 1):face_recognition_models"

FROM alpine:3.15
RUN apk --update --no-cache add \
    ca-certificates \
    coreutils \
    libxcb \
    shadow \
    tzdata

ARG BUILD_DATE
ARG VERSION

LABEL build_version="catfight360.com version:${VERSION} Build-date:${BUILD_DATE}"
LABEL maintainer="VergilGao"
LABEL build_from="https://github.com/yoshiko2/Movie_Data_Capture"
LABEL org.opencontainers.image.source="https://github.com/VergilGao/docker-mdc"

ENV TZ="Asia/Shanghai"
ENV PUID=99
ENV PGID=100
ENV UMASK=000

ADD docker-entrypoint.sh docker-entrypoint.sh

RUN chmod +x docker-entrypoint.sh && \
    mkdir /app && \
    mkdir -p /data && \
    mkdir -p /config && \
    useradd -d /config -s /bin/sh alpha && \
    chown -R alpha /config && \
    chown -R alpha /data

COPY --from=build-stage /tmp/src/dist/Movie_Data_Capture /app

VOLUME [ "/data", "/config" ]

ENTRYPOINT ["/docker-entrypoint.sh"]