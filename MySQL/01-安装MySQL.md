#### 简单安装MySQL
- [MySQL 二进制包 下载地址](https://downloads.mysql.com/archives/community/)
``` shell
mkdir -pv /mysql/3306/{app,conf,data,logs,tmp,binlog,redo}
tar -xf mysql-5.7.30-linux-glibc2.12-x86_64.tar.gz -C /mysql/3306/app/

# 需要注意MySQL文件夹的权限
useradd mysql -s /sbin/nologin -M
chown mysql.mysql -R /mysql

# 添加环境变量
export PATH="$PATH:/mysql/3306/app/mysql/bin"

# 创建MySQL配置文件
vim /mysql/3306/conf/my.cnf
ln -vs /mysql/3306/conf/my.cnf /etc/my.cnf

# 初始化MySQL
mysqld --initialize --user=mysql --basedir=/mysql/3306/app/mysql --datadir=/mysql/3306/data

# 密码文件
tail -1 /mysql/3306/logs/hdss7-200.host.com-error.err

# 修改密码
mysql -uroot -p
Alter USER 'root'@'localhost' IDENTIFIED BY '123456';
set password='123456';
flush privileges

# 手动启动和停止
nohup mysqld_safe --defaults-file=/etc/my.cnf &
mysqladmin -uroot -p 123456 shutdown -S /mysql/3306/tmp/mysql.sock

# 创建CentOS Linux启停脚本
systemctl start mysqld.service 

# 卸载MySQL数据库
systemctl stop mysqld.service 
rm -rf /mysql*
```
- 检验一下
``` sql
use mysql
select host,user from user where user='root';
create USER 'root'@'10.4.7.%' IDENTIFIED BY '123456';
select host,user from user where user='root';
```

- MySQL配置文件
  - vim /mysql/data/3306/my.cnf
``` cnf
[client]
default-character-set                  = utf8

[mysql]
default-character-set                  = utf8
socket                                 = /mysql/3306/tmp/mysql.sock

[mysqld]
#skip-name-resolve
#skip-grant-tables
port                                   = 3306
socket                                 = /mysql/3306/tmp/mysql.sock
basedir                                = /mysql/3306/app/mysql
datadir                                = /mysql/3306/data
tmpdir                                 = /mysql/3306/tmp
pid-file                               = /mysql/3306/tmp/mysql.pid
server-id                              = 1
log-bin                                = /mysql/3306/binlog/mysql-bin
log_bin_index                          = /mysql/3306/binlog/mysql-bin.index
binlog_format                          = ROW
character-set-server                   = utf8
collation-server                       = utf8_general_ci
default-storage-engine                 = INNODB
innodb_buffer_pool_size                = 200M
innodb_data_file_path                  = ibdata1:10M:autoextend
innodb_log_group_home_dir              = /mysql/3306/redo
innodb_file_per_table                  = 1
max_allowed_packet                     = 16M
explicit_defaults_for_timestamp        = 1
log-output                             = FILE
general_log                            = ON
general_log_file                       = /mysql/3306/logs/linux-node-01.host.com-general.err
slow_query_log                         = ON
slow_query_log_file                    = /mysql/3306/logs/linux-node-01.host.com-slow.err
long_query_time                        = 10
log-error                              = /mysql/3306/logs/linux-node-01.host.com-error.err

```
- CentOS Linux 系统的启停配置文件
  - vim /usr/lib/systemd/system/mysqld.service 
``` shell
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
ExecStart=/mysql/3306/app/mysql/bin/mysqld --defaults-file=/mysql/3306/conf/my.cnf
LimitNOFILE = 65535
LimitNPROC = 65535
```
