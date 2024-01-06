#### 生成证书
``` shell
openssl genrsa -out web-nginx.chain.com.pem
openssl req -new -key web-nginx.chain.com.pem -out web-nginx.chain.com.csr -subj /C=CN/ST=BeiJing/L=BeiJing/O=CHAIN/OU=CX/CN=web-nginx.chain.com/emailAddress=xusxlinux@163.com
openssl ca -in web-nginx.chain.com.csr  -md sha384  -out  web-nginx.chain.com.crt  -days 365 -batch -notext
```
#### 创建一个secret 的 tls
``` shell
kubectl create secret tls web-nginx --key web-nginx.chain.com.pem --cert web-nginx.chain.com.crt -n ingress-nginx
```
#### 查看创建完成的secret
``` shell
kubectl get secrets -n ingress-nginx web-nginx -o yaml
```
#### 查看帮助文档
``` shell
kubectl exec -it -n ingress-nginx nginx-ingress-controller-hfbk8 -- /nginx-ingress-controller --help
kubectl exec -it -n ingress-nginx nginx-ingress-controller-hfbk8 -- /nginx-ingress-controller --help | grep --default-ssl-certificate
```
#### 修改magic_change.yaml配置文件, 添加如下配
``` shell
- --default-ssl-certificate=ingress-nginx/web-nginx
```
#### 应用magic_change.yaml配置文件
``` shell
kubectl apply -f magic_change.yaml
```
#### 创建一个https的secret对外暴露服务
[ingress-tls](https://v1-18.docs.kubernetes.io/zh/docs/concepts/services-networking/ingress/#tls)  
- vim ingress-https.yaml
``` yaml
# default名称空间下 daem服务暴露 
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  # 添加局部变量
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
  # 创建https的服务
  tls:
    - hosts:
      - web-nginx.chain.com
      secretName: web-nginx
```
