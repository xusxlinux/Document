[github heketi使用方式](https://github.com/heketi/heketi/blob/master/docs/admin/server.md)
```
# 安装client
yum install centos-release-gluster -y
yum install glusterfs glusterfs-server glusterfs-fuse glusterfs-rdma glusterfs-geo-replication -y
yum install heketi heketi-client -y

# gluster服务器要开启如下模块
modprobe dm_snapshot
modprobe dm_mirror
modprobe dm_thin_pool


# -t：秘钥类型；
# -q：安静模式；
# -f：指定生成秘钥的目录与名字
# -N：秘钥密码，""即为空

ssh-keygen -t rsa -q -f /etc/heketi/heketi_key -N ""
chown heketi:heketi /etc/heketi/heketi_key

ssh-copy-id -i /etc/heketi/heketi_key.pub root@hdss7-11.host.com
ssh-copy-id -i /etc/heketi/heketi_key.pub root@hdss7-12.host.com
ssh-copy-id -i /etc/heketi/heketi_key.pub root@hdss7-21.host.com
ssh-copy-id -i /etc/heketi/heketi_key.pub root@hdss7-22.host.com
```

``` shell
# 配置文件详解
vim /etc/heketi/heketi.json

{
  "_port_comment": "Heketi Server Port Number",
  # 启用端口
  "port": "8080",

  "_use_auth": "Enable JWT authorization. Please enable for deployment",
  # JWT认证是否开启
  "use_auth": true,

  # JWT认证开启情况下配置
  "_jwt": "Private keys for access",
  "jwt": {
    "_admin": "Admin has access to all APIs",
    "admin": {
      # 超级用户的密码，超级用户可以使用所有api
      "key": "admin@123"
    },
    "_user": "User only has access to /volumes endpoint",
    "user": {
      # 普通用户的密码，普通用户可以使用卷资源，即集群、节点之间的关系无法操作
      "key": "user@123"
    }
  },

  "_glusterfs_comment": "GlusterFS Configuration",
  "glusterfs": {
     # 执行命令的方式
    "_executor_comment": [
      "Execute plugin. Possible choices: mock, ssh",
      # 开发者模式，测试功能用
      "mock: This setting is used for testing and development.",
      "      It will not send commands to any node.",
      # ssh是正常生产环境使用的
      "ssh:  This setting will notify Heketi to ssh to the nodes.",
      "      It will need the values in sshexec to be configured.",
      # 当gfs集群在kubernetes作为ds跑的时候使用
      "kubernetes: Communicate with GlusterFS containers over",
      "            Kubernetes exec api."
    ],
    "executor": "ssh",

    # 调用ssh时配置
    "_sshexec_comment": "SSH username and private key file information",
    "sshexec": {
      # ssh执行用户的私钥，heketi用户需要该文件读权限
      "keyfile": "/etc/heketi/heketi_key",
      # ssh执行用户，生产不用root
      "user": "root",
      # ssh端口
      "port": "22",
      # 系统fstab路径
      "fstab": "/etc/fstab"
    },

    "_kubeexec_comment": "Kubernetes configuration",
    "kubeexec": {
      # 调用k8s时配置
      "host" :"https://apiserver.chain.com:6443",
      # k8s证书
      "cert" : "/etc/heketi/apiserver.crt",
      # 是否启用不安全模式
      "insecure": false,
      # k8s用户
      "user": "kubernetes username",
      # k8s密码
      "password": "password for kubernetes user",
      # 项目所处命名空间
      "namespace": "OpenShift project or Kubernetes namespace",
      "fstab": "Optional: Specify fstab file on node.  Default is /etc/fstab"
    },

    "_db_comment": "Database file name",
    # heketi会有一个自己的小库，这个默认地址即可
    "db": "/var/lib/heketi/heketi.db",

    "_loglevel_comment": [
      "Set log level. Choices are:",
      "  none, critical, error, warning, info, debug",
      "Default is warning"
    ],
    # 日志等级，日志会在/var/log/messages里显示
    "loglevel" : "warning"
  }
}
```

```
# 启动heketi进程
systemctl start heketi.service
systemctl enable heketi.service 
systemctl status heketi.service
```

``` json
cat /etc/heketi/topology.json

{"clusters": [
    {
      "nodes": [
        {
          "node": {
            "hostnames": {
              "manage": [
                "hdss7-11.host.com"
              ],
              "storage": [
                "10.4.7.11"
              ]
            },
            "zone": 1
          },
          "devices": [
            {
              "name": "/dev/sdb",
              "destroydata": false
            }
          ]
        },
        {
          "node": {
            "hostnames": {
              "manage": [
                "hdss7-12.host.com"
              ],
              "storage": [
                "10.4.7.12"
              ]
            },
            "zone": 1
          },
          "devices": [
            {
              "name": "/dev/sdb",
              "destroydata": false
            }
          ]
        },
        {
          "node": {
            "hostnames": {
              "manage": [
                "hdss7-21.host.com"
              ],
              "storage": [
                "10.4.7.21"
              ]
            },
            "zone": 1
          },
          "devices": [
            {
              "name": "/dev/sdb",
              "destroydata": false
            }
          ]
        },
        {
          "node": {
            "hostnames": {
              "manage": [
                "hdss7-22.host.com"
              ],
              "storage": [
                "10.4.7.22"
              ]
            },
            "zone": 1
          },
          "devices": [
            {
              "name": "/dev/sdb",
              "destroydata": false
            }
          ]
        }
      ]
    }
  ]
}
```


``` shell

# 添加环境变量
export HEKETI_CLI_SERVER=http://10.4.7.200:8080
export HEKETI_CLI_USER=admin
export HEKETI_CLI_KEY=admin@123



# 使用heketi创建卷
heketi-cli --user admin --secret admin@123 -s http://0.0.0.0:8080 topology load --json=topology.json

# 显示所有信息
heketi-cli --user admin --secret admin@123 topology info

# 创建一个1G的磁盘, 副本数为2
heketi-cli --user admin --secret admin@123 volume create --size=1 --replica=2

# 删除磁盘(挂载后卸载不掉可以使用这样的方式)
heketi-cli --user admin --secret admin@123 volume delete c3cd919418407f54c2bbef18e4f64721 (Cluster Id)

# 查看信息
heketi-cli cluster info 5d5dd154de3da4b4617502fd007d8a40
heketi-cli node list
heketi-cli node info 878b339838e300c7a4c1d424843477d2
heketi-cli device info abd32f316932cac0d3a1caa159892cca
```

``` shell
[root@hdss7-200 heketi]# heketi-cli --user admin --secret admin@123 -s http://0.0.0.0:8080 topology load --json=topology.json

Creating cluster ... ID: 5d5dd154de3da4b4617502fd007d8a40
	Allowing file volumes on cluster.
	Allowing block volumes on cluster.
	Creating node hdss7-11.host.com ... ID: 878b339838e300c7a4c1d424843477d2
		Adding device /dev/sdb ... OK
	Creating node hdss7-12.host.com ... ID: 32fab967535a19f4ceaa1ff4dec89068
		Adding device /dev/sdb ... OK
	Creating node hdss7-21.host.com ... ID: c44fc2c89e88c5efbad387779e3cbcde
		Adding device /dev/sdb ... OK
	Creating node hdss7-22.host.com ... ID: 6b6c06bfa1bbe22c137f365759452bc5
		Adding device /dev/sdb ... OK
```

``` shell
[root@hdss7-200 storage-class]# heketi-cli --user admin --secret admin@123 topology info

Cluster Id: 5d5dd154de3da4b4617502fd007d8a40

    File:  true
    Block: true

    Volumes:


    Nodes:

	Node Id: 32fab967535a19f4ceaa1ff4dec89068
	State: online
	Cluster Id: 5d5dd154de3da4b4617502fd007d8a40
	Zone: 1
	Management Hostnames: hdss7-12.host.com
	Storage Hostnames: 10.4.7.12
	Devices:
		Id:d8dfd16dc9389ea8708cd64682d0345e   Name:/dev/sdb            State:online    Size (GiB):9       Used (GiB):0       Free (GiB):9       
			Bricks:

	Node Id: 6b6c06bfa1bbe22c137f365759452bc5
	State: online
	Cluster Id: 5d5dd154de3da4b4617502fd007d8a40
	Zone: 1
	Management Hostnames: hdss7-22.host.com
	Storage Hostnames: 10.4.7.22
	Devices:
		Id:9f7fbf4f11ebab7a9c5b0a36f62dfbeb   Name:/dev/sdb            State:online    Size (GiB):9       Used (GiB):0       Free (GiB):9       
			Bricks:

	Node Id: 878b339838e300c7a4c1d424843477d2
	State: online
	Cluster Id: 5d5dd154de3da4b4617502fd007d8a40
	Zone: 1
	Management Hostnames: hdss7-11.host.com
	Storage Hostnames: 10.4.7.11
	Devices:
		Id:abd32f316932cac0d3a1caa159892cca   Name:/dev/sdb            State:online    Size (GiB):9       Used (GiB):0       Free (GiB):9       
			Bricks:

	Node Id: c44fc2c89e88c5efbad387779e3cbcde
	State: online
	Cluster Id: 5d5dd154de3da4b4617502fd007d8a40
	Zone: 1
	Management Hostnames: hdss7-21.host.com
	Storage Hostnames: 10.4.7.21
	Devices:
		Id:8504695b4ef8e751da818276600c0c77   Name:/dev/sdb            State:online    Size (GiB):9       Used (GiB):0       Free (GiB):9       
			Bricks:
```


``` shell
# heketi创建后
[root@hdss7-200 storage-class]# heketi-cli --user admin --secret admin@123 volume create --size=1 --replica=2

Name: vol_c3cd919418407f54c2bbef18e4f64721		# 这个名字记下
Size: 1
Volume Id: c3cd919418407f54c2bbef18e4f64721
Cluster Id: 5d5dd154de3da4b4617502fd007d8a40
Mount: 10.4.7.12:vol_c3cd919418407f54c2bbef18e4f64721
Mount Options: backup-volfile-servers=10.4.7.22,10.4.7.11,10.4.7.21
Block: false
Free Size: 0
Reserved Size: 0
Block Hosting Restriction: (none)
Block Volumes: []
Durability Type: replicate
Distribute Count: 1
Replica Count: 2
```


``` shell
# 挂载磁盘
[root@hdss7-11 ~]# mount -t glusterfs -o backup-volfile-servers=10.4.7.22,10.4.7.11,10.4.7.21,log-level=WARNING hdss7-12.host.com:/vol_c3cd919418407f54c2bbef18e4f64721 /mnt/
Invalid option 10.4.7.11


[root@hdss7-11 ~]# df -Th
/dev/mapper/vg_abd32f316932cac0d3a1caa159892cca-brick_55187b5b3d3557272a3de3734bcd9136 xfs      1014M   33M  982M   4% /var/lib/heketi/mounts/vg_abd32f316932cac0d3a1caa159892cca/brick_55187b5b3d3557272a3de3734bcd9136
```


``` shell

```
