
[SALT.RETURNERS.MYSQL](https://www.unixhot.com/docs/saltstack/ref/returners/all/salt.returners.mysql.html)
```
vim /etc/salt/master

master_job_cache: mysql
mysql.host: 'mysqlhost_ip'
mysql.user: 'salt'
mysql.pass: 'salt'
mysql.db: 'salt'
mysql.port: 3306
```
