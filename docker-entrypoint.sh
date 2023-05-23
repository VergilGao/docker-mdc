#! /bin/sh

USER=mdc
config_file="/config/mdc.ini"

echo "---Setup Timezone to ${TZ}---"
echo "${TZ}" > /etc/timezone
echo "---Checking if UID: ${UID} matches user---"
usermod -o -u ${UID} ${USER}
echo "---Checking if GID: ${GID} matches user---"
groupmod -o -g ${GID} ${USER} > /dev/null 2>&1 ||:
usermod -g ${GID} ${USER}
echo "---Setting umask to ${UMASK}---"
umask ${UMASK}

echo "---Taking ownership of data...---"
if [ ! -d /config ]; then
    echo "---no config folder found, create...---"
    mkdir -p /config
fi
chown -R ${UID}:${GID} /data /config 

echo "Checking if config file exist"
if [ ! -f "${config_file}" ]; then
    cp /app/config.template "${config_file}"
    echo "config file missing, we create a new config file, modify the config file and restart container please!"
    echo "没有找到配置文件，我们创建了一个新的配置文件，请修改后重启镜像"
    exit 1
fi

echo "Starting..."
cd /data
gosu ${USER} /app/Movie_Data_Capture
