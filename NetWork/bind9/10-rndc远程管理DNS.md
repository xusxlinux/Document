## rndc(无法reload动态域)
- rndc 可以针对某个域重载 `rndc reload chain.com`
#### 配置rndc远程管理的步骤
``` shell
# 本地的rndc key和配置文件要删除
[root@hdss7-11 ~]# cat /etc/rndc.key

# 删除 key
[root@hdss7-11 ~]# rm -rf /etc/rndc.key
# 删除后重新生成
[root@hdss7-11 ~]# rndc-confgen -r /dev/urandom
```
#### 把生成的配置粘贴到 etc/named.conf中的 options段之外
``` shell
[root@hdss7-11 ~]# vim /etc/named.conf
key "rndc-key" {
        algorithm hmac-md5;
        secret "AJScRjexY29LrMrKchfJ5g==";
};

controls {
        inet 10.4.7.11 port 953                                        # 需要修改让本机能监听
                allow { 10.4.7.11;10.4.7.12; } keys { "rndc-key"; };   # 让这两台服务都能进行rndc远程管理
};
```
#### 把rndc生成的key粘贴到 /etc/rndc.conf配置文件上
``` shell
[root@hdss7-11 ~]# vim /etc/rndc.conf

key "rndc-key" {
    algorithm hmac-md5;
    secret "AJScRjexY29LrMrKchfJ5g==";
};

options {
    default-key "rndc-key";
    default-server 10.4.7.11;      // 需要修改成本机内网地址
    default-port 953;
};
```
#### 在辅助DNS服务器上配置
``` shell
# 删除辅助DNS上的key
[root@hdss7-12 ~]# rm -rf /etc/rndc.key

[root@hdss7-12 ~]# vim /etc/rndc.conf

key "rndc-key" {
    algorithm hmac-md5;
    secret "AJScRjexY29LrMrKchfJ5g==";
};

options {
    default-key "rndc-key";
    default-server 10.4.7.11;     // 需要修改成主DNS的IP
    default-port 953;
};
```
#### 重启后验证
``` shell
# 重启
[root@hdss7-11 ~]# systemctl restart named

# 验证
[root@hdss7-11 ~]# netstat -lntup | grep 953
tcp        0      0 10.4.7.11:953           0.0.0.0:*               LISTEN      39264/named

# 在辅助DNS上验证
[root@hdss7-12 ~]# rndc status
```
#### 需要把动态业务域修改成静态域
``` shell
[root@hdss7-11 ~]# vim /etc/named.rfc1912.zones
zone "chain.com" IN {
        type  master;
        file  "chain.com.zone";
        allow-update { none; };      // 修改成静态
}
```
#### 在解析域名后, 不需要在手动重启named服务
``` shell
[root@hdss7-12 ~]# rndc reload chain.com
# 成功
zone reload queued
```
#### 在辅助DNS服务器上进行远程管理
- 我们的 host.com  chain.com 是静态域  
- 7.4.10.in-addr.arpa 是动态域
``` shell
# 冻结这个域
[root@hdss7-12 ~]# rndc freeze 7.4.10.in-addr.arpa

# 重新加载这个域
[root@hdss7-12 ~]# rndc reload 7.4.10.in-addr.arpa

# 解冻这个域
[root@hdss7-12 ~]# rndc thaw 7.4.10.in-addr.arpa
```

