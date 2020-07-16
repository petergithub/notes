# Git Notes

[TOC]
`git push https://github.com/petergithub/eclipsePluginOpen.git master`

## 规范

1. 特定业务开发需要单独拉分支的，一般不要做merge master操作；需要同步master代码的时候，从master新拉分支，再从新分支merge之前的开发分支。
2. 本地commit之后在push 之前，必须执行pull --rebase，尽量确保提交commit树简单清晰，不要把冲突留到merge时大量爆发，在本地rebase时处理掉自己的代码冲突。

## Commands

### Most recent

`git checkout -b hotfix upstream/master` create a new branch from upstream
`git log -m --name-only` List all modified files in git merge commit
`git log -S<string> -- *.php` show a list of commits where the relevant_string was either added or removed in any PHP file in the project.
`git rev-list --all | xargs git grep <string>`
`ssh -v git@gitlab.com` get `Welcome to GitLab, Anonymous!`
`ssh -v shangpu@git.picooc.com` get `Welcome to GitLab, Anonymous!`

`HEAD^` 上一个版本
`HEAD^^` `HEAD~2` 倒数第2个版本
`HEAD~3` 倒数第3个版本

Final release version  
`git merge --no-ff <branchName>`    使得合并操作总是产生一次新的提交  
`git merge --squash <branchName>`    把branchName上所有提交合并为一次提交到当前分支上再commit  
`git tag <tagName> -m "comment"`  
`git push origin --tags`    一次性推送很多标签  
`git tag -n9` list all the tags along with annotations & 9 lines of message for every tag  

`git log -g branchName` show Git branch created time just for local fetch/create time  
`git log --name-only` show changed file name only  
`git show <commit-id>` show difference for a commit
`git show --pretty="format:" --name-only efbf363` List all the files for a commit in Git  
`git log --follow [file]`    显示某个文件的版本历史，包括文件改名  
`git whatchanged [file]`    显示某个文件的版本历史，包括文件改名  
`git log -p [file]`    显示指定文件相关的每一次diff  
`git blame [file]`    显示指定文件是什么人在什么时间修改过  
`git commit -v`  

`git ls-files` List all tracked files  
`git checkout anotherBranch -- path/to/file` Copy file from another branch  

```bash
# Replace master branch entirely from another latestBranch:

git checkout latestBranch  
git merge -s ours master --allow-unrelated-histories
git checkout master  
git merge latestBranch  
```

git pull all the projects in the folder  

```bash

for project in $(ls -1 .)
do
    cd $project
    pwd
    git pull
    cd -
done
```

#### tag

`git tag -m "comment" <tagName>`  
`git tag -a <tagName> <commit-id>`  
`git show <tagName>`    查看相应标签的版本信息，并连同显示打标签时的提交对象  
`git push origin --tags`    一次性推送很多标签  
`git checkout -b <branchName> <tagName>`  
`git tag -d <tagname>`    刪除Tag  
`git push origin :refs/tags/<tagName>`    刪除Tag from remote Git repositories  

### Basic commands

HEAD指向最后一次commit的信息  
`git cat-file -p [SHA-1]` 输出数据内容  
`git cat-file -t [SHA-1]` 输出数据对象的类型  

`git log --stat -2` 查看详细提交影响的文件 -p //输出非常详细的日志内容，包括了每次都做了哪些源码的修改  
`git log --oneline`  

`git commit --amend -m "Comment"`
`git pull --rebase origin master`合并上游的修改到自己的仓库中,并把自己的提交移到同步了中央仓库修改后的master分支的顶部
`git rebase -i HEAD~3` 重写历史
`git rebase --onto master commitId` 在非master分支上执行,在master上重复commitId之后的提交,开区间
`git rebase A B` 会把在 A 分支里提交的改变移到 B 分支里重放一遍。
`git cherry-pick` 使用cherry pick在各个分支间同步代码
`git clean` clean untracked files
`git branch -m <oldname> <newname>`
`git branch -a`: show all branch (remote and local)
`git checkout -b feature/portal3.0 origin/feature/portal3.0`: Branch feature/portal3.0 set up to track remote branch feature/portal3.0 from origin.

`git stash`
Do the merge, and then pull the stash:
`git stash pop`

通过 `git remote set-url` 变更远程仓库地址 `git remote set-url origin ssh://git@host:port/os/developer-platform.git`

批量修改为ssh协议 `find . -name config | grep .git | xargs sed -i 's#http://username@host:7990/scm#ssh://git@host:port#g'`

`git remote add origin <server>` 将仓库连接到某个远程服务器  

添加另一个仓库存储分支

1. `git remote add anotherRepository URL`
2. `git push anotherRepository remoteRepository`

