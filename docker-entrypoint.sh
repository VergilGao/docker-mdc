#! /bin/sh

USER=mdc
config_file="/config/mdc.ini"

echo "---Setup Timezone to ${TZ}---"
echo "${TZ}" > /etc/timezone
echo "---Checking if UID: ${UID} matches user---"
usermod -u ${UID} ${USER}
echo "---Checking if GID: ${GID} matches user---"
groupmod -g ${GID} ${USER} > /dev/null 2>&1 ||:
usermod -g ${GID} ${USER}
echo "---Setting umask to ${UMASK}---"
umask ${UMASK}

echo "---Taking ownership of data...---"
if [ ! -d /config ]; then
    echo "---no config folder found, create...---"
    mkdir -p /config
fi
chown -R ${UID}:${GID} /app /data /config 

echo "Checking if config file exist"
if [ ! -f "${config_file}" ]; then
    cp /app/config.template "${config_file}"
fi

echo "Starting..."
cd /data
gosu ${USER} /app/Movie_Data_Capture