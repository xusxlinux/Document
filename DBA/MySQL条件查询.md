



``` sql
create database if not exists books default charset utf8 collate utf8_general_ci;
use books

# 创建_图书类型表
create table tb_booktype(
	type_id int not null primary key auto_increment comment '图书类型编号',
    type_name varchar(50) not null comment '图书类型名称',
    create_time datetime not null default current_timestamp comment '创建时间'
) comment='图书类型表';


# 创建_图书作者信息表
create table tb_author(
	id int not null primary key auto_increment comment '作者编号',
	author varchar(30) not null comment '作者名称',
    country_no varchar(10) null comment '国家编号',
    country varchar(50) not null comment '国籍',
    memo varchar(500) null comment '作者备注',
    create_time datetime not null default current_timestamp comment '创建时间'
) comment='作者信息表';


# 03 创建_图书信息表
create table tb_book (
	id int not null primary key auto_increment comment '图书编号' ,
	name varchar(50) not null comment '图书名称',
	author varchar(20) not null comment '图书作者',
	price decimal(10,3) null comment '图书价格',
	discount decimal (5,3) null comment '图书折扣',
	memo varchar(500) null comment '图书备注',
	status tinyint null comment '图书状态，1=有货，0=缺货',
	type_id int null comment '图书类型id,依赖于tb_booktype表的type_id' ,
	country_no varchar(10) null comment '国家编号',
	create_time datetime null default current_timestamp comment '创建时间'
) comment='图书信息表';
```



``` sql
-- 插入数据
insert into tb_booktype(type_name, create_time) values ('中文书籍', '2020-10-01 09:00:00');
insert into tb_booktype(type_name, create_time) values ('中文书籍', '2020-10-02 10:05:00');
```





``` sql
-- 插入中国作者
insert into tb_author(author, country_no, country, memo, create_time) select '纪徒弟01','1001','中国','大学士','2021-02-01 20:10:59';
insert into tb_author(author, country_no, country, memo, create_time) select '纪徒弟02','1001','中国','大学士','2021-02-02 21:10:15';
insert into tb_author(author, country_no, country, memo, create_time) select '纪徒弟03','1001','中国','大学士','2021-02-03 12:10:30';
insert into tb_author(author, country_no, country, memo, create_time) select '纪徒弟04','1001','中国','大学士','2021-02-04 13:15:59';


-- 插入法国作者
insert into tb_author(author, country_no, country, memo, create_time) select '雨果','1002','法国','作家','2021-02-01 13:15:59';
insert into tb_author(author, country_no, country, memo, create_time) select '凡尔纳','1002','法国','作家','2021-02-02 13:15:59';
-- 插入丹麦作者
insert into tb_author(author, country_no, country, memo, create_time) select '安徒生','1003','丹麦','作家','2021-02-01 13:15:59';
-- 插入英国作者
insert into tb_author(author, country_no, country, memo, create_time) select '莎士比亚','1004','英国','作家','2021-02-01 13:15:59';
```





``` sql
-- 插入书籍信息
insert into tb_book (name,author,price,discount,memo,status,type_id,country_no,create_time)
select '经部01','纪徒弟01',600,1,null,1,1,'1001','2018-10-01'
union all
select '经部02','纪徒弟01',500,0.8,null,1,1,'1001','2018-10-02'
union all
select '经部03','纪徒弟01',300,0.6,null,1,1,'1001','2018-10-05'
union all
select '史部01','纪徒弟02',400,1,null,1,1,'1001','2019-10-01'
union all
select '史部02','纪徒弟02',200,0.6,null,1,1,'1001','2019-10-12'
union all
select '史部03','纪徒弟02',800.8,0.4,null,1,1,'1001','2019-10-15'
union all
select '子部01','纪徒弟03',900,1,null,1,1,'1001','2020-01-01'
union all
select '子部02','纪徒弟03',100,0.7,null,1,1,'1001','2020-02-05'
union all
select '子部02','纪徒弟03',100,0.7,null,1,1,'1001','2020-02-05'
union all
select '子部03','纪徒弟03',200,0.6,null,1,1,'1001','2020-04-15'
union all
select '集部01','纪徒弟04',300,0.9,null,1,1,'1001','2020-10-01'
union all
select '集部02','纪徒弟04',500,0.7,null,1,1,'1001','2020-11-05'
union all
select '集部03','纪徒弟04',300,0.3,null,1,1,'1001','2020-11-15'
union all
select '巴黎圣母院','雨果',200,1,null,1,2,'1002','2018-10-01'
union all
select '悲惨世界','雨果',98,0.8,null,1,2,'1002','2018-10-02'
union all
select '亚马逊漂流记','凡尔纳',300,0.6,null,1,2,'1002','2018-10-05'
union all
select '神秘岛','凡尔纳',98,0.6,null,1,2,'1002','2018-10-05'
union all
select '皇帝的新装','安徒生',69,1,null,1,2,'1003','2018-10-01'
union all
select '卖火柴的小女孩','安徒生',90,0.8,null,1,2,'1003','2018-10-02'
union all
select '海的女儿','安徒生',200,0.6,null,1,2,'1003','2018-10-05'
union all
select '丑小鸭','安徒生',300,0.6,null,1,2,'1003','2018-10-05'
union all
select '拇指姑娘','安徒生',75,0.6,null,1,2,'1003','2018-10-05'
union all
select '火星探秘','',609,1,null,0,0,' ','2018-10-01'
union all
select '金星探秘','',99,0.8,null,0,0,' ','2018-10-02';
```

