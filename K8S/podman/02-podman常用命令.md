#### 安装podman工具
``` shell
# 其中包含了Podman、Buildah、Skopeo等全套容器工具集
dnf install container-tools -y
```

#### podman的常用命令
``` shell
podman pod                             容器组的管理工具, 称作pod
podman start/stop /restart             启动/停止/重启一个或多个正在运行的容器
podman exec                            进入容器执行命令
podman create                          创建一个新容器
podman run                             在新容器中运行命令
podman ps                              查看正在运行的容器

podman status                          显示一个或多个容器的资源使用统计的实时信息
podman cp                              在容器和本地文件系统之间复制文件
podman export                          克隆容器,把容器当前的样子完整复制下来，适合做容器状态的快照
podman import
podman load                            将tar存档中的文件加载到容器存储中
podman save                            克隆镜像, 把创建容器的那个模板(镜像)完整保存下来，适合分享软件包

podman search                          在注册表中搜索镜像
podman port                            列出容器的端口映射
podman pull                            从注册表中拉取镜像
podman push                            将镜像, 清单列表或镜像索引从本地存储推送到其他地方
podman system                          管理podman
podman tag                             向本地镜像添加标签

podman rm                              删除一个或多个容器
podman rmi                             删除一个或多个本地镜像

podman build                           使用containerfile构建容器镜像
podman commit                          根据更改的容器创建新图像
podman mount                           挂载一个工作容器的根文件系统
podman network                         管理podman CNI网络
podman login/logout                    登录/注销注册列表
podman logs                            显示容器日志

podman image                           管理镜像 
podman images                          列出本地存储中的镜像
podman info                            显示podman相关的系统信息
podman init                            初始化容器
podman inspect                         显示容器的镜像,网络,卷或pod的配置
podman kill                            杀死容器中的主进程

podman machine                         管理podman的虚拟机
podman manifest                        创建和管理清单列表和图形索引
podman pause                           暂停容器
podman play                            根据结构化输入文件播放容器, pod或卷
podman rename                          重命名现有容器
podman secret                          加密
podman attach                          附加到正在运行的容器
podman auto update                     根据其自动更新策略自动更新容器
podman completion                      生成shell完成脚本
podman container                       管理容器
podman diff                            检查容器或镜像文件系统上的更改
podman events                          监控podman事件
podman generate                        基于容器,pod或卷生成结构化数据
podman healthcheck                     管理容器的健康检查
podman history                         显示镜像的历史记录
```

#### 命令使用的案例
``` shell

```

