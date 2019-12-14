源地址转换
$ iptables-save | grep -i masquerade
-A POSTROUTING -s 172.7.21.0/24 ! -o docker0 -j MASQUERADE  (不是从docker0地址出去的才做nat源地址转换)

$ iptables -t nat -D POSTROUTING -s 172.7.21.0/24 ! -o docker0 -j MASQUERADE
$ iptables -t nat -I POSTROUTING -s 172.7.21.0/24 ! -d 172.7.0.0/16 ! -o docker0 -j MASQUERADE  (目标地址不是从172.7.0.0/16,也不是从docker0出网的,需要做源地址转换)

