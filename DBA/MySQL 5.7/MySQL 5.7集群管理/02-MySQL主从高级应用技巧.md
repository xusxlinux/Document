## MySQL 主从复制 高级应用技巧

### 复制过滤规则

  默认情况下, master节点生成的所有二进制日志, 都将发送到slave节点, 哪怕slave节点只想同步一张表中的数据, 也得把所有的二进制日志都接收到本地. MySQL为灵活控制复制过滤规则, 提供了一些参数:

- master端  `生产中不建议使用这三个参数`

  - --binlog-do-db:  指定对某数据库的操作事件被记录

  - --binlog-ignore-db: 指定对某数据库的操作事件不被记录

  - set sql_log_bin=0: 会话级别所做操作不被记录

    在master端进行复制过滤会导致主服务器上的二进制日志记录不完整, 一旦主服务器奔溃将无法做到还原所有数据.
    
    

- slave端

  slave节点在接收日志时没有选择权, master节点写过的日志它全部接收到本地, 保存在本地的中继日志文件中.  但slave节点在应用哪些数据库哪些表时具有选择权的.  MySQL提供了一些列参数用于slave节点定义过滤规则:

  - --replicate-do-db=name
  - --replicate-ignore-db=name
  - --replicate-do-table=name
  - --replicate-ignore-table=name
  - --replicate-wild-do-table=foo%.bar%
  - -replicate-wild-ignore-table=foo%.bar%
  
- 两种配置方式:

  - 参数文件

    ``` shell
    [root@node-02 ~]# less /mysql/3306/conf/my.cnf
    replicate-ignore-db=demo1
    replicate-ignore-db=demo2
    
    replicate-do-table=demo1.t_columns
    replicate-ignore-table=demo2.t_columns
    ```

  - 在线配置:

    ``` sql
    # 查看在线配置帮助文档
    mysql> help change replication filter;
    ```

    ``` sql
    -- 指定复制某一个或多个库,其他库不复制
    mysql> stop slave sql_thread;
    mysql> change replication filter replicate_do_db=(demo1,demo2);
    mysql> start slave sql_thread;
    
    # 查看从库配置生效
    mysql> show slave status\G
    Replicate_Do_DB: demo1,demo2
    ```

    ``` sql
    -- 指定忽略某一个或多个库
    mysql> stop slave sql_thread;
    mysql> change replication filter replicate_ignore_db=(demo3);
    mysql> start slave sql_thread;
    
    # 查看从库配置生效
    mysql> show slave status\G
    Replicate_Ignore_DB: demo3
    ```

    ``` sql
    -- 指定复制某一个库中的某一个表
    mysql> stop slave sql_thread;
    mysql> change replication filter replicate_do_table=(demo.t_columns);
    mysql> start slave sql_thread;
    ```

    ``` sql
    -- 指定忽略某一个库中的某一个表
    mysql> stop slave sql_thread;
    mysql> change replication filter replicate_ignore_table=(demo.t_columns);
    mysql> start slave sql_thread;
    ```

  ``` sql
  -- 取消复制限制
  mysql> change replication filter replicate_do_db=();
  mysql> change replication filter replicate_ignore_db=();
  
  mysql> change replication filter replicate_do_table=();
  mysql> change replication filter replicate_ignore_table=();
  ```

  

  - 



### 半同步机制







### 手动主从切换





### 主从延时分析及解决