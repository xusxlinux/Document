## 一 Remote AccessVPN(远程访问)
#### openvpn3安装
``` shell
[root@linux-node-01 ~]# yum install easy-rsa openvpn -y
[root@linux-node-01 ~]# mkdir -pv /data/openvpn

[root@linux-node-01 ~]# rpm -ql easy-rsa

[root@linux-node-01 ~]# cd /data/openvpn
[root@linux-node-01 openvpn]# cp -a /usr/share/easy-rsa/3/* .
[root@linux-node-01 openvpn]# cp -a /usr/share/doc/easy-rsa/vars.example ./vars

```
#### 1丶配置ca颁发机构
``` shell
[root@linux-node-01 openvpn]# vim /data/openvpn/vars

if [ -z "$EASYRSA_CALLER" ]; then
        echo "You appear to be sourcing an Easy-RSA 'vars' file." >&2
        echo "This is no longer necessary and is disallowed. See the section called" >&2
        echo "'How to use this file' near the top comments for more details." >&2
        return 1
fi
set_var EASYRSA_CA_EXPIRE       3650
set_var EASYRSA_CERT_EXPIRE     3650
set_var EASYRSA_DN              "cn_only"
set_var EASYRSA_REQ_COUNTRY     "CN"
set_var EASYRSA_REQ_PROVINCE    "Beijing"
set_var EASYRSA_REQ_CITY        "Beijing"
set_var EASYRSA_REQ_ORG         "wm"
set_var EASYRSA_REQ_EMAIL       "xusxlinux@163.com"
set_var EASYRSA_NS_SUPPORT      "yes"
```
#### 2丶证书初始化
``` shell
# 初始化PKI, 在当前目录创建PKI目录, 用于存储证书
[root@linux-node-01 openvpn]# ./easyrsa init-pki
# 创建CA机构, 主要对后续创建的 server,client 证书进行签名; 会提示密码, 其他默认
[root@linux-node-01 openvpn]# ./easyrsa build-ca
```
#### 3丶签发服务端证书
``` shell
# 创建 server 端的证书, nopass表示不加密私钥文件, 其他可默认
[root@linux-node-01 openvpn]# ./easyrsa gen-req server nopass
# 给server端证书签名, 首先是对信息的确认, 输入yes,然后输入创建ca根证书时设置的密码. 第一个server是类型, 第二个server是req请求文件名称
[root@linux-node-01 openvpn]# ./easyrsa sign server server
```
#### 4丶签发客户端证书
``` shell
# 创建 client 端的证书, nopass表示不加密私钥文件, 其他可默认
[root@linux-node-01 openvpn]# ./easyrsa gen-req client nopass
# 给client端证书签名, 首先是对信息的确认, 输入yes,然后输入创建ca根证书时设置的密码. 第一个client是类型, 第二个client是req请求文件名称
[root@linux-node-01 openvpn]# ./easyrsa sign client client
```
#### 5丶创建DH密钥
``` shell
# Diffie-Hellman是一种安全协议; 让双方在完全没有对方信息下通过不安全信道建立一个密钥; 称为 "对称加密", 被双方在后续传输中使用.
[root@linux-node-01 openvpn]# ./easyrsa gen-dh
```
#### 6丶防止ddoc攻击
``` shell
[root@linux-node-01 ~]# cd /etc/openvpn
[root@linux-node-01 openvpn]# openvpn --genkey --secret ta.key
```
## 查看openvpn3 安装路径
``` shell
[root@linux-node-01 openvpn]# rpm -ql openvpn
[root@linux-node-01 openvpn]# cp /usr/share/doc/openvpn/sample/sample-config-files/server.conf /etc/openvpn/server/
```
#### 7丶拷贝server证书和私钥
``` shell
[root@linux-node-01 openvpn]# cp /data/openvpn/pki/dh.pem /etc/openvpn/server/
[root@linux-node-01 openvpn]# cp /data/openvpn/pki/ca.crt /etc/openvpn/server/
[root@linux-node-01 openvpn]# cp /data/openvpn/pki/issued/server.crt /etc/openvpn/server/
[root@linux-node-01 openvpn]# cp /data/openvpn/pki/private/server.key /etc/openvpn/server/
```
#### 8丶修改server端配置文件
``` shell
[root@linux-node-01 ~]# vim /etc/openvpn/server/server.conf

port 1194                                       ;端口
proto udp                                       ;TCP/UDP协议
dev tun                                         ;采用路由隧道模式tun
ca ca.crt                                       ;ca证书件位置
cert server.crt                                 ;服务端公钥名称
key server.key                                  ;服务端私钥名称
dh dh.pem                                       ;交换证书
tls-auth ta.key 0                               ;防止DDOC,服务器端配置为0 客户端配置为1
server 10.8.0.0 255.255.255.0                   ;给客户端分配地址池，注意：不能和VPN服务器内段有相同
ifconfig-pool-persist ipp.txt                   ;地址池记录文件位置
push "route 192.168.10.0 255.255.255.0"         ;允许客户端访问内网192.168.10.0/24段
client-to-client                                ;客户端与客户端之间支持通信
duplicate-cn                                    ;允许一个用户从多个PC端同时保持连接
keepalive 10 120                                ;存活时间，10秒ping一次,120 如未收到响应则视为断线
max-clients 100                                 ;最多允许100个客户端连接
persist-key                                     ;通过keepalive检测超时后，重新启动VPN，不重新读取keys，保留第⼀次使⽤的keys。
persist-tun                                     ;检测超时后，重新启动VPN，一直保持tun是linkup的。否则网络会先linkdown然后再linkup
status openvpn-status.log                       ;日志记录位置
verb 3                                          ;openvpn版本
#以下参数为用户认证使用
script-security 3
auth-user-pass-verify /etc/openvpn/server/checkpsw.sh via-env
username-as-common-name
verify-client-cert none
# 表示只使用用户名密码⽅式验证，不加该参数，则代表需要证书、⽤户名、密码多重验证登录
# client-cert-not-required
```
#### 9丶编写用户认证脚本文件 (脚本是由openvpn官网提供)
``` shell
[root@linux-node-01 ~]# vim /etc/openvpn/server/checkpsw.sh

#!/usr/bin/env bash
PASSFILE="/etc/openvpn/server/psw-file"
LOG_FILE="/etc/openvpn/server/openvpn-password.log"
TIME_STAMP=`date "+%Y-%m-%d %T"`

if [ ! -r "${PASSFILE}" ]; then
  echo "${TIME_STAMP}: Could not open password file \"${PASSFILE}\" for reading." >>${LOG_FILE}
  exit 1
fi

CORRECT_PASSWORD=`awk '!/^;/&&!/^#/&&$1=="'${username}'"{print $2;exit}' ${PASSFILE}`

if [ "${CORRECT_PASSWORD}" = "" ]; then 
  echo "${TIME_STAMP}: User does not exist: username=\"${username}\", password=\"${password}\"." >> ${LOG_FILE}
  exit 1
fi

if [ "${password}" = "${CORRECT_PASSWORD}" ]; then 
  echo "${TIME_STAMP}: Successful authentication: username=\"${username}\"." >> ${LOG_FILE}
  exit 0
fi

echo "${TIME_STAMP}: Incorrect password: username=\"${username}\",     password=\"${password}\"." >> ${LOG_FILE}
exit 1

# 增加执行权限
[root@linux-node-01 ~]# chmod +x /etc/openvpn/server/checkpsw.sh
```
#### 创建用户密码文件
``` shell
[root@linux-node-01 ~]# vim /etc/openvpn/server/psw-file
xusx 123456
```
#### 10丶启动服务
``` shell
# 使用这个方式启动, 需要把配置文件中的证书和私钥拷贝到server目录中
[root@linux-node-01 openvpn]# systemctl start openvpn-server@server
# 使用命令后台启动则不需要重新拷贝
[root@linux-node-01 openvpn]# openvpn --daemon --config /etc/openvpn/server.conf
```
#### 开启`内核转发`, `配置安全组`, `DNAT`, `自定义路由条目`
``` shell
[root@linux-node-01 ~]# echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
[root@linux-node-01 ~]# sysctl -p
[root@linux-node-01 ~]# iptables -t nat -A POSTROUTING -s 10.8.0.1/24 -j MASQUERADE
[root@linux-node-01 ~]# iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -j SNAT --to 192.168.10.1
```
#### 11丶拷贝client证书和私钥到win/mac
``` shell
[root@linux-node-01 client]# cp /data/openvpn/pki/ca.crt .
[root@linux-node-01 client]# cp /data/openvpn/pki/private/client.key .
[root@linux-node-01 client]# cp /data/openvpn/pki/issued/client.crt .
[root@linux-node-01 client]# cp /etc/openvpn/ta.key .
[root@linux-node-01 client]# cp /usr/share/doc/openvpn/sample/sample-config-files/client.conf ./client.ovpn
```
#### 修改client端配置文件
``` shell
[root@linux-node-01 client]# grep -Ev "#|^$|;" client.ovpn

client                         ;指定当前VPN是客户端
dev tun                        ;使用tun隧道传输协议
proto udp                      ;使用udp协议传输数据
remote openvpn.3bgm.cn 1194    ;openvpn服务器IP地址端口
resolv-retry infinite          ;断线自动重新连接，在网络不稳定的情况下非常有用
nobind                         ;不绑定本地特定的端口号
persist-key                    ;通过keepalive检测超时后，重新启动VPN，不重新读取keys，保留第一次使用的keys
persist-tun                    ;检测超时后，重新启动VPN，一直保持tun是linkup的。否则网络会先linkdown然后再linkup
ca ca.crt                      ;指定CA证书的文件路径
cert client.crt                ;指定当前客户端的证书的件路径
key client.key                 ;指定当前客户端的私钥的件路径
remote-cert-tls server         ;指定远程服务器所使用的证书
tls-auth ta.key 1              ;防御DDOC, 淹没等恶意攻击行为
verb 3                         ;指定日志文件的记录详细级别，可选0-9，等级越高志内容越详细
auth-user-pass                 ;用户密码认证
```

## 二 在Linux上安装VPN
``` shell
[root@bj-172-5 ~]# cd /etc/openvpn/client/
# 上传客户端配置和证书
[root@bj-172-5 client]# ls
ca.crt  client.crt  client.key  client.ovpn  ta.key

# 修改openvpn守护进程
[root@bj-172-5 client]# vim /usr/lib/systemd/system/openvpn-client@.service
13 ExecStart=/usr/sbin/openvpn --suppress-timestamps --nobind --config client.ovpn

# 设置开机启动.  启动openvpn-client
[root@bj-172-5 client]# systemctl enable openvpn-client@server.service
[root@bj-172-5 client]# systemctl start openvpn-client@server.service
```
