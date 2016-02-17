[TOC]

学习系统结构的最好方法是自己做一个linux系统，再也没有什么能比自己做一个linux系统更能学习系统结构的了。LFS (linux from strach)可以教你从源代码自己编译一个系统。通过自己编译一个系统，你就可以了结linux系统结构，知道哪些文件是干什么用的，以及他们如何协调 工作。
Linux内核设计与实现 Linux Kernel Development(Third Edition)-Robort Love

## Recent
为了方便地键入长命令，在设置你的编辑器后（例如 export EDITOR=vim），键入 ctrl-x ctrl-e 会打开一个编辑器来编辑当前命令。在 vi 模式下则键入 escape-v 实现相同的功能。
vimtutor: vim interactive guide
CTRL+h: show hidden files
nautilus: open your home folder
location: make a command can be call anywhere
/usr/share/icons/ubuntu-mono-dark/mimes/16
tweak get the theme ubuntu-mono-dark
`ln -sfn` update a symbolic link
date_str=`date +%Y%m%d%H%M%S`;echo $date_str
`groups username`	To find group memebership for username
sudo apt-get install -f fixed it.

pgrep 和 pkill
pgrep -l apache2
ps -A -opid,stime,etime,args 查看进程的启动时间
sort <file> | uniq -c
du -s * | sort -n | tail	列出当前目录里最大的10个文件。

escape square brackets with backslash:   `grep "test\[1]" log.txt`
for `less`, the sequences \(, \), \n, and in some implementations \{, \}, \+, \?, \| and other backslash+alphanumerics have special meanings. You can get away with not quoting $^] in some positions in some implementations.

### Move Running Process to Background 
#### ALREADY RUNNING PROCESS INTO BACKGROUND
1. CTRL+z
2. jobs
or alternate method which lists the PID (note the PID is not the jobnum, the job number is shell specific to the current bash session): jobs -l
3. bg %jobnum
or alternate method %jobnum & for example for the first job %1 &

To place a foreground process in the background: suspend the foreground process (with CTRL+z) then enter the bg command to move the process into the background.
Show the status of all background and suspended jobs: jobs
Bring a job back into the foreground: fg %jobnumber
Bring a job back into the background: bg %jobnumber

#### ALREADY RUNNING PROCESS INTO NOHUP
0. Run some SOMECOMMAND
1. ctrl+z to stop (pause) the program and get back to the shell
2. bg to run it in the background
3. disown -h so that the process isn't killed when the terminal closes
4. Type exit to get out of the shell because now your good to go as the operation will run in the background in it own process so its not tied to a shell

This process is the equivalent of running nohup SOMECOMMAND

### LibreOffice
CTRL+0 (zero) 	Apply Default paragraph style
CTRL+1 	Apply Heading 1 paragraph style
CTRL+ALT+PageDown: Navigating from comment to comment 
CTRL+ALT+c: create comment 
ALT+Insert, and then press the up or down arrow key:  insert a new row in a table
ALT+Delete, and then press the up or down arrow key.


## Basic Command
### VI
#### Configuration
:set nu / :set nonu	(不)列出行号 (nu为行数)
:set ic / :set noic	vi在查找过程中(不)区分大小写 :set ignorecase/:set noignorecase

#### Move
`%`	move to the matching parenthesis

#### Basic vi
`~`	切换大小写
`:sp`	split window above and below
`:sh`	暂时退出vi到系统下，结束时按CTRL+d则回到vi
`:r!command`	将命令command的输出结果放到当前行【强大】
`:x` == `:wq` 当文件被修改时两个命令时相同的。但如果未被修改，使用`:x`不会更改文件的修改时间，而使用`:wq`会改变文件的修改时间
`:w !sudo tee %`  在VIM中保存一个当前用户无权限修改的文件 查阅vim的文档（输入:help :w），会提到命令:w!{cmd}，让vim执行一个外部命令{cmd}，然后把当前缓冲区的内容从stdin传入。tee是一个把stdin保存到文件的小工具。而%，是vim当中一个只读寄存器的名字，总保存着当前编辑文件的文件路径。所以执行这个命令，就相当于从vim外部修改了当前编辑的文件  
replace a character by a newline in Vim: Use `\r` instead of `\n`.  

改变与替换操作命令 
<r> 替换光标所在的字符 
<R> 替换字符序列 
<cw> 替换一个单词 
<ce> 同<cw> 
<cb> 替换光标所在的前一字符 
<c$> 替换自光标位置至行尾的所有字符 
<C> 同<c$> 
<cc> 替换当前行

`yw`	只有当当前光标处于单词的第一个字母时才是"复制整个单词"(包含末尾的空格)
`yiw`	不管当前光标处于单词的哪个字母，都是复制整个单词(不包括末尾的空格)
`diw`	删除当前光标所在的word(不包括空白字符)，意为Delete Inner Word 两个符号之间的单词
`dt<LETTER>`	删除所有的内容，直到遇到<LETTER>
`daw`	删除当前光标所在的word(包括空白字符)，意为Delete A Word
`guw`	光标下的单词变为小写
`gUw`	光标下的单词变为大写
`ga`	显示光标下的字符在当前使用的encoding下的内码
`CTRL+SHIFT++`	zoom in on your terminal
`CTRL+-`	Zoom out

`.` 命令重复上次的修改。
`:!` command allows you to enter the name of a shell command
修改在这里就是插入、删除或者替换文本。能够重复是一个非常强大的机制。如果你基于它来安排你的编辑，许多修改将变得只是敲.键。留意其间的其他修改，因为它会替代你原来要重复的修改。相反，你可以用m命令先标记这个位置，继续重复你的修改，稍后再返回到这个位置。
重复修改一个单词。
如果是在整个文件中，你可以使用:`s`（substitute）命令。如果只是几个地方需要修改，一种快速的方法是使用`*`命令去找到下一个出现的单词，使用`cw`命令修改它。然后输入`n`去找到下一个单词，输入英文逗点 . 去重复`cw`命令。
删除多行
1. 如果要删除的段落的下一行是空行 一般用`d}` , 按两个键就可以了 多段的时候再按 .
2. 如果要删除的段落的下一行不是空行 则很容易找到该行的模式， 如该行存在function字串 一般 `d/fu` 也就搞定了
输入单词A的前几个字母，然后CTRL+n补全。<CTRL+o><CTRL+n> <CTRL+o><CTRL+p> 只是简单的上下文补全，还有<CTRL+o><CTRL+f> 用于对目录名进行补全

#### Move around inside of long line
`gj` and `gk` move up and down one displayed line by using gj and gk. That way, you can treat your one wrapped line as multiple lines

#### 文件对比 合并 多窗口
diff -u
vimdiff  FILE_LEFT  FILE_RIGHT
:qa (quit all)同时退出两个文件
:wa (write all)
:wqa (write, then quit all)
:qa! (force to quit all)

