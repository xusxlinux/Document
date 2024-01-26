## 一 MySQL 半同步复制

#### 半同步复制机制

1丶MySQL在5.5版本之前, 一致采用的是异步复制的方式. 主库的事务执行不会管备库的同步进度, 如果备库数据落后, 主库不幸crash, 那么就会导致数据丢失.

2丶MySQL在5.5版本中引入了半同步复制, 主库在应答客户端提交的事务之需要保证至少一个从库接收并写道relay log 中, 性能较差.

3丶MySQL在5.6版本增强了半同步.

4丶MySQL在5.7版本比较完善(在5.7.2无损复制)

#### 半同步机制原理

​	默认情况下, MySQL的复制是异步的, 主库执行完commit提交操作后, 在主库写入binlog后即可成功返回给客户端, 无需等待binlog传给从库. 当前在主库上写入一个事务并提交成功, 而从库尚未得到主库的binlog时, 主机宕机, 从而从库可能损失该事务, 造成主从库不一致.

​	为了解决这个问题, MySQL引入半同步复制. 半同步复制保证了主库上的每一个binlog都能可靠的复制到从库上, 主库的每次事务提交时, 并不及时反馈给前端用户, 而是等待其中一个从库也接收到binlog并成功写入中继日志后, 主库才返回给客户端. 此时, 至少有两份日志记录, 一份在主库的binlog上, 另一方在至少一个从库的中继日志上, 从而保证了数据的完整性.

#### 半同步复制机制的改进

​	MySQL 5.7.2 版本增加了 `rpl_semi_sync_master_wait_point` 参数, 该参数有两个值

- AFTER_COMMIT(5.6默认值)

  master将每个事务写入binlog (sync_binlog=1), 传递到slave刷新到磁盘(sync_relay=1), 同时主库提交事务. master等待slave反馈收到relay log, 只有收到ACK后 master才将commit OK结果反馈给客户端.

  ![image-20240126150909450](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20240126150909450.png)

  在使用after_commit的模式下, 客户端事务在存储引擎层提交后, 在得到从库确认的过程中, 主机宕机. 此时, 即主库在等待 salve ACK的时候, 虽然没有返回当前客户端, 但是事务以及提交, 其他客户端会读取到已提交事务. 如果slave端还没有读到该事务的events, 同时主库发生了crash, 然后切换到备库. 那么之前读到的事务就不见了, 出现了幻读.

  ![image-20240126151402184](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20240126151402184.png)

- AFTER_SYNC(5.7默认值, 但5.6中无此参数)

  master将每个事务写入binlog,  传递到slave刷新到磁盘(relay log).  master等待slave反馈收到relay log的ack之后,  在提交事务并且返回commit OK给客户端.

  ![image-20240126153259529](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20240126153259529.png)

- 半同步复制与无损复制的对比

  - ACK的时间点不同:
    - 一个先 engine commit后再接收ACK
    - 一个再接收ACK后再engine commit
  - 主从数据一致性
    - 半同步复制意味着再master节点上, 这个刚刚提交的事务对数据库的修改, 对其他事务是可见的. 因此,如果再等待`slave ACK`的时候crash了, 那么会对其他事务出现幻读, 数据丢失.
    - 无损复制再write binlog完成后, 就传输binlog,  但还没有去写commit log,  意味着当前这个事务对数据库的修改,  其他事务也是不可见的.  因此,  不会出现幻读,  数据丢失风险.

---

## 二 MySQL5.7 半同步复制配置

#### 半同步复制配置

``` shell
# 查看MySQL系统版本
mysql> select version();

# 查看主库上安装和开启插件
mysql> show plugins;

# 服务器上插件存放目录
[root@node-01 ~]# ll /mysql/3306/app/mysql/lib/plugin/semisync_master.so
[root@node-01 ~]# ll /mysql/3306/app/mysql/lib/plugin/semisync_slave.so
```

