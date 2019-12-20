```
修改转发的模式
~]# cat /opt/kubernetes/server/bin/kube-proxy.sh
--proxy-mode=iptables \
--ipvs-scheduler=rr \
```

```
删除ipvsadm规则,当kube-proxy还原为ipvs的时候,该规则自动还原
ipvsadm -D -t 192.168.0.1:443
ipvsadm -D -t 192.168.0.2:53
ipvsadm -D -t 192.168.0.2:9153
ipvsadm -D -t 192.168.49.64:80
ipvsadm -D -t 192.168.111.12:80
ipvsadm -D -t 192.168.189.40:80
ipvsadm -D -t 192.168.223.11:80
ipvsadm -D -u 192.168.0.2:53
```

```
日志中kube-proxy的运行模式更改为iptables
~]# tail -f /data/logs/kubernetes/kube-proxy/proxy.stdout.log
I1220 22:06:04.890923   74254 server_others.go:143] Using iptables Proxier.
```

```yaml
NodePort型Service的声明方式
cat nginx-ds-NodePort.yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    app: nginx-ds
  name: nginx-ds
  namespace: default
spec:
  ports:
  - port: 80
    protocol: TCP
    nodePort: 8000
  selector:
    app: nginx-ds
  sessionAffinity: None
  type: NodePort
```

```
可以在宿主机上看到8000端口
~]# netstat -lntup | grep 8000
tcp6       0      0 :::8000                 :::*                    LISTEN      72824/./kube-proxy


iptables转发的规则。
  让你去访问ClusterIP的时候,如何把流量从宿主机上调度过来？
  宿主机上也要监听8000端口,帮你把流量从宿主机上引导容器内
~]# iptables-save | grep 8000
-A KUBE-MARK-DROP -j MARK --set-xmark 0x8000/0x8000
-A KUBE-NODEPORTS -p tcp -m comment --comment "default/nginx-ds:" -m tcp --dport 8000 -j KUBE-MARK-MASQ
-A KUBE-NODEPORTS -p tcp -m comment --comment "default/nginx-ds:" -m tcp --dport 8000 -j KUBE-SVC-T4RQBNWQFKKBCRET
```