CTRL+w K(把当前窗口移到最上边)
CTRL+w H(把当前窗口移到最左边)
CTRL+w J(把当前窗口移到最下边)
CTRL+w L(把当前窗口移到最右边)
CTRL+w,r 交换上/下、左/右两个分隔窗口的位置
其中2和4两个操作会把窗口改成垂直分割方式。
在两个文件之间来回跳转，可以用下列命令序列CTRL+w, w
可以使用快捷键在各个差异点之间快速移动。跳转到下一个差异点：]c. 反向跳转是：[c
`> -`, `> +` 调整窗口大小

dp (diff "put") 把一个差异点中当前文件的内容复制到另一个文件里
do (diff "get"，之所以不用dg，是因为dg已经被另一个命令占用了)把另一个文件的内容复制到当前行
:diffu[pdate] #更新diff 修改文件后，vimdiff会试图自动来重新比较文件，来实时反映比较结果。但是也会有处理失败的情况，这个时候需要手工来刷新比较结果：
zo (folding open，之所以用z这个字母，是因为它看上去比较像折叠着的纸) 展开被折叠的相同的文本行
zc (folding close)重新折叠

#### Mutiple tab
:n next file :p previous file
:bn 和 :bp :n 使用这两个命令来切换下一个或上一个文件。（陈皓注：我喜欢使用:n到下一个文件）

#### Replace
/可以用#代替
:g/old			查找old，并打印出现它的每一行
:s/old/new		替换当前行第一个old
:s/old/new/gc	当前行old全替换并需要确认
:n,ms/old/new/g	n,m are the line numbers; n can be (.), which represent current line
:%s/old/new/gc	全文替换,也可用1,$表示从第一行到文本结束
:%s/^ *//gc		去掉所有的行首空格
:s：等同于 :s//~/，即会重复上一次替换
:& repeat last :s command
:g/^\s*$/d	delete the blank lines
:%s/\s\s/\t/gc	convert two space(\s\s) to tab(\t)
:%s/\s\+/,/g	use a substitution (:s///) over each line (%) to replace all (g) continuous whitespace (\s\+) with a comma (,).
pattern [^0-9]*,	matches string start with non-number until to (,)

#### custom keyboard shortcut
`inoremap jj <ESC>`	Remap Your ESCAPE Key in Vim
`nnoremap j VipJ`
`:map`	列出当前已定义的映射
 

#### VI正则表达式
元字符 	说明
. 	匹配任意字符
[abc] 	匹配方括号中的任意一个字符，可用-表示字符范围。如[a-z0-9]匹配小写字母和数字
[^abc] 	匹配除方括号中字符之外的任意字符
\d 	匹配阿拉伯数字，等同于[0-9]
\D 	匹配阿拉伯数字之外的任意字符，等同于[^0-9]
\x 	匹配十六进制数字，等同于[0-9A-Fa-f]
\X 	匹配十六进制数字之外的任意字符，等同于[^0-9A-Fa-f]
\l 	匹配[a-z]
\L 	匹配[^a-z]
\u 	匹配[A-Z]
\U 	匹配[^A-Z]
\w 	匹配单词字母，等同于[0-9A-Za-z_]
\W 	匹配单词字母之外的任意字符，等同于[^0-9A-Za-z_]
\t 	匹配<TAB>字符
\s 	匹配空白字符，等同于[\t]
\S 	匹配非空白字符，等同于[^\t]

一些普通字符需转意
元字符 	说明
\* 	匹配* 字符
. 	匹配. 字符
\/ 	匹配 / 字符
\ 	匹配 \ 字符
\[ 	匹配 [ 字符
\] 	匹配 ] 字符

表示数量的元字符
元字符 	说明
* 	匹配0-任意个
\+ 	匹配1-任意个
\? 	匹配0-1个
\{n,m} 	匹配n-m个
\{n} 	匹配n个
\{n,} 	匹配n-任意个
\{,m} 	匹配0-m个

表示位置的元字符
元字符 	说明
$ 	匹配行尾
^ 	匹配行首
\< 	匹配单词词首
\> 	匹配单词词尾


### find grep sed
```
grep pattern files - 搜索 files 中匹配 pattern 的内容
grep -r pattern dir - 递归搜索 dir 中匹配 pattern 的内容
grep -l old *.htm | xargs sed -n "/old/p"  (sed -n '/old/p' 查询个数; sed -i 's/old/new/g' 替换)
sed -n '/old/p' `grep -l old *.htm`
sed -i 's/package com.pfizer.gdms.tools;//g' ../*/ExportGtcConfigFile.java
sed -i 's#../../gxt#../../gxt2#g' */*.html

:%s#":.*$#gc   "
sed -i 's#":.*$#;//#g' test
sed -i 's#":.*//#;//#g' test
sed -i 's#":#;//#g' test
sed -i 's#"#private String #g' test

sed -i 's#\s`#private String #g' test
sed -i 's#`\(.*\)COMMENT#;//#g' test
sed -i "s#'##g" test
sed -i "s#,##g" test
sed -i 's/_[a-z]/\U&\E/g' test
sed -i 's/_//g' test

删除行尾空格：:%s/\s+$//g
删除行首多余空格：%s/^\s*// 或者 %s/^ *//
删除沒有內容的空行：%s/^$// 或者 g/^$/d
删除包含有空格组成的空行：%s/^\s*$// 或者 g/^\s*$/d
删除以空格或TAB开头到结尾的空行：%s/^[ |\t]*$// 或者 g/^[ |\t]*$/d
替换变量:在正则式中以\(和\)括起来的正则表达式，在后面使用的时候可以用\1、\2等变量来访问\(和\)中的内容。
把文中的所有字符串"abc……xyz"替换为"xyz……abc"可以有下列写法
    :%s/abc\(.*\)xyz/xyz\1abc/g
    :%s/\(abc\)\(.*\)\(xyz\)/\3\2\1/g
把ABC转换为小写
    echo "ABC" | sed 's/[A-Z]*/\L&\E/' 或
    echo "ABC" | sed 's/[A-Z]/\l&/g'
    把abc转换为大写
    echo "abc" | sed 's/[a-z]*/\U&\E/' 或
    echo "abc" | sed 's/[a-z]/\u&/g'

    echo "ab_c" | sed 's/_[a-z]/\u&/g'
    echo "ab_c" | sed 's/_[a-z]/\U&\E/g'
	‘s/[ ] [ ] [ ] */[ ]/g’ 删除一个以上空格，用一个空格代替
	‘s/^[ ][ ] *//g’ 删除行首空格
	‘s/\ .[ ][ ] */[ ]/g’ 删除句点后跟两个或更多空格，代之以一个空格
	‘s/\ . $//g’ 删除以句点结尾行
	‘-e/abcd/d’ 删除包含a b c d的行
	‘/^ $/d’ 删除空行
	‘s/^ .//g’ 删除第一个字符
	‘s/COL \ ( . . . \ )//g’ 删除紧跟C O L的后三个字母
	‘s/^ \///g’ 从路径中删除第一个\
	‘s/[ ]/[TAB]//g’ 删除所有空格并用tab键替代
	‘S/^ [TAB]//g’ 删除行首所有tab键
	‘s/[TAB] *//g’ 删除所有tab键

find . -name '*.htm' | xargs  perl -pi -e 's|old|new|g'
find . -type f -name "*.log" | xargs grep "ERROR" : 从当前目录开始查找所有扩展名为.log的文本文件，并找出包含"ERROR"的行
find . -name dfc.properties
delete file except notDelete.txt: find . -type f -not -name notDelete.txt | xargs rm
```

#### 替换多文件中的内容
`find . -name '*.htm' | xargs sed -n '/old/p'`  (查询个数)
`find . -name '*.htm' | xargs sed -i 's/old/new/g'` (替换或者 s#old#new#g)

#### 删除.svn文件夹
find . -type d -name ".svn" | xargs rm -rf
find . -name "*.svn"  | xargs rm -rf  或
find . -type d -iname ".svn" -exec rm -rf {} \;

#### 多目录重命名文件
```
for file in `find . -name 'sync1.properties'`; do echo $file; done
for i in `find . -name sync1.properties`; do mv $i `echo $i | sed 's/sync1.properties$/sync.properties/'`; done
```

#### 查找包含class的jar文件
```
find . -iname \*.jar | while read JARF; do jar tvf $JARF | grep CaraCustomActionsFacade.class && echo $JARF ; done
find . -iname \*.jar | while read JARF; do /app/java/jdk1.6.0_35/bin/jar tvf $JARF | grep FunctionName.class && echo $JARF ; done
```

#### 文件名乱码处理
1. `ls -i` print the index number of each file(文件的i节点) 12345
2. `find . -inum 12345 -print -exec rm {} -r \;` rm
3. `find . -inum 12345 -exec mv {} NewName \;` mv
命令中的"{}"表示find命令找到的文件，在-exec选项执行mv命令的时候，会利用按i节点号找到的文件名替换掉"{}"

convmv -f 源编码 -t 新编码 [选项] 文件名 #linux文件名编码批量转换
转换文件名由GBK为UTF8 :  convmv -r -f cp936 -t utf8 --notest --nosmart *

### xargs
xargs 工具的经典用法示例 
```
find some-file-criteria some-file-path | xargs some-great-command-that-needs-filename-arguments
kill -9 `ps -ef |grep GA | grep -v grep | awk '{print $2}'`
kill $(ps -aef | grep java | grep apache-tomcat-7.0.27 | awk '{print $2}')
kill -9 `netstat -ap |grep 6800 |awk '{print $7}'|awk -F "/" '{print $1}'`
```
awk <pattern> '{print <stuff>}' <file> 可以用来删掉所有空行
Print every line that has at least one field: awk 'NF > 0' data
其中单引号中的被大括号括着的就是awk的语句，注意，其只能被单引号包含。其中的$1..$n表示第几例。注：$0表示整个行。
过滤记录
awk '$3==0 && $6=="LISTEN" ' netstat.txt 其中的"=="为比较运算符。其他比较运算符：!=, >, <, >=, <=
如果我们需要表头的话，我们可以引入内建变量NR：awk '$3==0 && $6=="TIME_WAIT" || NR==1 ' netstat.txt

### shell

xargs echo
在bash的脚本中，你可以使用 set -x 来debug输出。使用 set -e 来当有错误发生的时候abort执行。考虑使用 set -o pipefail 来限制错误。还可以使用trap来截获信号（如截获ctrl+c）。
在bash 脚本中，subshells (写在圆括号里的) 是一个很方便的方式来组合一些命令。一个常用的例子是临时地到另一个目录中

read -p "Press [Enter] key to continue"
read -n 1 -p "Press any key to continue"
sleep 2; echo 'end sleep 2 sec'

﻿$? 上一个命令的返回代码。0为true, 1为false
$$进程标识号
$*，该变量包含了所有输入的命令行参数值
string string不为空 

#### Common Bash comparisons
Operator	Meaning	Example
-z	Zero-length string	[ -z "$myvar" ]
-z string string为空
-n	Non-zero-length string	[ -n "$myvar" ]
=	String equality	[ "abc" = "$myvar" ]
!=	String inequality	[ "abc" != "$myvar" ]
-eq	Numeric equality	[ 3 -eq "$myinteger" ]
-ne	Numeric inequality	[ 3 -ne "$myinteger" ]
-lt	Numeric strict less than	[ 3 -lt "$myinteger" ]
-le	Numeric less than or equals	[ 3 -le "$myinteger" ]
-gt	Numeric strict greater than	[ 3 -gt "$myinteger" ]
-ge	Numeric greater than or equals	[ 3 -ge "$myinteger" ]
-f	Exists and is regular file	[ -f "$myfile" ]
[ -f "somefile" ] ：判断是否是一个文件
-d	Exists and is directory	[ -d "$mydir" ]
-d 是否是目录
-nt	First file is newer than second one	[ "$myfile" -nt ~/.bashrc ]
-ot	First file is older than second one	[ "$myfile" -ot ~/.bashrc ]
[ -x "/bin/ls" ] ：判断/bin/ls是否存在并有可执行权限
[ -n "$var" ] ：判断$var变量是否有值
[ "$a" = "$b" ] ：判断$a和$b是否相等
[ $# -lt 3 ]判断输入命令行参数是否小于3个 (特殊变量$# 表示包含参数的个数)
[ ! ]

#### example 

``` shell
if [ ! -f "./gdms_apply_security.config" ]; then
    echo  "The config file for docbase and username doesn't exist, please check it"
    exit 0
fi
if [ a || b && c ]; then
　 ....
elif ....; then
　 ....
else
　 ....
fi

while [ -n "$binnum" ]; do
　　...
done


for x in one two three four
do
    echo number $x
done

output:
number one
number two 
number three 
number four

for myfile in /etc/r*
do
    if [ -d "$myfile" ] 
    then
      echo "$myfile (dir)"
    else
      echo "$myfile"
    fi
done


	#! /bin/sh
	#shell脚本控制jar的启动和停止
	#启动方法
	start(){
	
	        java -Xms128m -Xmx2048m -jar test1.jar 5 > log.log &
	        java -Xms128m -Xmx2048m -jar test2.jar 5 > log.log &
	        tail -f result.log
	}
	#停止方法
	stop(){
	        ps -ef|grep test|awk '{print $2}'|while read pid
	        do
	           kill -9 $pid
	        done
	}
	
	case "$1" in
	start)
	  start
	  ;;
	stop)
	  stop
	  ;;
	restart)
	  stop
	  start
	  ;;
	*)
	  printf 'Usage: %s {start|stop|restart}\n' "$prog"
	  exit 1
	  ;;
	esac
