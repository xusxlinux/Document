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

```
下载sql脚本
wget https://raw.githubusercontent.com/ctripcorp/apollo/1.5.1/scripts/db/migration/configdb/V1.0.0__initialization.sql -O apolloconfig.sql

导入sql
mysql -uroot -p < /mnt/apollo-v1.5.1/apolloconfig.sql

创建授权账号,授权IP必须是做SNAT优化后的IP,没做优化，使用的是本地内网IP
grant INSERT,DELETE,UPDATE,SELECT on ApollConfigDB.* to 'apolloconfig'@'172.7.0.%' identified by '123456';

修改初始化数据
update ApolloConfigDB.ServerConfig set ServerConfig.Value="http://config.od.com/eureka" where ServerConfig.Key="eureka.service.url";
```

```
$ cat /var/named/od.com.zone 
$ORIGIN od.com.
$TTL 600        ; 10 minutes
@               IN SOA  dns.od.com. dnsadmin.od.com. (
                                2019111009 ; serial
                                10800      ; refresh (3 hours)
                                900        ; retry (15 minutes)
                                604800     ; expire (1 week)
                                86400      ; minimum (1 day)
                                )
                                NS   dns.od.com.
$TTL 60 ; 1 minute
dns                A    10.4.7.11
harbor             A    10.4.7.200
traefik            A    10.4.7.10
k8s-yaml           A    10.4.7.200
dashboard          A    10.4.7.10
zk1                A    10.4.7.11
zk2                A    10.4.7.12
zk3                A    10.4.7.21
jenkins            A    10.4.7.10
dubbo-monitor      A    10.4.7.10
demo               A    10.4.7.10
config             A    10.4.7.10
mysql              A    10.4.7.11


dig -t A config.od.com @10.4.7.11 +short   这个IP地址是192.168.0.2上一层DNS 同样可以查询到
dig -t A config.od.com @92.168.0.2 +short
```

[下载1.5.1版本ConfigService软件包](https://github.com/ctripcorp/apollo/releases/download/v1.5.1/apollo-configservice-1.5.1-github.zip)  
```
wget https://github.com/ctripcorp/apollo/releases/download/v1.5.1/apollo-configservice-1.5.1-github.zip

mkdir -pv /data/dockerfile/apollo-configservice

unzip -o apollo-configservice-1.5.1-github.zip -d /data/dockerfile/apollo-configservice

sed -i "s#fill-in-the-correct-server#mysql.od.com#g" /data/dockerfile/apollo-configservice/config/application-github.properties 
sed -i "s#FillInCorrectPassword#123456#g" /data/dockerfile/apollo-configservice/config/application-github.properties 
sed -i "s#FillInCorrectUser#apolloconfig#g" /data/dockerfile/apollo-configservice/config/application-github.properties 
```

[修改启动脚本startup.sh](https://github.com/ctripcorp/apollo/blob/1.5.1/scripts/apollo-on-kubernetes/apollo-config-server/scripts/startup-kubernetes.sh)  
```
$ cat /data/dockerfile/apollo-configservice/scripts/startup.sh
APOLLO_CONFIG_SERVICE_NAME=$(hostname -i)
```


