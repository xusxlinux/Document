## ETCD集群部署
- [etcd3.3.15安装包下载](https://github.com/etcd-io/etcd/releases?q=3.3.15&expanded=true)  

#### 创建应用目录
``` shell
mkdir -pv /opt/etcd/certs /data/logs/etcd-server /data/etcd/etcd-server
```

#### 下载后解压
``` shell
tar xf etcd-v3.3.15-linux-amd64.tar.gz -C /opt/etcd/
```

#### 创建一个etcd用户
``` shell
# 安装etcd节点的服务器都需要创建
useradd -s /sbin/nologin -M etcd
```

```bash
vim /opt/etcd/etcd-server-startup.sh
#!/bin/env bash
./etcd --name etcd-server-7-12 \
       --data-dir /data/etcd/etcd-server \
       --listen-peer-urls https://10.4.7.12:2380 \
       --listen-client-urls https://10.4.7.12:2379,http://127.0.0.1:2379 \
       --quota-backend-bytes 8000000000 \
       --initial-advertise-peer-urls https://10.4.7.12:2380 \
       --advertise-client-urls https://10.4.7.12:2379,http://127.0.0.1:2379 \
       --initial-cluster  etcd-server-7-11=https://10.4.7.11:2380,etcd-server-7-12=https://10.4.7.12:2380,etcd-server-7-21=https://10.4.7.21:2380 \
       --ca-file ./certs/ca.pem \
       --cert-file ./certs/etcd-peer.pem \
       --key-file ./certs/etcd-peer-key.pem \
       --client-cert-auth  \
       --trusted-ca-file ./certs/ca.pem \
       --peer-ca-file ./certs/ca.pem \
       --peer-cert-file ./certs/etcd-peer.pem \
       --peer-key-file ./certs/etcd-peer-key.pem \
       --peer-client-cert-auth \
       --peer-trusted-ca-file ./certs/ca.pem \
       --log-output stdout
 ```

#### 添加权限, 变更目录属主,和属组
 ```
chmod +x /opt/etcd/etcd-server-startup.sh
chown -R etcd:etcd /opt/etcd /data/logs/etcd-server /data/etcd
 ```
 
 #### 安装进程管理工具
 ``` shell
 yum install supervisor -y
 ```
 
 #### 使用supervisor管理etcd
 ```ini
cat > /etc/supervisord.d/etcd-server.ini << EOF
[program:etcd02]
command=/opt/etcd/etcd-server-startup.sh                        ; the program (relative uses PATH, can take args)
numprocs=1                                                      ; number of processes copies to start (def 1)
directory=/opt/etcd                                             ; directory to cwd to before exec (def no cwd)
autostart=true                                                  ; start at supervisord start (default: true)
autorestart=true                                                ; retstart at unexpected quit (default: true)
startsecs=30                                                    ; number of secs prog must stay running (def. 1)
startretries=3                                                  ; max # of serial start failures (default 3)
exitcodes=0,2                                                   ; 'expected' exit codes for process (default 0,2)
stopsignal=QUIT                                                 ; signal used to kill process (default TERM)
stopwaitsecs=10                                                 ; max num secs to wait b4 SIGKILL (default 10)
user=etcd                                                       ; setuid to this UNIX account to run the program
redirect_stderr=true                                            ; redirect proc stderr to stdout (default false)
stdout_logfile=/data/logs/etcd-server/etcd.stdout.log           ; stdout log path, NONE for none; default AUTO
stdout_logfile_maxbytes=64MB                                    ; max # logfile bytes b4 rotation (default 50MB)
stdout_logfile_backups=4                                        ; # of stdout logfile backups (default 10)
stdout_capture_maxbytes=1MB                                     ; number of bytes in 'capturemode' (default 0)
stdout_events_enabled=false                                     ; emit events on stdout writes (default false)
killasgroup=true
stopasgroup=true
EOF
```

#### supervisor 命令
```
supervisorctl start etcd02
supervisorctl update
supervisorctl reload
supervisorctl status
supervisorctl restart all
```