```


### bash
CTRL+u remove line command
CTRL+t It will reverse two characters
CTRL+q Windows vi region select
Add comments for mutillines
	press CTRL+v to enter visual block mode and press "down" until all the lines are marked. Then press I to insert at the beginning (of the block). The inserted characters will be inserted in each line at the left of the marked block.
编辑命令
    * CTRL+a ：移到命令行首
    * CTRL+e ：移到命令行尾
    * ALT+f ：按单词前移（右向）
    * ALT+b ：按单词后移（左向）
    * CTRL+xx：在命令行首和光标之间移动
    * CTRL+u ：从光标处删除至命令行首
    * CTRL+k ：从光标处删除至命令行尾
    * CTRL+w ：从光标处删除至字首
    * ALT+d ：从光标处删除至字尾
    * CTRL+d ：删除光标处的字符
    * CTRL+h ：删除光标前的字符
    * CTRL+y ：粘贴至光标后
    * ALT+c ：从光标处更改为首字母大写的单词
    * ALT+u ：从光标处更改为全部大写的单词
    * ALT+l ：从光标处更改为全部小写的单词
    * CTRL+t ：交换光标处和之前的字符
    * ALT+t ：交换光标处和之前的单词
    * ALT+Backspace：与 CTRL+w 相同类似，分隔符有些差别 [感谢 rezilla 指正]
重新执行命令
    * CTRL+r：逆向搜索命令历史
    * CTRL+g：从历史搜索模式退出
    * CTRL+p：历史中的上一条命令
    * CTRL+n：历史中的下一条命令
    * ALT+.：使用上一条命令的最后一个参数
控制命令
    * CTRL+l：清屏
    * CTRL+o：执行当前命令，并选择上一条命令 循环执行历史命令
    * CTRL+s：阻止屏幕输出
    * CTRL+q：允许屏幕输出
    * CTRL+c：终止命令
    * CTRL+z：挂起命令
Bang (!) 命令
    * !!：执行上一条命令
    * !blah：执行最近的以 blah 开头的命令，如 !ls
    * !blah:p：仅打印输出，而不执行
    * !$：上一条命令的最后一个参数，与 ALT+. 相同
    * !$:p：打印输出 !$ 的内容
    * !*：上一条命令的所有参数
    * !*:p：打印输出 !* 的内容
    * ^blah：删除上一条命令中的 blah
    * ^blah^foo：将上一条命令中的 blah 替换为 foo
    * ^blah^foo^：将上一条命令中所有的 blah 都替换为 foo
$ ^old^new^  或者 !!:s/old/new/ !!:gs/old/new 替换上一条命令中的一个短语 old替换成new
!$	是一个特殊的环境变量，它代表了上一个命令的最后一个字符串
!!	Run the last command-name
sudo !!	以root的身份执行上一条命令
echo !!:1	to call 1st arg
echo !!:2	to call 2nd arg
echo $?	获取上一次命令执行的结果，0表示成功，非0表示失败
`sudo su -` change to root user

友情提示：
   1. 以上介绍的大多数 Bash 快捷键仅当在 emacs 编辑模式时有效，若你将 Bash 配置为 vi 编辑模式，那将遵循 vi 的按键绑定。Bash 默认为 emacs 编辑模式。如果你的 Bash 不在 emacs 编辑模式，可通过 set -o emacs 设置。
   2. CTRL+s、CTRL+q、CTRL+c、CTRL+z 是由终端设备处理的，可用 stty 命令设置。
   3.  用CTRL+p取出历史命令列表中某一个命令后, 按CTRL+o可以在这条命令到历史命令列表后面的命令之间循环执行命令, 比如历史命令列表中有50条命令, 后面三项分别是命令A, 命令B, 命令C, 用CTRL+p取出命令A后, 再按CTRL+o就可以不停的在命令A, 命令B, 命令C中循环执行这三个命令. CTRL+o有一个非常好用的地方, 比如用cp命令在拷贝一个大目录的时候, 你肯定很想知道当前的拷贝进度, 那么你现在该怎样做呢? 估计很多人会想到不停的输入du -sh dir去执行, 但用CTRL+o可以非常完美的解决这个问题, 方法就是:
    输入du -sh dir, 按回车执行命令
    CTRL+p, CTRL+o, 然后就可以不停的按CTRL+o了, 会不停的执行du -sh dir这条命令  like watch -n 1 -d du -sh dir
	其实上面这个问题也可以用watch命令解决: watch -n 10 -d du -sh /app/data/nas/gdms/
   4. 使用 CTRL+r 而不是上下光标键来查找历史命令
   5. 在已经敲完的命令后按<CTRL+x CTRL+e>，会打开一个你指定的编辑器（比如vim，通过环境变量$EDITOR 指定）

ALT+.把上一条命令的最后一个参数输入到当前命令行. 非常非常之方便, 强烈推荐. 如果继续按ALT+., 会把上上条命令的最后一个参数拿过来. 同样, 如果你想把上一条命令第一个参数拿过来咋办呢? 用ALT+0 ALT+., 就是先输入ALT+0, 再输入ALT+.. 如果是上上条命令的第一个参数呢? 当然是ALT+0 ALT+. ALT+.了.
undo 	CTRL+/

#### bash profile
bash Startup Files: it looks for ~/.bash_profile, ~/.bash_login, and ~/.profile
 You only want to see it on login, so you only want to place this in your .bash_profile. If you put it in your .bashrc, you'd see it every time you open a new terminal window.
add  one line in .profile
`alias ls='ls --color=never'` #调用`\ls`使用原本的ls命令而不是别名
add one line in .bashrc
.bashrc:  `alias grep='grep --color=auto'`

#### file carriage
在Linux下使用vi来查看一些在Windows下创建的文本文件，有时会发现在行尾有一些"^M"。有几种方法可以处理,注意：这里的"^M"要使用"CTRL+v CTRL+m"生成，而不是直接键入"^M"。 
1. $ dos2unix myfile.txt
2. vi :%s/^M$//g #去掉行尾的^M。
	:%s/^M//g #去掉所有的^M。
3. sed -e 's/^M//n/g' myfile.txt // evluate
 sed -i 's/^M//n/g' myfile.txt // replace


### zip/jar 
ps -ef | grep gdms | grep jboss
unzip gdms.war WEB-INF/lib/gdms.jar only unzip the jar from the war
unzip -l gdms.war | grep jaxen
unzip -l archive.zip lists the contents of a ZIP archive to ensure your file is inside.
unzip -c archive.zip file1.txt file2.txt | less :Use the -c option to write the contents of named files to stdout (screen) without having to uncompress the entire archive.
unzip -O cp936 fix linux下文件解压乱码
zip -u gdms.war WEB-INF/lib/jaxen-core.jar update zip file
zip -d gdms.war WEB-INF/lib/jaxen-core.jar

Find a file in lots of zip files: `for f in *.zip; do echo "$f: "; unzip -c $f | grep -i <pattern>; done`
`zless`,`zipgrep`,`zgrep`

jar tvf <filename>.jar to find the content of the file without extracting.
jar tvf classes.zip | grep DctmUtil
extract the class files in the jar
jar xvf <jar name>.jar [class name]
jar xvf gdmsSM.jar com/vdm/Method.class
update files
cd C:\sp\Workspace\gdms\gdmsSMr4p5\bin\classes
jar uvf C:\gdmsSM.jar com\vdm\Method.class com\vdm\UtilsG.class
jar uvf C:\gdmsSM.jar -C backup config.properties; add config.properties without backup folder path into jar
java -classpath .;jdom.jar;jPDFNotesS.jar com.PDFFrame  (linux 下用 :)
java命令引入jar时可以-cp参数，但-cp不能用通配符(JDK 5中多个jar时要一个个写,不能*.jar)，通常的jar都在同一目录，且多于1个
如：java -Djava.ext.dirs=lib MyClass

### mail
mail -s "subject" -a /opt/attachment.txt username@gmail.com < /dev/null
mail -s "Got permission" username@gmail.com < /dev/null
mutt -s "Sample" -a /file/path/file user@local.com < /tmp/msg	send email
mutt -s "gpseqnum" -a gpseqnumInUsed.csv.zip username@gmail.com < /tmp/msg	send email
sendmail user@example.com  < /tmp/email.txt

### help
help命令用来描述不同的内置Bash命令help -s printf
open another terminal: gnome-terminal
man -k or apropos: key words search for command
find out which command shell executes and to print binary(command) file location for specified command: which, whereis, type -a
`locate indexserverconfig.xml`	find file based on index /var/lib/mlocate/mlocate.db
`updatedb`	update index /var/lib/mlocate/mlocate.db as per /etc/updatedb.conf 

### Other
`history | awk '{a[$2]++}END{for(i in a){print a[i] " " i}}' | sort -rn | head` 列出最常用的10条命令
查看最后一个日志文件cat /app/dmfdev08/dba/log/0001d795/bp/`ls -tr /app/dmfdev08/dba/log/0001d795/bp | tail -1`
cat << EOF > test.txt
ABC
DEF
EOF
tar -jxvf firefox-37.0.2.tar.bz2 -C /opt/ -C 选项提取文件到指定目录
watch -d -n 1 'df; ls -FlAt /path' 实时某个目录下查看最新改动过的文件
watch -n 3 ls 以3秒钟执行一个ls命令
du -sh dirname 查看目录的大小
du -h --max-depth=1 显示当前目录中所有子目录的大小
cd - 切换回上一个目录
source .profile 使profile改动生效
wget是linux最常用的下载命令
tnsping MDATADEV.PFIZER.COM
使用一个命令来定义复杂的目录树	mkdir -p project/{lib/ext,bin,src,doc/{html,info,pdf},demo/stat/a}
ntsysv 就会*出图形界面给你选择(有的则显示在里面)，如果在文本界面就用ntsysv命令
常见的场景是由于某种原因`ls`无法使用(内存不足、动态连接库丢失等等), 因为shell通常可以做`*`扩展，所以我们可以用 `echo * == ls`

## Advanced command
### Tmux 
tmux	CRTL-b
tmux使用C/S模型构建，主要包括以下单元模块：
    server服务器。输入tmux命令时就开启了一个服务器。
    session会话。一个服务器可以包含多个会话
    window窗口。一个会话可以包含多个窗口。
    pane面板。一个窗口可以包含多个面板。
tmux ls #列出会话
tmux a[ttach] -t session

#### session operation：
:new	create new session(:new -s sessionName)
? 列出所有快捷键；按q返回
d 脱离当前会话,可暂时返回Shell界面，输入tmux a[ttach]能够重新进入之前会话
s 选择并切换会话；在同时开启了多个会话时使用
$ Rename the current session

#### window operation
c 创建一个新的窗口
w 以菜单方式显示及选择窗口
n(到达下一个窗口) p(到达上一个窗口)
& 关掉当前窗口，也可以输入 exit
, Rename the current window

If the window name keeps renaming, create file `.tmux.conf` with content below
`set-option -g allow-rename off` or `set -g default-terminal "xterm-256color"`
Reload tmux config `.tmux.conf` within tmux, by pressing `CTRL+b` and then `:source-file ~/.tmux.conf` or simply from a shell: `tmux source-file ~/.tmux.conf`

#### panel operation
" 将当前面板上下分屏"
% 将当前面板左右分屏
x 关闭当前面板
<光标键> 移动光标选择对应面板
! 将当前面板置于新窗口,即新建一个窗口,其中仅包含当前面板
CTRL+b+o交换两个panel位置
space 调整panel摆放方式
CTRL+方向键 	以1个单元格为单位移动边缘以调整当前面板大小
ALT+方向键 	以5个单元格为单位移动边缘以调整当前面板大小

#### Example: tmux scripts:
``` shell
	#!/bin/bash
	SESSION=Redis
	#Setup a session and setup a window for redis
	tmux -2 new-session -d -s $SESSION -n $SESSION
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

	#tmux new-window -t $WINDOW2:1 -n $WINDOW2
