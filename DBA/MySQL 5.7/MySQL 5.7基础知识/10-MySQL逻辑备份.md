## 逻辑备份与恢复
- 逻辑备份与恢复特点
  - 备份出来的是SQL语句，可读性高，便于处理
  - 备份和恢复粒度灵活，可以是库、表
  - *逻辑备份必须是热备*
  - 备份/恢复数度通常慢于物理备份

- __`mysqldump`使用__
  - 客户端通用参数：  
    __本地备份：__ `mysqldump -uroot -p123456 -S /mysql/3306/tmp/mysql.sock`  
    __远程备份：__ `mysqldump -uroot -p123456 -h 192.168.2.10 -P3306`  
    
  - 基本参数应用：  
    -A：全备参数  
    -B：备份多个单库  
    -R：备份存储过程及函数  
    --triggers：备份触发器  
    --default-character-set：设置字符集  
    
    __例子：__
    
    ``` sql
    # 全备库
    mysqldump -uroot -p123456 -S /mysql/3306/tmp/mysql.sock -A -R --triggers --default-character-set=utf8 > /mysql/backup-241/$(date "+%Y%m%d_%H%M%S").sql
    
    # 备份单库 db_gb2312  db_innodb
    mysqldump -uroot -p123456 -S /mysql/3306/tmp/mysql.sock -B db_gb2312 db_innodb -R --triggers --default-character-set=utf8 > /mysql/backup-241/$(date "+%Y%m%d_%H%M%S").sql
    ```
  
  - 高级参数应用：  
    --single-transaction：  
    不加这个参数的时候，所有被dump的表都会被锁(--lock-tables默认开启)  
    加上这个参数的时候，对innodb进行一致性备份，对非innodb表可以实现自动锁表功能
  
    __例子：__
  
    ``` sql
    mysqldump -uroot -p123456 -S /mysql/3306/tmp/mysql.sock -B db_innodb -R --triggers --single-transaction --default-character-set=utf8 > /mysql/backup-241/db_innodb_$(date "+%Y%m%d_%H%M%S").sql
    ```
  
    --master-data：对innodb进行一致性备份，对非innodb表可以实现自动锁表功能  
  
    - 在备份时，会自动记录，二进制日志文件名和位置号  
      · 0 默认值  
      · 1 以change master to 命令行事，可以用主从复制  
      · 2 以注释的形式记录， 备份时刻的文件名+`postion`号  
    - 会产生全局锁`(--lock-all-tables)`
    - 联合 `--single-transaction`，则只对非InnoDB表进行锁表备份，InnoDB表进行热备
    - 使用该参数的用户必须具有`reload`权限  
  
    ``` sql
    # 使用这个方式恢复到库中会出现奇怪的错误, 需要清空GTID_EXECUTED; 
    # SELECT @@GLOBAL.GTID_EXECUTED;  查询出来有数据 
    mysqldump -uroot -p123456 -S /mysql/3306/tmp/mysql.sock -B db_innodb -R --triggers --master-data=2 --single-transaction --default-character-set=utf8 > /mysql/backup-241/db_innodb02_$(date "+%Y%m%d_%H%M%S").sql
    ```
    
    --set-gtid-purged=OFF：在gtid模式下，mysqldump默认会记录GTID_PURGED信息, 备份的时候关闭
    
    - 在原数据库导出时加了--set-gtid-purged=OFF，导入新数据库时，才会触发记录到新数据库的binlog日志。如果不加，则新数据库不记录binlog日志。
    
    __例子：__
    
    ``` sql
    # 使用这个sql备份,会过滤不需要的库, 并且关闭gtid复制的id
    #!/usr/bin/env bash
    pass='123456'
    mysql -h 10.60.0.15  -uroot -p$pass -e "show databases;" | egrep -v "Database|_schema|sys|mysql" | xargs -I {} mysqldump -h 10.60.0.15 -uroot -p$pass -B {} -R --triggers --master-data=2 --single-transaction --set-gtid-purged=OFF > /data/software/$(date "+%Y%m%d_%H%M%S").sql
    ```
  
  ---
  
