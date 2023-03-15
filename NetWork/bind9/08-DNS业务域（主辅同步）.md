## 业务域(不需要反解)
- 注意： 主机域可以是假域， 业务域推荐用真实的已购买的

#### 在主DNS服务器上添加 区域配置文件 
``` shell
[root@hdss7-11 ~]# vim /etc/named.rfc1912.zones
# 业务域配置

zone "chain.com" IN {
        type  master;
        file  "chain.com.zone";
        allow-update { 10.4.7.11; };
};
```

#### 每次做完, 需要检查是否有语法错误, 配置是否正确
``` shell
[root@hdss7-11 ~]# named-checkconf
```
#### 注意权限
``` shell
[root@hdss7-11 ~]# chown root:named /var/named/chain.com.zone
[root@hdss7-11 ~]# chmod 640 /var/named/chain.com.zone
```
#### 在主DNS服务器上添加区域数据库文件
``` shell
[root@hdss7-11 ~]# vim /var/named/chain.com.zone
# 业务域

$ORIGIN chain.com.
$TTL 600        ; 10 minutes
@               IN SOA  dns.chain.com. dnsadmin.chain.com. (
                                2019111010 ; serial
                                10800      ; refresh (3 hours)
                                900        ; retry (15 minutes)
                                604800     ; expire (1 week)
                                86400      ; minimum (1 day)
                                )
                   NS   dns1.chain.com.
                   NS   dns2.chain.com.
$TTL 60         ; 1 minute
dns1               A    10.4.7.11
dns2               A    10.4.7.12
www                A    10.4.7.11
superset           A    10.4.7.12
es1                A    10.4.7.11
kibana             A    10.4.7.11
cerebro            A    10.4.7.11
gitlab             A    10.4.7.12
```
#### 每次做完需要检查是否有语法错误, 配置是否正确
``` shell
[root@hdss7-11 ~]# named-checkzone chain.com. /var/named/chain.com.zone
```

#### 新建一个区域数据库文件后要重启一下
``` shell
[root@hdss7-11 ~]# systemctl restart named
```

#### 检查一下是否生效
``` shell
[root@hdss7-11 ~]# dig -t A www.chain.com @10.4.7.11 +short
```
#### dig 在辅助DNS上没有生效的原因
``` shell
# 没有生效的原因是辅助DNS服务器上没有配置, 在12的服务器上配置后生效
[root@hdss7-11 ~]# dig -t A www.chain.com @10.4.7.12 +short
```
#### 在辅助DNS上配置
``` shell
[root@hdss7-12 ~]# vim /etc/named.rfc1912.zones
# 粘贴下面配置

zone "chain.com" IN {
        type slave;
        file "slaves/chain.com.zone";
        masters { 10.4.7.11; };
};
```
#### 检验
``` shell
# 每次做完, 需要检查是否有语法错误, 配置是否正确
[root@hdss7-12 ~]# named-checkconf


# 重新启动辅助DNS服务
[root@hdss7-12 ~]# systemctl restart named


# 查看区域数据库文件是否同步成功
[root@hdss7-12 ~]# ll /var/named/slaves/
-rw-r--r-- 1 named named 443 Mar 14 20:43 7.4.10.in-addr.arpa.zone
-rw-r--r-- 1 named named 532 Mar 14 21:22 chain.com.zone
-rw-r--r-- 1 named named 438 Mar 14 21:18 host.com.zone
```
#### 主DNS和辅助DNS上都能查询出结果
``` shell
[root@hdss7-12 ~]# dig -t A dns1.chain.com @10.4.7.11 +short
[root@hdss7-12 ~]# dig -t A dns1.chain.com @10.4.7.12 +short
```
