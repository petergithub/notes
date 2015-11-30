[TOC]
学习系统结构的最好方法是自己做一个linux系统，再也没有什么能比自己做一个linux系统更能学习系统结构的了。LFS (linux from strach)可以教你从源代码自己编译一个系统。通过自己编译一个系统，你就可以了结linux系统结构，知道哪些文件是干什么用的，以及他们如何协调 工作。
Linux内核设计与实现 Linux Kernel Development(Third Edition)-Robort Love

shortcuts:
^Z jobs fg(前台运行)， bg(后台运行)
vimtutor: vim interactive guide
Ctrl+h: show hidden files
nautilus: open your home folder
location: make a command can be call anywhere

## Basic Command
### VI
:set nu / :set nonu	(不)列出行号 (nu为行数)
:set ic / :set noic	vi在查找过程中(不)区分大小写 :set ignorecase/:set noignorecase
~	切换大小写
:sp split window above and below
dt"  删除所有的内容，直到遇到"

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
`daw`	删除当前光标所在的word(包括空白字符)，意为Delete A Word
guw	光标下的单词变为小写
gUw	光标下的单词变为大写
ga	显示光标下的字符在当前使用的encoding下的内码
`:sh`	暂时退出vi到系统下，结束时按Ctrl + d则回到vi
`:r!command`	将命令command的输出结果放到当前行【强大】

zoom in on your terminal with Ctrl+Shift++.
Zoom out with Ctrl+-

:x == :wq 当文件被修改时两个命令时相同的。但如果未被修改，使用 :x 不会更改文件的修改时间，而使用 :wq 会改变文件的修改时间
:w !sudo tee %  在VIM中保存一个当前用户无权限修改的文件
. 命令重复上次的修改。
:! command allows you to enter the name of a shell command
修改在这里就是插入、删除或者替换文本。能够重复是一个非常强大的机制。如果你基于它来安排你的编辑，许多修改将变得只是敲.键。留意其间的其他修改，因为它会替代你原来要重复的修改。相反，你可以用m命令先标记这个位置，继续重复你的修改，稍后再返回到这个位置。
重复修改一个单词。
如果是在整个文件中，你可以使用:s（substitute）命令。如果只是几个地方需要修改，一种快速的方法是使用 * 命令去找到下一个出现的单词，使用cw命令修改它。然后输入n去找到下一个单词，输入英文逗点 . 去重复cw命令。
删除多行
1. 如果要删除的段落的下一行是空行 一般用d} , 按两个键就可以了 多段的时候再按 .
2. 如果要删除的段落的下一行不是空行 则很容易找到该行的模式， 如该行存在function字串 一般 d/fu 也就搞定了
输入单词A的前几个字母，然后ctrl+N补全。<C-o><C-n> <C-o><C-p> 只是简单的上下文补全，还有<C-o><C-f> 用于对目录名进行补全

#### Vim: move around quickly inside of long line
`gj` and `gk` move up and down one displayed line by using gj and gk. That way, you can treat your one wrapped line as multiple lines

#### 文件对比 合并 多窗口
diff -u
vimdiff  FILE_LEFT  FILE_RIGHT
:qa (quit all)同时退出两个文件
:wa (write all)
:wqa (write, then quit all)
:qa! (force to quit all)

Ctrl-w K(把当前窗口移到最上边)
Ctrl-w H(把当前窗口移到最左边)
Ctrl-w J(把当前窗口移到最下边)
Ctrl-w L(把当前窗口移到最右边)
ctrl-w,r 交换上/下、左/右两个分隔窗口的位置
其中2和4两个操作会把窗口改成垂直分割方式。
在两个文件之间来回跳转，可以用下列命令序列Ctrl-w, w
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
grep pattern files – 搜索 files 中匹配 pattern 的内容
grep -r pattern dir – 递归搜索 dir 中匹配 pattern 的内容
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

