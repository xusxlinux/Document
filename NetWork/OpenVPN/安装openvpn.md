## 配置服务端
#### 安装OpenVPN 证书加密

[easy-rsa-old下载](https://github.com/OpenVPN/easy-rsa-old)
``` shell
[root@hz-186 ~]# unzip easy-rsa-old-master.zip
[root@hz-186 ~]# cd easy-rsa-old-master/easy-rsa/2.0/
```

#### 配置签发机构信息
``` shell
[root@hz-186 2.0]# vim vars 
export KEY_COUNTRY="CN"
export KEY_PROVINCE="BeiJing"
export KEY_CITY="BeiJing"
export KEY_ORG="WM"
export KEY_EMAIL="shaoxin.xu@wm-motor.com"
export KEY_CN=xusx
export KEY_NAME=xusx
export KEY_OU=xusx
export PKCS11_MODULE_PATH=changeme
export PKCS11_PIN=1234
```

#### 初始化配置文件
```
[root@hz-186 2.0]# source vars 
[root@hz-186 2.0]# ./clean-all
```

#### 生成证书
``` shell
# 不需要设置密码
[root@hz-186 2.0]# ./build-ca 


# 最后输入两个 yes
[root@hz-186 2.0]# ./build-key-server server
[root@hz-186 2.0]# ./build-key client

[root@hz-186 2.0]# ./build-dh
```

#### 配置openvpn服务器证书
``` shell
[root@hz-186 ~]# yum install openvpn -y

[root@hz-186 openvpn]# cp ~/easy-rsa-old-master/easy-rsa/2.0/keys/server.crt /etc/openvpn/keys/
[root@hz-186 openvpn]# cp ~/easy-rsa-old-master/easy-rsa/2.0/keys/server.key /etc/openvpn/keys/
[root@hz-186 openvpn]# cp ~/easy-rsa-old-master/easy-rsa/2.0/keys/ca.crt /etc/openvpn/keys/
[root@hz-186 openvpn]# cp ~/easy-rsa-old-master/easy-rsa/2.0/keys/dh2048.pem /etc/openvpn/keys/
```

#### server服务端 模板配置文件
``` shell
[root@hz-186 openvpn]# cp /usr/share/doc/openvpn-2.4.12/sample/sample-config-files/server.conf /etc/openvpn/

[root@hz-186 ~]# vim /etc/openvpn/server.conf
78 ca ./keys/ca.crt
79 cert ./keys/server.crt
80 key ./keys/server.key
85 dh ./keys/dh2048.pem
43 push "route 172.16.199.0 255.255.255.0"
244 tls-auth keys/ta.key 0 # This file is secret
253 cipher AES-256-GCM
```

#### 防止ddoc攻击
``` shell
[root@hz-186 keys]# cd /etc/openvpn/keys
[root@hz-186 keys]# openvpn --genkey --secret ta.key
```

#### 启动OpenVPN
``` shell
[root@hz-186 ~]# openvpn --daemon --config /etc/openvpn/server.conf
[root@hz-186 ~]# netstat -lntup | grep 1194
```

## 配置客户端
#### 创建win10客户端使用的配置文件
``` shell
[root@hz-186 ~]# mkdir -pv client

[root@hz-186 ~]# cp /usr/share/doc/openvpn-2.4.12/sample/sample-config-files/client.conf ~/client/client.ovpn

[root@hz-186 ~]# vim ~/client/client.ovpn
42 remote 47.97.20.241 1194
116 cipher AES-256-GCM
```

``` shell
[root@hz-186 ~]# cp easy-rsa-old-master/easy-rsa/2.0/keys/ca.crt ~/client/
[root@hz-186 ~]# cp easy-rsa-old-master/easy-rsa/2.0/keys/client.crt ~/client/
[root@hz-186 ~]# cp easy-rsa-old-master/easy-rsa/2.0/keys/client.key ~/client/
[root@hz-186 ~]# cp /etc/openvpn/keys/ta.key ~/client/
```

#### 额外配置,访问局域网的服务器
``` shell
# 列表为空
[root@hz-186 ~]# iptables -t nat -L

# 设置iptables规则, 放开拨号网段, 访问局域网的服务器(允许数据包在不同的网络接口之间转发)
[root@hz-186 ~]# iptables -t nat -A POSTROUTING -s 10.8.0.1/24 -j MASQUERADE
[root@hz-186 ~]# iptables -t nat -L

# 开启内核转发
[root@hz-186 ~]# echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
[root@hz-186 ~]# sysctl -p

# 设置云服务器的安全组: 放开UDP端口1194
```
