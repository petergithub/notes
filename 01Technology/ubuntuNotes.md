# Ubuntu Notes

[TOC]

学习系统结构的最好方法是自己做一个linux系统, 再也没有什么能比自己做一个linux系统更能学习系统结构的了. LFS (linux from scratch)可以教你从源代码自己编译一个系统. 通过自己编译一个系统, 你就可以了结linux系统结构, 知道哪些文件是干什么用的, 以及他们如何协调 工作.
Linux内核设计与实现 Linux Kernel Development(Third Edition)-Robort Love

## Recent

emacs save and quit: `Ctrl+x, Ctrl+c`
[Emacs Basics](http://ergoemacs.org/emacs/emacs_basics.html)

[命令行的艺术](https://github.com/jlevy/the-art-of-command-line/blob/master/README-zh.md)

16 进制数字 10 进制转换 `printf '%d\n' 0x11`
Convert a number from hexadecimal to decimal: `printf '%d\n' 0xff`  or `echo $((0xFF))`
Convert a number from decimal to hexadecimal: `printf '%x\n' 255`

`for i in *; do cd /path/to/folder/$i ;mvn clean; done`
`SCRIPT_PATH=$(S=$(readlink "$0"); [ -z "$S" ] && S=$0; dirname ${S})`

`chkconfig --list [serviceName]` a simple command-line tool for maintaining the /etc/rc[0-6].d directory hierarchy
`chkconfig serviceName on/off`
获取 IP 地址位置信息: `curl -s "http://ip.taobao.com/service/getIpInfo.php?ip=113.104.182.107" | jq '.data | .city + ", " +.region + ", " + .isp'`
ubuntu reset menu bar: restart unity `sudo killall unity-panel-service` or `alt + F2 unity`
[Memcached服务端自动启动](http://www.cnblogs.com/technet/archive/2011/09/11/2173485.html)

`ldd --version` get glibc version
`sysctl -a` display all
`sysctl -p` make effective

`trap`命令用于指定在接收到信号后将要采取的动作，常见的用途是在脚本程序被中断时完成清理工作。
当shell接收到sigspec指定的信号时，arg参数（命令）将会被读取，并被执行。
例如：`trap "exit 1" HUP INT PIPE QUIT TERM` 表示当`shell`收到`HUP INT PIPE QUIT TERM`这几个命令时，当前执行的程序会读取参数`exit 1`，并将它作为命令执行

```sh
# To list only hidden files
ls -d .[\!.]*
ls -S # 按文件大小排序

mv {short,very_long}.txt # will move short.txt to very_long.txt
CTRL+h # show hidden files
nautilus # open your home folder
location # make a command can be call anywhere
ln -sfn # update a symbolic link
ps -A -opid,stime,etime,args # 查看进程的启动时间
pstack # Linux命令查看某个进程的当前线程栈运行情况
ps huH p <PID_OF_U_PROCESS> | wc -l # monitor the active thread count of a process (jvm)
last # To find out when a particular user last logged in to the Linux or Unix server.

fuser # command (short for "file user"), this will show you information about the process that is using the file or the file user.
sudo service network-manager start

# Table 4-2: Commonly Used Character Classes

whatis # Display a very brief description of a command
info # Display a command's info entry
apropos # Display a list of appropriate commands

# Recent versions of bash provide a second, more streamlined method for performing combined redirection
ls -1 /bin/usr &> ls-output.txt
# This will work cor-rectly with most hidden files (though it still won't include filenames with multiple leading periods). The ls command with the -A option ("almost all") will provide a correct listing of hidden files:
ls-A
echo [!]*
```

[network-manager](http://archive.ubuntu.com/ubuntu/pool/main/n/network-manager/network-manager_0.9.8.8-0ubuntu7.3_amd64.deb)

execute `echo 2` 5 times: `seq 5 | xargs -I@ -n1 echo 2`
`$((1 + RANDOM % 1000))` random number between 1 and 1000

get the MD5 hash `echo -n Welcome | md5sum`

### encode

unicode编码，所以想转成utf8看中文
printf %b '\u6df1\u5733'
echo '["\u6df1\u5733"]' | jq .

## Basic Command

M-1 is meta-1 (Alt-1 in Ubuntu)
C-1 is control-1

[Keyboard problems, setting 3rd level chooser and Meta key in Unity](http://ubuntuforums.org/showthread.php?t=2220062)

If you are not sure which key codes represent which keys on your keyboard you might want to run xev and then press the desired keys to get their codes.
less /usr/share/X11/xkb/symbols/us

`CDPATH` : 设置 cd 命令的基目录 `export CDPATH=".:/home/guru:/usr"` 经常使用CD命令进入某一个特定目录下的子目录，你可以将CDPATH设置为该目录，当使用cd进入其下的子目录时，则不需要键入该目录名

### bash

`man readline` to get the introduction to the combination of keys or documentation from [Readline Interaction](http://www.gnu.org/software/bash/manual/bash.html#Readline-Interaction)
NB : LNEXT interpret the next character as a string. eg : for symbolize a `CR+LF` you must do the key
combination `ctrl+v+return`, that will print `^M`
The `M-`/`Meta` sequence means the `Alt` key in Linux/Windows, `Esc` in Mac

为了方便地键入长命令, 在设置你的编辑器后（例如 `export EDITOR=vim`）, 键入 `ctrl-x, ctrl-e` 会打开一个编辑器来编辑当前命令. 在 `vi` 模式下则键入 `escape-v` 实现相同的功能. Use `Ctrl+x` followed by `Ctrl+e` to open the current line in the editor specified by `$FCEDIT` or `$EDITOR` or emacs (tried in that order).
vimtutor: vim interactive guide
`man readline` to get the introduction to the combination of keys
`bindkey` get all keybinding
Question: Cancel failed reverse-i-search in bash but keep what I typed in

[Fastest way(s) to move the cursor on a terminal command line](https://stackoverflow.com/questions/657130/fastest-ways-to-move-the-cursor-on-a-terminal-command-line?rq=1)

Add comments for multi-lines
    press CTRL+v to enter visual block mode and press "down" until all the lines are marked. Then press I to insert at the beginning (of the block). The inserted characters will be inserted in each line at the left of the marked block.

编辑命令

- CTRL+a : 移到命令行首
- CTRL+e : 移到命令行尾
- ALT+f : 按单词前移（右向）
- ALT+b : 按单词后移（左向）
- CTRL+xx: 在命令行首和光标之间移动
- CTRL+u : 从光标处删除至命令行首 remove line command
- CTRL+k : 从光标处删除至命令行尾
- CTRL+w : 从光标处删除至字首
- ALT+d : 从光标处删除至字尾 `esc +d`   Delete the Word after the cursor
- CTRL+d : 删除光标处的字符
- CTRL+h : 删除光标前的字符
- CTRL+y : 粘贴至光标后
- ALT+c : 从光标处更改为首字母大写的单词
- ALT+u : 从光标处更改为全部大写的单词
- ALT+l : 从光标处更改为全部小写的单词
- CTRL+t : 交换光标处和之前的字符 It will reverse two characters
- ALT+t : 交换光标处和之前的单词 `esc+t` transpose two adjacent words
- ALT+Backspace: 与 CTRL+w 相同类似, 分隔符有些差别 [感谢 rezilla 指正]

重新执行命令

- CTRL+r: 逆向搜索命令历史 reverse-i-search in bash
- CTRL+s: forward-search-history (it is used by `stty` in Ubuntu, add `stty -ixon` in .bashrc)
- CTRL+g: 从历史搜索模式退出
- CTRL+p: 历史中的上一条命令
- CTRL+n: 历史中的下一条命令
- ALT+.: 使用上一条命令的最后一个参数；zsh 从后往前数。bash 从前往后数

控制命令

- CTRL+l: 清屏
- CTRL+o: 执行当前命令, 并选择上一条命令 循环执行历史命令
- CTRL+s: 阻止屏幕输出
- CTRL+q: 允许屏幕输出
- CTRL+c: 终止命令
- CTRL+z: 挂起命令

#### history cmd

history with date and time

1. macOS `history -t"%F %T"`
2. zsh `history -i`
3. bash `echo 'export HISTTIMEFORMAT="%d/%m/%y %T "' >> ~/.bash_profile && source ~/.bash_profile`

`man zshbuiltins` to see more format:

- -f     prints full time-date stamps in the US `MM/DD/YY hh:mm' format
- -i     prints full time-date stamps in ISO8601 `yyyy-mm-dd hh:mm' format
- -t fmt prints time and date stamps in the given format; fmt is formatted with the strftime function with the zsh extensions  described  for  the  %D{string} prompt format in the section EXPANSION OF PROMPT SEQUENCES in zshmisc(1).  The resulting formatted string must be no more than 256 characters or will not be printed

Bang (!) 命令 [documention](https://www.gnu.org/software/bash/manual/html_node/Event-Designators.html#Event-Designators)

- `!!` or `!-1` : 执行上一条命令 Run the last command-name
- `!-2` : 执行倒数第二条命令
- `!-3` : 执行倒数第三条命令
- `!!:1` or `!^`: to call 1st arg, `echo !!:1`
- `!!:2`    to call 2nd arg, `echo !!:2`
- `!$`: 上一条命令的最后一个参数, 与 ALT+. 相同
- `!$:p`: 打印输出 !$ 的内容
- `!*`: 上一条命令的所有参数
- `!*:p`: 打印输出 `!*` 的内容

- `!foo`: 执行最近的以 foo 开头的命令, 如 !ls
- `!foo:p`: 仅打印输出, 而不执行
- `^foo`: 删除上一条命令中的 foo
- `^foo^foo`: 将上一条命令中的 foo 替换为 bar
- 将上一条命令中所有的 `foo` 都替换为 `bar`的几种方式，quick substitution
  - `!!:gs/foo/bar/` 推荐使用
  - `fc -s foo=bar` GNU bash, zsh
  - `^foo^bar^:G` zsh
  - `^foo^bar^` 未验证出来

- `rm !(2.txt) 从目录中删除除 2.txt 外的所有文件, 使用 !(文件名) 的方式来避免命令对某个文件的影响
- `[ ! -d /home/exist ] && mkdir /home/exist` 检查某个目录是否存在, 没有则创建

Bash History: Correct / Repeat The Last Command With a Substitution
echo $?    获取上一次命令执行的结果, 0表示成功, 非0表示失败
`sudo su -` change to root user
`su - username`(load new env) vs. `su username`

友情提示

1. 以上介绍的大多数 Bash 快捷键仅当在 emacs 编辑模式时有效, 若你将 Bash 配置为 vi 编辑模式, 那将遵循 vi 的按键绑定. Bash 默认为 emacs 编辑模式. 如果你的 Bash 不在 emacs 编辑模式, 可通过`set -o emacs`设置.
2. 用`CTRL+p`取出历史命令列表中某一个命令后, 按`CTRL+o`可以在这条命令到历史命令列表后面的命令之间循环执行命令, 比如历史命令列表中有50条命令, 后面三项分别是命令A, 命令B, 命令C, 用`CTRL+p`取出命令A后, 再按CTRL+o就可以不停的在命令A, 命令B, 命令C中循环执行这三个命令. `CTRL+o`有一个非常好用的地方, 比如用cp命令在拷贝一个大目录的时候, 你肯定很想知道当前的拷贝进度, 那么你现在该怎样做呢? 估计很多人会想到不停的输入`du -sh dir`去执行, 但用`CTRL+o`可以非常完美的解决这个问题, 方法就是:
   1. 输入`du -sh dir`, 按回车执行命令
   2. `CTRL+p, CTRL+o`, 然后就可以不停的按CTRL+o了, 会不停的执行`du -sh dir`这条命令  like `watch -n 1 -d du -sh dir`
   3. 这个问题也可以用watch命令解决: `watch -n 10 -d du -sh /app/data/nas/`
3. 使用 CTRL+r 而不是上下光标键来查找历史命令  CTRL+g: 从历史搜索模式退出
4. `CTRL+s,CTRL+q,CTRL+c,CTRL+z` 是由终端设备处理的, 可用`stty`命令设置.
    CTRL+s: forward-search-history (it is used by `stty` in Ubuntu, add `stty -ixon` in .bashrc)
    The sequence C-s is taken from the terminal driver, as you can see from `stty -a | grep '\^S'` To free up the sequence for use by readline, set the stop terminal sequence to some other sequence, as for example `stty stop ^J`
    or remove it altogether with `stty stop undef`.
    or totally disable XON/XOFF (resume/pause) flow control characters by `stty -ixon`
    After that `C-s` would work in the given terminal.
    Set it in ~/.bashrc to make it work in every terminal.
    refer to [search bash history](http://stackoverflow.com/questions/791765/unable-to-forward-search-bash-history-similarly-as-with-ctrl-r) and [search bash history reverse](http://askubuntu.com/questions/60071/how-to-forward-search-history-with-the-reverse-i-search-command-ctrlr)
5. 在已经敲完的命令后按`CTRL+x CTRL+e`, 会打开一个你指定的编辑器（比如vim, 通过环境变量$EDITOR 指定）  `echo "export EDITOR=vim" >> ~/.bashrc`
6. `ALT+.`把上一条命令的最后一个参数输入到当前命令行. 非常非常之方便, 强烈推荐. 如果继续按ALT+., 会把上上条命令的最后一个参数拿过来. 同样, 如果你想把上一条命令第一个参数拿过来咋办呢? 用ALT+0 ALT+., 就是先输入ALT+0, 再输入ALT+.. 如果是上上条命令的第一个参数呢? 当然是ALT+0 ALT+. ALT+.了.
7. undo     CTRL+/

#### bash profile

bash Startup Files: it looks for `~/.bash_profile`, `~/.bash_login`, and `~/.profile`
 You only want to see it on login, so you only want to place this in your .bash_profile. If you put it in your .bashrc, you'd see it every time you open a new terminal window.
add  one line in .profile
`alias ls='ls --color=never'` #调用`\ls`使用原本的ls命令而不是别名
add one line in .bashrc
.bashrc:  `alias grep='grep --color=auto'`

#### file carriage return & line feed 换行

两个字符: 一个字符`Return`来移到第一列, 另一个字符`Line feed`来新增一行
UNIX人认为在到达一行的结尾时新增一行`<Line feed> (LF) \n`, 而Mac人则认同`<Return> (CR) \r`的解决办法, MS则坚持古老的`<Return><Line feed> (CRLF) \r\n`
在Linux下使用vi来查看一些在Windows下创建的文本文件, 有时会发现在行尾有一些"^M". 有几种方法可以处理,注意: 这里的"^M"要使用"CTRL+v CTRL+m"生成, 而不是直接键入"^M".

1. $ dos2unix myfile.txt
2. vi `:%s/^M$//g` #去掉行尾的^M.
    `:%s/^M//g` #去掉所有的^M.
3. `sed -e 's/^M//n/g' myfile.txt` // evluate
 `sed -i 's/^M//n/g' myfile.txt` // replace
 `sed -i 's/\r$//' myfile.txt` // replace

vi下显示回车换行符等特殊符号
显示换行 `:set list` 进入`list mode`, 可以看到以`$`表示的换行符和以`^I`表示的制表符.
退出`list mode` `:set nolist`

删除换行
可以用以下命令删除换行符:  `:%s/\n//g`
可以用以下命令删除DOS文件中的回车符“^M”: `:%s/\r//g`
可以用以下命令转换DOS回车符“^M”为真正的换行符: `:%s/\r/\r/g`

`fileformats`选项, 用于处理文件格式问题
`:set fileformats=unix,dos` vim将UNIX文件格式做为第一选择, 而将MS-DOS的文件格式做为第二选择
`:set fileformat?` 检测到的文件格式会被存放在fileformat选项中
`:set fileformat=unix` 将文件转换为UNIX格式的文件

在默认情况下, Vim认为文件是由行组成的, 并且文件最后一行是以`EOL`为结束符的
`:set endofline` 设置文件以`EOL`结束符结尾
`:set noendofline` 设置文件不以`EOL`结束符来结尾

#### move hidden files together

1. `shopt -s dotglob nullglob`: set shopt
2. `move configuration/* .`: move files
3. `shopt -u dotglob nullglob`: unset shopt

`shopt | grep on` will print a list of all the enabled options.
`man bash` search `shopt`
`dotglob` If set, Bash includes filenames beginning with a `.` in the results of filename expansion.
`nullglob` If set, Bash allows filename patterns which match no files to expand to a null string, rather than themselves.
expands non-matching globs to zero arguments, rather than to themselves.
[The-Shopt-Builtin](https://www.gnu.org/software/bash/manual/bash.html#The-Shopt-Builtin), [glob](http://mywiki.wooledge.org/glob)

#### man manpath

MANDATORY_MANPATH           /home/pu/opt/OracleDeveloperStudio12.6-linux-x86-bin/developerstudio12.6/man
MANPATH_MAP /home/pu/opt/OracleDeveloperStudio12.6-linux-x86-bin/developerstudio12.6/bin        /home/pu/opt/OracleDeveloperStudio12.6-linux-x86-bin/developerstudio12.6/man

#### When pasting in terminal, `00~` is pasted at the start and `01~` at the end

[macos - When pasting in Terminal.app, `00~` is pasted at the start and `01~` at the end - Ask Different](https://apple.stackexchange.com/questions/446859/when-pasting-in-terminal-app-00-is-pasted-at-the-start-and-01-at-the-end)

Short answer: Run the command `printf '\e[?2004l'`. This sends an escape sequence to the terminal that tells it to stop sending bracketed paste sequences.

or `reset`

### vi

[What is your most productive shortcut with Vim?](https://stackoverflow.com/questions/1218390/what-is-your-most-productive-shortcut-with-vim/1220118#1220118)

[wsdjeg/vim-galore-zh_cn: Vim 从入门到精通](https://github.com/wsdjeg/vim-galore-zh_cn)
[Moolenaar.net - Vim](https://www.moolenaar.net/vim.html)

命令提示 Command line completion with `CTRL-D` and `<TAB>`
`:help` help document
`:help cmdline-special` special character
Jump to a subject:  Position the cursor on a tag (e.g. |bars|) and hit `CTRL-]`
Jump back:  Type `CTRL-T` or `CTRL-O` (repeat to go further back)
`CTRL-O` Go to previous (`^O` - "O" for old) location or to the next (^I - "I" just near to "O"). When you perform searches, edit files etc., you can navigate through these "jumps" forward and back.
`gi` Go to last edited location (very useful if you performed some searching and than want go back to edit)

`~` changes case (in visual mode)
`U` to convert to uppercase (in visual mode)
`u` to convert to lowercase (in visual mode)
`>` indent block (in visual mode)
`<` unindent block (in visual mode)

#### Set option Configuration

```sh
:syntax on

# sets the option "xxx"
:set xxx
# Some options are:
# 'ic' 'ignorecase'       ignore upper/lower case when searching
# 'is' 'incsearch'        show partial matches for a search phrase
# 'hls' 'hlsearch'        highlight all matching phrases
# You can either use the long or the short option name.
#   Prepend "no" to switch an option off:   :set noic

# (不)列出行号 (nu为行数)
:set nu
:set nonu
# vi在查找过程中(不)区分大小写 `:set ignorecase` / `:set noignorecase`
:set ic
:set noic
# Show the line and column number of the cursor position
:set ru
:set noru
# To display non-printable characters, such as control characters `$` is Newline, `^|` is Tab
:set list
# customized specified symbols to display.
:set listchars=nbsp:☠,tab:▸,eol:$,tab:>-,trail:~,extends:>,precedes:<
# (不)自动换行
:set wrap
:set nowrap
# (不)高亮搜索结果
:set hls
:set nohls
```

#### custom keyboard shortcut

`inoremap jj <ESC>`    Remap Your ESCAPE Key in Vim
`nnoremap j VipJ`
`:map`    列出当前已定义的映射

#### Move

`%`    move to the matching parenthesis (), {}, [] Or from a "#if" to the matching "#endif". Actually, % can jump to many different matching
`(` / `)` move a sentence back/forward
`{` / `}` move paragraph back/forward
After a search, `CTRL-O` takes you back to older positions, `CTRL-I` to newer positions
`gi` Go to last edited location (very useful if you performed some searching and than want go back to edit)
`[{` to jump back to the `{` at the start of the current code block.
`gd` to jump from the use of a variable to its local declaration.

Move around inside of long line: `gj` and `gk` move up and down one displayed line by using gj and gk. That way, you can treat your one wrapped line as multiple lines

#### Scrolling relative to cursor (scroll-cursor)

`:help scroll-cursor` or `:help z`

`zEnter` or `zt` puts current line to top of screen
`z.` or `zz` puts current line to center of screen, (warning: ZZ is save and exit, so watch out for caps lock)
`z-` or `zb` puts current line to bottom of screen

(`zEnter`, `z.`, and `z-` puts the cursor in the first non blank column. `zt`, `zz`, and `zb` leaves the cursor in the current column)

`zt / zz / zb` - fixed cursor and move screen to top/center(german:'zentrum')/ bottom <---> `H / M / L` - fixed screen and move cursor to High / Middle / Low position

##### 快速回跳

``  :  当前文件上次跳转操作的位置
`.  :  上次修改操作的地方
\`^  :  上次插入的地方
`[  :  上次修改或复制的起始位置
\`]  :  上次修改或复制的结束位置
`<  :  上次高亮选区的起始位置
\`>  :  上次高亮选区的结束位置

#### Selection

You need to select to the next matching parenthesis.

- `v%` if the cursor is on the starting/ending parenthesis
- `vib` if the cursor is inside the parenthesis block

- select text between quotes: `vi"` for double quotes, `vi'` for single quotes
- select a curly brace block (very common on C-style languages): `viB`, `vi{`

##### i & a

`i` 命令可以理解为 inside，即选中匹配符号之间不包含匹配符号的内容。而 `a` 则选中包含匹配项的内容。

``` bash
'a)' 或 'ab'  :  一对()
'a}' 或 'aB'  :  一对{}
a]  :  一对[]
a>  :  一对<>
a"  :  一对""
at  :  一对xml标签

iw  :  当前单词
aw  :  当前单词及一个空格
iW  :  当前字符串
aW  :  当前字符串及一个空格
is  :  当前句子
as  :  当前句子及一个空格
ip  :  当前段落
ap  :  当前段落及一个空行
```

#### mark and registers

```sh
mg  # This book marks the current position as g (this can be any letter)
'g  # going to the bookmarked line
`g  # return to g
```

You can move to the line containing a mark using the ' (single quote) command. Thus 'a moves to the beginning of the line containing the 'a' mark.
You can move to the precise location of any mark using the \`(backquote) command. Thus \`z will move directly to the exact location of the 'z' mark.

I can use any of the 26 "named" registers by prefixing the "object" reference with " (the double quote modifier). Thus if I use "add I'm cutting the current line into the 'a' register and if I use "by/foo then I'm yanking a copy of the text from here to the next line containing "foo" into the 'b' register. To paste from a register I simply prefix the paste with the same modifier sequence: "ap pastes a copy of the 'a' register's contents into the text after the cursor and "bP pastes a copy from 'b' to before the current line.

#### Basic vi

VIM - main help file  `:help`
find help on just about any subject, by giving an argument to the `:help` command. `:help w`, `:help c_CTRL-D`, `:help user-manual`
切换大小写 `~`
`:sp`    split window above and below
`:sh`    暂时退出vi到系统下, 结束时按CTRL+d则回到vi
`.` 命令重复上次的修改.
`:!command`  executes an external command
`:r !command`    将命令command的输出结果放到当前行 如`:r! ls -ltr`
read the output of an external command.  For example, `:r !ls`  reads the output of the `ls` command and puts it below the cursor

`:r FILENAME`  retrieves disk file FILENAME and puts it below the cursor position
`:x` == `:wq` 当文件被修改时两个命令是相同的. 但如果未被修改, 使用`:x`不会更改文件的修改时间, 而使用`:wq`会改变文件的修改时间
`:w !sudo tee %`  在VIM中保存一个当前用户无权限修改的文件 查阅vim的文档（输入`:help :w`）, 会提到命令`:w!{cmd}`, 让vim执行一个外部命令{cmd}, 然后把当前缓冲区的内容从stdin传入. `tee`是一个把stdin保存到文件的小工具. 而`%`, 是vim当中一个只读寄存器的名字, 总保存着当前编辑文件的文件路径. 所以执行这个命令, 就相当于从vim外部修改了当前编辑的文件.
`:help cmdline-special` to see meaning of `%`
replace a character by a newline in Vim: Use `\r` instead of `\n`

`:g, :global` Hide all matching lines in Vim, `:g/FIND`
`:g!, :global!` Hide all not matching lines in Vim, `:g!/FIND` or `:v/FIND`

`.` 命令重复上次的修改.
修改在这里就是插入、删除或者替换文本. 能够重复是一个非常强大的机制. 如果你基于它来安排你的编辑, 许多修改将变得只是敲.键. 留意其间的其他修改, 因为它会替代你原来要重复的修改. 相反, 你可以用m命令先标记这个位置, 继续重复你的修改, 稍后再返回到这个位置.
重复修改一个单词.
如果是在整个文件中, 你可以使用:`s`（substitute）命令. 如果只是几个地方需要修改, 一种快速的方法是使用`*`命令去找到下一个出现的单词, 使用`cw`命令修改它. 然后输入`n`去找到下一个单词, 输入英文逗点 . 去重复`cw`命令

改变与替换操作命令
`r` 替换光标所在的字符
`R` 替换字符序列 a capital  `R`  to replace more than one character
`cw` 替换一个单词
`ce` 同`cw`
`cb` 替换光标所在的前一字符
`c$` 替换自光标位置至行尾的所有字符
`C` 同`c$`
`cc` 替换当前行

`yw`    只有当当前光标处于单词的第一个字母时才是"复制整个单词"(包含末尾的空格)
`yiw`    不管当前光标处于单词的哪个字母, 都是复制整个单词(不包括末尾的空格)
`diw`    删除当前光标所在的word(不包括空白字符), 意为Delete Inner Word 两个符号之间的单词
`dt<LETTER>`    删除所有的内容, 直到遇到 LETTER
`daw`    删除当前光标所在的word(包括空白字符), 意为Delete A Word
`guw`    光标下的单词变为小写
`gUw`    光标下的单词变为大写
`ga`    显示光标下的字符在当前使用的encoding下的内码
`CTRL+SHIFT++`    zoom in on your terminal
`CTRL+-`    Zoom out

删除多行

1. 如果要删除的段落的下一行是空行 一般用`d}` , 按两个键就可以了 多段的时候再按 .
2. 如果要删除的段落的下一行不是空行 则很容易找到该行的模式,  如该行存在function字串 一般 `d/fu` 也就搞定了

输入单词A的前几个字母, 然后CTRL+n补全. <CTRL+o><CTRL+n> <CTRL+o><CTRL+p> 只是简单的上下文补全, 还有<CTRL+o><CTRL+f> 用于对目录名进行补全

Recording 记录功能: 命令模式下按`q`, 再按一个字母`a`做名字, 就进入了记录模式, 再按`q`停止记录.
Replay 回放记录: 在命令模式下按`@`, 再按下记录名字`a`. 连续回放可以在`@`前加次数.
To playback your keystrokes, press `@` followed by the letter previously chosen. Typing `@@` repeats the last playback.

#### 文件对比 合并 多窗口

```sh
diff -u
# 查看变更总览数据
diffstat
# 对整个文件夹有效。使用 `diff -r tree1 tree2 | diffstat` 查看变更的统计数据
diff -r
# 查看变更的统计数据
diff -r tree1 tree2 | diffstat

vimdiff  FILE_LEFT  FILE_RIGHT
# quit all 同时退出两个文件
:qa
# write all
:wa
# write, then quit all
:wqa
# force to quit all
:wqa

# execute set wrap on every window (windo stands for "window do").
:windo set wrap
```

```sh
]c # 跳转到下一个差异点.
[c # 反向跳转
dp # (diff "put") 把一个差异点中当前文件的内容复制到另一个文件里
do # (diff "get", 之所以不用dg, 是因为dg已经被另一个命令占用了)把另一个文件的内容复制到当前行
:diffu[pdate] # 更新diff 修改文件后, vimdiff会试图自动来重新比较文件, 来实时反映比较结果. 但是也会有处理失败的情况, 这个时候需要手工来刷新比较结果:
zo # (folding open, 之所以用z这个字母, 是因为它看上去比较像折叠着的纸) 展开被折叠的相同的文本行
zc # (folding close)重新折叠

CTRL+w, w # 在两个文件之间来回跳转
CTRL+w K # (把当前窗口移到最上边)
CTRL+w H # (把当前窗口移到最左边)
CTRL+w J # (把当前窗口移到最下边)
CTRL+w L # (把当前窗口移到最右边)
CTRL+w,r # 交换上/下、左/右两个分隔窗口的位置
# 其中2和4两个操作会把窗口改成垂直分割方式.
> - # 调整窗口大小
> + # 调整窗口大小
```

```sh
# 设置对比色彩模板 如 evening, darkblue.vim, torte.vim
# 查看所有模板 ls /usr/share/vim/vim74/colors/
:colorscheme

# vi ~/.vimrc
if &diff
    colorscheme evening
endif
```

#### Mutiple tab

```sh
:n # next file
:N # previous file
:bn # 和 :bp 使用这两个命令来切换下一个或上一个文件
:buffers # 列出所有打开的文件
:ls # 列出所有打开的文件
:bNUMBER # 切换到指定的文件
:e # 打开文件
:split # 打开文件
:vsplit # 垂直打开文件
```

#### vim folder

```sh
# 在 vim 中，按下 :e，然后输入 ..，再按下回车，将打开上层目录的内容，你可以像浏览文件一样浏览目录
:e ..
```

#### vi regular expression 正则表达式

元字符     说明
`.`     匹配任意字符
`[abc]`     匹配方括号中的任意一个字符, 可用-表示字符范围. 如[a-z0-9]匹配小写字母和数字
`[^abc]`     匹配除方括号中字符之外的任意字符
`\d`     匹配阿拉伯数字, 等同于[0-9]
`\D`     匹配阿拉伯数字之外的任意字符, 等同于[^0-9]
`\x`     匹配十六进制数字, 等同于[0-9A-Fa-f]
`\X`     匹配十六进制数字之外的任意字符, 等同于[^0-9A-Fa-f]
`\l`     匹配[a-z]
`\L`     匹配[^a-z]
`\u`     匹配[A-Z]
`\U`     匹配[^A-Z]
`\w`     匹配单词字母, 等同于[0-9A-Za-z_]
`\W`     匹配单词字母之外的任意字符, 等同于[^0-9A-Za-z_]
`\t`     匹配 TAB 字符
`\s`     匹配空白字符, 等同于[\t]
`\S`     匹配非空白字符, 等同于[^\t]

一些普通字符需转义
元字符     说明
`\*`     匹配* 字符
`.`     匹配. 字符
`\/`     匹配 / 字符
`\`     匹配 \ 字符
`\[`     匹配 [ 字符
`\]`     匹配 ] 字符

表示数量的元字符
元字符     说明
`*`     匹配0-任意个
`\+`     匹配1-任意个
`\?`     匹配0-1个
`\{n,m}`     匹配n-m个
`\{n}`     匹配n个
`\{n,}`     匹配n-任意个
`\{,m}`     匹配0-m个

表示位置的元字符
元字符     说明
`$`     匹配行尾
`^`     匹配行首
`\<`     匹配单词词首
`\>`     匹配单词词尾

`\s` space
`\n`,`\r\n` new line
`\t` tab

#### Replace

`/`可以用`#`代替
`:s`, `:&` repeat last :s command
:g/old            查找old, 并打印出现它的每一行
:s/old/new        替换当前行第一个old
:s/old/new/gc    当前行old全替换并需要确认
:n,ms/old/new/g    n,m are the line numbers; n can be (.), which represent current line
:%s/old/new/gc    全文替换,也可用1,$表示从第一行到文本结束
:%s/^ *//gc        去掉所有的行首空格
:g/^\s*$/d    delete the blank lines
:%s/\s\+/,/g    use a substitution (:s///) over each line (%) to replace all (g) continuous whitespace (\s\+) with a comma (,).
`s/.*/\U&/`        replace lower case to upper case, it is the same with `tr [A-Z] [a-z]`, `awk '{print tolower($0)}'`
`s/.*/\L&/`        replace upper case to lower case `awk '{print toupper($0)}'`

提示`replace with hehe (y/n/a/q/l/^E/^Y)?`
`y`替换，`n`不替换，`a`替换所有，`q`放弃，`l`替换第一个并进入插入模式，`^E`和`^Y`是提示你用`Ctrl+e`或`Ctrl+y`来滚动屏幕的

#### 文件名编码转换

`convmv -f srcEncode -t targetEncode [options] file` #linux文件名编码批量转换
转换文件名由GBK为UTF8 :  `convmv -r -f cp936 -t utf8 --notest --nosmart *`

#### 查看文件编码

`file <fileName>`
Vim中查看文件编码 `:set fileencoding`

#### 文件编码转换

1. 在Vim中直接进行转换文件 编码 ,比如将一个文件 转换成utf-8格式 `:set fileencoding=utf-8`
2. enconv 转换文件 编码 , 比如要将一个GBK编码 的文件 转换成UTF-8编码 , 操作如下 `enconv -L zh_CN -x UTF-8 filename`
3. iconv 转换, iconv的命令格式如下: `iconv -f fromEncoding -t toEncoding inputfile -o outputfile`
  比如将一个GBK编码 的文件 转换成 UTF-8 编码 `iconv -f GBK -t UTF-8 file1 -o file2`

### cp

`cp -avx /home/* /mnt/newhome`

功能: 复制文件或目录
说明: cp指令用于复制文件或目录，如同时指定两个以上的文件或目录，且最后的目的地是一个已经存在的目录，则它会把前面指定的所有文件或目录复制到此目录中。若同时指定多个文件或目录，而最后的目的地并非一个已存在的目录，则会出现错误信息
参数:
-a 或 --archive 此参数的效果和同时指定"-dpR"参数相同
-d same as --no-dereference --preserve=links: never follow symbolic links in SOURCE
-p 或 --preserve=mode,ownership,timestamps 保留源文件或目录的属性，包括所有者、所属组、权限与时间
--preserve[=ATTR_LIST] preserve the specified attributes (default: mode,ownership,timestamps), if possible additional attributes: context, links, xattr, all
-R 或 --recursive 递归处理，将指定目录下的文件及子目录一并处理
-v 或 --verbose 显示执行过程
-x 或 --one-file-system 复制的文件或目录存放的文件系统，必须与cp指令执行时所处的文件系统相同，否则不复制，亦不处理位于其他分区的文件

-b 或 --backup 删除、覆盖目的文件先备份，备份的文件或目录亦建立为符号链接，并指向源文件或目录链接的源文件或目录。假如没有加上这个参数，在复制过程中若遇到符号链接，则会直接复制源文件或目录
-f 或 --force 强行复制文件或目录， 不论目的文件或目录是否已经存在
-i 或 --interactive 覆盖文件之前先询问用户
-l 或 --link 对源文件建立硬链接，而非复制文件
-P, --no-dereference never follow symbolic links in SOURCE
-P 或 --parents 保留源文件或目录的路径，此路径可以是绝对路径或相对路径，且目的目录必须已经丰在
-r 递归处理，将指定目录下的文件与子目录一并处理。若源文件或目录的形态，不属于目录或符号链接，则一律视为普通文件处理
-s 或 --symbolic-link 对源文件建立符号链接，而非复制文件
-S <备份字尾字符串> 或 --suffix=<备份字尾字符串> 用"-b"参数备份目的文件后，备份文件的字尾会被加上一个备份字符串。默认的备份字尾符串是符号"~"
-u 或 --update 使用这项参数之后，只会在源文件的修改时间(Modification Time)较目的文件更新时，或是名称相互对应的目的文件并不存在，才复制文件
-V <备份方式> 或 --version-control=<备份方式> 指定当备份文件时，备份文件名的命名方式，有以下3种:
    1.numbered或t, 将使用备份编号，会在字尾加上~1~字符串，其数字编号依次递增
    2.simple或never 将使用简单备份，默认的备份字尾字符串是~, 也可通过-S来指定
    3.existing或nil将使用当前方式，程序会先检查是否存在着备份编号，若有则采用备份编号，若无则采用简单备份
--help 显示在线帮助
--sparse=<使用时机> 设置保存希疏文件的时机
--version 显示版本

示例:

- 复制文件，只有源文件较目的文件的修改时间新时，才复制文件 `cp -u -v file1 file2`
- 采用交互方式将文件file1复制成文件file2 `cp -i file1 file2`
- 将文件file1复制成file2，因为目的文件已经存在，所以指定使用强制复制的模式 `cp -f file1 file2`
- 将目录dir1复制成目录dir2 `cp -R file1 file2`
- 同时将文件file1、file2、file3与目录dir1复制到dir2 `cp -R file1 file2 file3 dir1 dir2`
- 复制时保留文件属性 `cp -p a.txt tmp/`
- 复制时保留文件的目录结构 `cp -P /var/tmp/a.txt ./temp/`
- 复制时产生备份文件 `cp -b a.txt tmp/`
- 复制时产生备份文件，尾标 ~1~格式 `cp -b -V t a.txt /tmp`
- 指定备份文件尾标 `cp -b -S _bak a.txt /tmp`

### rsync

`rsync -Pavz src/ dest` Copy contents of `src/` to destination

- `-a` 等于 `-rlptgoD`
- `-r` 是递归
- `-l` 是链接文件, 意思是拷贝链接文件;
- `-p` 表示保持文件原有权限
- `-t` 保持文件原有时间;
- `-g` 保持文件原有用户组
- `-o` 保持文件原有属主;
- `-D` 相当于块设备文件

- `-z` 传输时压缩;
- `-P` 等于 `--partial --progress`
- `--partial` 保留那些因故没有完全传输的文件
- `--progress` 进度

- `--partial-dir=.rsync-partial`

- `-v` 详细输出信息
- `-c` using checksum (-c) rather than time to detect if the file has changed. (Useful for validating backups)
- `-e, --rsh=COMMAND` choose an alternative remote shell program to use
- `--exclude=PATTERN` PATTERN='*.txt' 表示忽略所有 .txt 文件 This option is a simplified form of the --filter option that specifies an exclude rule and does not allow the full  rule-parsing  syntax  of  normal filter rules.  This is equivalent to specifying -f'- PATTERN'.

Note: The trailing slash (/) on the source directory modifies the behavior of the rsync command.

- If you do not use a trailing slash, the source directory is copied to the destination directory, and then the contents of the directory.
- When you do use the trailing slash, rsync only copies the content of the source without creating an additional directory level.

### less

`less -n -i -S`

- `-i, --ignore-case` Causes searches to ignore case;
- `-n` Suppresses line  numbers
- `-S` Causes lines longer than the screen width to be chopped rather than folded
- `-e, --quit-at-eof` Causes less to automatically exit the second time it reaches end-of-file. 查看多个小文件时使用
- `-xn,... or --tabs=n,...` Sets tab stops.

for `less`, the sequences \(, \), \n, and in some implementations \{, \}, \+, \?, \| and other backslash+alphanumerics have special meanings. You can get away with not quoting $^] in some positions in some implementations.

less `&pattern` is like `grep` in `less`
Display only lines which match the pattern; lines which do not match the pattern are not displayed.  If pattern is empty (if you type `&` immediately followed by ENTER), any filtering is turned off, and all lines are displayed
`&eth[01]`  will display lines containing eth0 or eth1
`&arp.*eth0` will display lines containing arp followed by eth0
`&arp|dns`  will display lines containing arp or dns
`!` can invert any of the above: `&!event`

less config file,

```sh
# create an .lesskey file to set default options
tee -a ~/.lesskey <<EOF
#env
LESS = --tabs=4
EOF

# run lesskey to activate the default options
lesskey
```

### find

```sh
find -L "$HOME/MySymlinkedPath" -name "run*.sh" # traverse symbolic links to find the file [find does not work on symlinked path?](https://unix.stackexchange.com/questions/93857/find-does-not-work-on-symlinked-path)
find . -type f -name "*.log" | xargs grep "ERROR" # 从当前目录开始查找所有扩展名为.log的文本文件, 并找出包含"ERROR"的行
find . -name '*.xml' -o -name '*.java' # matches multiple patterns
# Operators  Operators join together the other items within the expression.
# -o (meaning logical OR)
# -a (meaning logical AND).  Where an operator is missing, -a is assumed
find /data -type f -exec stat -c "%s %n" {} \; | sort -nr | head -n 20 # List size top 20 files recursively
find . -type l -ls # To list all of the symlinks or symbolic links or soft links in a Linux system, run

find /home/admin -size +250000k # 超过250000k的文件，当然+改成-就是小于了

find /home/admin -atime -1  # 1天内访问过的文件
find /home/admin -ctime -1  # 1天内状态改变过的文件
find /home/admin -mtime -1  # 1天内修改过的文件
find /home/admin -amin -1  # 1分钟内访问过的文件
find /home/admin -cmin -1  # 1分钟内状态改变过的文件
find /home/admin -mmin -1  # 1分钟内修改过的文件

+n     # for greater than n,
-n     # for less than n,
n      # for exactly n.
```

examples:

```sh
# 查找固定日期的文件
find . -type f -newermt 2007-06-07 ! -newermt 2007-06-08 # To find all files modified on the 7th of June, 2007
find . -type f -newerat 2008-09-29 ! -newerat 2008-09-30 # To find all files accessed on the 29th of september, 2008
find . -type f -newerct 2008-09-29 ! -newerct 2008-09-30 # files which had their permission changed on the same day, If permissions was not change on the file, 'c' would normally correspond to the creation date

# 查找并删除 30 天前的文件
find /data/backup/postgresql.temp -type f -mtime +30 -exec rm {} \;
find /root/logs/user_center/* -mtime +2 -type f -not -name "*.gz" | xargs gzip # File's data was last modified n*24 hours ago
find . -name "test*" \! -name "*.txt" # start with test and not end with .txt

# 删除.svn文件夹
find . -type d -name ".svn" | xargs rm -rf
find . -name "*.svn" | xargs rm -rf
find . -type d -iname ".svn" -exec rm -rf {} \;

# 删除时排除文件
# delete file except notDelete.txt:
find . -type f -not -name notDelete.txt | xargs rm
ls | grep -v notDelete.txt | xargs rm -r

# 删除时排除文件, 当前目录下其他文件全部删除
rm !(foo|bar)

# 文件个数 count files in directory recursively
find . -type f | wc -l
la -lR | grep "^-" | wc -l

# 文件夹个数 count directories in directory recursively
find -mindepth 1 -type d | wc -l
ls -lR | grep ^d | wc -l

# 多目录重命名文件
for file in $(find . -name sync1.properties) do echo $file; done
for i in $(find . -name sync1.properties); do mv $i $(echo $i | sed 's/sync1.properties$/sync.properties/'); done

# 文件内多字符串替换
# xml 文件格式的内容替换成 properties 的等号格式
# sed -i 's/OLD1/NEW1/g; s/OLD2/NEW2/g; /DOCTYPE properties SYSTEM/d'
find . -name '*.xml' -exec sed -i 's#\"><!\[CDATA\[#=#g; s#\t<entry key=\"##g; s#]]></entry>##g; s#</entry>##g; /<?xml version="1.0" encoding="UTF-8"?>/d; /DOCTYPE properties SYSTEM "http:\/\/java.sun.com\/dtd\/properties.dtd"/d; /<properties>/d; /<\/properties>/d' {} \;

# 查找包含class的jar文件
find . -iname \*.jar | while read JARF; do jar tvf $JARF | grep CaraCustomActionsFacade.class && echo $JARF ; done
find . -iname \*.jar | while read JARF; do /app/java/jdk1.6.0_35/bin/jar tvf $JARF | grep FunctionName.class && echo $JARF ; done

# 文件及文件名乱码处理 删除文件名乱码文件 重命名 rename
# print the index number of each file(文件的i节点) 12345
ls -i
# rm
find . -inum 12345 -print -exec rm {} -r \;
# mv
find . -inum 12345 -exec mv {} NewName \;
# 命令中的"{}"表示find命令找到的文件, 在-exec选项执行mv命令的时候, 会利用按i节点号找到的文件名替换掉"{}"
```

### grep

grep pattern files - 搜索 files 中匹配 pattern 的内容
grep -r pattern dir - 递归搜索 dir 中匹配 pattern 的内容
`-l`    只列出匹配的文件名
`-L`    列出不匹配的文件名
`-w`    匹配整个单词
`-A`, `-B`, `-C`    print context lines
`-i`, --ignore-case不区分大小写地搜索. 默认情况区分大小写,
`-n`, --line-number
`-c`, --count
`-r`, --recursive
`-v`, --invert-match
`-E`, --extended-regexp
`-e`, PATTERN, --regexp=PATTERN
Use PATTERN as the pattern; useful to protect patterns beginning with -.

`grep pattern1 | pattern2 files`    显示匹配 pattern1 或 pattern2 的行
`grep pattern1 files | grep pattern2`    显示既匹配 pattern1 又匹配 pattern2 的行 or `grep  'pattern1.*pattern2' filename`
grep for multiple patterns
    `grep 'word1\|word2\|word3' /path/to/file`
    `grep -E 'word1|word2' *.doc`
    Use single quotes in the pattern: `grep 'pattern*' file1 file2`, `grep 'AB.*DEF'`
    Use extended regular expressions: `egrep 'pattern1|pattern2' *.py`
    Use this syntax on older Unix shells: `grep -e pattern1 -e pattern2 *.pl`
On Linux, you can also type `egrep` instead of `grep -E`

escape double quote with backslash `echo "\"member\":\"time\"" |grep -e "member\""` or with  single quote `echo '"member":"time"' |grep -e 'member"'`
escape square brackets with backslash:   `grep "test\[1]" log.txt`

pgrep 和 pkill
pgrep -l apache2

### sed (Stream Editor)

[Regular Expressions - sed, a stream editor](https://www.gnu.org/software/sed/manual/html_node/Regular-Expressions.html)

[Linux Sed命令详解](https://qianngchn.github.io/wiki/4.html)

```sh
# 多个模式
sed -i 's/OLD1/NEW1/g; s/OLD2/NEW2/g; /DOCTYPE properties SYSTEM/d' file
# 删除行
sed -i '/DELETE_LINE/d' file

# 注释行
# If BBB is at the beginning of the line
sed -i 's/^BBB/#&/' file
# If BBB is in the middle of the line
sed-i  's/^[^#]*BBB/#&/' file

# 从文本内的第一个包含start内容的部分截取直到end为止；
sed -n '/start/,/end/p' file
# 设置为时间，可以用于截取一定时间范围内的日志
sed -n '/2021:09:20:10/,/2021:09:20:39/p' access.log

# 删除行尾空格:
sed -i 's/\s+$//g' filename
# 删除行首多余空格:
sed -i 's/^\s*//g' filename
# 或者
sed -i 's/^ *//g' filename
# 删除沒有內容的空行:
sed -i 's/^$//g' filename
# 删除包含有空格组成的空行:
sed -i 's/^\s*$//g' filename
# 删除以空格或TAB开头到结尾的空行:
sed -i 's/^[ |\t]*$//g' filename
# 替换变量:在正则式中以`\(`和`\)`括起来的正则表达式, 在后面使用的时候可以用`\1`、`\2`等变量来访问`\(`和`\)`中的内容.
# 把文中的所有字符串"abc……xyz"替换为"xyz……abc"可以有下列写法
sed -i 's/abc\(.*\)xyz/xyz\1abc/g' filename
# or
sed -i 's/\(abc\)\(.*\)\(xyz\)/\3\2\1/g' filename
# 把ABC转换为小写
echo "ABC" | sed 's/[A-Z]*/\L&\E/'
# 或
echo "ABC" | sed 's/[A-Z]/\l&/g'
# 把abc转换为大写
echo "abc" | sed 's/[a-z]*/\U&\E/'
# 或
echo "abc" | sed 's/[a-z]/\u&/g'
echo "ab_c" | sed 's/_[a-z]/\u&/g'
echo "ab_c" | sed 's/_[a-z]/\U&\E/g'
# 删除一个以上空格, 用一个空格代替
sed -i 's/[ ] [ ] [ ] */[ ]/g' filename
# 删除行首空格
sed -i 's/^[ ][ ] *//g' filename
# 删除句点后跟两个或更多空格, 代之以一个空格
sed -i 's/\ .[ ][ ] */[ ]/g' filename
# 删除以句点结尾行
sed -i 's/\ . $//g' filename
# 删除包含a b c d的行
sed -i '/abcd/d' filename
# 删除第一个字符
sed -i 's/^ .//g' filename
# 删除紧跟C O L的后三个字母
sed -i 's/COL \ ( . . . \ )//g' filename
# 从路径中删除第一个`\`
sed -i 's/^ \///g' filename
# 删除所有空格并用tab键替代
sed -i 's/[ ]/\t/g' filename
# 删除行首所有tab键
sed -i 's/^\t//g' filename
# 删除所有tab键
sed -i 's/\t//g' filename
```

#### 删除行

Delete first line or header line `sed 'Nd' file` Here N indicates Nth line in a file
Delete last line or footer line or trailer line `sed '$d' file`
Delete particular line `sed '2d' file`
Delete range of lines `sed 'm,nd' file`, e.g. `sed '2,4d' file`
Delete lines other than the first line or header line `sed '1!d' file`
Delete empty lines or blank lines `sed '/^$/d' file`
Delete lines that contain a pattern `sed '/debian/d' file`
Delete lines that begin with specified character `sed '/^u/d' file`

#### 不替换某些行

```ini
# filename message_en.properties
key1">value1
key2=value2
key3=<font color="#6fa5e9">value3</font>
```

替换 "> 为 =，但是包含 font 标签的不替换，因为 font 标签结尾 "> 是正常的 `cat message_en.properties | sed -e '/font/! s/">/=/g'` 解释：`/font/!` 表示不匹配该行

#### 替换多文件中的内容

```sh
# -n 静默替换
find . -name '*.htm' | xargs sed -n '/old/p'
grep -l old *.htm | xargs sed -n "/old/p"

# 也可以使用 s#old#new#g
find . -name '*.htm' | xargs sed -i 's/old/new/g'

# 只修改指定文件，目录使用通配符
sed -i 's#https://git.com/project#git@git.com:project/' */.git/config

# 批量修改文件
sed -i "s#namespace: ns-test#namespace: bj-ns-test#g" $(grep -rl 'namespace: ns-test')

# 把web文件下所有文件中的//old.example.com 替换为 //new.example.com
sed -i 's#//new.example.com#//old.example.com#g' $(grep -rl '//old.example.com' web/*)
```

##### 问题 sed: 1: "/path/to/file.txt": extra characters at the end of l command

Unlike Ubuntu, BSD/macOS requires the extension to be explicitly specified. The workaround is to set an empty string:
`sed -i '' 's/megatron/pony/g' /path/to/file.txt`

#### rename

[linux - Shell/Bash shortcut for bulk renaming of files in a folder - Stack Overflow](https://stackoverflow.com/questions/8416990/shell-bash-shortcut-for-bulk-renaming-of-files-in-a-folder)
[Bash Reference Manual](https://www.gnu.org/software/bash/manual/bash.html#Shell-Parameter-Expansion-1)

```bash
for i in *.txt; do mv "$i" "${i/Pattern/Replacement}"; done

# install perl script rename
rename 's/test-this/REPLACESTRING/g' *
# dry run with -n
rename -n 's/test-this/REPLACESTRING/g' *
```

### awk

#### Common usage 例子

``` bash
# print the process by "root", $1 match root
ps -ef | awk '$1~/root/ && $2>2000 && $2<2060 {printf("%6s owns it, pid is: %5d\n"), $1, $2}' | head

# 合并多行到一行 并去掉最后一个符号 join multiple lines of file names into one with custom delimiter
ls -1 | awk 'ORS=","' | head -c -1
# 或者
ls -1 | paste -sd "," -

# 求和 sum
echo "00:05:42,913 33884 314" | awk '{ len += $2; cost += $3 } END {print len, cost, len/cost}'
# 求TCP重传率
cat /proc/net/snmp | grep Tcp | grep -v RetransSegs | awk '{print $13/$12}'

# query ~/.ssh/config to get aliases in to IP addresses
awk '/Host $youralias/ { print $2; getline; print $2;}' ~/.ssh/config

# Using bash shell function inside AWK: system(cmd) executes cmd and returns its exit status
# download in batch
ossutil ls oss://path/to/202109/02/ | sort -k 2 | awk '$2>"14:28:00" && $2<"14:32:00" {print $8; system("ossutil cp " $8 " .")}'

# url decode with unquote_plus,  url encode with quote_plus
less confluence.ognl.attack.log | python -c "import sys, urllib as ul; [sys.stdout.write(ul.unquote_plus(l)) for l in sys.stdin]" | less

# 文本
2011-10-25 8:41:20
2011-10-25 8:41:38
2011-10-25 18:10:09
2011-10-26 8:29:05
# 取出每天的第一条记录，即去重
awk '!a[$1]++' file
# 解析
# 1. ”!” 即非。
# 2. a[$0]，以$0为数据下标，建立数组a，a[$0]++，即给数组a赋值，a[$0]+=1
# 3. 组合起来，awk 执行!a[$0]++的流程
# 3.1 '!a[$0]++' 当$0的内容首次出现时，a[$0]将为空（相当于0），
# 此时将先求!a[$0]的值（也是整个式子的值，即为非空 true ,将影响后续动作，执行默认的print)
# 3.2 对a[$0]进行+1，a[$0] 加1后为1，当下次出现时a[$0]即不为空，表达式结果为非真 false，即不打印
# 可以使用下面的语句查看执行流程
echo -e "5\n5\n5"|awk '{print ">"a[$0]+0}!a[$0]++{print $0}'


#统计相同的日期的个数
awk '{a[$1]++}END{for(i in a)print i,a[i]}' file

# 同时筛选 8 点的数据($2==8)的限制条件, | 表示同时使用两个分隔符
awk -F ' |:' '!a[$1]++&&($2==8)' file

#取每天的最后一条记录
awk '!a[$1]++ && i {print i} {i=$0} END {print i}' file
awk 'NR>1{if($1!=x)print y}{x=$1;y=$0}END{print $0}' file
# 取最后一条只需取首次出现的上面那条即可,通过{i=$0}将$0赋给i,!a[$1]++限制首次出现,
# 首行i为空,会打印一个空行,加个&&i来保证不打印那个空行,最后必须要有END{print i},
# 最后一行要单独打印
# {i=$0}保存上一行的记录是常规用法。
# if($1!=x)print y}{x=$1;y=$0} 保存$1 $0
#加个($2==18)的条件
awk -F ' |:' '!a[$1]++&&i{print i}{if($2==18)i=$0}END{print i}' file
```

#### awk 日志解析

```bash
# tomcat localhost_access_log filter with http status code
awk '$9!~200 && $9!~302 && $9!~304 && $9!~403'

# 按时间区间查询:
awk '{if ($1>startTime && $1<endTime) {print $0}}' startTime="2016-09-18T10:37:23" endTime="2016-09-18T10:37:37" awkTime.log
awk '$1>=startTime && $1<=endTime' startTime="2016-09-18T10:37:23" endTime="2016-09-18T10:37:37" awkTime.log

# 解析日志 将每个IP访问的页面数进行从小到大排序：
awk '{++S[$1]} END {for (a in S) print S[a],a}' log_file | sort -n
# 文件流量统计
cat /www/logs/access.2011-08-03.log |awk '{sum[$7]+=$10}END{for(i in sum){print sum[i],i}}'|sort -rn|more

# 查出运行速度最慢的脚本
grep -v 0$ access.2010-11-05.log | awk -F '\" ' '{print $4" " $1}' web.log | awk '{print $1" "$8}' | sort -n -k 1 -r | uniq > /tmp/slow_url.txt

# 刪除一个月前的日志
rm -f /www/logs/access.log.$(date -d '-1 month' +'%Y-%m')*
```

#### awk 16进制转换

```bash
echo "D0490012475E" | awk '{
    p0=("0x" $1);
    p1=(substr($1,1,2) ":" substr($1,3,2) ":" substr($1,5,2) ":" substr($1,7,2) ":" substr($1,9,2) ":" substr($1,11,2))
    printf "insert into device (mac,macHex,deviceId,area,createTime) values (%d,\"%s\",9,0,now()) \n", p0,p1;
    }'
# hex 转成 decimal 实际利用的是`printf :  printf %d "0x109e3a022559"`
# decimal 转成 hex: `printf "%x\n" 18271764096345`
```

#### awk 语法

awk扫描filename中的每一行, 对符合模式pattern的行执行操作action.
语法格式 `awk 'pattern {action}' filename`
    `awk 'pattern' filename`   显示所有符合模式pattern的行
    `awk '{action}' filename`   对所有行执行操作action
    `awk '{action}'`           从命令行输入数据
    `awk '/search pattern1/ {Actions} /search pattern2/ {Actions}' file`
awk还支持命令文件 `awk -f awk_file data_file`
`awk -v RS="?" filename`

Initialization and Final Action

``` bash
Syntax:
BEGIN { Actions}
{ACTION} # Action for everyline in a file
END { Actions }

# is for comments in Awk
```

example:

``` bash
$ awk 'BEGIN {print "Name\tDesignation\tDepartment\tSalary";}
> {print $2,"\t",$3,"\t",$4,"\t",$NF;}
> END{print "Report Generated\n--------------";
> }' employee.txt
Name    Designation    Department    Salary
Thomas      Manager      Sales              $5,000
Jason      Developer      Technology      $5,500
Sanjay      Sysadmin      Technology      $7,000
Nisha      Manager      Marketing      $9,500
Randy      DBA           Technology      $6,000
Report Generated
--------------
```

#### awk 变量

内建的字段变量
$0 一字符串, 其内容为目前 awk 所读入的数据行.
$1 $0上第一个字段的数据
$2 $0上第二个字段的数据
`awk 'pattern' '{print}'` or `awk 'pattern' '{print $0}'`    print the whole line matched the pattern

内建变量(Built-in Variables)
`NF` (Number of Fields)     整数, 其值表$0上所存在的字段数目
`NR` (Number of Records)    整数, 其值表awk已读入的数据行数目
`FILENAME`                awk正在处理的数据文件文件名
`FS` (Field Separator)    FS default as space and tab. `FS="\n"` take "\n" as separator, `-F \t` take tab as separator，可以使用 `|` 来同时使用多个分隔符
`RS` (Record Separator)    awk根据 RS 把输入分成多个Records,一次读入一个Record进行处理,预设值是 "\n". RS = "" 表示以 空白行 来分隔相邻的Records.
`ORS` gets appended after every line that gets output

`awk -F \" '{print $1, $2}'` 以"为分隔符处理每一个Records
`awk -F '[= ]'` 同时以=和空格作为分隔符
`awk -F '[\\[\\]]'` 和 `awk -F "[\\\[\\\]]"` 转义 `[`和`]` 同时以这两个字符作为分隔符
`echo "a (b (c" | awk -F " \\\(" '{ print $1; print $2; print $3 }'`: To use ( (space+parenthesis) as field separator in awk, use " \\\("`

```sh
# NF
# 按逗号分割字段输出成行, 来查看需要打印的行数 print each field number
ps -ef | head -n 2 | awk '{for (i=1;i<=NF;i++) {printf("%2d: %s\n"), i, $i}}'
# Print every line that has at least one field
awk 'NF > 0' data

# NR
# 输出第三行以后的行
awk -F ':' 'NR >3 {print $1}' demo.txt
# 引入内建变量 `NR` 保留表头
awk '$6=="TIME_WAIT" || NR==1 ' netstat.txt

# RS
#按空白行切分文件成Records
awk -v RS=""
# 以`),(`为每行的记录分隔符, 以`'`切分记录, 用于SQL文件
awk -v RS='\),\(' -F "'" '{print $2}'
# CentOS 以`),(`为每行的记录分隔符, 以`'`切分记录, 用于SQL文件
awk -v RS='\\),\\(' -F "'" '{print $2}'

# ORS
# 合并多行到一行 并去掉最后一个符号 join multiple lines of file names into one with custom delimiter
ls -1 | awk 'ORS=","' | head -c -1
```

#### awk escape

awk escape single quote: `watch -n 1 -d 'ls -l | awk '\''{print $9}'\'''` is same as `watch -n 1 -d 'ls -l | awk "{print \$9}"'`
 with `'\''` you close the opening `'`, then print a literal `'` by escaping it and finally open the ' again.
escape square brackets: Brackets `[` need double escape `\\`: `\\[`

awk escape double quote: `"\""

```sh
# escape $, the $ is preceded by a \ to prevent $1 from being expanded by the shell.
alias aprint='awk "{print \$1}"'

# awk escape double quote: `"\""`
# [Print double quotes in unix Awk](http://www.unixcl.com/2012/07/print-double-quotes-in-unix-awk.html)
cat file.txt
# 6289693505455 Plan_DAIL_30D_AA
awk '{print $2,"\""$1"\""}' file.txt
# Plan_DAIL_30D_AA "6289693505455"

#Assigning the quotes sequence to a variable x
$ awk -v x="\"" '{print $2,x$1x}' file.txt
#Using octal code of double quotes
$ awk '{print $2,"\042"$1"\042"}' file.txt
#Using ASCII code of double quotes
$ awk '{print $2,"\x22"$1"\x22"}'  file.txt
```

#### awk的工作流程

Pattern 一般常使用 "关系表达式"(Relational expression) 来当成 Pattern
Actions 是由许多awk指令构成. 而awk的指令与 C 语言中的指令十分类似.
例如: awk的 I/O指令 : print, printf( ),
    getline var < file 一次读取一行 变量 var(var省略时,表示置于$0)
     awk的 流程控制指令 : if(...){..} else{..}, while(...){...}...

awk 如何处理 Pattern { Actions } ?
awk 会先Evaluate该 Pattern 的值, 若 Pattern 判断后的值为true (或不为0的数字,或不是空的字符串), 则 awk将执行该 Pattern 所对应的 Actions.反之, 若 Pattern 之值不为 true, 则awk将不执行该 Pattern所对应的 Actions.

执行awk时, 它会反复进行下列四步骤.

自动从指定的数据文件中读取一个数据行.
自动更新(Update)相关的内建变量之值. 如 : NF, NR, $0...
依次执行程序中 所有 的 Pattern { Actions } 指令.
当执行完程序中所有 Pattern { Actions } 时, 若数据文件中还有未读取的数据, 则反复执行步骤1到步骤4.

awk会自动重复进行上述4个步骤, 使用者不须于程序中编写这个循环 (Loop).

#### Pattern

awk 中提供下列 关系运算符(Relation Operator)

运算符 含意
`>` 大于
`<` 小于
`>=` 大于或等于
`<=` 小于或等于
`==` 等于
`!=` 不等于
`%` 求余
`~` match 包含
`!~` not match
上列关系运算符除`~`(match)与`!~`(not match)外与 C 语言中之含意一致.

(match)`~` 与`!~`(match) 如下 :
A为字符串, B为正则表达式.
`A ~B` 判断 字符串A 中是否 包含 能匹配(match)B式样的子字符串.
`A !~B` 判断 字符串A 中是否 未包含 能匹配(match)B式样的子字符串.
`.`    通配符, 代表任意个字符
`||` or, `&&` and, `!` not

例如

- `$0 ~ /program[0-9]+\.c/ { print $0 }`
- `$0 ~ /program[0-9]+\.c/` 用来判断`$0`(数据行)中是否含有可 match `/program[0-9]+\.c/` 的子字符串, 若`$0`中含有该类字符串, 则执行 print (打印该行数据).
- `awk '$5 ~ /ldb/ {print}' f.txt` #第五列包含 ldb
- `w | awk '/pts\/0/ {print $1}'`    print who is on the TTY pts/0
- `awk '/ldb/ && !/LISTEN/ {print}' f.txt`   #匹配ldb和不匹配LISTEN
- `awk '$3==0 && $6=="LISTEN" ' netstat.txt` 过滤记录
- `awk '$3==0 && $6=="TIME_WAIT" || NR==1 ' netstat.txt` 保留表头 引入内建变量NR

当Pattern 中被用来比对的字符串为`$0`时, 可省略`$0`, 故本例的 Pattern 部分`$0 ~/program[0-9]+\.c/` 可仅用`/program[0-9]+\.c/`表示(有关匹配及正则表达式请参考 附录 E )

#### Actions

Actions 是由下列指令(statement)所组成 :
表达式 ( function calls, assignments..)
print 表达式列表
printf( 格式化字符串, 表达式列表)
if( 表达式 ) 语句 [else 语句]
while( 表达式 ) 语句
do 语句 while( 表达式)
for( 表达式; 表达式; 表达式) 语句
for( variable in array) 语句
delete
break
continue
next
exit [表达式]
语句

awk 中大部分指令与 C 语言中的用法一致
例子: [awk-conditional-statements](http://www.thegeekstuff.com/2010/02/awk-conditional-statements)

1. Awk If Else

    awk '{
    if ($3 >=35 && $4 >= 35 && $5 >= 35)
        print $0,"=>","Pass";
    else
        print $0,"=>","Fail";
    }' student-marks

2. Awk If Else If

    ``` bash

        $ cat grade.awk
        {
        total=$3+$4+$5;
        avg=total/3;
        if ( avg >= 90 ) grade="A";
        else if ( avg >= 80) grade ="B";
        else if (avg >= 70) grade ="C";
        else grade="D";

        print $0,"=>",grade;
        }
        $ awk -f grade.awk student-marks
        Jones 2143 78 84 77 => C
        Gondrol 2321 56 58 45 => D
    ```

3. Awk Ternary ( ?: )

``` bash

    $ awk 'ORS=NR%3?",":"\n"' student-marks
    Jones 2143 78 84 77,Gondrol 2321 56 58 45,RinRao 2122 38 37
    Edwin 2537 87 97 95,Dayan 2415 30 47,
```

#### awk 的内建函数(Built-in Functions)

1. index( 原字串, 找寻的子字串 )
2. length( 字串 ) : 返回该字串的长度
3. match( 原字串, 用以找寻比对的正则表达式 ):
4. split( 原字串, 数组名称, 分隔字符 ):
5. sprintf(格式字符串, 项1, 项2, ...)
6. sub( 比对用的正则表达式, 将替换的新字串, 原字串 )
7. substr( 字串,起始位置 [,长度] )    返回从起始位置起,指定长度的子字串. 若未指定长度,则返回起始位置到字串末尾的子字串.

### xargs 工具的经典用法示例

``` bash
find some-file-criteria some-file-path | xargs some-great-command-that-needs-filename-arguments
kill -9 `ps -ef |grep GA | grep -v grep | awk '{print $2}'`
kill $(ps -aef | grep java | grep apache-tomcat-7.0.27 | awk '{print $2}')
kill -9 `netstat -ap |grep 6800 |awk '{print $7}'|awk -F "/" '{print $1}'`

find . -size +1M | xargs -I {} rm "{}"

find . -name "*Conflict*" | xargs -I {} trash "{}"
find . -print0 -name "*conflict*" | xargs -I {} trash {}
```

`-L` Use at most max-lines nonblank input  lines  per  command  line.  每行使用的非空字符串最大个数
`-0`      Change xargs to expect NUL (``\0'') characters as separators, instead of spaces and newlines.  This is expected to be used in concert with the -print0 function in find(1).

控制每行参数个数`-L`和最大并行数`-P`. 如果你不确定它们是否会按你想的那样工作, 先使用 xargs echo 查看一下. 此外, 使用 `-I {}` 会很方便. 例如:

`find . -name '*.py' | xargs grep some_function`
`cat hosts | xargs -I {} ssh root@{} hostname`

execute `echo 2` 5 times: `seq 5 | xargs -I@ -n1 echo 2`
`find /root/logs/user_center/* -mtime +2 -type f | xargs gzip`

replace: `seq 3| xargs -I % echo http://example.com/persons/%.tar`

两个变量 `echo {1..8} | xargs -n2 sh -c 'echo "the number $1 comes before $2"' sh`

### kill

refer to [what-does-kill-0-do](https://unix.stackexchange.com/questions/169898/what-does-kill-0-do)
> man 2 kill
...
If sig is 0, then no signal is sent, but error checking is still performed; this can be used to check for the existence of a process ID or process group ID.

So signal 0 will not actually in fact send anything to your process's PID, but will in fact check whether you have permissions to do so.

``` bash

#!/bin/bash

PID=$(pgrep sleep)
if ! kill -0 $PID 2>/dev/null; then
    echo "you don't have permissions to kill PID:$PID"
    exit 1
fi

kill -9 $PID
```

### date

```sh
date --help

# Get Unix time stamp 1685455706
date +%s
# Convert Unix timestamp to Date Tue May 30 22:08:26 CST 2023
date -d @1685455706
# Convert Date to Unix timestamp 1685455706
date -d 'Tue May 30 22:08:26 CST 2023' +%s
date -d '2023-05-30 22:08:26' +%s

# 20161031_19
date -d '1 hours ago' "+%Y%m%d_%H"
# 2016-11-01
date -d '1 days ago' "+%F"
date -d now "+%Y%m%d %H:%M:%S"
# 20161031191653.792204176
date +%Y%m%d%H%M%S.%N

# for --rfc-2822 format which displays correct offset
date -R

TZ=Asia/Shanghai date -R
# > Wed, 30 Aug 2017 13:58:05 +0800
TZ=UTC-8 date -R
# > Wed, 30 Aug 2017 13:58:32 +0800
TZ=UTC date -R
# > Wed, 30 Aug 2017 05:58:36 +0000
TZ=UTC+8 date -R
# > Tue, 29 Aug 2017 21:58:33 -0800
```

设置时区

Valid timezones are defined in `/usr/share/zoneinfo/`
`man timezone`
>The offset is positive if the local timezone is west of the Prime Meridian and negative if it is east

example: timezone `UTC+0800` is `TZ=UTC-8` or `TZ=Asia/Shanghai`

```sh
# Display Current Date and Time with timedatectl
timedatectl
# 列出支持的时区
timedatectl list-timezones | grep keyword
# 设置时区
timedatectl set-timezone Asia/Shanghai
# Set Universal Time (UTC) in Ubuntu
timedatectl set-timezone UTC
```

### crontab

To create a cronjob, just edit the crontab file: `crontab -e`.
It uses `/bin/sh`
`-l` 列出crontab文件
`-e` 编辑当前的crontab文件
`-r` 删除当前的crontab文件

crontab filename 以filename做为crontab的任务列表文件并载入

crontab task back up `* */1 * * * /usr/bin/crontab -l > /data/configurations/crontab.txt 2>&1`

crontab特殊的符号说明

1. "*"代表所有的取值范围内的数字
2. "/"代表每的意思, 如"*/5"表示每5个单位
3. "-"代表从某个数字到某个数字
4. ","分散的数字
5. Percent-signs (%) requires escaped with backslash (\)

``` bash

Graphically:

┌────────── minute (0 - 59)
│ ┌──────── hour (0 - 23)
│ │ ┌────── day of month (1 - 31)
│ │ │ ┌──── month (1 - 12)
│ │ │ │ ┌── day of week (0 - 6 => Sunday - Saturday, or
│ │ │ │ │                1 - 7 => Monday - Sunday)
↓ ↓ ↓ ↓ ↓
* * * * * command to be executed

MAILTO=username@example.org
# 如果不能发送邮件，设置邮箱为空, 避免 /var/spool/postfix/ldrop 下面有很多文件
MAILTO='"'
PATH=/data/software/pgsql-16.3/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin
5 0 * * * sh /data/projects/account/cronjob.sh >> /data/projects/account/cronjob.log 2>&1
# 查找并删除 30 天前的文件
0 2 * * * find /data/backup/postgresql.temp -type f -mtime +3 | xargs gzip
0 3 * * * /data/backup/postgresql.temp -type f -mtime +30 -exec rm {} \;

1 1 1 * * /usr/bin/docker exec jenkins-docker sh -c "docker image rm \$(docker image ls --format '{{.Repository}}:{{.Tag}}')" >> /var/log/docker_image_cleanup.log 2>&1
```

log path: `/var/log/messages` or `/var/log/cron*`, `/var/mail/$USER` on Mac

环境变量

1. 脚本中涉及文件路径时全部写绝对路径
2. 在第一行设置 PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin:/data/software/jdk1.8.0_202/bin
   1. 设置前先获取默认值 `* * * * * env > /data/logs/crontab/env.cron.txt 2>&1`
3. 在crontab 脚本行 加入`source /etc/profile;`
4. 脚本执行要用到java或其他环境变量时，通过source命令引入环境变量  `source $HOME/.bash_profile`

`10 1 * * 6,0 /usr/local/etc/rc.d/lighttpd restart` 表示每周六、周日的1 : 10重启lighttpd
`* */1 * * * /usr/local/etc/rc.d/lighttpd restart` 每一小时重启lighttpd
`* 23-7/1 * * * /usr/local/etc/rc.d/lighttpd restart` 晚上11点到早上7点之间，每隔一小时重启lighttpd
`0 11 4 * mon-wed /usr/local/etc/rc.d/lighttpd restart` 每月的4号与每周一到周三的11点重启lighttpd
Question mark (?)
    In some implementations, used instead of '*' for leaving either day-of-month or day-of-week blank. Other cron implementations substitute "?" with the start-up time of the cron daemon, so that ? ? `* * * * would be updated to 25 8 * * * *` if cron started-up on 8:25am, and would run at this time every day until restarted again.[20]

Slash (/)
Note that frequencies in general cannot be expressed; only step values which evenly divide their range express accurate frequencies (for minutes and seconds, that's /2, /3, /4, /5, /6, /10, /12, /15, /20 and /30 because 60 is evenly divisible by those numbers; for hours, that's /2, /3, /4, /6, /8 and /12); all other possible "steps" and all other fields yield inconsistent "short" periods at the end of the time-unit before it "resets" to the next minute, second, or day; for example, entering */5 for the day field sometimes executes after 1, 2, or 3 days, depending on the month and leap year; this is because cron is stateless (it does not remember the time of the last execution nor count the difference between it and now, required for accurate frequency counting—instead, cron is a mere pattern-matcher).

当手动执行脚本OK，但是crontab死活不执行时。这时必须大胆怀疑是环境变量惹的祸，并可以尝试在crontab中直接引入环境变量解决问题。如：
`0 * * * * . /etc/profile; sh /path/to/script.sh`

发现Ubuntu下没有自动打开cron的日志服务功能, 解决方法如下
cron的日志功能使用syslogd服务, 不同版本linux可能装了不同的软件, 这里介绍常见的两种:
sysklogd

1. 编辑 /etc/syslog.conf, 并且打开以cron.*开始的那行注释.
2. 运行 /etc/init.d/sysklogd restart .
3. 运行 /etc/init.d/cron restart .

rsyslog

1. 修改rsyslog文件, 将/etc/rsyslog.d/50-default.conf 文件中的#cron.*前的#删掉;
2. 重启rsyslog服务service rsyslog restart
3. 重启cron服务service cron restart

`(crontab -l ; echo "00 09 * * 1-5 echo hello") | crontab -`  [How to create a cron job using Bash](https://stackoverflow.com/questions/878600/how-to-create-a-cron-job-using-bash )

`at` want a command to run once at a later date, `at 4:01pm`
If you want a command to be run once at system boot, the correct solution is to use either

- system RC scripts (/etc/rc.local)
- crontab with the `@reboot` special prefix (see manpage)

#### [Unable to run a service command via cron - Stack Overflow](https://stackoverflow.com/questions/8127433/unable-to-run-a-service-command-via-cron)

Failed with `service service_name start`

sbin is not in the path when run via cron. Specify the full path to service. This is probably either `/sbin/service` or `/usr/sbin/service`. You can find the path on your system by running `which service`.

### logrotate

`man logrotate`

在/etc/logrotate.d/ 文件夹下, 新建nginx文件 内容如下
`logrotate -d /etc/logrotate.d/nginx` 测试, 不会真的切割文件
`logrotate -vf /etc/logrotate.d/nginx` 手动切割文件

`rpm -ql logrotate` 查看logrotate的配置文件

``` bash

/path/to/nginx/access.log
/path/to/other/*.log
{
    daily
    # rotate 7: 一次将存储7个归档日志。对于第8个归档，时间最久的归档将被删除。
    rotate 7
    # missingok 在日志轮循期间，任何错误将被忽略，例如“文件无法找到”之类的错误
    missingok
    # dateext 使用日期作为命名格式
    dateext
    # compress 在轮循任务完成后，已轮循的归档将使用gzip进行压缩
    compress
    # nocompress 如果你不希望对日志文件进行压缩，设置这个参数即可
    # delaycompress: 总是与compress选项一起用，delaycompress选项指示logrotate不要将最近的归档压缩，压缩将在下一次轮循周期进行。这在你或任何软件仍然需要读取最新归档时很有用
    delaycompress
    # copytruncate Truncate the original log file in place after creating a copy, instead of moving the old log file and optionally creating a new one.
    copytruncate
    # notifempty 如果日志文件为空，轮循不会进行
    notifempty
    # sharedscripts 表示postrotate脚本在压缩了日志之后只执行一次
    sharedscripts
    postrotate
        [ -e /usr/local/nginx/logs/nginx.pid ] && kill -USR1 `cat /usr/local/nginx/logs/nginx.pid`
    endscript
}
```

[Nginx Log Rotation](https://www.nginx.com/resources/wiki/start/topics/examples/logrotation/)

### zip jar tar

#### zip

`unzip project.war WEB-INF/lib/project.jar` only unzip the jar from the war

- `-q` perform operations quietly
- `-l` lists the contents of a ZIP archive to ensure your file is inside.
- `-c` Use the -c option to write the contents of named files to stdout (screen) without having to uncompress the entire archive.

examples:

- 防止linux下文件解压乱码 `unzip -O cp936`
- update zip file `zip -u project.war WEB-INF/lib/jaxen-core.jar`
- delete file in zip `zip -d project.war WEB-INF/lib/jaxen-core.jar`

Find a file in lots of zip files: `for f in *.zip; do echo "$f: "; unzip -c $f | grep -i <pattern>; done`
`zless`,`zipgrep`,`zgrep`,`zcat`

#### tar

- `-r` specifies that you want to append files to the archive,
- `-v` enables verbose output for tracking progress
- `-f` specifies the name of the tar archive
- `--delete` option is used to delete a file from an archive

`tar -tf filename.tar.gz`    List files inside the tar.gz file
`tar -rvf existingTar.tar new1.txt new2.txt` Adding Files to a Tar Archive
`tar --delete -f tecmint.tar ravi1.txt ravi3.txt` Deleting Files from a Tar Archive
`vim filename.tar.gz` List files and open file inside it with `Enter`
`tar -jxvf firefox-37.0.2.tar.bz2 -C /opt/` -C 选项提取文件到指定目录
`-exclude path/to/exclude` exclude files

`GZIP=-9 tar cvfz path/to/folder` 指定压缩比率

Extract multiple .tar.gz files with a single tar call
`ls *.tar | xargs -i tar xf {}` or `cat *.tar | tar -xvf - -i`
The `-i` option ignores the EOF at the end of the tar archives, from the man page:
`-i, --ignore-zeros` ignore blocks of zeros in archive (normally mean EOF)

`tar --exclude /path/to/logs --exclude path/to/temp -zcv target.tgz source` 排除文件夹或者文件

#### jar

- list files without extracting `jar tvf <filename>.jar`
- extract files in the jar `jar xvf <jar name>.jar [class name]`
- update files `jar xvf package.jar com/vdm/Method.class`

- add file with folder path `cd C:\sp\Workspace\packager4p5\bin\classes; jar uvf C:\package.jar com\vdm\Method.class com\vdm\UtilsG.class`
- add file without backup folder path into jar `jar uvf C:\package.jar -C backup file`

`java -Dlog4j.configuration=file:log4j.xml  -classpath .;jdom.jar;jPDFNotesS.jar com.PDFFrame`  (linux 下用 :)
java命令引入jar时可以-cp参数, 但-cp不能用通配符(JDK 5中多个jar时要一个个写,不能*.jar), 通常的jar都在同一目录, 且多于1个
如: java -Djava.ext.dirs=lib MyClass

```sh
# 创建 MANIFEST.MF 文件
tee MANIFEST.MF << EOF
Manifest-Version: 1.0
Created-By: Maven JAR Plugin 3.4.1
Build-Jdk-Spec: 21
Main-Class: org.springframework.boot.loader.JarLauncher
Start-Class: com.ruoyi.RuoYiApplication
Spring-Boot-Version: 2.5.15
Spring-Boot-Classes: BOOT-INF/classes/
Spring-Boot-Lib: BOOT-INF/lib/
Spring-Boot-Classpath-Index: BOOT-INF/classpath.idx
Spring-Boot-Layers-Index: BOOT-INF/layers.idx
EOF

# 打包您的类文件和资源，并指定清单文件
# cvfm 是 jar 命令的选项，分别代表 create（创建）、verbose（详细模式）、file manifest（指定清单文件）和 metadata（包含清单文件中的元数据）
# -C bin/ 指定了类文件的目录，最后的点 . 表示包含当前目录下的所有文件。
jar cvfm yourapp.jar MANIFEST.MF -C bin/ .

# 验证 JAR 文件是否正确设置了主清单属性
# -c 打印到控制台 不解压缩为文件
unzip -c yourapp.jar META-INF/MANIFEST.MF
```

### sort, uniq and cut

`sort` `-t` 设定间隔符 `-k` 指定列数
`sort [-fbMnrtuk] [file or stdin]`

- `-n`: 使用『纯数字』进行排序(默认是以文字型态来排序的);
- `-r`: 反向排序;
- `-t`: 分隔符, 默认是用 [tab] 键来分隔;
- `-k`: 排序区间 (field), 可以多个，表示多字段排序

示例:

- `/etc/passwd` 内容是以 `:` 来分隔的, 以第三栏来排序 `cat /etc/passwd | sort -t ':' -k 3`
- 默认是以字符串来排序的, 如果想要使用数字倒序排序 `cat /etc/passwd | sort -t ':' -k 3nr`
- 如果要对`/etc/passwd`,先以第六个域的第2个字符到第4个字符进行正向排序, 再基于第一个域进行反向排序 `cat /etc/passwd |  sort -t':' -k 6.2,6.4 -k 1r`

`uniq [-icu]`
uniq 去除排序过的文件中的重复行, 因此uniq经常和sort合用. 也就是说, 为了使uniq起作用, 所有的重复行必须是相邻的.

- `-i`  : 忽略大小写字符的不同;
- `-c`  : 进行计数
- `-u`  : 只显示唯一的行

Sample:
删除交集，不同的部分放到一个新文件中    `cat list.txt list.txt.old | sort | uniq -u > list.txt.new`
取出两个文件的并集,重复的行只保留一份    `cat file1 file2 | sort | uniq > file3`
取出两个文件的交集,只留下同时存在于两个文件中的文件    `cat file1 file2 | sort | uniq -d >file3`

cut命令可以从一个文本文件或者文本流中提取文本列
`cut -d '分隔字符' -f fields` 用于有特定分隔字符

- `-d`  : 后面接分隔字符. 与 -f 一起使用;
- `-f`  : 依据 -d 的分隔字符将一段信息分割成为数段, 用 -f 取出第几段的意思;
- `-c`  : 以字符 (characters) 的单位取出固定字符区间;

操作PATH变量

- 找出第五个路径 `echo $PATH | cut -d ':' -f 5`
- 找出第三和第五个路径 `echo $PATH | cut -d ':' -f 3,5`
- 找出第三到最后一个路径 `echo $PATH | cut -d ':' -f 3-`
- 找出第一到第三个路径 `echo $PATH | cut -d ':' -f 1-3`
- 找出第一到第三, 还有第五个路径 `echo $PATH | cut -d ':' -f 1-3,5`

### tr 合并换行 多行变一行

concatenate multiple lines of output to one line (merge) `grep pattern file | tr '\n' ' '`
Upper case to lower case  `tr [A-Z] [a-z]`
Remove all the space characters in a string `echo "A5 0a D0 49 00 01 02 03  01 30" | tr -d " "`

### curl

查看网页源码 `curl www.sina.com`
保存网页`curl -o [文件名] www.sina.com`
自动跳转重定向 `curl -L www.sina.com`

显示http header, 显示http response的头信息, 连同网页代码一起 `curl -i www.sina.com`, `-I`参数则是只显示http response的头信息.

#### curl option

- `-o, --output /path/to/file`    Write output to filex` instead of stdout
- `-i, --include`    (HTTP)  Include  the  HTTP-header in the output
- `-I, --head`    Fetch the HTTP-header only!
- `-L, --location`    Follow redirects
- `-v, --verbose`    Makes the fetching more  verbose/talkative
- `--trace <file>`    Enables  a  full  trace  dump of all incoming and outgoing data
- `-X, --request <command>`    Specifies a custom request method curl默认的HTTP动词是GET, 使用`-X`参数可以支持其他动词
- `-s, --silent`    Silent  or  quiet  mode. Don't show progress meter or error messages.  Makes Curl mute. It will still output the data  you  ask for
- `--cookie "key1=value1;k2=v2"` Pass cookie
- `-H, --header`    Sent with header `-H "host:login.example.com" -H "Content-Type: application/json"`
- `-u, --USER`    username:password
- `-w, --write-out "@curl-format.txt"`    tells cURL to use our format file
- `-m, --max-time <seconds>`    超时时间. Maximum time in seconds that you allow the whole operation to  take.
- `-F, --form`  `-F "filename=@file.tar.gz"` 上传文件
- `-G, --get`  make all data specified with -d, --data, --data-binary or --data-urlencode to be used in an HTTP GET request instead of the POST request that otherwise would be used. The data will be appended to the URL with a '?' separator.
- `--data-urlencode <data>` (HTTP) This posts data, similar to the other -d, --data options with the exception that this performs URL-encoding.
- `-x` use proxy `curl -x http://127.0.0.1:1087 -Lv https://www.google.com`
- `-C/--continue-at <offset>` Continue/Resume a previous file transfer at the given offset. Use `-C -` to tell curl to automatically find out where/how to resume the transfer.
- Change user agent
  - `curl -A "user-agent-name-here" url`
  - `curl --user-agent "user-agent-name-here" url`
  - `curl -H "User-Agent: user-Agent-Name-Here"`

#### Sample

- 显示通信过程  `curl -v www.sina.com`
- 更详细的信息 `curl --trace output.txt www.sina.com` or `curl --trace-ascii output.txt www.sina.com`
- HTTP动词 curl默认的HTTP动词是GET, 使用`-X`参数可以支持其他动词.
    `curl -X POST www.example.com` `curl -X DELETE www.example.com`
- HTTP认证    `curl --user name:password example.com`
- 跨域请求 CORS: `curl -I -X GET -H "Origin: http://www.example.com" "https://api2.example.com/v1/getIp`
- socks5 proxy `curl -v https://ww.example.com --socks5-hostname localhost:7070`
- 上传文件 `curl -F "key=value" -F "filename1=@file1.tar.gz -F "filename1=@file1.tar.gz" http://localhost/upload`
- 上传文件数组 `curl -F "key=value" -F "files[]=@file1.tar.gz -F "files[]=@file1.tar.gz" http://localhost/upload`
- `curl -G`

```bash
curl -G \
    --data-urlencode "p1=value 1" \
    --data-urlencode "p2=value 2" \
    http://example.com
    # http://example.com?p1=value%201&p2=value%202
```

##### 分段下载

- download part 1  `curl --header "range:bytes=0-99" -o file.part1 -L URL` or `curl --range 0-99 URL`
- down load part 2  `curl --header "range:bytes=100-" -o file.part2 -L URL` or `curl --range 100-`
- `cat file.part* > file`  merge to one file

##### POST application/x-www-form-urlencoded 提交表单并设置header

`curl -X POST --header "Content-Type: application/x-www-form-urlencoded" --data  "username=name&token=value" https://login.test.com/account/update`

`-F/--form <name=content> Specify HTTP multipart POST data` e.g. `--form "file=@/path/to/file"`

##### POST application/json

`curl -d '{"key1":"value1", "key2":"value2"}' -H "Content-Type: application/json" -X POST http://localhost:3000/data`

##### POST body with variable

[json - Using curl POST with variables defined in bash script functions - Stack Overflow](https://stackoverflow.com/questions/17029902/using-curl-post-with-variables-defined-in-bash-script-functions)

```sh
# 字符串$name 使用 "'" 来转义
# 数字 $age 使用 ' 来转义
export name="20220916161114CA35C0"
curl -X POST http://localhost:3000/data --header 'Content-Type:application/json' -d '{"name":"'"$name"'", "age": '$age'}'
```

##### Print request time detail

``` bash
curl -so /dev/null -w "namelookup: %{time_namelookup} tcp: %{time_connect} ssl: %{time_appconnect}  pretransfer: %{time_pretransfer} redirect: %{time_redirect} starttransfer: %{time_starttransfer} total: %{time_total}\n" https://www.baidu.com

# Print 5 times
seq 5 | xargs -I@ -n1 curl -w "namelookup: %{time_namelookup} tcp: %{time_connect} ssl: %{time_appconnect}  pretransfer: %{time_pretransfer} redirect: %{time_redirect} starttransfer: %{time_starttransfer} total: %{time_total}\n" -so /dev/null https://www.baidu.com
# Print 5 times
for i in $(seq 1 5); do curl -so /dev/null -w "namelookup: %{time_namelookup} tcp: %{time_connect} ssl: %{time_appconnect}  pretransfer: %{time_pretransfer} redirect: %{time_redirect} starttransfer: %{time_starttransfer} total: %{time_total}\n" "https://www.baidu.com";  done
```

Time to domain lookup: `time_namelookup`
TCP handshake: `time_connect`
SSL handshake: `time_appconnect`
Time to first byte: `time_starttransfer`
Total time: `time_total`

``` bash
    curl -w "
    namelookup: %{time_namelookup}
    tcp:        %{time_connect}
    ssl:        %{time_appconnect}
    pretransfer:%{time_pretransfer}
    redirect  : %{time_redirect}
    starttransfer:%{time_starttransfer}
    ----------
    time_total: %{time_total}\n" -so /dev/null https://www.baidu.com
```

[Timing Details With cURL](https://josephscott.org/archives/2011/10/timing-details-with-curl/)
Step one: create a new file, curl-format.txt, and paste in:

``` bash
    \n
        time_namelookup:  %{time_namelookup}\n
           time_connect:  %{time_connect}\n
        time_appconnect:  %{time_appconnect}\n
       time_pretransfer:  %{time_pretransfer}\n
          time_redirect:  %{time_redirect}\n
     time_starttransfer:  %{time_starttransfer}\n
                        ----------\n
             time_total:  %{time_total}\n
    \n
```

Step two, make a request: `curl -w "@curl-format.txt" -o /dev/null -s http://example.com`

- `-w "@curl-format.txt"` tells cURL to use our format file
- `-o /dev/null` redirects the output of the request to /dev/null

And here is what you get back:

``` bash
       time_namelookup:  0.001
          time_connect:  0.037
       time_appconnect:  0.000
      time_pretransfer:  0.037
         time_redirect:  0.000
    time_starttransfer:  0.092
                       ----------
            time_total:  0.164
```

### wget

``` bash
wget http://127.0.0.1 \
    -q -O --header="Content-Type:application/json"
    --post-file=foo.json \

wget 'http://www.example.com:9000/json' \
    -O --header='Content-Type:application/json' \
    --post-data='{"some data to post..."}'
```

#### wget options

- `-c, --continue` Continue getting a partially-downloaded file.  This is useful when you want to finish up a download started by a previous instance of Wget, or by another program.
- `--no-check-certificate`

### [Unison file synchronizer](https://github.com/bcpierce00/unison)

Unison works across platforms, allowing you to synchronize a Windows laptop with a Unix server, for example.

### nc 传输文件

- -l 表示监听端口，等待接收数据
- -p 1234 表示要监听端口号1234
- -u udp
- `-v` verbose
- `-w timeout`
- `-z` Only scan for listening daemons, without sending any data to them.  Cannot be used together with -l.

```sh
# 接收端等待接收文件
nc -l -p 1234 > target.tgz
# 发送端发传输文集
nc TARGET_HOST 1234 < source.tgz

# 批量传输多个文件
# 发送端，我们需要先用 tar 将文件打包，然后通过管端传给 nc：
tar cvf - SOURCE_DIRECTORY/ | nc TARGET_HOST 1234
# 接收端，我们让 nc 收到数据后通过管道传给 tar 解包
nc -l -p 1234 | tar xvf -
```

使用 nc 测试两个节点及 pod 之间的四层连通性

```sh
# host1
nc -l 9999
# host2
nc -vzw 1 <host1> 9999
# udp -u
nc -uvzw 1 host2 8472
Connection to host2 8472 port [udp/otv] succeeded!

```

### mail

`mail -s "subject" -a /opt/attachment.txt username@gmail.com < /dev/null`
check attachment file size limit `postconf -d | grep message_size_limit` or `grep message_size_limit /etc/postfix/main.cf`
wipe the limit by `postconf -e message_size_limit=0`
mail log `/var/log/maillog`

mutt -s "Sample" -a /file/path/file user@local.com < /tmp/msg    send email
mutt -s "gpseqnum" -a gpseqnumInUsed.csv.zip username@gmail.com < /tmp/msg    send email
sendmail user@example.com  < /tmp/email.txt

configuration for mail
/etc/mail/sendmail.mc

``` bash
sendmail username@gmail.com < /tmp/email.txt
# cat /tmp/email.txt
Subject: Terminal Email Send

Email Content line 1
Email Content line 2
```

### help

help命令用来描述不同的内置Bash命令help -s printf
open another terminal: gnome-terminal
man -k or apropos: key words search for command
find out which command shell executes and to print binary(command) file location for specified command: which, whereis, type -a
`locate indexserverconfig.xml`    find file based on index /var/lib/mlocate/mlocate.db
`updatedb`    update index /var/lib/mlocate/mlocate.db as per /etc/updatedb.conf

### Move Running Process to Background

#### already running process into background

1. CTRL+z
2. `jobs`
 or alternate method which lists the PID (note the PID is not the jobnum, the job number is shell specific to the current bash session): jobs -l
3. `bg %jobnum`
 or alternate method %jobnum & for example for the first job %1 &

To place a foreground process in the background: suspend the foreground process (with CTRL+z) then enter the bg command to move the process into the background.
Show the status of all background and suspended jobs: jobs
Bring a job back into the foreground: `fg %jobnumber`
Bring a job back into the background: `bg %jobnumber`

`stty tostop` disable ability of background jobs to output to controlling terminal

#### already running process into nohup

1. Run some SOMECOMMAND
2. ctrl+z to stop (pause) the program and get back to the shell
3. bg to run it in the background
4. disown -h so that the process is not killed when the terminal closes
5. Type exit to get out of the shell because now your good to go as the operation will run in the background in it own process so its not tied to a shell

This process is the equivalent of running nohup SOMECOMMAND

### ab

send 100 requests with a concurrency of 50 requests to an URL
`ab -n 100 -c 50 http://www.example.com/`

send requests during 30 seconds with a concurrency of 50 requests to an URL
`ab -t 30 -c 50 URL http://www.example.com/`

### od

od - dump files in octal and other formats

`od -A x -t x1z -v fileName` Display hexdump format output

`-A, --address-radix=RADIX` output format for file offsets; RADIX is one of [doxn], for Decimal, Octal, Hex or None
`-t, --format=TYPE` select output format or formats
`-v, --output-duplicates` do not use * to mark line suppression
`-w[BYTES], --width[=BYTES]` output BYTES bytes per output line; 32 is implied when BYTES is not specified

`TYPE` is made up of one or more of these specifications:

`a`      named character, ignoring high-order bit
`c`      printable character or backslash escape
`o[SIZE]` octal, SIZE bytes per integer
`x[SIZE]` hexadecimal, SIZE bytes per integer

`SIZE` is a number.
Adding a `z` suffix to any type displays printable characters at the end of each output line.

### Other

`history | awk '{a[$2]++}END{for(i in a){print a[i] " " i}}' | sort -rn | head` 列出最常用的10条命令
使用 HISTTIMEFORMAT 在历史中显示 TIMESTAMP `export HISTTIMEFORMAT='%F %T '`

查看最后一个日志文件 `ls -tr /data/log | tail -1`

```sh
cat << EOF > test.txt
ABC
DEF
EOF
```

```SH
# sudo tee -a 追加文件, 没有-a 覆盖文件
sudo tee -a /etc/rc.local <<EOF
mount -t vboxsf -o uid=$UID,gid=$(id -g) D_DRIVE /d
mount -t vboxsf -o uid=$UID,gid=$(id -g) E_DRIVE /e
EOF
```

`watch -d -n 1 'df; ls -FlAt /path'` 实时某个目录下查看最新改动过的文件
`watch -n 3 ls` 以3秒钟执行一个ls命令
`cd -` 切换回上一个目录
`wget -c file` continue stopped download
`wget -r url` recursive download files from url
`tnsping MDATADEV.DOMAIN.COM`
`mkdir -p $(dirname /tmp/tmp/log)` Create folder /tmp/tmp
使用一个命令来定义复杂的目录树    `mkdir -p project/{lib/ext,bin,src,doc/{html,info,pdf},demo/stat/a}`
ntsysv 就会*出图形界面给你选择(有的则显示在里面), 如果在文本界面就用ntsysv命令
常见的场景是由于某种原因`ls`无法使用(内存不足、动态连接库丢失等等), 因为shell通常可以做`*`扩展, 所以我们可以用 `echo * == ls`
`killall proc` kill all processes named proc

## Tool

### Tmux

tmux    CRTL-b
tmux使用C/S模型构建, 主要包括以下单元模块:
    server服务器. 输入tmux命令时就开启了一个服务器.
    session会话. 一个服务器可以包含多个会话
    window窗口. 一个会话可以包含多个窗口.
    pane面板. 一个窗口可以包含多个面板.
tmux ls #列出会话
tmux a[ttach] -t session

#### session operation

:new    create new session(:new -s sessionName)
? 列出所有快捷键; 按q返回
d 脱离当前会话,可暂时返回Shell界面, 输入tmux a[ttach]能够重新进入之前会话
s 选择并切换会话; 在同时开启了多个会话时使用
\$ Rename the current session

#### window operation

c 创建一个新的窗口
w 以菜单方式显示及选择窗口
n(到达下一个窗口) p(到达上一个窗口)
& 关掉当前窗口, 也可以输入 exit
, Rename the current window

```sh
# 移动 Window
tmux move-window -s <source-session>:<window-number> -t <target-session>:<window-number>
```

#### panel operation

" 将当前面板上下分屏"
% 将当前面板左右分屏
x 关闭当前面板
<光标键> 移动光标选择对应面板
! 将当前面板置于新窗口,即新建一个窗口,其中仅包含当前面板
CTRL+o 交换两个panel位置
space 调整panel摆放方式
CTRL+方向键     以1个单元格为单位移动边缘以调整当前面板大小
ALT+方向键     以5个单元格为单位移动边缘以调整当前面板大小

#### tmux key binding

- `L`           Switch the attached client back to the last session.
- `l`           Move to the previously selected window.
- `[`           Enter copy mode to copy text or view the history.

#### tmux setting .tmux.conf

```sh
# Reload tmux config `.tmux.conf` within tmux, by pressing `CTRL+b` and then `:source-file ~/.tmux.conf` or simply from a shell: `tmux source-file ~/.tmux.conf`

# disable automatic rename
# DISABLE_AUTO_TITLE=true` in .zshrc for zsh
set-option -g allow-rename off
# or
set-option -g allow-rename off
set -g default-terminal "xterm-256color"

# Enable Vi Mode
#setw -g mode-keys vi
set-window-option -g mode-keys vi
```

#### tmux 同步模式

在tmux中，同步模式的作用是让你可以同时在多个窗格（pane）中输入相同的命令。这样，你可以提高效率，特别是在需要在多个服务器或环境中执行相同操作时。

进入同步模式：Ctrl-b，setw synchronize-panes on 启用同步模式。
退出同步模式：Ctrl-b，setw synchronize-panes off 关闭同步模式。

#### Example: tmux scripts

``` bash

#!/bin/bash
SESSION_NAME=session0
WINDOW_NAME=win0
#Setup a session and setup a window for redis
tmux -2 new-session -d -s $SESSION_NAME -n $WINDOW_NAME
tmux split-window -h
tmux select-pane -t 0
tmux send-keys "cd ~/opt/redis-sentinel" C-m
tmux send-keys "startRedisMaster6380.sh" C-m
tmux select-pane -t 1
tmux send-keys "cd ~/opt/redis-sentinel" C-m
tmux send-keys "startRedisSlave6381.sh" C-m
tmux split-window -v
tmux select-pane -t 2
tmux send-keys "cd ~/opt/redis-sentinel" C-m
tmux send-keys "startRedisSlave6382.sh" C-m

tmux new-window -t $SESSION_NAME:1 -n $WINDOW_NAME
```

### screen

screen vi test.c
`-S sessionname`    When  creating a new session
`screen -ls`
`screen -r <PID>`    Reattach a session
`-x <name>`   Attach to a not detached screen  session

可以通过CTRL+a ?来查看所有的键绑定, 常用的键绑定有:
CTRL+a ?    显示所有键绑定信息
CTRL+a w    显示所有窗口列表
CTRL+a A    set window title
CTRL+a CTRL+a    切换到之前显示的窗口
CTRL+a c    创建一个新的运行shell的窗口并切换到该窗口
CTRL+a n    切换到下一个窗口
CTRL+a p    切换到前一个窗口(与CTRL+a n相对)
CTRL+a "    select window from list "
CTRL+a 0..9    切换到窗口0..9
CTRL+a a    发送CTRL+a到当前窗口 bash中到行首
CTRL+a d    暂时断开screen会话
CTRL+a k    杀掉当前窗口
CTRL+a [    进入拷贝/回滚模式
-c file    使用配置文件file, 而不使用默认的$HOME/.screenrc
screen -wipe命令清除死掉的会话

### lsof

`lsof` command (short for "list open files")  this will show you a list of all the open files and their associated process.

```sh
$ lsof
COMMAND  PID       USER   FD      TYPE     DEVICE  SIZE/OFF       NODE NAME
init       1       root  cwd       DIR        8,1      4096          2 /
init       1       root  txt       REG        8,1    124704     917562 /sbin/init
init       1       root    0u      CHR        1,3       0t0       4369 /dev/null
init       1       root    3r     FIFO        0,8       0t0       6323 pipe
```

FD – Represents the file descriptor. Some of the values of FDs are,

- cwd – Current Working Directory
- txt – Text file
- mem – Memory mapped file
- mmap – Memory mapped device
- NUMBER – Represent the actual file descriptor. The character after the number i.e `1u`, represents the mode in which the file is opened. r for read, w for write, u for read and write.

TYPE – Specifies the type of the file. Some of the values of TYPEs are,

- REG – Regular File
- DIR – Directory
- FIFO – First In First Out
- CHR – Character special file

DEVICE

http://www.kernel.org/pub/linux/docs/lanana/device-list/devices-2.6.txt

Parameters:

- `+D` will recurse
- `+d` will not recurse
- `-c` based on process names starting with
- `-u` specific user
- `-p` specific process
- `-t` list the process id
- `-r` repeat until interrupt
- `+r` repeat until no open files found
- `-i` network. selects the listing of files any of whose Internet address matches the address specified in i.  If no address is specified, this option selects the listing of all Internet and x.25 (HP-UX) network files. `-i:1433`
- `-n` inhibits the conversion of network numbers to host names for network files.
- `-P` inhibits the conversion of port numbers to port names for network files.

Samples:

- List open files thread in order `lsof -n |awk '{print $1,$2}'|sort|uniq -c |sort -nr| head`
- List processes which opened a specific file: `lsof /var/log/syslog`
- List opened files under a directory: `lsof +D /var/log/`
- List opened files based on process names starting with: `lsof -c ssh -c init`
- can give multiple -c switch on a single command line.
- List processes using a mount point: `lsof /home`, `lsof +D /home/`
- List files opened by a specific user: `lsof -u username`
- Sometimes you may want to list files opened by all users, expect some 1 or 2. In that case you can use the `^` to exclude only the particular user as follows: `lsof -u ^username`
- List all open files by a specific process: `lsof -p 1753`
- Kill all process that belongs to a particular user: kill -9 `lsof -t -u username`
- Execute lsof in repeat mode: `lsof -u username -c init -a -r5`
- List all network connections: `lsof -i` use `-i4` or `-i6` to list only `IPV4` or `IPV6` respectively.
- List processes which are listening on a particular port: `lsof -i :25`
- List all TCP or UDP connections: `lsof -i tcp; lsof -i udp;`
- list only network files with TCP state LISTEN `lsof -iTCP -sTCP:LISTEN -P -n | less`

### strace 跟踪进程中的系统调用

strace 常用来跟踪进程执行时的系统调用和所接收的信号。strace可以跟踪到一个进程产生的系统调用,包括参数，返回值，执行消耗的时间。 Mac OS 是 dtruss

- `strace command` 执行名称为command的命令或程序并跟踪系统调用
- `strace -p procid` 跟踪ID为的procid的进程系统调用情况
- `strace -c -p procid` 统计ID为的procid的进程系统调用次数与用时，按CTRL+C结束统计，执行结果如下：

example:

`strace ls a`
`strace -ffp 12114`
strace 使用 `strace uptime 2>&1 | grep open`

### Python

The command to print a prompt to the screen and to store the resulting input into a variable named var is:

`var = raw_input('Prompt')`
`python -m SimpleHTTPServer 8000`  HTTP服务在8000号端口上侦听 Python 2
`python -m http.server 7777` （使用端口 7777 和 Python 3）

### maxmind mmdbinspect

[maxmind/mmdbinspect: look up records for one or more IPs/networks in one or more .mmdb databases](https://github.com/maxmind/mmdbinspect)

`mmdbinspect -db GeoLite2-City.mmdb 1.1.1.1`

### Squid Http proxy

[How to Install and Configure Squid Proxy on Ubuntu](https://phoenixnap.com/kb/setup-install-squid-proxy-server-ubuntu)
[How to install a Squid server - Ubuntu Server documentation](https://documentation.ubuntu.com/server/how-to/web-services/install-a-squid-server/index.html)

```sh
sudo apt install squid -y
sudo vi /etc/squid/squid.conf
```

config squid

```sh
# /etc/squid/squid.conf
# Squid normally listens to port 3128, chang to 8081
http_port 8081

# And finally deny all other access to this proxy
#http_access deny all
http_access allow all
```

```sh
# restart squid
sudo systemctl restart squid

curl -x squid_host:8081 www.example.com

export https_proxy=http://squid_host:8081 http_proxy=http://squid_host:8081
curl -v "https://www.example.com"
```

## Software

### Software List

screenshot: shutter,deepin-scrot
ubuntu上 接收 outlook exchange 郵件？ thunderbird + exquilla 插件

### ffmpeg

```sh
# [ffmpeg-script: 基于ffmpeg的一键脚本命令](https://github.com/xxxily/ffmpeg-script)
# 将音视频文件进行快速的合并操作
ffmpeg -i out.mp4 -i out.aac -vcodec copy -acodec copy new.mp4

# 将flv文件快速转换成mp4文件
ffmpeg -i input.flv -vcodec copy -acodec copy output.mp4
```

### Tomcat

export JPDA_ADDRESS=8000
catalina.sh jpda start
catalina.sh configtest
java -Xdebug -Xrunjdwp:transport=dt_socket,server=y,address=8000,suspend=n -jar remoting-debug.jar
Listeningfor transport dt_socket at address: 8000

### [LAMP](https://askubuntu.com/questions/284971/how-to-run-php-web-application-in-lamp-server-and-how-to-do-mysql-connection)

1. Install Apache: `sudo apt-get install apache2`
2. Testing Apache: `http://localhost/`
3. Install PHP: `sudo apt-get install php5 libapache2-mod-php5 php5-mcrypt`
4. Restart Apache: `sudo /etc/init.d/apache2 restart`
5. Test PHP: `sudo echo "<?php phpinfo(); ?>" > /var/www/html/testphp.php`, then open `http://localhost/testphp.php` or execute the following command, which will make PHP run the code without the need for creating a file `php -r 'echo "\n\nYour PHP installation is working fine.\n\n\n";'`
6. Install MySQL: `sudo apt-get install mysql-server libapache2-mod-auth-mysql php5-mysql`

7. PHP Modules: check avaliable libraries: `apt-cache search php5-`, install `sudo apt-get install name of the module`

libapache2-mod-auth-mysql php5-mysql

### inotifywait

`yum install -y inotify-tools`
命令参数说明
`-m` 选项表示 monitor ，即开启监视
`-r` 选项表示递归监视，但是会比较慢一些，若监视/etc 目录，其中的子目录下修改文件也是能被监控到。
`-e` 选项指定要监控的“事件”(events)包括了：`access, modify,  attrib,  close_write,  close_nowrite, close, open,  moved_to,  moved_from, move,  move_self,  create, delete, delete_self, unmount`

如果修改了/etc/passwd文件，则把这个事件记录在文件/root/modify_passwd.txt里
inotifywait -m /etc/passwd -e modify > /root/modify_passwd.txt

```shell
#!/bin/bash
SRC=/path/to/watch/   # 同步的路径，请根据实际情况修改
inotifywait --exclude '\.(part|swp)' -r -mq -e  modify,move_self,create,delete,move,close_write $SRC |
  while read event;
    do
    rsync -vazu --progress  --password-file=/etc/rsyncd_rsync.secret  $SRC  rsync@10.208.1.1::gri ##这里执行同步的命令，可以改为其他的命令
  done

# execute: nohup watch.sh > /dev/null 2>&1 &
```

### LibreOffice

CTRL+0 (zero)     Apply Default paragraph style
CTRL+1     Apply Heading 1 paragraph style
CTRL+ALT+PageDown: Navigating from comment to comment
CTRL+ALT+c: create comment
ALT+Insert, and then press the up or down arrow key:  insert a new row in a table
ALT+Delete, and then press the up or down arrow key.

### convert heic to jpg

[software recommendation - Any app on Ubuntu to open and/or convert HEIF pictures (.HEIC, High Efficiency Image File Format)? - Ask Ubuntu](https://askubuntu.com/questions/958355/any-app-on-ubuntu-to-open-and-or-convert-heif-pictures-heic-high-efficiency-i)

```sh
sudo add-apt-repository ppa:strukturag/libheif
# sudo add-apt-repository ppa:strukturag/libde265
# sudo add-apt-repository --remove ppa:strukturag/libde265
sudo apt update
sudo apt install libheif-examples

for file in *.HEIC; do heif-convert -q 50 $file ${file/%.HEIC/.jpg}; done
```

## Miscellaneous

### Split file 分割文件

1. split
2. head | tail
3. sed
4. awk

`head -n 10 | tail -n 5` print 5 up to 10 line

`sed -n '2p' < file.txt` print the 2nd line
`sed -n '10,33p' < file.txt` print 10 up to 33 line
`sed -n '1p;3p' < file.txt` print 1st and 3rd line

#### split

`split [-<行数>][-b][-c][-l] file.txt`

- -b, --bytes=size 对file进行切分 每个小文件大小为size 可以指定单位b，k，m
- -l, --lines=number 对file进行切分 每个文件都有number行
- -d 添加数字后缀
- -a 2 表示用2位数来顺序命名 后缀长度
- smaillFile_ 分割后文件的前缀

`split -b 100M bigFile.txt smaillFile_` split file into small files
`split -l 10000 bigFile.txt -d -a 2 smaillFile_`

### Missing clock menu bar fix

killall unity-panel-service

### Launcher customization

launcher icon path: ./local/share/applications
Globally in /usr/share/applications, locally in ~/.local/share/applications.
If you want to add a custom launcher, create it in ~/.local/share/applications, make it executable, drag and drop it on the launcher*, and finally pin it (right-click on the launcher item → Keep In Launcher).
make it executable

### Android connect to Ubuntu

gMTP connect to android from Ubuntu

### Ubuntu死机

1. 重启桌面方法
 `sudo restart lightdm`restarting the GUI gnome-system-monitor or `ALT+CTRL+F1`进入命令行Console, kill Xorg的进程`ps -t tty7`后(tty7中跑的是图形桌面进程),Ubuntu将自动重新启动Xorg, 缺点是重新启动了Xorg的进程, 死机前原来正在运行的程序和数据无法恢复！
2. When a single program stops working: `ALT+F2`, type `xkill`

## System

`zdump -v /etc/localtime` examine the contents of the time zone files

2 的次方表

```text
Power           Exact Value         Approx Value        Bytes
---------------------------------------------------------------
7                             128
8                             256
10                           1024   1 thousand           1 KB
16                         65,536                       64 KB
20                      1,048,576   1 million            1 MB
30                  1,073,741,824   1 billion            1 GB
32                  4,294,967,296                        4 GB
40              1,099,511,627,776   1 trillion           1 TB
```

每个程序员都应该知道的延迟数

CPU -> 内存 -> SSD -> 磁盘 -> 网络
纳秒 -> 微秒 -> 毫秒 -> 毫秒 -> 秒

```text
Latency Comparison Numbers
--------------------------
L1 cache reference                           0.5 ns
Branch mispredict                            5   ns
L2 cache reference                           7   ns                      14x L1 cache
Mutex lock/unlock                           25   ns
Main memory reference                      100   ns                      20x L2 cache, 200x L1 cache
Compress 1K bytes with Zippy            10,000   ns       10 us
Send 1 KB bytes over 1 Gbps network     10,000   ns       10 us
Read 4 KB randomly from SSD*           150,000   ns      150 us          ~1GB/sec SSD
Read 1 MB sequentially from memory     250,000   ns      250 us
Round trip within same datacenter      500,000   ns      500 us
Read 1 MB sequentially from SSD*     1,000,000   ns    1,000 us    1 ms  ~1GB/sec SSD, 4X memory
Disk seek                           10,000,000   ns   10,000 us   10 ms  20x datacenter roundtrip
Read 1 MB sequentially from 1 Gbps  10,000,000   ns   10,000 us   10 ms  40x memory, 10X SSD
Read 1 MB sequentially from disk    30,000,000   ns   30,000 us   30 ms 120x memory, 30X SSD
Send packet CA->Netherlands->CA    150,000,000   ns  150,000 us  150 ms

Notes
-----
1 ns = 10^-9 seconds
1 us = 10^-6 seconds = 1,000 ns
1 ms = 10^-3 seconds = 1,000 us = 1,000,000 ns
```

### Performance

[Linux Performance](http://www.brendangregg.com/linuxperf.html )
[The USE Method](http://www.brendangregg.com/usemethod.html )

#### [Linux Perf Analysis in 60s Checklist](http://techblog.netflix.com/2015/11/linux-performance-analysis-in-60s.html)

1. `uptime` ⟶  load averages
2. `dmesg -T | tail` ⟶  kernel errors 输出系统日志的最后10行, `less /var/log/messages` or `less /var/log/dmesg`
3. `vmstat 1` ⟶  overall stats by time
4. `mpstat -P ALL 1` ⟶  CPU balance
5. `pidstat 1` ⟶  process usage
6. `iostat -xz 1` ⟶  disk I/O
7. `free -m` or `cat /proc/meminfo` ⟶   memory usage
8. `sar -n DEV 1` ⟶   network I/O
9. `sar -n TCP,ETCP 1` ⟶   TCP stats
10. `top` ⟶  check overview

11. `sysstat`工具与负载历史回放
12. `dstat`

```bash
# dmesg -T 可以转换成可读时间
# dmesg日志时间转换公式:log实际时间=格林威治1970-01-01+(当前时间秒数-系统启动至今的秒数+dmesg打印的log时间)秒数：
date -d "1970-01-01 UTC `echo "$(date +%s)-$(cat /proc/uptime|cut -f 1 -d' ')+12288812.926194"|bc ` seconds"
```

[性能指标总结](http://blog.csdn.net/heyongluoyao8/article/details/51413668)

1. CPU
    * CPU利用率：us <= 70，sy <= 35，us + sy <= 70。
    * 上下文切换：与CPU利用率相关联，如果CPU利用率状态良好，大量的上下文切换也是可以接受的。
    * 可运行队列：每个处理器的可运行队列<=3个线程。
2. Memory
    * swap in (si) == 0，swap out (so) == 0
    * 可用内存/物理内存 >= 30%
3. Disk: Use% <= 90%
4. Disk I/O: I/O等待的请求比例 <= 20%
5. Network I/O: UDP包丢包率与TCP包重传率不能超过1%/s。
6. Connect Num: <= 1024
7. File Handle Num: num/max_num <= 90%

### CPU

#### [Linux CPU Checklist](http://www.brendangregg.com/blog/2016-05-04/srecon2016-perf-checklists-for-sres.html)

1. `uptime` ⟶  load averages
2. `vmstat 1` ⟶  system-wide utilization, run q length
3. `mpstat -P ALL 1` ⟶  CPU balance
4. `pidstat 1` ⟶  per-process CPU
5. CPU flame graph ⟶  CPU profiling
6. CPU subsecond offset heat map ⟶  look for gaps
7. `perf stat -a` -- sleep 10 ⟶  IPC, LLC hit ratio
8. `htop` can do 1-4

`cat /proc/cpuinfo` view the amount of cores
`pidstat -l 2 10`
`w` - Find Out Who Is Logged on And What They Are Doing

#### 良好状态指标

- CPU利用率：User Time <= 70%，System Time <= 35%，User Time + System Time <= 70% (同时可以结合idle值来看，也就是%id，如果%id<=70% 则表示IO的压力较大) `top`输出
- 上下文切换：与CPU利用率相关联，如果CPU利用率状态良好，大量的上下文切换也是可以接受的 `cs` in `vmstat`
- 可运行队列：每个处理器的可运行队列<=3个线程 `vmstat`输出中`r`列表示run queue
- wa（wait）: 参考值：小于25%，超过25%的wa的值可以表示磁盘子系统可能没有被正确平衡，也可能是磁盘密集工作负载的结果，系统的磁盘或其它I/o可能有问题，可以通过iostat/sar -C命令进一步分解分析
- r: 参考值：对于单个处理器来说, r 小于4. 队列大于4时，表明系统的cpu或内存可能有问题，如果r经常大于4，且id经常少于40，表示cpu的负荷很重。当队列变长时，队列中进程在等待cpu调度执行时所花的时间会变长. `vmstat`

如何衡量当前系统是否负载过高?
如果每个cpu(可以按CPU核心的数量计算)上当前活动进程数

- 不大于3，则系统性能良好;
- 不大于4，表示可以接受;
- 如大于5，则系统性能问题严重
当负载为8.13,如果有2个cpu核心,则8.13/2=4.065, 此系统性能可以接受

建议设置严格的报警值为: CPU核心的数量
比如：CPU核心数量为2，则设置报警值为2

使用`top`, `vmstat` 和 `sar -q` 等来查看

#### CPU 时间组成

CPU的工作时间由三部分组成：用户态时间、系统态时间和空闲态时间。具体的组成为：
CPU时间包含User time、System time、Nice time、Idle time、Waiting time、Hardirq time、Softirq time、Steal time
空闲态时间==idle time
用户态时间==user time + Nice time
内核态时间==system time + Hardirq time + Softirq time
user time。指CPU在用户态执行进程的时间
system time。指CPU在内核运行的时间
nice time。指系统花费在调整进程优先级上的时间
idle time。系统处于空闲期，等待进程运行
waiting time。指CPU花费在等待I/O操作上的总时间，与blocked相似
steal time。指当前CPU被强制（involuntary wait ）等待另外虚拟的CPU处理完毕时花费的时间，此时 hypervisor 在为另一个虚拟处理器服务
Softirq time 、Hardirq time。分别对应系统在处理软硬中断时候所花费的CPU时间

#### 查看 CPU 信息

```sh
# uname -m will display the machine hardware name, which will indicate the processor architecture.
uname -m
# `lscpu` display information on CPU architecture
lscpu | grep Architecture
# prints values such as x86_64, i686, arm, or aarch64.
# x86_64 is amd64 (also known as x86-64 or Intel 64).
# i386 i686 is 386
# arm is arm

/*CPU查看CPU型号*/
cat /proc/cpuinfo | grep name | cut -f2 -d: | uniq -c

/*查看物理CPU个数*/
cat /proc/cpuinfo | grep "physical id" | sort -u | wc -l

/*查看逻辑CPU个数*/
cat /proc/cpuinfo | grep "processor" | wc -l

/*查看CPU内核数*/
cat /proc/cpuinfo | grep "cpu cores" | uniq

/*查看单个物理CPU封装的逻辑CPU数量*/
cat /proc/cpuinfo | grep "siblings" | uniq

/*计算是否开启超线程
##逻辑CPU > 物理CPU x CPU核数 #开启超线程
##逻辑CPU = 物理CPU x CPU核数 #没有开启超线程或不支持超线程*/

/*查看是否超线程,如果cpu cores数量和siblings数量一致，则没有启用超线程，否则超线程被启用。*/
cat /proc/cpuinfo | grep -e "cpu cores"  -e "siblings" | sort | uniq
```

#### top uptime

`top`命令包含了几个命令的检查的内容: 比如系统负载情况（`uptime`）、系统内存使用情况（`free`）、系统CPU使用情况（`vmstat`）等. 因此通过这个命令, 可以相对全面的查看系统负载的来源. 同时, `top`命令支持排序, 可以按照不同的列排序, 方便查找出诸如内存占用最多的进程、CPU占用率最高的进程等.
`top -u postgres`  查看某个用户内存使用情况,如:postgres

1. `uptime`
`23:51:26 up 21:31,  1 user,  load average: 30.02, 26.43, 19.02`
命令的输出分别表示1分钟、5分钟、15分钟的平均负载情况. 通过这三个数据, 可以了解服务器负载是在趋于紧张还是区域缓解. 如果1分钟平均负载很高, 而15分钟平均负载很低, 说明服务器正在命令高负载情况, 需要进一步排查CPU资源都消耗在了哪里. 反之, 如果15分钟平均负载很高, 1分钟平均负载较低, 则有可能是CPU资源紧张时刻已经过去.
判断一个系统负载是否偏高需要计算单核CPU的平均负载, 等于这里uptime命令显示的系统平均负载 / CPU核数, 一般以0.7为比较合适的值. 偏高说明有比较多的进程在等待使用CPU资源

1. `top`
top命令中, 按 `f` 键, 进入选择排序列的界面, 按 `k` 键, 并输入想要终止的PID, 就可以直接杀死指定进程
`RES`是常驻内存, 是进程切实使用的物理内存量
第3行: 当前的CPU运行情况:
 `us, user`: 非nice用户进程占用CPU的比率
　　　　`sy, system`: 内核、内核进程占用CPU的比率;
　　　　`ni, nice`: 如果一些用户进程修改过优先级, 这里显示这些进程占用CPU时间的比率;
　　　　`id`: CPU空闲比率, 如果系统缓慢而这个值很高, 说明系统慢的原因不是CPU负载高;
　　　　`wa, IO-wait`: CPU等待执行I/O操作的时间比率, 该指标可以用来排查磁盘I/O的问题, 通常结合wa和id判断
　　　　`hi`: CPU处理硬件终端所占时间的比率;
　　　　`si`: CPU处理软件终端所占时间的比率;
　　　　`st`: 流逝的时间, 虚拟机中的其他任务所占CPU时间的比率;

　用户进程占比高, wa低, 说明系统缓慢的原因在于进程占用大量CPU, 通常还会伴有较低的id, 说明CPU空转时间很少;
　　wa低, id高, 可以排除CPU资源瓶颈的可能
　　wa高, 说明I/O占用了大量的CPU时间, 需要检查交换空间的使用, 交换空间位于磁盘上, 性能远低于内存, 当内存耗尽开始使用交换空间时, 将会给性能带来严重影响, 所以对于性能要求较高的服务器, 一般建议关闭交换空间. 另一方面, 如果内存充足, 但wa很高, 说明需要检查哪个进程占用了大量的I/O资源.

`Shift+P` sort by CPU utilization
`Shift+M` sort by Memory utilization
`Shift+H` toggle the visibility of threads
`Shift+K` see kernel threads

`skill` 和 `snice`
如果您发现了一个占用大量 CPU 和内存的进程，但又不想停止它，该怎么办
`skill -STOP PID` 冻结 not kill it
`skill -CONT PID` 如果希望暂时冻结进程以便为完成更重要的进程腾出空间，该方法非常有用。要停止 "oracle" 用户的所有进程，只需要一个命令即可实现：
`skill -STOP oracle` 可以使用用户、PID、命令或终端 id 作为参数

#### perf

`sudo perf record -F 99 -p 13204 -g -- sleep 30`
perf record表示记录，-F 99表示每秒99次，-p 13204是进程号，即对哪个进程进行分析，-g表示记录调用栈，sleep 30则是持续30秒。
perf 命令（performance 的缩写）讲起，它是 Linux 系统原生提供的性能分析工具，会返回 CPU 正在执行的函数名以及调用栈（stack）

[The USE Method](http://www.brendangregg.com/usemethod.html )
[如何读懂火焰图](http://www.ruanyifeng.com/blog/2017/09/flame-graph.html )
[Flame Graphs](http://www.brendangregg.com/flamegraphs.html )

#### CPU核数怎么计算

```sh
# 物理cpu数: 主板上实际插入的cpu数量，可以数不重复的 physical id 有几个（physical id）
cat /proc/cpuinfo | grep "physical id" | sort | uniq | wc -l

# cpu核数: 单块CPU上面能处理数据的芯片组的数量，如双核、四核等 （cpu cores）
cat /proc/cpuinfo | grep "cpu cores" | wc -l

# 逻辑cpu数: 简单来说，它可使处理器中的1颗内核，如2颗内核那样在操作系统中发挥作用。
cat /proc/cpuinfo | grep "processor" | wc -l
```

操作系统可以使用逻辑CPU来模拟出真实CPU的效果。 在之前没有多核处理器的时候，一个CPU只有一个核，而现在有了多核技术，其效果就好像把多个CPU集中在一个CPU上。

当计算机没有开启超线程时，逻辑CPU的个数就是计算机的核数。 而当超线程开启后，逻辑CPU的个数是核数的两倍。

### Memory

#### Memory 良好状态指标

- swap in （si） == 0，swap out （so） == 0  `si, so` in `vmstat`
- 应用程序可用内存/系统物理内存 >= 30%  (可用内存=系统free memory+buffers+cached) `free`

使用`sar -B`、`sar -r` 和 `sar -W`查看
`dmesg | grep oom-killer shows the OutOfMemory-killer at work`
`cat /proc/meminfo`
`ps aux | sort -nk +4 | tail` 列出头十个最耗内存的进程
进程内存 `ps -O rss` 指定 rss 可以查看进程的内存
实时查看进程内存 `pidstat -sr`

1. Reserved (保留内存)：保留内存是指操作系统已经为某个应用程序预留的虚拟内存地址空间，但并没有实际分配物理内存。换句话说，保留的内存区域可以被应用程序使用，但在实际使用之前，操作系统不必立刻为其分配物理 RAM。保留内存的目的是为了保证应用程序可以在将来使用这些地址，而不会与其他应用程序发生冲突。
2. Committed (承诺内存)：承诺内存是指已经分配并实际使用的内存。这部分内存可以被视为已承诺给应用程序使用的物理内存，操作系统为其分配了物理 RAM。简单来说，承诺内存就是已经被分配并实际存在于物理内存中的那部分内存。
3. Resident (常驻内存)：常驻内存指的是当前在物理 RAM 中驻留的内存页。这部分内存是已经承诺并分配的内存，且确实加载到了物理内存中。常驻内存与承诺内存的主要区别在于，承诺内存不一定在物理内存中，可能会被交换到磁盘上，而常驻内存则永远是在物理内存中。

#### 实时查看进程内存

pidstat -sr

```sh
# 查看 23097 PID 的内存信息，每隔一秒打印一次
# -r: 查看进程的内存信息
# -s: 查看进程的 stack 信息
# -p: 指定 PID
# 1: 每间隔 1s 打印一次
# 5: 共打印 5 组
$ pidstat -sr -p 23097 1 5
Linux 3.10.0-693.2.2.el7.x86_64 (shanyue)       07/18/19        _x86_64_        (2 CPU)

18:56:07      UID       PID  minflt/s  majflt/s     VSZ    RSS   %MEM StkSize  StkRef  Command
18:56:08        0     23097      0.00      0.00  366424  95996   2.47    136      80  node

18:56:08      UID       PID  minflt/s  majflt/s     VSZ    RSS   %MEM StkSize  StkRef  Command
18:56:09        0     23097      0.00      0.00  366424  95996   2.47    136      80  node
```

#### Momory troubleshooting

[Linux系统排查1——内存篇 - 王智愚 - 博客园](http://www.cnblogs.com/Security-Darren/p/4685629.html)
Steps:

　　1. 内存的使用率如何查看, 使用率真的很高吗
　　2. 内存用在哪里了
　　3. 内存优化可以有哪些手段

1. 内存硬件查看 `dmidecode -t memory`: 通过dmidecode工具可以查看很多硬件相关的数据
2. 内存的大体使用情况 `free -h`

    ~$ free -h
                   total      used       free     shared    buffers     cached
    Mem:          7.5G       7.4G       175M       327M        25M       527M
    -/+ buffers/cache:       6.8G       729M
    Swap:         1.9G       1.9G         0B
free 下面有一行“-/+ buffers/cache”, 该行显示的used是上一行“used”的值减去buffers和cached的值(7.4G - 327M - 25M), 同时该行的free是上一行的free加上buffers和cached的值(175M + 327M + 25M)

3. 哪些进程消耗内存比较多 `top`
 top命令中, 按下 f 键, 进入选择排序列的界面, 按%MEM排序. RES是常驻内存, 是进程切实使用的物理内存量, free命令中看到的used列下面的值, 就包括常驻内存的加总, 但不是虚拟内存的加总

4. 交换空间
 `# swapon` 开启交换空间
 `# swapoff` 关闭交换空间
 `# mkswap` 创建交换空间
 使用free命令可以查看内存的总体使用, 显示的内容也包括交换分区的大小, 可以使用swapon, swapoff, 命令开启或关闭交换空间, 交换空间是磁盘上的文件, 并不是真正的内存空间.
系统的可用内存一般等于物理内存 + 交换分区. 交换分区在磁盘上,  因此速度比内存读写要慢得多. 交换分区实际上就是磁盘上的文件, 可以通过mkswap命令来创建交换空间

5. 内核态内存占用 `# slabtop`
　　slab系统用来处理系统中比较小的元数据, 如文件描述符等, 进而组织内核态的内存分配.
　　一个slab包含多个object, 例如dentry这些数据结构就是object, 可以通过slabtop命令查看系统中活动的object的数量与内存占用情况, 从而了解哪些数据结构最占用内核态的内存空间.
通常关注1. 哪些数据结构的内存占用最大, 2. 哪些类型的数据结构对应的object最多, 比如inode多代表文件系统被大量引用等

6. 查看系统内存历史记录`# sar`
7. dstat
8. 查看共享内存空间 `pmap` 通过pmap找到那个占用内存量最多的进程, `pmap pid` - Process Memory Usage 查看pid进程使用的共享内存, 包括使用的库, 所在堆栈空间等.

#### 如何清理内存使用

1. 释放占用的缓存空间
 `# sync     //先将内存刷出, 避免数据丢失`
 `# echo 1 > /proc/sys/vm/drop_caches //释放pagecache`
 `# echo 2 > /proc/sys/vm/drop_caches //释放dentry和inode`
 `# echo 3 > /proc/sys/vm/drop_caches //释放pagecache、dentry和inode`

2. 终止进程
    与Linux内存相关的文件系统文件
    内存信息 `/proc/meminfo`
    进程状态信息 `/proc/$pid/status`
    进程物理内存信息 `/proc/$pid/statm`
    slab的分布状况 `/proc/slabinfo`
    虚拟内存信息 `/proc/vmstat`

3. 降低swap的使用率 查看当前swap的使用 `# sysctl -a | grep swappiness`

4. 限制其他用户的内存使用
    `# vim /etc/security/limits.conf`

    `user1 hard as 1000` （用户user1所有累加起来, 内存不超过1000kiB）
    `user1 soft as 800` （用户user1一次运行, 内存不超过800kiB）

5. 大量连续内存数据:
    `# vim /etc/sysctl.conf`

    `vm.nr_hugepage=20`

6. 调节page cache（大量一样的请求 调大page cache）
    `vm.lowmem_reserve_ratio = 256 256 32` （保留多少内存作为pagecache 当前 最大 最小）
    `vm.vfs_cache_pressure=100` （大于100, 回收pagecache）
    `vm.page.cluster=3`（一次性从swap写入内存的量为2的3次方页）
    `vm.zone_reclaim_mode=0/1`（当内存危机时, 是否尽量回收内存 0:尽量回收 1:尽量不回收）
    `min_free_kbytes`: 该文件表示强制Linux VM最低保留多少空闲内存（Kbytes）.

7. 脏页
 　　脏页是指已经更改但尚未刷到硬盘的内存页, 由pdflush往硬盘上面刷.
`vm.dirty_background_radio=10` （当脏页占内存10%, pdflush工作）
`vm.dirty_radio=40` （当进程自身脏页占内存40%, 进程自己处理脏页, 将其写入磁盘）
`vm.dirty_expire_centisecs=3000` （脏页老化时间为30秒 3000/100=30秒）
`vm.dirty_writeback_centisecs=500` （每隔5秒, pdflush监控一次内存数量 500/100=5秒）

### Disk & I/O

`df -hT`    查看大小、分区、文件系统类型
硬盘是否SCSI: /dev/sdX就是scsi的, hdX就是普通的.
`cat /sys/block/sda/queue/rotational`    硬盘是否SSD, 0是SSD, 1是传统硬盘

#### Disk 良好状态指标

- Use% <= 90%
- `iowait` % < 20%, `iostat -c 2 5` 查看 iowait 的值
- 提高命中率的一个简单方式就是增大文件缓存区面积，缓存区越大预存的页面就越多，命中率也越高
- Linux 内核希望能尽可能产生次缺页中断（从文件缓存区读），并且能尽可能避免主缺页中断（从硬盘读），这样随着次缺页中断的增多，文件缓存区也逐步增大，直到系统只有少量可用物理内存的时候 Linux 才开始释放一些不用的页
- 一般地系统I/O响应时间`await`应该低于5ms, 如果大于10ms就比较大了
- 如果`svctm`的值与`await`很接近，表示几乎没有I/O等待，磁盘性能很好，如果`await`的值远高于`svctm`的值，则表示I/O队列等待太长，系统上运行的应用程序将变慢
- 如果`%util`超过60, 可能会影响IO性能; 如果到达100%, 说明硬件设备已经饱和.
- 如果`avgqu-sz`值大于1, 可能是硬件设备已经饱和（部分前端硬件设备支持并行写入）

`iostat -xz 2 5`查看 svctm, await, util, avgqu-sz 的值
使用`sar -b`、`sar -u` 和 `sar -d`查看

#### [Linux Disk Checklist](http://www.brendangregg.com/blog/2016-05-04/srecon2016-perf-checklists-for-sres.html)

1. `iostat -xnz 1` ⟶  any disk I/O? if not, stop looking
2. `vmstat 1` ⟶  is this swapping? or, high sys time?
3. `df -h` ⟶  are file systems nearly full?
4. `ext4slower 10` ⟶  (zfs*, xfs*, etc.) slow file system I/O?
5. `bioslower 10` ⟶  if so, check disks
6. `ext4dist 1` ⟶  check distribution and rate
7. `biolatency 1` ⟶  if interesting, check disks
8. `cat /sys/devices/…/ioerr_cnt` ⟶  (if available) errors
9. `smartctl -l error /dev/sda1` ⟶  (if available) errors

#### 当磁盘无法写入的时候, 一般有以下可能

[Linux系统排查3——I/O篇 - 王智愚 - 博客园](http://www.cnblogs.com/Security-Darren/p/4700386.html)

- 文件系统只读
- 磁盘已满
- I节点使用完

##### 遇到只读的文件系统

`# mount -o remount, rw /home`  重新挂载改变/home分区的读写属性, remount是指重新挂载指定文件系统, rw指定重新挂载时的读写属性, 该命令不改变挂载点, 只是改变指定分区的读写属性.

##### 磁盘满

`df -h` 查看当前已挂载的所有分区及使用情况
`tune2fs -l /dev/sda2 | grep -i "block"`查看系统保留块
`du -ckx /path/to/file | sort -n > /tmp/dir_space`, `tail /tmp/dir_space`得到根文件系统下最大的10个目录
`du -sh dirname` 查看目录的大小
`du -h --max-depth=1` 显示当前目录中所有子目录的大小
`find / -name '*log*' -size +1000M -exec du -h {} \;` find files size more than 1G
`du -s * | sort -nr | head | awk '{print $2}' | xargs du -sh` List size top 10 files in current folder
`find /data/logs/* -mtime +8 -type f  | xargs rm -f` delete files which modify time 8 days ago

##### I节点不足

`df -i` 查看I节点的使用情况

identify the directory which is using all your inodes:

- `sudo find / -xdev -printf '%h\n' | sort | uniq -c | sort -k 1 -n | tail -n 15`  check the root filesystem `/`
- `sudo du --inodes -d 3 / | sort -n | tail`

一旦遇到I节点用光的情形, 有以下几种选择:

1. 删除 30 天前的文件  `find /path/to/folder -mtime +30 -type f  | xargs rm -f >/dev/null 2>&1`
2. 将大量文件移动到其他的文件系统中;
3. 将大量的文件压缩成一个文件;
4. 备份当前文件系统中的所有文件, 重新格式化之前的硬盘, 获得更多的I节点, 再将文件复制回去.

一般 `/var/spool/postfix/ldrop` 下面有很多文件
为了避免，可以在每个定时任务后面加上  `>/dev/null 2>&1`
或者执行 `crontab -e` 在最开头添加 `MAILTO='"'` 保存，然后 `server crond restart` 重启 `crond`

#### I/O

1. `iostat` 查看系统分区的IO使用情况
2. `iotop` iotop命令类似于top命令, 但是显示的是各个进程的I/O情况, 对于定位I/O操作较重的进程有比较大的作用.

#### 硬盘写速度

普通硬盘的写速度大概100M/s, RAID级别的查看不方便, SSD的速度也不定, 所以用dd测一下最靠谱:
`dd if=/dev/zero of=/tmp/output bs=8k count=128k conv=fdatasync`
`dd if=/dev/zero of=/tmp/output bs=1G count=1 conv=fdatasync`
`dd if=/dev/zero of=/tmp/output bs=8k count=256k conv=fdatasync; rm -f /tmp/output`
上面命令测试了分别以每次8k和1g的大小, 写入1g文件的速度.
`if`: input file 输入文件名,  /dev/zero 设备无穷尽地提供0
`of`: output file 输出文件名
`bs`: 块大小 表示每一次读写1M数据
`count`: 表示读写次数
`conv=fdatasync` : 实际写盘, 而不是写入Page Cache

`dd if=/dev/zero of=10M.file bs=1M count=10`    在当前目录下生成一个10M的文件

dd做的只是文件拷贝工作
`dd if=/dev/zero of=test bs=1M count=0 seek=100` 此时创建的文件在文件系统中的显示大小为100M,但是并不实际占用block,占用空间为0, `du -m test`

#### 硬盘读速度

##### dd

硬盘读速度的测试同理, 不过要先清理缓存, 否则直接从Page Cache读了.
`sh -c "sync && echo 3 > /proc/sys/vm/drop_caches"`
`dd if=/tmp/output of=/dev/null bs=8k`

##### hdparm

`hdparm` get/set SATA/IDE device parameters
`sudo hdparm -Tt /dev/sda`
`for i in 1 2 3; do sudo hdparm -tT /dev/sda; done`
`sudo hdparm -v /dev/sda` will give information as well.

``` bash
    sudo hdparm -Tt /dev/sda
    /dev/sda:
    Timing cached reads:   12540 MB in  2.00 seconds = 6277.67 MB/sec
    Timing buffered disk reads: 234 MB in  3.00 seconds =  77.98 MB/sec
```

#### 查看硬盘信息

`lsblk` 查看接入到系统中的块设备，默认输出分区、大小、挂载点等信息
`lsscsi` 打印SCSI硬盘信息
`lshw -class disk` 打印硬件的详细信息，打印硬盘信息需要root权限

#### File recovery

[File recovery - ArchWiki](https://wiki.archlinux.org/title/file_recovery)
[Linux debugfs Hack: Undelete Files - nixCraft](https://www.cyberciti.biz/tips/linux-ext3-ext4-deleted-files-recovery-howto.html)

### Network

#### [Linux Network Checklist](http://www.brendangregg.com/blog/2016-05-04/srecon2016-perf-checklists-for-sres.html)

1. `sar -n DEV,EDEV 1` ⟶  at interface limits? or use nicstat
2. `sar -n TCP,ETCP 1` ⟶  active/passive load, retransmit rate
3. `cat /etc/resolv.conf` ⟶  it is always DNS
4. `mpstat -P ALL 1` ⟶  high kernel time? single hot CPU?
5. `tcpretrans` ⟶  what are the retransmits? state?
6. `tcpconnect` ⟶  connecting to anything unexpected?
7. `tcpaccept` ⟶  unexpected workload?
8. `netstat -rnv` ⟶  any inefficient routes?
9. check firewall config ⟶  anything blocking/throttling?
10. `netstat -s` ⟶  play 252 metric pickup
 tcp*, are from bcc/BPF tools

11 `iftop`
12 `nicstat`
13 `iperf` Diagnosing network speed

Linux查看网卡数据吞吐量方法

1. [`iptraf`](http://iptraf.seul.org),提供了每个网卡吞吐量的仪表盘: `iptraf -d eth0`
2. `watch -n 1 "/sbin/ifconfig eth0 | grep bytes"`.
3. 带宽监控 [`nload`](https://linux.cn/article-2871-1.html)
4. `yum install nethogs -y`  查看某一网卡上进程级流量信息
5. `sudo ntop -i enp0s25 -d -L -w 3002`
6. `ntopng -d -L -w 3001` 使用web 页面 `http://localhost:3001` 访问 默认密码 admin / admin

#### Network 良好状态指标

- 对于UDP, 接收、发送缓冲区不长时间有等待处理的网络包
- 对于TCP, 不会出现因为缓存不足而存在丢包的事，因为网络等其他原因，导致丢了包，协议层也会通过重传机制来保证丢的包到达对方。所以，tcp而言更多的专注重传率 `cat /proc/net/snmp | grep Tcp`
- 连接数如果超过1024报警 `netstat -na | sed -n '3,$p' |awk '{print $5}' | grep -v 127\.0\.0\.1 | grep -v 0\.0\.0\.0 | wc -l`

##### UDP

`netstat -lunp` 查看所有监听的UDP端口的网络情况, RecvQ、SendQ为0，或者不长时间有数值是比较正常的。
`netstat -su` 查看丢包情况（网卡收到了，但是应用层没有处理过来造成的丢包）, packet receive errors 这一项数值增长了，则表明在丢包

##### TCP

`cat /proc/net/snmp | grep Tcp`, `重传率 = RetransSegs / OutSegs`
综上, 重传率 = `cat /proc/net/snmp | grep Tcp | grep -v RetransSegs | awk '{print $13/$12}'`
Tcp: RtoAlgorithm RtoMin RtoMax MaxConn ActiveOpens PassiveOpens AttemptFails EstabResets CurrEstab InSegs OutSegs RetransSegs InErrs OutRsts
Tcp: 1 200 120000 -1 25169661 1267603036 5792926 11509899 84 16782050531 18268679467 14875350 21734 11294887

##### 网卡

- 先用`ifconfig`看看有多少块网卡和bonding. bonding是个很棒的东西, 可以把多块网卡绑起来, 突破单块网卡的带宽限制
- 然后检查每块网卡的速度, 比如`ethtool eth0`.
- 再检查bonding, 比如`cat /proc/net/bonding/bond0`, 留意其Bonding Mode是负载均衡的, 再留意其捆绑的网卡的速度.
- 最后检查测试客户机与服务机之间的带宽, 先简单`ping`或`traceroute` 一下得到RTT时间, `iperf`之类的可稍后.

##### Network troubleshooting

[Linux系统排查4——网络篇 - 王智愚 - 博客园](www.cnblogs.com/Security-Darren/p/4700387.html )
[Quick HOWTO : Ch04 : Simple Network Troubleshooting](http://www.linuxhomenetworking.com/wiki/index.php/Quick_HOWTO_:_Ch04_:_Simple_Network_Troubleshooting#.V4rx8p7hJz0 )

网络排查一般是有一定的思路和顺序的, 其实排查的思路就是根据具体的问题逐段排除故障可能发生的地方, 最终确定问题.

网络问题是什么, 是不通, 还是慢？

1. 如果是网络不通, 要定位具体的问题, 一般是不断尝试排除不可能故障的地方, 最终定位问题根源. 一般需要查看
    链路是否连通: `ethtool eth0`
        `Speed: 1000Mb/s`显示了当前网卡的速度, `Duplex: Full`显示了当前网络支持全双工, `Link detected: yes`显示当前网卡和网络的物理连接正常
    网卡是否正常启用: `ifconfig eth0`
        第3行显示了对该网卡的配置, 包括IP, 子网掩码等, 这里可以检查是否出现错配, 如果这一行显示不正确, 那一定是网卡没有正确配置开启.
    本地网络是否连接:  用route 命令查看内核路由表 `route -n`得到网关, 之后就可以尝试ping 网关, 排查与网关之间的连接
    DNS工作状况: `nslookup`, `dig +trace` 如果这里nslookup命令无法解析目标域名, 则很有可能是DNS配置不当
    能否路由到目标主机:
        1. based on ICMP: `ping IP`, `traceroute IP`
            ping得通, 说明路由工作正常, ping不通可能是因为网络不通或者某个网关限制了ICMP协议包
        2. `sudo tcptraceroute 113.106.202.46`
    远程端口是否开放
        1. 使用telnet检测远程主机的端口开放情况 `telnet IP PORT`
            telnet无法连接包含两种可能: 1是端口确实没有开放, 2是防火墙过滤了连接.
        2. `nmap HOST`, `nmap -p PORT IP` 可以了解端口无法连接的原因是端口关闭还是防火墙过滤了
      本地端口 `# netstat -lnp | grep PORT`
      查看防火墙规则: `iptables -L -n -v`
        `ip rule show`
        `ip route get IP` 得到使用的 RULE
        `ip route show table RULE | grep IP`

2. 如果是网络速度慢, 一般有以下几个方式定位问题源:
    DNS是否是问题的源头:
        1. `traceroute`不仅可以查看路由的正确性, 还可以查看网络中每一跳的延时, 从而定位延时最高的网络区段
        2. `iftop`命令类似于`top`命令, 查看哪些网络连接占用的带宽较多
        3. `tcpdump`是常用的抓包工具
    查看路由过程中哪些节点是瓶颈
    查看带宽的使用情况

##### nslookup

```sh
nslookup google.com 172.28.7.70
```

##### ip route 配置静态路由

```sh
ip addr show enp0s3

ip route add [network/prefix] via [gateway] dev [interface]
# 其中，network/prefix 指目标网络和掩码位数，即网络前缀长度，via 指路由数据包的下一跳网关的IP地址，dev interface 指数据包从哪个网络接口出去。如果只想查看路由表，则不需要在命令中添加 add 参数，而是直接输入 ip route

# 设置系统默认路由
ip route add default via 192.168.1.254

# 设置192.168.4.0网段的网关为192.168.0.254,数据走eth0接口
ip route add 192.168.4.0/24 via 192.168.0.254 dev eth0

# 设置默认网关为192.168.0.254
ip route add default via 192.168.0.254 dev eth0

# 删除路由规则
ip route del 192.168.4.0/24

# 检查网络连通性
ip route get 8.8.8.8
# 限制网络流量转发
ip route add prohibit 10.0.0.2
```

网桥 network bridge

```sh
# 删掉网桥
sudo ip link set dev docker0 down
sudo brctl delbr docker0
sudo brctl show
```

##### 服务器中TIME_WAIT状态连接数较多

```sh
# 执行以下命令，确认TIME_WAIT状态的连接数过多。
while true;do netstat -n | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a,S[a]}';sleep 1;done | grep TIME_WAIT
```

##### traceroute

`Hop #     RTT 1     RTT 2     RTT 3     Name/IP Address`
`10     81 ms     74 ms     74 ms     205.134.225.38`

`Hop Number` - This is the first column and is simply the number of the hop along the route. In this case, it is the tenth hop.

`RTT Columns` - The next three columns display the round trip time (RTT) for your packet to reach that point and return to your computer. This is listed in milliseconds. There are three columns because the traceroute sends three separate signal packets. This is to display consistency, or a lack thereof, in the route.

`Domain/IP column` - The last column has the IP address of the router. If it is available, the domain name will also be listed.

##### netstat

属于net-tools工具集

- `-t`、`-u`、`-w`和`-x`分别表示TCP、UDP、RAW和UNIX套接字连接;
- `-a` 显示出等待连接（也就是说处于监听模式）的套接字;
- `-l` 显示正在被监听(listen)的端口
- `-n` 表示直接显示端口数字而不是通过察看/etc/service来转换为端口名;
- `-p` 选项表示列出监听的程序
- `-r` 显示路由信息
- `-i` 显示网卡借口统计
- `-s` 显示网络协议统计
- `--numeric , -n`
       Show numerical addresses instead of trying to determine symbolic  host,
       port or user names.

Example

- `netstat -anp | grep PORT` Listening open ports
- `netstat -antup` 查看已建立的连接进程, 所占用的端口
- `netstat -tulpn | grep sqlservr`
- Mac OS X: `netstat -anv | grep PORT` 倒数第四个是进程号  或者 `lsof -i -P | grep 9091`

##### ss

short for Socket Statistics, 用来获取socket统计信息,显示和netstat类似的内容, ss命令是iproute工具集中的一员
从某种意义上说，iproute工具集几乎可以替代掉net-tools工具集，具体的替代方案是这样的：

用途             |    net-tool（被淘汰）|     iproute2
---                |    ---                |    ---
地址和链路配置     |    ifconfig        |     ip addr, ip link
路由表             |    route            |     ip route
邻居             |    arp                |     ip neigh
VLAN             |    vconfig            |     ip link
隧道             |    iptunnel        |     ip tunnel
组播             |    ipmaddr            |     ip maddr
统计             |    netstat            |    ss

- `ss -l` 查看所有打开的网络端口, `-pl`参数，会列出具体的程序名称
- `ss -a` 查看所有的socket连接
    `-ta` 只查看TCP sockets
    `-ua` 只查看UDP sockets
    `-wa` 只查看RAW sockets
    `-xa` 只查看UNIX sockets
- `ss -s` 查看当前服务器的网络连接统计

``` bash
    Total: 295 (kernel 312)
    TCP:   48 (estab 1, closed 31, orphaned 0, synrecv 0, timewait 0/0), ports 13

    Transport Total     IP        IPv6
    *         312       -         -
    RAW       0         0         0
    UDP       2         2         0
    TCP       17        12        5
    INET      19        14        5
    FRAG      0         0         0
```

##### iftop

查看哪些网络连接占用的带宽较多, 按照带宽占用高低排序, 可以确定那些占用带宽的网络连接
最上方的一行刻度是整个网络的带宽比例, 下面第1列是源IP, 第2列是目标IP, 箭头表示了二者之间是否在传输数据, 以及传输的方向. 最后三列分别是2s、10s、40s时两个主机之间的数据传输速率.
最下方的TX、RX分别代表发送、接收数据的统计, TOTAL则是数据传输总量.
在进入iftop的非交互界面后, 按 `p` 键可以打开或关闭显示端口, 按 `s` 键可以显示或隐藏源主机, 而按 `d` 键则可以显示或隐藏目标主机.

`-i` 选项可以指定要查看的网卡, 默认情况下, iftop会显示自己找到的第一个网卡;
`-n` 选项直接显示连接的IP, Do not do hostname lookups
`iftop -i eth1 -P -Bn`

##### iperf

Diagnosing network speed with [iperf](https://iperf.fr/iperf-doc.php)
`iperf`:
`-u` use UDP mode

TCP Clients & Servers

1. `iperf -s` to launch Iperf in server mode
2. `iperf -c <SERVER_IP>` to connect to the first server

UDP Clients & Servers

1. `iperf -s -u` to Start a UDP Iperf server
2. `iperf -c <SERVER_IP> -u` to Connect your client to your Iperf UDP server

##### nicstat

`nicstat` reports network utilization and saturation by network interface

##### ntop

1. 使用web 页面 `http://localhost:3002` 访问
2. `/etc/init.d/ntop restart`

##### bandwhich 查看带宽及不同 IP 地址产生的流量

查看当前什么程序在占用带宽，以及不同 IP 地址产生的流量。

displaying current network utilization by process, connection and remote IP/hostname

[imsnif/bandwhich: Terminal bandwidth utilization tool](https://github.com/imsnif/bandwhich)

##### [10款抓包工具 不止Wireshark和Tcpdump -腾讯云开发者社区-腾讯云](https://cloud.tencent.com/developer/article/2231025?areaId=106001)

1. Wireshark
2. Tcpdump
3. Fiddler
4. Solarwinds 带宽分析器 处理各种规模网络的故障、可用性和性能监控，监控显示网络设备的响应时间、可用性和性能，并通过开箱即用的仪表板、警报和报告检测、诊断和解决性能问题。
5. Free Network Analyzer 是一款出色的免费网络监控软件，可以分析计算机的有线或无线连接，可以捕获、过滤和显示所有流量数据并解码网络数据包原始数据
6. NAST英文全称：Network Analyzer Sniffer Tool，是一个基于 ncurses 的工具，适用于无 GUI 的 UNIX 服务器，可以在正常模式或混杂模式下嗅探网络接口上的数据包并记录它。
7. Kismet 不仅仅是个网络嗅探器，还可以分析隐藏网络或未广播 SSID 的流量，适用于无线流量和无线设备的抓包，可用于 *NIX、Windows Under Cygwin 和 OSX 环境。
8. EtherApe 具有许多与 WireShark 相同的功能，也是开源免费的，具有链路层、IP 和 TCP 模式，以图形方式显示网络活动。主机和链接的大小随流量而变化，图形化界面更加好看，但是它仅适用于 Linux、Unix 和 MacOS，不适用于Windows系统。
9. NetworkMiner 可以抓取实时流量，也可以分析以前捕获的以pcap 格式保存的流量的内容，适用于 Windows，由总部位于瑞典的小公司 Netresec 开发和支持，有免费版和收费版
10. WinDump 是 tcpdump 的 Windows 版本，可用于根据各种复杂规则监视、诊断和保存到磁盘网络流量，可以通过命令行、PowerShell 或远程 shell 运行。

#### 网络拓扑的发现

1. `netstat -ni` -i 提供网络接口的信息。我们还指定-n 标志以输出数值地址，而不是试图把它们反向解析成名字。
2. `netstat -nr` –r 展示路由表，也是另一种确定接口的方法。我们通常指定-n 标志以输出数值地址。它还给出默认路由器的IP地址。
3. `ifconfig eth0` 有了各个网络接口的名字，执行ifconfig 就可获得每个接口的详细信息。
4. `ping -b 206.168.112.127` 找出本地网络中众多主机的IP地址的方法之一是，针对从上一步找到的本地接口的广播地址执行ping 命令。

```sh
root@CentOS:~ # netstat -ni
Kernel Interface table
Iface       MTU Met    RX-OK RX-ERR RX-DRP RX-OVR    TX-OK TX-ERR TX-DRP TX-OVR Flg
em2        1500   0 34011461      0      0      0 23760915      0      0      0 BMRU
lo        16436   0 40477415      0      0      0 40477415      0      0      0 LRU

root@CentOS:~ # netstat -ar
Kernel IP routing table
Destination     Gateway         Genmask         Flags   MSS Window  irtt Iface
172.17.0.0      *               255.255.254.0   U         0 0          0 em2
link-local      *               255.255.0.0     U         0 0          0 em2
default         localhost       0.0.0.0         UG        0 0          0 em2

root@mac netstat -nr
Routing tables

Internet:
Destination        Gateway            Flags           Netif Expire
default            172.17.0.1         UGScg             en0
127.0.0.1          127.0.0.1          UH                lo0
172.17.0.1         a0:63:91:f0:fb:db  UHLWIir           en0   1184
172.17.0.15        6a:bb:64:50:8d:de  UHLWI             en0    395
172.17.1.255       ff:ff:ff:ff:ff:ff  UHLWbI            en0      !
```

### 操作系统 `uname -a`

find out system version: `cat /etc/*-release` or `ls /etc/*-release`
Redhat/CentOS版本 : `cat /etc/redhat-release`
`lsb_release -a`

[系统性能评估标准](http://blog.csdn.net/hguisu/article/details/39373311 )
             好                                |      坏                      |    糟糕
----|---------------------------------------|---------------------------|--------------------
CPU |    user% + sys%< 70%                      |    user% + sys%= 85%        |    user% + sys% >=90%
内存 |    "Swap In（si）＝0  Swap Out（so）＝0"    |    Per CPU with 10 page/s    |    More Swap In & Swap Out
磁盘 |    iowait % < 20%                        |    iowait % =35%            |    iowait % >= 50%

### 状态采集工具

讲究点, 要用来出报告的, 用`Zabbix`之类.
`ulimit -n` 查看系统默认的最大文件句柄数，系统默认是1024
`ulimit -c unlimited`  To enable core dumping
`lsof -n|awk '{print $1,$2}'|sort|uniq -c|sort -nr|head` 查看当前进程打开了多少句柄数, 第一列是打开的句柄数，第二列是进程ID
查看连接数(超过1024即较高) `netstat -na | sed -n '3,$p' |awk '{print $5}' | grep -v 127\.0\.0\.1 | grep -v 0\.0\.0\.0 | wc -l`

#### dstat

实时观察的, 对得够齐, 单位能自动转换. 不过`dstat`需要安装(`yum install dstat`)
dstat: 默认, 已有足够信息
`dstat -am`: 再多一个memory信息
`dstat -amN bond0,lo`:如果有bonding, dstat会把bond0和eth0算双份, 还有lo的也算到总量里, 所以还是用-N指定网卡好
要看IO细节, 还是要用`iostat -dxm 5`

#### vmstat - Report virtual memory statistics

`vmstat [options] [delay [count]]`
`vmstat -SM`

- `-w, --wide`             wide output
- `-S, --unit <char>`      define display unit
- `-M` switch shows the output in megabytes to make it easier to read

``` bash

    $ vmstat 2 3
    procs ---------memory----------     ---swap-- -----io---- -system-- ------cpu-----
     r  b swpd   free      buff  cache   si   so    bi    bo   in   cs  us sy id wa st
    34  0    0 200889792  73708 591828    0    0     0     5    6   10  96  1  3  0  0
    32  0    0 200889920  73708 591860    0    0     0   592 13284 4282 98  1  1  0  0
    32  0    0 200890112  73708 591860    0    0     0     0 9501  2154 99  1  0  0  0
```

Part `FIELD DESCRIPTION FOR VM MODE` in `man vmstat`
procs（进程）:

- r, run queue: 运行队列中进程数量(就是说多少个进程真的分配到CPU, 当这个值超过了CPU数目，就会出现CPU瓶颈了)
- b, blocked: 等待IO的进程数量

memory（内存）:

- swpd: 虚拟内存已使用大小，如果大于0，表示你的机器物理内存不足了，如果不是程序内存泄露的原因，那么你该升级内存了或者把耗内存的任务迁移到其他机器
- free: 空闲的物理内存的大小
- buff: 用作缓冲的内存大小
- cache: 用作缓存的内存大小

swap:

- si: Amount of memory swapped in from disk (/s). 每秒从磁盘读入虚拟内存的大小，如果这个值大于0，表示物理内存不够用或者内存泄露了
- so: Amount of memory swapped to disk (/s)，如果这个值大于0，同上

io：（现在的Linux版本块的大小为1024bytes）

- bi: 块设备每秒接收的块数量(数据从磁盘读入内存)，这里的块设备是指系统上所有的磁盘和其他块设备，默认块大小1024byte
- bo: 块设备每秒发送的块数量，例如我们读取文件，bo就要大于0。bi和bo一般都要接近0，不然就是IO过于频繁，需要调整

system：

- in, interrupts: 每秒中断数，包括时钟中断
- cs, context switch: 每秒上下文切换数, 值要越小越好，太大了，要考虑调低线程或者进程的数目

cpu（以百分比表示）

- us, user time: 用户进程执行时间占比(%)，例如在做高运算的任务时，如加密解密，那么会导致us很大，这样，r也会变大，造成系统瓶颈
- sy, system time: 系统进程执行时间占比(%)，如果太高，表示系统调用时间长，如IO频繁操作
- id: 空闲时间(包括IO等待时间)
- wa: 等待IO时间

`vmstat(8)` 命令, 每行会输出一些系统核心指标, 这些指标可以让我们更详细的了解系统状态. 后面跟的参数2, 表示每2秒输出一次统计信息, 表头提示了每一列的含义, 介绍和性能调优相关的列:
`r`: 等待在CPU资源的进程数. 这个数据比平均负载更加能够体现CPU负载情况, 数据中不包含等待IO的进程. 如果这个数值大于机器CPU核数, 那么机器的CPU资源已经饱和.
`free`: 系统可用内存数（以千字节为单位）, 如果剩余内存不足, 也会导致系统性能问题.
`si, so`: 交换区写入和读取的数量. 如果这个数据不为0, 说明系统已经在使用交换区（swap）, 机器物理内存已经不足
`us, sy, id, wa, st`: 这些都代表了CPU时间的消耗, 它们分别表示用户时间（user）、系统（内核）时间（sys）、空闲时间（idle）、IO等待时间（wait）和被偷走的时间（stolen, 一般被其他虚拟机消耗）.

上述这些CPU时间, 可以让我们很快了解CPU是否出于繁忙状态. 一般情况下, 如果用户时间和系统时间相加非常大, CPU出于忙于执行指令. 如果IO等待时间很长, 那么系统的瓶颈可能在磁盘IO.
示例命令的输出可以看见, 大量CPU时间消耗在用户态, 也就是用户应用程序消耗了CPU时间. 这不一定是性能问题, 需要结合r队列, 一起分析.

#### iostat - Average CPU Load, Disk Activity

主要用于查看机器磁盘IO情况. iostat命令属于sysstat工具包
`iostat 2 3`
参数:

- `2 3`表示, 数据显示每隔2秒刷新一次, 共显示3次.
- `-d` 表示, 显示设备（磁盘）使用状态
- `-x` 获得更多统计信息
- `-k` 某些使用block为单位的列强制使用Kilobytes为单位
- `-m` 以m为单位, 而不以block原始size

1. 查看详细状态 `iostat -dxm 3`
2. 查看磁盘状态 `iostat -d -k 2 3`

    输出列含义

    * `tps`: 每秒I/O传输请求量;
    * `kB_read/s`: 每秒读取多少KB;
    * `kB_wrtn/s`: 每秒写多少KB;
    * `kB_read`: 一共读了多少KB;
    * `kB_wrtn`: 一共写了多少KB.

3. 查看详细状态 `iostat -xz 2 3`

    该命令输出列的主要含义是:

    * `r/s, w/s`: 分别表示每秒读写次数, 读写量过大, 可能会引起性能问题.
    * `rkB/s, wkB/s` 分别表示每秒读写数据量(kB). 读写量过大, 可能会引起性能问题.
    * `await`: 平均每次设备I/O操作的等待时间 (毫秒). 这是应用程序在和磁盘交互时, 需要消耗的时间, 包括IO等待和实际操作的耗时. 如果这个数值过大, 可能是硬件设备遇到了瓶颈或者出现故障. **一般地系统I/O响应时间`await`应该低于5ms, 如果大于10ms就比较大了**.
    * `svctm, serviice time`: 平均每次设备I/O操作的服务时间 (毫秒). **如果svctm的值与await很接近，表示几乎没有I/O等待，磁盘性能很好，如果await的值远高于svctm的值，则表示I/O队列等待太长，系统上运行的应用程序将变慢**
    * `%util`: 设备利用率. 在统计时间内所有处理IO时间, 除以总共统计时间`util = (r/s+w/s) * (svctm/1000)`. 例如, 如果统计间隔1秒, 该设备有0.8秒在处理IO, 而0.2秒闲置, 那么该设备的%util = 0.8/1 = 80%, 所以该参数暗示了设备的繁忙程度, 经验值是 **如果`%util`超过60, 可能会影响IO性能**（可以参照IO操作平均等待时间）. 如果到达100%, 说明硬件设备已经饱和.
    * `avgrq-sz`, delta(rsect+wsect)/delta(rio+wio):  平均每次设备I/O操作的数据大小 (扇区).
    * `avgqu-sz`, delta(aveq)/s/1000 : 向设备发出的请求平均数量 (因为aveq的单位为毫秒). **如果`avgqu-sz`值大于1, 可能是硬件设备已经饱和（部分前端硬件设备支持并行写入）**
    * `rrqm/s`, delta(rmerge)/s: 每秒这个设备Merge的读操作数（当系统调用需要读取数据的时候, VFS将请求发到各个FS, 如果FS发现不同的读取请求读取的是相同Block的数据, FS会将这个请求合并Merge）;
    * `wrqm/s`, delta(wmerge)/s: 每秒这个设备merge的写操作数
    * `rsec/s`, delta(rsect)/s: 每秒读取的扇区数;
    * `wsec/s`, delta(wsect)/s: 每秒写入的扇区数.
    * `r/s`, delta(rio)/s: The number of read requests that were issued to the device per second;
    * `w/s`, delta(wio)/s: The number of write requests that were issued to the device per second;

    如果显示的是逻辑设备的数据, 那么设备利用率不代表后端实际的硬件设备已经饱和. 值得注意的是, 即使IO性能不理想, 也不一定意味这应用程序性能会不好, 可以利用诸如预读取、写缓存等策略提升应用性能.

4. 查看CPU部分状态值 `iostat -c 2 5`
    cpu属性值说明:

    * `%user`: CPU处在用户模式下的时间百分比.
    * `%nice`: CPU处在带NICE值的用户模式下的时间百分比.
    * `%system`: CPU处在系统模式下的时间百分比.
    * `%iowait`: CPU等待输入输出完成时间的百分比.
    * `%steal`: 管理程序维护另一个虚拟处理器时, 虚拟CPU的无意识等待时间百分比.
    * `%idle`: CPU空闲时间百分比.

    1. `%iowait`的值过高, 表示硬盘存在I/O瓶颈
    2. `%idle`值高, 表示CPU较空闲
    3. 如果`%idle`值高但系统响应慢时, 有可能是CPU等待分配内存, 此时应加大内存容量. **`%idle`值如果持续低于10, 那么系统的CPU处理能力相对较低, 表明系统中最需要解决的资源是CPU**.

#### sar (System Activity Recorder) - Collect and Report System Activity

`sar`命令来自sysstat工具包, 可以记录系统的CPU负载、I/O状况和内存使用记录, 便于历史数据的回放
可以查看CPU、内存和磁盘记录, 网络设备的吞吐率. 在排查性能问题时, 可以通过网络设备的吞吐量, 判断网络设备是否已经饱和.

- `sar 2 5`: for each 2 seconds. 5 lines are displayed.
- `-b` 显示磁盘I/O, Report I/O and transfer rate statistics
- `-d` Report activity for each block device
- `-r` 显示收集的内存记录
- `-u` CPU统计信息  Report CPU utilization
- `-n` Report network statistics
- `-B` Report paging statistics 分页信息
- `-W` 查看页面交换发生状况 页面发生交换时，服务器的吞吐量会大幅下降, 则服务器状况不良
    pswpin/s：每秒系统换入的交换页面（swap page）数量
    pswpout/s：每秒系统换出的交换页面（swap page）数量
- `-e [ hh:mm:ss ]` Set the ending time of the report
- `-s [ hh:mm:ss ]` Set the starting time of the report, `sar -s 20:00:00` 查看当天20:00:00后的CPU统计记录
- `-f [ filename ]` records from filename (created by the -o filename flag), file location: /var/log/sysstat/sadd or `/var/log/sa/sadd`, sysstat工具只存储1个月内的系统使用记录, 每天的记录以sadd为文件名保存. `sar -f /var/log/sysstat/sa08`查看本月8号的CPU使用记录

1. 要判断系统瓶颈问题，有时需几个 sar 命令选项结合起来
    * 怀疑CPU存在瓶颈，可用 `sar -u` 和 `sar -q` 等来查看
    * 怀疑内存存在瓶颈，可用 `sar -B`、`sar -r` 和 `sar -W` 等来查看
    * 怀疑I/O存在瓶颈，可用 `sar -b`、`sar -u` 和 `sar -d` 等来查看

2. 查看网络状态 `sar -n DEV 1`
    `-n`参数有6个不同的关键字: DEV | EDEV | NFS | NFSD | SOCK | ALL. DEV显示网络接口信息, EDEV显示关于网络错误的统计数据, NFS统计活动的NFS客户端的信息, NFSD统计NFS服务器的信息, SOCK显示套接字信息, ALL显示所有5个开关. 它们可以单独或者一起使用. 我们现在要用的就是`-n DEV`了

    * `IFACE`: LAN接口
    * `rxpck/s`: 每秒钟接收的数据包
    * `txpck/s`: 每秒钟发送的数据包
    * `rxbyt/s`: 每秒钟接收的字节数
    * `txbyt/s`: 每秒钟发送的字节数
    * `rxcmp/s`: 每秒钟接收的压缩数据包
    * `txcmp/s`: 每秒钟发送的压缩数据包
    * `rxmcst/s`: 每秒钟接收的多播数据包

    ``` bash

        $ sar -n DEV 2 3
        Linux 3.13.0-49-generic (titanclusters-xxxxx)  07/14/2015     _x86_64_    (32 CPU)
        12:16:48 AM     IFACE   rxpck/s   txpck/s    rxkB/s    txkB/s   rxcmp/s   txcmp/s  rxmcst/s   %ifutil
        12:16:49 AM      eth0  18763.00   5032.00  20686.42    478.30      0.00      0.00      0.00      0.00
        12:16:49 AM        lo     14.00     14.00      1.36      1.36      0.00      0.00      0.00      0.00
        12:16:49 AM   docker0      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
        12:16:49 AM     IFACE   rxpck/s   txpck/s    rxkB/s    txkB/s   rxcmp/s   txcmp/s  rxmcst/s   %ifutil
        12:16:50 AM      eth0  19763.00   5101.00  21999.10    482.56      0.00      0.00      0.00      0.00
        12:16:50 AM        lo     20.00     20.00      3.25      3.25      0.00      0.00      0.00      0.00
        12:16:50 AM   docker0      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
    ```

    如示例输出中, eth0网卡设备, 吞吐率大概在22 Mbytes/s, 既176 Mbits/sec, 没有达到1Gbit/sec的硬件上限.

3. 查看TCP连接状态 `sar -n TCP,ETCP 1`

    ``` bash
        $ sar -n TCP,ETCP 2 5
        Linux 3.13.0-49-generic (titanclusters-xxxxx)  07/14/2015    _x86_64_    (32 CPU)
        12:17:19 AM  active/s passive/s    iseg/s    oseg/s
        12:17:20 AM      1.00      0.00  10233.00  18846.00
        12:17:19 AM  atmptf/s  estres/s retrans/s isegerr/s   orsts/s
        12:17:20 AM      0.00      0.00      0.00      0.00      0.00
        12:17:20 AM  active/s passive/s    iseg/s    oseg/s
        12:17:21 AM      1.00      0.00   8359.00   6039.00
        12:17:20 AM  atmptf/s  estres/s retrans/s isegerr/s   orsts/s
        12:17:21 AM      0.00      0.00      0.00      0.00      0.00
    ```

    输出内容:
    * `active/s`: 每秒本地发起的TCP连接数, 既通过connect调用创建的TCP连接;
    * `passive/s`: 每秒远程发起的TCP连接数, 即通过accept调用创建的TCP连接;
    * `retrans/s`: 每秒TCP重传数量;
    TCP连接数可以用来判断性能问题是否由于建立了过多的连接, 进一步可以判断是主动发起的连接, 还是被动接受的连接. TCP重传可能是因为网络环境恶劣, 或者服务器压力过大导致丢包.

### File

To easily display all the permissions on a path, you can use `namei -om /path/to/check`

#### 文件特殊权限 SUID、SGID、STICKY简介

linux中除了常见的读（r）、写（w）、执行（x）权限以外, 还有3个特殊的权限, 分别是setuid、setgid和stick bit
setuid、setgid实例, /usr/bin/passwd 与/etc/passwd文件的权限

``` bash
sudo ls -l /usr/bin/passwd /etc/passwd
-rw-r--r-- 1 root root  1549 08-19 13:54 /etc/passwd
-rwsr-xr-x 1 root root 22984 2007-01-07 /usr/bin/passwd
```

从权限上看, /etc/passwd仅有root权限的写（w）权, 可实际上每个用户都可以通过/usr/bin/passwd命令去修改这个文件, 于是这里就涉及了linux里的特殊权限setuid, 正如-rwsr-xr-x中的s

stick bit （粘贴位） 实例, 查看/tmp目录的权限

``` bash
sudo ls -dl /tmp
drwxrwxrwt 6 root root 4096 08-22 11:37 /tmp
```

tmp目录是所有用户共有的临时文件夹, 所有用户都拥有读写权限, 这就必然出现一个问题, A用户在/tmp里创建了文件a.file, 此时B用户看了不爽, 在/tmp里把它给删了（因为拥有读写权限）, 那肯定是不行的. 实际上在/tmp目录中, 只有文件的拥有者和root才能对其进行修改和删除, 其他用户则不行, 因为有特殊权限stick bit（粘贴位）权限, 正如drwxrwxrwt中的最后一个t

##### 特殊位作用

- SUID:对一个可执行文件, 不是以发起者身份来获取资源, 而是以可执行文件的属主身份来执行.
- SGID对一个可执行文件, 不是以发起者身份来获取资源, 而是以可执行文件的属组身份来执行.
- STICKY: 粘滞位, 通常对目录而言. 通常对于全局可写目录（other也可写）来说, 让该目录具有sticky后, 删除只对属于自己的文件有效（但是仍能编辑修改别人的文件, 除了root的）. 不能根据安全上下文获取对别人的文件的写权限

##### 设置方式

- SUID: 置于 u 的 x 位, 原位置有执行权限, 就置为 s, 没有了为 S . `#chmod u+s`
- SGID: 置于 g 的 x 位, 原位置有执行权限, 就置为 s, 没有了为 S . `#chmod g+s`
- STICKY: 粘滞位, 置于 o 的 x 位, 原位置有执行权限, 就置为 t , 否则为T  `#chmod o+t`

在一些文件设置了特殊权限后, 字母不是小写的s或者t, 而是大写的S和T, 那代表此文件的特殊权限没有生效, 是因为你尚未给它对应用户的x权限
去除特殊位有:  `#chmou u-s`等
将三个特殊位的用八进制数值表示, 放于 u/g/o 位之前. 其中 suid :4 sgid:2  sticky:1
也可以这样设:

``` bash
setuid:chmod 4755 xxx
setgid:chmod 2755 xxx
stick bit:chmod 1755 xxx
```

### Kernel

Find Out If Running Kernel Is 32 Or 64 Bit (find out if my Linux server CPU can run a 64 bit kernel version (apps) or not)

`uname -a`    print system information:

Find Out CPU is 32bit or 64bit?

`grep flags /proc/cpuinfo`
CPU Modes:
    lm flag means Long mode cpu - 64 bit CPU
    Real mode 16 bit CPU
    Protected Mode is 32-bit CPU

### Network Command

`ip addr` = `ip a`
`ip addr show eth0`
`sudo dhclient -4`

#### nmap

`nmap -A -T4 IP` scan all open ports from the IP
`nmap -p PORT -Pn IP`
`nmap -A -T4 scanme.nmap.org playground`

EXAMPLES:
  nmap -v -A scanme.nmap.org
  nmap -v -sn 192.168.0.0/16 10.0.0.0/8
  nmap -v -iR 10000 -Pn -p 80


寻找网络中所有在线主机 `nmap -sP 192.168.0.0/24`

状态可能是 open(开放的)，filtered(被过滤的)， closed(关闭的)，或者unfiltered(未被过滤的)。

- open(开放的)意味着目标机器上的应用程序正在该端口接收 TCP 连接或者 UDP 报文。
- closed(关闭的) 端口没有应用程序在它上面监听，但是他们随时可能开放。
- filtered(被过滤的) 意味着防火墙，过滤器或者其它网络障碍阻止了该端口被访问，Nmap无法得知 它是 open(开放的) 还是 closed(关闭的)。
- unfiltered(未被过滤的) 当端口对Nmap的探测做出响应，但是Nmap无法确定它们是关闭还是开放
- open|filtered 和 closed|filtered时，如果Nmap报告状态组合时，那说明Nmap无法确定该端口处于两个状态中的哪一个状态。

`-Pn` Treat all hosts as online -- skip host discovery
`-p1-6553,8080` 扫描1到6553,和8080 端口
`-A`， 用来进行操作系统及其版本的探测
`-T<0-5>`: Set timing template (higher is faster)
`-v`: Increase verbosity level (use -vv or more for greater effect)
`-d`: Increase debugging level (use -dd or more for greater effect)

#### Restart network

`sudo service network-manager restart`
网卡的启动与关闭 `ifconfig en0 up/down`

#### network interface /etc/sysconfig/network-scripts/ifcfg-eth0

DEVICE   =   eth0
ONBOOT   =   yes
BOOTPROTO   =   static
BROADCAST=192.168.230.255
IPADDR=   192.168.230.160 (你需要的固定ip)
NETMASK=255.255.255.0
NETWORK=192.168.1.0
TYPE=Ethernet

如果需要动态分配IP, 那么
DEVICE   =   eth0
ONBOOT   =   yes
USERCTL   =   yes
BOOTPROTO   =   dhcp
重启网络服务service network restart

#### [Change system proxy settings from the command line using gsettings](http://ask.xmodulo.com/change-system-proxy-settings-command-line-ubuntu-desktop.html)

**Question**: change system proxy settings on Ubuntu desktop: "System Settings" -> "Network" -> "Network proxy". Is there a more convenient way to change proxy settings of desktop from the command line?
To modify a DConf setting: `$ gsettings set <schema> <key> <value>`
To read a DConf setting: `$ gsettings get <schema> <key>`

**Change System Proxy Setting to Manual from the Command Line**
The following commands will change HTTP proxy setting to "my.proxy.com:8000" on Ubuntu desktop.
`$ gsettings set org.gnome.system.proxy.http host 'my.proxy.com'`
`$ gsettings set org.gnome.system.proxy.http port 8000`
`$ gsettings set org.gnome.system.proxy mode 'manual'`

If you want to change HTTPS/FTP proxy to manual as well, use these commands:
`$ gsettings set org.gnome.system.proxy.https host 'my.proxy.com'`
`$ gsettings set org.gnome.system.proxy.https port 8000`
`$ gsettings set org.gnome.system.proxy.ftp host 'my.proxy.com'`
`$ gsettings set org.gnome.system.proxy.ftp port 8000`

To change Socks host settings to manual:
`$ gsettings set org.gnome.system.proxy.socks host 'my.proxy.com'`
`$ gsettings set org.gnome.system.proxy.socks port 8000`

All these changes above are limited to the current Desktop user only. If you want to apply the proxy setting changes system-wide, prepend sudo to gsettings command. For example:
`$ sudo gsettings set org.gnome.system.proxy.http host 'my.proxy.com'`
`$ sudo gsettings set org.gnome.system.proxy.http port 8000`
`$ sudo gsettings set org.gnome.system.proxy mode 'manual'`

**Change System Proxy Setting to Automatic from the Command Line**
If you are using proxy auto configuration (PAC), type the following commands to switch to PAC.
`$ gsettings set org.gnome.system.proxy mode 'auto'`
`$ gsettings set org.gnome.system.proxy autoconfig-url http://my.proxy.com/autoproxy.pac`
Clear System Proxy Setting from the Command Line

Finally, to remove manual/automatic proxy setting, and revert to no-proxy setting:
`$ gsettings set org.gnome.system.proxy mode 'none'`

### User

```sh
# Add a new group
groupadd <groupName>
# remove a user from a group groupName /etc/group
gpasswd --delete username groupName
# To find group memebership for username
groups username

# Add a new user to primary group
useradd -g <groupName> --create-home --comment "Account for running Confluence" --shell /bin/zsh confluence
useradd -g <groupName> <username>
# Add a new user to secondary group
useradd -G <groupName> <username>
# Remove user from group which is not list in the command
usermod -G {groupname1,groupname2,...} <username>

# add the user to the sudo group /etc/sudoers, edit it by visudo.
# sudo group: wheel in CentOS, sudo in Ubuntu
usermod -aG sudoGroupName username
# configure sudo to never ask for your password. add the following line in the bottom of the file.
username ALL=(ALL) NOPASSWD: ALL
# ubuntu
%sudo ALL=(ALL) NOPASSWD: ALL

# update password
passwd <username>
# 管理所有用户
vipw
# get the user
id <username>
# Find out user group identity
id -nG <username>
# Get all groups in system
less /etc/group
# or
getent group
# To list groups the current user belong to
groups
```

#### sudo

```sh
# 默认不使用用户的环境变量，使用最小权限去执行
sudo visudo
# -E 表示使用用户的环境变量
sudo -E visudo
```

```sh
# 授权规则格式：用户 登入主机=(代表用户) 命令
root ALL=(ALL) ALL

# 格式说明：
# user: 运行命令者的身份 以%开头的是组
# host: 通过哪些主机
# (runas)：以哪个用户的身份
# command: 运行哪些命令

# 指定命令
student ALL=(root) /sbin/pidof,/sbin/ifconfig

# 允许用户 postgres 不需要密码执行 sudo systemctl restart postgresql 命令
postgres ALL=(ALL)NOPASSWD: /bin/systemctl start postgresql
postgres ALL=(ALL)NOPASSWD: /bin/systemctl stop postgresql
postgres ALL=(ALL)NOPASSWD: /bin/systemctl restart postgresql
# 用户添加无密码运行命令
yourusername ALL=(ALL) NOPASSWD: /usr/bin/make, /usr/bin/git
# 用户添加无密码运行所有命令
yourusername ALL=(ALL) NOPASSWD: ALL

# 用户组（例如sudo组）无密码运行所有命令
%sudo ALL=(ALL) NOPASSWD: ALL

# 通过 env_keep 保留用户自己的环境变量
# This allows running arbitrary commands, but so does ALL, and it means
# different sudoers have their choice of editor respected.
Defaults:%sudo env_keep += "EDITOR"
# 保留 JAVA_HOME 和 PATH 两个环境变量
Defaults env_keep += "JAVA_HOME PATH"

# 全局设置 env_reset 表示重置环境变量，即不使用用户的 $PATH
Defaults        env_reset
# !env_reset 表示不重置环境变量，使用用户的
#Defaults       !env_reset
```

### update hostname

`hostname newname`
`vi /etc/hostname`
`vi /etc/hosts`

### 设置 DNS

修改 /etc/resolv.conf ，默认为软连接，可以不再使用软连接，创建新文件

```sh
sudo apt install resolvconf
sudo vi /etc/resolvconf/resolv.conf.d/head
sudo resolvconf -u
cat /etc/resolv.conf

nameserver 192.168.1.1
```

### ca-certificates update

1. `sudo mkdir /usr/share/ca-certificates/extra`
2. `sudo cp /path/to/ca.cert /usr/share/ca-certificates/extra/com.ca.crt`
3. `sudo dpkg-reconfigure ca-certificates` or `sudo update-ca-certificates`
4. if no cert installed, then `sudo vi /etc/ca-certificates.conf`, add `extra/com.ca.crt`
then `sudo update-ca-certificates`

## Ubuntu Installation

check your Ubuntu version using any of the following methods:

1. Use the `lsb_release -a` command.
2. Use the `/etc/lsb-release` or `/etc/os-release` command.
3. Check the `/etc/issue` file.
4. Use the `hostnamectl` command.

### ubuntu shortcut

Terminal Use keyboard shortcuts

Ctrl + PgUp: Go to the next tab
Ctrl + PgDn: Go to the previous tab
Ctrl + Shift + PgUp: Reorder tabs by moving the current tab up
Ctrl + Shift + PgDn: Reorder tabs by moving the current tab down
Alt + 1: Go to the first tab
Alt + 2: Go to the second tab
Alt + 3: Go to the third tab
Shift + Ctrl + w: Close the current tab

### Main directories

[LinuxFilesystemTreeOverview](https://help.ubuntu.com/community/LinuxFilesystemTreeOverview)
The standard Ubuntu directory structure mostly follows the Filesystem Hierarchy Standard, which can be referred to for more detailed information.
Here, only the most important directories in the system will be presented.
/bin is a place for most commonly used terminal commands, like ls, mount, rm, etc.
/boot contains files needed to start up the system, including the Linux kernel, a RAM disk image and bootloader configuration files.
/dev contains all device files, which are not regular files but instead refer to various hardware devices on the system, including hard drives.
/dev/shm 这个目录是在内存里 采用tmpfs文件系统 默认值是内存的一半
/etc contains system-global configuration files, which affect the system''s behavior for all users.
/home home sweet home, this is the place for users'' home directories.
/lib contains very important dynamic libraries and kernel modules
/usr contains the majority of user utilities and applications, and partly replicates the root directory structure, containing for instance, among others, /usr/bin/ and /usr/lib.
/var is dedicated variable data that potentially changes rapidly; a notable directory it contains is /var/log where system log files are kept.
通常情况下, linux会这样放软件的组件:
程序的文档->/usr/share/doc; /usr/local/share/doc
程序->/usr/share; /usr/local/share
程序的启动项->/usr/share/apps; /usr/local/share
程序的语言包->/usr/share/locale; /usr/local/share/locale
可执行文件->/usr/bin; /usr/local/bin
而有的软件为了和系统组件分隔开, 选择栖息于 /opt, 但目录结构往往是一样的, 把/usr或/usr/local 替换为了/opt/"软件名"
~/share all softwares
~/opt softwares

### [Source code](https://peteris.rocks/blog/htop/#source-code)

``` bash
$ which uptime
/usr/bin/uptime
$ dpkg -S /usr/bin/uptime
procps: /usr/bin/uptime
```

Here we find out that uptime is actually located at `/usr/bin/uptime` and that on Ubuntu it is part of the `procps` package.
You can then go to packages.ubuntu.com and search for the package there.
Here is the page for [procps](http://packages.ubuntu.com/source/xenial/procps)
If you scroll to the bottom of the page, you'll see links to the source code repositories:

- Debian Package Source Repository git://git.debian.org/collab-maint/procps.git
- Debian Package Source Repository ([Browsable](https://anonscm.debian.org/cgit/collab-maint/procps.git/))

### Software manage

dpkg -i AdbeRdr*.deb  #install
abort installation or recover from failed installing by apt-get
sudo dpkg -r packageName

uninstall qq

1. find the name: dpkg -l | grep package
2. sudo dpkg -r qq-for-wine 或 sudo dpkg -P qq-for-wine
sudo apt-get remove acroread;sudo apt-get autoremove  #uninstall

apt-cache search #package 搜索包

aptitude name for failed resolving dependency

#### apt command

```sh
repos/mirros location: /etc/apt/
3rd party repos/mirros location: /etc/apt/sources.list.d

apt-get 下载后, 软件所在路径是 /var/cache/apt/archives

apt-cache policy maven    #check the version of package from apt-get
apt-cache pkgnames #To list all the available packages,
apt-cache pkgnames packageName    #To find and list down all the packages starting with 'packageName'
apt-cache search packageName    #To find out the package name and with it description before installing
apt-cache show packageName    #check information of package along with it short description say (version number, check sums, size, installed size, category etc)

apt-get install
apt-get install packageName --only-upgrade    #do not install new packages but it only upgrade the already installed packages and disables new installation of packages
apt-get install vsftpd=2.3.5-3ubuntu1    #Install Specific Package Version

apt-get remove vsftpd    #To un-install software packages without removing their configuration files
apt-get purge vsftpd    #To remove software packages including their configuration files
apt-get --download-only source vsftpd    #To download only source code of particular package
apt-get source vsftpd    #To download and unpack source code of a package to a specific directory
apt-get --compile source goaccess    #download, unpack and compile the source code at the same time
apt-get download nethogs    #Download a Package Without Installing
apt-get changelog vsftpd    #downloads a package change-log and shows the package version that is installed

apt clean
apt autoclean
apt autoremove
```

ubuntu:24.04

```sh
docker run -it --rm -v /data/docker/ubuntu/package:/data/package
# default download path /var/cache/apt/archives/
# cp /var/cache/apt/archives/*.deb <your_directory_here>
sudo apt install --download-only docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

#### dpkg command

sudo apt-get install gdebi    #gdebi is a simple tool to install deb files,apt does the same, but only for remote (http, ftp) located package repositories.

dpkg -i packageName    #Install a Package
dpkg -l    #List all the installed Packages
dpkg -r packageName    #The "-r" option is used to remove/uninstall a package
dpkg -p packageName    #use 'p' option in place of 'r' which will remove the package along with configuration files
dpkg -c packageName    #View the Content of a Package
dpkg -S packageName    #显示所有包含该软件包的目录
dpkg -s packageName    #Check a Package is installed or not
dpkg -L packageName    #Check the location of Packages installed
dpkg --unpack packageName    #Unpack the Package but do not Configure
dpkg --configure packageName    #Reconfigure a Unpacked Package

#### install and manage RPMs

convert single RPM files into DEBs with Alien:

```sh
sudo apt-get install alien
sudo alien my_package.rpm
sudo dpkg -i my_package.deb
```

### mount disk

用mount挂载你的windows分区, 事先以root权限用fdisk -l查看. 你就知道该挂载哪个了
mount /dev/cdrom /mnt/cdrom 挂载光盘

auto mount your NTFS disk: Install pysdm or ntfs-config
Mount Windows drivers automatically
This works in 12.10, 13.04, 13.10 and 14.04
Type Disks in Dash, and you will get:
Click on the little gears, to get the sub menu, and choose Edit Mount Options. After that you will see:
Change the Automatic Mount Options to ON. do that to all the drives that you need mounted on start-up.
Note: Be careful with you modify, it may cause the system not to work properly.

先用FDISK命令查看一下磁盘的UUID

```sh
sudo fdisk -l
id username
vi /etc/fstab
# /dev/sda3      /media/program    ntfs    defaults,nofail,utf8,uid=1000,gid=1000,dmask=022,fmask=133     0       0    #defaults = rw, suid, dev, exec, auto, nouser, and async.

# 追加 uuid 到 fstab
echo `blkid /dev/vdb1 | awk '{print $2}' | sed 's/\"//g'` /data ext4 defaults,nofail 0 0 >> /etc/fstab
```


auto= mounted at boot
noauto= not mounted at boot
user= when mounted the mount point is owned by the user who mounted the partition
users= when mounted the mount point is owned by the user who mounted the partition and the group users
ro= read only
rw= read/write
dmask: directory umask
fmask: file umask

#### iso file mount

`sudo mkdir /mnt/iso`
`sudo mount -o loop ubuntu-16.10-server-amd64.iso /mnt/iso`
`ls /mnt/iso/`

#### Permission mapping

4     read
2     write
1     execute

#### NTFS permission The mode is determined by the partition's mount options

bash script.sh    #You can always explicitly invoke the script interpreter

## 入侵排查思路

[第2篇:Linux入侵排查 · 应急响应实战笔记](https://xzbzq.github.io/Emergency-Response-Notes/Summary/第2篇：Linux入侵排查.html)

### 基本使用

```sh
1、用户信息文件/etc/passwd
root:x:0:0:root:/root:/bin/bash
account:password:UID:GID:GECOS:directory:shell
用户名：密码：用户ID：组ID：用户说明：家目录：登陆之后shell
注意：无密码只允许本机登陆，远程不允许登陆

2、影子文件/etc/shadow
root:$6$oGs1PqhL2p3ZetrE$X7o7bzoouHQVSEmSgsYN5UD4.kMHx6qgbTqwNVC5oOAouXvcjQSt.Ft7ql1WpkopY0UV9ajBwUt1DpYxTCVvI/:16809:0:99999:7:::
用户名：加密密码：密码最后一次修改日期：两次密码的修改时间间隔：密码有效期：密码修改到期到的警告天数：密码过期之后的宽限天数：账号失效时间：保留
who     查看当前登录用户（tty本地登陆  pts远程登录）
w       查看系统信息，想知道某一时刻用户的行为
uptime  查看登陆多久、多少用户，负载
```

### 入侵排查

```sh
1、查询特权用户特权用户(uid 为0)
[root@localhost ~]# awk -F: '$3==0{print $1}' /etc/passwd
2、查询可以远程登录的帐号信息
[root@localhost ~]# awk '/\$1|\$6/{print $1}' /etc/shadow
3、除root帐号外，其他帐号是否存在sudo权限。如非管理需要，普通帐号应删除sudo权限
[root@localhost ~]# more /etc/sudoers | grep -v "^#\|^$" | grep "ALL=(ALL)"
4、禁用或删除多余及可疑的帐号
    usermod -L user    禁用帐号，帐号无法登录，/etc/shadow第二栏为!开头
    userdel user       删除user用户
    userdel -r user    将删除user用户，并且将/home目录下的user目录一并删除
```
