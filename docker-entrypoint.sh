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
    echo "config file missing, we create a new config file, modify the config file and restart container please!"
    echo "没有找到配置文件，我们创建了一个新的配置文件，请修改后重启镜像"
    exist 1
fi

echo "Download Mapping Table"
mkdir -p /config/.local/share/mdc && cd /config/.local/share/mdc
wget https://raw.githubusercontent.com/yoshiko2/Movie_Data_Capture/master/MappingTable/mapping_actor.xml || true
wget https://raw.githubusercontent.com/yoshiko2/Movie_Data_Capture/master/MappingTable/mapping_info.xml || true
wget https://raw.githubusercontent.com/yoshiko2/Movie_Data_Capture/master/MappingTable/c_number.json || true

echo "Starting..."
cd /data
gosu ${USER} /app/Movie_Data_Capture