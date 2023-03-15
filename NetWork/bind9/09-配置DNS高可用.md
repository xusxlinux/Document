#### 加上辅助DNS的IP实现高可用 (配置短域名)
``` shell
[root@hdss7-11 ~]# cat /etc/resolv.conf
# search作用：短域名
search host.com chain.com
nameserver 10.4.7.12
nameserver 10.4.7.11

[root@hdss7-12 ~]# cat /etc/resolv.conf
# search作用：短域名
search host.com chain.com
nameserver 10.4.7.12
nameserver 10.4.7.11
```

``` shell
[root@hdss7-11 ~]# ping es1
PING es1.chain.com (10.4.7.11) 56(84) bytes of data.
64 bytes from hdss7-11.host.com (10.4.7.11): icmp_seq=1 ttl=64 time=0.023 ms
```
