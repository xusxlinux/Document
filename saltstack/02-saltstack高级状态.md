## highstate 高级状态
```
vim top.sls

base:
  '*':
    - nginx
```

## grains 是在 minion 节点上配置
- Grains 存储位置在 Minion端, 是静态数据, 启动时收集, 也可以使用`saltutil.sync_grains`进行刷新.  自身数据可以用来做资产管理  
```
在所有 web 服务器上给minion 添加 nginx 标签
[root@web-01 salt]# cat /etc/salt/grains
roles: nginx

在所有 haproxy 服务器上给minion添加 haproxy 标签
vim /etc/salt/minion

grains:
  roles:
    - haproxy
```
#### 执行
```
salt '*' grains.item roles
salt -G 'roles:nginx' cmd.run 'echo nginx'
salt -G 'roles:haproxy' cmd.run 'echo haproxy'
```
#### 执行高级状态
```
[root@web-01 salt]# cat /srv/salt/top.sls 
base:
  'roles:nginx':
    - match: grain
    - nginx
    
salt -G 'roles:nginx' state.highstate
```

## pillar 是在 master 节点上配置
- Pillar 存储位置在 Master端, 是动态数据, 可以指定给对应的Minion.  使用saltutil.refresh_pillar来刷新, 用于敏感数据  
```
打开 pillar 的配置
sed -i 's/#pillar_opts: False/pillar_opts: True/g' /etc/salt/master

vim /etc/salt/master
pillar_roots:
  base:
    - /srv/pillar
    
mkdir -pv /srv/pillar
```
#### 执行topfile
```
[root@web-01 salt]# cat /srv/pillar/nginx.sls
{% if grains['os'] == 'CentOS' %}
nginx: nginx
{% elif grains['os'] == 'Ubuntu' %}
haproxy: haproxy
{% endif %}

[root@web-01 ~]# cat /srv/pillar/top.sls 
base:
  '*':
    - nginx

测试是否匹配上服务器
[root@web-01 ~]# salt '*' pillar.items


执行命令
[root@web-01 ~]# salt -I 'nginx:nginx' test.ping
web-01.host.com:
    True

[root@web-01 ~]# salt -I 'haproxy:haproxy' test.ping
haproxy-01.host.com:
    True
```
#### 刷新
```
salt '*' saltutil.refresh_pillar
```
