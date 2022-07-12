
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
## gitlab-code backup
gitlab_rails['manage_backup_path'] = true
gitlab_rails['backup_path'] = "/data/gitlab-backup"

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

#### gitlab 备份
``` shell
查看软件版本
cat /opt/gitlab/embedded/service/gitlab-rails/VERSION

备份命令
gitlab-rake gitlab:backup:create

定时任务备份
0 0 * * * gitlab-rake gitlab:backup:create
```

#### gitlab 恢复方式
``` shell
输入两次yes
gitlab-rake gitlab:backup:restore
注意: 目录保留一个备份文件就行

恢复完成后, 启动刚刚得两个服务, 或者重启所有服务,在使用浏览器访问, 数据可之前一致
gitlab-ctl start unicorn
gitlab-ctl start sidekiq

或者
gitlab-ctl restart

注意: 通过备份文件恢复gitlab必须保障两台主机gitlab版本一致, 否则会提是版本不匹配
```
