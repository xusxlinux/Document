#### 新建用户
``` sql
select host,user from user where user='root';
create USER 'xusx'@'10.4.7.%' IDENTIFIED BY '123456';
```

#### 添加用户权限
``` sql
# 给全部权限
grant all priviliges on hdss7_200.* to 'xusx'@'10.4.7.%' identified by '123456';

# 只给select权限
grant select on hdss7_200.test_01 to 'xusx'@'10.4.7.%';

# 刷新
flush privileges;
```

#### 删除用户
``` sql
delete from user where host='10.4.7.%' and user='xusx';
drop user xusx@'localhost';
```



``` sql
# 创建数据库
create database hdss7_200 DEFAULT charset utf8;

# 创建表
create table test_01(
  id int auto_increment primary key, 
  name varchar(15)
)engine = InnoDB;

insert into test_01 values(1,'3bgm.com');

# 查看表结构
desc hdss7_200;
``` 
