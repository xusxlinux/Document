源地址转换
> $ iptables-save | grep -i masquerade  
>-A POSTROUTING -s 172.7.21.0/24 ! -o docker0 -j MASQUERADE  (不是从docker0地址出去的才做nat源地址转换)

> 删除iptable规则,新增下一条规则  
> $ iptables -t nat -D POSTROUTING -s 172.7.21.0/24 ! -o docker0 -j MASQUERADE  

> (在主机10.4.7.21主机上,来源是172.7.21.0/24段docker的IP地址,目标地址不是从172.7.0.0/16,网络发包不是从docker0桥设备出网的,需要做源地址SNAT转换)  
> $ iptables -t nat -I POSTROUTING -s 172.7.21.0/24 ! -d 172.7.0.0/16 ! -o docker0 -j MASQUERADE  
