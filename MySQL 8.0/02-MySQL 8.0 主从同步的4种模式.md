## 主从复制的几种模式
#### 1. 异步复制 (会丢失数据)
  - 主库和客户端相关沟通, 不在乎从库是否同步好数据. 主库宕机的情况下, `从库`(slave)从`主库`(master)得到的信息没有完全写入从库的情况下. 发生主从切换的情况下, 从库没有100%主库的数据, 所有存在数据丢失的情况.  


#### 2. 半同步复制(提高数据安全级别, 损失一部分性能) `生产需要使用这个方式比较稳妥`
  - 客户端和主库的数据交互, 要等待从库返回确认信息.
  - 使用半同步需要安装插件
    - 在MySQL命令行执行如下命令
      ``` shell
      install plugin rpl_semi_sync_master SONAME  'semisync_master.so';
      install plugin rpl_semi_sync_slave SONAME 'semisync_slave.so'
      ```
    - 在MySQL配置文件中添加
      ``` shell
      plugin-load  =  rpl_semi_sync_master=semisync_master.so;rpl_semi_sync_slave=semisync_slave.so
      ```
  - 在主库上查看配置是否生效
    ``` shell
    show plugins;
    show status like '%semi%';
    ```
  - 在从库上查看配置是否生效
    ``` shell
    show plugins;
    show status like 'rpl_semi_sync_slave_status';
    ```

#### 3. 全同步复制
  - 主库执行了一个事务, 所有的从库都执行完了该事务才能返回客户端(和半同步复制略有不同)  
    方案:  
        MySQL 组复制 (MGR):  
        介绍: 一种可用于实施容错系统的技术. 组复制是一组服务器, 每个服务器都有自己的完整数据副本, 并通过消息传递互相交互.  

        特点:  
        组复制是什么?   一个组复制由多个服务器组成, 该组中的每个服务器都可以随时独立执行事务.  
        对于任何读写事务, 该组都需要确定提交, 因此执行提交操作不是来自原始服务器的单方面决定.  

#### 4. 延迟复制
  - 在从库查看
    ``` shell
    show slave status\G
    
      SQL_Delay:  主库执行完相关操作后,  从库延迟多少时间进行数据的一个同步.
      SQL_Remaining_Delay: NULL   -->  倒计时.DML操作后 NULL会变成倒计时的状态
    ``` 
  - 作用: 进行灾难恢复  
    从库更新落后于主库一段时间,  在这段时间内, 可以保证数据的安全  
    如果不采用延迟复制, 则需要采用备份恢复中的基于时间点的复制, 很消耗时间  
