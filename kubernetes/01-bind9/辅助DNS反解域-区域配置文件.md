```
[root@hdss7-11 ~]# ll /etc/named.rfc1912.zones
-rw-r-----. 1 root named 1152 May 21 12:16 /etc/named.rfc1912.zones

[root@hdss7-11 ~]# vim /etc/named.rfc1912.zones
zone "host.com" IN {
        type slave;
        file "slaves/host.com.zone";
        masters { 10.4.7.12; };
};

zone "7.4.10.in-addr.arpa" IN {
        type slave;
        file "slaves/7.4.10.in-addr.arpa.zone";
        masters { 10.4.7.12; };
};

```
