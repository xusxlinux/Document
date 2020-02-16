> $ kubectl create ns test  


> $ kubectl create secret docker-registry harbor --docker-server=harbor.od.com --docker-username=admin --docker-password=123456 -n test

#### 修改sql创建test库
```
CREATE DATABASE IF NOT EXISTS ApolloConfigTestDB DEFAULT CHARACTER SET = utf8mb4;
Use ApolloConfigTestDB;

update ApolloConfigTestDB.ServerConfig set ServerConfig.Value="http://config-test.od.com/eureka" where ServerConfig.Key="eureka.service.url";

grant INSERT,DELETE,UPDATE,SELECT on ApolloConfigTestDB.* to "apolloconfig"@"10.4.7.%" identified by "123456";

use ApolloPortalDB
update ServerConfig set Value='fat,pro' where Id=1;
```


#### 修改资源配置清单
```
$ cat /data/k8s-yaml/apollo-portal/cm.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: apollo-portal-cm
  namespace: infra
data:
  application-github.properties: |
    # DataSource
    spring.datasource.url = jdbc:mysql://mysql.od.com:3306/ApolloPortalDB?characterEncoding=utf8
    spring.datasource.username = apolloportal
    spring.datasource.password = 123456
  app.properties: |
    appId=100003173
  apollo-env.properties: |
    fat.meta=http://config-test.od.com
    pro.meta=http://config-prod.od.com
```

#### 拷贝资源配置清单
```
mkdir -pv test/{apollo-configservice,apollo-adminservice,dubbo-demo-service,dubbo-demo-consumer}
cd /data/k8s-yaml/test/apollo-configservice
cp -r /data/k8s-yaml/apollo-configservice/* .
```

#### 修改名称空间
```
grep -n test *
cm.yaml:5:  namespace: test
cm.yaml:12:    eureka.service.url = http://config-test.od.com/eureka
dp.yaml:5:  namespace: test
ingress.yaml:5:  namespace: test
ingress.yaml:8:  - host: config-test.od.com
svc.yaml:5:  namespace: test
```

#### 做域名解析
```
$ cat /var/named/od.com.zone 

$ORIGIN od.com.
$TTL 600        ; 10 minutes
@               IN SOA  dns.od.com. dnsadmin.od.com. (
                                2019111014 ; serial
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
portal             A    10.4.7.10
zk-test            A    10.4.7.11
zk-prod            A    10.4.7.12
config-test        A    10.4.7.10
config-prod        A    10.4.7.10
```


## 拷贝资源配置清单修改adminservice
```
cp -r /data/k8s-yaml/apollo-adminservice/* /data/k8s-yaml/test/apollo-adminservice/

grep -in test *
cm.yaml:5:  namespace: test
cm.yaml:9:    spring.datasource.url = jdbc:mysql://mysql.od.com:3306/ApolloConfigTestDB?characterEncoding=utf8
```

## 数据库作弊
```
> use ApolloPortalDB
> truncate table App;
> truncate table Appnamespace;
```

![Image text](https://github.com/xusxlinux/Document/blob/master/kubernetes/100-images/11-apollo.png)
