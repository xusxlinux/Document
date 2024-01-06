#### MySQL 8.0单库初始化配置
 - vim /mysql/4131/conf/my.cnf
``` shell
[client]
default-character-set                               = utf8mb4

[mysql]
default-character-set                               = utf8mb4
socket                                              = /mysql/4131/tmp/mysql.sock

[mysqld]
port                                                = 4131
basedir                                             = /mysql/4131/app/mysql
datadir                                             = /mysql/4131/data
tmpdir                                              = /mysql/4131/tmp
socket                                              = /mysql/4131/tmp/mysql.sock
pid-file                                            = /mysql/4131/tmp/mysql.pid
server_id                                           = 52131
bind_address                                        = 0.0.0.0
skip_name_resolve                                   = ON
transaction_isolation                               = READ-COMMITTED
default_authentication_plugin                       = mysql_native_password
character-set-server                                = utf8mb4
collation-server                                    = utf8mb4_general_ci
lower_case_table_names                              = 1
log-bin                                             = /mysql/4131/binlog/mysql-bin
log_bin_index                                       = /mysql/4131/binlog/mysql-bin.index
binlog_format                                       = ROW
binlog_rows_query_log_events                        = ON
log_bin_trust_function_creators                     = OFF
sql-mode                                            = "STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION"
explicit_defaults_for_timestamp                     = 1
log-output                                          = FILE
general_log                                         = ON
general_log_file                                    = /mysql/4131/logs/hdss7-11.host.com-general.err
slow_query_log                                      = ON
slow_query_log_file                                 = /mysql/4131/logs/hdss7-11.host.com-slow.err
long_query_time                                     = 10
log-error                                           = /mysql/4131/logs/hdss7-11.host.com-error.err

default-storage-engine                              = INNODB
innodb_buffer_pool_size                             = 200M
innodb_data_file_path                               = ibdata1:10M:autoextend
innodb_log_group_home_dir                           = /mysql/4131/redo
innodb_file_per_table                               = 1
max_allowed_packet                                  = 16M
```
