## 本章大纲

#### 备份与恢复名词解释
- 冷备：关闭数据库，数据库没有任何变更的情况下，进行数据备份
- 热备：再数据库正常运行是，业务数据的备份
- 全量备份：备份所有数据
- 增量备份：备份某一段时间内变化了的数据


#### 逻辑备份与恢复
- 逻辑备份与恢复特点
  - 备份出来的是SQL语句，可读性高，便于处理
  - 备份和恢复粒度灵活，可以是库、表
  - *逻辑备份必须是热备*
  - 备份/恢复数度通常慢于物理备份

- `mysqldump`使用
  - 客户端通用参数：  
    __本地备份：__ `mysqldump -uroot -p123456 -S /mysql/3306/tmp/mysql.sock`  
    __远程备份：__ `mysqldump -uroot -p123456 -h 192.168.2.10 -P3306`  
    
  - 基本参数应用：  
    -A：全备参数  
    -B：备份多个单库  
    -R：备份存储过程及函数  
    --triggers：备份触发器  
    --default-character-set：设置字符集  
    
  - 例子：
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

    __例子：__
    ``` sql
    mysqldump -uroot -p123456 -S /mysql/3306/tmp/mysql.sock -B db_innodb -R --triggers --master-data=2 --single-transaction --default-character-set=utf8 > /mysql/backup-241/db_innodb02_$(date "+%Y%m%d_%H%M%S").sql
    ```
    
- `mysqlbinlog`使用  
  --no-defaults：不使用my.cnf的缺省文件  
  --read-from-remote-server：备份远程服务器的`binlog`。不指定就会备份本地的  
  --raw：binlog日志会以二进制格式存储磁盘中，不指定，则会以文本形式保存  
  --user：复制的MySQL用户，只需授予`replication slave`权限  `grant replication slave on *.* to 'work'@'10.4.7.%';`  
  --stop-never：`mysqlbinlog`可以只从远程服务器获取指定的几个`binlog`，也可将不断生成的`binlog`保存到本地，指定这个参数，代表只要远程服务器不关闭或者连接未未断开，`mysqlbinlog`就会不断的复制远程服务器上的`binlog`  
  --mysql-bin.000001：代表从哪个`binlog`开始复制  
  --result-file：用于设置远程服务器的binlog，保存到本地的前缀。（比如`mysql-bin.000001`，如果指定`--result-file=/mysql/backup/chain-`，保存到本地后文件名为`chain-mysql-bin.000001`)  
  ``` sql
  # mysql备份远程服务器的日志
  mysqlbinlog --no-defaults --read-from-remote-server --raw --result-file=/mysql/backup-11/IP200- --host=10.4.7.200 --user=work --password=123456 --stop-never mysql-bin.000001
  ```
  --base64-output：解码处理  
  -v ：重组伪SQL语句的  
  ``` sql
  mysqlbinlog --no-defaults --base64-output=decode-row -v -v mysql-bin.000006 | more
  ```  
  --set-charset：设置字符集  
  ``` sql
  mysqlbinlog --no-defaults --base64-output=decode-row -v -v --set-charset=utf8 mysql-bin.000006 | more
  ```  
  --database：只处理指定的数据库  
  ``` sql
  mysqlbinlog --no-defaults --database db_innodb --set-charset=utf8 mysql-bin.000001 > /mysql/backup-200/bin1.sql
  ```
  --start-position：指定分析事件的起始位置  
  ``` sql
  mysqlbinlog --no-defaults --database db_innodb --set-charset=utf8 --start-position=154 mysql-bin.000001 > /mysql/backup-200/bin1.sql
  ```
  --stop-position：指定分析时间的结束位置  
  ``` sql
  mysqlbinlog --no-defaults --database db_innodb --set-charset=utf8 --stop-position=219 mysql-bin.000002 > /mysql/backup-200/bin2.sql
  ```  
  --start-datetime：指定分析的起始时间  
  --stop-datetime：指定分析的结束时间

- 案例演示
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
    vim /mysql/backup-200/db_innodb01_20211115_163853.sql
    -- CHANGE MASTER TO MASTER_LOG_FILE='mysql-bin.000009', MASTER_LOG_POS=154;
  3、根据日志位置截取需要的二进制日志
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

