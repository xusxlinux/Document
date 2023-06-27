## 实验环境
[实验环境准备](https://github.com/xusxlinux/Document/blob/master/NetWork/route/01-%E8%B7%A8%E7%BD%91%E6%AE%B5%E8%B7%AF%E7%94%B1%E8%A1%A8%E9%85%8D%E7%BD%AE.md)

## iptables命令
``` shell
-P  或者 --pilicy        定义默认策略
-A  或者 --append        在规则列表的最后追加一条规则
-I  或者 --insert        在指定的位置插入一条规则
-D  或者 --delete        删除一个规则
-R  或者 --replace       替换某个规则
-F  或者 --flush         刷新
```

#### 实验 一  禁ping
- 插入一条filter表规则
``` shell
# 该规则是拒绝icmp包进入服务器
[root@route-01 ~]# iptables -t filter -I INPUT -p icmp -i eth1 -j DROP

# 该规则是拒绝(源地址: 192.168.80.123)icmp包在路由器上进行转发到(目标地址: 192.168.10.123)这个服务器上的
[root@route-01 ~]# iptables -t filter -I FORWARD -p icmp -s 192.168.80.123/32 -d 192.168.10.123 -j DROP
```
- 修改一条路由表规则
``` shell
# 修改INPUT链上 第一条规则
[root@route-01 ~]# iptables -t filter -R INPUT 1 -p icmp -i eth1 -j ACCEPT
```
- 删除一条filter表规则
``` shell
# 删除filter表上INPUT链的规则
[root@route-01 ~]# iptables -D INPUT 1
[root@route-01 ~]# iptables -t filter -p INPUT -D 1

# 删除filter表上FORWARD链的规则
[root@route-01 ~]# iptables -D FORWARD 1
[root@route-01 ~]# iptables -t filter -F FORWARD
```

## iptables匹配选项
``` shell
-i 或者--in-interface    指定数据包从哪个网络接口进入, 如eth0  eth1等
-o 或者--out-interface   指定数据包从哪块网络接口进入, 如eth0  eth1等
-p 或者--protocol        协议类型,  指定数据包匹配的协议, 如TCP, UDP 和ICMP
-s 或者--source          指定数据包匹配的源地址
-d 或者--destination     指定数据包匹配的目标地址
--sport                  指定数据包匹配的源端口号, 可以使用  "起始端口号: 结束端口号"的格式指定一个范围的端口号
--dport                  指定数据包匹配的目标端口号, 可以使用  "起始端口号: 结束端口号"的格式指定一个范围的端口号
```

#### 实验 二  拒绝远程登录
- 包转发经过forward链
``` shell
# 拒绝192.168.80.123服务器使用ssh登录192.168.10.123服务器22为端口
[root@route-01 ~]# iptables -t filter -I FORWARD -p tcp -s 192.168.80.123/32 -d 192.168.10.123/32 --dport 22 -j DROP

# 拒绝一个192.168.80.0/24网段 登录192.168.10.123服务器
[root@route-01 ~]# iptables -t filter -I FORWARD -p tcp -s 192.168.80.0/24 -d 192.168.10.123/32 --dport 22 -j DROP

# 放行所有数据包
[root@route-01 ~]# iptables -t filter -I FORWARD -s 172.16.80.0/24 -d 172.16.10.0/24 -j ACCEPT
```

## iptables扩展匹配选项
- 其实匹配扩展中, 还有需要加 -m 引用模块的显示扩展  
  - 参数 -m state
      - 基于状态检测的包过滤, 指定检测那种状态  --state {NEW, ESTATBLISHED, INVALID, RELATED}
      - 说明 用来比对连接状态, 共有四种连接状态. INVALID, ESTABLISHED, NEW, RELATED
``` shell
范例: iptables -A INPUT -m state --state  RELATED,ESTABLISHED

INVALID:           表明该封包的连接编号 (session ID) 无法识别或编号不正确.
ESTABLISHED:       表示该封包属于某个已经建立的连接
NEW:               表示该封包想要起始一个连接(重设连接或将连接重定向)
RELATED:           表示该封包是属于某个已经建立的连接, 所建立的新连接. 例如FTP-DATA 连接必定是源自莫格FTP连接
```

#### 实验 三  只允许建立单向会话, 不允许向外发送数据包
- 包转发经过forward链
``` shell
# 不允许192.168.10.0/24这个网段的地址和 192.168.80.0/24这个网段的地址建立新的连接
iptables -t filter -I FORWARD -s 192.168.10.0/24 -d 192.168.80.0/24 -m state --state NEW -j DROP


# 测试结果  -->  node10-123无法和node80-123建立连接 
[root@node10-123 ~]# ssh 192.168.80.123
ssh: connect to host 192.168.80.123 port 22: Connection timed out
```
- 不允许和外界建立新的连接 通过控制output链
``` shell
# 不让node10-123这个服务器向外发送数据包.  在filter表上的output链上加控制, 拒绝会话
[root@node10-123 ~]# iptables -t filter -I OUTPUT -m state --state NEW -j DROP
```

#### 实验 四  使用扩展参数 禁ping
- 参数 -m icmp --icmp-type
    - ping 命令使用icmp协议测试网络是否畅通, icmp有两种类型的数据包 icmp-type (echo request 和 echo reply)
- icmp数据包的类型也可以使用数字表示 如:
    - 类型8:  echo-request
    - 类型0:  echo-reply

``` shell
# 使用扩展参数 -m icmp --icmp-type 禁止192.168.10.123 ping通 192.168.80.123
[root@route-01 ~]# iptables -t filter -I FORWARD -s 192.168.10.0/24 -d 192.168.80.0/24 -p icmp -m icmp --icmp-type echo-request -j DROP

# 测试向192.168.80.123发送ping包
[root@node10-123 ~]# ping 192.168.80.123

# 在route-01上抓包观察
[root@route-01 ~]# tcpdump -i eth0 icmp -ne
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), capture size 262144 bytes
21:38:01.887401 00:0c:29:13:e4:ad > 00:0c:29:a2:02:e0, ethertype IPv4 (0x0800), length 98: 192.168.10.123 > 192.168.80.123: ICMP echo request, id 29072, seq 1, length 64
21:38:01.888385 00:0c:29:a2:02:e0 > 00:0c:29:13:e4:ad, ethertype IPv4 (0x0800), length 98: 192.168.80.123 > 192.168.10.123: ICMP echo reply, id 29072, seq 1, length 64
21:38:02.893393 00:0c:29:13:e4:ad > 00:0c:29:a2:02:e0, ethertype IPv4 (0x0800), length 98: 192.168.10.123 > 192.168.80.123: ICMP echo request, id 29072, seq 2, length 64
21:38:02.894953 00:0c:29:a2:02:e0 > 00:0c:29:13:e4:ad, ethertype IPv4 (0x0800), length 98: 192.168.80.123 > 192.168.10.123: ICMP echo reply, id 29072, seq 2, length 64
```
- 使用扩展参数禁ping  
``` shell
# 使用扩展参数 禁止其他服务器 ping 本机Linux.  本机服务器可以ping通 其他服务器
iptables -t filter -I INPUT -p icmp -m icmp --icmp-type echo-request -j DROP
```

#### 实验 五  使用多端口和ip范围做限制
参数 -m multiport  
  - 指定多端口号  -m multiport  
        -- sport  
        -- dport  
        -- ports  
``` shell
# 拒绝 192.168.80.0/24 访问 192.168.10.0/24 1-1024 3389 端口
[root@route-01 ~]# iptables -t filter -I FORWARD -p tcp -s 192.168.80.0/24 -d 192.168.10.0/24 -m multiport --dports 1:1024,3389 -j DROP


# 测试结果
[root@node80-123 ~]# ssh 192.168.10.123
ssh: connect to host 192.168.10.123 port 22: Connection timed out
```
  - 指定 IP 段 -m iprange  
        -src-range ip-ip  
        -dst-range ip-ip  
``` shell
# 禁止 192.168.80-100地址段 访问192.168.10.0/24网端
[root@route-01 ~]# iptables -t filter -I FORWARD -m iprange --src-range 192.168.80.1-192.168.80.100 -d 192.168.10.123/32 -j DROP


# 测试结果 192.168.80.23无法ping通 ping 192.168.10.123
[root@node80-123 ~]# ping 192.168.10.123
PING 192.168.10.123 (192.168.10.123) 56(84) bytes of data.
```

#### 实验 六  限制服务器最大ssh连接数
- 限定最大连接个数  
-m connlimit    --connlimit-above
``` shell
# 之允许192.168.80.0/24 连接远程服务器 192.168.10.123/32 最多两个会话
[root@route-01 ~]# iptables -t filter -I FORWARD -p tcp -s 192.168.80.0/24 -d 192.168.10.123/32 --dport 22 -m connlimit --connlimit-above 2 -j DROP
``` 

#### 实验 七  使用limit限速
- 指定包通过的速度(限速)
-m limit --limit    说明 用来对比某时间内封包的平均流量, 上面的例子是用来比对, 每小时平均流量是否超过一次3个封包
``` shell
# 192.168.10.0/24网段每秒种向192.168.80.0/24网段发送数据包不能超过300个1500字节  (流量不会超过该值)带宽=1500*300=450000=450k
# 需要使用到两条规则, 不超过450k的放行, 超过的拒绝.
[root@route-01 ~]# iptables -t filter -I FORWARD -s 192.168.10.0/24 -d 192.168.80.0/24 -m limit --limit 300/second -j ACCEPT
[root@route-01 ~]# iptables -t filter -A FORWARD -s 192.168.10.0/24 -d 192.168.80.0/24 -j DROP


# 测试结果 192.168.10.123服务器向192.168.80.123服务器发送数据包   限速后慢的一批
[root@node10-123 ~]# scp kibana-7.17.7-x86_64.rpm 192.168.80.123:/root
kibana-7.17.7-x86_64.rpm                                                                                                  15%   39MB 838.5KB/s   04:25 ETA
```

#### 实验 八  流量控制
参数 -m limit --limit-burst  
  - 瞬间流量控制, 用来对瞬间大量封包的数量. 同时涌入的封包
``` shell
# 解决突发流量 限制每秒钟最多300个数据包通过的限制  一般 `--limit` 需要和 `--limit-burst` 一起使用, 做流量控制
vim /etc/sysconfig/iptable_limit.sh
#!/usr/bin/env bash
for ((i=2; i<254; i++))
do
iptables -I FORWARD -s 192.168.10.$i -j DROP
# 前400个数据包不限速.  突发流量超过400个数据包的时候, 每秒钟控制到300个数据包. 
iptables -I FORWARD -s 192.168.10.$i -m limit --limit 300/sec --limit-burst 400 -j ACCEPT
done
```

``` shell
# 只允许192.168.10.123 向192.168.80.123 发送4个数据包
[root@route-01 ~]# iptables -t filter -I FORWARD -s 192.168.10.123/32 -d 192.168.80.123/32 -p icmp -m limit --limit-burst 4 -j ACCEPT
[root@route-01 ~]# iptables -t filter -A FORWARD -s 192.168.10.123/32 -d 192.168.80.123/32 -p icmp -j DROP


# 清空计时器
[root@route-01 ~]# iptables -t filter -Z
```

## iptables 动作处理命令
``` shell
-j 参数用来指定要进行的处理动作, 常用处理动作包括: 
ACCEPT, REJECT, DROP, REDIRECT, MASQUERADE, LOG, DNAT, SNAT, QUEUE,  MIRROR, RETURN, MARK

filter表能使用的主要动作:

ACCEPT:  将封包放行, 进行完此处理动作后, 将不再匹配其它规则, 直接跳到下一个规则链
REJECT:  阻拦该封包, 并传送封包通知对方, 可以传送的封包有几个选择(ICMP tpo-unreachable,  ICMP echo-reply, tcp-reset要求关闭连接), 进行完此处理动作后, 将不再匹配其他规则, 直接中断过滤程序
DROP:    丢弃封包不予处理, 进行完此处理动作后, 将不再匹配其他规则, 直接中断过滤程序
LOG:     将封包相关信息 记录在/var/log中.
```
#### 保存iptables规则
``` shell
[root@route-01 ~]# iptables-save > /etc/sysconfig/iptables
[root@route-01 ~]# iptables-restore < /etc/sysconfig/iptables
[root@route-01 ~]# iptables -L -vn --line-number
```

#### 实验 九  保护服务器安全-配置安全组
``` shell
# 配置安全端口之前需要先设置定时任务, 防止把自己关在外面
[root@route-01 ~]# crontab -l
*/5 * * * * /usr/bin/systemctl stop iptables.service

# 在route-01服务器上配置开放安全端口22 (下面命令其中一条即可)
[root@route-01 ~]# iptables -t filter -I INPUT -p tcp -s 192.168.80.123/32 --dport 22 -j ACCEPT
[root@route-01 ~]# iptables -t filter -I INPUT -p tcp -s 192.168.80.123/32 -d 192.168.10.10/32  --dport 22 -j ACCEPT

# 在 web 服务器对外开放80/443端口
[root@route-01 ~]# iptables -t filter -I INPUT -p tcp -s 0.0.0.0/0 -m multiport  --dports 80,443 -j ACCEPT

# 拒绝所有的 (防火墙规则是由上自下的, 所以先匹配上面的规则)
[root@route-01 ~]# iptables -t filter -P INPUT DROP

# 确认没问题后, 删除定时任务
#*/5 * * * * /usr/bin/systemctl stop iptables.service
```

## recent 模块实现服务器网络安全
recent 这个模块很有趣, 善加利用可以充分保证您服务器的安全  
设定常用参数:  
``` shell
--name         # 设定列表名称, 默认 DEFAULT
--resource     # 源地址, 此为默认
--rdest        # 目标地址
--secondes     # 指定时间内
--hitcount     # 命中次数
--set          # 将地址添加进列表, 并更新信息, 包含地址加入的时间戳
--rcheck       # 检查地址是否在列表, 以第一个匹配计算时间
--update       # 和rcheck类似, 以最后一个匹配计算时间
--remove       # 在列表里删除相应地址, 后跟列表名称以及地址
```

#### 实验 十  保护服务器安全-防止暴力破解密码
防止暴力破解ssh登录密码. 只允许300秒建立10个新连接
``` shell
# 设置ssh连接一个客户端300秒内只允许连接10次 查看该条规则的SSHTABLES表,没有记录,不满足,查找下一条规则.(这三条规则需要配合使用)
[root@route-01 ~]# iptables -t filter -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --name SSHTABLES --rcheck --seconds 300 --hitcount 10 -j DROP

# 新建一个会话进行--set操作记录SSHTABLES表中, set默认记录源地址(相当于一个计数器, 每访问一次记录一下SSHTABLES表)
[root@route-01 ~]# iptables -t filter -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --name SSHTABLES --set -j ACCEPT

# 建立了会话的数据包, 统统允许进入网卡
[root@route-01 ~]# iptables -t filter -A INPUT -m state --state ESTABLISHED -j ACCEPT
```

#### 实验 十一  保护服务器安全-防止cc攻击
防止web网站遭受cc攻击 (防止syn洪水攻击)
``` shell
# 限制TCP 80端口 60秒内每个IP只能发起10个新连接, 超过后记录日志并且丢弃数据包, 可防止CC以及非伪造IP的syn flood


# 记录日志跟踪 (按照顺序)
[root@route-01 ~]# iptables -t filter -I INPUT -p tcp --dport 80 --syn -m recent --name websyntables --rcheck --seconds 60 --hitcount 10 -j LOG --log-prefix 'DDOS:' --log-ip-options

# 不匹配60秒10个新连接就进入下一条规则
[root@route-01 ~]# iptables -t filter -I INPUT -p tcp --dport 80 --syn -m recent --name websyntables --rcheck --seconds 60 --hitcount 10 -j DROP

# 计数器, 记录60秒10新连接
[root@route-01 ~]# iptables -t filter -I INPUT -p tcp --dport 80 --syn -m recent --name websyntables --set -j ACCEPT

# 建立了会话的数据包, 统统允许进入网卡 (也可以不加)
[root@route-01 ~]# iptables -t filter -A INPUT -m state --state ESTABLISHED -j ACCEPT

# 在 web 服务器对外开放80/443端口
[root@route-01 ~]# iptables -t filter -I INPUT -p tcp -s 0.0.0.0/0 -m multiport  --dports 80,443 -j ACCEPT
```

#### 实验 十二  保护服务器安全-为开放的端口添加密钥
``` shell
# 没啥用
```

#### 实验 十三  保护网段中服务器安全
使用Linux路由器来保护网段中服务器的安全
``` shell
# 不放行forward上的所有转发规则
[root@route-01 ~]# iptables -P FORWARD DROP

# 放行通过eth0网卡转发的 tcp 22端口
[root@route-01 ~]# iptables -t filter -I FORWARD -p tcp --dport 22 -d 192.168.80.123/32 -o eth0 -j ACCEPT

# 没有这条规则就无法建立 tcp三次握手. 需要做到有来有回
[root@route-01 ~]# iptables -t filter -I FORWARD -m state --state ESTABLISHED -j ACCEPT



# 测试  卡在ssh连接上了, 因为没有添加第三条规则, 做不到有来有回
[root@node80-123 ~]# ssh 192.168.10.123    

# 新开一个窗口查看建立连接的状态是SYN_SENT
[root@node80-123 ~]# netstat -an | grep SYN_SENT
tcp        0      1 192.168.80.123:56120    192.168.10.123:22       SYN_SENT
```

#### 实验 十四  配置NAT实现网络地址转换
nat地址转换  SNAT(源地址目标转换)
``` shell
#*删除 route2上到192.168.10.0/24网络的路由
[root@route-02 ~]# route del -net 192.168.10.0 netmask 255.255.255.0

# 为eth1 添加一个公网ip地址做NAT 模拟SNAT (让内网服务器可以访问外网, 外网无法访问内网)
[root@route-01 ~]# ip addr add 192.168.20.11/32 dev eth1:1

# 添加转发规则  使用SNAT, 让内网服务器能访问到公网IP地址
[root@route-01 ~]# iptables -t nat -A POSTROUTING -s 192.168.10.0 -o eth1 -j SNAT --to-source 192.168.20.10-192.168.20.11
```
nat端口映射  DNAT(目标网络地址转换)
``` shell
# 使用dnat端口映射 通过连接192.168.20.10的22端口连接192.168.10.123的22端口
[root@route-01 ~]# iptables -t nat -I PREROUTING -i eth1 -d 192.168.20.10/32 -p tcp --dport 22 -j DNAT --to 192.168.10.123:22

# 使用dnat端口映射 通过连接192.168.20.10的4000端口连接192.168.10.123的22端口
[root@route-01 ~]# iptables -t nat -I PREROUTING -i eth1 -d 192.168.20.10/32 -p tcp --dport 4000 -j DNAT --to 192.168.10.123:22



# 测试结果  使用22端口去连接的192.168.20.10服务器, 通过DNAT映射到192.168.10.123的22端口
[root@node80-123 ~]# ssh 192.168.20.10
root@192.168.20.10's password:
Last login: Tue Jun 27 15:32:11 2023 from 192.168.80.123

# 测试结果  使用4000端口去连接的192.168.20.10服务器, 通过DNAT映射到192.168.10.123的22端口 
[root@node80-123 ~]# ssh -p4000 192.168.20.10
root@192.168.20.10's password:
Last login: Tue Jun 27 15:27:55 2023 from 192.168.80.123
```