#### 乱码文件名的文件处理
1. `ls -i` print the index number of each file(文件的i节点) 12345
2. `find . -inum 12345 -print -exec rm {} -r \;` rm
3. `find . -inum 12345 -exec mv {} NewName \;` mv
命令中的"{}"表示find命令找到的文件，在-exec选项执行mv命令的时候，会利用按i节点号找到的文件名替换掉"{}"

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

read -p "Press enter to continue"
read -n 1 -p "Press any key to continue"
sleep 2; echo 'end sleep 2 sec'

### bash
^u remove line command
^T It will reverse two characters
^Q Windows vi region select
Add comments for mutillines
	press Ctrl-V to enter visual block mode and press "down" until all the lines are marked. Then press I to insert at the beginning (of the block). The inserted characters will be inserted in each line at the left of the marked block.
编辑命令
    * Ctrl + a ：移到命令行首
    * Ctrl + e ：移到命令行尾
    * Alt + f ：按单词前移（右向）
    * Alt + b ：按单词后移（左向）
    * Ctrl + xx：在命令行首和光标之间移动
    * Ctrl + u ：从光标处删除至命令行首
    * Ctrl + k ：从光标处删除至命令行尾
    * Ctrl + w ：从光标处删除至字首
    * Alt + d ：从光标处删除至字尾
    * Ctrl + d ：删除光标处的字符
    * Ctrl + h ：删除光标前的字符
    * Ctrl + y ：粘贴至光标后
    * Alt + c ：从光标处更改为首字母大写的单词
    * Alt + u ：从光标处更改为全部大写的单词
    * Alt + l ：从光标处更改为全部小写的单词
    * Ctrl + t ：交换光标处和之前的字符
    * Alt + t ：交换光标处和之前的单词
    * Alt + Backspace：与 Ctrl + w 相同类似，分隔符有些差别 [感谢 rezilla 指正]
重新执行命令
    * Ctrl + r：逆向搜索命令历史
    * Ctrl + g：从历史搜索模式退出
    * Ctrl + p：历史中的上一条命令
    * Ctrl + n：历史中的下一条命令
    * Alt + .：使用上一条命令的最后一个参数
控制命令
    * Ctrl + l：清屏
    * Ctrl + o：执行当前命令，并选择上一条命令 循环执行历史命令
    * Ctrl + s：阻止屏幕输出
    * Ctrl + q：允许屏幕输出
    * Ctrl + c：终止命令
    * Ctrl + z：挂起命令
Bang (!) 命令
    * !!：执行上一条命令
    * !blah：执行最近的以 blah 开头的命令，如 !ls
    * !blah:p：仅打印输出，而不执行
    * !$：上一条命令的最后一个参数，与 Alt + . 相同
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

友情提示：
   1. 以上介绍的大多数 Bash 快捷键仅当在 emacs 编辑模式时有效，若你将 Bash 配置为 vi 编辑模式，那将遵循 vi 的按键绑定。Bash 默认为 emacs 编辑模式。如果你的 Bash 不在 emacs 编辑模式，可通过 set -o emacs 设置。
   2. ^S、^Q、^C、^Z 是由终端设备处理的，可用 stty 命令设置。
   3.  用C-p取出历史命令列表中某一个命令后, 按C-o可以在这条命令到历史命令列表后面的命令之间循环执行命令, 比如历史命令列表中有50条命令, 后面三项分别是命令A, 命令B, 命令C, 用C-p取出命令A后, 再按C-o就可以不停的在命令A, 命令B, 命令C中循环执行这三个命令. C-o有一个非常好用的地方, 比如用cp命令在拷贝一个大目录的时候, 你肯定很想知道当前的拷贝进度, 那么你现在该怎样做呢? 估计很多人会想到不停的输入du -sh dir去执行, 但用C-o可以非常完美的解决这个问题, 方法就是:
    输入du -sh dir, 按回车执行命令
    C-p, C-o, 然后就可以不停的按C-o了, 会不停的执行du -sh dir这条命令  like watch -n 1 -d du -sh dir
	其实上面这个问题也可以用watch命令解决: watch -n 10 -d du -sh /app/data/nas/gdms/
   4. 使用 Ctrl-r 而不是上下光标键来查找历史命令

