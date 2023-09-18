## lsof
``` shell
# 追踪命令打开了哪些函数
[root@node-01 ~]# strace tail

# 查看文件被哪些命令使用
[root@node-01 ~]# lsof /etc/passwd
[root@node-01 ~]# lsof | grep /etc/passwd

# 查看PID进程号
[root@node-01 ~]# lsof -p 14557

# 查看端口号
[root@node-01 ~]# lsof -i :22
[root@node-01 ~]# lsof -i :80

# 查看用户打开的文件
[root@node-01 ~]# lsof -u root
[root@node-01 ~]# lsof -u nginx

# 删除文件后, 磁盘不被释放
[root@node-01 ~]# lsof | grep deleted
[root@node-01 ~]# ll /proc/14385/fd
[root@node-01 ~]# echo > /proc/14385/fd/3
```
