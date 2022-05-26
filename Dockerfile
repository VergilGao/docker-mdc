FROM ghcr.io/vergilgao/mdc-buildimage:dev as build-stage

# get mdc source code
ARG MDC_SOURCE_VERSION
ENV MDC_SOURCE_VERSION=${MDC_SOURCE_VERSION:-c319d78888fec507cdc8aa468d96f37bb06e569b}

RUN wget -O- https://github.com/yoshiko2/Movie_Data_Capture/archive/$MDC_SOURCE_VERSION.tar.gz | tar xz -C /tmp/mdc --strip-components 1

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
ENV UMASK=002

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