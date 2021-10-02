- MySQL体系结构

- 常见存储引擎
  - MEMORY
    - 特点：
      1. 这个`.frm`文件是存储表的结构信息
      2. 数据存放在内存中, 没有表数据文件, 重启后数据丢失
      3. 使用表级锁
      4. 表的最大大小受参数max_heap_table_size的限制
    - 适用场景：
      主要用于内容变化不频繁的表, h或者作为中间的查找表
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
  - MRG_MYISAM
  - FEDERATED
