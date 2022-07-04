
[gitlab下载地址](https://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/yum/el7/)

yum install openssh-server openssh-clients postfix cronie policycoreutils-python


vim /etc/yum.repos.d/gitlab-ce.repo
yum install gitlab-ce --nogpgcheck -y


编辑配置文件
vim /etc/gitlab/gitlab.rb


语言换接问题
echo "export LC_ALL=en.US.UTF-8" >> /etc/profile

配置剩下
gitlab-ctl reconfigure

启动
gitlab-ctl start

gitlab彻底停止服务
gitlab-ctl uninstall

gitlab-ctl cleanse

gitlab-ctl remove-accounts

find / -name gitlab | xargs rm -rf
