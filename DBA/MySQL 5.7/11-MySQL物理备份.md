## 物理备份与恢复
- 物理备份与恢复特点
  - 备份集中包括完整的数据库目录和数据文件
  - 备份粒度一般是数据库服务级别
  - 物理备份一般都比较块
  - 备份能够轻易恢复到配置类似的机器上  
  __常用工具__  
  1. 冷备： cp、scp、tar
  2. 热备：XtraBackup
- 使用XtraBackup联机备份
  - XtraBackup简介  
    - XtraBackup是由数据库软件企业Percona提供的一款热备工具，出来能够支持`MyISAM`、`InnoDB`引擎对象，还支持XtraDB引擎  
  - XtraBackup安装[Xbackup下载地址](https://downloads.percona.com/downloads/Percona-XtraBackup-2.4/Percona-XtraBackup-2.4.22/binary/tarball/percona-xtrabackup-2.4.22-Linux-x86_64.glibc2.12.tar.gz)  
    - Xtrabackup： 专用于备份`InnoDB`和`XtraDB`引擎对象
    - Innobackupex：能够备份所有使用`MyISAM`、`InnoDB`、`XtraDB`引擎的表对象（当该命令备份InnoDB和XtraDB引擎数据时，它会通过调用xtrabackup命令完成相关操作） 
    ``` shell
    ## 下载二进制包安装XtraBackup
    wget https://downloads.percona.com/downloads/Percona-XtraBackup-2.4/Percona-XtraBackup-2.4.22/binary/tarball/percona-xtrabackup-2.4.22-Linux-x86_64.glibc2.12.tar.gz
    tar -xf percona-xtrabackup-2.4.22-Linux-x86_64.glibc2.12.tar.gz -C /usr/local/
    mv percona-xtrabackup-2.4.22-Linux-x86_64.glibc2.12 xtrabackup
    chown -R mysql.mysql /usr/local/xtrabackup
    echo 'export PATH="$PATH:/usr/local/xtrabackup/bin"' >> /etc/profile
    
    ## 创建备份账号
    create user xtrabk@'localhost' identified by '123456';
    grant reload,lock tables,Replication client,super,process on *.* to 'xtrabk'@'localhost';
    ```
  - InnoBackupex创建全备  
    __基本参数__  
    - --user：连接使用的用户名
    - --password：连接使用的用户密码
    - --defaults-file：MySQL的参数文件
    - --no-timestamp：禁用生成日期子目录
    - [backup_dir]：指定备份集的存储路径
    ``` sql
    ## 全备
    innobackupex --defaults-file=/mysql/3306/conf/my.cnf --host=0.0.0.0 --user=xtrabk --password='123456' /mysql/backup-200/3306_full
    ```
    __备份集文件__  
    - backup-my.cnf：包含备份所需的二进制信息
    - xtrabackup_binlog_info：记录备份时的二进制日志文件位置
    - xtrabackup_checkpoints：记录LSN(日志序列号，文件类型)以及备份的类型
    - xtrabackup_info：
    - xtrabackup_logfile：备份日志文件，里面记录备份操作过程中数据库的变更
  - InnoBackupex创建增量全备
    - 增量备份的理论基础  
      1、  `InnoBackupex`增量备份必须基于全量备份或者之前的增量备份。可以利用增量备份优化备份策略，如每周一次全备，每天一次增量备份  
      2、  对于`InnoBackupex`来说，只有`InnoDB`引擎对象才有真正意义的增量备份，其他如`MyISAM/CSV`这类引擎的表对象都是完整备份。因为`InnoDB`的每个页(page)都保存了LSN(Log Sequence Number日志序列号)，这个序号能够表示该页最修改时间，增量备份正是根据这个日志序列号来实现的，每次备份时`XtraBackup`都会在备份集中创建一个`xtrabackup_checkpoints`文件，这个文件中的内容记录了最后修改的日志序列号。那么创建增量备份集时，只需要从上次的备份集中找到`xtrabackup_checkpoints`文件，读取最新的日志序列号，而后在创建增量备份时，只选择LSN大于这个序列号的页(page)进行备份，以及这期间产生的binlog日志  
    - 创建增量备份策略
      ![image](https://github.com/xusxlinux/Document/assets/37207302/cfdfde5d-8aea-46e6-9904-fcf6c25d59e5)
     - 创建增量备份  
        __参数说明__  
        `--incremental`：告诉xtrabackup这次创建的时增量备份  
        `--incremental-basedir`：指定为前一次全备或者增量备份的目录  
        __创建增量备份__  
      ``` sql
      ## 增量备份
      
      #方式一 （第一天到第二天备份，第一天到第三天备份，第一天到第四天备份，第一天到第五天备份）
      innobackupex --defaults-file=/mysql/3306/conf/my.cnf --host=0.0.0.0 --user=xtrabk --password='123456' --no-timestamp \
      --incremental --incremental-basedir=/mysql/backup-200/3306_full /mysql/backup-200/3306_inc1
      
      
      #方式二 （每天备份一个新的）
      innobackupex --defaults-file=/mysql/3306/conf/my.cnf --host=0.0.0.0 --user=xtrabk --password='123456' --no-timestamp \
      --incremental --incremental-basedir=/mysql/backup-200/3306_inc1 /mysql/backup-200/3306_inc2
      ```
- 使用XtraBackup恢复  

  1、__准备阶段__：按顺序逐一将各个增量备份集合并到全备份集中  
  
    __恢复的隐含动作:__
  
  ​      前滚(redo)：将redolog日志中已提交的数据同步到数据文件中（redo日志中有两部分数据, 一部分是`有提交标识`. 一部分是`没有提交表示`.） 
  
  ​      回滚(rollback)：将redolog日志中没有提交标识的数据回滚取消掉, 不向数据文件去同步了.
  
  ​      __增量备份(full + inc01)代表了不存在未提交的数据.  当最后一个增量备份合并到全备份集中, 我既要做前滚操作, 也需要回滚操作.(只需要--apply-log 这个参数)__
  
    __`参数说明`:__   
      --apply-log：这个参数表示我要做`前滚`和`回滚`操作.(存在可能未提交的数据要用这个参数)
  
  ​	此选项作用是通过回滚未提交的事务及同步已提交的事务到数据文件（前滚）使数据文件处于一致性状态`[包含前滚和回滚两个操作]`  
  ​    --redo-only：这个参数表示跳过`回滚`操作, 只做`前滚`操作
  
  ​	最后一次恢复(full + inc01 +inc02)之前的增量恢复(full + inc01)，只需redo（前滚）不需rollback（回滚），强制在恢复时只redo（前滚）而跳过rollback（回滚）`[只做前滚操作  跳过回滚操作]`  
  
    ``` sql
  ##对全量备份做准备(--apply-log --redo-only 这两个参数一块使用的时候,只做前滚操作, 不做回滚操作)
  innobackupex --defaults-file=/mysql/3306/conf/my.cnf --apply-log --redo-only /mysql/backup-200/3306_full
  
  ##合并inc1到full中
  innobackupex --defaults-file=/mysql/3306/conf/my.cnf --apply-log --redo-only /mysql/backup-200/3306_full --incremental-dir=/mysql/backup-200/3306_inc01
  
  ##合并inc2到full中(inc2可能存在未提交的数据, 所有只需要--apply-log这个参数)
  innobackupex --defaults-file=/mysql/3306/conf/my.cnf --apply-log             /mysql/backup-200/3306_full --incremental-dir=/mysql/backup-200/3306_inc02
    ```
  ---
  
  2、__恢复阶段__：将准备好的备份集恢复到指定的路径下  
    __`参数说明` __
      --defaults-file：指定初始化选项文件  
      --copy-back：指明接下来要做的操作是从备份路径中，将文件复制会初始化选项指定的路径下  
      [backup_dir]：指定备份文件所在路径
  
    ``` sql
    innobackupex --defaults-file=/mysql/3306/conf/my.cnf --copy-back /mysql/backup-200/3306_full
    ```

​	
