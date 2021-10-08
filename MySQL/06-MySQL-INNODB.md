#### InnoDB存储引擎

InnoDB特性概述
  - 设计遵循`ACID模型`，支持`事务`
  - 支持行级锁，以提升多用户并发时的读写性能
  - Innodb引擎表组织数据时，按照`主键聚簇`
  - 支持外键约束
  - 拥有从服务器奔溃中恢复的能力，能够最大限度地保护数据
  - Innodb拥有自己独立的缓存池，常用的数据(含索引)都在缓存中

InnoDB事务
  - ACID模型
    - Atomic模型(原子性)
      - 所有语句作为一个单元全部成功执行或全部取消，不能出现中间状态  
         `例子`：A账户向B账户转账，A账户进行`扣款`操作，并在B账户进行`存款`操作 (要么全部成功，要么全部失败)
    - Consistent(一致性) [官方文档描述](https://dev.mysql.com/doc/refman/5.7/en/mysql-acid.html)
      - 指数据库事务不能破坏关系数据的完整性以及业务逻辑上的一致性
    - Isolated(隔离性)
      - `事务`之间不相互影响 (在两个tty中的MySQL客户端，对同一张表进行操作，称为两个事务)
    - Durable(持久性)
      - `事务`成功完成后，所做的所有更改都会准确地记录在数据库中，所做的更改不会丢失
  - 事务概述：  
      事务是数据库区别于文件系统的重要特性之一。事务是指逻辑上的一组操作，组成这组操作的各个单元，要么全成功，要么全失败。同时事务有严格的定义，它必须同时满足ACID
  - 事务控制：  
      默认情况下，链接到NySQL服务的客户端处于自动提交模式，也就是说每条DML执行即提交。若希望启用事务支持，有两种方式：
      - 禁用事务自动提交 `show variables like 'autocommit';`  -->  `set autocommit=off;`    
          MySQL中默认提交功能由系统变量`autocommit`控制，将该变量值为`0`或`off`即可禁用自动提交，将事务的提交`commit`和`rollback`控制权交由前端用户控制
          ``` sql
          set autocommit=off;
          create table t_idb01(id int not null auto_increment primary key, c1 varchar(20))ENGINE=innodb auto_increment=1;
          insert into t_idb01(c1) values('a');
          
          # 不想操作了，执行下面的命令，就回滚了
          rollback;
          
          # 使用commit提交操作，不能在回滚了，并且自增的id边成 3
          insert into t_idb01(c1) values('a');
          commit；
          ```
      - 显示声明事务  
          执行DML语句前，先通过`start transaction`或者`begin`语句启动一个事务，执行SQL语句后，就可以通过commit或者rollback语句来控制事务的提交或回滚  
            start transaction; //事务开始  
              DML sql  
              DML sql  
            commit or rollback; //事务结束
InnoDB体系结构

InnoDB逻辑存储结构

什么是聚簇索引
