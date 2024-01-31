## 一 GTID介绍

###### **1.1 GTID概念:**

- 全局事务标识: global transaction identifiers
- GTID与事务一一对应,  并且全局唯一ID
- 一个GTID在一个服务器上只执行一次
- MySQL 5.65开始支持GTID
- GTID组成: GTID=server_uuid:transaction_id

###### **1.2 GTID和Binlog之间的关系**

- previous_gtid_log_event
  - 用于表示当前binlog文件之前已经执行过的GTID集合,  记录在binlog文件头
- 假设有4个binlog: `bin.001` `bin.002` `bin.003` `bin.004`
  - bin.001: Previous-GTIDs=empty; binlog_events有: 1-40
  - bin.002: Previous-GTIDs=1-40;  binlog_events有: 41-80
  - bin.003: Previous-GTIDs=1-80;  binlog_events有: 81-120
  - bin.004: Previous-GTIDs=1-120; binlog_events有: 121-160
- 如何找到GTID=?变量对应的binlog文件:
  - 假设现在我们要找GTID=$A, 那么MySQL的扫描顺序为: 从最后一个binlog开始扫描(即: bin.004)
  - bin.004的Previous-GTIDs=1-120,  如果$A=140> Previous-GTIDs, 那么肯定在bin.004中.
  - bin.004的Previous-GTIDs=1-120,  如果$A=88包含在Previous-GTIDs中, 那么继续对比上一个文件bin.003, 然后在循环前面的2的步骤,直到找到为止.
- GTID的复制协议(COM_BINLOG_DUMP_GTID):
  - 从服务器向主服务器发送已执行过的GTID.
  - 主服务器将所有其他GTID发送给从服务器.
  - 同样的GTID不能被执行两次, 如果有同样的GTID, 会自动被skip掉.