alt+.把上一条命令的最后一个参数输入到当前命令行. 非常非常之方便, 强烈推荐. 如果继续按alt+., 会把上上条命令的最后一个参数拿过来. 同样, 如果你想把上一条命令第一个参数拿过来咋办呢? 用alt+0 alt+., 就是先输入alt+0, 再输入alt+.. 如果是上上条命令的第一个参数呢? 当然是alt+0 alt+. alt+.了.
undo 	C-/

#### bash profile
bash Startup Files: it looks for ~/.bash_profile, ~/.bash_login, and ~/.profile
 You only want to see it on login, so you only want to place this in your .bash_profile. If you put it in your .bashrc, you'd see it every time you open a new terminal window.
add  one line in .profile
alias ls='ls --color=never'
add one line in .bashrc
.bashrc:  alias grep='grep --color=auto'

#### file carriage
在Linux下使用vi来查看一些在Windows下创建的文本文件，有时会发现在行尾有一些"^M"。有几种方法可以处理,注意：这里的"^M"要使用"CTRL-V CTRL-M"生成，而不是直接键入"^M"。 
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
convmv -f 源编码 -t 新编码 [选项] 文件名 #linux文件名编码批量转换
zip -u gdms.war WEB-INF/lib/jaxen-core.jar update zip file
zip -d gdms.war WEB-INF/lib/jaxen-core.jar

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
help命令用来描述不同的内置Bash命令help –s printf
open another terminal: gnome-terminal
man -k or apropos: key words search for command
find out which command shell executes and to print binary(command) file location for specified command: which, whereis, type -a
`locate indexserverconfig.xml`	find file based on index /var/lib/mlocate/mlocate.db
`updatedb`	update index /var/lib/mlocate/mlocate.db as per /etc/updatedb.conf 

