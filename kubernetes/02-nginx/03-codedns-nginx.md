```conf
配置nginx的配置文件,下载coredns使用的
$ cat /etc/nginx/conf.d/k8s-yaml.od.com.conf 
server {
    listen       80;
    server_name  k8s-yaml.od.com;

    location / {
        autoindex on;
        default_type text/plain;
        root /data/k8s-yaml;
    }
}
```

```
配置内网域名解析
$ORIGIN od.com.
$TTL 600        ; 10 minutes
@               IN SOA  dns.od.com. dnsadmin.od.com. (
                                2019111003 ; serial
                                10800      ; refresh (3 hours)
                                900        ; retry (15 minutes)
                                604800     ; expire (1 week)
                                86400      ; minimum (1 day)
                                )
                                NS   dns.od.com.
$TTL 60 ; 1 minute
dns                A    10.4.7.11
harbor             A    10.4.7.200
k8s-yaml           A    10.4.7.200
```


```
~]# kubectl create deployment nginx-dp --image=harbor.od.com/public/nginx:v1.15.3 -n kube-public
~]# kubectl get pods -o wide -n kube-public 
NAME                        READY   STATUS    RESTARTS   AGE     IP           NODE                NOMINATED NODE   READINESS GATES
nginx-dp-686959b78f-hs8zg   1/1     Running   0          3m44s   172.7.11.2   hdss7-11.host.com   <none>           <none>


~]# kubectl expose deployment nginx-dp --port=80 -n kube-public
~]# kubectl get svc -o wide -n kube-public 
NAME       TYPE        CLUSTER-IP        EXTERNAL-IP   PORT(S)   AGE   SELECTOR
nginx-dp   ClusterIP   192.168.225.221   <none>        80/TCP    3s    app=nginx-dp


~]# dig -t A nginx-dp @192.168.0.2 +short

~]# dig -t A nginx-dp.kube-public.svc.cluster.local. @192.168.0.2 +short
192.168.225.221
```



```
查看默认命名空间的容器信息
~]# kubectl get svc,pod,deploy -o wide
NAME                 TYPE        CLUSTER-IP        EXTERNAL-IP   PORT(S)   AGE   SELECTOR
service/kubernetes   ClusterIP   192.168.0.1       <none>        443/TCP   10d   <none>
service/nginx-ds     ClusterIP   192.168.137.202   <none>        80/TCP    17h   app=nginx-ds

NAME                 READY   STATUS    RESTARTS   AGE   IP           NODE                NOMINATED NODE   READINESS GATES
pod/nginx-ds-5fw5l   1/1     Running   0          17h   172.7.12.2   hdss7-12.host.com   <none>           <none>
pod/nginx-ds-8hgck   1/1     Running   0          17h   172.7.21.2   hdss7-21.host.com   <none>           <none>
pod/nginx-ds-hhbpw   1/1     Running   0          17h   172.7.22.2   hdss7-22.host.com   <none>           <none>
pod/nginx-ds-qz2qv   1/1     Running   0          17h   172.7.11.2   hdss7-11.host.com   <none>           <none>


查看kube-public命名空间的容器信息
~]# kubectl get svc,pod,deploy -o wide -n kube-public 
NAME               TYPE        CLUSTER-IP        EXTERNAL-IP   PORT(S)   AGE   SELECTOR
service/nginx-dp   ClusterIP   192.168.223.105   <none>        80/TCP    17h   app=nginx-dp

NAME                            READY   STATUS    RESTARTS   AGE   IP           NODE                NOMINATED NODE   READINESS GATES
pod/nginx-dp-79cf69fc5f-fgrfr   1/1     Running   0          17h   172.7.12.3   hdss7-12.host.com   <none>           <none>

NAME                             READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES                                         SELECTOR
deployment.extensions/nginx-dp   1/1     1            1           17h   my-nginx     harbor.od.com/public/nginx_hith_curl:v1.15.2   app=nginx-dp

可以通过集群的ClusterIP来访问容器
~]# curl -I -m 10 -o /dev/null -s -w %{http_code} 192.168.137.202
200
~]# curl -I -m 10 -o /dev/null -s -w %{http_code} 192.168.223.105
200


进入容器,查看dns的解析情况
~]# kubectl exec -it pod/nginx-ds-5fw5l bash
root@nginx-ds-5fw5l:/# cat /etc/resolv.conf 
nameserver 192.168.0.2
search default.svc.cluster.local svc.cluster.local cluster.local
options ndots:5


使用集群IP,容器IP,短域名 都能访问到
root@nginx-ds-5fw5l:/# curl -I -m 10 -o /dev/null -s -w %{http_code} 192.168.223.105
200
root@nginx-ds-5fw5l:/# curl -I -m 10 -o /dev/null -s -w %{http_code} 172.7.12.3
200
root@nginx-ds-5fw5l:/# curl -I -m 10 -o /dev/null -s -w %{http_code} nginx-dp.kube-public.svc.cluster.local.
200
```

