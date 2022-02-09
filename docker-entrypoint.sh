#! /bin/bash

MAIN_MODE=${MAIN_MODE:-"1"}
SOURCE_FOLDER=${SOURCE_FOLDER:-"./"}
FAILED_OUTPUT=${FAILED_OUTPUT:-"failed"}
SUCCESS_OUTPUT=${SUCCESS_OUTPUT:-"output"}
SOFT_LINK=${SOFT_LINK:-"0"}
FAILED_MOVE=${FAILED_MOVE:-"1"}
TRANSLATE=${TRANSLATE:-"1"}
DEL_EMPTY_FOLDER=${DEL_EMPTY_FOLDER:-"1"}
MULTI_THREAD=${MULTI_THREAD:-"1"}
USE_PROXY=${USE_PROXY:-"0"}
PROXY_TYPE=${PROXY_TYPE:-"socks5"}
PROXY_URI=${PROXY_URI}
CACERT_FILE=${CACERT_FILE}
TIMEOUT=${TIMEOUT:-"5"}
RETRY=${RETRY:-"3"}
NFO_SKIP_DAYS=${NFO_SKIP_DAYS:-"30"}
STOP_COUNTER=${STOP_COUNTER:-"0"}
IGNORE_FAILED_LIST=${IGNORE_FAILED_LIST:-"0"}
DOWNLOAD_ONLY_MISSING_IMAGES=${DOWNLOAD_ONLY_MISSING_IMAGES:-"1"}
MAPPING_TABLE_VALIDITY=${MAPPING_TABLE_VALIDITY:-"7"}
LOCATION_RULE=${LOCATION_RULE:-"actor+'/'+number"}
NAMING_RULE=${NAMING_RULE:-"number+'-'+title"}
MAX_TITLE_LEN=${MAX_TITLE_LEN:-"50"}
PRIORITY_WEBSITE=${PRIORITY_WEBSITE:-"javbus,javdb,airav,fanza,xcity,mgstage,fc2,avsox,dlsite,carib"}
ESCAPE_FOLDERS=${ESCAPE_FOLDERS:-"${SUCCESS_OUTPUT},${FAILED_OUTPUT}"}
ESCAPE_LITERALS=${ESCAPE_LITERALS:-"\()/"}
WATERMARK=${WATERMARK:-"0"}
WATERMARK_POSITION=${WATERMARK_POSITION:-"2"}
EXTRAFANART=${EXTRAFANART:-"0"}
EXTRAFANART_FOLDER=${EXTRAFANART_FOLDER:-"extrafanart"}
DEBUG=${DEBUG:-"0"}

STORYLINE_SWITCH=${STORYLINE_SWITCH:-"1"}
STORYLINE_SITE=${STORYLINE_SITE:-"=1:avno1,4:airavwiki"}
STORYLINE_CENSORED_SITE=${STORYLINE_CENSORED_SITE:-"2:airav,5:xcity,6:amazon"}
STORYLINE_UNCENSORED_SITE=${STORYLINE_UNCENSORED_SITE:-"3:58avgo"}
STORYLINE_RUN_MODE=${STORYLINE_RUN_MODE:-"1"}
STORYLINE_SHOW_RESULT=${STORYLINE_SHOW_RESULT:-"0"}
CC_CONVERT_MODE=${CC_CONVERT_MODE:-"1"}
CC_CONVERT_VARS=${CC_CONVERT_VARS:-"outline,series,studio,tag,title"}
JAVDB_SITES=${JAVDB_SITES:-"33,34"}

mk_config() {
    cat>/root/mdc.ini<<EOF
[common]
main_mode=${MAIN_MODE}
source_folder=${SOURCE_FOLDER}
failed_output_folder=${FAILED_OUTPUT}
success_output_folder=${SUCCESS_OUTPUT}
soft_link=${SOFT_LINK}
failed_move=${FAILED_MOVE}
auto_exit=1
transalte_to_sc=${TRANSLATE}
multi_threading=${MULTI_THREAD}
del_empty_folder=${DEL_EMPTY_FOLDER}
actor_gender=female
nfo_skip_days=${NFO_SKIP_DAYS}
stop_counter=${STOP_COUNTER}
ignore_failed_list=${IGNORE_FAILED_LIST}
download_only_missing_images=${DOWNLOAD_ONLY_MISSING_IMAGES}
mapping_table_validity=${MAPPING_TABLE_VALIDITY}
[proxy]
switch=${USE_PROXY}
type=${PROXY_TYPE}
proxy=${PROXY_URI}
timeout=${TIMEOUT}
retry=${RETRY}
cacert_file=${CACERT_FILE}
[Name_Rule]
location_rule=${LOCATION_RULE}
naming_rule=${NAMING_RULE}
max_title_len=${MAX_TITLE_LEN}
[update]
update_check=0
[priority]
website=${PRIORITY_WEBSITE}
[escape]
literals=${ESCAPE_LITERALS}
folders=${ESCAPE_FOLDERS}
[debug_mode]
switch=${DEBUG}
[transalte]
switch=0
values=title,outline
; 预告片
[trailer]
switch=0
; 用来确定是否是无码
[uncensored]
uncensored_prefix=S2M,BT,LAF,SMD
[media]
; 影片后缀
media_type=.mp4,.avi,.rmvb,.wmv,.mov,.mkv,.flv,.ts,.webm,.iso
; 字幕后缀
sub_type=.smi,.srt,.idx,.sub,.sup,.psb,.ssa,.ass,.txt,.usf,.xss,.ssf,.rt,.lrc,.sbv,.vtt,.ttml
; 水印
[watermark]
switch=${WATERMARK}
water=${WATERMARK_POSITION}
; 左上 0, 右上 1, 右下 2， 左下 3
; 剧照
[extrafanart]
switch=${EXTRAFANART}
extrafanart_folder=${EXTRAFANART_FOLDER}
; 剧情简介
[storyline]
switch=${STORYLINE_SWITCH}
site=${STORYLINE_SITE}
censored_site=${STORYLINE_CENSORED_SITE}
uncensored_site=${STORYLINE_UNCENSORED_SITE}
; 运行模式：0:顺序执行(最慢) 1:线程池(默认值) 2:进程池(启动开销比线程池大，并发站点越多越快)
run_mode=${STORYLINE_RUN_MODE}
; show_result剧情简介调试信息 0关闭 1简略 2详细(详细部分不记入日志)，剧情简介失效时可打开2查看原因
show_result=${STORYLINE_SHOW_RESULT}
; 繁简转换 繁简转换模式mode=0:不转换 1:繁转简 2:简转繁
[cc_convert]
mode=${CC_CONVERT_MODE}
vars=${CC_CONVERT_VARS}
[javdb]
sites=${JAVDB_SITES}
EOF
}

run_mdc() {
    cd /data
    s6-setuidgid alpha \
      /app/Movie_Data_Capture
}

PUID=${PUID:-666}
PGID=${PGID:-666}

groupmod -o -g "$PGID" alpha
usermod -o -u "$PUID" alpha


mk_config
chown -R alpha:alpha /root
chown alpha:alpha /app
chown -R alpha:alpha /data
run_mdc