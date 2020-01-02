[jenkins官网](https://jenkins.io/zh/download/)  
[jenkins镜像](https://hub.docker.com/r/jenkins/jenkins)  

下载最新镜像
> $docker pull jenkins/jenkins:2.210  
> $docker tag 5810ec636c04 harbor.od.com/public/jenkins:v2.210  
> $docker push harbor.od.com/public/jenkins:v2.210  

```
创建dokcerfile
$ mkdir -pv /data/dockerfile/jenkins

$ cat /data/dockerfile/jenkins/Dockerfile
FROM harbor.od.com/public/jenkins:v2.210
USER root
RUN /bin/cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime &&\
    echo 'Asia/Shanghai' >/etc/timezone
ADD id_rsa /root/.ssh/id_rsa
ADD config.json /root/.docker/config.json
ADD get-docker.sh /get-docker.sh
RUN echo "    StrictHostKeyChecking no" >> /etc/ssh/ssh_config &&\
    /get-docker.sh

拷贝私钥
$ cp /root/.ssh/id_rsa .
拷贝docker仓库的认证文件
$ cp /root/.docker/config.json .
下载docker安装脚本
$ curl -fsSL get.docker.com -o get-docker.sh
$ chmod +x get-docker.sh

提交到私钥仓库
$ docker build . -t harbor.od.com/infra/jenkins:v2.210
验证镜像是否正确
$ docker run --rm harbor.od.com/infra/jenkins:v2.210 ssh -i id_rsa -T gitee@gitee.com
```

```
创建名称空间
$ kubectl create ns infra
创建私有仓库密钥认证
$ kubectl create secret docker-registry harbor --docker-server=harbor.od.com --docker-username=admin --docker-password=123456 -n infra
```

```yaml
$ cat dp.yaml
kind: Deployment
apiVersion: extensions/v1beta1
metadata:
  name: jenkins
  namespace: infra
  labels: 
    name: jenkins
spec:
  replicas: 1
  selector:
    matchLabels: 
      name: jenkins
  template:
    metadata:
      labels: 
        app: jenkins 
        name: jenkins
    spec:
      volumes:
      - name: data
        nfs: 
          server: hdss7-200
          path: /data/nfs-volume/jenkins_home
      - name: docker
        hostPath: 
          path: /run/docker.sock
          type: ''
      containers:
      - name: jenkins
        image: harbor.od.com/infra/jenkins:v2.190.3
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 8080
          protocol: TCP
        env:
        - name: JAVA_OPTS
          value: -Xmx512m -Xms512m
        volumeMounts:
        - name: data
          mountPath: /var/jenkins_home
        - name: docker
          mountPath: /run/docker.sock
      imagePullSecrets:
      - name: harbor
      securityContext: 
        runAsUser: 0
  strategy:
    type: RollingUpdate
    rollingUpdate: 
      maxUnavailable: 1
      maxSurge: 1
  revisionHistoryLimit: 7
  progressDeadlineSeconds: 600
```

```yaml
$ cat svc.yaml
kind: Service
apiVersion: v1
metadata: 
  name: jenkins
  namespace: infra
spec:
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
  selector:
    app: jenkins
```

```yaml
$ cat ingress.yaml
kind: Ingress
apiVersion: extensions/v1beta1
metadata: 
  name: jenkins
  namespace: infra
spec:
  rules:
  - host: jenkins.od.com
    http:
      paths:
      - path: /
        backend: 
          serviceName: jenkins
          servicePort: 80
```

```
挂载资源
$ cat /etc/exports
/data/nfs-volume 10.4.7.0/24(rw,no_root_squash)

$ mkdir -pv /data/nfs-volume

$ systemctl start nfs
$ systenctl enable nfs
```

```
$ cat /var/named/od.com.zone 
$ORIGIN od.com.
$TTL 600	; 10 minutes
@   		IN SOA	dns.od.com. dnsadmin.od.com. (
				2019111006 ; serial
				10800      ; refresh (3 hours)
				900        ; retry (15 minutes)
				604800     ; expire (1 week)
				86400      ; minimum (1 day)
				)
				NS   dns.od.com.
$TTL 60	; 1 minute
dns                A    10.4.7.11
harbor             A    10.4.7.200
traefik            A    10.4.7.10
k8s-yaml           A    10.4.7.200
dashboard          A    10.4.7.10
zk1                A    10.4.7.11
zk2                A    10.4.7.12
zk3                A    10.4.7.21
jenkins            A    10.4.7.10
```

```
查看jenkins的admin认证密码
$ cat /data/nfs-volume/jenkins_home/secrets/initialAdminPassword
```
