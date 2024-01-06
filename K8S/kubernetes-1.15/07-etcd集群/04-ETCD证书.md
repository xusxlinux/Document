#### 安装cfssl
``` shell
# 下载签发软件, 重命名
wget https://github.com/cloudflare/cfssl/releases/download/v1.5.0/cfssl_1.5.0_linux_amd64 -O /usr/bin/cfssl
wget https://github.com/cloudflare/cfssl/releases/download/v1.5.0/cfssljson_1.5.0_linux_amd64 -O /usr/bin/cfssl-json
wget https://github.com/cloudflare/cfssl/releases/download/v1.5.0/cfssl-certinfo_1.5.0_linux_amd64 -O /usr/bin/cfssl-certinfo

# 添加可执行权限
chmod +x /usr/bin/cfssl*
```

#### 创建密钥生成目录
``` shell
mkdir -pv /opt/certs
```

#### 创建生成CA证书签名请求(csr)的JSON配置文件
``` shell
vim /opt/certs/ca-csr.json
{
    "CN": "Kubernetes",
    "hosts": [
    ],
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "ST": "beijing",
            "L": "beijing",
            "O": "chain",
            "OU": "ops"
        }
    ],
    "ca": {
        "expiry": "175200h"
    }
}
```

#### 创建基于根证书的config配置文件
``` shell
vim /opt/certs/ca-config.json
{
    "signing": {
        "default": {
            "expiry": "175200h"
        },
        "profiles": {
            "server": {
                "expiry": "175200h",
                "usages": [
                    "signing",
                    "key encipherment",
                    "server auth"
                ]
            },
            "client": {
                "expiry": "175200h",
                "usages": [
                    "signing",
                    "key encipherment",
                    "client auth"
                ]
            },
            "peer": {
                "expiry": "175200h",
                "usages": [
                    "signing",
                    "key encipherment",
                    "server auth",
                    "client auth"
                ]
            }
        }
    }
}
```

#### 生成ca证书和私钥
``` shell
# 拷贝证书、私钥,注意属性600
cfssl gencert -initca ca-csr.json | cfssl-json -bare ca
```

#### 签发etcd-peer证书
``` shell
vim /opt/certs/etcd-peer-csr.json 
{
    "CN": "k8s-etcd",
    "hosts": [
        "10.4.7.11",
        "10.4.7.12",
        "10.4.7.21",
        "10.4.7.22"
    ],
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "ST": "beijing",
            "L": "beijing",
            "O": "chain",
            "OU": "ops"
        }
    ]
}
```

#### 生成etcd证书和私钥
``` shell
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=peer etcd-peer-csr.json |cfssl-json -bare etcd-peer
```

#### 把证书放到etcd的证书目录下
``` shell
# 把该目录下生成的三张pem证书拷贝到etcd的证书目录(所有的etcd都要拷贝)
cp ca.pem etcd-peer.pem etcd-peer-key.pem /opt/etcd/certs/

# 拷贝到etcd服务器的证书目录
scp *.pem k8s-master-02:/opt/etcd/certs/
scp *.pem k8s-node-01:/opt/etcd/certs/
```