- __`mysqlbinlog`基本参数使用__  
  --no-defaults：不使用my.cnf的缺省文件  
  --read-from-remote-server：备份远程服务器的`binlog`。不指定就会备份本地的  
  --raw：binlog日志会以二进制格式存储磁盘中，不指定，则会以文本形式保存  
  --user：复制的MySQL用户只需授予`replication slave`权限 `grant replication slave on *.* to 'work'@'10.4.7.%';`  
  --stop-never：`mysqlbinlog`可以只从远程服务器获取指定的几个`binlog`，也可将不断生成的`binlog`保存到本地，指定这个参数，代表只要远程服务器不关闭或者连接未未断开，`mysqlbinlog`就会不断的复制远程服务器上的`binlog`  
  --mysql-bin.000001：代表从哪个`binlog`开始复制  
  --result-file：用于设置远程服务器的binlog，保存到本地的前缀。（比如`mysql-bin.000001`，如果指定`--result-file=/mysql/backup/chain-`，保存到本地后文件名为`chain-mysql-bin.000001`)  
  
  ``` sql
  # mysql备份远程服务器的binlog日志文件
  mysqlbinlog --no-defaults --read-from-remote-server --raw --result-file=/mysql/backup-11/IP200- --host=10.4.7.200 --user=work --password=123456 --stop-never mysql-bin.000001
  ```
  --base64-output：解码处理`never`, `decode-rows`, `auto`  
  -v (--verbose)：重组伪SQL语句的 , 专门用于ROW格式的日志文件中的事件处理, 指定两次-vv, 输出的信息会报考列的数据类型信息  
  
  ``` sql
  # 输出肉眼可以识别的文本
  # 去掉--base64-output -v -v 这两个参数后, 得到的sql可以在数据库中执行
  mysqlbinlog --no-defaults --base64-output=decode-row -v -v mysql-bin.000006 | more
  ```
  --set-charset：设置字符集  
  ``` sql
  mysqlbinlog --no-defaults --base64-output=decode-row -v -v --set-charset=utf8 mysql-bin.000006 | more
  ```
  --database：只处理指定的数据库  
  ``` sql
  mysqlbinlog --no-defaults --database evcos --set-charset=utf8 mysql-bin.000001 > /mysql/backup-200/bin1.sql
  ```
  --start-position：指定分析事件的起始位置  
  ``` sql
  mysqlbinlog --no-defaults --database evcos --set-charset=utf8 --start-position=154 mysql-bin.000001 > /mysql/backup-200/bin1.sql
  ```
  --stop-position：指定分析时间的结束位置  
  ``` sql
  mysqlbinlog --no-defaults --database evcos --set-charset=utf8 --stop-position=219 mysql-bin.000002 > /mysql/backup-200/bin2.sql
  ```
  --start-datetime：指定分析的起始时间  
  --stop-datetime：指定分析的结束时间
  
  ---
  
- __案例演示__
```
# 故障模拟及恢复执行步骤：
1、模拟备份数据库：db_innodb
  mysqldump -uroot -p123456 -S /mysql/3306/tmp/mysql.sock -B db_innodb -R --triggers --master-data=2 --single-transaction --default-character-set=utf8 > /mysql/backup-200/db_innodb01_$(date "+%Y%m%d_%H%M%S").sql

2、模拟白天的业务数据变化：
  create tables t_columns as select * from information_schema.columns;
  commit;
  flush logs;
  
  insert into t_columns select * from information_schema.columns;
  commit;
  flush logs;
  
  insert into t_columns select * from information_schema.columns;
  commit;
  flush logs;  
  
3、模拟库被删除：
  drop database db_innodb;
  
  1、获取drop前的时间，避免进入循环
    show binary logs;
    +------------------+------------+
    | Log_name         | File_size  |
    +------------------+------------+
    | mysql-bin.000013 | 493369     |
    +------------------+------------+
    | mysql-bin.000014 |    335     |
    +------------------+------------+

    show binlog events in 'mysql-bin.000014'
    +------------------+-----+----------------+-----------+-------------+---------------------------------------+
    | Log_name         | Pos | Event_type     | Server_id | End_log_pos | Info                                  |
    +------------------+-----+----------------+-----------+-------------+---------------------------------------+
    | mysql-bin.000014 |   4 | Format_desc    |         1 |         123 | Server ver: 5.7.25-log, Binlog ver: 4 |
    | mysql-bin.000014 | 123 | Previous_gtids |         1 |         154 |                                       |
    | mysql-bin.000014 | 154 | Anonymous_Gtid |         1 |         219 | SET @@SESSION.GTID_NEXT= 'ANONYMOUS'  |
    | mysql-bin.000014 | 219 | Query          |         1 |         326 | drop database db_innodb               |
    +------------------+-----+----------------+-----------+-------------+---------------------------------------+
4、恢复思路：
  1、获取备份数据
    db_innodb01_20211115_163853.sql
  2、从备份中获取二进制日志位置
    less /mysql/backup-200/db_innodb01_20211115_163853.sql
    -- CHANGE MASTER TO MASTER_LOG_FILE='mysql-bin.000009', MASTER_LOG_POS=154;
  3、根据全备的sql位置截取需要的二进制日志
    mysqlbinlog --no-defaults --database db_innodb --start-position=154 --set-charset=utf8 mysql-bin.000009 > /mysql/backup-200/bin9.sql
    mysqlbinlog --no-defaults --database db_innodb --set-charset=utf8 mysql-bin.000010 > /mysql/backup-200/bin10.sql
    mysqlbinlog --no-defaults --database db_innodb --set-charset=utf8 mysql-bin.000011 > /mysql/backup-200/bin11.sql
    mysqlbinlog --no-defaults --database db_innodb --set-charset=utf8 mysql-bin.000012 > /mysql/backup-200/bin12.sql
    mysqlbinlog --no-defaults --database db_innodb --set-charset=utf8 mysql-bin.000013 > /mysql/backup-200/bin13.sql
    mysqlbinlog --no-defaults --database db_innodb --stop-position=219 --set-charset=utf8 mysql-bin.000014 > /mysql/backup-200/bin14.sql
  4、恢复备份数据
    set SQL_LOG_BIN=0;  (避免进入循环)
    source /mysql/backup-200/db_innodb01_20211115_163853.sql
  5、恢复二进制日志
    source /mysql/backup-200/bin9.sql
    source /mysql/backup-200/bin10.sql
    source /mysql/backup-200/bin11.sql
    source /mysql/backup-200/bin12.sql
    source /mysql/backup-200/bin13.sql
    source /mysql/backup-200/bin14.sql
```
