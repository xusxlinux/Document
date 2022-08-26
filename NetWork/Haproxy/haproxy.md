## 下载安装包
[haproxy下载](https://src.fedoraproject.org/repo/pkgs/haproxy/)

#### 编译安装
``` shell
# 安装make工具
yum install gcc gcc-c++ pcre pcre-devel bzip2-devel zlib-devel glibc httpd-tools autoconf automake -y

# 解压到目录
tar xf haproxy-2.6.0.tar.gz
cd haproxy-2.6.0/

# 查看Linux内核版本, 进行编译
uname -a 
make TARGET=linux3100 CPU=x86_64 PREFIX=/usr/local/haprpxy
make install PREFIX=/usr/local/haproxy

mkdir -pv /usr/local/haproxy/{logs,conf}
mkdir -pv /etc/haproxy

# 复制启动脚本, 并且修改命令haproxy的路径
cd /root/haproxy-2.6.0/examples/
cp haproxy.init /etc/init.d/haproxy
sed -i 's#BIN=/usr/sbin/$BASENAME#BIN=/usr/local/haproxy/sbin/$BASENAME#g' /etc/init.d/haproxy
```

#### 修改内核参数
``` shell
# 开启Kernel的参数 , 绑定本机不存在的IP
echo '1' > /proc/sys/net/ipv4/ip_nonlocal_bind
# 允许转发, 开启数据包转发
echo '1' > /proc/sys/net/ipv4/ip_forward
```

#### 命令参考
``` shell
# 检查配置文件语法, 没输出就没有报错
/usr/local/haproxy/sbin/haproxy -f /etc/haproxy/haproxy.cfg

# 启动调试功能，将显示所有连接和处理信息在屏幕
/usr/local/haproxy/sbin/haproxy -d -f  /etc/haproxy/haproxy.cfg

# 显示haproxy编译和启动信息
haproxy -vv

# 启动
service haproxy start
```

#### 配置文件
``` shell
vim /etc/haproxy/haproxy.cfg

#默认参数设置
global
        maxconn 100000
        chroot /usr/local/haproxy
        uid 99  
        gid 99 
        daemon
        pidfile /usr/local/haproxy/logs/haproxy.pid 
        log 127.0.0.1 local3 info

#默认参数设置
defaults
        option http-keep-alive
        maxconn 100000
        mode http
        timeout connect 5000ms
        timeout client  50000ms
        timeout server 50000ms

#开启Haproxy Status状态监控，增加验证
listen stats
        mode http
        bind 0.0.0.0:8888
        stats enable
        stats uri     /haproxy-status 
        stats auth    haproxy:saltstack

#前端设置
frontend test_web_host_com
        bind 0.0.0.0:80
        mode http
        option httplog
        log global
        default_backend test_web_host_com

#后端设置
backend test_web_host_com
        option forwardfor header X-REAL-IP
        option httpchk HEAD / HTTP/1.0
        balance roundrobin
        server web-node1  10.4.7.51:80 check inter 2000 rise 30 fall 15
        server web-node2  10.4.7.52:80 check inter 2000 rise 30 fall 15
```

[参考文档 一](https://copyfuture.com/blogs-details/202204140439236722)  
[参考文档 二](https://blog.csdn.net/Persistence___/article/details/124953434)
