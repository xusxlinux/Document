## ingress-http

#### 查看ingress的方式kubectl get ingress
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
