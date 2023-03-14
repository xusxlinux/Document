#### 在辅助DNS上创建自定义反解区域配置
``` shell
[root@hdss7-12 ~]# vim /etc/named.rfc1912.zones
# 在这个配置文件中, 添加下面配置

zone "7.4.10.in-addr.arpa" IN {
        type slave;
        file "slaves/7.4.10.in-addr.arpa.zone";
        masters { 10.4.7.11; };
}; 
```

#### 检查配置并重启辅助DNS
``` shell
# 检查配置语法是否有错误
[root@hdss7-12 ~]# named-checkconf


# 重启后 slave会同步配置文件
[root@hdss7-12 ~]# systemctl restart named
```

#### 检查同步过来的区域数据库文件
``` shell
# 出现结果就是配置成功
[root@hdss7-12 ~]# cat /var/named/slaves/7.4.10.in-addr.arpa.zone


[root@hdss7-12 ~]# dig -t AXFR 7.4.10.in-addr.arpa. @10.4.7.11
```
