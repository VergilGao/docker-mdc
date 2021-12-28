FROM python:3.8-slim
LABEL maintainer="VergilGao"

# 软件包版本号
ARG MDC_VERSION

RUN \
    apt-get update && \
    apt-get install -y wget ca-certificates && \
    mkdir build && \
    cd build && \
    wget -O - https://github.com/yoshiko2/Movie_Data_Capture/archive/${MDC_VERSION}.tar.gz | tar xz && \
<<<<<<< HEAD
    mv AV_Data_Capture-${MDC_VERSION} /app && \
=======
    mv Movie_Data_Capture-${MDC_VERSION} /app && \
>>>>>>> 64f17757eb94d5ef9f63148f05f2f213884fd64b
    cd .. && \
    rm -rf build && \
    cd /app && \
    sed -i '/pyinstaller/d' requirements.txt && \
    cat requirements.txt && \
    pip install --no-cache-dir -r requirements.txt && \
    apt-get purge -y wget

VOLUME /app/data
WORKDIR /app

COPY docker-entrypoint.sh docker-entrypoint.sh

# 镜像版本号
ARG BUILD_DATE
LABEL build_version="catfight360.com mdc-version:- ${MDC_VERSION} build-date:- ${BUILD_DATE}"

RUN chmod +x docker-entrypoint.sh

ENTRYPOINT ["./docker-entrypoint.sh"]
