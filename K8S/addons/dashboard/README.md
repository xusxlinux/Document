```
kubectl create -f dashboard-configmap.yaml
kubectl create -f dashboard-rbac.yaml
kubectl create -f dashboard-secret.yaml
kubectl create -f dashboard-controller.yaml 
kubectl create -f dashboard-service.yaml
kubectl create -f k8s-admin.yaml
```

```
kubectl get pod -n kube-system
kubectl get svc,pod,deploy -n kube-system
kubectl get svc,pod,deploy -n kube-system  -o wide
```

```
kubectl get secret -n kube-system
kubectl describe secret dashboard-admin-token-mhvjx -n kube-system
```
