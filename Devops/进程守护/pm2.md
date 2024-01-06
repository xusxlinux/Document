#### 因为npm的进程版本太老了,与nodejs的版本不符合
- 安装pm2进程
``` shell
# 创建目录
mkdir -pv /data/.pm2
ln -vs /data/.pm2 /root/

# 下载安装
cd /data/
wget https://npm.taobao.org/mirrors/node/v10.14.1/node-v10.14.1-linux-x64.tar.gz
wget https://npm.taobao.org/mirrors/node/v12.12.0/node-v12.12.0-linux-x64.tar.gz
tar xf node-v10.14.1-linux-x64.tar.gz
mv node-v10.14.1-linux-x64 node
echo "export PATH="$PATH:/data/node/bin"" >> /etc/profile
source /etc/profile


# 确认好node高版本,使用npm安装
[root@node ~]# node -v
v10.14.1
[root@node ~]# npm install -g pm2


# 设置为淘宝 npm 源 
npm config set registry https://registry.npm.taobao.org 
# 查看 npm 源 
npm config get registry
```
- cat app.json 
``` json
{
    "apps": [{
        "name": "${java_module_name}",
        "cwd": ".",
        "script": "java",
        "args": [
            "-Dfile.encoding=utf-8",
            "-jar",
	    "-XX:+PrintGCDetails",
            "-XX:+PrintGCDateStamps",
            "-XX:+PrintGCCause",
            "-Xloggc:/date/logs/${java_module_name}_gc.log",
            "${java_module_name}.jar",
            "-Djava.security.egd=file:/dev/./urandom"
        ],
        "env": {
            "spring.cloud.config.label":"release",
            "server.port":"${port}"
        },
        "log_date_format": "YYYY-MM-DD HH:mm Z",
        "exec_interpreter": "",
        "exec_mode": "fork_mode"
    }]
}
```
