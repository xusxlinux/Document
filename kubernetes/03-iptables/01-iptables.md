#### 源地址转换
> $ iptables-save | grep -i masquerade  
>-A POSTROUTING -s 172.7.21.0/24 ! -o docker0 -j MASQUERADE  (不是从docker0地址出去的才做nat源地址转换)

> 删除iptable规则,新增下一条规则  
> $ iptables -t nat -D POSTROUTING -s 172.7.21.0/24 ! -o docker0 -j MASQUERADE  

> (在主机10.4.7.21主机上,来源是172.7.21.0/24段docker的IP地址,目标地址不是从172.7.0.0/16,网络发包不是从docker0桥设备出网的,需要做源地址SNAT转换)  
> $ iptables -t nat -I POSTROUTING -s 172.7.21.0/24 ! -d 172.7.0.0/16 ! -o docker0 -j MASQUERADE  

> 其他原因导致无法ping同这个网段,索性就放行了所有  
> $ iptables-save | grep -i reject  
> $ iptables -t filter -D INPUT -j REJECT --reject-with icmp-host-prohibited  
> $ iptables -t filter -D FORWARD -j REJECT --reject-with icmp-host-prohibited


> 保存规则  
> $ iptables-save > /etc/sysconfig/iptables

> 在容器内,容器需要互相看到真实pod的IP(其实就是容器与容器之间的通信)  
> $ kubectl logs -f nginx-ds-hvm6v  
未做SNAT优化  
10.4.7.22 - - [14/Dec/2019:14:05:22 +0000] "GET / HTTP/1.1" 200 612 "-" "curl/7.38.0" "-"  
做完SNAT优化  
172.7.12.2 - - [14/Dec/2019:15:00:48 +0000] "GET / HTTP/1.1" 200 612 "-" "curl/7.38.0" "-"
