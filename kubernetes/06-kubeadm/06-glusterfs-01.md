
``` shell
# 所有glusterfs节点安装源
yum install centos-release-gluster -y
# 所有节点安装最新的glusterfs软件包
yum install glusterfs glusterfs-server glusterfs-fuse glusterfs-rdma glusterfs-geo-replication -y
# 所有节点加入开机自启动
systemctl start glusterd && systemctl enable glusterd && systemctl status glusterd
``` 

``` shell
# 所有存储主机加入信任存储池, 已经包含第一个节点 hdss7-11
[root@hdss7-11 ~]# gluster peer probe hdss7-12.host.com
[root@hdss7-11 ~]# gluster peer probe hdss7-21.host.com
[root@hdss7-11 ~]# gluster peer probe hdss7-22.host.com
```

``` shell
# 查看集群状态
[root@hdss7-11 ~]# gluster peer status
Number of Peers: 2

Hostname: hdss7-12.host.com
Uuid: 8e30f6c5-8bca-4f04-867e-ad4e509854ad
State: Peer in Cluster (Connected)

Hostname: hdss7-21.host.com
Uuid: e1008d0d-d76b-4268-8ef8-2db6548df8cd
State: Peer in Cluster (Connected)


# 查看列表
[root@hdss7-11 ~]# gluster pool list
UUID					Hostname         	State
8e30f6c5-8bca-4f04-867e-ad4e509854ad	hdss7-12.host.com	Connected 
e1008d0d-d76b-4268-8ef8-2db6548df8cd	hdss7-21.host.com	Connected 
446b6870-3222-4ed1-a194-e3b55b33aff6	hdss7-22.host.com	Connected 
6b279456-4ff5-4ce2-a52a-b9cd5fff4c9c	localhost        	Connected
```

``` shell
# 所有存储节点上安装xfs支持包
[root@hdss7-11 ~]# yum install xfsprogs -y 
# 所有存储节点先做分区
[root@hdss7-11 ~]# fdisk /dev/sdb
# 所有文件系统格式化
[root@hdss7-11 ~]# mkfs.xfs /dev/sdb1
# 所有创建挂载磁盘并挂载
[root@hdss7-11 ~]# mkdir -pv /storage/brick1
[root@hdss7-11 ~]# mount /dev/sdb1 /storage/brick1/
# 所有开机自动挂载
[root@hdss7-11 ~]# echo "/dev/sdb1 /storage/brick1                       xfs     defaults        0 0" >> /etc/fstab
```

#### 分布卷
``` shell
# 创建 分布卷 应用场景：大量小文件   
[root@hdss7-11 ~]# gluster volume create gv1 hdss7-11.host.com:/storage/brick1 hdss7-12.host.com:/storage/brick1 hdss7-21.host.com:/storage/brick1 hdss7-22.host.com:/storage/brick1 force
volume create: gv1: success: please start the volume to access data



# 创建的卷需要启动后才能使用
[root@hdss7-11 ~]# gluster volume start gv1



# 查看一下启动后的状态
[root@hdss7-11 ~]# gluster volume status gv1
Status of volume: gv1
Gluster process                             TCP Port  RDMA Port  Online  Pid
------------------------------------------------------------------------------
Brick hdss7-11.host.com:/storage/brick1     49152     0          Y       31624
Brick hdss7-12.host.com:/storage/brick1     49152     0          Y       25084
Brick hdss7-21.host.com:/storage/brick1     49152     0          Y       22266
Brick hdss7-22.host.com:/storage/brick1     49152     0          Y       70303
 
Task Status of Volume gv1
------------------------------------------------------------------------------
There are no active volume tasks



# 卷的info信息
[root@hdss7-11 ~]# gluster volume info
Volume Name: gv1
Type: Distribute
Volume ID: e9d718ef-fbce-4382-9797-3c82b1b0b3d2
Status: Started
Snapshot Count: 0
Number of Bricks: 4
Transport-type: tcp
Bricks:
Brick1: hdss7-11.host.com:/storage/brick1
Brick2: hdss7-12.host.com:/storage/brick1
Brick3: hdss7-21.host.com:/storage/brick1
Brick4: hdss7-22.host.com:/storage/brick1
Options Reconfigured:
storage.fips-mode-rchecksum: on
transport.address-family: inet
nfs.disable: on



# 卷的停止
[root@hdss7-11 ~]# gluster volume stop gv1
Stopping volume will make its data inaccessible. Do you want to continue? (y/n) y
volume stop: gv1: success



# 卷的使用, 创建一个临时挂载点
[root@hdss7-11 ~]# mkdir -pv /data1
[root@hdss7-11 ~]# mount -t glusterfs hdss7-11.host.com:/gv1 /data1



# 测试
[root@hdss7-11 data1]# cd /data1 && touch `seq 100`
[root@hdss7-11 ~]# ls /storage/brick1/ | wc -l
19
[root@hdss7-12 ~]# ls /storage/brick1/ | wc -l
27
[root@hdss7-21 ~]# ls /storage/brick1/ | wc -l
23
[root@hdss7-22 ~]# ls /storage/brick1/ | wc -l
30
```

