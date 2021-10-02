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
      1.这个`.csv `
  - ARCHIVE
  - BLACKHOLE
  - MRG_MYISAM
  - FEDERATED
