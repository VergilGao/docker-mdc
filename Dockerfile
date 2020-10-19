FROM python:3.8-slim
LABEL maintainer="VergilGao"

# 软件包版本号
ARG GLIBC_VERSION
ARG AVDC_VERSION

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

# 镜像版本号
ARG BUILD_DATE
ARG VERSION
LABEL build_version="catfight360.com version:- ${VERSION} build-date:- ${BUILD_DATE}"

RUN chmod +x docker-entrypoint.sh

ENTRYPOINT ["./docker-entrypoint.sh"]
