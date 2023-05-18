## 搭建kibana
|:-|:-|
|软件|版本|
|kibana|kibana-7.17.7-x86_64.rpm|

|:- |:- |
|服务器|IP|
|linux-node-01|10.4.7.11|

#### 配置文件修改
``` shell
[root@linux-node-01 ~]# grep -Evn "^#|^$" /etc/kibana/kibana.yml

7:server.host: "0.0.0.0"
32:elasticsearch.hosts: ["http://linux-node-04.host.com:9200","http://linux-node-02.host.com:9200","http://linux-node-03.host.com:9200"]
45:elasticsearch.username: "kibana_system"
46:elasticsearch.password: "XCnh15Df0lVhOo9OoqhO"
# 显示登陆页面
115:xpack.monitoring.ui.container.elasticsearch.enabled: true
116:i18n.locale: "zh-CH"

```

#### 启动检查
``` shell
[root@linux-node-01 ~]# systemctl start kibana.service
[root@linux-node-01 ~]# systemctl enable kibana.service

[root@linux-node-01 ~]# netstat -lntup | grep 5601
```
