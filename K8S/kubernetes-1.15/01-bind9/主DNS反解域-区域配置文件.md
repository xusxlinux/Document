
```
[root@hdss7-12 ~]# ll /etc/named.rfc1912.zones
-rw-r----- 1 root named 1289 May 17 16:31 /etc/named.rfc1912.zones

[root@hdss7-12 ~]# vim /etc/named.rfc1912.zones

zone "host.com" IN {
        type  master;
        file  "host.com.zone";
        allow-update { 10.4.7.11;10.4.7.12; };
};

zone "7.4.10.in-addr.arpa" IN {
        type master;
        file "7.4.10.in-addr.arpa.zone";
        allow-update { 10.4.7.11;10.4.7.12; };
};

zone "chain.com" IN {
        type  master;
        file  "chain.com.zone";
        allow-update { 10.4.7.12; };
};
```
