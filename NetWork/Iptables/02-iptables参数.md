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

```` shell
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




















