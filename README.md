# 用更优雅的方式管理硬盘中的大姐姐们(测试版)

![publish](https://github.com/VergilGao/docker-avdc/workflows/publish/badge.svg) [![GitHub license](https://img.shields.io/github/license/VergilGao/docker-avdc)](https://github.com/VergilGao/docker-avdc/blob/master/LICENSE)

**数据无价，请谨慎操作！**

**数据无价，请谨慎操作！**

**数据无价，请谨慎操作！**

重要的事情说三遍。

`AV_Data_Capture` 以下简称`avdc`是一款由[yoshiko2](https://github.com/yoshiko2)使用`python`编写的日本AV刮削器。

本镜像能帮助用户在nas中无需安装复杂的`python`运行时环境，可以更简单的使用`avdc`。

本镜像从仓库[AV_Data_Capture](https://github.com/yoshiko2/AV_Data_Capture)构建，版本号和源仓库的release版本号统一，初始发布版本为`3.9.1`

* **注意，因为docker文件系统的特殊性，请仔细阅读以下操作指南后再行使用。**
* **镜像仍处于测试阶段，使用方法可能会出现较大变化。**
* **镜像作者[VergilGao](https://github.com/VergilGao)对使用此镜像导致的文件丢失、损坏均不负责。**
* **源作者[yoshiko2](https://github.com/yoshiko2)保留最终决定权和最终解释权**  
* **其他注意事项敬请参阅[源仓库的README](https://github.com/yoshiko2/AV_Data_Capture/blob/master/README.md)**

## 测试

首先你可以测试一下程序是否可用。

```sh
docker pull vergilgao/avdc:3.9.2
mkdir test
touch test/MIFD-046.mp4
docker run --name avdc_test -it -v ${PWD}/test:/app/data vergilgao/avdc:3.9.2
```
然后你会看到如下输出：
```sh
[*]================== AV Data Capture ===================
[*]                    Version 3.9.2
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
确认程序没有问题后把测试数据删掉就好了。顺便也删掉已经没有用了的测试容器:
```sh
sudo rm -rf test
docker rm avdc_test
```

## 自定义配置

与源程序不同，本镜像使用运行时的环境变量来完成自定义配置。

```sh
docker run -it \
	--name avdc_test \
	-v ${PWD}/test:/app/data \
	-e PROXY_TYPE="socks5" \
	-e PROXY_URI="127.0.0.1:1080" \ 
	vergilgao/avdc:3.9.2
```

注意，尽量将环境变量值包含在`""`内，同时请勿再在环境变量中使用`""`。

环境变量字段和原程序`config.ini`文件的字段对应关系如下。

| 字段名           | 原 ini 文件字段       | 值语义 | 预设值 |
| ---------------- | --------------------- | ------ | ------ |
| FAILED_OUTPUT    | failed_output_folder  |        |        |
| SUCCESS_OUTPUT   | success_output_folder |        |        |
| SOFT_LINK        | soft_link             |        |        |
| FAILED_MOVE      | failed_move           |        |        |
| TRANSLATE        | transalte_to_sc       |        |        |
| PROXY_TYPE       | type                  |        |        |
| PROXY_URI        | proxy                 |        |        |
| TIMEOUT          | timeout               |        |        |
| RETRY            | retry                 |        |        |
| LOCATION_RULE    | location_rule         |        |        |
| NAMING_RULE      | naming_rule           |        |        |
| MAX_TITLE_LEN    | max_title_len         |        |        |
| PRIORITY_WEBSITE | website               |        |        |
| ESCAPE_FOLDERS   | folders               |        |        |
| DEBUG            | switch                |        |        |

## TODO List

- [x] 将`config.ini`中的配置项改为环境变量
- [ ] 完善环境变量
