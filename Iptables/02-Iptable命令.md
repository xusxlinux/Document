

增加filter表一条禁止ping服务器
iptables -t filter -A INPUT -P icmp -j DROP
iptables -t filter -I INPUT -P icmp -j DROP

Chain INPUT (policy ACCEPT)
target     prot opt source               destination         
ACCEPT     icmp --  anywhere             anywhere


删除filter表上的第二条规则
iptables -t filter -D INPUT 2
Chain INPUT (policy ACCEPT)
target     prot opt source               destination


修改filter表上的第二条规则
iptables -t filter -R INPUT 2 -P icmp -j ACCEPT
Chain INPUT (policy ACCEPT)
target     prot opt source               destination


清除指定链上的所有规则
iptables -t filter -F INPUT
