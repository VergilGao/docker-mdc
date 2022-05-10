FROM python:3.8-alpine3.15 as build-stage

ARG MDC_REQUIREMENTS_SOURCE_VERSION
ENV MDC_REQUIREMENTS_SOURCE_VERSION=${MDC_REQUIREMENTS_SOURCE_VERSION:-0dff1a72c00ae75cdec7c39ebeee5b49e0a520d5}
ARG PILLOW_SOURCE_VERISON
ENV PILLOW_SOURCE_VERISON=${PILLOW_SOURCE_VERISON:-5d070222d21138d2ead002fd33fdf5adcb708941}

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
    libxslt-dev \
    # download utils
    wget && \
    pip install --upgrade pip

# get pillow
RUN cd /tmp && \
    wget -q -nc --show-progress --progress=bar:force:noscroll -O /tmp/pillow-$PILLOW_SOURCE_VERISON.tar.gz https://github.com/python-pillow/Pillow/archive/$PILLOW_SOURCE_VERISON.tar.gz && \
    tar zxvf /tmp/pillow-$PILLOW_SOURCE_VERISON.tar.gz && \
    rm /tmp/pillow-$PILLOW_SOURCE_VERISON.tar.gz && \
    mv Pillow-$PILLOW_SOURCE_VERISON /Pillow && \
    pip install virtualenv && \
    virtualenv /vpy && \
    source /vpy/bin/activate && \
    pip install nose

# install requirements
RUN cd /tmp && \
    wget -q -nc --show-progress --progress=bar:force:noscroll -O /tmp/mdc_requirements.txt https://raw.githubusercontent.com/yoshiko2/Movie_Data_Capture/$MDC_REQUIREMENTS_SOURCE_VERSION/requirements.txt && \
    pip install -r mdc_requirements.txt

ARG PYINSTALLER_SOURCE_VERISON
ENV PYINSTALLER_SOURCE_VERISON=${PYINSTALLER_SOURCE_VERISON:-669313ba4c5c1403ebeb335c35cb68c8c6ba5dd4}

# build bootloader for alpine
RUN cd /tmp && \
    wget -q -nc --show-progress --progress=bar:force:noscroll -O /tmp/pyinstaller-$PYINSTALLER_SOURCE_VERISON.tar.gz https://github.com/pyinstaller/pyinstaller/archive/$PYINSTALLER_SOURCE_VERISON.tar.gz && \
    tar zxvf /tmp/pyinstaller-$PYINSTALLER_SOURCE_VERISON.tar.gz && \
    rm /tmp/pyinstaller-$PYINSTALLER_SOURCE_VERISON.tar.gz && \
    mv pyinstaller-$PYINSTALLER_SOURCE_VERISON pyinstaller && \
    cd /tmp/pyinstaller/bootloader && \
    CFLAGS="-Wno-stringop-overflow -Wno-stringop-truncation" python ./waf configure --no-lsb all && \
    pip install ..  && \
    rm -Rf /tmp/pyinstaller

ADD ./root /pyinstaller
RUN chmod a+x /pyinstaller/*

# get mdc source code
ARG MDC_SOURCE_VERSION
ENV MDC_SOURCE_VERSION=${MDC_SOURCE_VERSION:-c0fab96191b882ebbd7acaeb3c81d6f60e1d4206}

RUN cd /tmp && \
    wget -q -nc --show-progress --progress=bar:force:noscroll -O /tmp/mdc-$MDC_SOURCE_VERSION.tar.gz https://github.com/yoshiko2/Movie_Data_Capture/archive/$MDC_SOURCE_VERSION.tar.gz && \
    tar zxvf /tmp/mdc-$MDC_SOURCE_VERSION.tar.gz && \
    rm /tmp/mdc-$MDC_SOURCE_VERSION.tar.gz && \
    mv Movie_Data_Capture-$MDC_SOURCE_VERSION mdc

# build mdc
RUN cd /tmp/mdc && \
    /pyinstaller/pyinstaller.sh \
        --onefile Movie_Data_Capture.py \
        --hidden-import ADC_function.py \
        --hidden-import core.py \
        --add-data "Img:Img" \
        --add-data "$(python -c 'import cloudscraper as _; print(_.__path__[0])' | tail -n 1):cloudscraper" \
        --add-data "$(python -c 'import opencc as _; print(_.__path__[0])' | tail -n 1):opencc" \
        --add-data "$(python -c 'import face_recognition_models as _; print(_.__path__[0])' | tail -n 1):face_recognition_models"

# build done

FROM ghcr.io/vergilgao/alpine-baseimage

RUN apk --update --no-cache add \
    libxcb

ARG BUILD_DATE
ARG VERSION

LABEL build_version="catfight360.com version:${VERSION} Build-date:${BUILD_DATE}"
LABEL maintainer="VergilGao"
LABEL build_from="https://github.com/yoshiko2/Movie_Data_Capture"
LABEL org.opencontainers.image.source="https://github.com/VergilGao/docker-mdc"

ENV TZ="Asia/Shanghai"
ENV UID=99
ENV GID=100
ENV UMASK=000

ADD docker-entrypoint.sh docker-entrypoint.sh

RUN chmod +x docker-entrypoint.sh && \
    mkdir -p /app && \
    mkdir -p /data && \
    mkdir -p /config && \
    useradd -d /config -s /bin/sh mdc && \
    chown -R mdc /config && \
    chown -R mdc /data

COPY --from=build-stage /tmp/mdc/dist/Movie_Data_Capture /app
COPY --from=build-stage /tmp/mdc/config.ini /app/config.template

VOLUME [ "/data", "/config" ]

ENTRYPOINT ["/docker-entrypoint.sh"]