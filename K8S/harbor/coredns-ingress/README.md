## ingress-http
```
kubectl describe ingress dockerstart.com
Name:             dockerstart.com
Namespace:        default
Address:          
Default backend:  default-http-backend:80 (<none>)
Rules:
  Host                 Path  Backends
  ----                 ----  --------
  www.dockerstart.com  
                       /   tomcat-service:80 (10.0.54.2:8080,10.0.7.3:8080,10.0.70.2:8080)
Annotations:
  nginx.ingress.kubernetes.io/rewrite-target:  /
Events:
  Type    Reason  Age    From                      Message
  ----    ------  ----   ----                      -------
  Normal  CREATE  4m49s  nginx-ingress-controller  Ingress default/dockerstart.com
  Normal  CREATE  4m49s  nginx-ingress-controller  Ingress default/dockerstart.com
  Normal  CREATE  4m49s  nginx-ingress-controller  Ingress default/dockerstart.com
```

## ingress-https
```

```
