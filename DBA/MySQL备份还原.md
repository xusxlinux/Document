## MySQL 备份和还原



#### 一  只备份表结构

###### 导出表结构  加`-d` 只导出表结构;

1丶导出某张表的表结构

``` sql
mysqldump -uroot -p -d 库名 表名 > /MySQL_Backup/表名_schema.sql
```

2丶 导出多张表的表结构, 表之间用空格分开

``` sql
mysqldump -uroot -p -d 库名 表名1 表名2 > /MySQL_Backup/表名_schema.sql
```

3丶导出整个数据的表结构

``` sql
mysqldump -uroot -p -d 库名 > /MySQL_Backup/所有表_schema.sql
```

#### 二  只备份数据

###### 导出表的数据 加 `-t`

1丶 导出某一个表数据 加 -t ;

``` sql
mysqldump -uroot -p -t 库名 表名 > /MySQL_Backup/表数据.sql
```

2丶 导出多张表的表数据, 表之间用空格分开

``` sql
mysqldump -uroot -p -t 库名 表名1 表名2 > /MySQL_Backup/表1_表2数据.sql
```

3丶 导出整个数据的数据

``` sql
mysqldump -uroot -p -t 库名 > /MySQL_Backup/所有表数据.sql
```

4丶 按照条件导出数据

``` sql
mysqldump -uroot -p -t 库名 表名 --where="id>'1'"> /MySQL_Backup/增加条件数据.sql
```

#### 三  备份表结构和数据

###### 导出数据库所有表的结构和数据 不加参数

``` sql
mysqldump -uroot -p 库名 > /MySQL_Backup/所有表结构和数据.sql
```

#### 四  备份数据

- 备份1个数据库

``` sql
mysqldump -uroot -p --databases 库名 > /MySQL_Backup/所有表结构和数据.sql
```

- 备份多个数据库

``` sql
mysqldump -uroot -p --databases 库名1 库名2 > /MySQL_Backup/所有表结构和数据.sql
```



``` sql
mysqldump -uroot -p --databases 库名1 -single-transaction --master-data=2 --events --triggers --routines /MySQL_Backup/所有表结构和数据.sql
```





#### 五  还原数据库

``` sql
```

