#### 四层代理
```
user  nginx;
worker_processes  auto;

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;


events {
    worker_connections  1024;
}

stream {
    log_format main "$remote_addr $upstream_addr - $time_local $status";
    access_log /var/log/nginx/k8s-access.log main;

    upstream kube-apiserver {
        server 10.4.7.21:6443;
        server 10.4.7.22:6443;
    }

    server {
        listen 0.0.0.0:6443;
        proxy_pass kube-apiserver;
    }
}


http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    keepalive_timeout  65;

    #gzip  on;

    include /etc/nginx/conf.d/*.conf;
}
```
