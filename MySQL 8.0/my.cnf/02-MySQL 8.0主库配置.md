#### MySQL 8.0主库初始化配置
 - vim /mysql/4131/conf/my.cnf
``` shell
# MySQL_version 8.0.27 innodb engine
# Version 1.1
# Date    2023-06-13

# The MySQL server
[mysql]
default-character-set                               = utf8mb4
socket                                              = /mysql/4131/tmp/mysql.sock

[mysqld]
port                                                = 4131
basedir                                             = /mysql/4131/app/mysql
datadir                                             = /mysql/4131/data
tmpdir                                              = /mysql/4131/tmp
socket                                              = /mysql/4131/tmp/mysql.sock
mysqlx_socket                                       = /mysql/4131/tmp/mysqlx.sock
pid-file                                            = /mysql/4131/tmp/mysql.pid
server_id                                           = 52131
bind_address                                        = 0.0.0.0
skip_name_resolve                                   = ON
transaction_isolation                               = READ-COMMITTED
default_authentication_plugin                       = mysql_native_password
default-storage-engine                              = INNODB
log-bin                                             = /mysql/4131/binlog/mysql-bin
log_bin_index                                       = /mysql/4131/binlog/mysql-bin.index
binlog_format                                       = ROW
binlog_rows_query_log_events                        = ON
log_bin_trust_function_creators                     = OFF
sync_binlog                                         = 1
innodb_flush_log_at_trx_commit                      = 1
max_binlog_size                                     = 2147483648
expire_logs_days                                    = 99
binlog_cache_size                                   = 4194304
sql-mode                                            = "STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION"
explicit_defaults_for_timestamp                     = 1
log-output                                          = FILE
general_log                                         = ON
general_log_file                                    = /mysql/4131/logs/hdss7-11.host.com-general.err
slow_query_log                                      = ON
slow_query_log_file                                 = /mysql/4131/logs/hdss7-11.host.com-slow.err
long_query_time                                     = 10
log-error                                           = /mysql/4131/logs/hdss7-11.host.com-error.err
plugin-load                                         = rpl_semi_sync_master=semisync_master.so;rpl_semi_sync_slave=semisync_slave.so
loose_rpl_semi_sync_master_enabled                  = ON
loose_rpl_semi_sync_master_timeout                  = 10000
loose_rpl_semi_sync_master_wait_point               = AFTER_SYNC
loose_rpl_semi_sync_master_wait_for_slave_count     = 1


report_port=4131
lower_case_table_names=1
max_connections=151
table_open_cache=2000
tmp_table_size=217M
thread_cache_size=10
key_buffer_size=8M
read_buffer_size=64K
read_rnd_buffer_size=256K
innodb_flush_log_at_trx_commit=1
innodb_log_buffer_size=1M
innodb_buffer_pool_size=8M
innodb_log_file_size=48M
innodb_thread_concurrency=17
innodb_autoextend_increment=64
innodb_buffer_pool_instances=8
innodb_concurrency_tickets=5000
innodb_old_blocks_time=1000
innodb_open_files=300
innodb_stats_on_metadata=0
innodb_file_per_table=1
innodb_checksum_algorithm=0
back_log=80
flush_time=0
join_buffer_size=256K
max_allowed_packet=4M
max_connect_errors=100
open_files_limit=4161
sort_buffer_size=256K
table_definition_cache=1400
binlog_row_event_max_size=8K
sync_master_info=10000
sync_relay_log=10000
sync_relay_log_info=10000
max_connections=5000
character-set-server=utf8mb4
collation-server=utf8mb4_general_ci
init_connect='SET NAMES utf8mb4'
max_allowed_packet = 1073741824


[myisamchk]
myisam_max_sort_file_size=100G
myisam_sort_buffer_size=422M
```
