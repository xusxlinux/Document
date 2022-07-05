
[Gitlab下载地址](https://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/yum/el7/)  
[Gitlab官方文档](https://gitlab.cn/install/)  

#### 配置源
``` shell
vim /etc/yum.repos.d/gitlab-ce.repo

yum install openssh-server openssh-clients postfix cronie perl policycoreutils-python
yum install gitlab-ce --nogpgcheck -y 忽略校验
```


#### 编辑配置文件
vim /etc/gitlab/gitlab.rb

``` shell
[root@linux-node-01 ~]# grep -Ev "#|^$" /etc/gitlab/gitlab.rb

## URL on which GitLab will be reachable.
external_url 'http://10.4.7.11'

## GitLab email server setting
gitlab_rails['smtp_enable'] = true
gitlab_rails['smtp_address'] = "smtp.163.com"
gitlab_rails['smtp_port'] = 465
gitlab_rails['smtp_user_name'] = "xusxlinux@163.com"
gitlab_rails['smtp_password'] = "STBIELSUTFMKAEIX"
gitlab_rails['smtp_domain'] = "163.com"
gitlab_rails['smtp_authentication'] = "login"
gitlab_rails['smtp_enable_starttls_auto'] = true
gitlab_rails['smtp_tls'] = true
gitlab_rails['gitlab_email_enabled'] = true
gitlab_rails['gitlab_email_from'] = 'xusxlinux@163.com'
gitlab_rails['gitlab_email_display_name'] = 'Gitlab'
gitlab_rails['gitlab_email_reply_to'] = 'xusxlinux@163.com'
gitlab_rails['gitlab_email_subject_suffix'] = '[gitlab]'

## For setting up different data storing directory
git_data_dirs({
  "default" => {
    "path" => "/data/gitlab-data"
   }
})


## 配置 https 官网不建议
external_url 'https://note.3bgm.com'
nginx['ssl_certificate'] = "/etc/gitlab/ssl/note.3bgm.com.pem"
nginx['ssl_certificate_key'] = "/etc/gitlab/ssl/note.3bgm.com.key"
letsencrypt['enable'] = false
```

#### 测试邮件发送
``` shell
进入控制台
gitlab-rails console

Notify.test_email('xxx@xxx.com', 'Message Subject', 'Message Body').deliver_now
```

#### 修改root密码
``` shell
gitlab-rails console production

user = User.where(id: 1).first
user.password='' #输入新密码
user.password_confirmation='' #确认新密码
user.save! #保存
quit #退出
```

#### gitlab命令
``` shell
语言问题
echo "export LC_ALL=en.US.UTF-8" >> /etc/profile
source /etc/profile

配置生效
gitlab-ctl reconfigure

启动
gitlab-ctl start

停止
gitlab-ctl stop

gitlab彻底停止服务
gitlab-ctl uninstall
gitlab-ctl cleanse
gitlab-ctl remove-accounts

删除文件
cd /
find / -name gitlab | xargs rm -rf
```
