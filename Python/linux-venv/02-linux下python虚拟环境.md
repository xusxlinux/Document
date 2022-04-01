#### 创建用户
``` shell
useradd xusx
echo 'xusx2020_' | passwd --stdin xusx
```

#### 启动用户密码登陆
``` shell
# 腾讯云
sed -i 's#^PasswordAuthentication no#PasswordAuthentication yes#g' /etc/ssh/sshd_config
```

#### 安装软件
``` shell
# 切换到子用户: xusx 进行安装 virtualenv这个命令的位置会变成  /home/xusx/.local/bin/virtualenv


# 安装最基础的包virtualenv 
pip3 install virtualenv

# Linux OS则安装virtualenvwrapper
pip3 install virtualenvwrapper

# Windows OS则安装virtualenvwrapper-win
pip3 install virtualenvwrapper-win
```

#### 设置环境变量
``` shell
vim .bashrc
export VIRTUALENVWRAPPER_PYTHON=`which python3`                       # 指定virtualenvwrapper执行的python版本
export WORKON_HOME=$HOME/.virtualenvs                                 # 指定虚拟环境存放目录，.virtualenvs目录名可自拟
export VIRTUALENVWRAPPER_VIRTUALENV=/home/xusx/.local/bin/virtualenv  # 指定virtualenv的路径
source /home/xusx/.local/bin/virtualenvwrapper.sh                     # virtualenvwrapper.sh所在目录
```
#### 虚拟环境命令使用
``` shell
# 创建软连接
ln -vs /usr/local/python3/bin/virtualenv /usr/bin/virtualenv

# 创建虚拟环境
mkvirtualenv python3
# 可以指定py27或者py36
mkvirtualenv --python=/usr/bin/python3 py3-env

# 列出所有环境
lsvirtualenv

# 切换虚拟环境
workon

# 退出虚拟环境
deactivate

# 删除指定环境
rmvirtualenv

# 进入虚拟环境目录
cdvirtualenv 
```
