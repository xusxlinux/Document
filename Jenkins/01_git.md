#### git常用命令 - 初始化
``` md
初始化:
echo "# ccc" >> README.md
git init
git add README.md
git commit -m "first commit"
git branch -M main
git remote add origin git@github.com:xusxlinux/django.git
git push -u origin main
```

#### git常用命令 - 删除
``` md
删除仓库中文件: 
git rm -rf --cached Python/
git commit -m '删除python'
git push -u origin master

删除本地分支:
git checkout dev
git branch -d dev

删除远程分支:
git push origin --delete dev
```

#### git常用命令 - 创建
``` md
创建本地分支, 然后切换到dev分支, 加上-b参数表示创建并切换:
git checkout -b dev

创建本地分支
git branch dev
然后切换到dev分支
git checkout dev

拉取远程分支到本地:
git fetch origin dev

拉取远程分支并创建本地分支:
git fetch origin dev:dev2

查看本地分支:
git branch

查看远程分支:
git branch -r

查看所有分支:
git branch -a
```

#### git常用命令 - 合并分支(merge)
``` md
# 两种方式:
第一种: 拉取到本地合并(避免冲突)
  git fetch origin master:merge_master
  git status
  git stash
  
  git fetch origin dev
  git status
  git stash
  
  git checkout master
  git merge dev
  git push origin dev
  

第二种: 在远程合并分支
```
