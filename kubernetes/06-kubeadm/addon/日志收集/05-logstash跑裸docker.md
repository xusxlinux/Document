

- 下载logstash的镜像
``` shell
docker pull logstash:7.14.0
```
- `logstash`的配置文件, 按照环境启动不同的`logstash`配置文件
  - vim /etc/logstash/logstash-dev.conf
  - vim /etc/logstash/logstash-test.conf
  - vim /etc/logstash/logstash-prod.conf
``` conf
input {
  kafka {
    bootstrap_servers => ["hdss7-12.host.com:9092,hdss7-21.host.com:9092,hdss7-22.host.com:9092"]
    client_id => "10.4.7.200"
    consumer_threads => 4
    group_id => "k8s_dev"
    topics_pattern => "k8s-fb-dev-.*"
  }
}

filter {
  json {
    source => "message"
  }
}

output {
  elasticsearch {
    hosts => ["172.16.25.243:9200"]
    index => "k8s-dev-%{+YYYY.MM.DD}"
  }
  stdout {
    codec => rubydebug
  }
}
```
- 运行容器
  - `--add-host` 这个参数是用于解析主机名。
    - elasticsearch:172.16.25.243 es集群中services的ClusterIP
``` shell
docker run -d --name logstash-dev -v /etc/logstash:/etc/logstash  \
  --add-host elasticsearch:172.16.25.243 \
  logstash:7.14.0  \
  -f /etc/logstash/logstash-dev.conf
```

