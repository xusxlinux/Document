
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
[root@hdss7-11 ~]# mkfs.xfs -i size=512 /dev/sdb1
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
# 最常用 分布式复制卷   |   replica = brick * 2


[root@hdss7-11 ~]# gluster volume stop gv1
[root@hdss7-11 ~]# gluster volume delete gv1



# 分布式复制卷
[root@hdss7-11 ~]# gluster volume create gv1 replica 2 hdss7-11.host.com:/storage/brick1 hdss7-12.host.com:/storage/brick1 hdss7-21.host.com:/storage/brick1 hdss7-22.host.com:/storage/brick1 force
volume create: gv1: success: please start the volume to access data



# 启动
[root@hdss7-11 ~]# gluster volume start gv1
volume start: gv1: success



# 查看信息
[root@hdss7-11 ~]# gluster volume info gv1
 
Volume Name: gv1
Type: Distributed-Replicate
Volume ID: e85616b7-f2e1-4691-a1c1-64b7dd51440f
Status: Started
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

# 创建集群
[root@hdss7-11 ~]# gluster volume create gv1  hdss7-11.host.com:/storage/brick1 hdss7-21.host.com:/storage/brick1 force
volume create: gv1: success: please start the volume to access data


# 启动
[root@hdss7-11 ~]# gluster volume start gv1
volume start: gv1: success



# 查看信息
[root@hdss7-11 ~]# gluster volume info gv1
 
Volume Name: gv1
Type: Distribute
Volume ID: 47d5e036-920e-4a68-9694-3fd0b878ca58
Status: Started
Snapshot Count: 0
Number of Bricks: 2
Transport-type: tcp
Bricks:
Brick1: hdss7-11.host.com:/storage/brick1
Brick2: hdss7-21.host.com:/storage/brick1
Options Reconfigured:
storage.fips-mode-rchecksum: on
transport.address-family: inet
nfs.disable: on



# 挂载
[root@hdss7-11 ~]# mount -t glusterfs hdss7-11.host.com:/gv1 /data1



# 扩容
[root@hdss7-11 ~]# gluster volume add-brick gv1  hdss7-12.host.com:/storage/brick1 hdss7-22.host.com:/storage/brick1 force
volume add-brick: success



# 当新的磁盘加入到旧的集群中,需要平衡布局
[root@hdss7-11 ~]# gluster volume rebalance gv1 start
volume rebalance: gv1: success: Rebalance on gv1 has been started successfully. Use rebalance status command to check status of the rebalance process.
ID: 0ea39109-c5c5-4c9d-aa22-debd92382065



# 查看状态
[root@hdss7-11 ~]# gluster volume rebalance gv1 status
                                    Node Rebalanced-files          size       scanned      failures       skipped               status  run time in h:m:s
                               ---------      -----------   -----------   -----------   -----------   -----------         ------------     --------------
                       hdss7-12.host.com                0        0Bytes            27             0             0            completed        0:00:01
                       hdss7-21.host.com                0        0Bytes            28             0             0            completed        0:00:01
                       hdss7-22.host.com                0        0Bytes            27             0             3            completed        0:00:01
                               localhost                0        0Bytes            46             0            19            completed        0:00:00
volume rebalance: gv1: success
```

#### 缩容
```
# 移除其中一个坏掉的存储磁盘节点
[root@hdss7-11 ~]# gluster volume remove-brick gv1  hdss7-22.host.com:/storage/brick1 force
Remove-brick force will not migrate files from the removed bricks, so they will no longer be available on the volume.
Do you want to continue? (y/n) y



# 查看下状态
[root@hdss7-11 ~]# gluster volume remove-brick gv1  hdss7-22.host.com:/storage/brick1 status
volume remove-brick status: failed: remove-brick not started for volume gv1.



# 查看磁盘的信息
[root@hdss7-11 ~]# gluster volume info gv1
 
Volume Name: gv1
Type: Distribute
Volume ID: 461b8f32-f59d-43b8-ad7e-50e3cb4fdae3
Status: Started
Snapshot Count: 0
Number of Bricks: 3
Transport-type: tcp
Bricks:
Brick1: hdss7-11.host.com:/storage/brick1
Brick2: hdss7-12.host.com:/storage/brick1
Brick3: hdss7-21.host.com:/storage/brick1
Options Reconfigured:
performance.client-io-threads: on
storage.fips-mode-rchecksum: on
transport.address-family: inet
nfs.disable: on



# 重新 加载磁盘结构
[root@hdss7-11 ~]# gluster volume rebalance gv1 start
volume rebalance: gv1: success: Rebalance on gv1 has been started successfully. Use rebalance status command to check status of the rebalance process.
ID: 8fa710a1-0506-4999-9bf7-c9ae74e2467f



# 查看加载后的状态
[root@hdss7-11 ~]# gluster volume rebalance gv1 status
                                    Node Rebalanced-files          size       scanned      failures       skipped               status  run time in h:m:s
                               ---------      -----------   -----------   -----------   -----------   -----------         ------------     --------------
                       hdss7-12.host.com                4        0Bytes            28             0             0            completed        0:00:00
                       hdss7-21.host.com                0        0Bytes            28             0             0            completed        0:00:00
                               localhost                0        0Bytes            46             0            46            completed        0:00:00
volume rebalance: gv1: success
```

#### 替换
``` shell
# replace-brick老版本的命令
[root@hdss7-11 ~]# gluster volume replace-brick gv1 hdss7-21.host.com:/storage/brick1 hdss7-22.host.com:/storage/brick1 commit force
volume replace-brick: failed: replace-brick is not permitted on distribute only volumes. Please use add-brick and remove-brick operations instead.


# 按照提示,需要移除替换的盘,在把新的磁盘加入到集群中
Please use add-brick and remove-brick operations instead.
```

#### 
``` shell
# 设置网段访问挂载glusterfs
[root@hdss7-11 ~]# gluster volume set gv1 auth.allow 10.4.7.*
volume set: success


# 查看
[root@hdss7-11 ~]# gluster volume info
auth.allow: 10.4.7.*
```
