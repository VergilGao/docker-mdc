FROM python:3.8-slim

ARG AVDC_VERSION
LABEL build_version="avdc_version:- ${AVDC_VERSION}"
LABEL maintainer="VergilGao"

RUN \
    apt-get update && \
    apt-get install -y wget ca-certificates && \
    mkdir build && \
    cd build && \
    wget -O - https://github.com/yoshiko2/AV_Data_Capture/archive/${AVDC_VERSION}.tar.gz | tar xz && \
    mv AV_Data_Capture-${AVDC_VERSION} /app && \
    cd .. && \
    rm -rf build && \
    cd /app && \
    rm config.ini && \
    pip install --no-cache-dir -r requirements.txt && \
    apt-get purge -y wget

VOLUME /app/data
WORKDIR /app

COPY docker-entrypoint.sh docker-entrypoint.sh

RUN chmod +x docker-entrypoint.sh

ENTRYPOINT ["./docker-entrypoint.sh"]
