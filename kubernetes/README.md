<table border="0">
    <tr>
        <td><strong></strong>部署前的准备</td>
        <td><a href="01-环境准备.md">环境准备</a></td>
        <td><a href="../NetWork/bind9/03-DNS正解域配置文件（单个节点）.md">内网DNS</a></td>
        <td><a href="../Docker/02-容器安装部署.md">安装docker引擎</a></td>
        <td><a href=""></a>Containerd</td>
    </tr>
    <tr>
        <td><strong></strong>证书签发</td>
        <td><a href="02-证书的签发.md">cfssl</a></td>
        <td><a href="02-ca证书.md">harbor-https</a></td>
        <td><a href=""></a></td>
        <td><a href=""></a></td>
    </tr>
    <tr>
        <td><strong></strong>存储节点</td>
        <td><a href="07-etcd集群/01-ETCD部署.md">etcd01</a></td>
        <td><a href="07-etcd集群/02-ETCD部署.md">etcd02</a></td>
        <td><a href="07-etcd集群/03-ETCD部署.md">etcd03</a></td>
        <td><a href="07-etcd集群/04-ETCD证书.md">集群签发证书</a></td>
    </tr>
    <tr>
        <td><strong></strong>镜像仓库</td>
        <td><a href="03-镜像仓库.md">harbor</a></td>
        <td><a href="02-nginx/02-harbor-nginx.md">harbor业务域</a></td>
        <td><a href=""></a></td>
        <td><a href=""></a></td>
    </tr>
    <tr>
        <td><strong></strong>集群方案</td>
        <td><a href="05-keepalived/master01.md">keepalived01</a></td>
        <td><a href="05-keepalived/master02.md">keepalived02</a></td>
        <td><a href="05-keepalived/master03.md">keepalived03</a></td>
        <td><a href=""></a>阿里云SLB方案</td>
    </tr>
    <tr>
        <td><strong></strong>主控节点</td>
        <td><a href="07-master节点/01-kube-apiserver.md">kube-apiserver</a></td>
        <td><a href="07-master节点/03-kube-scheduler.md">kube-scheduler</a></td>
        <td><a href="07-master节点/02-kube-controller-manager.md">controller-manager</a></td>
        <td><a href=""></a></td>
    </tr>
    <tr>
        <td><strong></strong>被控节点</td>
        <td><a href="07-node节点/02-kubelet.md">kubelet</a></td>
        <td><a href="07-node节点/01-kube-proxy.md">kube-proxy</a></td>
        <td><a href=""></a></td>
        <td><a href=""></a></td>
    </tr>
    <tr>
        <td><strong></strong>网络节点</td>
        <td><a href="06-kubeadm/03-k8s之flannel网络.md">flanned</a></td>
        <td><a href="08-网络节点.md">calico</a></td>
        <td><a href=""></a></td>
        <td><a href=""></a></td>
    </tr>
    <tr>
        <td><strong></strong>集群内网络</td>
        <td><a href="03-iptables/01-iptables.md">iptables优化</a></td>
        <td><a href="03-iptables/01-iptables.md">ipvs优化</a></td>
        <td><a href=""></a></td>
        <td><a href=""></a></td>
    </tr>
    <tr>
        <td><strong></strong>服务暴露</td>
        <td><a href="02-nginx/03-coredns-nginx.md">coredns</a></td>
        <td><a href="02-nginx/05-traefik-nginx.md">traefik</a></td>
        <td><a href="09-Ingress.md">ingress</a></td>
        <td><a href="09-Ingress.md">nginx</a></td>
    </tr>
    <tr>
        <td><strong></strong>控制面板</td>
        <td><a href="06-kubeadm/04-基于角色的访问控制(RBAC).mdd">基于角色的访问控制</a></td>
        <td><a href="10-控制面板.md">dashborad</a></td>
        <td><a href=""></a></td>
        <td><a href=""></a></td>
    </tr>
    <tr>
        <td><strong></strong>配置中心</td>
        <td><a href="04-配置管理/01-ConfigMap.md">ConfigMap</a></td>       
        <td><a href="04-配置管理/02-secrets.md">secrets</a></td>
        <td><a href="04-配置管理/03-apollo.md">Apollo</a></td>
        <td><a href=""></a></td>
    </tr>
    <tr>
        <td><strong></strong>服务交付</td>
        <td><a href="06-K8S && CICD/02-jenkins安装部署.md">Jenkins</a></td>
        <td><a href="10-控制面板.md">spinnaker</a></td>
        <td><a href=""></a></td>
        <td><a href=""></a></td>
    </tr>
    <tr>
        <td><strong></strong>集群监控</td>
        <td><a href="01-环境准备.md">Prometheus</a></td>
        <td><a href="10-控制面板.md">grafana</a></td>
        <td><a href=""></a></td>
        <td><a href=""></a></td>
    </tr>
    <tr>
        <td><strong></strong>日志收集</td>
        <td><a href="06-kubeadm/addon/日志收集/01-k8s部署es集群+csi.md">es集群+csi</a></td>
        <td><a href="06-kubeadm/addon/日志收集/01-k8s部署es集群.md">k8s部署es集群.md</a></td>
        <td><a href="06-kubeadm/addon/日志收集/01-服务器部署es集群.md">服务器部署es集群</a></td>
        td><a href=""></a></td>
    </tr>
</table>
