#### 需要下载两个工具
``` shell
# xtrabackup 第一个文章有提到

# 阿里云的解压工具
wget "http://docs-aliyun.cn-hangzhou.oss.aliyun-inc.com/assets/attach/183466/cn_zh/1608011575185/qpress-11-linux-x64.tar
```

#### 处理xb文件
``` shell
cat xxxxx-SH03_backup_20230324202449.xb | xbstream -x -v -C mysql_backup_cx
innobackupex --decompress mysql_backup
innobackupex --defaults-file=/data/software/mysql_backup_cx/backup-my.cnf --apply-log /data/software/mysql_backup_cx
```

[参考博文 一](https://blog.csdn.net/mwtai/article/details/101854888?spm=1001.2101.3001.6650.1&utm_medium=distribute.pc_relevant.none-task-blog-2%7Edefault%7ECTRLIST%7ERate-1-101854888-blog-94985802.235%5Ev27%5Epc_relevant_default&depth_1-utm_source=distribute.pc_relevant.none-task-blog-2%7Edefault%7ECTRLIST%7ERate-1-101854888-blog-94985802.235%5Ev27%5Epc_relevant_default&utm_relevant_index=2)  
[参考博文 二](https://blog.csdn.net/weixin_42917630/article/details/94985802)


#### 自建数据库不支持如下参数，需要注释掉
``` shell

```

#### 更新一下新的my.cnf文件
``` shell
cat /etc/my.cnf
[mysqld]
datadir = /data/software/mysql_backup_cx/
port = 3306
server_id = 1
socket = /data/software/mysql_backup_cx/mysqld.sock
max_allowed_packet=32M
log-error = /data/software/mysql_backup_cx/error.log
default-storage-engine=INNODB
lower_case_table_names=1
group_concat_max_len = 102400
max_allowed_packet = 8M
key_buffer_size = 12M
sort_buffer_size = 1M
skip-grant-tables
```
