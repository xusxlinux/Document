[携程开源的阿波罗](https://github.com/ctripcorp/apollo)
[数据库脚本下载地址](https://raw.githubusercontent.com/ctripcorp/apollo/1.5.1/scripts/db/migration/configdb/V1.0.0__initialization.sql)

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

下载sql脚本
wget https://raw.githubusercontent.com/ctripcorp/apollo/1.5.1/scripts/db/migration/configdb/V1.0.0__initialization.sql -O apolloconfig.sql

导入sql
mysql -uroot -p < /mnt/apollo-v1.5.1/apolloconfig.sql

创建授权账号,授权IP必须是做SNAT优化后的IP,没做优化，使用的是本地内网IP
grant INSERT,DELETE,UPDATE,SELECT on ApollConfigDB.* to 'apolloconfig'@'172.7.0.%' identified by '123456';

修改初始化数据
update ApolloConfigDB.ServerConfig set ServerConfig.Value="http://config.od.com/eureka" where ServerConfig.Key="eureka.service.url";



