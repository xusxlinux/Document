## 1.1 系统优化
#### 1.1 设置主机名
``` shell

```
#### 1.2 修改时区(上海时区)
``` shell
# 修改时区
xusx@localhost:~$ sudo timedatectl set-timezone Asia/Shanghai
```

## 2.权限设置
#### 2.1 新建用户
```
# 创建用户
```

## 3.服务器加固
#### 3.1 密钥文件
``` shell

```

## 4. 磁盘维护
``` shell
# 查看磁盘
root@localhost:~# fdisk -l
root@localhost:~# fdisk /dev/sdc

# 硬盘格式化 
root@localhost:~# mkfs.xfs /dev/sdc1
# 查看想要挂载分区的UUID
root@localhost:~# blkid /dev/sdc1

# 临时挂载硬盘
xusx@localhost:~$ sudo mount /dev/sdc1 /data
# 卸载硬盘
xusx@localhost:~$ sudo umount /dev/sdc1

# 永久挂载硬盘(挂载UUID的方式)
xusx@localhost:~$ sudo blkid /dev/sdc1
/dev/sdc1: UUID="aa8f75ff-3ee4-4fe0-9556-e62367e4d864" BLOCK_SIZE="512" TYPE="xfs" PARTUUID="3d00e709-01"

xusx@localhost:~$ sudo vim /etc/fstab
/dev/disk/by-uuid/aa8f75ff-3ee4-4fe0-9556-e62367e4d864 /home/xusx/data xfs defaults 0 1
```

## 5.安全设置(安全组)
``` shell
# 设置安全断开
```
