## xpack认证

#### 添加认证参数
- 开启`所有es节点`的配置  
  ``` shell
  vim /etc/elasticsearch/elasticsearch.yml

  xpack.security.enabled: true
  xpack.security.transport.ssl.enabled: true
  ```
- 配置完成后重启`所有es节点`
  ``` shell
  systemctl restart elasticsearch.service
  ```

#### 开始配置xpack
``` shell
# 切换到证书加密执行目录
[root@linux-node-01 ~]# cd /usr/share/elasticsearch/bin/

# 一路回车, 不需要设置密码
[root@linux-node-01 bin]# ./elasticsearch-certutil ca
[root@linux-node-01 bin]# ./elasticsearch-certutil cert --ca elastic-stack-ca.p12

# 设置密码 (需要把生成的密码记录)
[root@linux-node-01 bin]# ./elasticsearch-setup-passwords auto

# 拷贝证书到家目录
[root@linux-node-01 bin]# mv ../elastic-* /etc/elasticsearch/

# 拷贝证书到所有es节点
[root@linux-node-01 elasticsearch]# scp elastic-* elasticsearch.keystore linux-node-02:/etc/elasticsearch/
[root@linux-node-01 elasticsearch]# scp elastic-* elasticsearch.keystore linux-node-03:/etc/elasticsearch/
```
#### 配置es集群 开启xpack认证
- 开启`所有es节点` xpack 的配置
  ``` shell
  vim /etc/elasticsearch/elasticsearch.yml

  xpack.security.transport.ssl.verification_mode: certificate
  xpack.security.transport.ssl.keystore.path: elastic-certificates.p12
  xpack.security.transport.ssl.truststore.path: elastic-certificates.p12
  ```
#### 神坑  证书权限
``` shell
[root@linux-node-01 ~]# chmod 777 elastic-certificates.p12
[root@linux-node-01 ~]# systemctl restart elasticsearch.service

[root@linux-node-02 ~]# chmod 640 elastic-certificates.p12
[root@linux-node-02 ~]# systemctl restart elasticsearch.service

[root@linux-node-03 ~]# chmod 640 elastic-certificates.p12
[root@linux-node-03 ~]# systemctl restart elasticsearch.service
```

#### 验证是否成功
``` shell
[root@linux-node-01 ~]# curl -u elastic:x5uB9SngNtYYYxIU414d 0.0.0.0:9200/_cat/nodes
```
