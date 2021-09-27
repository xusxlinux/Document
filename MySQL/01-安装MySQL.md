#### 简单安装MySQL
- [MySQL 二进制包 下载地址](https://downloads.mysql.com/archives/community/)
``` shell
mkdir -pv /mysql/{app,data,logs}/3306
tar -xf mysql-5.7.25-linux-glibc2.12-x86_64.tar.gz -C /mysql/app/

useradd mysql -s /sbin/nologin -M
chown mysql.mysql -R /mysql

# 创建MySQL配置文件
vim /mysql/data/3306/my.cnf
ln -vs /mysql/data/3306/my.cnf /etc/my.cnf

# 初始化MySQL
mysqld --initialize --user=mysql --basedir=/mysql/app/mysql/ --datadir=/mysql/data/3306/data

# 密码文件
tail -1 /mysql/logs/3306/hdss7-200.host.com-error.err

# 修改密码
mysql -uroot -p
Alter USER 'root'@'localhost' IDENTIFIED BY '123456';

# 手动启动和停止
nohup mysqld_safe --defaults-file=/etc/my.cnf &
mysqladmin -uroot -p 123456 shutdown -S /mysql/data/3306/mysql.sock

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
[mysql]
default-character-set                  = utf8
socket                                 = /mysql/data/3306/mysql.sock

[mysqld]
#skip-name-resolve
#skip-grant-tables
port                                   = 3306
socket                                 = /mysql/data/3306/mysql.sock
basedir                                = /mysql/app/mysql
datadir                                = /mysql/data/3306/data
character-set-server                   = utf8
default-storage-engine                 = INNODB
innodb_buffer_pool_size                = 200M
max_allowed_packet                     = 16M
explicit_defaults_for_timestamp        = 1
log-output                             = FILE
general_log                            = 0
general_log_file                       = /mysql/logs/3306/hdss7-200.host.com-general.err
slow_query_log                         = No
slow_query_log                         = /mysql/logs/3306/hdss7-200.host.com-query.err
long_query_time                        = 10
log-error                              = /mysql/logs/3306/hdss7-200.host.com-error.err
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
ExecStart=/mysql/app/mysql/bin/mysqld --defaults-file=/mysql/data/3306/my.cnf
LimitNOFILE = 65535
LimitNPROC = 65535
```
