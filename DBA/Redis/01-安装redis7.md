## reids
#### 创建基础环境
``` shell
mkdir -pv /data/redis7/{src,bin,data,logs,standalone,master-replica,sentinel}
cd /data/software/
tar xf redis-stable.tar.gz
mv /data/software/redis-stable /data/redis7/src/
cd /data/redis7/src/redis-stable/src
make -j88 && make install PREFIX=/data/redis7/

vim /etc/profile
export PATH="$PATH:/data/redis7/bin"
source /etc/profile
```

#### redis standalone
``` shell
cd /data/redis7/standalone/
cat /data/redis7/standalone/redis.conf

daemonize yes
port 6379
bind 0.0.0.0
protected-mode no
requirepass 123456
save 900 1 300 10 60 10000
dir /data/redis7/data
pidfile /data/redis7/logs/redis.pid
loglevel notice
logfile "/data/redis7/logs/redis.log"
always-show-logo yes
masterauth 123456
```

#### redis Cluster
``` shell
cd /data/redis7/master-replica
cat /data/redis7/master-replica/redis.conf

daemonize yes
port 6379
bind 0.0.0.0
protected-mode no
requirepass 123456
save 900 1 300 10 60 10000
dir /data/redis7/data
pidfile /data/redis7/logs/redis.pid
loglevel notice
logfile "/data/redis7/logs/redis.log"
always-show-logo yes
replicaof 192.168.0.22 6379
masterauth 123456
```

## redis sentinel(哨兵) 
``` shell
daemonize yes
port 26379
bind 0.0.0.0
requirepass 123456
pidfile /data/redis7/logs/redis.pid
logfile "/data/redis7/logs/redis.log"

sentinel monitor mymaster 192.168.0.22 6379 2
sentienl auth-pass mymaster 123456
sentienl down-after-milliseconds mymaster 30000
```
