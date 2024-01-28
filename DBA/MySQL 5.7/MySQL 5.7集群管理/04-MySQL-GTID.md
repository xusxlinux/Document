

## GTID介绍

###### GTID和Binlog之间的关系

- 假设有4个binlog: `bin.001` `bin.002` `bin.003` `bin.004`
  - bin.001: Previous-GTIDs=empty; binlog_events有: 1-40
  - bin.002: Previous-GTIDs=1-40; binlog_events有: 41-80
  - bin.003: Previous-GTIDs=1-80; binlog_events有: 81-120
  - bin.004: Previous-GTIDs=1-120; binlog_events有: 121-160
- 如何找到GTID=?对应的binlog文件:
  - 假设现在我们要找GTID=$A, 那么MySQL的扫描顺序为: 从最后一个binlog开始扫描(即: bin.004)
  - bin.004的Previous-GTIDs=1-120,  如果$A=140> Previous-GTIDs, 那么肯定在bin.004中.
  - bin.004的Previous-GTIDs=1-120,  如果$A=88包含在Previous-GTIDs中, 那么继续对比上一个文件bin.003, 然后在循环前面的2的步骤,直到找到为止.
- GTID的复制协议(COM_BINLOG_DUMP_GTID):
  - 从服务器向主服务器发送已执行过的GTID.
  - 主服务器将所有其他GTID发送给从服务器.
  - 同样的GTID不能被执行两次, 如果有同样的GTID, 会自动被skip掉.

![image-20240124173209050](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20240124173209050.png)

###### 传统复制与GTID对比

![image-20240124173310062](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20240124173310062.png)

此时, master服务器宕机, 需要将业务切换到Slave1上, 同时, 我们又需要将Slave2的复制源改成Slave1.

而这种方式的难点在于, 由于同一个事务在每台机器上所在的binlog名字和位置都不一样, 那么怎么找到Slave2当前同步停止点对应Slave1上 master_log_file和master_log_pos的位置就成为了难题



![image-20240124174133080](C:\Users\admin\AppData\Roaming\Typora\typora-user-images\image-20240124174133080.png)

由于同一事务的GTID在所有节点上的值一致, 那么根据slave2 当前停止点的GTID就能定位到slave1上的GTID. 直接使用 CHANGE MASTER TO MASTER_HOST='xxxx', MASTER_AUTO_POSITION=1 命令就可以直接完成failover的工作.



## GTID配置

#### 从0开始搭建 (不细讲)

- 配置主从my.cnf文件
- 创建复制专用账户
- 使用 change master 更新主从配置



#### 传统复制升级为GTID复制

- 配置主从my.cnf文件
- 所有服务器设置 read_only模式, 等待主从服务器同步完毕
- 依次重启主从服务器
- 使用 change master 更新主从配置



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



## 同步故障处理

- 主库新增记录, 从库提示主键冲突

- 主库对象可更新, 从库无对应的对象可更新

- 主库对象可删除, 从库无对应的对象可删除

  ``` shell
  
  ```

- 主库日志被purged

  ``` shell
  ```

  