#### 复制卷
``` shell
# 创建 复制卷 应用场景：对可靠性高和读写性能要求高的场景,  读性能好,写性能差  |   replica = brick

# 将分布卷删除
[root@hdss7-11 ~]# gluster volume delete gv1



# 创建复制卷
[root@hdss7-11 ~]# gluster volume create gv1 replica 2 hdss7-11.host.com:/storage/brick1 hdss7-12.host.com:/storage/brick1 hdss7-21.host.com:/storage/brick1 hdss7-22.host.com:/storage/brick1 force
volume create: gv1: success: please start the volume to access data



# 启动复制卷
[root@hdss7-11 ~]# gluster volume start gv1
volume start: gv1: success



#查看一下启动后的状态
[root@hdss7-11 ~]# gluster volume status gv1
Status of volume: gv1
Gluster process                             TCP Port  RDMA Port  Online  Pid
------------------------------------------------------------------------------
Brick hdss7-11.host.com:/storage/brick1     49152     0          Y       67843
Brick hdss7-12.host.com:/storage/brick1     49152     0          Y       59825
Brick hdss7-21.host.com:/storage/brick1     49152     0          Y       55051
Brick hdss7-22.host.com:/storage/brick1     49152     0          Y       103275
Self-heal Daemon on localhost               N/A       N/A        Y       67860
Self-heal Daemon on hdss7-22.host.com       N/A       N/A        Y       103292
Self-heal Daemon on hdss7-12.host.com       N/A       N/A        Y       59842
Self-heal Daemon on hdss7-21.host.com       N/A       N/A        Y       55068
 
Task Status of Volume gv1
------------------------------------------------------------------------------
There are no active volume tasks



# 卷的info信息
[root@hdss7-11 ~]# gluster volume info
Volume Name: gv1
Type: Distributed-Replicate
Volume ID: 35cd2240-3d5b-48a3-85f9-da6ecb4d4628
Status: Created
Snapshot Count: 0
Number of Bricks: 2 x 2 = 4
Transport-type: tcp
Bricks:
Brick1: hdss7-11.host.com:/storage/brick1
Brick2: hdss7-12.host.com:/storage/brick1
Brick3: hdss7-21.host.com:/storage/brick1
Brick4: hdss7-22.host.com:/storage/brick1
Options Reconfigured:
cluster.granular-entry-heal: on
storage.fips-mode-rchecksum: on
transport.address-family: inet
nfs.disable: on
performance.client-io-threads: off



# 挂载复制卷
[root@hdss7-11 ~]# mount -t glusterfs hdss7-11.host.com:/gv1 /data1
```

#### 条带卷
``` shell
# 条带卷 弃用!!!
```

#### 分布式复制卷
``` shell
# 最常用
```

#### 分布式条带卷
``` shell
# 分布式条带卷 弃用!!!
```

#### 条带复制卷
``` shell
# 条带复制卷 弃用!!!
```

#### 扩容
``` shell

```

#### 缩容
```

```

#### 替换
``` shell

```
