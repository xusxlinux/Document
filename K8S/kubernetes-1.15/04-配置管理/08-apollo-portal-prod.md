> $ kubectl create ns prod  


> $ kubectl create secret docker-registry harbor --docker-server=harbor.od.com --docker-username=admin --docker-password=123456 -n prod

#### 修改sql创建prod库
```
CREATE DATABASE IF NOT EXISTS ApolloConfigProdDB DEFAULT CHARACTER SET = utf8mb4;
Use ApolloConfigProdDB;

update ApolloConfigProdDB.ServerConfig set ServerConfig.Value="http://config-prod.od.com/eureka" where ServerConfig.Key="eureka.service.url";

grant INSERT,DELETE,UPDATE,SELECT on ApolloConfigProdDB.* to "apolloconfig"@"10.4.7.%" identified by "123456";
```

#### 拷贝资源配置清单
```
mkdir -pv prod/{apollo-configservice,apollo-adminservice,dubbo-demo-service,dubbo-demo-consumer}
cd /data/k8s-yaml/test/apollo-configservice
cp -r /data/k8s-yaml/apollo-configservice/* .
```

#### 修改资源配置清单
```
grep -n prod *
cm.yaml:5:  namespace: prod
cm.yaml:12:    eureka.service.url = http://config-prod.od.com/eureka
dp.yaml:5:  namespace: prod
ingress.yaml:5:  namespace: prod
ingress.yaml:8:  - host: config-prod.od.com
svc.yaml:5:  namespace: prod
```

#### 拷贝资源配置清单修改adminservice
```
cp -r /data/k8s-yaml/apollo-adminservice/* /data/k8s-yaml/prod/apollo-adminservice/

grep -in prod *
cm.yaml:5:  namespace: prod
cm.yaml:9:    spring.datasource.url = jdbc:mysql://mysql.od.com:3306/ApolloConfigProdDB?characterEncoding=utf8
```
