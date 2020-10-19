#! /bin/bash
set -e

FAILED_OUTPUT=${FAILED_OUTPUT:-"failed"}
SUCCESS_OUTPUT=${SUCCESS_OUTPUT:-"output"}
SOFT_LINK=${SOFT_LINK:-"0"}
FAILED_MOVE=${FAILED_MOVE:-"1"}
TRANSLATE=${TRANSLATE:-"1"}
PROXY_TYPE=${PROXY_TYPE:-"socks5"}
PROXY_URI=${PROXY_URI}
TIMEOUT=${TIMEOUT:-"5"}
RETRY=${RETRY:-"3"}
LOCATION_RULE=${LOCATION_RULE:-"actor+'/'+number"}
NAMING_RULE=${NAMING_RULE:-"number+'-'+title"}
MAX_TITLE_LEN=${MAX_TITLE_LEN:-"50"}
PRIORITY_WEBSITE=${PRIORITY_WEBSITE:-"javbus,javdb,fanza,xcity,mgstage,fc2,avsox,jav321,javlib,dlsite"}
ESCAPE_FOLDERS=${ESCAPE_FOLDERS:-"${SUCCESS_OUTPUT},${FAILED_OUTPUT}"}
DEBUG=${DEBUG:-"0"}

cd /app
cat>docker.ini<<EOF
[common]
main_mode=1
failed_output_folder=data/${FAILED_OUTPUT}
success_output_folder=data/${SUCCESS_OUTPUT}
soft_link=${SOFT_LINK}
failed_move=${FAILED_MOVE}
auto_exit=1
transalte_to_sc=${TRANSLATE}

[proxy]
;proxytype: http or socks5 or socks5h
type=${PROXY_TYPE}
proxy=${PROXY_URI}
timeout=${TIMEOUT}
retry=${RETRY}

[Name_Rule]
location_rule=${LOCATION_RULE}
naming_rule=${NAMING_RULE}
max_title_len=${MAX_TITLE_LEN}

[update]
update_check=0

[priority]
website=${PRIORITY_WEBSITE}

[escape]
literals=\()/
folders=${ESCAPE_FOLDERS}

[debug_mode]
switch=${DEBUG}
EOF

exec python AV_Data_Capture.py -c docker.ini