- 字符集
  1. 指符号和字符编码的集合
  2. 例如：有"A B a b" 四个字符, 为每个字符定义一个数值: A用0表示 B用1表示, A作为一个符合, 与其对应的0就是A的编码, 这四个字符以及编码形式的组合, 就是字符集
- 校对规则
  1. 比较字符集中字符的规则
  2. 如果希望比较两个字符的大小, 最简单的方式当然就是按照定义好的规则直接对比其编码, 由于0比1小, 因此我们说A比B小, 这就是所谓的校对规则
---
- 显示数据库中所有的字符集 show character set;
  - Charset (字符集)
  - Default collation (校对规则)
    - _ci: 全称：case insensitive (大小写不敏感)
    - _cs: 全程：case sensitive  (大小写敏感)
    - _bin: binary, 表示为二元校对规则, 大小写敏感
    ``` sql
    show collation like 'latin1%';
    show collation like '%utf8%';
    ```
- 指定字符集和检验规则  
  1.服务器端设置
    - 编译MySQL软件时指定
    - 启动参数指定
      ``` sql
      mysqld_safe --defaults-file=/mysql/3306/conf/my.cnf --character-set-server=utf8mb4 --collation-server=utf8mb4_general_ci
      ```
    - 参数文件中配置 my.cnf
      - character_set_server
      - collation_server
    - MySQL服务运行期间更改
      ``` sql
      # 设置全局字符集(会话级别)
      set global character_set_server=utf8;
      ```
  2.客户端连接时指定
    - 客户端连接到服务器时信息的处理过程如下:
      1. 客户端发出的SQL语句, 所使用的字符集由系统变量 `character_set_client` 指定
      2. MySQL服务端接收到语句后, 会用到`character_set_connection`和`collation_connection`两个系统变量, 并且会将客户端发送的语句字符集由`character_set_client`转换到`character_set_connection`
      3. MySQL服务端执行完语句后, 会按照`character_set_results`系统变量设置的字符集返回结果集到客户端
      ``` sql
      show variables like 'character_set%';
      show global variables like 'character_set%';
      ```
    - set names(会话级别)  
    - set character set(会话级别)
    - 配置my.cnf文件
      ``` shell
      [mysql]
      default-character-set                  = utf8
      ```
  3.保存时指定  (同一个库下的不同表可以指定不同的字符集)  不能这么干, 会挨骂~
    ``` sql
    # 案例, 创建一个db_gbk2312字符集的库
    create database if not exists db_gb2312 default charset gb2312 collate  gb2312_chinese_ci;    
    # 查看库的字符集
    show variables like 'character_set_database';
    # 查看库的检验规则
    show variables like 'collation_database';
    
    # 案例, 创建一个
    create table t_gb2312(
      id int auto_increment primary key, 
      name varchar(15)
    )engine = InnoDB default charset=gb2312 collate gb2312_chinese_ci;
    # 查看表的字符集
    show create table test_01;
    
    # 查看列的字符集
    # 查看列的检验规则
    ```
#### 提示
- 尽量让服务器端、客户端字符集保存一致, 并在配置文件中指定
- 全局和库级粒度的字符集设置可以任意修改, 他们不会对现有数据造成影响。但是对于表粒度和列粒度中字符集的修改需要慎重处理, 因为表和列中真正保存着数据, 如果操作不慎, 会丢失数据