![image](https://github.com/xusxlinux/Document/assets/37207302/323388b6-890e-4d5a-a0fe-f8bc6e4974f1)

###### **1.3 传统复制与GTID对比**

- 此时, master服务器宕机, 需要将业务切换到Slave1上, 同时, 我们又需要将Slave2的复制源改成Slave1.

- 而这种方式的难点在于, 由于同一个事务在每台机器上所在的binlog名字和位置都不一样, 那么怎么找到Slave2当前同步停止点对应Slave1上 master_log_file和master_log_pos的位置就成为了难题

  ![image](https://github.com/xusxlinux/Document/assets/37207302/f91f4a93-5ba0-4a19-86be-b5751eddfda1)

- 由于同一事务的GTID在所有节点上的值一致, 那么根据slave2 当前停止点的GTID就能定位到slave1上的GTID. 直接使用 `CHANGE MASTER TO MASTER_HOST='xxxx', MASTER_AUTO_POSITION=1` 命令就可以直接完成failover的工作.

  ![image](https://github.com/xusxlinux/Document/assets/37207302/85e9b1b5-6639-4c23-83c4-c1b2c59004a4)

## 二 GTID配置

#### 从0开始搭建 (不细讲)

- 配置主从my.cnf文件
- 创建复制专用账户
- 使用 change master 更新主从配置

#### 传统复制升级为GTID复制

- 配置主从my.cnf文件

  ``` shell
  # 主库配置文件
  [mysqld]
  ##GTID
  server-id                              = 4711                          #服务器id
  gtid_mode                              = ON                            #开启gtid模式(必选)
  enforce_gtid_consistency               = ON                            #强制gtid一致性(必选)
  ##binlog                                                               
  log-slave-updates                      = 1                             #实现级联同步时,需要开启该参数(必选) 默认情况, SQL线程读取relay-log而执行的SQL语句并不会记录到bin-log,无法实现三级级联同步(A>B>c)
  log-bin                                = /mysql/3306/binlog/mysql-bin  #(必选)
  binlog_format                          = ROW                           #建议使用该模式, 其他格式可能会造成数据不一致
  #relay-log                                                              
  skip-slave-start                       = 1                             #禁止复制线程随mysql服务自动启动
  ```

  ``` shell
  # 从库配置文件
  [mysqld]
  ##GTID
  server-id                              = 4712
  gtid_mode                              = ON
  enforce_gtid_consistency               = ON
  ##binlog                                                             
  log-slave-updates                      = 1
  log-bin                                = /mysql/3306/binlog/mysql-bin
  binlog_format                          = ROW
  #relay-log                                                              
  skip-slave-start                       = 1
  ```
- 所有服务器设置 read_only模式, 等待主从服务器同步完毕
- 依次重启主从服务器

  ``` shell
  # 配置好my.cnf文件后,等待数据追平了, 重启MySQL服务
  systemctl restart mysqld.service 
  systemctl status mysqld.service
  
  root@(none)> show global variables like '%gtid%';
  root@(none)> show variables like '%gtid%';
  | binlog_gtid_simple_recovery      | ON        |
  | enforce_gtid_consistency         | ON        |
  | gtid_mode                        | ON        |
  ```
- 使用 change master 更新主从配置

  ``` sql
  # 然后更新主从配置
  root@(none)> help change master to
  
  root@(none)> CHANGE MASTER TO
    MASTER_HOST='10.4.7.11',
    MASTER_USER='repl',
    MASTER_PASSWORD='123456',
    MASTER_PORT=3306,
    MASTER_AUTO_POSITION = 1,
    MASTER_CONNECT_RETRY=10;
    
  start slave;
  show slave status\G
  ```

  

#### GTID相关参数

| 参数                     | comment                       |
| ------------------------ | ----------------------------- |
| gtid_executed            | 执行过的所有GTID              |
| gtid_purged              | 丢弃掉的GTID                  |
| gtid_mode                | gitd模式                      |
| gtid_next                | session级别的变量, 下一个gtid |
| gtid_owned               | 正在运行的gtid                |
| enforce_gtid_consistency | 保证GTID安全的参数            |

- GTID的限制

  设置enforce_gtid_consistency=ON时, 一下三类语句不被执行

  - create table .... select statements (不允许创建备份表)
  - create temporary table  / drop temporary table statements inside transactions
  - 同时更新 事务引擎和非事务引擎



## 三 同步故障处理

- 主库新增记录, 从库提示主键冲突

  ``` shell
  # 到从库中找到相对于的记录删除
  ```

- 主库对象可更新, 从库无对应的对象可更新

  ``` shell
  # 到binlog找到相应的记录, 然后插入到从库
  ```

- 主库对象可删除, 从库无对应的对象可删除

  - 模拟故障1:  从库找不到对应的被删除的记录(Errno: 132)

    - 主库

      ``` sql
      root@demo> create table t_delete(id int not null auto_increment primary key,c1 varchar(20));
      root@demo> insert into t_delete(c1) values('a');
      
      # 从库删除数据后,执行这个sql
      root@demo> delete from t_delete;
      ```

    - 从库

      ``` sql
      # 此时主从数据不一致
      root@demo> delete from t_delete;
      ```

    - 解决办法

      ``` sql
      ##通过注入空事务来跳过
      root@demo> stop slave;
      
      # 查看主库的gtid信息
      root@demo> show global variables like '%gtid%';
      | gtid_executed                    | 716ae165-bcf7-11ee-b723-000c29154ec0:1-6 |
      # 从库上查看事务的gtid值  
      root@demo> show slave status\G
      Retrieved_Gtid_Set: 716ae165-bcf7-11ee-b723-000c29154ec0:2-6   # 主库执行到6, 从库是没法执行的
      Executed_Gtid_Set: 716ae165-bcf7-11ee-b723-000c29154ec0:1-5,   # 
      c04ee7a9-bcfc-11ee-b6d5-000c299b1d87:1                         # 主库同步过来的
      
      # 跳过不能执行的
      root@demo> set gtid_next='716ae165-bcf7-11ee-b723-000c29154ec0:6';
      
      # 产生一个空事务
      root@demo> begin;commit;
      
      # 执行完成后就跳过了
      root@demo> show slave status\G
      Retrieved_Gtid_Set: 716ae165-bcf7-11ee-b723-000c29154ec0:2-6
      Executed_Gtid_Set: 716ae165-bcf7-11ee-b723-000c29154ec0:1-6,   # 这里就跳过了
      c04ee7a9-bcfc-11ee-b6d5-000c299b1d87:1
      
      # 设置一个自动的
      root@demo> set gtid_next='AUTOMATIC';
      
      root@demo> start slave;
      ```

- 主库日志被purged

  - 模拟故障2:  主库binglog被purge的情形(Erron: 1236)
  
    - 从库

      ``` sql
      # 首先停止从库, 模拟从库被意外宕机:
      root@demo> stop slave;
      ```
  
    - 主库
  
      ``` sql
      # 主库, 制造数据生成binlog:
      root@demo> insert into t_delete(c1)values('a');
      root@demo> flush logs;
      
      root@demo> delete from t_delete;
      root@demo> flush logs;
      
      root@demo> insert into t_delete(c1)values('a');
      root@demo> insert into t_delete(c1)values('a');
      root@demo> insert into t_delete(c1)values('a');
      root@demo> flush logs;
      
      root@demo> insert into t_delete(c1)values('a');
      root@demo> flush logs;
      root@demo> delete from t_delete;
      
      root@demo> insert into t_delete(c1)values('a');
      root@demo> flush logs;
      ```
  
      ``` sql
      # 主库清理binlog
      root@demo> show binary logs;
      +------------------+-----------+
      | Log_name         | File_size |
      +------------------+-----------+
      | mysql-bin.000010 |    982251 |
      | mysql-bin.000011 |      1252 |
      | mysql-bin.000012 |       505 |
      | mysql-bin.000013 |      1033 |
      | mysql-bin.000014 |       505 |
      | mysql-bin.000015 |       790 |
      | mysql-bin.000016 |       194 |
      +------------------+-----------+
      
      
      root@demo> purge binary logs to 'mysql-bin.000016';
      
      
      root@demo> show binary logs;
      +------------------+-----------+
      | Log_name         | File_size |
      +------------------+-----------+
      | mysql-bin.000016 |       194 |
      +------------------+-----------+
      
      
      root@demo> show variables like '%gtid_purged%';
      +---------------+-------------------------------------------+
      | Variable_name | Value                                     |
      +---------------+-------------------------------------------+
      | gtid_purged   | 716ae165-bcf7-11ee-b723-000c29154ec0:1-14 |
      +---------------+-------------------------------------------+
      ```
  
      ``` sql
      # 启动从库:
      root@demo> start slave;
      
      root@demo> show slave status\G
      Last_IO_Error: Got fatal error 1236 from master when reading data from binary log: 'The slave is connecting using CHANGE MASTER TO MASTER_AUTO_POSITION = 1, but the master has purged binary logs containing GTIDs that the slave requires. Replicate the missing transactions from elsewhere, or provision a new slave from backup. Consider increasing the master's binary log expiration period. The GTID set sent by the slave is '716ae165-bcf7-11ee-b723-000c29154ec0:1-6,
      c04ee7a9-bcfc-11ee-b6d5-000c299b1d87:1', and the missing transactions are '716ae165-bcf7-11ee-b723-000c29154ec0:7-14'.'
      
      
      root@demo> show variables like '%gtid_purged%';  
      +---------------+-------+
      | Variable_name | Value |
      +---------------+-------+
      | gtid_purged   |       |
      +---------------+-------+
      ```
  
    - 解决办法:
  
      ``` sql
      # 从库尝试使用gtid_purged跳过事务, 这个1-14是从库中通过show slave status\G查看的Last_IO_Error:信息
      root@demo> set global gtid_purged='716ae165-bcf7-11ee-b723-000c29154ec0:1-14';
      ERROR 1840 (HY000): @@GLOBAL.GTID_PURGED can only be set when @@GLOBAL.GTID_EXECUTED is empty.
      
      root@demo> show global variables like '%gtid_executed%';
      
      root@demo> reset master; # 在从库上 清空从库binlog以及gtid_executed
      root@demo> set global gtid_purged='716ae165-bcf7-11ee-b723-000c29154ec0:1-14';
      
      root@demo> start slave;
      ```
  
    - 这个案例,  是演示使用gtid_purged方式来达到跳过事务的目的. 仅仅是让主从恢复正常.  `但是主从的数据是不一致的`,  还可能会遇到`1032`,  `1062`等错误,  还需要根据时间的需要考虑是否进行相应的修复. `考虑使用上一步方式修复`ss
  
