# Movie Data Capture - Docker

[github](https://github.com/VergilGao/docker-mdc) [![GitHub stars](https://img.shields.io/github/stars/VergilGao/docker-mdc)](https://github.com/VergilGao/docker-mdc/stargazers) | [dockerhub](https://hub.docker.com/r/vergilgao/mdc)

![release](https://github.com/VergilGao/docker-mdc/workflows/release/badge.svg) [![GitHub license](https://img.shields.io/github/license/VergilGao/docker-mdc)](https://github.com/VergilGao/docker-mdc/blob/master/LICENSE)

**数据无价，请谨慎操作！**

**数据无价，请谨慎操作！**

**数据无价，请谨慎操作！**

重要的事情说三遍。

`Movie_Data_Capture` 以下简称 `mdc`是一款由[yoshiko2](https://github.com/yoshiko2)使用 `python3`编写的成人影片刮削器。

本镜像能帮助用户在nas中无需安装运行时环境，可以更简单的使用 `mdc`。

本仓库针对 `unraid`系统做出了特别优化，对于 `unraid`用户，本镜像的默认配置即可避免权限问题。对于其他nas系统用户，请按照各自的系统权限策略设置 `UID` `GID` `UMASK`三个环境变量。

本镜像从仓库[Movie_Data_Capture](https://github.com/yoshiko2/movie_data_Capture)构建，因为本人工作较忙，很可能不会及时和上游release同步。

* **注意，因为docker文件系统的特殊性，请仔细阅读以下操作指南后再行使用。**
* **镜像作者[VergilGao](https://github.com/VergilGao) [yoshiko2](https://github.com/yoshiko2)对使用此镜像导致的文件丢失、损坏均不负责。**
* **6.2.1版本有功能性BUG，已被上游作者废置，请酌情使用**

## 更新日志

20230523:

* 同步至上游 6.6.3
* 基础镜像修改为 debian11
* 移除 arm64 支持

因为上游人脸识别模块需要的依赖在 arm64 架构下需要编译，本人不擅长编译 pip 模块，所以放弃了 arm64 架构的维护。

20220529：

* 修复root用户运行

20220528：

* 更新至上游6.2.2版本
* 修复人脸识别未生效的问题
* 通过环境变量启动程序的方法已经废弃，程序将在启动时检测是否存在配置文件，如果不存在，将会在config映射目录下创建，并且退出。请修改配置文件后再次启动程序。**Breaking Change!**
* 环境变量`PUID`,`PGID`已经修改为`UID` `GID`**Breaking Change!**
* `UMASK`的默认值改为`002`**Breaking Change!**

20220312:

* 新增自定义配置文件功能，你现在可以使用自己编写的配置文件来运行程序了！请映射 `mdc.ini` 文件至 `/config/mdc.ini` 目录，程序会自动判断是否存在配置文件。如果配置文件存在，环境变量的设置及修改将会**不起作用**，这意味着如果使用环境变量启动，程序只会应用**首次**启动容器时的环境变量，反复启动程序时，新修改的环境变量将**不起作用**。如果你的容器不是一次性的，请使用映射mdc.ini文件的方式启动。
* 新增环境变量 `TZ`，默认值为 `Asia/Shanghai`，这将设置容器内的时间区域。
* 新增环境变量 `UMASK`，修改 `PUID`和 `PGID`的默认值，目前的默认值为 `PUID=99, PGID=100 UMASK=000`，此为 `UNRAID`系统用户的推荐配置，其他系统仍然需要自行修改以防止出现权限问题。
* 删除 `s6-overlay`驱动，权限问题将通过 `su`命令解决，因此，本镜像的 `PUID`和 `PGID`环境变量事实上等同于 `UID`和 `GID`，为了保持兼容性，环境变量名不再修改。
* 新增[ghcr.io](https://github.com/VergilGao/docker-mdc/pkgs/container/mdc)镜像仓库，此仓库只有 `vergilgao/mdc`，同时dockerhub镜像仓库将继续保持 `vergilgao/avdc`和 `vergilgao/mdc`两个地址的更新。
* 提升tag丰富度，将上游版本号按 `{major}.{minor}.{build}`拆分更新，同时新增一个定义为 `{version}-r{release_count}`的tag，用于标识同一个上游release下docker版本的更新次数。
* 新增夜间构建tag，只会推送到 `vergilgao/mdc`和 `ghcr.io/vergilgao/mdc`，此tag将保持每周一次的更新频率，并不保证会更新至最新源码。

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
docker run --rm --name mdc_test -it -v ${PWD}/test:/data -v ${PWD}/config:/config -e UID=$(stat -c %u test) -e GID=$(stat -c %g test) ghcr.io/vergilgao/mdc:latest
```

然后你会看到如下输出：

```sh
---Setup Timezone to Asia/Shanghai---
---Checking if UID: 1000 matches user---
usermod: no changes
---Checking if GID: 1000 matches user---
usermod: no changes
---Setting umask to 002---
---Taking ownership of data...---
Checking if config file exist
Starting...
[*]================= Movie Data Capture =================
[*]                        6.2.1
[*]======================================================
[*] - Linux-5.4.0-110-generic-x86_64-with
[*] - x86_64 - Python-3.9.13
[*]======================================================
[*] - 严禁在墙内宣传本项目 -
[*]======================================================
[+]Start at 2022-05-26 15:12:30
[+]Load Config file '/config/mdc.ini'.
[+]Main Working mode ## 1: Scraping ## , nfo_skip_days=30
[+]Find 1 movies.
[*]======================================================
[!]                - 100.% [1/1] -             15:12:31
[!] [MIFD-046] As Number Processing for '/data/御坂りあ/MIFD-046/MIFD-046.mp4'
[+]Find movie [MIFD-046] metadata on website 'javbus'
[+]Image Downloaded! MIFD-046-fanart.jpg
[+]Image Cutted!     MIFD-046-poster.jpg
[+]Wrote!            JAV_output/御坂りあ/MIFD-046/MIFD-046.nfo
[*]======================================================
[+]Deleting empty folder /data/JAV_output/御坂りあ/MIFD-046/extrafanart
[+]Deleting empty folder /data/failed
[+]Running time 0:00:17.748  End at 2022-05-26 15:12:47
[+]All finished!!!
Log file '/config/.mlogs/mdc_20220526T151229.txt' saved.
```

确认程序没有问题后把测试数据删掉就好了。

```sh
rm -rf test
```

## docker环境变量

本镜像增加了权限设置功能，你可以通过使用 UID (用户id) GID (组id) 两个环境变量来配置程序运行后所有文件的权限。

| 字段名 | 值语义          | 预设值        |
| :----- | :-------------- | :------------ |
| UID    | uid             | 99            |
| GID    | gid             | 100           |
| UMASK  | data目录的umask | 002           |
| TZ     | 容器内时间区域  | Asia/Shanghai |

## 程序运行时配置

### 映射mdc.ini文件

假设你的mdc.ini文件存放在当前目录的config子目录下。

```sh
docker run --rm -it \
  --name mdc_test \
  -v ${PWD}/test:/data \
  -v ${PWD}/config:/config \
  -e UID=1000 \
  -e GID=1000 \
  vergilgao/mdc:latest
```

程序将在启动时检测是否存在配置文件，如果不存在，将会在config映射目录下创建，并且退出。请修改配置文件后再次启动程序。

### 环境变量配置（已废弃）

## 夜间构建版本（已暂停）

本仓库每周一次使用当时的最新上游源码构建，tag为nightly，你可以选择拉取 `vergilgao/mdc:nightly`和 `ghcr.io/vergilgao/mdc:nightly`进行测试，注意此tag仅用于测试，并不保证会更新至最新源码，更不保证功能的稳定性。
此外，由于配置文件兼容性问题，默认情况下，夜间构建版本会忽略传入的配置文件环境变量，使用夜间构建版本强烈建议自行映射配置文件。

## 构建（开发人员，构建方式已经发生变化，等待补充修改）

```sh
cd docker-mdc
docker build -t mdc --build-arg MDC_VERSION="6.0.1" ./

mkdir test
dd if=/dev/zero of="./test/MIFD-046.mp4" bs=250MB count=1
docker run --rm --name mdc_test -it -v ${PWD}/test:/data -e UID=$(stat -c %u test) -e GID=$(stat -c %g test) vergilgao/mdc:latest
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
