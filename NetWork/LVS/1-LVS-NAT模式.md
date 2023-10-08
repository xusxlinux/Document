## 如何部署LVS负载均衡集群 (NAT模式)
#### 环境准备
- 模拟使用公网IP地址 访问内网的服务器集群

|角色|网络|地址|主机名|网关|
|:-------: |:-------:|:-------:|:-------:|:-------:|
|debian桌面版|Vmnet8 nat模式|CIP: 10.4.7.129|debian.host.com||
|director|Vmnet8 nat模式  Vmnet2 仅主机|VIP: 10.4.7.10  DIP: 192.168.16.20|director.host.com||
|real server 1 |Vmnet2 仅主机|RIP: 192.168.16.21|rs1.host.com|192.168.16.20|
|real server 2 |Vmnet2 仅主机|RIP: 192.168.16.22|rs2.host.com|192.168.16.20|
