
#### 修改辅助DNS的主配置文件
``` shell
[root@hdss7-12 ~]# vim /etc/named.conf
13         listen-on port 53 { 10.4.7.12; };  // 监听在本机的内网地址
14         listen-on-v6 port 53 { ::1; };     // 删除这行

20         allow-query     { any; };         // 允许本机的DNS帮你查询

33         masterfile-format text;            // 默认生成的zone文件是乱码的, 加上这个设置，输出就不会乱码


# 检查配置是否正确
[root@hdss7-11 ~]# named-checkconf
```

#### 修改主DNS的配置文件
``` shell
[root@hdss7-11 ~]# vim /etc/named.conf 

23         allow-transfer  { 10.4.7.12; };    // 完全区域传送, 只同意10.4.7.12这个服务器同步主配置信息
24         also-notify     { 10.4.7.12; };    // 主动通知从（slave）服务器进行更新, 指定的 IP 地址才能同步


# 检查配置是否正确
[root@hdss7-11 ~]# named-checkconf

# 检查配置没问题后可以重启
[root@hdss7-11 ~]# systemctl restart named
```

#### 在辅助DNS上去检查完全区域传送
``` shell
[root@hdss7-12 ~]# dig -t AXFR host.com @10.4.7.11
```

#### 在辅助DNS上创建自定义正解区域配置
``` shell
[root@hdss7-12 ~]# vim /etc/named.rfc1912.zones
# 在这个配置文件中, 添加下面配置

zone "host.com" IN {
        type slave;
        file "slaves/host.com.zone";
        masters { 10.4.7.11; };
};

# 检查配置语法是否有错误
[root@hdss7-12 ~]# named-checkconf
```

#### 检查配置并启动辅助DNS
``` shell
# 文件属性 named.named, 文件权限770.  配置named.rfc1912.zones后没有重启, 该文件家是空
[root@hdss7-12 ~]# ls -l /var/named/slaves


# 重启后 slave会同步配置文件
[root@hdss7-12 ~]# systemctl restart named
```

#### 检查同步过来的区域数据库文件
``` shell
# 出现结果就是配置成功
[root@hdss7-12 ~]# cat /var/named/slaves/host.com.zone

# 在 11 这个服务器上检查是否解析成功
[root@hdss7-11 ~]# dig -t A hdss7-12.host.com @10.4.7.12 +short
```
