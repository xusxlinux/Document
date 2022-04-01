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
dev分支的工作完成，切换回master分支：
git checkout master

merge命令用于合并指定分支(dev)到当前分支:
git merge dev

合并完成后，删除dev分支：
git branch -d dev
```
