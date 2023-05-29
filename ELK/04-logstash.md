## logstash

|:-|:-|
|软件|版本|
|jdk|11.0.18|
|logstash|7.17.7|


#### 安装
``` shell
rpm -ivh logstash-7.17.7-x86_64.rpm
ln -vs /usr/share/logstash/bin/logstash /bin/logstash
```

#### 测试
  ``` shell
  # 控制台
  logstash -e 'input { stdin { } } output { stdout { } }'
  
  # 写入文件
  cat test_output.conf 
  input { stdin { } } output { stdout { } }
  
  # logstash输出
  [root@linux-node-01 conf.d]# logstash -f test_output.conf 
  ```
  
