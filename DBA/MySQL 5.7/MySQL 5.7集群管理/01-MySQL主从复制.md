## MySQL 主从复制

#### 复制概述

- MySQL中的主从复制是将数据从一段(通常称为master, 即主库) 复制到另外一端(通常称为slave, 即从库).

- MySQL的复制特性操作很灵活, 既可以实现整个服务器级别的复制, 也可以只复制某个数据库, 甚至某个数据库中的某个表对象;

- 可实现从A复制到B(主从单项复制), B再复制带C, 也可以实现A直接复制到B和C(单主多从复制), 甚至是A的数据复制给B, B的数据也复制回A(双主复制).

 - 服务器间复制数据有多种解决方案, 哪种方案最合适, 取决于使用的数据引擎和期望实现的复制需求. 一般来说, 可以将MySQL的复制特性应用再下列场景上:
   - 实时灾备, 用于故障切换
   - 读写分离, 提供查询服务
   - 备份, 避免影响业务

#### 复制关键因素以及原理

- 复制格式

  复制格式和二进制日志格式本质上是一个东西, 只是在不同场景下称为不同, 都由系统变量`binlog_format`控制

  - 二进制日志格式:
    - 基于语句记录(Statement-Based Logging, SBL), 对应的参数值为statement. 二进制日志文件中保存的是执行过的SQL语句.
    - 基于行格式记录(Row-Based Logging, RBL), 对应的参数值为row. 二进制日志文件中记录的是变更的行的信息.
    - 混合模式(Mixed-Based Logging, MBL), 对应的参数值为mixed. 在记录事件到二进制日志时, MySQL服务根据需要, 动态修改日志记录的格式.

  - 复制格式:
    - 基于语句复制(Statement-Based Replication, SBR)
    - 基于行复制(Row-Based Replication, RBR)  选择这个的原因是, 稳定大于一切
    - 混合记录模式(Mixed-Based Logging, MBL)
    
      ``` tex
      使用场景举例1:
        有一条复杂的SQL语句, 在Master节点执行了一个小时, 最终成功修改了两条记录.
        采用SBR模式, 二进制日志中记录的事件就是这条SQL语句, 那么,这个记录被复制到slave节点, 也要一个小时执行时间.
        采用RBR模式, 不管master 节点执行了多长时间, 最终变更记录只有两条, 那么二进制日志记录的事件, 就是这两条记录的更新, 日志被同步到slave节点后,能做到秒级执行完成.
      ```
    
      ``` tex
      使用场景举例2:
        有一条简单的SQL语句, 在master节点执行时, 要更新一千万条记录.
        采用RBR模式, 这一千万条记录会生成较大的二进制日志文件, 数据在网络传输过程就要耗费一定时间, slave接受完数据, 还得花费相当长的时间慢慢应用到库中.
        采用SBR模式, 二进制日志文件中就记录了该SQL语句, slave节点可以迅速接受该语句, 然后再执行, 执行可能耗费一定时间, 但总体时间开销还是比RBR小.
      ```
    
      

- 中继日志文件和状态文件

  MySQL数据库中有二进制日志文件, 用于记录所有执行的变更事件, 复制特性正是基于这类文件实现复制操作. slaves节点中有两个线程, 其中IO_THREAD线程用于接收和保存二进制日志文件, IO_THREAD将接收的二进制日志就保存再本端的中继日志中.

  ``` shell
  [root@node-01 ~]# less /mysql/3306/conf/my.cnf
  relay-log                              = /mysql/3306/relaylog/relay-bin
  ```

  slaves节点会在满足下列条件时, 触发创建新的中继日志文件:

  - 启动slaves节点IO线程时. (IO线程创建中继日志, SQL线程删除中继日志)
  - 执行日志刷新命令: flush logs
  - 中继日志文件达到指定最大值:
    - 如果`max_relay_log_size`参数值大于0, 则日志文件超过该值后会重建.
    - 如果`max_relay_log_size`参数值等于0, 则通过max_binlog_size确定单个中继日志文件的最大值


  状态文件:

  - 复制环境中slave节点会创建两个状态文件: `master.info`和`relay-log.info`, 这两个文件默认保存再data目录:

    ``` shell
    # 记录了一些连接master信息, IO线程通过读取这个文件到master请求连接. 
    # 还有当前哪个二进制日志文件的位置信息
    [root@node-02 ~]# more /mysql/3306/data/master.info 
    
    # 这个是和SQL线程有关的,启动时读取这个信息,用到当前中继日志哪个文件的哪个位置, 再这个文件之前的中继日志是可以删除的
    [root@node-02 ~]# more /mysql/3306/data/relay-log.info 
    ```

  -  可以通过以下两个参数文件修改文件的名称和保存路径:

    - --master-info-file
    - --relay-log-info-file

