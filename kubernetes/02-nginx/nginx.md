#### 四层代理
```
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
```
