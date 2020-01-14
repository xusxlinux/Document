水平扩展
kubectl scale --replicas=2 deployment.apps/dubbo-demo-consumer -n app

强制删除
kubectl delete -n app pod/dubbo-demo-service-86977dd88d-gm6s5 --grace-period=0 --force
