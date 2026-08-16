## jenkins 容器化安装部署

#### 步骤一
``` md
# 在hub.docker.com下载Jenkins镜像
[root@harbor ~]# docker pull crpi-r27qdou8boyf3zjk.cn-hangzhou.personal.cr.aliyuncs.com/xusx-images/jenkins:2.577

# 给下载的镜像打上标签
[root@harbor ~]# docker tag crpi-r27qdou8boyf3zjk.cn-hangzhou.personal.cr.aliyuncs.com/xusx-images/jenkins:2.577 harbor.od.com/public/jenkins:2.55

# 推送到自建的harbor私有仓库
[root@harbor ~]# docker push harbor.od.com/public/jenkins:2.55

# 创建Jenkins的Dockerfile目录
[root@harbor ~]# mkdir -pv /data/Dockerfile/jenkins/
[root@harbor ~]# cd /data/Dockerfile/jenkins/

# 拷贝私钥到, 让Jenkins可用连接gitlab.od.com
[root@harbor jenkins]# cp ~/.ssh/id_rsa .
# 拷贝密码文件, 让Jenkins可以拉取harbor.od.com私有镜像仓库上的镜像
[root@harbor jenkins]# cp ~/.docker/config.json .
# 下载docker安装包
- [docker下载地址](https://download.docker.com/linux/debian/dists/bookworm/pool/stable/amd64/)
[root@harbor jenkins]# wget https://download.docker.com/linux/debian/dists/bookworm/pool/stable/amd64/docker-ce-cli_24.0.0-1~debian.12~bookworm_amd64.deb
```

#### 步骤二
``` md
# 编写构建Jenkins的Dockerfile脚本
[root@harbor jenkins]# vim Dockerfile 

FROM harbor.od.com/public/jenkins:2.577

USER root

RUN /bin/cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo 'Asia/Shanghai' > /etc/timezone

ADD id_rsa /root/.ssh/id_rsa

ADD config.json /root/.docker/config.json

ADD containerd* docker-ce-cli* .

RUN echo "    StrictHostKeyChecking no" >> /etc/ssh/ssh_config && dpkg -i *.deb

# 构建Jenkins镜像
[root@harbor jenkins]# docker build . -t harbor.od.com/infra/jenkins:2.577
# 推送构建成功的镜像到infra仓库中
[root@harbor jenkins]# docker push harbor.od.com/infra/jenkins:2.577
``` 

#### 步骤三
``` md
# 创建Jenkins的挂载点, 并且需要把docker.sock挂载到Jenkins容器中
[root@harbor jenkins]# mkdir -pv /data/nfs-volume

# 运行镜像创建容器
docker run -it -d -p 8081:8080 --name jenkins \
	-v /data/nfs-volume:/var/jenkins_home \
	-v /run/docker.sock:/run/docker.sock \
	--health-cmd="curl -fsS http://jenkins.od.com/health/ || exit 1" \
	--health-start-period=20s \
	--health-interval=30s \
	--health-retries=3 \
	--restart=unless-stopped \
	harbor.od.com/infra/jenkins:2.577

# 容器启动后测试Jenkins与gitlab.od.com是否连接
[root@harbor jenkins]# docker exec -it jenkins ssh -i ~/.ssh/id_rsa -T git@gitlab.od.com
Welcome to GitLab, @root!

# 一个错误是因为,Jenkins本身需要跑在k8s集群中. 他会通过集群内的网络与gitlab.od.com通信. 现在单独的docker容器并没有与本地的gitlab.od.com建立通信, 所以需要在容器内添加一条主机名解析
# docker exec -it jenkins bash

# tee /etc/hosts << EOF
> 10.4.7.100  gitlab.od.com
> EOF
```
