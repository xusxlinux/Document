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
  --result-file：用于设置远程服务器的binlog，保存到本地的前缀。（比如`mysql-bin.000001`，如果指定`--result-file=/mysql/backup/chain-`，保存到本地后文件名为`chain-mysql-bin.000001`）  
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
  --start-position：指定分析事件的起始位置  
  --stop-position：指定分析时间的结束位置  
  ``` sql
  mysqlbinlog --no-defaults --start-position=154 --stop-position=997 --set-charset=utf8 mysql-bin.000006 | more
  ```  
  --start-datetime：指定分析的起始时间  
  --stop-datetime：指定分析的结束时间

- 案例演示


#### 物理备份与恢复
