```
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
