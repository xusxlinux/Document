#### 参数文件
_告诉MySQL服务启动时在哪里可以找到数据库文件，并且指定某些初始化参数_  
`mysqld_safe --defaults-file=/mysql/3306/conf/my.cnf`  
如果把参数文件保存在自己指定的路径下，MySQL命令行在启动的时默认读不到，需要通过参数(defaults-file)指定其路径
#### 错误日志文件
作用：记录错误信息 [Note]、[Warning]、[Error]
路径：`show variables like '%log_er%';`
#### 查询日志文件
慢查询日志：  
慢查询指查询语句执行时间超过变量`long_query_time`指定的参数值，并且访问的记录数超过系统变量`min_examined_row_limit`的数量的语句  
默认情况下慢查询日志功能时被禁用的，启用喝禁用慢查询日志文件都是通过MySQL的系统参数控制，主要有三个：
`long_query_time`  
`slow_query_log`  
`slow_query_log_file`指定日志文件路径  
#### 二进制日志文件

#### 其他文件
