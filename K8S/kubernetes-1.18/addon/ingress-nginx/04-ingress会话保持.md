
- vim ingress-session.yaml
``` yaml
# web会话保持
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/affinity: cookie
    nginx.ingress.kubernetes.io/session-cookie-hash: sha1
    nginx.ingress.kubernetes.io/session-cookie-name: route
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
  tls:
    - hosts:
      - web-nginx.chain.com
      secretName: web-nginx
```
