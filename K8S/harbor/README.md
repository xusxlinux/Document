```
[root@k8s-master-01 dashboard]# kubectl get nodes 192.168.12.11
NAME            STATUS   ROLES    AGE    VERSION
192.168.12.11   Ready    <none>   182d   v1.12.1
[root@k8s-master-01 dashboard]# kubectl describe nodes 192.168.12.11
Name:               192.168.12.11
Roles:              <none>
Labels:             beta.kubernetes.io/arch=amd64
                    beta.kubernetes.io/os=linux
                    kubernetes.io/hostname=192.168.12.11
Annotations:        node.alpha.kubernetes.io/ttl: 0
                    volumes.kubernetes.io/controller-managed-attach-detach: true
CreationTimestamp:  Sun, 10 Mar 2019 15:41:26 +0800
Taints:             <none>
Unschedulable:      false
Conditions:
  Type             Status  LastHeartbeatTime                 LastTransitionTime                Reason                       Message
  ----             ------  -----------------                 ------------------                ------                       -------
  OutOfDisk        False   Sun, 08 Sep 2019 18:16:20 +0800   Sun, 08 Sep 2019 16:45:21 +0800   KubeletHasSufficientDisk     kubelet has sufficient disk space available
  MemoryPressure   False   Sun, 08 Sep 2019 18:16:20 +0800   Sun, 08 Sep 2019 16:45:21 +0800   KubeletHasSufficientMemory   kubelet has sufficient memory available
  DiskPressure     False   Sun, 08 Sep 2019 18:16:20 +0800   Sun, 08 Sep 2019 16:45:21 +0800   KubeletHasNoDiskPressure     kubelet has no disk pressure
  PIDPressure      False   Sun, 08 Sep 2019 18:16:20 +0800   Sun, 10 Mar 2019 15:41:23 +0800   KubeletHasSufficientPID      kubelet has sufficient PID available
  Ready            True    Sun, 08 Sep 2019 18:16:20 +0800   Sun, 08 Sep 2019 16:54:12 +0800   KubeletReady                 kubelet is posting ready status
Addresses:
  InternalIP:  192.168.12.11
  Hostname:    192.168.12.11
Capacity:
 attachable-volumes-azure-disk:  16
 cpu:                            4
 ephemeral-storage:              18422Mi
 hugepages-1Gi:                  0
 hugepages-2Mi:                  0
 memory:                         2031888Ki
 pods:                           110
Allocatable:
 attachable-volumes-azure-disk:  16
 cpu:                            4
 ephemeral-storage:              17385180337
 hugepages-1Gi:                  0
 hugepages-2Mi:                  0
 memory:                         1929488Ki
 pods:                           110
System Info:
 Machine ID:                 5e53dbe9c48646fdadf706181ae50183
 System UUID:                994F4D56-BF04-998F-3048-CD355B4124B1
 Boot ID:                    81313145-a27a-42a5-bb1e-cff65581eabe
 Kernel Version:             3.10.0-693.el7.x86_64
 OS Image:                   CentOS Linux 7 (Core)
 Operating System:           linux
 Architecture:               amd64
 Container Runtime Version:  docker://18.9.3
 Kubelet Version:            v1.12.1
 Kube-Proxy Version:         v1.12.1
Non-terminated Pods:         (3 in total)
  Namespace                  Name                                     CPU Requests  CPU Limits  Memory Requests  Memory Limits
  ---------                  ----                                     ------------  ----------  ---------------  -------------
  default                    nginx-dbddb74b8-sdgx2                    0 (0%)        0 (0%)      0 (0%)           0 (0%)
  default                    tomcat-5dbbcfbdbc-g9cq4                  500m (12%)    1 (25%)     256Mi (13%)      512Mi (27%)
  kube-system                kubernetes-dashboard-774f47666c-d6hlg    50m (1%)      100m (2%)   100Mi (5%)       300Mi (15%)
Allocated resources:
  (Total limits may be over 100 percent, i.e., overcommitted.)
  Resource                       Requests     Limits
  --------                       --------     ------
  cpu                            550m (13%)   1100m (27%)
  memory                         356Mi (18%)  812Mi (43%)
  attachable-volumes-azure-disk  0            0
Events:                          <none>
```
