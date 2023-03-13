#### 添加反解域的自定义区域配置
``` shell
[root@hdss7-11 ~]# vim /etc/named.rfc1912.zones

# 粘贴如下反解域的配置
zone "7.4.10.in-addr.arpa" IN {
        type master;
        file "7.4.10.in-addr.arpa.zone";
        allow-update { 10.4.7.11; };
};


# 检查配置文件语法
[root@hdss7-11 ~]# named-checkconf
```

#### 添加反解域的区域数据库文件
``` shell
[root@hdss7-11 ~]# vim /var/named/7.4.10.in-addr.arpa.zone
# 复制粘贴如下配置到zone文件中

$TTL 600 ;10 minutes
@        IN    SOA     dns.host.com. dnsadmin.host.com. (
                       2019030303    ;serial
                       10800         ;refresh time
                       900           ;retry time
                       64800         ;expire
                       86400         ;negative anwer ttl
)
         IN     NS      dns.host.com.


$ORIGIN 7.4.10.in-addr.arpa.
$TTL 60  ;1 minute
11       IN     PTR     hdss7-11.host.com.
12       IN     PTR     hdss7-12.host.com.
21       IN     PTR     hdss7-21.host.com.
22       IN     PTR     hdss7-22.host.com.
```

#### 配置文件权限
``` shell
[root@hdss7-11 ~]# chown root.named /var/named/7.4.10.in-addr.arpa.zone
[root@hdss7-11 ~]# chmod 640 /var/named/7.4.10.in-addr.arpa.zone
```

#### 检查主机域配置文件是否正确
``` shell
[root@hdss7-11 ~]# named-checkzone 7.4.10.in-addr.arpa. /var/named/7.4.10.in-addr.arpa.zone
```

#### 验证反解域是否配置正确
``` shell
[root@hdss7-11 ~]# dig -t PTR 11.7.4.10.in-addr.arpa @10.4.7.11 +short
[root@hdss7-11 ~]# dig -t PTR 21.7.4.10.in-addr.arpa @10.4.7.11 +short
```
