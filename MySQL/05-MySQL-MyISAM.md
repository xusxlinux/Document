#### MyISAM 存储引擎
MyISAM文件结构
 - `.frm`存储表对象结构
 - `.MYD`数据文件，存储数据
 - `.MYI`索引文件，用于存储表的索引信息(数据和索引是分开存放的)
``` sql
create table t_myisam01(id int, c1 char(10))ENGINE=MyISAM;
create table t_myisam02(id int, c1 varchar(10))ENGINE=MyISAM;
show table status like 't_myisam0%'\G
```

MyISAM引擎格式
  - 静态：表种不包含边长类型的列(varchar/varbinary/blob/text) 使用`show table status like 't_myisam0%'\G`查看`Row_format`
    - 静态格式特点：
      - 查询较快
      - 崩溃后易于重建，因为记录保存的位置是固定的
      - 通常会比动态格式的表占用更多的磁盘空间
  - 动态：包含边长字符类型的列(varchar/varbinary/blob/text)
    - 动态格式特点：
      - 相比静态表，每行仅需要存储字符实际需要的空间，会节省一些空间
      - 崩溃时恢复会更加复杂
  - 压缩：通过myisampack创建
    - 压缩格式特点：
      - 只读，不支持添加和修改

MyISAM引擎特点
  - 不支持事务(事务是指逻辑上的一组操作，组成这组操作的各个单元，要么全成功，要么全失败)
  - 表级锁：虽然锁定的实现成本很小，但降低了其并发性
  - 读写相互阻塞：不仅会在写入的时候阻塞读取，还会在读取的时候阻塞写入，但读本身不会阻塞另外的读
  - 只缓存索引：MyISAM可以通过key_buffer_size 缓存索引，索引大大提高访问性能，减少磁盘IO。但是这个缓存区指挥缓存索引，不会缓存数据
  - 不支持外键约束

MyISAM适用场景
  - 非事务性的业务(监控系统，审计系统)
  - 读写并发访问较少的业务系统
