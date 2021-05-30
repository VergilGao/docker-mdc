#! /bin/bash
set -e

FAILED_OUTPUT=${FAILED_OUTPUT:-"failed"}
SUCCESS_OUTPUT=${SUCCESS_OUTPUT:-"output"}
SOFT_LINK=${SOFT_LINK:-"0"}
FAILED_MOVE=${FAILED_MOVE:-"1"}
TRANSLATE=${TRANSLATE:-"1"}
MULTI_THREAD=${MULTI_THREAD:-"1"}
USE_PROXY=${USE_PROXY:-"0"}
PROXY_TYPE=${PROXY_TYPE:-"socks5"}
PROXY_URI=${PROXY_URI}
CACERT_FILE=${CACERT_FILE}
TIMEOUT=${TIMEOUT:-"5"}
RETRY=${RETRY:-"3"}
LOCATION_RULE=${LOCATION_RULE:-"actor+'/'+number"}
NAMING_RULE=${NAMING_RULE:-"number+'-'+title"}
MAX_TITLE_LEN=${MAX_TITLE_LEN:-"50"}
PRIORITY_WEBSITE=${PRIORITY_WEBSITE:-"javbus,javdb,airav,fanza,xcity,mgstage,fc2,avsox,dlsite,carib"}
ESCAPE_FOLDERS=${ESCAPE_FOLDERS:-"${SUCCESS_OUTPUT},${FAILED_OUTPUT}"}
ESCAPE_LITERALS=${ESCAPE_LITERALS:-"\()/"}
DEBUG=${DEBUG:-"0"}

cd /app
cat>config.ini<<EOF
[common]
main_mode=1
failed_output_folder=data/${FAILED_OUTPUT}
success_output_folder=data/${SUCCESS_OUTPUT}
soft_link=${SOFT_LINK}
failed_move=${FAILED_MOVE}
auto_exit=1
transalte_to_sc=${TRANSLATE}
multi_threading=${MULTI_THREAD}
actor_gender=female

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
switch=0
water=2
; 左上 0, 右上 1, 右下 2， 左下 3

; 剧照
[extrafanart]
switch=0
extrafanart_folder=extrafanart

EOF

exec python AV_Data_Capture.py