删除远程仓库 `git remote rm remoteRepository`  
查看远程仓库信息 `git remote show origin`  

`git push remoteMachine localBranch:remoteBranch`
`git push origin global:global`
`git push --set-upstream origin develop1.0`

`git push origin tagName`
`git push origin --tags`: 推送refs/tags/*
`git push -u origin master` 将本地的master分支推送到origin主机，同时指定origin为默认主机,如果当前分支与多个主机存在追踪关系，则可以使用-u选项指定一个默认主机，这样后面就可以不加任何参数使用git push

`git pull <远程主机名> <远程分支名>:<本地分支名>`  
`git push <远程主机名> <本地分支名>:<远程分支名>`  
`git branch --set-upstream master origin/next` 指定master分支追踪origin/next分支  

(1) current status
(2) After modified local files
(3) After git add
`git diff`得到的是从(2)到(1)的变化   
`git diff --cached`得到的是从(3)到(2)的变化  
`git diff HEAD`得到的是从(3)到(1)的变化  
`git diff global origin/global`: fetch后对比文件  
`gitk`: view commite graph  

### Advanced Command

`git pull --rebase origin master`合并上游的修改到自己的仓库中,并把自己的提交移到同步了中央仓库修改后的master分支的顶部
`git rebase --onto master <commitId>` 在非master分支上执行,在master上重复commitId之后的提交,开区间
`git rebase A B` 会把在 A 分支里提交的改变移到 B 分支里重放一遍。

## Skills

### restore flies

撤销工作区操作 `git checkout <file_name>`
这个命令有2种情况需要考虑

1. file_name自修改后还没有被放到暂存区，现在，撤销修改就回到和版本库一模一样的状态；
2. file_name已经添加到暂存区后，又作了修改，现在，撤销修改就回到添加到暂存区后的状态  。
    总之，就是让这个文件回到最近一次git commit或git add时的状态。

回退总结
    场景1：当你改乱了工作区某个文件的内容，想直接丢弃工作区的修改时，用命令`git checkout <file_name>`  
    场景2：当你不但改乱了工作区某个文件的内容，还添加到了暂存区时，想丢弃修改，分两步，第一步用命令`git reset HEAD <file_name>`，就回到了场景1，第二步按场景1操作。  
    场景3：已经提交了不合适的修改到版本库时，想要撤销本次提交，参考版本回退(`git reset --hard HEAD^`)，不过前提是没有推送到远程库。  
恢复 `git reset --hard` 删除的文件 通过`git reflog`找到commitID,然后`git reset --hard commitID`  

### stage part of a new file, but not the whole file

> [Flight rules for Git](https://github.com/k88hudson/git-flight-rules/#i-want-to-stage-part-of-a-new-file-but-not-the-whole-file)
`git add --patch filename` This will open interactive mode. You would be able to use the s option to split the commit - however, if the file is new, you will not have this option. To add a new file, do this:
`git add -N filename`
Then, you will need to use the e option to manually choose which lines to add. Running git diff --cached or git diff --staged will show you which lines you have staged compared to which are still saved locally

### Untrack files

删掉已经track的文件  This will tell git you want to start ignoring the changes to the file
`git update-index --assume-unchanged path/to/file`  
When you want to start keeping track again  
`git update-index --no-assume-unchanged path/to/file`  
停止追踪一个文件 `git rm --cached path/to/file`

### [Get rid of large files](https://help.github.com/articles/remove-sensitive-data)

`git filter-branch --index-filter 'git rm -r --cached --ignore-unmatch FILE_NAME' --prune-empty`  
`git gc --aggressive --prune`  
`git push origin --force --all`  

### .gitignore文件的例子 [git ignore](https://www.gitignore.io/api/intellij,linux,windows,eclipse,java,scala,osx,maven,gradle,sbt,svn)

``` bash
#此为注释 – 将被 Git 忽略
*.a                          #忽略所有 .a 结尾的文件
!lib.a                       #但 lib.a 除外
/TODO                   #仅仅忽略项目根目录下的 TODO 文件,不包括 subdir/TODO
build/                      #忽略 build/ 目录下的所有文件
doc/*.txt                  #会忽略 doc/notes.txt 但不包括 doc/server/arch.txt
```

### git hooks

Add hooks for `git merge` and `git checkout`

1. create `.git/hooks/post-checkout` and `.git/hooks/post-merge` (for `git pull` also)
2. `chmod ug+x .git/hooks/post-checkout .git/hooks/post-merge`

## Git configuration

### git auto complete　自动补全

download git-completion.bash from source code and load it from .bashrc
`wget --no-check-certificate -O ~/.git-completion.bash https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash && echo >> ~/.bashrc && echo "if [ -f ~/.git-completion.bash ]; then . ~/.git-completion.bash; fi" >> ~/.bashrc && source ~/.bashrc`

### git status 中文

默认中文文件名是 `\xxx\xxx` 等八进制形式 , 是因为 对`0x80`以上的字符进行quote, 只需要 `git config --global core.quotepath false`  

### git中文乱码解决(git bash中的中文乱码问题)

ls命令查看当前文件夹下文件时，中文文件、文件名乱码：
    编辑git安装目录下 git/etc/git-completion.bash ，新增一行 alias ls='ls --show-control-chars --color=auto'
不能递交中文commit log：

1. 像我一样把msysgit自带的vi改成gvim
2. 修改git/etc/inputrc set output-meta on 及 set convert-meta off

#### git log无法显示中文注释

在git/etc/profile中增加一行：export LESSCHARSET=iso8859
另外还有个问题，git bash中的文件对比显示出来代码中的中文也是乱码，这部分还没找到解决方法。或者干脆使用git gui，全局选项里设定字符编码UTF-8，上面问题全部搞定，只是msysgit的界面做的实在不够人性化
add in gitconfig
[gui] encoding = utf-8
说明：我们的代码库是统一用的 utf-8，这样设置可以在 git gui 中正常显示代码中的中文。
[i18n]commitencoding = utf-8
说明：如果没有这一条，虽然我们在本地用 $ git log 看自己的中文修订没问题，但，一、我们的 log 推到服务器后会变成乱码；二、别人在 Linux 下推的中文 log 我们 pull 过来之后看起来也是乱码。这是因为，我们的 commit log 会被先存放在项目的 .git/COMMIT_EDITMSG 文件中；在中文 Windows 里，新建文件用的是 GB2312 的编码；但是 Git 不知道，当成默认的 utf-8 的送出去了，所以就乱码了。有了这条之后，Git 会先将其转换成 utf-8，再发出去，于是就没问题了。

## Examples

### create repository

Create A Repo

First: Create A Repo
    Click New Repository. `https://github.com/repositories/new`

Next: Create a README for your repo.

1. Create the README file
    In the prompt, type the following code:

        $ mkdir ~/Hello-World    //Creates a directory for your project called "Hello-World" in your user directory
        $ cd ~/Hello-World    //Changes the current working directory to your newly created directory
        $ git init    //Sets up the necessary Git files
        Initialized empty Git repository in /Users/your_user_directory/Hello-World/.git/
        $ touch README

Open the new README file found in your Hello-World directory in a text editor and add the text "Hello World!" When you are finished, save and close the file.
2. Commit your README
    Now that you have your README set up, it's time to commit it. A commit is essentially a snapshot of all the files in your project at a particular point in time. In the prompt, type the following code:
        More about commits
        Think of a commit as a snapshot of your project — code, files, everything — at a particular point in time. More accurately, after your first commit, each subsequent commit is only a snapshot of your changes. For code files, this means it only takes a snapshot of the lines of code that have changed. For everything else like music or image files, it saves a new copy of the file.

        `$ git add README    //Stages your README file, adding it to the list of files to be committed`
        `$ git commit -m 'first commit'    //Commits your files, adding the message "first commit"`

THE CODE ABOVE EXECUTES ACTIONS LOCALLY, meaning you still haven't done anything on GitHub yet. To connect your local repository to your GitHub account, you will need to set a remote for your repo and push your commits to it:
        More about remotes
        A remote is a repo stored on another computer, in this case on GitHub's server. It is standard practice (and also the default in some cases) to give the name origin to the remote that points to your main offsite repo (for example, your GitHub repo).
    Git supports multiple remotes. This is commonly used when forking a repo.

        `$ git remote add origin git@github.com:petergithub/Hello-World.git    //Sets the origin for the Hello-World repo`
        `$ git push -u origin master    //Sends your commit to GitHub`

Now if you look at your repository on GitHub, you will see your README has been added to it.
Your README has been created

### You have an empty repository To get started

You have an empty repository To get started you will need to run these commands in your terminal.

#### Configure Git for the first time

git config --global user.name peter
git config --global user.email "email@gmail.com"

#### Working with your repository

I just want to clone this repository
If you want to simply clone this empty repository then run this command in your terminal.
it clone `http://username@host/project.git`

#### My code is ready to be pushed

If you already have code ready to be pushed to this repository then run this in your terminal.

```bash
cd existing-project
git init
git add --all
git commit -m "Initial Commit"
git remote add origin http://username@host/project.git
git push origin master
```

#### My code is already tracked by Git

If your code is already tracked by Git then set this repository as your "origin" to push to.

``` bash
cd existing-project
git remote set-url origin http://username@host/project.git
git push origin master
```