```

### screen 
screen vi test.c
screen -ls
screen -r PID
可以通过CTRL+a ?来查看所有的键绑定，常用的键绑定有：
CTRL+a ?	显示所有键绑定信息
CTRL+a w	显示所有窗口列表
CTRL+a A	set window title
CTRL+a CTRL+a	切换到之前显示的窗口
CTRL+a c	创建一个新的运行shell的窗口并切换到该窗口
CTRL+a n	切换到下一个窗口
CTRL+a p	切换到前一个窗口(与CTRL+a n相对)
CTRL+a "	select window from list
CTRL+a 0..9	切换到窗口0..9
CTRL+a a	发送CTRL+a到当前窗口 bash中到行首
CTRL+a d	暂时断开screen会话
CTRL+a k	杀掉当前窗口
CTRL+a [	进入拷贝/回滚模式
-c file	使用配置文件file，而不使用默认的$HOME/.screenrc
screen -wipe命令清除死掉的会话

### Python
The command to print a prompt to the screen and to store the resulting input into a variable named var is:
var = raw_input('Prompt')
python -m SimpleHTTPServer  HTTP服务在8000号端口上侦听

## Softwares

### Software List
chromium browser
screenshot: shutter,deepin-scrot

ubuntu上如何使用郵箱客戶端去接收發送outlook exchange 郵件？ 試試 thunderbird + exquilla 插件
HTTPS://HELP.UBUNTU.COM/COMMUNITY/THUNDERBIRDEXCHANGE
https://exquilla.zendesk.com/home
http://www.5dmail.net/html/2013-5-7/201357111547.htm

### JDK installation
1. 安装JDK
0.1 download
	wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u5-b13/jdk-8u5-linux-i586.tar.gz"
0.2 unzip: tar xzf jdk-8u5-linux-i586.tar.gz
0.3 check version: jdk1.8.0_05/bin/java -version

1.1. 下载Linux x86 jdk-6u26-linux-i586.bin：
	sudo cp Downloads/jdk-6u26-linux-i586.bin /opt
	cd /opt
	sudo chmod +x jdk-6u26-linux-i586.bin
1.2. 解压缩安装包进行安装sudo ./jdk-6u26-linux-i586.bin
1.3. 接下来要配置环境变量，修改profile文件。
	sudo gedit /etc/profile
	在文本中添加以下代码：
	#Sun JDK profile
	export JAVA_HOME=/opt/jdk1.6.0_26
	export JRE_HOME=/opt/jdk1.6.0_26/jre
	export CLASSPATH=.:$CLASSPATH:$JAVA_HOME/lib:$JAVA_HOME/jre/lib
	export PATH=$JAVA_HOME/bin:$JAVA_HOME/jre/bin:$PATH:$HOME/bin
1.4. 还要修改另外一个文件environment：
	sudo gedit /etc/environment
	在文本中添加以下代码：
	#Sun JDK environment
	export JAVA_HOME=/opt/jdk1.6.0_26
	export JRE_Home=/opt/jdk1.6.0_26/jre
	export CLASSPATH=.:$CLASSPATH:$JAVA_HOME/lib:$JAVA_HOME/jre/lib
1.5. 手动配置JDK。
	sudo update-alternatives --install /usr/bin/java java /opt/jdk1.6.0_26/bin/java 300
	sudo update-alternatives --install /usr/bin/javac javac /opt/jdk1.6.0_26/bin/javac 300
1.6. 让系统使用我们安装的JDK。
	sudo update-alternatives --config java
1.7. 验证安装JDK是否成功。
	java -version

### eclipse installation
To install eclipse on ubuntu you need to download it first from http://www.eclipse.org/downloads/ Extract the downloaded file by right click on it and extract here or running the following:
	tar xzf dir/eclipse-SDK-3.3.1.1-linux-gtk.tar.gz
	Where eclipse-SDK-3.3.1.1-linux-gtk is your eclipse-SDK name with version and dir is the directory of eclipse-sdk.
	Now move it to the root directory. Apply the following command to do this.
		sudo mv dir/eclipse ~
	Now you are ready to configure your eclipse. To do this follow the following step by step...
		sudo mv eclipse /opt/
	Take care of the permissions:
		sudo chmod -R +r /opt/eclipse
		sudo chmod +x /opt/eclipse/eclipse
Create an executable in your path:
	sudo touch /usr/bin/eclipse
	sudo chmod 755 /usr/bin/eclipse

	sudo gedit /usr/bin/eclipse
	Copy the following content and save the file:
```shell
	#!/bin/bash
	export ECLIPSE_HOME="/home/peter/opt/eclipse"
	$ECLIPSE_HOME/eclipse $*
