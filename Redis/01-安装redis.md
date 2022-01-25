#### Redis介绍
``` txt
概念:  
  redis是一个基于内存的Key-Value 非关系型数据库  
特点:  
  内存数据库, 但数据可以持久化  
  数据间没有必然的联系  
  单线程程序  
  存储对象为 Key-Value , 五种常见对象: 字符串,哈希对象,列表对象,集合对象,有序集合对象  
```
#### Redis 体系结构
``` txt
不同的持久化生成不同的文件
RDB
AOF1
AOF2
```
#### Redis 下载安装
``` txt
wget https://download.redis.io/releases/redis-4.0.14.tar.gz
tar xf redis-4.0.14.tar.gz
mv redis-4.0.14 redis
cd redis/
make

# 创建环境变量
export PATH="$PATH:~/redis/src"
```
