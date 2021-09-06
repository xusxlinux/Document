
``` yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-deploy
spec:
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  selector:
    matchLabels:
      app: web-deploy
  replicas: 2
  template:
    metadata:
      labels:
        app: web-deploy
    spec:
      containers:
      - name: web-deploy
        image: xusx/nginx:1.15.12
        ports:
        - containerPort: 80
        volumeMounts:
          - name: gluster-volume
            mountPath: "/usr/share/nginx/html"
            readOnly: false
      volumes:
      - name: gluster-volume
        persistentVolumeClaim:
          claimName: glusterfs-pvc
```
