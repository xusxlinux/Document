```ini
cat logstash.ini
[program:charging_api_logs]

command=/data/logstash-2.4.0/bin/logstash -f /data/logstash-2.4.0/etc/charging_api_logs.conf -l /data/logstash-2.4.0/logs/charging_api_logs.log 
directory=/data/logstash-2.4.0
user=root
autorestart=yes


[program:charging_api_station_infos]

command=/data/logstash-2.4.0/bin/logstash -f /data/logstash-2.4.0/etc/charging_api_station_infos.conf -l /data/logstash-2.4.0/logs/charging_api_station_infos.log
directory=/data/logstash-2.4.0
user=root
autorestart=yes


[program:evcos_log]

command=/data/logstash-2.4.0/bin/logstash -f /data/logstash-2.4.0/etc/evcos_log.conf -l /data/logstash-2.4.0/logs/evcos_logs.log
directory=/data/logstash-2.4.0
user=root
autorestart=yes


[program:nginx_log]

command=/data/logstash-2.4.0/bin/logstash -f /data/logstash-2.4.0/etc/nginx_log.conf -l /data/logstash-2.4.0/logs/nginx_log.log
directory=/data/logstash-2.4.0
user=root

[program:kafka]

command=/data/kafka/bin/kafka-server-start.sh config/server.properties
directory=/data/kafka
user=root
autorestart=yes
stopasgroup=true
killasgroup=true
```
