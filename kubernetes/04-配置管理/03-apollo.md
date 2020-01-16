[携程开源的阿波罗](https://github.com/ctripcorp/apollo)

```
mariadb数据库源
$ cat /etc/yum.repos.d/MariaDB.repo
[mariadb]
name = MariaDB
baseurl = https://mirrors.ustc.edu.cn/mariadb/yum/10.1/centos7-amd64/
gpgkey=https://mirrors.ustc.edu.cn/mariadb/yum/RPM-GPG-KEY-MariaDB
gpgcheck=1

导入GPG-KEY
$ rpm --import https://mirrors.ustc.edu.cn/mariadb/yum/RPM-GPG-KEY-MariaDB

$ yum clean all
$ yum makecache
$ yum list mariadb-server --show-duplicates
$ yum install MariaDB-server -y

配置数据库
$ cat /etc/my.cnf.d/mysql-clients.cnf
[mysql]
default-character-set = utf8mb4

$ cat /etc/my.cnf.d/server.cnf
[mysqld]
character_set_server = utf8mb4
collation_server = utf8mb4_general_ci
init_connect = "SET NAMES 'utf8mb4'"
```
