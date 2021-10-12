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
      &ensp; &ensp; 事务是数据库区别于文件系统的重要特性之一。  
      &ensp; &ensp; 事务是指逻辑上的一组操作，组成这组操作的各个单元，要么全成功，要么全失败。同时事务有严格的定义，它必须同时满足ACID
  - 事务控制：  
      &ensp; &ensp; 默认情况下，链接到NySQL服务的客户端处于自动提交模式，也就是说每条DML执行即提交。若希望启用事务支持，有两种方式：
      - 一、禁用事务自动提交  
          &ensp; &ensp; `show variables like 'autocommit';`  -->  `set autocommit=off;`  
          &ensp; MySQL中默认提交功能由系统变量`autocommit`控制，将该变量值为`0`或`off`即可禁用自动提交，将事务的提交`commit`和`rollback`控制权交由前端用户控制
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
      - 二、显示声明事务  
          &ensp; &ensp; 执行DML语句前，先通过`start transaction`或者`begin`语句启动一个事务，执行SQL语句后，就可以通过commit或者rollback语句来控制事务的提交或回滚  
            &ensp; &ensp; start transaction; //事务开始  
              &ensp; &ensp; DML sql  
              &ensp; &ensp; DML sql  
            &ensp; &ensp; commit or rollback; //事务结束  

InnoDB体系结构
  - 内存结构
    - `Buffer Pool`  
      &ensp; &ensp; InnoDB专用缓存，用来缓存表对象的数据和索引信息的。大小由`innodb_buffer_pool_size`变量指定，默认为`128MB`。在独立的数据库服务器中，该缓存大小可以设置为物理内存的`80%`  
      &ensp; &ensp; 对二级索引的更改不直接更改数据文件当中的，而是将他缓存到 change buffer中更改
    - `Change Buffer`  
      &ensp; &ensp; Change Buffer的主要目的是将对二级索引的操作(insert, delete, update)缓存下来，而不是直接读入索引页进行更新；再择机将Change Buffer中的记录合并到真正的二级索引中，以此减少二级索引的随机IO  
      &ensp; &ensp; innodb_chang_buffer_max_size：表示change buffer在buffer pool中的最大占比，默认`25%`，最大`50%`  
      &ensp; &ensp; 在MySQL5.5之前的版本中，由于只支持缓存insert操作，最初叫做insert buffer，只是后来的版本中支持了更多的操作类型缓存，才改叫 Change Buffer  
    - `Log Buffer`  
      &ensp; &ensp; 存储要写入日志文件的数据的内存区域。 Log Buffer的大小由 innodb_log_buffer_size变量自定义。默认大小为`16MB`。Log Buffer的内容会定期刷到磁盘上
      
      __知识加油站__  
        1. InnoDB中 主键(聚簇索引)以外的索引都是二级索引  
        2. InnoDB中 索引和数据(行记录)在同一个文件中存储  
        3. InnoDB中 二级索引在文件中有自己单独的数据页  
        4. 对行记录的(insert, delete, update)操作时，二级索引可能也会被执行相应的(insert, delete, update)操作，很可能会产生大量的物理读(物理读二级索引数据页)    

- 物理存储结构
  - 系统表空间  
    &ensp; &ensp; 默认情况下InnoDB引擎只对应一个表空间，即系统表空间，所有InnoDB引擎表的数据(含索引)都存储再该表空间中，注意仅仅是保存数据和索引，表对象的结构信息仍然保存再`.frm`文件中  
    &ensp; &ensp; InnoDB系统表空间对应哪些物理数据文件，通过系统变量`innodb_data_file_path`指定，其语法：  
    __innodb_data_file_path=file_name:file_size[:autoextend[:max:max_file_size]]__  
    - file_name：指定文件名
    - file_size：指定文件初始化大小
    - autoextend：指定文件是否可扩展，可选参数
    - :max:max_file_size：指定该数据文件最大可占用空间，可选参数
    &ensp; &ensp; MySQL5.7中 autoextend默认一次扩展64M的空间，可通过innodb_autoextend_increament系统变量指定  
    &ensp; &ensp; 默认情况下InnoDB数据文件会保存在MySQL的data目录中。如果要变更文件的保存路径，可以通过系统变量`innodb_data_home_dir`设置  
    &ensp; &ensp; &ensp; &ensp; 例如`innodb_data_home_dir=/mysql/3306/data`
  - 独立表空间  
    &ensp; &ensp; 默认的情况下，InnoDB引擎的表和索引都保存在系统表空间对应的数据文件中，当数据量很大的时候，管理成本就会上升。系统表空间的数据文件扩展后无法回缩，即使表被`DROP`或者`TRUNCATE`，甚至该表空间内实际已经没有任何数据，已分配的空间仍然仅是相对于InnoDB数据可用，而不能被操作系统再分配给其他文件使用。  
    &ensp; &ensp; 针对这种情况，可以考虑应用InnoDB数据存储的另一项设定，InnoDB将其定义为多重表空间(multiple tablespaces)，就是每个表对象拥有一个独享的`.ibd`为扩展名的数据文件，这个文件就是一个独立的表空间。  
    &ensp; &ensp; 是否启用独立的表空间是由系统变量 `innodb_file_per_table`控制  
    __独立表空间的优点__  
    a. 各表对象的数据独立存储至不同的文件，可以更灵活地分散I/O、执行备份及恢复操作  
    b. 当执行`DROP`或者`TRUNCATE`删除表对象时，空间可以即时释放回操作系统层
  - Redo日志  
    &ensp; &ensp; redo日志仅针对InnoDB引擎，MySQl数据库的其他引擎是用不到的。默认情况下，InnoDB引擎会创建两组大小均为5MB的日志文件，分别命名为`ib_logfile0`和`ib_logfile1`,日志文件保存在datadir变量指定的路径下。不过可以通过InnoDB的专用参数修改日志路径、日志大小以及日志文件组的数量：  
    - innodb_log_group_home_dir
    - innodb_log_file_size
    - innodb_log_file_in_group  

    __redo 在事务中的应用__  
      redo的作用：  
      &ensp; &ensp; redo来实现事务持久性，redo对于AC也有相应的作用  
      持久性相关组件：  
      &ensp; &ensp; 重做日志缓存(redo log buffer)，是易失的  
      &ensp; &ensp; 重做日志文件(redo log file)，是持久的  
      持久性远离：  
      &ensp; &ensp; 当事务提交 `commit` 时，会刷新当前事务的`redo buffer`到重做日志文件中进行持久化，待事务的commit完成才算完成(`会将此日志打上commit标记`)。还会顺便将一部分`redo buffer`中没有提交的事务日志也刷新到redo日志文件中。  
  - Undo日志  
    &ensp; &ensp; 对于事务操作来说，有提交就必然会有回滚，提交就是确定保存写入的数据。  
    &ensp; &ensp; 有两个步骤：  
    &ensp; &ensp; &ensp; &ensp; `撤销刚刚做的修改`，`将数据恢复至修改前的状态`。  
    &ensp; &ensp; 怎么回滚？  
    &ensp; &ensp; &ensp; &ensp; 修改前将旧数据保存下来，保存下的这部分数据就是`UNDO`日志，存储在系统分配好的回滚段中。  

InnoDB逻辑存储结构

什么是聚簇索引
