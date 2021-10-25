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

- mysqldump使用
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
    --single-transaction：所有被dump的表都会被锁(--lock-tables默认开启)  
    --master-data：对innodb进行一致性备份，对非innodb表可以实现自动锁表功能  
    - 在备份时，会自动记录，二进制日志文件名和位置号
      · 0 默认值  
      · 1 以change master to 命令行事，可以用主从复制  
      · 2 以注释的形式记录， 备份时刻的文件名+`postion`号  
    - 会产生全局锁`(--lock-all-tables)`
    - 联合 `--single-transaction`，则只对非InnoDB表进行锁表备份，InnoDB表进行热备
    - 使用该参数的用户必须具有`reload`权限
    
  - 例子：
    ``` sql
    mysqldump -uroot -p123456 -S /mysql/3306/tmp/mysql.sock -B db_innodb -R --triggers --single-transaction --default-character-set=utf8 > /mysql/backup-241/db_innodb_$(date "+%Y%m%d_%H%M%S").sql
    ```
- mysqlbinlog使用


- 案例演示


#### 物理备份与恢复