```
Let's also make eclipse executable everywhere by creating a symlink: 
`sudo ln -s /usr/bin/eclipse /bin/eclipse` 
Create the menu icon: `sudo gedit /usr/share/applications/eclipse.desktop` Type in this content and save:
```
[Desktop Entry]
Encoding=UTF-8
Name=eclipse
Comment=eclipse IDE
Exec=eclipse
Icon=/home/pu/opt/eclipse/icon.xpm
Terminal=false
Type=Application
Categories=GNOME;Application;Development;
StartupNotify=true
```
Run for the first time: eclipse -clean
You can now start Eclipse by simply typing eclipse in the terminal or from the GNOME menu Applications -> Programming -> Eclipse

update tooltips color
http://askubuntu.com/questions/70599/how-to-change-tooltip-background-color-in-unity
grep -r tooltip_[fb]g_color /usr/share/themes/Ambiance: find all files to update
update as below:
tooltip_bg_color #f5f5b5;
tooltip_fg_color #000000;

### Tomcat
export JPDA_ADDRESS=8000
catalina.sh jpda start
java -Xdebug -Xrunjdwp:transport=dt_socket,server=y,address=8000,suspend=n -jar remoting-debug.jar
Listeningfor transport dt_socket at address: 8000

### Chinese input installation 
1.click dash home, search for "language support"
2.click "install/remove language" and add Chinese
3.click dash home, search for "keyboard input method"
4.under "input method",add Chinese input method
5.auto start it: system->administrator->language support->Keyboard input method system, choose ibus

## Miscellaneous

### Missing clock menu bar fix:
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
`sudo restart lightdm`restarting the GUI gnome-system-monitor or `ALT+CTRL+F1`进入命令行Console, kill Xorg的进程`ps -t tty7`后(tty7中跑的是图形桌面进程),Ubuntu将自动重新启动Xorg, 缺点是重新启动了Xorg的进程，死机前原来正在运行的程序和数据无法恢复！
2. When a single program stops working: ALT+F2, type xkill

## System
`zdump -v /etc/localtime` examine the contents of the timezone files

### Performance 

`uptime`
```
uptime
23:51:26 up 21:31,  1 user,  load average: 30.02, 26.43, 19.02
```
命令的输出分别表示1分钟、5分钟、15分钟的平均负载情况。通过这三个数据，可以了解服务器负载是在趋于紧张还是区域缓解。如果1分钟平均负载很高，而15分钟平均负载很低，说明服务器正在命令高负载情况，需要进一步排查CPU资源都消耗在了哪里。反之，如果15分钟平均负载很高，1分钟平均负载较低，则有可能是CPU资源紧张时刻已经过去。  
上面例子中的输出，可以看见最近1分钟的平均负载非常高，且远高于最近15分钟负载，因此我们需要继续排查当前系统中有什么进程消耗了大量的资源。可以通过下文将会介绍的`vmstat`、`mpstat`等命令进一步排查。 

`dmesg | tail`	输出系统日志的最后10行
`vmstat 1`, `iostat-xz 1`

#### CPU `cat /proc/cpuinfo`
`uptime`, `top`, `pidstat -l 2 10`
ps aux | sort -nk +4 | tail	列出头十个最耗内存的进程
w - Find Out Who Is Logged on And What They Are Doing
uptime - Tell How Long The System Has Been Running
top - Process Activity Command

`top`命令包含了前面好几个命令的检查的内容。比如系统负载情况（`uptime`）、系统内存使用情况（`free`）、系统CPU使用情况（`vmstat`）等。因此通过这个命令，可以相对全面的查看系统负载的来源。同时，`top`命令支持排序，可以按照不同的列排序，方便查找出诸如内存占用最多的进程、CPU占用率最高的进程等。

#### Memory `free -h`
pmap - Process Memory Usage

#### Disk 
`df -hT`	查看大小、分区、文件系统类型
硬盘是否SCSI：/dev/sd<X>就是scsi的，hd<X>就是普通的。
`cat /sys/block/sda/queue/rotational`	硬盘是否SSD, 0是SSD，1是传统硬盘  

##### 硬盘写速度
普通硬盘的写速度大概100M/s，RAID级别的查看不方便，SSD的速度也不定，所以用dd测一下最靠谱:
`dd if=/dev/zero of=dd.file bs=8k count=128k conv=fdatasync`
`dd if=/dev/zero of=dd.file bs=1G count=1 conv=fdatasync` 
上面命令测试了分别以每次8k和1g的大小，写入1g文件的速度。
`if`：输入文件名， /dev/zero 设备无穷尽地提供0
`of`：输出文件名
`bs`：块大小
`count`：次数
`conv=fdatasync` ：实际写盘，而不是写入Page Cache

##### 硬盘读速度
硬盘读速度的测试同理，不过要先清理缓存，否则直接从Page Cache读了。
`sh -c "sync && echo 3 > /proc/sys/vm/drop_caches”`
`dd if=./dd.file of=/dev/null bs=8k` 

#### 网卡
* 先用`ifconfig`看看有多少块网卡和bonding。bonding是个很棒的东西，可以把多块网卡绑起来，突破单块网卡的带宽限制
* 然后检查每块网卡的速度，比如`ethtool eth0`。
* 再检查bonding，比如`cat /proc/net/bonding/bond0`, 留意其Bonding Mode是负载均衡的，再留意其捆绑的网卡的速度。
* 最后检查测试客户机与服务机之间的带宽，先简单`ping`或`traceroute` 一下得到RTT时间，`iperf`之类的可稍后。

