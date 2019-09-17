## ingress-http

#### 查看ingress的方式  kubectl get ingress
```
kubectl describe ingress http-dockerstart-com
Name:             http-dockerstart-com
Namespace:        default
Address:          
Default backend:  default-http-backend:80 (<none>)
Rules:
  Host                 Path  Backends
  ----                 ----  --------
  www.dockerstart.com  
                       /   tomcat-service-http:80 (10.0.54.2:8080,10.0.7.3:8080,10.0.70.2:8080)
Annotations:
  nginx.ingress.kubernetes.io/rewrite-target:  /
Events:
  Type    Reason  Age   From                      Message
  ----    ------  ----  ----                      -------
  Normal  CREATE  39m   nginx-ingress-controller  Ingress default/http-dockerstart-com
  Normal  CREATE  39m   nginx-ingress-controller  Ingress default/http-dockerstart-com
  Normal  CREATE  39m   nginx-ingress-controller  Ingress default/http-dockerstart-com
```

## ingress-https
#### 使用阿里云购买的证书无法访问的原因是
```
在启动tomcat pod的时候  配置了NotePort  指定了固定的端口
```
#### 使用证书的时候，需要创建secret认证
```
创建：kubectl create secret tls https.dockerstart.com --cert=www.dockerstart.com.pem --key=www.dockerstart.com.key 
删除：kubectl delete secrets https-dockerstart-com
```
```
kubectl describe ingress https-dockerstart-com
Name:             https-dockerstart-com
Namespace:        default
Address:          
Default backend:  default-http-backend:80 (<none>)
TLS:
  https.dockerstart.com terminates www.dockerstart.com
Rules:
  Host                 Path  Backends
  ----                 ----  --------
  www.dockerstart.com  
                       /   tomcat-service-http:80 (10.0.54.2:8080,10.0.7.3:8080,10.0.70.2:8080)
Annotations:
Events:
  Type    Reason  Age   From                      Message
  ----    ------  ----  ----                      -------
  Normal  CREATE  30m   nginx-ingress-controller  Ingress default/https-dockerstart-com
  Normal  CREATE  30m   nginx-ingress-controller  Ingress default/https-dockerstart-com
  Normal  CREATE  30m   nginx-ingress-controller  Ingress default/https-dockerstart-com
```
