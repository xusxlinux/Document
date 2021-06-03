
```
https://hub.docker.com/_/openjdk?tab=tags&page=1&ordering=last_updated

# 自己在hub仓库下载一个openjdk的jre包
docker pull openjdk
```

```yaml
$ cat Dockerfile
FROM harbor.od.com/public/jre8:8u112
RUN /bin/cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime &&\
    echo 'Asia/Shanghai' >/etc/timezone
ADD config.yml /opt/prom/config.yml
ADD jmx_javaagent-0.3.1.jar /opt/prom/
WORKDIR /opt/project_dir
ADD entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]
```

```yml
$ cat config.yml
---
rules:
  - pattern: '.*'
```

通过jmx的一个jar包来收集jvm的状态
```
$ wget https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.3.1/jmx_prometheus_javaagent-0.3.1.jar -O jmx_javaagent-0.3.1.jar
```

```bash
$ cat entrypoint.sh
#!/bin/sh
M_OPTS="-Duser.timezone=Asia/Shanghai -javaagent:/opt/prom/jmx_javaagent-0.3.1.jar=$(hostname -i):${M_PORT:-"12346"}:/opt/prom/config.yml"
C_OPTS=${C_OPTS}
JAR_BALL=${JAR_BALL}
exec java -jar ${M_OPTS} ${C_OPTS} ${JAR_BALL}
```

docker进程在执行shell脚本的时候会分配一个pid,这个pid=1。  
要保证pid=1的进程在前台一直运行,才能维持docker的生命周期在run状态。  
如果不用exec,docker执行完脚本之后会退出。pid=1的进程就会退出,docker就会退出。  
所以脚本中的exec后面的命令代替了当前的shell脚本进程,变成了pid=1的进程。  
