
``` sql
创建用户
select host,user from user where user='root';
create USER 'root'@'10.4.7.%' IDENTIFIED BY '123456';


# 给xusx用户添加权限, 允许访问hdss7_200 这个库中的所有表
grant all priviliges on hdss7_200.* to 'xusx'@'10.4.7.%' identified by '123456';
grant all privileges on hdss7_200.* to 'xusx'@'localhost' identified by '123456';


# 删除创建错误的用户
use mysql
delete from user where host='10.4.7.%' and user='xusx';



# 创建数据库
create database hdss7_200 DEFAULT charset utf8;

# 创建表
create table hdss7_200(
  id int auto_increment primary key, 
  name varchar(15)
)engine = InnoDB;

insert into hdss7_200 values(1,'3bgm.com');

# 查看表结构
desc hdss7_200;
``` 
