## MySQL数据库的操作

| 对象 | create | drop   | alter  | show   |
| :--- | ------ | ------ | ------ | ------ |
| 数据 | insert | delete | update | select |

**DDL (data Definition Language 数据定义语言)**

操作数据库对象: 数据库, 表, 视图, 函数, 存储过程等. DDL操作是数据库对象, 不对具体的数据进行操作;

**DML (data Manipulation Language 数据操控语言)**

操作数据库对象中的数据;

**DQL (data Query Language 据库查询语言)**

查询数据库中的数据

**DCL (data Control Language 数据控制语言)**

用来授予或回收访问数据库的某种特权, 并控制数据库操纵事务等;

#### 一 操作库

#### 1.1 数据库的`增删改查`

``` sql
-- 删库 
drop database if exists demo;

-- 创建库
create database if not exists demo default charset utf8mb4 collate utf8mb4_general_ci;

-- 修改库的名称 5.7.1x后移除命令
rename database demo 同demo1;
-- 修改数据库编码
alter database demo character set utf8 collate utf8_general_ci;
```

#### 二 表操作

#### 2.1 数据库中表的`增删改查`

`create`   `drop`   `alter`   `show`

```sql
-- 创建表
create table city1(
  name varchar(50) NOT NULL COMMENT "城市名称",
  population int(11) NOT NULL COMMENT "人口数量",
  zip varchar(10) DEFAULT NULL COMMENT "城市编码"
)engine = InnoDB default charset=utf8mb4 collate utf8mb4_general_ci COMMENT "城市表";
```

``` sql
-- 查看表信息
desc city1;
show full columns from city1;

-- 修改表名
alter table city1 rename to city;

-- 插入字段
alter table city add column create_time datetime null comment "创建日期";
alter table city add column province varchar(50) null comment "省份" after zip;
alter table city add column id int not null auto_increment primary key comment "自增id" first;

-- 修改表属性
alter table city modify zip varchar(15) null comment "城市邮编";
alter table city change column zip code varchar(10) null comment "城市邮编";

-- 删除列
alter table city drop column province;

-- 删除表
drop table city;
```

#### 三 表数据操作

`insert`  `delete`  `update`  `select`

#### 3.1 数据的`增删改查`

###### 3.1.1 插入数据

``` sql
# 语法一 insert into ... values...
insert into city(id,name,population,code,province,create_time) values (1, '北京市','23000000',10010,'北京','2022-08-22 07:36:37.163223');
insert into city values (2, '上海市','23000000',10010,'上海','2022-08-23 07:36:37.563223');


# 语法二 insert into ... select ...
insert into city(id,name,population,code,province,create_time) select 3, '重庆市','23000000',10010,'四川','2022-08-24 00:36:37.863223';


# 语法三 insert into ... set ...
insert into city set id=4, name='深圳', population='23000000';
```

###### 3.1.2 删除数据

``` sql
# 删除数据 增加条件删除
delete from city where id=4;

# 删除所有数据
drop from city;
truncate table city;
```

###### 3.1.3 修改数据

``` sql
# 修改数据
update city set province='重庆' where id=3;
update city set province='重庆_new', code='10013' where id=3;

# 根据两个字段改一个值
update city set province='重庆' where code='10013' and name='重庆市';

# 更改数据不加条件, 会修改全部
update city set code='9999';
# where 1=1 表示为判断为 真
update city set code='8888' where 1=1;
update city set name='北京市_new' where name='北京市';  
```

###### 3.1.4 查询数据

``` sql
# 无条件查询
select * from city;
select id,name,population,code from city;

# 有条件查询
select code,name from city where id=1;
select code,name from city where id=1 and province='北京';

# 起别名
select name as '城市名称', code as '邮政编码' from city;
select name '城市名称', code '邮政编码' from city;

# 拼接
select concat(name,'new'), concat(code,'123') from city;
select concat(name,'new') '城市名称', concat(code,'123') '邮政编码' from city;

# 字段拼接
select id,(id+10) as '城市ID' from city;
```

