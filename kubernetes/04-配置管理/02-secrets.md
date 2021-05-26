## 加密的配置信息  

#### 创建私有仓库密钥  
kubectl create secret docker-registry harbor --docker-server=harbor.od.com --docker-username=admin --docker-password=123456 -n infra  

kubectl create secret docker-registry harbor --docker-server=harbor.od.com --docker-username=admin --docker-password=123456 -n app  

kubectl create secret docker-registry harbor --namespace=kube-system \
    --docker-server=harbor.chain.com --docker-username=admin \
    --docker-password=123456 --docker-email=xusxlinux@163.com
