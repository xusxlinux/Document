#### MySQL体系结构

- 常见存储引擎
  - MEMORY
    - 特点：
      1. 这个`.frm`文件是存储表的结构信息
      2. 数据存放在内存中, 没有表数据文件, 重启后数据丢失
      3. 使用表级锁
      4. 表的最大大小受参数max_heap_table_size的限制
    - 适用场景：
      主要用于内容变化不频繁的表, 或者作为中间的查找表
  ``` sql
  create database if not exists db_innodb default charset utf8  collate utf8_general_ci;
  # 创建 t_mem_01 插入数据后, 重启数据库, 数据消失
  create table t_mem_01(id int)engine=memory;
  
  # 设置1m的存储内存
  set max_heap_table_size=1024*1024;
  create table t_mem_1m(v1 varchar(10000))engine=memory;
  
  # 设置2m的存储内存
  set max_heap_table_size=1024*1024*2;
  create table t_mem_2m(v1 varchar(10000))engine=memory;
  
  # 这个表默认可以存储16m的数据
  show table status like 't_mem%';
  ```
  - CSV
    - 特点：
      1. 这个`.csv `文件是存储表内容
      2. `.csm`文件存储表的元数据如表的状态和数据量
      3. `.frm`文件存储表的结构信息
      4. 所有列非空 `not null`
      5. 不支持索引, 不支持分区
    - 适用场景：
      数据存储为CSV文件格式, 不用进行转换
   ``` sql
   # 所有列非空
   create table t_csv_01(id int not null, c1 varchar(10) not null) ENGINE=csv;
   ```
  - ARCHIVE
    - 特点：
      1. 这个`.frm `文件是存储表内容
      2. `.ARZ`文件存储表的数据
      3. 支持insert、replace和select操作, 但是`不支持`update和delete
      4. 往archive表插入的数据会经过压缩、压缩比非常高、存储空间大概是innodb的10-15分之一 
    - 适用场景：
      适用于数据归档、采集等场景 
  ``` sql
  create table t_arch(id int)engine=archive;
  insert into t_arch values(1);
  
  # 不支持删除操作
  delete from t_arch;
  ERROR 1031 (HY000): Table storage engine for 't_arch' doesn't have this option
  ```
  - BLACKHOLE
    - 特点：
      1. 只有表结构文件(.frm), 没有表数据文件
      2. 写入的数据会消失, 但会记录在binlog日志当中
    - 应用场景：
      配置一主多从时, 多个从服务器会在主服务器上分别开启自己相对应的线程, 执行`binlog dump`命令, 而且多个此类型进程并不是共享的.
      为了避免因多个从服务器同事请求而导致主机资源耗尽, 可以单独建立一个伪的从服务器或者`分发服务器`  (不会存储数据,就代表数据不会落盘,这样就避免浪费存储空间)
  ``` sql
  create table t_blackhole(i int,c1 char(10)) engine=BLACKHOLE;
  insert into t_blackhole values(1,'record one'),(2,'record two');
   
  # 查不到数据
  select * from t_blackhole;
  ```
  - MRG_MYISAM
    - 特点：
      1. MRG_MYISAM引擎表本身不保存数据, 只是起到汇总作用, 将一组`结构相同`的MyISAM表逻辑聚合到一起
      2. `.frm`文件存储表的结构信息
      3. `.mgr`不保存数据，保存的是数据来源
      4. 默认情况下, 不能向MRG_MyISAM引擎中插入记录。如果像插入记录，在创建MRG_MYISAM引擎时，可以通过`INSERT_METHOD`选项，指定插入的记录写道哪个表中
         - `NO`：不允许插入 
         - `FIRST`：插入到第一个表中
         - `LAST`：插入到第二个表中
    - 适用场景：
      单表过大, `水平分表` (每个月生成1千万数据, 可以分成12月12张表, 查找聚合表就行, 可以避免单个表数据过大问题)
  ``` sql
  create table t_myisam_01(id int not null auto_increment primary key,c1 varchar(20)) engine=MyISAM;
  create table t_myisam_02(id int not null auto_increment primary key,c1 varchar(20)) engine=MyISAM;
  
  insert into t_myisam_01(c1) values('this'),('is'),('myisam1');
  insert into t_myisam_02(c1) values('this'),('is'),('myisam2');
  
  # 把两个相同表结构的表合并, (逻辑上合并) 起到聚合作用
  create table t_mer1(id int not null auto_increment primary key,c1 varchar(20)) engine=MRG_MyISAM union=(t_myisam_01,t_myisam_02) INSERT_METHOD=LAST;
  ```
  - FEDERATED
    - 特点：
      1. 访问在远程数据库的表中的数据, 类似Oracle中的 db link
      2. `.frm`文件存储表的结构信息
    - 适用场景：
      跨不同服务器的数据库查询
  ``` sql
  # 开启federated sed -i '9a federated' /mysql/data/3306/my.cnf 
  show engines \G
    
  create table t_fd(id int(11) NOT NULL, name varchar(30) NOT NULL, age int(11) NOT NULL, PRIMARY KEY (id))ENGINE=InnoDB CHARSET=utf8;
  insert into t_fd(id,name,age) values(0,'zhangsan',20);
  
  # 在其他的服务器的库中的建表语句, 以及MySQL连接方式
  create table t_fd(id int(11) NOT NULL, name varchar(30) NOT NULL, age int(11) NOT NULL, PRIMARY KEY (id))ENGINE=FEDERATED CONNECTION='mysql://root:123456@10.4.7.200:3306/hdss7_200/t_fd';
  
  # 可以在其他服务器上的库查到数据
  select * from t_fd;
  
  # drop无法删除其他服务器上的表. 只能删除本地库的表
  drop table t_fd;
  
  # truncate会把其他服务器上的表数据删除
  truncate table t_fd;
  ```
