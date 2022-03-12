# Movie Data Capture - Docker

[ghcr.io]](https://github.com/VergilGao/docker-mdc/pkgs/container/mdc) | [dockerhub]](https://hub.docker.com/repository/docker/vergilgao/mdc) 

![publish](https://github.com/VergilGao/docker-mdc/workflows/publish/badge.svg) [![GitHub license](https://img.shields.io/github/license/VergilGao/docker-mdc)](https://github.com/VergilGao/docker-mdc/blob/master/LICENSE)

**数据无价，请谨慎操作！**

**数据无价，请谨慎操作！**

**数据无价，请谨慎操作！**

重要的事情说三遍。

`Movie_Data_Capture` 以下简称 `mdc`是一款由[yoshiko2](https://github.com/yoshiko2)使用 `python3`编写的成人影片刮削器。

本镜像能帮助用户在nas中无需安装运行时环境，可以更简单的使用 `mdc`。

本仓库针对`unraid`系统做出了特别优化，对于`unraid`用户，本镜像的默认配置即可避免权限问题。对于其他nas系统用户，请按照各自的系统权限策略设置`PUID` `PGID` `UMASK`三个环境变量。

本镜像从仓库[Movie_Data_Capture](https://github.com/yoshiko2/movie_data_Capture)构建，因为本人工作较忙，很可能不会及时和上游release同步。

* **注意，因为docker文件系统的特殊性，请仔细阅读以下操作指南后再行使用。**
* **镜像作者[VergilGao](https://github.com/VergilGao) [yoshiko2](https://github.com/yoshiko2)对使用此镜像导致的文件丢失、损坏均不负责。**

## 更新日志

20220312:

* 新增自定义配置文件功能，你现在可以使用自己编写的配置文件来运行程序了！请映射 `mdc.ini` 文件至 `/config/mdc.ini` 目录，程序会自动判断是否存在配置文件。如果配置文件存在，环境变量的设置及修改将会**不起作用**，这意味着如果使用环境变量启动，程序只会应用**首次**启动容器时的环境变量，反复启动程序时，新修改的环境变量将**不起作用**。如果你的容器不是一次性的，请使用映射mdc.ini文件的方式启动。
* 新增环境变量`TZ`，默认值为`Asia/Shanghai`，这将设置容器内的时间区域。
* 新增环境变量`UMASK`，修改`PUID`和`PGID`的默认值，目前的默认值为`PUID=99, PGID=100 UMASK=000`，此为`UNRAID`系统用户的推荐配置，其他系统仍然需要自行修改以防止出现权限问题。
* 删除`s6-overlay`驱动，权限问题将通过`su`命令解决，因此，本镜像的`PUID`和`PGID`环境变量事实上等同于`UID`和`GID`，为了保持兼容性，环境变量名不再修改。
* 新增ghcr.io镜像仓库，此仓库只有`vergilgao/mdc`，同时dockerhub镜像仓库将继续保持`vergilgao/avdc`和`vergilgao/mdc`两个地址的更新。
* 提升tag丰富度，将上游版本号按{major}.{minor}.{build}拆分更新，同时新增一个定义为`{version}-r{release_count}`的tag，用于标识同一个上游release下docker版本的更新次数。
* 新增夜间构建tag，只会推送到`vergilgao/mdc`和`ghcr.io/vergilgao/mdc`，此tag将保持每周一次的更新频率，并不保证会更新至最新源码。

20220209：

* 文件挂载目录从 /app/data 变为 /data **Breaking Change!**
* 增加 PUID PGID 两个环境变量，现在你可以通过设置这两个环境变量来控制程序刮削获取到的文件权限，注意，程序启动后同时也会用这两个环境变量设置整个挂载目录的所有文件的权限！两个环境变量的默认值均为 666 **强烈推荐设置这两个环境变量**
* 镜像从源代码运行改为了使用 alpine 运行二进制 **仅测试了x64环境，其他环境如果有问题请发issue反馈**

## 测试

首先你可以测试一下程序是否可用。

```sh
docker pull ghcr.io/vergilgao/mdc:latest
mkdir test
dd if=/dev/zero of="./test/MIFD-046.mp4" bs=250MB count=1
docker run --rm --name mdc_test -it -v ${PWD}/test:/data -e PUID=$(stat -c %u test) -e PGID=$(stat -c %g test) vergilgao/mdc:latest
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
rm -rf test
```

## docker环境变量

本镜像增加了权限设置功能，你可以通过使用 PUID (用户id) PGID (组id) 两个环境变量来配置程序运行后所有文件的权限。

| 字段名    | 值语义             | 预设值         |
| :--------| :----------------- | :------------- |
| PUID     | uid                | 99             |
| PGID     | gid                | 100            |
| UMASK    | data目录的umask    | 000            |
| TZ       | 容器内时间区域      | Asia/Shanghai  |

## 程序运行时配置

### 映射mdc.ini文件（推荐）

假设你的mdc.ini文件存放在当前目录的config子目录下。

```sh
docker run --rm -it \
  --name mdc_test \
  -v ${PWD}/test:/data \
  -v ${PWD}/config:/config \
  -e PUID=1000
  -e PGID=1000
  vergilgao/mdc:latest
```

### 环境变量配置（过时）

当没有映射mdc.ini文件时，本镜像也可以使用运行时的环境变量来完成自定义配置。
注意如果配置文件存在，环境变量的设置及修改将会**不起作用**，这意味着如果使用环境变量启动，程序只会应用**首次**启动容器时的环境变量，反复启动程序时，新修改的环境变量将**不起作用**。如果你的容器不是一次性的，请使用映射mdc.ini文件的方式启动。


```sh
docker run --rm -it \
  --name mdc_test \
  -v ${PWD}/test:/data \
  -e PUID=1000
  -e PGID=1000
  -e USE_PROXY=1 \
  -e PROXY_TYPE="socks5" \
  -e PROXY_URI="127.0.0.1:1080" \
  vergilgao/mdc:latest
```

注意，尽量将环境变量值包含在 `""`内，同时请勿再在环境变量中使用 `""`。

环境变量字段和原程序 `mdc.ini`文件的字段对应关系如下。

| 字段名                       | 原 ini 文件字段              | 值语义                           | 预设值                                               |
| :--------------------------- | :--------------------------- | :------------------------------- | :--------------------------------------------------- |
| MAIN_MODE                    | main_mode                    | 运行模式                         | 1                                                    |
| SOURCE_FOLDER                | source_folder                | 原影片输入目录                   | ./                                                   |
| FAILED_OUTPUT                | failed_output_folder         | 失败输出目录                     | failed                                               |
| SUCCESS_OUTPUT               | success_output_folder        | 成功输出目录                     | output                                               |
| SOFT_LINK                    | soft_link                    | 软连接模式                       | 0                                                    |
| FAILED_MOVE                  | failed_move                  | 移动失败刮削文件至失败输出文件夹 | 1                                                    |
| TRANSLATE                    | transalte_to_sc              | 翻译至简体中文                   | 1                                                    |
| MULTI_THREAD                 | multi_threading              | 多线程刮削                       | 1                                                    |
| USE_PROXY                    | switch                       | 开启代理                         | 0                                                    |
| PROXY_TYPE                   | type                         | 代理类型                         | socket5                                              |
| PROXY_URI                    | proxy                        | 代理地址                         | ""                                                   |
| CACERT_FILE                  | cacert_file                  | 证书文件                         | ""                                                   |
| TIMEOUT                      | timeout                      | 刮削超时时间/秒                  | 5                                                    |
| RETRY                        | retry                        | 重试次数                         | 3                                                    |
| NFO_SKIP_DAYS                | nfo_skip_days                | NFO过期时间/天                   | 30                                                   |
| STOP_COUNTER                 | stop_counter                 | 文件刮削失败站点封禁阈值         | 0                                                    |
| IGNORE_FAILED_LIST           | ignore_failed_list           | 刮削失败文件开关                 | 0                                                    |
| DOWNLOAD_ONLY_MISSING_IMAGES | download_only_missing_images | 下载已刮削影片缺失信息           | 1                                                    |
| MAPPING_TABLE_VALIDITY       | mapping_table_validity       | 对照表重下载阈值/天              | 7                                                    |
| LOCATION_RULE                | location_rule                | 文件目录命名规则                 | "actor+'/'+number"                                   |
| NAMING_RULE                  | naming_rule                  | nfo文件中影片命名规则            | "number+'-'+title"                                   |
| MAX_TITLE_LEN                | max_title_len                | 最大标题长度                     | 50                                                   |
| PRIORITY_WEBSITE             | website                      | 刮削数据网站                     | 与源仓库相同                                         |
| ESCAPE_FOLDERS               | folders                      | 排除目录                         | FAILED_OUTPUT,SUCCESS_OUTPUT                         |
| ESCAPE_LITERALS              | literals                     | 去除文件名中的特殊符号           | "\()/"                                               |
| WATERMARK                    | switch                       | 水印开关                         | 0                                                    |
| WATERMARK_POSITION           | water                        | 水印位置                         | 2                                                    |
| EXTRAFANART                  | switch                       | 剧照开关                         | 0                                                    |
| EXTRAFANART_FOLDER           | extrafanart_folder           | 剧照文件夹                       | extrafanart                                          |
| DEBUG                        | switch                       | 测试输出                         | 0                                                    |
| STORYLINE_SWITCH             | switch                       | 剧情简介抓取开关                 | 1                                                    |
| STORYLINE_SITE               | site                         | 剧情简介站点                     | 1:avno1,4:airavwiki                                  |
| STORYLINE_CENSORED_SITE      | censored_site                | 剧情简介站点（有码）             | 2:airav,5:xcity,6:amazon                             |
| STORYLINE_UNCENSORED_SITE    | uncensored_site              | 剧情简介站点（无码）             | 3:58avgo                                             |
| STORYLINE_RUN_MODE           | run_mode                     | 运行模式                         | 1                                                    |
| STORYLINE_SHOW_RESULT        | show_result                  | 剧情简介调试信息                 | 0                                                    |
| CC_CONVERT_MODE              | mode                         | 繁简转换开关                     | 1                                                    |
| CC_CONVERT_VARS              | vars                         | 需转换的元数据                   | actor,director,label,outline,series,studio,tag,title |
| JAVDB_SITES                  | sites                        | javdb域名后缀                    | 33,34                                                |

注：水印位置定义，左上 0, 右上 1, 右下 2， 左下 3

## 夜间构建版本

本仓库每周一次使用当时的最新上游源码构建，tag为nightly，你可以选择拉取`vergilgao/mdc:nightly`和`ghcr.io/vergilgao/mdc:nightly`进行测试，
注意此tag仅用于测试，并不保证会更新至最新源码，更不保证功能的稳定性。

## 构建（开发人员）

```sh
cd docker-mdc
docker build -t mdc --build-arg MDC_VERSION="6.0.1" ./

mkdir test
dd if=/dev/zero of="./test/MIFD-046.mp4" bs=250MB count=1
docker run --rm --name mdc_test -it -v ${PWD}/test:/data -e PUID=$(stat -c %u test) -e PGID=$(stat -c %g test) vergilgao/mdc:latest
```

## 申明

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
