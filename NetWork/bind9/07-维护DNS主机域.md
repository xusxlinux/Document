## 维护静态主机域正解域主辅同步
``` shell
[root@k8s-master-01 ~]# vim /etc/named.rfc1912.zones

zone "host.com" IN {
        type  master;
        file  "host.com.zone";
        allow-update { 10.4.7.11;10.4.7.12; };           // 把这行删除,替换成下面这行
        allow-update { 10.4.7.12; };                      // 这行修要修改成none 才能使用nsupdate
};

zone "7.4.10.in-addr.arpa" IN {
        type master;
        file "7.4.10.in-addr.arpa.zone";
        allow-update { 10.4.7.12; };                      // 限制辅助DNS服务器 12 才能send 数据
};
```

``` shell
这时候 host.com.zone 就变成静态域
[root@hdss7-11 ~]# systemctl restart named
```

``` shell
# 这时候就变成静态域
[root@hdss7-11 ~]# nsupdate
> server 10.4.7.11
> update add k8s-master-03.host.com 60 A 10.4.7.13
> send   
update failed: REFUSED
> quit
```

``` shell
# 我们手动添加一个记录.  并且滚动一个serial号码,去手动通知辅助DNS, 我的记录变更
[root@k8s-master-01 ~]# vim /var/named/host.com.zone
k8s-master-03             IN  A    10.4.7.13

# 做完记录变更后重启
[root@k8s-master-01 ~]# systemctl restart named
```
## 维护动态主机域反解域主辅同步
- 我们维护一个动态域的时候,直接使用nsupdate命令进行了增删改,辅助DNS直接就生效了,不需要主动的再去变更 serial 记录
``` shell
# 维护反解域 动态的增
[root@hdss7-11 ~]# nsupdate
> server 10.4.7.11
> update add 13.7.4.10.in-addr.arpa. 60 PTR hdss7-13.host.com.
> send
> quit
```

``` shell
# 验证, 主DNS服务器上可以查到, 辅助DNS上也可以查到
[root@hdss7-11 ~]# dig -t PTR 13.7.4.10.in-addr.arpa. @10.4.7.11 +short
hdss7-13.host.com.


[root@hdss7-11 ~]# dig -t PTR 13.7.4.10.in-addr.arpa. @10.4.7.12 +short
hdss7-13.host.com.
```

``` shell
# 删除之前的反解记录
[root@hdss7-11 ~]# nsupdate
> server 10.4.7.11
> update del 13.7.4.10.in-addr.arpa. 60 PTR hdss7-13.host.com.
> send
> quit
```

``` shell
# 改  修改的前提是 先删除在增加
```

``` shell
# 多出的文件

[root@hdss7-11 ~]# ll /var/named/
total 32
-rw-r-----  1 named named  632 May 17 16:19 7.4.10.in-addr.arpa.zone
-rw-r--r--  1 named named  757 May 17 16:32 7.4.10.in-addr.arpa.zone.jnl
```
