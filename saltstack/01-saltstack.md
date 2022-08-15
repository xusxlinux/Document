#### 安装repo证书 下载repo源
```
rpm --import https://repo.saltproject.io/py3/redhat/7/x86_64/latest/SALTSTACK-GPG-KEY.pub
curl -fsSL https://repo.saltproject.io/py3/redhat/7/x86_64/latest.repo | sudo tee /etc/yum.repos.d/salt.repo
```
#### 安装salt组件
```
yum install salt-master salt-minion salt-syndic salt-ssh -y
```
#### 配置 minion 并启动
```
vim /etc/salt/minion
16 master: 10.4.7.51
112 id: fqdn

systemctl start salt-minion.service
systemctl enable salt-minion.service
```
#### 配置 master 并启动
```
[root@web-01 ~]# vim /etc/salt/master

file_roots:
  base:
    - /srv/salt

创建目录
[root@web-01 ~]# mkdir -pv /srv/salt

systemctl start salt-master.service
systemctl enable salt-master.service
```
#### 启动master后可以查看minion的认证信息
```
#### 未认证前 在master节点上查看
[root@web-01 ~]# tree /etc/salt/
```
#### 加入 minion 节点
``` 
[root@web-01 ~]# salt-key -A
```
#### 认证后 在master节点上查看
```
[root@web-01 ~]# tree /etc/salt/
```
#### 删除 与 重新加入
```
删除单个 minion
[root@web-01 ~]# salt-key -d web-01.host.com
删除所有 minion
[root@web-01 ~]# salt-key -D
重新加入
systemctl restart salt-minion
[root@web-01 ~]# salt-key -a web-01.host.com
```
#### 测试是否成功
```
[root@web-01 ~]# salt '*' cmd.run ls
[root@web-01 ~]# salt '*' test.ping
```
