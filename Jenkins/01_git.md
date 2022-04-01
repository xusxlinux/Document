#### git常用命令 - 初始化
``` md
添加文件:echo "# ccc" >> README.md
初始化仓库: git init
添加文件:git add README.md
提交注释: git commit -m "first commit"
创建主分支: git branch -M main
添加远程仓库: git remote add origin git@github.com:xusxlinux/django.git
推送到远程仓库:git push -u origin main
```

#### git常用命令 - 删除
``` md
删除仓库中文件: 
git rm -rf --cached Python/
git commit -m '删除python'
git push -u origin master
```

#### git常用命令 - 分支
``` md
创建本地分支，然后切换到dev分支:
git checkout -b dev

创建本地分支，然后切换到dev分支, 加上-b参数表示创建并切换，相当于以下两条命令
git branch dev
git checkout dev

查看分支:
git branch

拉取远程分支并创建本地分支:
git branch -r
```

#### git常用命令 - 合并分支
``` md
把dev分支的工作内容合并到master分支上：
git checkout master

merge命令用于合并指定分支到当前分支:
git merge dev


合并完成后，删除dev分支：
git branch -d dev
```
