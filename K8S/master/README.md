#### 在k8s-master-01节点上
```
cd /usr/local/src/
tar xf kubernetes-server-linux-amd64.tar.gz
cp kubernetes/server/bin/kube-apiserver /opt/kubernetes/bin/
cp kubernetes/server/bin/kube-scheduler /opt/kubernetes/bin/
cp kubernetes/server/bin/kube-controller-manager /opt/kubernetes/bin/
cp kubernetes/server/bin/kubectl /opt/kubernetes/bin/
cp /opt/kubernetes/bin/kube* /usr/bin/
cd /opt/kubernetes/bin/
```
