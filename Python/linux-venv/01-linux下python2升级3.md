#### 需要安装开发工具包
``` shell
yum group install  "base" "Development tools" -y
yum install zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel libffi-devel readline-devel -y
```

#### 下载python3.9的源码包
``` shell
wget https://www.python.org/ftp/python/3.9.9/Python-3.9.9.tgz
tar xf Python-3.9.9.tgz && cd Python-3.9.9

./configure --prefix=/usr/local/python3

# make install会执行commoninstall、bininstall、maninstall三个过程,make altinstall只执行commoninstall过程。
make && make altinstall
```

#### 创建python39软连接
``` shell
ln -vs /usr/local/python3/bin/python3 /usr/bin/python3
ln -vs /usr/local/python3/bin/pip3 /usr/bin/pip3

# 升级pip
python3 -m pip3 install --upgrade pip3
```

#### 要使用yum命令需要的是pip2.7版本
``` shell
vim /usr/bin/yum
#!/usr/bin/python2.7
```
