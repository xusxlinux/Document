为什么要制作这版镜像呢：  
        因为： linux服务器上的java版本是jdk8，但是按照github官网的要求， 需要java11 才能启动这个进程  
        所以：我们干脆就用这个镜像封装了一版可以使用java11跑manage跑这个程序的容器
    
[官网地址](https://github.com/yahoo/CMAK)

- kafka-manage镜像的打包命令 一

  - vim /data/Dockerfile/kafka-manage/Dockerfile
    ``` Dockerfile
    FROM hseeberger/scala-sbt:11.0.12_1.5.5_2.13.6

    ENV ZK_HOSTS=hdss7-12.host.com:2181,hdss7-21.host.com:2181,hdss7-22.host.com:2181 \
         KM_VERSION=2.0.0.2

    RUN mkdir -p /tmp && \
        cd /tmp && \
        wget https://github.com/yahoo/CMAK/archive/refs/heads/master.zip && \
        unzip  master.zip && \
        cd /tmp/CMAK-master && \
        sbt clean dist && \
        unzip  -d / ./target/universal/cmak-3.0.0.5.zip && \
        rm -fr /tmp/*3.0.0.5*

    WORKDIR /cmak-3.0.0.5/

    EXPOSE 9000
    ENTRYPOINT ["./bin/cmak","-Dconfig.file=conf/application.conf"]
    ```
  - vim /data/Dockerfile/kafka-manage/Dockerfile

    ``` Dockerfile
    FROM hseeberger/scala-sbt:11.0.12_1.5.5_2.13.6

    ENV ZK_HOSTS=hdss7-12.host.com:2181,hdss7-21.host.com:2181,hdss7-22.host.com:2181 \
        KM_VERSION=2.0.0.2

    COPY ./CMAK-3.0.0.2.zip /tmp

    RUN mkdir -p /tmp && \
        cd /tmp && \
        unzip CMAK-3.0.0.2.zip  && \
        cd /tmp/CMAK-3.0.0.2 && \
        sbt clean dist && \
        unzip  -d / ./target/universal/cmak-3.0.0.2.zip && \
        rm -fr /tmp/*3.0.0.2*

    WORKDIR /cmak-3.0.0.2/

    EXPOSE 9000
    ENTRYPOINT ["./bin/cmak","-Dconfig.file=conf/application.conf"]
    ```
  - 打包镜像并且推送

    ``` shell
    docker build . -t xusx/kafka-manage:v1
    docker push xusx/kafka-manage:v1
    ```
    
- kafka-manage连接zookeeper集群的时候会出现如下一个BUG
  - `Yikes! KeeperErrorCode = Unimplemented for /kafka-manager/mutex Try again.`  
  [官网的issue](https://github.com/yahoo/CMAK/issues/731)
  - 解决办法
    ``` shell
    [zk: localhost:2181(CONNECTED) 0] ls /kafka-manager
    [configs, deleteClusters, clusters]
    
    [zk: localhost:2181(CONNECTED) 1] create /kafka-manager/mutex ""
    Created /kafka-manager/mutex
    [zk: localhost:2181(CONNECTED) 2] create /kafka-manager/mutex/locks ""
    Created /kafka-manager/mutex/locks
    [zk: localhost:2181(CONNECTED) 3] create /kafka-manager/mutex/leases ""
    Created /kafka-manager/mutex/leases
    
    [zk: localhost:2181(CONNECTED) 4] ls /kafka-manager
    [configs, mutex, deleteClusters, clusters]
    ```
    
- kafka-manage.yaml的资源配置文件
  - vim kafka-manage.yaml

    ``` yaml
    kind: Deployment
    apiVersion: apps/v1
    metadata:
      name: kafka-manager
      namespace: elk
      labels:
        name: kafka-manager
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: kafka-manager
      strategy:
        type: RollingUpdate
        rollingUpdate:
          maxUnavailable: 1
          maxSurge: 1
      revisionHistoryLimit: 7
      progressDeadlineSeconds: 600
      template:
        metadata:
          labels:
            app: kafka-manager
        spec:
          containers:
          - name: kafka-manager
            image: xusx/kafka-manage:v1
            imagePullPolicy: IfNotPresent
            ports:
            - containerPort: 9000
              protocol: TCP
            env:
            - name: ZK_HOSTS
              value: hdss7-12.host.com:2181,hdss7-21.host.com,hdss7-22.host.com
            - name: APPLICATION_SECRET
              value: letmein
    ---
    kind: Service
    apiVersion: v1
    metadata:
      name: kafka-manager
      namespace: elk
    spec:
      ports:
      - protocol: TCP
        port: 9000
        targetPort: 9000
      selector:
        app: kafka-manager
    ---        
    kind: Ingress
    apiVersion: extensions/v1beta1
    metadata:
      name: kafka-manager
      namespace: elk
    spec:
      rules:
      - host: kafka-manager.chain.com
        http:
          paths:
          - path: /
            backend:
              serviceName: kafka-manager
              servicePort: 9000
    ```