#### 物理备份与恢复
- 物理备份与恢复特点
  - 1. 备份集中包括完整的数据库目录和数据文件
  - 2. 备份粒度一般是数据库服务级别
  - 3. 物理备份一般都比较块
  - 4. 备份能够轻易恢复到配置类似的机器上  
  __常用工具__  
  1. 冷备： cp、scp、tar
  2. 热备：XtraBackup
- 使用XtraBackup联机备份
  - XtraBackup简介  
    XtraBackup是由数据库软件企业Percona提供的一款热备工具，出来能够支持`MyISAM`、`InnoDB`引擎对象，还支持XtraDB引擎  
  - XtraBackup安装[Xbackup下载地址](https://downloads.percona.com/downloads/Percona-XtraBackup-2.4/Percona-XtraBackup-2.4.22/binary/tarball/percona-xtrabackup-2.4.22-Linux-x86_64.glibc2.12.tar.gz)  
    - Xtrabackup： 专用于备份`InnoDB`和`XtraDB`引擎对象
    - Innobackupex：能够备份所有使用`MyISAM`、`InnoDB`、`XtraDB`引擎的表对象（当该命令备份InnoDB和XtraDB引擎数据时，它会通过调用xtrabackup命令完成相关操作） 
    ``` shell
    ## 下载二进制包安装XtraBackup
    wget https://downloads.percona.com/downloads/Percona-XtraBackup-2.4/Percona-XtraBackup-2.4.22/binary/tarball/percona-xtrabackup-2.4.22-Linux-x86_64.glibc2.12.tar.gz
    tar -xf percona-xtrabackup-2.4.22-Linux-x86_64.glibc2.12.tar.gz -C /usr/local/
    mv percona-xtrabackup-2.4.22-Linux-x86_64.glibc2.12 xtrabackup
    chown -R mysql.mysql /usr/local/xtrabackup
    echo 'export PATH="$PATH:/usr/local/xtrabackup/bin"' >> /etc/profile
    
    ## 创建备份账号
    create user xtrabk@'localhost' identified by '123456';
    grant reload,lock tables,Replication client,super,process on *.* to 'xtrabk'@'localhost';
    ```
  - InnoBackupex创建全备  
    __基本参数__  
    - --user：连接使用的用户名
    - --password：连接使用的用户密码
    - --defaults-file：MySQL的参数文件
    - --no-timestamp：禁用生成日期子目录
    - [backup_dir]：指定备份集的存储路径
    ``` sql
    innobackupex --defaults-file=/mysql/3306/conf/my.cnf --host=0.0.0.0 --user=xtrabk --password='123456' /mysql/backup-200/3306_full
    ```
    __备份集文件__  
    - backup-my.cnf：包含备份所需的二进制信息
    - xtrabackup_binlog_info：记录备份时的二进制日志文件位置
    - xtrabackup_checkpoints：记录LSN(日志序列号，文件类型)以及备份的类型
    - xtrabackup_info：
    - xtrabackup_logfile：备份日志文件，里面记录备份操作过程中数据库的变更
  - InnoBackupex创建增量全备
    - 增量备份的理论基础
      InnoBackupex增量备份必须基于全量备份或者之前的增量备份。可以利用增量备份优化备份策略，如每周一次全备，每天一次增量备份  
      对于`InnoBackupex`来说，只有`InnoDB`引擎对象才有真正意义的增量备份，其他如`MyISAM/CSV`这类引擎的表对象都是完整备份。因为`InnoDB`的每个页(page)都保存了LSN(Log Sequence Number日志序列号)，这个序号能够表示该页最修改时间，增量备份正是根据这个日志序列号来实现的，每次备份时`XtraBackup`都会在备份集中创建一个`xtrabackup_checkpoints`文件，这个文件中的内容记录了最后修改的日志序列号。那么创建增量备份集时，只需要从上次的备份集中找到`xtrabackup_checkpoints`文件，读取最新的日志序列号，而后在创建增量备份时，只选择LSN大于这个序列号的页(page)进行备份，以及这期间产生的binlog日志  
    - 创建增量备份策略
    - 创建增量备份
- 使用XtraBackup恢复
