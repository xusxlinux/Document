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


```
export BOOTSTRAP_TOKEN=$(head -c 16 /dev/urandom | od -An -t x | tr -d ' ')
cat > token.csv <<EOF
${BOOTSTRAP_TOKEN},kubelet-bootstrap,10001,"system:kubelet-bootstrap"
EOF

mv token.csv /opt/kubernetes/cfg/

# -------------------------------------------------------------------------------

export KUBE_APISERVER="https://192.168.12.14:6443"


kubectl config set-cluster kubernetes \
  --certificate-authority=./ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=bootstrap.kubeconfig


kubectl config set-credentials kubelet-bootstrap \
--token=${BOOTSTRAP_TOKEN} \
--kubeconfig=bootstrap.kubeconfig


kubectl config set-context default \
  --cluster=kubernetes \
  --user=kubelet-bootstrap \
  --kubeconfig=bootstrap.kubeconfig


kubectl config use-context default --kubeconfig=bootstrap.kubeconfig


kubectl config set-cluster kubernetes \
  --certificate-authority=./ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=kube-proxy.kubeconfig
kubectl config set-credentials kube-proxy \
  --client-certificate=./kube-proxy.pem \
  --client-key=./kube-proxy-key.pem \
  --embed-certs=true \
  --kubeconfig=kube-proxy.kubeconfig
kubectl config set-context default \
  --cluster=kubernetes \
  --user=kube-proxy \
  --kubeconfig=kube-proxy.kubeconfig


kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig


kubectl create clusterrolebinding kubelet-bootstrap --clusterrole=system:node-bootstrapper --user=kubelet-bootstrap

kubectl create clusterrolebinding cluster-system-anonymous --clusterrole=cluster-admin --user=system:anonymous
```

```
scp *.kubeconfig k8s-node-01:/opt/kubernetes/ssl/
scp *.kubeconfig k8s-node-02:/opt/kubernetes/ssl/                                                  
scp *.kubeconfig k8s-node-03:/opt/kubernetes/ssl/
```
