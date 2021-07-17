#### 基于角色的访问控制（RBAC）
1、ServiceAccount：用于调用kubernetes API Server的实体（）  
2、Role/ClusterRole： 用于定义访问资源对象的权限`（Role只能定义namespace级别的权限，ClusterRole是定义集群级别的权限）`  
3、RoleBinding/ClusterRoleBinding：将ServiceAccount和Role绑定在一起`（RoleBinding是namespace级别的绑定，ClusterRoleBinding是集群级别的绑定）`

``` shell
# 查看该名称空间下的 serviceaccounts
kubectl get serviceaccounts -n kube-system

# 查看集群中内置的clusterrole
kubectl get clusterrole

# 集群管理员权限,集群拥有的最高权限的role
kubectl get clusterrole cluster-admin -o yaml
```

``` yaml
[root@hdss7-11 k8s]# cat admin-role.yaml

kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: admin
  annotations:
      rbac.authorization.kubernetes.io/autoupdate: "true"
roleRef:
  # 使用的是集群内置的ClusterRole 所以我们自己不用去定义了，直接使用cluster-admin
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
subjects:
  # ServiceAccount会和集群权限的role（cluster-admin）进行绑定，admin的ServiceAcount就拥有了集群的访问控制权限，而且是集群的管理员权限，最高权限
- kind: ServiceAccount
  name: admin
  namespace: kube-system
---
apiVersion: v1
kind: ServiceAccount
metadata:
  # 定义了一个ServiceAccount 叫做admin，把这个ServiceAccount定义在kube-system的名称空间下
  name: admin
  namespace: kube-system
  labels:
    kubernetes.io/cluster-service: "true"
    addonmanager.kubernetes.io/mode: Reconcile
```

``` shell
# 应用如上的资源配置清单
[root@hdss7-11 k8s]# kubectl apply -f admin-role.yaml

# 查看我们创建的ServerAccount和ClusterRoleBinding
[root@hdss7-11 k8s]# kubectl describe -n kube-system serviceaccounts admin

# 要连接集群就要获取ServerAcount的token内容,我们通过token就拥有了连接集群的权限
[root@hdss7-11 k8s]# kubectl describe -n kube-system secrets admin-token-dtm4v

# 因为开发不能拥有cluster-admin集群管理员的权限,要给开发单独创建一个view的权限view也是集群内置的
[root@hdss7-11 k8s]# kubectl get clusterrole | grep
[root@hdss7-11 k8s]# kubectl get clusterrole view -o yaml
```

``` yaml
[root@hdss7-11 k8s]# cat dev-role.yaml

kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: dev
  annotations:
      rbac.authorization.kubernetes.io/autoupdate: "true"
roleRef:
  # 使用的是集群内置的ClusterRole 所以我们自己不用去定义了，直接使用cluster-admin
  kind: ClusterRole
  # 将ServiceAccount和clusterrole的view进行连接绑定,这样dev就拥有了view的只读权限
  name: view
  apiGroup: rbac.authorization.k8s.io
subjects:
- kind: ServiceAccount
  name: dev
  namespace: kube-system
---
apiVersion: v1
kind: ServiceAccount
metadata:
  # 定义了一个ServiceAccount 叫做dev，把这个ServiceAccount定义在kube-system的名称空间下
  name: dev
  namespace: kube-system
  labels:
    kubernetes.io/cluster-service: "true"
    addonmanager.kubernetes.io/mode: Reconcile
```

## 如下在jumpserver上操作
``` shell
yum install kubectl-1.18.18-0.x86_64 -y
mkdir -pv /root/.kube/
```

``` yaml
cat /root/.kube/config

apiVersion: v1
kind: Config
preferences: {}
clusters:
- cluster:
    # 
    insecure-skip-tls-verify: true
    # 创建一个apiserver的负载均衡，给负载均衡解析域名
    server: https://apiserver.dockerstart.com:6443
  name: k8s
# context是把集群和账号进行绑定
contexts:
- context:
    cluster: k8s
    user: admin
  name: k8s-admin
- context:
    cluster: k8s
    user: dev
  name: k8s-dev
# 让当前的context连接到dev上
current-context: k8s-dev
users:
- name: admin
  user:
    token: xxxxxxxxxxxxxxxx
- name: dev
  user:
    token: xxxxxxxxxxxxxxxx
```

``` shell
# 切换admin的用户
kubectl config use-context k8s-admin

# 切换dev的用户
kubectl config use-context k8s-dev

# 权限无法查看node
kubectl get nodes
Error from server (Forbidden): nodes is forbidden: User "system:serviceaccount:kube-system:dev" cannot list resource "nodes" in API group "" at the cluster scope
```
