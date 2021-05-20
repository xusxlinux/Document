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


```
# 在centos7的镜像中安装bind9
cat /data/dockerfile/Dockerfile 
FROM centos:7
ENV VER 9.11.4-26.P2.el7_9.5.x86_64
USER root
RUN yum install bind-$VER -y
```


```
# 运行
dockerfile]# docker build . -t harbor.chain.com/public/centos7_bind9:v0.0.1

Sending build context to Docker daemon  3.072kB
Step 1/4 : FROM centos:7
7: Pulling from library/centos
2d473b07cdd5: Pull complete 
Digest: sha256:0f4ec88e21daf75124b8a9e5ca03c37a5e937e0e108a255d890492430789b60e
Status: Downloaded newer image for centos:7
 ---> 8652b9f0cb4c
Step 2/4 : ENV VER 9.11.4-26.P2.el7_9.5.x86_64
 ---> Running in 12eb1168f1ae
Removing intermediate container 12eb1168f1ae
 ---> fcfcc9171196
Step 3/4 : USER root
 ---> Running in edb9628e4996
Removing intermediate container edb9628e4996
 ---> 74a1cedf5760
Step 4/4 : RUN yum install bind-$VER -y
 ---> Running in 34c6e10e35b4
Loaded plugins: fastestmirror, ovl
Determining fastest mirrors
 * base: mirrors.tuna.tsinghua.edu.cn
 * extras: mirrors.tuna.tsinghua.edu.cn
 * updates: mirrors.tuna.tsinghua.edu.cn
Resolving Dependencies
--> Running transaction check
---> Package bind.x86_64 32:9.11.4-26.P2.el7_9.5 will be installed
--> Processing Dependency: bind-libs-lite(x86-64) = 32:9.11.4-26.P2.el7_9.5 for package: 32:bind-9.11.4-26.P2.el7_9.5.x86_64
--> Processing Dependency: bind-libs(x86-64) = 32:9.11.4-26.P2.el7_9.5 for package: 32:bind-9.11.4-26.P2.el7_9.5.x86_64
--> Processing Dependency: selinux-policy-base for package: 32:bind-9.11.4-26.P2.el7_9.5.x86_64
--> Processing Dependency: selinux-policy-base for package: 32:bind-9.11.4-26.P2.el7_9.5.x86_64
--> Processing Dependency: selinux-policy for package: 32:bind-9.11.4-26.P2.el7_9.5.x86_64
--> Processing Dependency: selinux-policy for package: 32:bind-9.11.4-26.P2.el7_9.5.x86_64
--> Processing Dependency: python-ply for package: 32:bind-9.11.4-26.P2.el7_9.5.x86_64
--> Processing Dependency: policycoreutils-python for package: 32:bind-9.11.4-26.P2.el7_9.5.x86_64
--> Processing Dependency: policycoreutils-python for package: 32:bind-9.11.4-26.P2.el7_9.5.x86_64
--> Processing Dependency: libselinux-utils for package: 32:bind-9.11.4-26.P2.el7_9.5.x86_64
--> Processing Dependency: libselinux-utils for package: 32:bind-9.11.4-26.P2.el7_9.5.x86_64
--> Processing Dependency: liblwres.so.160()(64bit) for package: 32:bind-9.11.4-26.P2.el7_9.5.x86_64
--> Processing Dependency: libisccfg.so.160()(64bit) for package: 32:bind-9.11.4-26.P2.el7_9.5.x86_64
--> Processing Dependency: libisccc.so.160()(64bit) for package: 32:bind-9.11.4-26.P2.el7_9.5.x86_64
--> Processing Dependency: libisc.so.169()(64bit) for package: 32:bind-9.11.4-26.P2.el7_9.5.x86_64
--> Processing Dependency: libdns.so.1102()(64bit) for package: 32:bind-9.11.4-26.P2.el7_9.5.x86_64
--> Processing Dependency: libbind9.so.160()(64bit) for package: 32:bind-9.11.4-26.P2.el7_9.5.x86_64
--> Processing Dependency: libGeoIP.so.1()(64bit) for package: 32:bind-9.11.4-26.P2.el7_9.5.x86_64
--> Running transaction check
---> Package GeoIP.x86_64 0:1.5.0-14.el7 will be installed
---> Package bind-libs.x86_64 32:9.11.4-26.P2.el7_9.5 will be installed
--> Processing Dependency: bind-license = 32:9.11.4-26.P2.el7_9.5 for package: 32:bind-libs-9.11.4-26.P2.el7_9.5.x86_64
---> Package bind-libs-lite.x86_64 32:9.11.4-26.P2.el7_9.5 will be installed
---> Package libselinux-utils.x86_64 0:2.5-15.el7 will be installed
---> Package policycoreutils-python.x86_64 0:2.5-34.el7 will be installed
--> Processing Dependency: policycoreutils = 2.5-34.el7 for package: policycoreutils-python-2.5-34.el7.x86_64
--> Processing Dependency: setools-libs >= 3.3.8-4 for package: policycoreutils-python-2.5-34.el7.x86_64
--> Processing Dependency: libsemanage-python >= 2.5-14 for package: policycoreutils-python-2.5-34.el7.x86_64
--> Processing Dependency: audit-libs-python >= 2.1.3-4 for package: policycoreutils-python-2.5-34.el7.x86_64
--> Processing Dependency: python-IPy for package: policycoreutils-python-2.5-34.el7.x86_64
--> Processing Dependency: libselinux-python for package: policycoreutils-python-2.5-34.el7.x86_64
--> Processing Dependency: libqpol.so.1(VERS_1.4)(64bit) for package: policycoreutils-python-2.5-34.el7.x86_64
--> Processing Dependency: libqpol.so.1(VERS_1.2)(64bit) for package: policycoreutils-python-2.5-34.el7.x86_64
--> Processing Dependency: libcgroup for package: policycoreutils-python-2.5-34.el7.x86_64
--> Processing Dependency: libapol.so.4(VERS_4.0)(64bit) for package: policycoreutils-python-2.5-34.el7.x86_64
--> Processing Dependency: checkpolicy for package: policycoreutils-python-2.5-34.el7.x86_64
--> Processing Dependency: libqpol.so.1()(64bit) for package: policycoreutils-python-2.5-34.el7.x86_64
--> Processing Dependency: libapol.so.4()(64bit) for package: policycoreutils-python-2.5-34.el7.x86_64
---> Package python-ply.noarch 0:3.4-11.el7 will be installed
---> Package selinux-policy.noarch 0:3.13.1-268.el7_9.2 will be installed
---> Package selinux-policy-minimum.noarch 0:3.13.1-268.el7_9.2 will be installed
--> Running transaction check
---> Package audit-libs-python.x86_64 0:2.8.5-4.el7 will be installed
---> Package bind-license.noarch 32:9.11.4-26.P2.el7 will be updated
---> Package bind-license.noarch 32:9.11.4-26.P2.el7_9.5 will be an update
---> Package checkpolicy.x86_64 0:2.5-8.el7 will be installed
---> Package libcgroup.x86_64 0:0.41-21.el7 will be installed
---> Package libselinux-python.x86_64 0:2.5-15.el7 will be installed
---> Package libsemanage-python.x86_64 0:2.5-14.el7 will be installed
---> Package policycoreutils.x86_64 0:2.5-34.el7 will be installed
---> Package python-IPy.noarch 0:0.75-6.el7 will be installed
---> Package setools-libs.x86_64 0:3.3.8-4.el7 will be installed
--> Finished Dependency Resolution

Dependencies Resolved

================================================================================
 Package                  Arch     Version                      Repository
                                                                           Size
================================================================================
Installing:
 bind                     x86_64   32:9.11.4-26.P2.el7_9.5      updates   2.3 M
Installing for dependencies:
 GeoIP                    x86_64   1.5.0-14.el7                 base      1.5 M
 audit-libs-python        x86_64   2.8.5-4.el7                  base       76 k
 bind-libs                x86_64   32:9.11.4-26.P2.el7_9.5      updates   157 k
 bind-libs-lite           x86_64   32:9.11.4-26.P2.el7_9.5      updates   1.1 M
 checkpolicy              x86_64   2.5-8.el7                    base      295 k
 libcgroup                x86_64   0.41-21.el7                  base       66 k
 libselinux-python        x86_64   2.5-15.el7                   base      236 k
 libselinux-utils         x86_64   2.5-15.el7                   base      151 k
 libsemanage-python       x86_64   2.5-14.el7                   base      113 k
 policycoreutils          x86_64   2.5-34.el7                   base      917 k
 policycoreutils-python   x86_64   2.5-34.el7                   base      457 k
 python-IPy               noarch   0.75-6.el7                   base       32 k
 python-ply               noarch   3.4-11.el7                   base      123 k
 selinux-policy           noarch   3.13.1-268.el7_9.2           updates   498 k
 selinux-policy-minimum   noarch   3.13.1-268.el7_9.2           updates   7.0 M
 setools-libs             x86_64   3.3.8-4.el7                  base      620 k
Updating for dependencies:
 bind-license             noarch   32:9.11.4-26.P2.el7_9.5      updates    91 k

Transaction Summary
================================================================================
Install  1 Package  (+16 Dependent packages)
Upgrade             (  1 Dependent package)

Total download size: 16 M
Downloading packages:
Delta RPMs disabled because /usr/bin/applydeltarpm not installed.
warning: /var/cache/yum/x86_64/7/base/packages/audit-libs-python-2.8.5-4.el7.x86_64.rpm: Header V3 RSA/SHA256 Signature, key ID f4a80eb5: NOKEY
Public key for audit-libs-python-2.8.5-4.el7.x86_64.rpm is not installed
Public key for bind-libs-9.11.4-26.P2.el7_9.5.x86_64.rpm is not installed
--------------------------------------------------------------------------------
Total                                              620 kB/s |  16 MB  00:25     
Retrieving key from file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
Importing GPG key 0xF4A80EB5:
 Userid     : "CentOS-7 Key (CentOS 7 Official Signing Key) <security@centos.org>"
 Fingerprint: 6341 ab27 53d7 8a78 a7c2 7bb1 24c6 a8a7 f4a8 0eb5
 Package    : centos-release-7-9.2009.0.el7.centos.x86_64 (@CentOS)
 From       : /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
  Installing : GeoIP-1.5.0-14.el7.x86_64                                   1/19 
  Installing : libselinux-utils-2.5-15.el7.x86_64                          2/19 
  Installing : policycoreutils-2.5-34.el7.x86_64                           3/19 
  Installing : selinux-policy-3.13.1-268.el7_9.2.noarch                    4/19 
  Updating   : 32:bind-license-9.11.4-26.P2.el7_9.5.noarch                 5/19 
  Installing : 32:bind-libs-lite-9.11.4-26.P2.el7_9.5.x86_64               6/19 
  Installing : 32:bind-libs-9.11.4-26.P2.el7_9.5.x86_64                    7/19 
  Installing : libcgroup-0.41-21.el7.x86_64                                8/19 
  Installing : setools-libs-3.3.8-4.el7.x86_64                             9/19 
  Installing : audit-libs-python-2.8.5-4.el7.x86_64                       10/19 
  Installing : checkpolicy-2.5-8.el7.x86_64                               11/19 
  Installing : python-IPy-0.75-6.el7.noarch                               12/19 
  Installing : libselinux-python-2.5-15.el7.x86_64                        13/19 
  Installing : libsemanage-python-2.5-14.el7.x86_64                       14/19 
  Installing : policycoreutils-python-2.5-34.el7.x86_64                   15/19 
  Installing : selinux-policy-minimum-3.13.1-268.el7_9.2.noarch           16/19 
  Installing : python-ply-3.4-11.el7.noarch                               17/19 
  Installing : 32:bind-9.11.4-26.P2.el7_9.5.x86_64                        18/19 
  Cleanup    : 32:bind-license-9.11.4-26.P2.el7.noarch                    19/19 
  Verifying  : GeoIP-1.5.0-14.el7.x86_64                                   1/19 
  Verifying  : python-ply-3.4-11.el7.noarch                                2/19 
  Verifying  : 32:bind-libs-9.11.4-26.P2.el7_9.5.x86_64                    3/19 
  Verifying  : 32:bind-libs-lite-9.11.4-26.P2.el7_9.5.x86_64               4/19 
  Verifying  : libsemanage-python-2.5-14.el7.x86_64                        5/19 
  Verifying  : 32:bind-license-9.11.4-26.P2.el7_9.5.noarch                 6/19 
  Verifying  : libselinux-python-2.5-15.el7.x86_64                         7/19 
  Verifying  : python-IPy-0.75-6.el7.noarch                                8/19 
  Verifying  : selinux-policy-minimum-3.13.1-268.el7_9.2.noarch            9/19 
  Verifying  : checkpolicy-2.5-8.el7.x86_64                               10/19 
  Verifying  : libselinux-utils-2.5-15.el7.x86_64                         11/19 
  Verifying  : policycoreutils-python-2.5-34.el7.x86_64                   12/19 
  Verifying  : selinux-policy-3.13.1-268.el7_9.2.noarch                   13/19 
  Verifying  : audit-libs-python-2.8.5-4.el7.x86_64                       14/19 
  Verifying  : setools-libs-3.3.8-4.el7.x86_64                            15/19 
  Verifying  : 32:bind-9.11.4-26.P2.el7_9.5.x86_64                        16/19 
  Verifying  : libcgroup-0.41-21.el7.x86_64                               17/19 
  Verifying  : policycoreutils-2.5-34.el7.x86_64                          18/19 
  Verifying  : 32:bind-license-9.11.4-26.P2.el7.noarch                    19/19 

Installed:
  bind.x86_64 32:9.11.4-26.P2.el7_9.5                                           

Dependency Installed:
  GeoIP.x86_64 0:1.5.0-14.el7                                                   
  audit-libs-python.x86_64 0:2.8.5-4.el7                                        
  bind-libs.x86_64 32:9.11.4-26.P2.el7_9.5                                      
  bind-libs-lite.x86_64 32:9.11.4-26.P2.el7_9.5                                 
  checkpolicy.x86_64 0:2.5-8.el7                                                
  libcgroup.x86_64 0:0.41-21.el7                                                
  libselinux-python.x86_64 0:2.5-15.el7                                         
  libselinux-utils.x86_64 0:2.5-15.el7                                          
  libsemanage-python.x86_64 0:2.5-14.el7                                        
  policycoreutils.x86_64 0:2.5-34.el7                                           
  policycoreutils-python.x86_64 0:2.5-34.el7                                    
  python-IPy.noarch 0:0.75-6.el7                                                
  python-ply.noarch 0:3.4-11.el7                                                
  selinux-policy.noarch 0:3.13.1-268.el7_9.2                                    
  selinux-policy-minimum.noarch 0:3.13.1-268.el7_9.2                            
  setools-libs.x86_64 0:3.3.8-4.el7                                             

Dependency Updated:
  bind-license.noarch 32:9.11.4-26.P2.el7_9.5                                   

Complete!
Removing intermediate container 34c6e10e35b4
 ---> 9e8ba121c895
Successfully built 9e8ba121c895
Successfully tagged harbor.chain.com/public/centos7_bind9:v0.0.1
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