下载官网上coredns容器  
> $ docker pull coredns/coredns:1.6.1  
打上tag  
> $ docker tag c0f6e815079e harbor.od.com/public/coredns:v1.6.1  
上传到自己的镜像仓库  
> $ docker push harbor.od.com/public/coredns:v1.6.1  
配置文件下载地址  
> $ wget https://github.com/kubernetes/kubernetes/blob/master/cluster/addons/dns/coredns/coredns.yaml.base


```rbac.yaml
$ cat /data/k8s-yaml/coredns/rbac.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: coredns
  namespace: kube-system
  labels:
      kubernetes.io/cluster-service: "true"
      addonmanager.kubernetes.io/mode: Reconcile
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
    addonmanager.kubernetes.io/mode: Reconcile
  name: system:coredns
rules:
- apiGroups:
  - ""
  resources:
  - endpoints
  - services
  - pods
  - namespaces
  verbs:
  - list
  - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
    addonmanager.kubernetes.io/mode: EnsureExists
  name: system:coredns
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:coredns
subjects:
- kind: ServiceAccount
  name: coredns
  namespace: kube-system
```

```yaml
$ cat cm.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system
data:
  Corefile: |
    .:53 {
        errors
        log
        health
        ready
        kubernetes cluster.local 192.168.0.0/16
        forward . 10.4.7.11
        cache 30
        loop
        reload
        loadbalance
       }
```

```yaml
$ cat dp.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: coredns
  namespace: kube-system
  labels:
    k8s-app: coredns
    kubernetes.io/name: "CoreDNS"
spec:
  replicas: 1
  selector:
    matchLabels:
      k8s-app: coredns
  template:
    metadata:
      labels:
        k8s-app: coredns
    spec:
      priorityClassName: system-cluster-critical
      serviceAccountName: coredns
      containers:
      - name: coredns
        image: harbor.od.com/public/coredns:v1.6.1
        args:
        - -conf
        - /etc/coredns/Corefile
        volumeMounts:
        - name: config-volume
          mountPath: /etc/coredns
        ports:
        - containerPort: 53
          name: dns
          protocol: UDP
        - containerPort: 53
          name: dns-tcp
          protocol: TCP
        - containerPort: 9153
          name: metrics
          protocol: TCP
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
            scheme: HTTP
          initialDelaySeconds: 60
          timeoutSeconds: 5
          successThreshold: 1
          failureThreshold: 5
      dnsPolicy: Default
      volumes:
        - name: config-volume
          configMap:
            name: coredns
            items:
            - key: Corefile
              path: Corefile
```

```yaml
$ cat svc.yaml
apiVersion: v1
kind: Service
metadata:
  name: coredns
  namespace: kube-system
  labels:
    k8s-app: coredns
    kubernetes.io/cluster-service: "true"
    kubernetes.io/name: "CoreDNS"
spec:
  selector:
    k8s-app: coredns
  clusterIP: 192.168.0.2
  ports:
  - name: dns
    port: 53
    protocol: UDP
  - name: dns-tcp
    port: 53
  - name: metrics
    port: 9153
    protocol: TCP
```
