#### 需要安装开发工具包
``` shell
yum group install  "base" "Development tools" -y
yum install zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel libffi-devel readline-devel -y
```

``` shell
# sqlite3版本比较低安装一个新的版本
cd /data/software
wget https://www.sqlite.org/2022/sqlite-autoconf-3380100.tar.gz
tar xf sqlite-autoconf-3380100.tar.gz 
cd sqlite-autoconf-3380100/
./configure --prefix=/usr/local/sqlite3
make -j 2
make install

mv /usr/bin/sqlite3{,.bak}
ln -vs /usr/local/sqlite3/bin/sqlite3 /usr/bin/sqlite3
export LD_LIBRARY_PATH=/usr/local/sqlite3/lib
source /etc/profile
sqlite3 -version

# 修改python源码包sqlite3的路径
vim /data/software/Python-3.9.9/setup.py
1452                              '/usr/localsqlite3',
1453                              '/usr/localsqlite3/bin/sqlite3',
1454                              '/usr/localsqlite3/bin/sqlite3',
```

[参考连接 一](https://www.django.cn/forum/forum-21090.html)  
[参考链接 二](https://blog.csdn.net/hhs_1996/article/details/117907381?spm=1001.2101.3001.6650.14&utm_medium=distribute.pc_relevant.none-task-blog-2%7Edefault%7EBlogCommendFromBaidu%7ERate-14.pc_relevant_aa&depth_1-utm_source=distribute.pc_relevant.none-task-blog-2%7Edefault%7EBlogCommendFromBaidu%7ERate-14.pc_relevant_aa)
#### 下载python3.9的源码包
``` shell
pip install pysqlite3
pip install pysqlite3-binary

vim ~/.virtualenvs/python3/lib/python3.9/site-packages/django/db/backends/sqlite3/base.py
#from sqlite3 import dbapi2 as Database  #注释它
from pysqlite3 import dbapi2 as Database #新加这段代码


# 方式二
wget https://www.python.org/ftp/python/3.9.9/Python-3.9.9.tgz
tar xf Python-3.9.9.tgz && cd Python-3.9.9

./configure --prefix=/usr/local/python3

# make install会执行commoninstall、bininstall、maninstall三个过程,make altinstall只执行commoninstall过程。
make && make altinstall
```

#### 创建python36软连接
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
