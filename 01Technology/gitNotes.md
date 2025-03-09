# Git Notes

[TOC]
`git push https://github.com/petergithub/eclipsePluginOpen.git master`

## 规范

1. 特定业务开发需要单独拉分支的，一般不要做merge master操作；需要同步master代码的时候，从master新拉分支，再从新分支merge之前的开发分支。
2. 本地commit之后在push 之前，必须执行pull --rebase，尽量确保提交commit树简单清晰，不要把冲突留到merge时大量爆发，在本地rebase时处理掉自己的代码冲突。

git merge --squash --no-ff

### Git commit message convention

[Git commit message convention that you can follow! - DEV Community 👩‍💻👨‍💻](https://dev.to/i5han3/git-commit-message-convention-that-you-can-follow-1709)

A typical git commit message will look like

`<type>(<scope>): <subject>`

"type" must be one of the following mentioned below!

- build: Build related changes (eg: npm related/ adding external dependencies)
- chore: A code change that external user won't see (eg: change to .gitignore file or .prettierrc file)
- ci: continuous integration related
- feat: A new feature
- fix: A bug fix
- docs: Documentation related changes
- refactor: A code that neither fix bug nor adds a feature. (eg: You can use this when there is semantic changes like renaming a variable/ function name)
- revert: reverts a previous commit
- perf: A code that improves performance
- style: A code that is related to styling
- test: Adding new test or making changes to existing test

"scope" is optional

Scope must be noun and it represents the section of the section of the codebase

"subject"

- use imperative, present tense (eg: use "add" instead of "added" or "adds")
- don't use dot(.) at end
- don't capitalize first letter

## Commands

### Most recent

`git checkout -b hotfix upstream/master` create a new branch from upstream
`git rev-list --all | xargs git grep <string>`
`ssh -Tv git@gitlab.com` get `Welcome to GitLab, Anonymous!`

Final release version
`git merge --no-ff <branchName>`    使得合并操作总是产生一次新的提交
`git merge --squash <branchName>`    把branchName上所有提交合并为一次提交到当前分支上再commit

`git show <commit-id>` show difference for a commit
`git show --pretty="format:" --name-only efbf363` List all the files for a commit in Git
`git log -g branchName` show Git branch created time just for local fetch/create time
`git log -p [file]`    显示指定文件相关的每一次diff
`git log -m --name-only` List all modified files in git merge commit
`git log -S<string> -- *.php` show a list of commits where the relevant_string was either added or removed in any PHP file in the project.
`git log --name-only` show changed file name only
`git log --follow [file]`    显示某个文件的版本历史，包括文件改名
`git log --all --full-history -- filename`  find a deleted file in commit history
`git log --all --full-history -- "**/thefile.*"` find a deleted file in commit history if you do not know the exact path you may use
`git checkout <SHA>^ -- <path-to-file>`  restore it into your working copy

`git whatchanged [file]`    显示某个文件的版本历史，包括文件改名
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

`git tag <tagName> -m "comment"`
`git tag -a <tagName> <commit-id>`
`git tag -d <tagname>`    刪除Tag
`git show <tagName>`    查看相应标签的版本信息，并连同显示打标签时的提交对象
`git tag -n9` list all the tags along with annotations & 9 lines of message for every tag

`git checkout -b <branchName> <tagName>`

`git push origin tagName`
`git push origin --tags`: 推送refs/tags/* 一次性推送很多标签
`git push origin :refs/tags/<tagName>`    刪除Tag from remote Git repositories

Remove local git tags that are no longer on the remote repository
    `git fetch --prune --prune-tags`
    `git fetch --prune origin "+refs/tags/*:refs/tags/*"`

通过 tagopt 配置若依仓库不拉取tag，本地仓库拉取tag，
通过 prune 和 pruneTags 随时更新删除掉的tag

```sh
# 通过 tagopt 配置若依仓库不拉取tag，本地仓库拉取tag，
# 通过 prune 和 pruneTags 随时更新删除掉的tag
$cat .git/config
[remote "ry"]
        url = git@gitee.com:y_project/RuoYi-Vue.git
        fetch = +refs/heads/*:refs/remotes/ry/*
        tagopt = --no-tags
[remote "origin"]
        url = ssh://git@gitlab.com/RuoYi-Backend.git
        fetch = +refs/heads/*:refs/remotes/origin/*
        tagopt = --tags
        prune = true
        pruneTags = true
[branch "master"]
        remote = origin
        merge = refs/heads/master
```

### Basic commands

HEAD指向最后一次commit的信息
`git cat-file -p [SHA-1]` 输出数据内容
`git cat-file -t [SHA-1]` 输出数据对象的类型

`git log --stat -2` 查看详细提交影响的文件 -p //输出非常详细的日志内容，包括了每次都做了哪些源码的修改
`git log --oneline`

`git commit --amend -m "New Comment"` 使用 New Commit 覆盖原来的 message
`git pull --rebase origin master`合并上游的修改到自己的仓库中,并把自己的提交移到同步了中央仓库修改后的master分支的顶部
`git rebase -i HEAD~3` 重写历史
`git rebase --onto master commitId` 在非master分支上执行,在master上重复commitId之后的提交,开区间
`git rebase A B` 会把在 A 分支里提交的改变移到 B 分支里重放一遍。
`git cherry-pick` 使用cherry pick在各个分支间同步代码
`git cherry-pick r1..r2` cherry pick commit (r1, r2] exclude r1. See `man gitrevisions`
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

`git pull --rebase origin master`合并上游的修改到自己的仓库中,并把自己的提交移到同步了中央仓库修改后的master分支的顶部
`git rebase --onto master <commitId>` 在非master分支上执行,在master上重复commitId之后的提交,开区间
`git rebase A B` 会把在 A 分支里提交的改变移到 B 分支里重放一遍。

[Git - Revision Selection Example history for range selection](https://git-scm.com/book/en/v2/Git-Tools-Revision-Selection#double_dot)

`^` to identify which parent，当前版本的上一个版本，即倒数第二个
`d921970^1` means the first parent of a merge commit
`d921970^2` means “the second parent of d921970

`HEAD~` and `HEAD^` are equivalent to refer the first parent
`HEAD~2` means “the first parent of the first parent,” or “the grandparent” — it traverses the first parents the number of times you specify.
`HEAD~3` or `HEAD~~~` the first parent of the first parent of the first parent
`HEAD~3^2` get the second parent of the `HEAD~3`

Double Dot
`git log origin/master..HEAD`  to see what you’re about to push to a remote
`git log origin/master..` — Git substitutes HEAD if one side is missing.

`r1..r2` commit (r1, r2] exclude r1. See `man gitrevisions`

Multiple Points
`^` character or `--not` before any reference

`git log refA..refB` == `git log ^refA refB` == `git log refB --not refA`
`git log refA refB ^refC` == `git log refA refB --not refC`

Triple Dot
`git log master...experiment` which specifies all the commits that are reachable by either of two references but not by both of them

## Skills

### restore flies

撤销工作区操作 `git checkout <file_name>`
这个命令有2种情况需要考虑

1. file_name自修改后还没有被放到暂存区，现在，撤销修改就回到和版本库一模一样的状态；
2. file_name已经添加到暂存区后，又作了修改，现在，撤销修改就回到添加到暂存区后的状态  。
    总之，就是让这个文件回到最近一次git commit或git add时的状态。

回退总结

1. 新增的文件还没有添加到暂存区，`git clean` clean untracked files. 或者先 add 然后 reset
2. 当你改乱了工作区某个文件的内容，想直接丢弃工作区的修改时，用命令`git checkout <file_name>`
3. 当你不但改乱了工作区某个文件的内容，还添加到了暂存区时，想丢弃修改，分两步，第一步用命令`git reset HEAD <file_name>`，就回到了场景1，第二步按场景1操作。
4. 已经提交了不合适的修改到版本库时，想要撤销本次提交，参考版本回退(`git reset --hard HEAD^`)，不过前提是没有推送到远程库。
5. 恢复 `git reset --hard` 删除的文件 通过`git reflog` or `git log -g` 找到commitID,然后`git reset --hard commitID`

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

## [Git - Submodules 子模块](https://git-scm.com/book/en/v2/Git-Tools-Submodules)

```sh
git config --global diff.submodule log
# git config --global log.submodule true
git config --global status.submoduleSummary true
git config --global fetch.recurseSubmodules on-demand
```

`git submodule update --init --recursive --remote` Submodule heads are generally detached

### 添加子模块

`git submodule add URL`，新增了配置文件 `.gitmodules`

### Cloning a Project with Submodules

`git clone --recurse-submodules URL`

To initialize, fetch and checkout any nested submodules `git submodule update --init --recursive`

### Working on a Project with Submodules

`git diff --submodule` you can see that the submodule was updated
 If you don’t want to type --submodule every time you run git diff, you can set it as the default format by setting the `diff.submodule` config value to “log”. `git config --global diff.submodule log`

`git submodule update --remote`, go into submodules and fetch and update. This command will by default assume that you want to update the checkout to the master branch of the submodule repository.

you can set it in either your .gitmodules file (so everyone else also tracks it), or just in your local .git/config file. Let’s set it in the .gitmodules file: `git config -f .gitmodules submodule.DbConnector.branch stable`  track that repository’s “stable” branch,

see log of commits `git log -p --submodule`, config it as default

## Git subtree

/Library/Developer/CommandLineTools/usr/libexec/git-core/git-subtree
[git/git-subtree.txt at master · git/git · GitHub](https://github.com/git/git/blob/master/contrib/subtree/git-subtree.txt)
[Mastering Git subtrees. They’re the ultimate way to both share… | by Christophe Porteneuve | Medium](https://medium.com/@porteneuve/mastering-git-subtrees-943d29a798ec)

### 介绍

用一句话来描述 Git Subtree 的优势就是：

> 经由 Git Subtree 来维护的子项目代码，对于父项目来说是透明的，所有的开发人员看到的就是一个普通的目录，原来怎么做现在依旧那么做，只需要维护这个 Subtree 的人在合适的时候去做同步代码的操作。

最简单理解两者的方式，subtrees在父仓库是拉取下来的一份子仓库拷贝，而submodule则是一个指针，指向一个子仓库commit。

我们可以过激地比较：
submodules 推送简单，但拉取困难，因为它们是指向子仓库的指针
subtrees 推送困难，但拉取简单，因为他们是子仓库的拷贝

### 什么时候需要Subtree

1、当多个项目共用同一模块代码，而且这块代码跟着项目在快速更新的时候
2、把一部分代码迁移出去独立为一个新的 git 仓库，但又希望能够保留这部分代码的历史提交记录

### 命令

[git subtree使用说明_一行Java的博客-CSDN博客](https://blog.csdn.net/lupengfei1009/article/details/103099820)

```sh
-d # show debug messages

# 引入子仓库
git remote add -f <仓库别名> <仓库地址>

git subtree add   --prefix=<prefix> <commit>
git subtree add   --prefix=<prefix> <repository> <ref>
git subtree pull  --prefix=<prefix> <repository> <ref>
git subtree push  --prefix=<prefix> <repository> <ref>
git subtree merge --prefix=<prefix> <commit>

# 对已有的项目目录进行拆分
git subtree split --prefix=<prefix> [OPTIONS] [<commit>]
# 重新split出一个新起点（这样，每次提交subtree的时候就不会从头遍历一遍了）
git subtree split --rejoin --prefix=<prefix> --branch <ref>
```

#### 添加一个已有的 subtree 项目示例

```sh
# git remote add -f <仓库别名> <仓库地址>
git remote add -f child git@github.com/subtree-child.git

# git subtree add   --prefix=<prefix> <repository> <ref>
git subtree add --prefix=child child master

# 推送到远程
git subtree push --prefix=child child feature/child
# 拉取远程代码
git subtree pull --prefix=child child master
```

#### 对已有的项目目录进行拆分

开发中发现某一部分可以抽离出来作为公共的子模块，操作流程如下

```sh
# 1. 将 subtree-parent项目的 src/plugins 目录剥离成一个新的分支 subtree-plugins-branch
# git subtree split --prefix=<prefix> [OPTIONS] [<commit>]
git subtree split --prefix=src/plugins -b subtree-plugins-branch

# 2. 在主项目 subtree-parent 的同级目录创建一个用于保存这个分支的文件夹
# 创建文件夹
mkdir ../subtree-plugins
# 切到对应的文件夹
cd ../subtree-plugins/
# 初始化成一个git仓库
git init

# 3. 将剥离出来的分支并到当前目录来
# ../subtree-parent 为主仓库的路径
# subtree-plugins-branch 为第一步剥离出来的分支名称
git pull ../subtree-parent subtree-plugins-branch

# 4. 将新的仓库关联到远端仓库
git remote add origin https://github.com/subtree-plugins.git

# 5. 推送到远端代码
git push -u origin +master
```

### Mastering Git subtrees

```sh
# [Mastering Git subtrees. They’re the ultimate way to both share… | by Christophe Porteneuve | Medium](https://medium.com/@porteneuve/mastering-git-subtrees-943d29a798ec)

# Adding a subtree
# add plugin repo
git subtree add --prefix=vendor/plugins/demo plugin master
# equals by manually:
git read-tree --prefix=vendor/plugins/demo -u plugin/master

# Getting an update from the subtree’s remote
# pull plugin repo
git subtree pull --prefix=vendor/plugins/demo plugin master
# equals by manually:
git merge -X subtree=vendor/plugins/demo plugin/master

# git subtree error "fatal: refusing to merge unrelated histories"
git merge -s subtree -X subtree=src/plugins plugins/master --allow-unrelated-histories

# Updating a subtree in-place in the container
# update plugin repo
git subtree push --prefix vendor/plugins/demo plugin master
# equals by manually:
git cherry-pick -x --strategy=subtree master^
git checkout -b backport-plugin plugin/master
git push plugin HEAD:master

# --strategy=subtree (-s means something else in cherry-pick) to make sure files outside of the subtree (elsewhere in container code) will get quietly ignored

# Turning a directory into a subtree
git subtree split --prefix lib/plugins/myown -b split-plugin
# equals by manually:
git checkout -b split-plugin
git filter-branch --subdirectory-filter lib/plugins/myown
```

## Git configuration

Show config and its origin
`git config --show-origin user.email`
`git config --show-origin user.name`

Show all config and its origin: `git config --list --show-origin`

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

## Git verbose information

[Git - Verbose Mode: Debug Fatal Errors - ShellHacks](https://www.shellhacks.com/git-verbose-mode-debug-fatal-errors/)
Debug Git command:

```sh
$ GIT_TRACE=true \
GIT_CURL_VERBOSE=true \
GIT_SSH_COMMAND="ssh -vvv" \
git clone git://host.xz/path/to/repo.git
Debug Git-related issues with the maximum level of verbosity:

$ GIT_TRACE=true \
GIT_CURL_VERBOSE=true \
GIT_SSH_COMMAND="ssh -vvv" \
GIT_TRACE_PACK_ACCESS=true \
GIT_TRACE_PACKET=true \
GIT_TRACE_PACKFILE=true \
GIT_TRACE_PERFORMANCE=true \
GIT_TRACE_SETUP=true \
GIT_TRACE_SHALLOW=true \
git clone git://host.xz/path/to/repo.git
```

| Option | Description |
| --- | --- |
| `GIT_TRACE=true` | Enable general trace messages |
| `GIT_CURL_VERBOSE=true` | Print HTTP headers (similar to `curl -v`) |
| `GIT_SSH_COMMAND="ssh -vvv"` | Print SSH debug messages (similar to `ssh -vvv)` |
| `GIT_TRACE_PACK_ACCESS=true` | Enable trace messages for all accesses to any packs |
| `GIT_TRACE_PACKET=true` | Enable trace messages for all packets coming in or out of a given program |
| `GIT_TRACE_PACKFILE=true` | Enable tracing of packfiles sent or received by a given program |
| `GIT_TRACE_PERFORMANCE=true` | Enable performance related trace messages |
| `GIT_TRACE_SETUP=true` | Enable trace messages printing the `.git`, working tree and current working directory after Git has completed its setup phase |
| `GIT_TRACE_SHALLOW=true` | Enable trace messages that can help debugging fetching/cloning of shallow repositories |

## Examples

### create repository

Create A Repo

First: Create A Repo
    Click New Repository. `https://github.com/repositories/new`

Next: Create a README for your repo.

1. Create the README file
    In the prompt, type the following code:

```bash
$ mkdir ~/Hello-World    //Creates a directory for your project called "Hello-World" in your user directory
$ cd ~/Hello-World    //Changes the current working directory to your newly created directory
$ git init    //Sets up the necessary Git files
Initialized empty Git repository in /Users/your_user_directory/Hello-World/.git/
$ touch README
```

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

```sh
git config --global user.name peter
git config --global user.email "email@gmail.com"
```

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

### How to complete a git clone for a big project on an unstable connection?

[How to complete a git clone for a big project on an unstable connection? - Stack Overflow](https://stackoverflow.com/questions/3954852/how-to-complete-a-git-clone-for-a-big-project-on-an-unstable-connection)

```bash
# The key here is --depth 1 and --unshallow.
# This also works for fetching an existing repo on slow connection: git fetch --depth 1 then git fetch --unshallow

# --depth 1: Create a shallow clone with a history truncated to the specified number of commits
git clone http://github.com/large-repository --depth 1
cd large-repository
git fetch --unshallow

# for m in $(seq 1 50);do git fetch --depth=$[m*100];done
```

### reset author for ALL commits

```bash
git filter-branch -f --env-filter "
    GIT_AUTHOR_NAME='Newname'
    GIT_AUTHOR_EMAIL='new@email'
    GIT_COMMITTER_NAME='Newname'
    GIT_COMMITTER_EMAIL='new@email'
  " HEAD
```

### View git history of specific line

[View git history of specific line - Stack Overflow](https://stackoverflow.com/questions/50469927/view-git-history-of-specific-line)

`git log -L 15,+1:'path/to/your/file.txt'` Trace the evolution of the line [15, 15+1] in file.txt

`-L <start>,<end>:<file>` Trace the evolution of the line range given by `<start>,<end>`
