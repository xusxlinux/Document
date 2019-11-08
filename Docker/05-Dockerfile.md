```
FROM                指定基础镜像本地或者远端仓库拥有的


RUN                 执行命令行命令,run指令在定制镜像时最常用的.每一个RUN的运行,就会新建立一层,commit这层的修改
                    shell格式   RUN apt-get update && apt-get install curl -y
				RUN buildDeps='curl net-toos' \
				&& apt-get update \
				&& apt-get install -y $buildDeps \
				&& mkdir -p /usr/local/xusx
		    exec格式    RUN ["可执行文件","参数1","参数2"]


COPY


ADD


CMD                 shell格式        CMD <命令>
                    exec格式         CMD ["可执行文件","参数1","参数2"...]
		    参数列表格式      CMD ["参数1","参数2"...]  在指定了 ENTRYPOIN指令后,用 CMD 指定具体的参数


ENTRYPOINT


ENV


ARG


VOLUME


EXPOSE              声明运行时容器提供服务端的口,将容器的对应端口服务,公开给外界访问


WORKDIR             如果需要改变以后各层的工作目录位置,那么应该使用 WORKDIR 指令


USER                帮助切换到指定用户,这个用户需要事先建立好。切换用户后,会以该用户身份执行 RUN CMD ENTRYPOINT这类命令的身份


HEALTHCHECK


ONBUILD
```



```
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
