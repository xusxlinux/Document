#### bind9主配置文件
``` shell
[root@hdss7-11 ~]# yum install bind
13         listen-on port 53 { 10.4.7.11; };
14         listen-on-v6 port 53 { ::1; };     // 删除这行

20         allow-query     { any; };
21         forwarders      { 10.4.7.1; };

22         allow-transfer  { 10.4.7.11; };    // 完全区域传送
23         also-notify     { 10.4.7.12; };    // 主动通知从（slave）服务器进行更新

35         recursion yes;                     // 企业内网DNS使用recursion选项
37         dnssec-enable yes;                 // 如果外面的域名加上DNSSEC的签名,我们通过这台DNS服务器查询的时候,可以把签名查出来
38         dnssec-validation yes;
```

#### 自定义正解域

``` shell
# 自定义区域配置文件
[root@hdss7-11 ~]# vim /etc/named.rfc1912.zones

zone "host.com" IN {
        type  master;
        file  "host.com.zone";
        allow-update { 10.4.7.11;10.4.7.12; };
};

zone "chain.com" IN {
        type  master;
        file  "chain.com.zone";
        allow-update { 10.4.7.11; };
};

zone "7.4.10.in-addr.arpa" IN {
        type master;
        file "7.4.10.in-addr.arpa.zone";
        allow-update { none; };
};

# 检查配置
[root@hdss7-11 ~]# named-checkconf
```

``` shell
# 自定义区域数据库文件
[root@hdss7-11 ~]# vim /var/named/host.com.zone 

$ORIGIN host.com.
$TTL 600             ; 10 minutes
@                    IN  SOA  dns.host.com. dnsadmin.host.com. (; SOA其实授权,有且只能有一条,并且要写在最前面
                                    2020101000 ; serial
                                    10800      ; refresh (3 hours)
                                    900        ; retry   (15 minutes)
                                    604800     ; expire  (1 week)
                                    86400      ; minimum (1 day)
                                    )
                     IN  NS   dns.host.com.
$TTL 60              ; 1 minute
$ORIGIN host.com.
dns                  IN  A    10.4.7.11
HDSS7-11             IN  A    10.4.7.11
HDSS7-12             IN  A    10.4.7.12
HDSS7-21             IN  A    10.4.7.21
HDSS7-22             IN  A    10.4.7.22
HDSS7-200            IN  A    10.4.7.200
```

``` shell

```

