# Movie Data Capture - Docker

![publish](https://github.com/VergilGao/docker-mdc/workflows/publish/badge.svg) [![GitHub license](https://img.shields.io/github/license/VergilGao/docker-mdc)](https://github.com/VergilGao/docker-mdc/blob/master/LICENSE)

**数据无价，请谨慎操作！**

**数据无价，请谨慎操作！**

**数据无价，请谨慎操作！**

重要的事情说三遍。

`Movie_Data_Capture` 以下简称`mdc`是一款由[yoshiko2](https://github.com/yoshiko2)使用`python3`编写的日本AV刮削器。

本镜像能帮助用户在nas中无需安装复杂的`python3`运行时环境，可以更简单的使用`mdc`。

本镜像从仓库[Movie_Data_Capture](https://github.com/yoshiko2/movie_data_Capture)构建，版本号和源仓库的release版本号统一

* **注意，因为docker文件系统的特殊性，请仔细阅读以下操作指南后再行使用。**
* **镜像作者[VergilGao](https://github.com/VergilGao) [yoshiko2](https://github.com/yoshiko2)对使用此镜像导致的文件丢失、损坏均不负责。**

## 测试

首先你可以测试一下程序是否可用。

```sh
docker pull vergilgao/mdc:latest
mkdir test
touch test/MIFD-046.mp4
docker run --rm --name mdc_test -it -v ${PWD}/test:/app/data vergilgao/mdc:latest
```

然后你会看到如下输出：

```sh
[*]================ Movie Data Capture ==================
[*]                    Version 6.0.1
[*]======================================================
[+]Find 1 movies
[!] - 100.% [1/1] -
[!]Making Data for [./data/MIFD-046.mp4], the number is [MIFD-046]
[+]Image Downloaded! data/JAV_output/御坂りあ/MIFD-046/MIFD-046-fanart.jpg
[+]Image Cutted!     data/JAV_output/御坂りあ/MIFD-046/MIFD-046-poster.jpg
[+]Wrote!            data/JAV_output/御坂りあ/MIFD-046/MIFD-046.nfo
[*]======================================================
[+]All finished!!!
```

确认程序没有问题后把测试数据删掉就好了。

```sh
sudo rm -rf test
```

## 自定义配置

与源程序不同，本镜像使用运行时的环境变量来完成自定义配置。

```sh
docker run --rm -it \
  --name mdc_test \
  -v ${PWD}/test:/app/data \
  -e USE_PROXY=1 \
  -e PROXY_TYPE="socks5" \
  -e PROXY_URI="127.0.0.1:1080" \
  vergilgao/mdc:latest
```

注意，尽量将环境变量值包含在`""`内，同时请勿再在环境变量中使用`""`。

环境变量字段和原程序`config.ini`文件的字段对应关系如下。

| 字段名           | 原 ini 文件字段       | 值语义                           | 预设值                       |
| :--------------- | :-------------------- | :------------------------------- | :--------------------------- |
| MAIN_MODE                      | main_mode                      | 运行模式                         | 1                            |
| SOURCE_FOLDER                  | source_folder                  | 原影片输入目录                   | ./                           |
| FAILED_OUTPUT                  | failed_output_folder           | 失败输出目录                     | failed                       |
| SUCCESS_OUTPUT                 | success_output_folder          | 成功输出目录                     | output                       |
| SOFT_LINK                      | soft_link                      | 软连接模式                       | 0                            |
| FAILED_MOVE                    | failed_move                    | 移动失败刮削文件至失败输出文件夹 | 1                            |
| TRANSLATE                      | transalte_to_sc                | 翻译至简体中文                   | 1                            |
| MULTI_THREAD                   | multi_threading                | 多线程刮削                       | 1                            |
| USE_PROXY                      | switch                         | 开启代理                         | 0                            |
| PROXY_TYPE                     | type                           | 代理类型                         | socket5                      |
| PROXY_URI                      | proxy                          | 代理地址                         | ""                           |
| CACERT_FILE                    | cacert_file                    | 证书文件                         | ""                           |
| TIMEOUT                        | timeout                        | 刮削超时时间/秒                     | 5                            |
| RETRY                          | retry                          | 重试次数                         | 3                            |
| NFO_SKIP_DAYS                  | nfo_skip_days                  | NFO过期时间/天                   | 30                           |
| STOP_COUNTER                   | stop_counter                   | 文件刮削失败站点封禁阈值            | 0                           |
| IGNORE_FAILED_LIST             | ignore_failed_list             | 刮削失败文件开关                  | 0                           |
| DOWNLOAD_ONLY_MISSING_IMAGES   | download_only_missing_images   | 下载已刮削影片缺失信息             | 1                           |
| MAPPING_TABLE_VALIDITY         | mapping_table_validity         | 对照表重下载阈值/天               | 7                           |
| LOCATION_RULE                  | location_rule                  | 文件目录命名规则                 | "actor+'/'+number"           |
| NAMING_RULE                    | naming_rule                    | nfo文件中影片命名规则            | "number+'-'+title"           |
| MAX_TITLE_LEN                  | max_title_len                  | 最大标题长度                     | 50                           |
| PRIORITY_WEBSITE               | website                        | 刮削数据网站                     | 与源仓库相同               |
| ESCAPE_FOLDERS                 | folders                        | 排除目录                         | FAILED_OUTPUT,SUCCESS_OUTPUT |
| ESCAPE_LITERALS                | literals                       | 去除文件名中的特殊符号           | "\()/"                       |
| WATERMARK                      | switch                         | 水印开关                         | 0         |
| WATERMARK_POSITION             | water                          | 水印位置                         | 2         |
| EXTRAFANART                    | switch                         | 剧照开关                         | 0         |
| EXTRAFANART_FOLDER             | extrafanart_folder             | 剧照文件夹                        | extrafanart         |
| DEBUG                          | switch                         | 测试输出                         | 0                            |
| STORYLINE_SWITCH               | switch                         | 剧情简介抓取开关                   | 1
| STORYLINE_SITE                 | site                           | 剧情简介站点                      | 1:avno1,4:airavwiki          |
| STORYLINE_CENSORED_SITE        | censored_site                  | 剧情简介站点（有码）                | 2:airav,5:xcity,6:amazon     |
| STORYLINE_UNCENSORED_SITE      | uncensored_site                | 剧情简介站点（无码）                | 3:58avgo                     |
| STORYLINE_RUN_MODE             | run_mode                       | 运行模式                         | 1                                    |
| STORYLINE_SHOW_RESULT          | show_result                    | 剧情简介调试信息                   | 0                           |
| CC_CONVERT_MODE                | mode                           | 繁简转换开关                      | 1                           |
| CC_CONVERT_VARS                | vars                           | 需转换的元数据                    | actor,director,label,outline,series,studio,tag,title|
| JAVDB_SITES                    | sites                          | javdb域名后缀                    | 33,34                           |


注：水印位置定义，左上 0, 右上 1, 右下 2， 左下 3

## 构建（开发人员）
```
cd docker-mdc
docker build -t mdc --build-arg MDC_VERSION="6.0.1" ./

mkdir test
touch test/MIFD-046.mp4
docker run --rm --name mdc_test -it -v ${PWD}/test:/app/data mdc
```

#  申明
当你查阅、下载了本项目源代码或二进制程序，即代表你接受了以下条款

* 本软件仅供技术交流，学术交流使用
* **请勿在墙内的社交平台上宣传此项目**
* 本软件作者编写出该软件旨在学习 Python ，提高编程水平
* 本软件不提供任何影片下载的线索
* 用户在使用本软件前，请用户了解并遵守当地法律法规，如果本软件使用过程中存在违反当地法律法规的行为，请勿使用该软件
* 用户在使用本软件时，若用户在当地产生一切违法行为由用户承担
* 严禁用户将本软件使用于商业和个人其他意图
* 源代码和二进制程序请在下载后24小时内删除
* 出售源码者的母亲会升天
* 本项目发起者yoshiko2保留最终决定权和最终解释权
* 若用户不同意上述条款任意一条，请勿使用本软件
---
When you view and download the source code or binary program of this project, it means that you have accepted the following terms

* This software is only for technical exchange and academic exchange
* **Please do not promote this project on popular social platforms**
* The software author wrote this software to learn Python and improve programming
* This software does not provide any clues for video download
* Before using this software, please understand and abide by local laws and regulations. If there is any violation of local laws and regulations during the use of this software, * please do not use this software  
* When the user uses this software, if the user has any illegal acts in the local area, the user shall bear
* It is strictly forbidden for users to use this software for commercial and personal intentions
* Please delete the source code and binary program within 24 hours after downloading
* The mother of the source seller will die
* The author of this software yoshiko2 reserves the right of final decision and final interpretation
* If the user does not agree with any of the above terms, please do not use this software
---
本プロジェクトのソースコード、バイナリファイルをダウンロード、または表示するしたうえで、あなたは本規約に同意したものと見なします。
* このソフトウェアは、開発技術学習することのみに使用できます。
* **ソーシャルメディアで本プロジェクトの宣伝をご遠慮ください**
* 作者はPythonの勉強と技術力の向上のために、このソフトウェアを作成しました
* 本ソフトウェアは、あらゆる動画ダウンロード機能一切提供しません
* 本ソフトウェアを使用する前に、現地の法律規範をよく理解する必要があります。あなたは、適用される現地の法令を順守する責任を負います
* 本ソフトウェアを使用した結果生じた損害や法的責任につきまして作者は一切責任を負いません
* 本ソフトウェアを商用、業務、その他の営利目的のために使用することは一切禁止します。
* 本プロジェクトのソースコード、バイナリファイルをダウンロードした場合、24時間以内に削除してください
* 元売り手の母親が天に召される
* 最終解釈権は作者yoshiko2に属します
* 本規約およびすべての適用法、規約および規則を遵守する場合にのみ本ソフトウェアを使用することができます