- 复制原理

  - 第一阶段:
    - 启动(`slave I/O Thread --> master.info`   `slave SQL Thread --> relay-log.info`)
    - 建立连接((`slave I/O Thread --> master.info`   `Master Log Dump Thread`)

  - 第二阶段:
    - 获取更新日志(`Master Log Dump Thread`    `binlog`)
    - 传递更新日志(`Master Log Dump Thread`    `binlog`    `Slave I/O Thread`)
    - 保存更新日志(`Slave I/O Thread`    `Slave Relay Log`)

  - 第三阶段
    - 应用中继日志(`Slave SQL Thread`    `relay-log.info`    `Slave Relay Log`)


  ![image](https://github.com/xusxlinux/Document/assets/37207302/a303ec22-b173-42fd-8e92-d63d05632761)
#### 搭建环境

- 搭建复制环境(一主一从)

  - 环境介绍:  [环境准备](https://github.com/xusxlinux/Document/blob/master/Linux/rpm/01-%E7%8E%AF%E5%A2%83%E5%87%86%E5%A4%87.md)

  - 安装数据库: [MySQL 5.7安装](https://github.com/xusxlinux/Document/blob/master/DBA/MySQL%205.7/MySQL%205.7%E5%9F%BA%E7%A1%80%E7%9F%A5%E8%AF%86/01-MySQL%E5%AE%89%E8%A3%85.md) 

  - 主从复制配置: 

    - Master端启用二进制日志(binlog), 指定唯一的server_id

      ``` shell
      server-id                              = 4711
      log-bin                                = /mysql/3306/binlog/mysql-bin
      ```

    - Slave端启用二进制日志(binlog), 指定唯一的server_id, 指定中继日志文件路径

      ``` shell
      server-id                              = 4712
      log-bin                                = /mysql/3306/binlog/mysql-bin
      relay-log                              = /mysql/3306/relaylog/relay-bin
      ```

    - Master端创建复制专用账户

      ``` shell
      mysql> create user 'repl'@'10.4.7.%' identified by '123456';
      mysql> grant replication slave on *.* to 'repl'@'10.4.7.%';
      ```

    - 创建主数据库备份并记录Master端日志相对应的位置信息

      ``` shell
      mysql> create database demo;
      mysql> create table t_columns as select * from information_schema.columns;
      mysql> insert into t_columns select * from information_schema.columns;
      mysql> commit;
      
      [root@node-01 ~]# mysqldump -uroot -p -A -R --triggers --master-data=2 --single-transaction --default-character-set=utf8 >/mysql/backup/demo_$(date "+%Y%m%d").sql
      
      [root@node-01 ~]# less /mysql/backup/demo_20240125.sql
      -- CHANGE MASTER TO MASTER_LOG_FILE='mysql-bin.000003', MASTER_LOG_POS=1478389;
      
      [root@node-01 ~]# scp /mysql/backup/demo_20240125.sql 10.4.7.12:/mysql/backup/
      
      [root@node-02 ~]# cat /mysql/backup/demo_20240125.sql | mysql -uroot -p123456
      ```

    - 配置Slave端的连接

      ``` shell
      # 在从库上执行, 根据获取的binlog位置信息填写下面配置
      mysql> help change master to
      
      mysql> CHANGE MASTER TO
        MASTER_HOST='10.4.7.11',
        MASTER_USER='repl',
        MASTER_PASSWORD='123456',
        MASTER_PORT=3306,
        MASTER_LOG_FILE='mysql-bin.000003',
        MASTER_LOG_POS=1478389,
        MASTER_CONNECT_RETRY=10;
        
      mysql> start slave;
      
      # 在从库生成master.info文件
      [root@node-02 ~]# less /mysql/3306/data/master.info
      ```

    - 验证

      ``` shell
      # 主服务器
      mysql> show processlist;
      +----+------+-----------------+------+-------------+--------+---------------------------------------------------------------+------------------+
      | Id | User | Host            | db   | Command     | Time   | State                                                         | Info             |
      +----+------+-----------------+------+-------------+--------+---------------------------------------------------------------+------------------+
      |  7 | repl | 10.4.7.12:54676 | NULL | Binlog Dump | 326426 | Master has sent all binlog to slave; waiting for more updates | NULL             |
      | 11 | root | localhost       | NULL | Query       |      0 | starting                                                      | show processlist |
      +----+------+-----------------+------+-------------+--------+---------------------------------------------------------------+------------------+
      2 rows in set (0.00 sec)
      
      
      # 从服务器
      mysql> show processlist;
      +----+-------------+-----------+------+---------+------+--------------------------------------------------------+------------------+
      | Id | User        | Host      | db   | Command | Time | State                                                  | Info             |
      +----+-------------+-----------+------+---------+------+--------------------------------------------------------+------------------+
      |  8 | root        | localhost | demo | Query   |    0 | starting                                               | show processlist |
      | 10 | system user |           | NULL | Connect |    6 | Waiting for master to send event                       | NULL             |
      | 11 | system user |           | NULL | Connect |    6 | Slave has read all relay log; waiting for more updates | NULL             |
      +----+-------------+-----------+------+---------+------+--------------------------------------------------------+------------------+
      3 rows in set (0.00 sec)
      
      # 从库上的两个线程
      mysql> show slave status\G
      Slave_IO_State: Waiting for master to send event                                # 对应processlist上ID为10的线程
      Slave_IO_Running: Yes                                                           # 负责从主master上取数
      Slave_SQL_Running: Yes                                                          # 负责将取来的数据应用到从服务器上
      Slave_SQL_Running_State: Slave has read all relay log; waiting for more updates # 对应processlist上ID为11的线程
      ```

- 常用的管理命令

  ``` shell
  mysql> show processlist;
  mysql> show slave status\G
  # 在主库上查看有多少从库
  mysql> show slave hosts;
  
  mysql> stop slave io_thread;
  mysql> start slave io_thread;
  
  mysql> stop slave sql_thread;
  mysql> start slave sql_thread;
  
  mysql> stop slave;
  mysql> start slave;
  ```

  



