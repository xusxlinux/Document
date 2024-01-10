#### 新建用户
``` sql
select host,user from user where user='root';
create USER 'xusx'@'10.4.7.%' IDENTIFIED BY '123456';
```

#### 添加用户权限
- 权限处理逻辑与授予、回收
``` sql
# 给全部权限
grant all privileges on hdss7_200.* to 'xusx'@'10.4.7.%' identified by '123456';

# 授select权限
grant select on hdss7_200.test_01 to 'xusx'@'10.4.7.%';
# 回收select权限
revoke select on hdss7_200.test_01 from 'work'@'10.4.7.%';
# 查看用户权限
show grants for xusx@'10.4.7.%';

# 刷新
flush privileges;
```
- 权限级别
  - 全局：    desc user;
  - 库  ：    desc db;
  - 表  ：    desc tables_priv;
  - 列  ：    desc columns_priv;
  - 程序：    desc procs_priv;
``` shell
# 创建work用户, 没有任何权限
create USER 'work'@'10.4.7.%' IDENTIFIED BY '123456';
# 查看授权后的work用户
show grants for 'work'@'10.4.7.%';


# 授予work用户select权限  --> [库]
grant select on mysql.* to work@'10.4.7.%';
# 授予work用户select权限  --> [表]
grant select on mysql.user to work@'10.4.7.%';
# 授予work用户select权限  --> [列]
grant select(id) on hdss7_200.test_01 to 'work'@'10.4.7.%';


# work用户, 库级别的 "Select_priv: Y" 权限
select * from db where User='work'\G;
```
- 用户权限设定原则
  - 只读用户  -->  运维人员
    ``` sql
    create user 'work01'@'10.4.7.%' identified by '123456';
    grant select on hdss7_200.* to 'work01'@'10.4.7.%';
    ```
  - 可读可写  -->  前端应用程序
    ``` sql
    create user 'work02'@'10.4.7.%' identified by '123456';
    grant select,insert,update,delete on hdss7_200.* to 'work02'@'10.4.7.%';
    ```
  - 管理用户  -->  项目负责人
    ``` sql
    create user 'work03'@'10.4.7.%' identified by '123456';
    grant all privileges on hdss7_200.* to 'work03'@'10.4.7.%';
    ```
#### 删除用户
``` sql
delete from user where host='10.4.7.%' and user='xusx';
drop user xusx@'localhost';
```


#### 创建数据库
``` sql
create database if not exists xusx default charset utf8mb4 collate utf8mb4_general_ci;
```

#### 创建表
``` sql
create table if not exists test_01(
  id int auto_increment primary key, 
  name varchar(15)
)engine = InnoDB;
```

#### 插入数据
``` sql
insert into test_01 values(1,'3bgm.com');
```

#### 查看表结构
``` sql
desc xusx;

show full columns from test_01;
```