Linux查看网卡数据吞吐量方法
1、`iptraf` 工具(http://iptraf.seul.org),提供了每个网卡吞吐量的仪表盘：`iptraf -d eth0`  
2、`watch -n 1 "/sbin/ifconfig eth0 | grep bytes"`。

`sar -n DEV 1`

#### 操作系统 `uname -a`
find out system version: `cat /etc/*-release` or `ls /etc/*-release`
Redhat/CentOS版本 : `cat /etc/redhat-release`

#### 状态采集工具
讲究点，要用来出报告的，用`Zabbix`之类。

##### `dstat`
实时观察的，我喜欢`dstat`，比`vmstat`，`iostat`, `sar`们都好用，起码对得够齐，单位能自动转换。不过`dstat`需要安装(`yum install dstat`，如果装不上，就要将就着用`vmstat`，`sar`了)
    dstat：默认，已有足够信息
    dstat -am：再多一个memory信息
    dstat -amN bond0,lo： 如果有bonding，dstat会把bond0和eth0 算双份，还有lo的也算到总量里，所以还是用-N指定网卡好。
要看IO细节，还是要用"iostat -dxm 5"
    -d 不看cpu信息
    -x 看细节
    -m 以m为单位，而不以block原始size
    5 5秒的间隔

##### `vmstat 1`
vmstat - System Activity, Hardware and System Information
```
$ vmstat 1
procs ---------memory---------- ---swap-- -----io---- -system-- ------cpu-----
 r  b swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
34  0    0 200889792  73708 591828    0    0     0     5    6   10 96  1  3  0  0
32  0    0 200889920  73708 591860    0    0     0   592 13284 4282 98  1  1  0  0
32  0    0 200890112  73708 591860    0    0     0     0 9501 2154 99  1  0  0  0
32  0    0 200889568  73712 591856    0    0     0    48 11900 2459 99  0  0  0  0
32  0    0 200890208  73712 591860    0    0     0     0 15898 4840 98  1  1  0  0
^C
```
`vmstat(8)` 命令，每行会输出一些系统核心指标，这些指标可以让我们更详细的了解系统状态。后面跟的参数1，表示每秒输出一次统计信息，表头提示了每一列的含义，这几介绍一些和性能调优相关的列：  
`r`：等待在CPU资源的进程数。这个数据比平均负载更加能够体现CPU负载情况，数据中不包含等待IO的进程。如果这个数值大于机器CPU核数，那么机器的CPU资源已经饱和。  
`free`：系统可用内存数（以千字节为单位），如果剩余内存不足，也会导致系统性能问题。下文介绍到的free命令，可以更详细的了解系统内存的使用情况。  
`si, so`：交换区写入和读取的数量。如果这个数据不为0，说明系统已经在使用交换区（swap），机器物理内存已经不足  
`us, sy, id, wa, st`：这些都代表了CPU时间的消耗，它们分别表示用户时间（user）、系统（内核）时间（sys）、空闲时间（idle）、IO等待时间（wait）和被偷走的时间（stolen，一般被其他虚拟机消耗）。  

上述这些CPU时间，可以让我们很快了解CPU是否出于繁忙状态。一般情况下，如果用户时间和系统时间相加非常大，CPU出于忙于执行指令。如果IO等待时间很长，那么系统的瓶颈可能在磁盘IO。
示例命令的输出可以看见，大量CPU时间消耗在用户态，也就是用户应用程序消耗了CPU时间。这不一定是性能问题，需要结合r队列，一起分析。

#####  `iostat-xz 1`
iostat - Average CPU Load, Disk Activity
`iostat`命令主要用于查看机器磁盘IO情况。该命令输出的列，主要含义是：
`r/s, w/s, rkB/s, wkB/s`：分别表示每秒读写次数和每秒读写数据量（千字节）。读写量过大，可能会引起性能问题。
`await`：IO操作的平均等待时间，单位是毫秒。这是应用程序在和磁盘交互时，需要消耗的时间，包括IO等待和实际操作的耗时。如果这个数值过大，可能是硬件设备遇到了瓶颈或者出现故障。
`avgqu-sz`：向设备发出的请求平均数量。如果这个数值大于1，可能是硬件设备已经饱和（部分前端硬件设备支持并行写入）。
`%util`：设备利用率。这个数值表示设备的繁忙程度，经验值是如果超过60，可能会影响IO性能（可以参照IO操作平均等待时间）。如果到达100%，说明硬件设备已经饱和。
如果显示的是逻辑设备的数据，那么设备利用率不代表后端实际的硬件设备已经饱和。值得注意的是，即使IO性能不理想，也不一定意味这应用程序性能会不好，可以利用诸如预读取、写缓存等策略提升应用性能。

##### `sar -n DEV 1`, `sar -n TCP,ETCP 1`
sar - Collect and Report System Activity
```
$ sar -n DEV 1
Linux 3.13.0-49-generic (titanclusters-xxxxx)  07/14/2015     _x86_64_    (32 CPU)
12:16:48 AM     IFACE   rxpck/s   txpck/s    rxkB/s    txkB/s   rxcmp/s   txcmp/s  rxmcst/s   %ifutil
12:16:49 AM      eth0  18763.00   5032.00  20686.42    478.30      0.00      0.00      0.00      0.00
12:16:49 AM        lo     14.00     14.00      1.36      1.36      0.00      0.00      0.00      0.00
12:16:49 AM   docker0      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
12:16:49 AM     IFACE   rxpck/s   txpck/s    rxkB/s    txkB/s   rxcmp/s   txcmp/s  rxmcst/s   %ifutil
12:16:50 AM      eth0  19763.00   5101.00  21999.10    482.56      0.00      0.00      0.00      0.00
12:16:50 AM        lo     20.00     20.00      3.25      3.25      0.00      0.00      0.00      0.00
12:16:50 AM   docker0      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
^C
```
`sar`命令在这里可以查看网络设备的吞吐率。在排查性能问题时，可以通过网络设备的吞吐量，判断网络设备是否已经饱和。如示例输出中，eth0网卡设备，吞吐率大概在22 Mbytes/s，既176 Mbits/sec，没有达到1Gbit/sec的硬件上限。

`sar -n TCP,ETCP 1`
```
$ sar -n TCP,ETCP 1
Linux 3.13.0-49-generic (titanclusters-xxxxx)  07/14/2015    _x86_64_    (32 CPU)
12:17:19 AM  active/s passive/s    iseg/s    oseg/s
12:17:20 AM      1.00      0.00  10233.00  18846.00
12:17:19 AM  atmptf/s  estres/s retrans/s isegerr/s   orsts/s
12:17:20 AM      0.00      0.00      0.00      0.00      0.00
12:17:20 AM  active/s passive/s    iseg/s    oseg/s
12:17:21 AM      1.00      0.00   8359.00   6039.00
12:17:20 AM  atmptf/s  estres/s retrans/s isegerr/s   orsts/s
12:17:21 AM      0.00      0.00      0.00      0.00      0.00
^C
```
`sar`命令在这里用于查看TCP连接状态，其中包括：
`active/s`：每秒本地发起的TCP连接数，既通过connect调用创建的TCP连接；
`passive/s`：每秒远程发起的TCP连接数，即通过accept调用创建的TCP连接；
`retrans/s`：每秒TCP重传数量；
TCP连接数可以用来判断性能问题是否由于建立了过多的连接，进一步可以判断是主动发起的连接，还是被动接受的连接。TCP重传可能是因为网络环境恶劣，或者服务器压力过大导致丢包。

### File

#### 文件特殊权限 SUID、SGID、STICKY简介
linux中除了常见的读（r）、写（w）、执行（x）权限以外，还有3个特殊的权限，分别是setuid、setgid和stick bit
setuid、setgid实例，/usr/bin/passwd 与/etc/passwd文件的权限
```
sudo ls -l /usr/bin/passwd /etc/passwd
-rw-r--r-- 1 root root  1549 08-19 13:54 /etc/passwd
-rwsr-xr-x 1 root root 22984 2007-01-07 /usr/bin/passwd
```
从权限上看，/etc/passwd仅有root权限的写（w）权，可实际上每个用户都可以通过/usr/bin/passwd命令去修改这个文件，于是这里就涉及了linux里的特殊权限setuid，正如-rwsr-xr-x中的s

stick bit （粘贴位） 实例，查看/tmp目录的权限
```
sudo ls -dl /tmp
drwxrwxrwt 6 root root 4096 08-22 11:37 /tmp
```
 tmp目录是所有用户共有的临时文件夹，所有用户都拥有读写权限，这就必然出现一个问题，A用户在/tmp里创建了文件a.file，此时B用户看了不爽，在/tmp里把它给删了（因为拥有读写权限），那肯定是不行的。实际上在/tmp目录中，只有文件的拥有者和root才能对其进行修改和删除，其他用户则不行，因为有特殊权限stick bit（粘贴位）权限，正如drwxrwxrwt中的最后一个t 

##### 特殊位作用
- SUID:对一个可执行文件，不是以发起者身份来获取资源，而是以可执行文件的属主身份来执行。
- SGID对一个可执行文件，不是以发起者身份来获取资源，而是以可执行文件的属组身份来执行。
- STICKY：粘滞位，通常对目录而言。通常对于全局可写目录（other也可写）来说，让该目录具有sticky后，删除只对属于自己的文件有效（但是仍能编辑修改别人的文件，除了root的）。不能根据安全上下文获取对别人的文件的写权限

##### 设置方式：
  SUID：置于 u 的 x 位，原位置有执行权限，就置为 s，没有了为 S . `#chmod u+s`
  SGID：置于 g 的 x 位，原位置有执行权限，就置为 s，没有了为 S . `#chmod g+s`
  STICKY：粘滞位，置于 o 的 x 位，原位置有执行权限，就置为 t ，否则为T  `#chmod o+t`
在一些文件设置了特殊权限后，字母不是小写的s或者t，而是大写的S和T，那代表此文件的特殊权限没有生效，是因为你尚未给它对应用户的x权限  
去除特殊位有： `#chmou u-s`等
将三个特殊位的用八进制数值表示，放于 u/g/o 位之前。其中 suid :4 sgid:2  sticky:1
也可以这样设:
```
setuid:chmod 4755 xxx
setgid:chmod 2755 xxx
stick bit:chmod 1755 xxx
```

### Kernel
Find Out If Running Kernel Is 32 Or 64 Bit (find out if my Linux server CPU can run a 64 bit kernel version (apps) or not)
	uname -a	print system information: 
Find Out CPU is 32bit or 64bit?
	grep flags /proc/cpuinfo 
	CPU Modes:
		lm flag means Long mode cpu - 64 bit CPU
		Real mode 16 bit CPU
		Protected Mode is 32-bit CPU

### Network
设定 DNS 的 IP：/etc/resolv.conf
nameserver 192.168.1.1

netstat
-t、-u、-w和-x分别表示TCP、UDP、RAW和UNIX套接字连接; 
-a标记，还会显示出等待连接（也就是说处于监听模式）的套接字; 
-l 显示正在被监听(listen)的端口
-n表示直接显示端口数字而不是通过察看/etc/service来转换为端口名; 
-p选项表示列出监听的程序
--numeric , -n
       Show numerical addresses instead of trying to determine symbolic  host,
       port or user names.

Listening open ports: netstat -anp | grep PORT
netstat -antup 查看已建立的连接进程，所占用的端口
$ netstat -anp | less: Finding the PID of the process using a specific port
Proto Recv-Q Send-Q Local Address               Foreign Address             State       PID/Program name   
tcp        0      0 *:pssc                      *:*                         LISTEN      -       

lsof -i

#### Restart network
sudo service network-manager restart

#### vi /etc/sysconfig/network-scripts/ifcfg-eth0
DEVICE   =   eth0   
ONBOOT   =   yes   
BOOTPROTO   =   static   
BROADCAST=192.168.230.255
IPADDR=   192.168.230.160 (你需要的固定ip)   
NETMASK=255.255.255.0
NETWORK=192.168.1.0
TYPE=Ethernet

如果需要动态分配IP，那么   
DEVICE   =   eth0   
ONBOOT   =   yes   
USERCTL   =   yes   
BOOTPROTO   =   dhcp  
重启网络服务service network restart

#### Change system proxy settings from the command line using gsettings
http://ask.xmodulo.com/change-system-proxy-settings-command-line-ubuntu-desktop.html
**Question**: change system proxy settings on Ubuntu desktop: "System Settings" -> "Network" -> "Network proxy". Is there a more convenient way to change desktop's proxy settings from the command line?  
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
`$ gsettings set org.gnome.system.proxy mode 'none' `

#### SSH
ssh user@host	以 user 用户身份连接到 host
ssh -p port user@host	在端口 port 以 user 用户身份连接到 host
-f ssh将在后台运行 
-N 不执行命令，仅转发端口 
-C 压缩传送的数据 
-i 使用指定的密钥登录 

escape_char (default: '~').  The escape character is only recognized at the beginning of a line.  The escape character followed by a dot ('.') closes the connection; followed by control-Z suspends the connection;
~^Z	suspends the connection
fg reconnect

ssh-keygen -t rsa -b 4096 -C "your_email@example.com"	#Creates a new ssh key, using the provided email as a label #Generating public/private rsa key pair.

ssh-copy-id user@host	将公钥添加到 host 以实现无密码登录
ssh-copy-id -i ~/.ssh/id_rsa.pub username@IP
cat ~/.ssh/id_rsa.pub | ssh user@machine "mkdir ~/.ssh; cat >> ~/.ssh/authorized_keys"	从一台没有SSH-COPY-ID命令的主机将你的SSH公钥复制到服务器
ssh user@host 'mkdir -p .ssh && cat >> .ssh/authorized_keys' < ~/.ssh/id_rsa.pub'

cd && tar czv src | ssh user@host 'tar xz'	将$HOME/src/目录下面的所有文件，复制到远程主机的$HOME/src/目录
ssh user@host 'tar cz src' | tar xzv	将远程主机$HOME/src/目录下面的所有文件，复制到用户的当前目录
ssh user@host 'ps ax | grep [h]ttpd'	查看远程主机是否运行进程httpd

yes | pv | ssh $host "cat > /dev/null"	实时SSH网络吞吐量测试 通过SSH连接到主机，显示实时的传输速度，将所有传输数据指向/dev/null，需要先安装pv.Debian(apt-get install pv) Fedora(yum install pv)
yes | pv | cat > /dev/null

ssh host -l user "`cat cmd.txt`"	通过SSH运行复杂的远程shell命令
mysqldump --add-drop-table --extended-insert --force --log-error=error.log -uUSER -pPASS OLD_DB_NAME | ssh -C user@newhost "mysql -uUSER -pPASS NEW_DB_NAME"	通过SSH将MySQL数据库复制到新服务器

##### SSH端口转发(Port Forwarding)
这是一种隧道(tunneling)技术
[远程操作与端口转发](http://www.ruanyifeng.com/blog/2011/12/ssh_port_forwarding.html )
``` bash
ssh -L 9090:remoteSecret:8080 remoteHost 本地端口转发Local forwarding:connect remoteSecret through remoteHost
ssh -L <local port>:<remote host>:<remote port> <SSH hostname>
ssh -R <local port>:<remote host>:<remote port> <SSH hostname> 远程端口转发remote forwarding
ssh -D <local port> <SSH Server>	动态转发 如果SSH Server是境外服务器，则该SOCKS代理实际上具备了翻墙功能
```

[实战 SSH 端口转发](https://www.ibm.com/developerworks/cn/linux/l-cn-sshforward/ )
[实战 SSH 端口转发 evernote copy](https://www.evernote.com/shard/s45/sh/659cae7f-4264-40f6-a05d-0fed2cfb5361/e1d88e29a968d3905789c94c98f5ae23 )
本地端口转发例子: 在实验室里有一台 LDAP 服务器（LdapServerHost），但是限制了只有本机上部署的应用才能直接连接此 LDAP 服务器。如果我们由于调试或者测试的需要想临时从远程机器（LdapClientHost）直接连接到这个 LDAP 服务器
在 LdapClientHost 上执行如下命令即可建立一个 SSH 的本地端口转发，例如：
`$ ssh -L 7001:localhost:389 LdapServerHost`

远程端口转发例子:　假设由于网络或防火墙的原因我们不能用 SSH 直接从 LdapClientHost 连接到 LDAP 服务器（LdapServertHost），但是反向连接却是被允许的。那此时我们的选择自然就是远程端口转发了。
在 LDAP 服务器（LdapServertHost）端执行如下命令：
`$ ssh -R 7001:localhost:389 LdapClientHost`

##### Jumphost
[How To Use A Jumphost in your SSH Client Configurations](https://ma.ttias.be/use-jumphost-ssh-client-configurations/)

Jumphosts are used as intermediate hops between your actual SSH target and yourself. Instead of using something like "unsecure" SSH agent forwarding, you can use ProxyCommand to proxy all your commands through your jumphost.
You want to connect to HOST B and have to go through HOST A, because of firewalling, routing, access privileges
+---+       +---+       +---+
|You|   ->  | A |   ->  | B |
+---+       +---+       +---+

Classic SSH Jumphost configuration
A configuration like this will allow you to proxy through HOST A.

```
$ cat .ssh/config
Host host-a
  User your_username
  Hostname 10.0.0.5

Host host_b
  User your_username
  Hostname 192.168.0.1
  Port 22
  ProxyCommand ssh -q -W %h:%p host-a
```
Now if you want to connect to your HOST B, all you have to type is `ssh host_b`, which will first connect to `host-a` in the background (that's the `ProxyCommand` being executed) and start the SSH session to your actual target.

SSH Jumphost configuration with netcat (nc)
Alternatively, if you can't/don't want to use ssh to tunnel your connections, you can also use nc (netcat).
configure it in ./ssh/config with `ProxyCommand`
`ProxyCommand ssh host-a nc -w 120 %h %p`

If netcat is not available to you as a regular user, because permissions are limited, you can prefix it with sudo
`ProxyCommand ssh host-a sudo nc -w 120 %h %p`


##### 创建Kerberos的keytab文件
```bash
cd /data/
ktutil
addent -password -p username@GMAIL.COM -k 1 -e aes256-cts
wkt username.keytab
quit
```

alias ssh35="kinit username@GMAIL.COM -k -t ~/sp/username.keytab;ssh work@IP1 -t 'ssh IP2;bash -l'"
ssh root@MachineB 'bash -s' < local_script.sh	#run local shell script on a remote machine

#### SCP
scp client_file user@server:filepath	上传文件到服务器端
scp user@server:server_files client_file_path	下载文件
client_file 待上传的文件，可以有多个，多个文件之间用空格隔开。也可以用*.filetype上传某个类型的全部文件
user 服务端登录用户名, server 服务器名（IP或域名）, filepath 上传到服务器的目标路径（这里注意此用户一定要有这个路径的读写权限）

#### Windows putty plink pscp
pscp.exe -pw pwd filename username@host:directory/subdirectory
plink -pw pwd username@host ls;ls
plink -pw pwd username@host -m local_script.sh
plink -i %putty%/privateKey.ppk
Windows的控制台会把两个双引号之间的字符串作为一个参数传递给被执行的程序，而不会把双引号也传递给程序
所以错误命令C:\>plink 192.168.6.200 ls "-l"
Windows控制台不认得单引号，所以上面那个命令的正确用法应该是：
c:\>plink 192.168.6.200 ls '-l'

### Software manage
dpkg -i AdbeRdr*.deb  #install
abort installation or recover from failed installing by apt-get
sudo dpkg -r <package name>

uninstall qq
1. find the name: dpkg -l | grep package 
2. sudo dpkg -r qq-for-wine 或 sudo dpkg -P qq-for-wine
sudo apt-get remove acroread;sudo apt-get autoremove  #uninstall

apt-cache search #package 搜索包

aptitude name for failed resolving dependency

#### apt command
apt-get 下载后，软件所在路径是 /var/cache/apt/archives

apt-cache policy maven	#check the version of package from apt-get
apt-cache pkgnames #To list all the available packages,
apt-cache pkgnames packageName	#To find and list down all the packages starting with 'packageName'
apt-cache search packageName	#To find out the package name and with it description before installing
apt-cache show packageName	#check information of package along with it short description say (version number, check sums, size, installed size, category etc)

apt-get install 
apt-get install packageName --only-upgrade	#do not install new packages but it only upgrade the already installed packages and disables new installation of packages
apt-get install vsftpd=2.3.5-3ubuntu1	#Install Specific Package Version

apt-get remove vsftpd	#To un-install software packages without removing their configuration files
apt-get purge vsftpd	#To remove software packages including their configuration files
apt-get --download-only source vsftpd	#To download only source code of particular package
apt-get source vsftpd	#To download and unpack source code of a package to a specific directory
apt-get --compile source goaccess	#download, unpack and compile the source code at the same time
apt-get download nethogs	#Download a Package Without Installing
apt-get changelog vsftpd	#downloads a package change-log and shows the package version that is installed

#### dpkg command
sudo apt-get install gdebi    #gdebi is a simple tool to install deb files,apt does the same, but only for remote (http, ftp) located package repositories.

dpkg -i packageName	#Install a Package
dpkg -l	#List all the installed Packages
dpkg -r packageName	#The "-r" option is used to remove/uninstall a package
dpkg -p packageName	#use 'p' option in place of 'r' which will remove the package along with configuration files
dpkg -c packageName	#View the Content of a Package
dpkg -S packageName	#显示所有包含该软件包的目录
dpkg -s packageName	#Check a Package is installed or not
dpkg -L packageName	#Check the location of Packages installed
dpkg --unpack packageName	#Unpack the Package but dont' Configure
dpkg --configure packageName	#Reconfigure a Unpacked Package

### update hostname
vi /etc/hostname
vi /etc/hosts

### update hosts
redirect it to ustc:lug.ustc.edu.cn
var url = request.url.replace('googleapis.com', 'lug.ustc.edu.cn');
refer to https://github.com/justjavac/ReplaceGoogleCDN
vi /etc/hosts
202.141.162.123 www.ajax.googleapis.com
202.141.162.123 ajax.googleapis.com

### 设置主DNS
/etc/resolvconf/resolv.conf.d/head 
sudo resolvconf -u
cat /etc/resolv.conf

### mount disk
用mount挂载你的windows分区，事先以root权限用fdisk -l查看。你就知道该挂载哪个了
mount /dev/cdrom /mnt/cdrom 挂载光盘

auto mount your NTFS disk: Install pysdm or ntfs-config
Mount Windows drivers automatically
This works in 12.10, 13.04, 13.10 and 14.04
Type Disks in Dash, and you will get:
Click on the little gears, to get the sub menu, and choose Edit Mount Options. After that you will see:
Change the Automatic Mount Options to ON. do that to all the drives that you need mounted on start-up.
Note: Be careful with you modify, it may cause the system not to work properly.
先用FDISK命令查看一下磁盘的UUID
$sudo fdisk -l
 id username
vi /etc/fstab
 /dev/sda3      /media/program    ntfs    defaults,utf8,uid=1000,gid=1000,dmask=022,fmask=133     0       0	#defaults = rw, suid, dev, exec, auto, nouser, and async.
auto= mounted at boot
noauto= not mounted at boot
user= when mounted the mount point is owned by the user who mounted the partition
users= when mounted the mount point is owned by the user who mounted the partition and the group users
ro= read only
rw= read/write
dmask: directory umask
fmask: file umask

#### Permission mapping
4 	read
2 	write
1 	execute

#### NTFS permission The mode is determined by the partition''s mount options
bash script.sh	#You can always explicitly invoke the script interpreter

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
/media is intended as a mount point for external devices, such as hard drives or removable media (floppies, CDs, DVDs).
/mnt is also a place for mount points, but dedicated specifically to "temporarily mounted" devices, such as network filesystems.
/opt can be used to store addition software for your system, which is not handled by the package manager.
/proc is a virtual filesystem that provides a mechanism for kernel to send information to processes.
/root is the superuser''s home directory, not in /home/ to allow for booting the system even if /home/ is not available.
/sbin contains important administrative commands that should generally only be employed by the superuser.
/srv can contain data directories of services such as HTTP (/srv/www/) or FTP.
/sys is a virtual filesystem that can be accessed to set or obtain information about the kernel''s view of the system.
/tmp is a place for temporary files used by applications.
/usr contains the majority of user utilities and applications, and partly replicates the root directory structure, containing for instance, among others, /usr/bin/ and /usr/lib.
/var is dedicated variable data that potentially changes rapidly; a notable directory it contains is /var/log where system log files are kept.
通常情况下，linux会这样放软件的组件： 
程序的文档->/usr/share/doc; /usr/local/share/doc
程序->/usr/share; /usr/local/share
程序的启动项->/usr/share/apps; /usr/local/share
程序的语言包->/usr/share/locale; /usr/local/share/locale
可执行文件->/usr/bin; /usr/local/bin
而有的软件为了和系统组件分隔开，选择栖息于 /opt，但目录结构往往是一样的，把/usr或/usr/local 替换为了/opt/"软件名" 
~/share all softwares
~/opt soft links to specify version of ~/share softwares
