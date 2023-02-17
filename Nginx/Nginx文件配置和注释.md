``` conf
user                  nginx;
worker_processes      2;
worker_priority       -19;
worker_rlimit_nofile  16380;
# worker_cpu_affinity 将Nginx工作进程绑定到指定的CPU核心，默认Nginx是不进行进程绑定的，绑定并不是意味着当前nginx进程独占以一核心CPU，
# 但是可以保证此进程不会运行在其他核心上，这就极大减少了nginx的工作进程在不同的cpu核心上的来回跳转，
# 减少了CPU对进程的资源分配与回收以及内存管理等，因此可以有效的提升nginx服务器的性能。关键是避免不同的CPU缓存失效
worker_cpu_affinity   0001 0010; 
events {
    # Nginx 引入 accept_mutex 参数，如果启用该参数表示多个 worker 进程间顺序接收新连接，关闭的话则会所有 worker 进程同时被唤醒
    accept_mutex off;
    worker_connections    65535;
}
http {
    geoip_city            /usr/local/tengine/conf/GeoLiteCity.dat;
    geoip_country         /usr/local/tengine/conf/GeoIP.dat;
    log_format      main  '$geoip_country_name $geoip_region $geoip_city '
                          '$remote_addr - $remote_user [$time_local] "$request" '
                          '$status $body_bytes_sent "$http_referer" '
                          '"$http_user_agent" "$http_x_forwarded_for"';

    log_format      json  '{' 
                              '"geoip_country": "$geoip_country_name",'
                              '"geoip_region": "$geoip_region",'
                              '"remote_addr": "$remote_addr",'
                              '"remote_user": "$remote_user",'
                              '"time_local": "$time_local",'
                              '"request": "$request",'
                              '"status": "$status",'
                              '"bytes": "$body_bytes_sent",'
                              '"referer": "$http_referer",'
                              '"agent": "$http_user_agent",'
                              '"x_forwarded": "$http_x_forwarded_for"'
                           '}';

    # gzip可以支持将日志缓冲区中的数据压缩后写入磁盘
    #access_log            /usr/local/tengine/logs/access.log.gz main gzip flush=5;
    access_log            /usr/local/tengine/logs/access.log main;
    #access_log            /usr/local/tengine/logs/access.log json;

    # 开启rewrite日志功能
    rewrite_log           on;
    error_log             /usr/local/tengine/logs/rewrite.error.log info;

    include               mime.types;
    default_type          application/octet-stream;
    sendfile              on;
    keepalive_timeout     65;
    charset_types         *;
    charset               utf-8,gbk;

    # 静态内容的缓存优化
    open_file_cache            max=10240 inactive=20s;
    open_file_cache_valid      30s;
    open_file_cache_min_uses   2;
    open_file_cache_errors     on;

    # 只能设置在http代码段中
    proxy_cache_path           /usr/local/tengine/proxy_cache
                               levels=1:2    keys_zone=proxy-cache:20m
                               inactive=300s max_size=1g;
    proxy_temp_path            proxy_temp 1 2;

    proxy_connect_timeout      15s;
    proxy_send_timeout         10s;
    proxy_read_timeout         10s;

    # 限制连接
    limit_conn_zone            $binary_remote_addr  zone=conn_zone:10m;

    # 限制传输
    limit_req_zone             $binary_remote_addr  zone=req_zone:10m rate=500r/s;

    # 请求头和请求体的优化
    client_header_buffer_size  4k;
    client_max_body_size       16m;
    client_body_buffer_size    256k;

    # 隐藏版本信息
    server_tokens off;
    server_info   off;
    server_tag    off;

    # 配置虚拟主机
    include vhost/*;

    # 优先级问题
    root   /www/nginx/domain3/;
}
```
