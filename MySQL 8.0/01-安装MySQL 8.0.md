## 下载MySQL 8.0 二进制安装包
[MySQL 8.0.27下载地址](https://downloads.mysql.com/archives/get/p/23/file/mysql-8.0.27-linux-glibc2.12-x86_64.tar)

## 删除系统自带的MySQL软件包,MySQL8.X和mariadb有冲突,需要卸载干净
``` shell
rpm -qa | grep mysql

rpm -qa | grep mariadb
rpm -e --nodeps mariadb-libs-5.5.68-1.el7.x86_64
```

## 准备工作
``` shell
# 创建用户和MySQL所需要的目录
useradd mysql -s /sbin/nologin -M
mkdir -pv /mysql/4131/{app,conf,data,logs,tmp,binlog,redo,relay}


# 解压二进制文件
tar xf mysql-8.0.27-linux-glibc2.12-x86_64.tar
rm -rf mysql-8.0.27-linux-glibc2.12-x86_64.tar
xz -d mysql-8.0.27-linux-glibc2.12-x86_64.tar.xz
tar xf mysql-8.0.27-linux-glibc2.12-x86_64.tar


# 放在标准位置
mv mysql-8.0.27-linux-glibc2.12-x86_64 /mysql/4131/app/mysql


# 创建配置文件
vim /mysql/4131/conf/my.cnf
ln -vs /mysql/4131/conf/my.cnf /etc/my.cnf


# 需要注意MySQL文件夹的权限
chown mysql.mysql -R /mysql
```
  - [MySQL 8.0单库](https://github.com/xusxlinux/Document/blob/master/MySQL%208.0/my.cnf/01-MySQL%208.0%E5%8D%95%E5%BA%93%E9%85%8D%E7%BD%AE.md)  
  - [MySQL 8.0主库](https://github.com/xusxlinux/Document/blob/master/MySQL%208.0/my.cnf/02-MySQL%208.0%E4%B8%BB%E5%BA%93%E9%85%8D%E7%BD%AE.md)  
  - [MySQL 8.0从库](https://github.com/xusxlinux/Document/blob/master/MySQL%208.0/my.cnf/03-MySQL%208.0%E4%BB%8E%E5%BA%93%E9%85%8D%E7%BD%AE.md)  
## 环境变量和初始化MySQL 8.0
``` shell
# 设置环境变量
vim /etc/profile
export PATH="$PATH:/mysql/4131/app/mysql/bin"
source /etc/profile

# 初始化MySQL8.0
mysqld --initialize --user=mysql --basedir=/mysql/4131/app/mysql --datadir=/mysql/4131/data
```

## 守护进程
``` shell
vim /usr/lib/systemd/system/mysqld.service

[Unit]
Description=MySQL Server
Documentation=man:mysqld(8)
Documentation=http://dev.mysql.com/doc/refman/en/using-systemd.html
After=network.target
After=syslog.target
[Install]
WantedBy=multi-user.target
[Service]
User=mysql
Group=mysql
ExecStart=/mysql/4131/app/mysql/bin/mysqld --defaults-file=/mysql/4131/conf/my.cnf
LimitNOFILE = 65535
LimitNPROC = 65535
```
