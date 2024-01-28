





## MySQL 数据类型(整数)

| 数据类型 | 范围(有符号)             | 范围(无符号)                    | 含义 |
| -------- | ------------------------ | ------------------------------- | ---- |
| tinyint  | (-128~127)               | (0, 255)                        | 整数 |
| smalint  | (-32768~32767)           | (0, 65 535)                     | 整数 |
| int      | (-2147483648~2147483647) | (0, 4 294 967 295)              | 整数 |
| bigint   | (+-9.22*10的18次方)      | (0, 18 446 744 073 709 511 615) | 整数 |



``` sql
create table t1(
  c_tinyint tinyint null comment '有符号'
)engine = InnoDB default charset=utf8mb4 collate utf8mb4_general_ci COMMENT "带符号";
```



``` sql
insert into t1 (c_tinyint) select -100;
insert into t1 (c_tinyint) select 100;
insert into t1 (c_tinyint) select -129;
insert into t1 (c_tinyint) select 128;
```



``` sql
alter table t1 add column c_un_tinyint tinyint unsigned null comment "无符号";
```



``` sql
update t1 set c_un_tinyint=128;
```

## MySQL 数据类型(字符型)







## MySQL 数据类型(浮点型, 定点型)







## MySQL 数据类型(日期型)

