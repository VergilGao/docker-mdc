# docker-avdc

![publish](https://github.com/VergilGao/docker-avdc/workflows/publish/badge.svg) [![GitHub license](https://img.shields.io/github/license/VergilGao/docker-avdc)](https://github.com/VergilGao/docker-avdc/blob/master/LICENSE)

**数据无价，请谨慎操作！**

**数据无价，请谨慎操作！**

**数据无价，请谨慎操作！**

重要的事情说三遍。

`AV_Data_Capture` 以下简称`avdc`是一款由[yoshiko2](https://github.com/yoshiko2)使用`python`编写的日本AV刮削器。

本镜像能帮助用户在nas中更简单的使用`avdc`，为了保证您的数据安全，并且更高效的使用`avdc`，请务必遵循接下来的最佳实践。

本镜像从仓库[AV_Data_Capture](https://github.com/yoshiko2/AV_Data_Capture)构建，版本号和源仓库的release版本号统一，初始发布版本为`3.9.1`
* **注意，因为docker文件系统的特殊性，请仔细阅读以下操作指南后再行使用。**
* **镜像作者[VergilGao](https://github.com/VergilGao)对使用此镜像导致的文件丢失、损坏均不负责。**
* **源作者[yoshiko2](https://github.com/yoshiko2)保留最终决定权和最终解释权**  
* **其他注意事项敬请参阅[源仓库的README](https://github.com/yoshiko2/AV_Data_Capture/blob/master/README.md)**

## 最佳实践



首先，您要知晓`avdc`组织数据的方式。
`avdc`在组织数据的过程中，首先将已经刮削完成的视频文件按照`config.ini`中预设的规则硬链接到指定目录，然后再删除原文件，此后，再将原文件目录中余下的视频文件通过`mv`命令（或等同的方式）移动到`failed`目录（默认规则）。如果您对于linux系统和docker有所了解，就会知道此种数据组织方式具有潜在的问题。
所以，我在制作本镜像的过程中，也总结出了一套**最佳实践**，通过遵循**最佳实践**，您能最大限度的规避掉潜在问题，并且获得极佳的使用体验。

