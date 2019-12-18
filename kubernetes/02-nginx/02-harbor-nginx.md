```
$ cat /etc/nginx/conf.d/harbor.od.com.conf 
server {
    listen 80;
    server_name harbor.od.com;

    client_max_body_size 1000m;

    location / {
       proxy_pass http://127.0.0.1:180;
    }
}
```

```
$ cat /var/named/od.com.zone 
$ORIGIN od.com.
$TTL 600        ; 10 minutes
@               IN SOA  dns.od.com. dnsadmin.od.com. (
                                2019111002 ; serial
                                10800      ; refresh (3 hours)
                                900        ; retry (15 minutes)
                                604800     ; expire (1 week)
                                86400      ; minimum (1 day)
                                )
                                NS   dns.od.com.
$TTL 60 ; 1 minute
dns                A    10.4.7.11
harbor             A    10.4.7.200
```
