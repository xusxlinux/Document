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

- mysqlbinlog使用


- 案例演示


#### 物理备份与恢复
