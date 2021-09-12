#### tcp服务使用
- vim tcp-config.yaml
``` yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: tcp-services
  namespace: ingress-nginx
data:
  # 指定程序启动的名称空间"default" /  服务的svc名称加上端口
  "30000": default/web-deploy:80
```

---

#### 进入到ingress容器中
[ingress-nginx官网文档的参数配置](https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/configmap/#configmaps)  
- vim nginx-config.yaml
``` yaml
kind: ConfigMap
apiVersion: v1
metadata:
  name: nginx-configuration
  namespace: ingress-nginx
  labels:
    app: ingress-nginx
data:
  proxy-body-size: "64m"
  proxy-read-timeout: "180"
  proxy-send-timeout: "180"
```
再次进入容器中, 发现上述的参数生效
``` shell
# 进入容器
kubectl exec -it -n ingress-nginx nginx-ingress-controller-x7xbf -- /bin/sh

# 查找对应的server是否生效
less nginx.conf
```

---

#### 自定义全局变量
- vim custom-header-global.yaml
``` yaml
# ingres-nginx 容器中 定义全局变量
apiVersion: v1
kind: ConfigMap
data:
  # 在ingress-nginx的空间下使用custom-headers
  proxy-set-headers: "ingress-nginx/custom-headers"
metadata:
  name: nginx-configuration
  namespace: ingress-nginx
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
---
apiVersion: v1
kind: ConfigMap
data:
  X-Different-Name: "true"
  X-Request-Start: t=${msec}
  X-Using-Nginx-Controller: "true"
metadata:
  name: custom-headers
  namespace: ingress-nginx
```

---

#### 定制在某个ingress下server的haed, 提供对外暴漏服务
- vim ingress-custom-header.yaml
``` yaml
# default名称空间下 daem服务暴露 
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/configuration-snippet: |
      more_set_headers "Request-Id: $req_id";
  name: web-deploy
  namespace: default
spec:
  rules:
  - host: web-nginx.chain.com
    http:
      paths:
      - backend:
          serviceName: web-deploy
          servicePort: 80
        path: /

```

---

#### 自定义配置模板
[Custom NGINX template](https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/custom-template/#custom-nginx-template)
``` shell
# 把容器中的nginx.tmpl文件拷贝出来
kubectl cp -n ingress-nginx nginx-ingress-controller-x7xbf:template/nginx.tmpl nginx.tmpl

# 创建一个ConfigMap
kubectl create cm nginx-template --from-file=nginx.tmpl -n ingress-nginx

# 查看创建的文件
kubectl get cm -n ingress-nginx | grep nginx-template
kubectl get cm -n ingress-nginx nginx-template -o yaml

# 配置magic_change.yaml文件, 添加如下ConfigMap的挂载配置
        volumeMounts:
          - mountPath: /etc/nginx/template
            name: nginx-template-volume
            readOnly: true
      volumes:
        - name: nginx-template-volume
          configMap:
            name: nginx-template
            items:
            - key: nginx.tmpl
              path: nginx.tmpl
              
# 重新应用一下修改后的文件使之生效
kubectl apply -f magic_change.yaml 

# 编辑模板文件, 对要改变的参数做调整实现热加载
kubectl edit -n ingress-nginx cm nginx-template 
```
