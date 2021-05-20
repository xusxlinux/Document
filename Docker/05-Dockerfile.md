``` dockerfile
FROM                指定基础镜像本地或者远端仓库拥有的


RUN                 执行命令行命令,run指令在定制镜像时最常用的.每一个RUN的运行,就会新建立一层,commit这层的修改
                    shell格式   RUN apt-get update && apt-get install curl -y
				RUN buildDeps='curl net-toos' \
				&& apt-get update \
				&& apt-get install -y $buildDeps \
				&& mkdir -p /usr/local/xusx
		    exec格式    RUN ["可执行文件","参数1","参数2"]


COPY                COPY 指令将构建上下文目录中的文件复制到新的一层镜像内
                    可以是容器内的绝对路径,也可以是 WORKDIR 指令来指定.如果路径不存在,复制文件前先行创建目录
                    可以改变 所属用户 和 所属组      --chown=<user>:<group>
		        $ cat Dockerfile
                        FROM nginx:1.15.3
                        COPY --chown=nginx:nginx hello.txt /root/


ADD                 添加的路径可以是一个URL,这种情况Docker引擎会下载这个链接放到 目标路径 设置权限600
                    可以修改权限, 额外的一层 RUN 指令进行权限调整
                    ADD 有着更复杂的功能, 会解压gzip,tar,bzip2,xz等, 到目标路径中.希望不解压使用 COPY 指令
		       $ cat Dockerfile
                       FROM nginx:1.15.3
                       ADD helloworld.tar.gz /root/


CMD                 shell格式        CMD <命令>
                    exec格式         CMD ["可执行文件","参数1","参数2"...]
		    参数列表格式     CMD ["参数1","参数2"...]  在指定了 ENTRYPOIN指令后,用 CMD 指定具体的参数
		    执行 /bin/echo 123 能执行  ENTRYPOINT则不能 执行 /bin/echo 123


ENTRYPOINT          ADD entrypoint.sh /entrypoint.sh	# 需要加上执行权限 chmod +x entrypoint.sh
		    ENTRYPOINT /entrypoint.sh


ENV                 ENV VER 1.16.1-3.el7.x86_64
		    RUN yum install epel-release -y && yum install nginx-$VER -y

ARG


VOLUME


EXPOSE              声明运行时容器提供服务端的口,将容器的对应端口服务,公开给外界访问


WORKDIR             如果需要改变以后各层的工作目录位置,那么应该使用 WORKDIR 指令


USER                帮助切换到指定用户,这个用户需要事先建立好。切换用户后,会以该用户身份执行 RUN CMD ENTRYPOINT这类命令的身份


HEALTHCHECK


ONBUILD
```



``` dockerfile
简单的Dockerfile
$ vim Dockerfile 
FROM nginx:1.15.3
USER nginx
WORKDIR /usr/share/nginx/html

使用docker命令构建镜像
$ docker build . -t docker.io/xusx/nginx:v1.15.3

进入容器
$ docker run -it -p 84:80 --name nginx4 xusx/nginx:v1.15.3 /bin/bash

只有这个路径是权限被改为nginx
$ nginx@d0e5da79c4ad:/usr/share/nginx/html$ pwd
/usr/share/nginx/html
$ nginx@d0e5da79c4ad:/usr/share/nginx/html$ whoami 
nginx
```


``` dockerfile
# 在centos7的镜像中安装bind9
cat /data/dockerfile/Dockerfile 
FROM centos:7
ENV VER 9.11.4-26.P2.el7_9.5.x86_64
USER root
RUN yum install bind-$VER -y
```


``` shell
# 运行
dockerfile]# docker build . -t harbor.chain.com/public/centos7_bind9:v0.0.1
dockerfile]# docker build -f Dockerfile -t harbor.chain.com/public/centos7_bind9:v0.0.1 .

```


```
# 验证
# docker run -it --rm harbor.chain.com/public/centos7_bind9:v0.0.1 /bin/bash

[root@eb9f380bb09a /]# cat /etc/redhat-release 
CentOS Linux release 7.9.2009 (Core)

[root@eb9f380bb09a /]# printenv 
HOSTNAME=eb9f380bb09a
TERM=xterm
LS_COLORS=rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=01;05;37;41:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.axv=01;35:*.anx=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=01;36:*.au=01;36:*.flac=01;36:*.mid=01;36:*.midi=01;36:*.mka=01;36:*.mp3=01;36:*.mpc=01;36:*.ogg=01;36:*.ra=01;36:*.wav=01;36:*.axa=01;36:*.oga=01;36:*.spx=01;36:*.xspf=01;36:
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
PWD=/
SHLVL=1
HOME=/root
VER=9.11.4-26.P2.el7_9.5.x86_64
```



``` dockerfile
# entrypoint的使用
# cat /data/dockerfile/Dockerfile 
FROM centos:7
ENV VER 1.16.1-3.el7.x86_64
RUN yum install epel-release -y && yum install nginx-$VER -y
ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT /entrypoint.sh

# cat /data/dockerfile/entrypoint.sh 
#!/bin/env bash
/sbin/nginx -g "daemon off;"

加上执行权限
chmod +x entrypoint.sh
```


``` Dockerfile
# 制作一个可以访问的nginx镜像
cat /data/dockerfile/Dockerfile 
FROM nginx:1.16
USER root
ENV WWW /usr/share/nginx/html
ENV CONF /etc/nginx/conf.d
ENV TZ Asia/Shanghai
WORKDIR $WWW
ADD index.html $WWW/index.html
ADD daemon.chain.com.conf $CONF/daemon.chain.com.conf;
EXPOSE 80
CMD ["nginx","-g","daemon off;"]



cat daemon.chain.com.conf 
server {
	listen 80;
	server_name daemon.chain.com;
	location / {
		root /usr/share/nginx/html;
		index index.html;
	}
}
```