- 主库上安装

  ``` sql
  -- 安装
  mysql> install plugin rpl_semi_sync_master soname 'semisync_master.so';
  -- 开启
  mysql> set global rpl_semi_sync_master_enabled=on;
  -- 确认
  mysql> show variables like '%semi%';
  ```

  ``` tex
  ## 设置为on表示开启了半同步功能
  rpl_semi_sync_master_enabled              
  
  ## 设置单位是毫秒, 表示如果主库等待从库回复消息的时间超过该值, 就自动切换为异步复制模式
  rpl_semi_sync_master_timeout                   
  
  ## 它控制主库接收多少个从库写事务成功反馈,才返回成功给客户端
  rpl_semi_sync_master_wait_for_slave_count 
  
  ## 默认值是ON. 表示master每个事务提交后都要等待slave的接收确认信号
  rpl_semi_sync_master_wait_no_slave        
  
  ## 默认值是AFTER_SYNC, 含义是主库将每个事务写入binlog, 并传递给从库, 刷新到中继日志,主库开始等待从库的反馈, 接收到从库的回复后, 再提交事务并且返回"commit ok"结果给客户端
  rpl_semi_sync_master_wait_point           
  ```

- 从库上安装

  ``` sql
  -- 安装
  mysql> install plugin rpl_semi_sync_slave soname 'semisync_slave.so';
  -- 开启
  mysql> set global rpl_semi_sync_slave_enabled=on;
  -- 重启一下IO线程和SQL线程
  mysql> stop slave;
  mysql> start slave;
  -- 确认
  mysql> show variables like '%semi%';
  ```

#### 测试无损复制

- 测试AFTER_COMMIT参数

  ``` shell
  # 1.设置参数
  set global rpl_semi_sync_master_wait_point='AFTER_COMMIT' 
  set global rpl_semi_sync_master_timeout=50000;	  
    
  # 2.制造故障，停掉slave节点IO线程
  stop slave io_thread;  
    
  # 3.会话1，主节点开启事务
  use demo
  select count(*) from t_columns;
  start transaction;
  insert into t_columns select * from information_schema.columns;
  commit;
    引擎commit已完成
    等待SLAVE节点返回ACK
  
    
  # 4.会话2，查询数据  --user2
  引擎commit已完成
  use demo
  select count(*) from t_columns;
  
    
  # 5.停掉主库
  mysqladmin -uroot -p123456 -hlocalhost shutdown
  
    
  # 6.开启slave节点IO线程，查询数据
  start slave io_thread;  
  use demo
  select count(*) from t_columns;
  
  # 结论: 4与6 看见的数据不一致。
  ```

- 测试 AFTER_SYNC 参数

  ``` shell
  # 1.设置参数
    set global rpl_semi_sync_master_wait_point='AFTER_SYNC' 
    set global rpl_semi_sync_master_timeout=50000;	  
    
  # 2.制造故障，停掉slave节点IO线程
    stop slave io_thread 
    
  
  # 3.会话1，主节点开启事务
    use demo
    select count(*) from t_columns;
    start transaction
  	insert into t_columns select * from information_schema.columns;
    commit;
    引擎commit未完成
    等待SLAVE节点返回ACK
    
  # 4.会话2，查询数据
    引擎commit未完成
    use demo
    select count(*) from t_columns;
    
  # 5.停掉主库
    mysqladmin -uroot -p123456 -hlocalhost shutdown
  
    
  # 6.开启slave节点IO线程，查询数据
    select count(*) from t_columns;
  
  # 结论: 4与6 看见的数据一致。
  ```

#### 卸载

``` sql
-- 查看帮助文档
mysql> help uninstall;

-- 从库上卸载插件
mysql> set global rpl_semi_sync_slave_enabled=off;
mysql> stop slave;
mysql> uninstall plugin rpl_semi_sync_slave ;
mysql> start slave;
mysql> show slave status\G

-- 主库上卸载插件
mysql> uninstall plugin rpl_semi_sync_master;
```













#### 半同步复制机制的改进











