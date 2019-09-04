## flannel无法启动
#### 原因
```
分配的子网数太少
Sep  4 08:40:48 linux-node3 flanneld: E0904 08:40:48.576291    1989 main.go:349] Couldn't fetch network config: Network is too small. Minimum useful network prefix is /28
```
#### 解决方法
```
仅在etcd01上操作
[root@linux-node1 bin]# ./etcdctl \
--ca-file=/opt/kubernetes/ssl/ca.pem -cert-file=/opt/kubernetes/ssl/server.pem --key-file=/opt/kubernetes/ssl/server-key.pem \
--endpoints="https://192.168.12.11:2379,https://192.168.12.12:2379,https://192.168.12.13:2379" \
set /coreos.com/network/config '{"Network": "10.0.0.0/8","Backend": {"Type": "vxlan"}}
```
#### 解决结果
```
[root@linux-node1 bin]# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN qlen 1
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 00:0c:29:41:24:b1 brd ff:ff:ff:ff:ff:ff
    inet 192.168.12.11/24 brd 192.168.12.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::20c:29ff:fe41:24b1/64 scope link 
       valid_lft forever preferred_lft forever
3: flannel.1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue state UNKNOWN 
    link/ether ba:22:49:ed:28:8b brd ff:ff:ff:ff:ff:ff
    inet 10.0.35.0/32 scope global flannel.1
       valid_lft forever preferred_lft forever
    inet6 fe80::b822:49ff:feed:288b/64 scope link 
       valid_lft forever preferred_lft forever
4: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN 
    link/ether 02:42:9e:25:fd:d0 brd ff:ff:ff:ff:ff:ff
    inet 10.0.35.1/24 brd 10.0.35.255 scope global docker0
       valid_lft forever preferred_lft forever
```
