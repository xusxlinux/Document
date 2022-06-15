#### Redis介绍
``` txt
概念:  
  redis是一个基于内存的Key-Value 非关系型数据库  
特点:  
  内存数据库, 但数据可以持久化  
  数据间没有必然的联系  
  单线程程序  
  存储对象为 Key-Value , 五种常见对象: 字符串,哈希对象,列表对象,集合对象,有序集合对象  
```
#### Redis 体系结构
``` txt
不同的持久化生成不同的文件
RDB
AOF1
AOF2
```
#### Redis 下载安装
``` txt
# 安装到 /usr/local/redis 目录下,  配置文件放置, 普通用户下
sudo -i

wget https://download.redis.io/releases/redis-4.0.14.tar.gz
tar xf redis-4.0.14.tar.gz
mv redis-4.0.14 redis
cd redis/
make

# 普通用户下创建目录
su - xusx
mkdir -pv redis6379/{conf,data,logs}

# 创建环境变量
export PATH="$PATH:/usr/local/redis/src"
```
#### 简单配置文件
``` txt
vim redis.conf

# Redis不支持注释,  需要删除,  否则报错
bind 127.0.0.1
port 6379
daemonize yes
pidfile "/home/xusx/redis6379/logs/redis.pid"
loglevel notice
always-show-logo yes
logfile "/home/xusx/redis6379/logs/redis.log"
requirepass  123456

############# RDB #############
always-show-logo yes
save 900 1                                            #900秒（15分钟）内有1个更改
save 300 10                                           #300秒（5分钟）内有10个更改
save 60 10000                                         #60秒（1分钟）内有10000个更改
stop-writes-on-bgsave-error yes                       #后台备份进程出错时,主进程停不停止写入? 主进程不停止容易造成数据不一致
rdbcompression yes                                    #导出的rdb文件是否压缩 如果rdb的大小很大的话建议这么做
rdbchecksum yes                                       #导入rbd恢复时数据时,要不要检验rdb的完整性 验证版本是不是一致
dbfilename dump.rdb
dir "/home/xusx/redis6379/data"


############# AOF #############
appendonly yes                                        #是否打开AOF日志功能
appendfilename "appendonly.aof"
appendfsync always                                    #每一条命令都立即同步到AOF
#appendfsync everysec                                 #每秒写一次
#appendfsync no                                       #写入工作交给操作系统,由操作系统判断缓冲区大小,统一写入到AOF
no-appendfsync-on-rewrite no                          #正在导出rdb快照的过程中,要不要停止同步aof
auto-aof-rewrite-percentage 100                       #aof文件大小比起上次重写时的大小,增长率100%时重写,缺点:业务开始的时候，会重复重写多次
auto-aof-rewrite-min-size 64mb                        #aof文件,至少超过64M时,重写
```
#### 创建普通用户启动脚本
``` txt
vim /etc/systemd/system/redis.service 

[Unit]
Description=Redis
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=simple
User=xusx
Group=xusx
ExecStart=/usr/local/redis/src/redis-server /home/xusx/redis6379/conf/redis.conf --daemonize no
ExecStop=/usr/local/redis/src/redis-cli -h 127.0.0.1 -p 6379 shutdown
Restart=always
RestartSec=5
RuntimeDirectory=xusx
RuntimeDirectoryMode=0755
LimitNOFILE = 65535
LimitNPROC = 65535

[Install]
WantedBy=default.target
```
