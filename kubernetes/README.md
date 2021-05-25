<table border="0">
    <tr>
        <td><strong></strong>部署前的准备</td>
        <td><a href="01-环境准备.md">环境准备</a></td>
        <td><a href="01-bind9/01-域名解析.md">主机域/业务域</a></td>
    </tr>
    <tr>
        <td><strong></strong>证书签发</td>
        <td><a href="02-证书的签发.md">cfssl</a></td>
    </tr>
    <tr>
        <td><strong></strong>证书签发</td>
        <td><a href="02-ca.md">cfssl</a></td>
    </tr>    
    <tr>
        <td><strong></strong>存储节点</td>
        <td><a href="05-ETCD部署.md">etcd</a></td>
    </tr>
    <tr>
        <td><strong></strong>镜像仓库</td>
        <td><a href="03-镜像仓库.md">harbor</a></td>
        <td><a href="02-nginx/02-harbor-nginx.md">harbor业务域</a></td>
    </tr>
    <tr>
        <td><strong></strong>主控节点</td>
        <td><a href="06-kube-apiserver.md">kube-apiserver</a></td>
        <td><a href="06-kube-scheduler.md">kube-scheduler</a></td>
        <td><a href="06-kube-controller-manager.md">kube-controller-manager</a></td>
        <td><a href="02-nginx/01-availability-nginx.md">高可用</a></td>
    </tr>
    <tr>
        <td><strong></strong>被控节点</td>
        <td><a href="07-kubelet.md">kubelet</a></td>
        <td><a href="07-kube-proxy.md">kube-proxy</a></td>
    </tr>
    <tr>
        <td><strong></strong>网络节点</td>
        <td><a href="08-网络节点.md">flanned</a></td>
        <td><a href="08-网络节点.md">calico</a></td>
        <td><a href="03-iptables/01-iptables.md">iptables优化</a></td>
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
        <td><a href="10-rbac.md">rbac</a></td>
        <td><a href="10-控制面板.md">dashborad</a></td>
    </tr>
    <tr>
        <td><strong></strong>配置中心</td>
        <td><a href="04-配置管理/01-ConfigMap.md">ConfigMap</a></td>       
        <td><a href="04-配置管理/02-secrets.md">secrets</a></td>
        <td><a href="04-配置管理/03-apollo.md">Apollo</a></td>        
    </tr>
    <tr>
        <td><strong></strong>服务交付</td>
        <td><a href="06-K8S && CICD/02-jenkins安装部署.md">Jenkins</a></td>
        <td><a href="10-控制面板.md">spinnaker</a></td>
    </tr>
    <tr>
        <td><strong></strong>集群监控</td>
        <td><a href="01-环境准备.md">Prometheus</a></td>
        <td><a href="10-控制面板.md">grafana</a></td>
    </tr>
    <tr>
        <td><strong></strong>日志收集</td>
        <td><a href="01-环境准备.md">ELK</a></td>
    </tr>
</table>