### Other
查看最后一个日志文件cat /app/dmfdev08/dba/log/0001d795/bp/`ls -tr /app/dmfdev08/dba/log/0001d795/bp | tail -1`
sudo usermod -a -G vboxsf your_user_name	:add user to group vboxsf
cat << EOF > test.txt
ABC
DEF
EOF
tar -jxvf firefox-37.0.2.tar.bz2 -C /opt/ -C 选项提取文件到指定目录
cd - 切换回上一个目录
wget是linux最常用的下载命令
tnsping MDATADEV.PFIZER.COM
使用一个命令来定义复杂的目录树mkdir -p project/{lib/ext,bin,src,doc/{html,info,pdf},demo/stat/a}
ps aux or ps -ef | grep
ps aux | sort -nk +4 | tail	列出头十个最耗内存的进程
top - Process Activity Command
vmstat - System Activity, Hardware and System Information
w - Find Out Who Is Logged on And What They Are Doing
uptime - Tell How Long The System Has Been Running
free - Memory Usage
iostat - Average CPU Load, Disk Activity
sar - Collect and Report System Activity
pmap - Process Memory Usage
watch -d -n 1 'df; ls -FlAt /path' 实时某个目录下查看最新改动过的文件
watch -n 3 ls 以3秒钟执行一个ls命令
du -sh dirname 查看目录的大小
du -h --max-depth=1 显示当前目录中所有子目录的大小
du -s * | sort -n | tail	列出当前目录里最大的10个文件。
source .profile 使profile改动生效
ntsysv 就会*出图形界面给你选择(有的则显示在里面)，如果在文本界面就用ntsysv命令
less /etc/*-release: find system version
uname -a	find out kernel versiontree directory
常见的场景是由于某种原因 ls 无法使用(内存不足、动态连接库丢失等等), 因为shell通常可以做*扩展，所以我们可以用 `echo * == ls`

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
```
#if the window name keeps renaming, create file .tmux.conf with content below
#reload tmux config .tmux.conf 
#within tmux, by pressing Ctrl+B and then :source-file ~/.tmux.conf
#Or simply from a shell: tmux source-file ~/.tmux.conf
set-option -g allow-rename off
#set -g default-terminal "xterm-256color"
```

#### panel operation
" 将当前面板上下分屏"
% 将当前面板左右分屏
x 关闭当前面板
<光标键> 移动光标选择对应面板
! 将当前面板置于新窗口,即新建一个窗口,其中仅包含当前面板
Ctrl+b+o交换两个panel位置
space 调整panel摆放方式
Ctrl+方向键 	以1个单元格为单位移动边缘以调整当前面板大小
Alt+方向键 	以5个单元格为单位移动边缘以调整当前面板大小

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
可以通过C-a ?来查看所有的键绑定，常用的键绑定有：
C-a ?	显示所有键绑定信息
C-a w	显示所有窗口列表
Ctrl+a A	set window title
C-a C-a	切换到之前显示的窗口
C-a c	创建一个新的运行shell的窗口并切换到该窗口
C-a n	切换到下一个窗口
C-a p	切换到前一个窗口(与C-a n相对)
C+a "	select window from list
C-a 0..9	切换到窗口0..9
C-a a	发送C-a到当前窗口 bash中到行首
C-a d	暂时断开screen会话
C-a k	杀掉当前窗口
C-a [	进入拷贝/回滚模式
-c file	使用配置文件file，而不使用默认的$HOME/.screenrc
screen -wipe命令清除死掉的会话

### Python
The command to print a prompt to the screen and to store the resulting input into a variable named var is:
var = raw_input('Prompt')
python -m SimpleHTTPServer  HTTP服务在8000号端口上侦听

## Programs

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
	java –version

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
#!/bin/sh
export ECLIPSE_HOME="/home/peter/opt/eclipse"
$ECLIPSE_HOME/eclipse $*
```
Let's also make eclipse executable everywhere by creating a symlink: 
sudo ln -s /usr/bin/eclipse /bin/eclipse 
Create the menu icon: sudo gedit /usr/share/applications/eclipse.desktop Type in this content and save:
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

## Misc.

### Missing clock menu bar fix:
killall unity-panel-service

### Launcher customization
launcher icon path: ./local/share/applications
Globally in /usr/share/applications, locally in ~/.local/share/applications.
If you want to add a custom launcher, create it in ~/.local/share/applications, make it executable, drag and drop it on the launcher*, and finally pin it (right-click on the launcher item → Keep In Launcher).
make it executable

## System
`zdump -v /etc/localtime` examine the contents of the timezone files

### File

#### 文件特殊权限 SUID、SGID、STICKY简介
linux中除了常见的读（r）、写（w）、执行（x）权限以外，还有3个特殊的权限，分别是setuid、setgid和stick bit
setuid、setgid实例，/usr/bin/passwd 与/etc/passwd文件的权限
```
[root@MyLinux ~]# ls -l /usr/bin/passwd /etc/passwd
-rw-r--r-- 1 root root  1549 08-19 13:54 /etc/passwd
-rwsr-xr-x 1 root root 22984 2007-01-07 /usr/bin/passwd
```
从权限上看，/etc/passwd仅有root权限的写（w）权，可实际上每个用户都可以通过/usr/bin/passwd命令去修改这个文件，于是这里就涉及了linux里的特殊权限setuid，正如-rwsr-xr-x中的s

stick bit （粘贴位） 实例，查看/tmp目录的权限
```
[root@MyLinux ~]# ls -dl /tmp
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
BROADCAST=192.168. 230.255
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

### software manage
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

### set waiting time for OS 解决Ubuntu 14.04 grub选择启动项10秒等待时间
sudo vi /etc/default/grub
update seconds: GRUB_HIDDEN_TIMEOUT=1
sudo update-grub

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
