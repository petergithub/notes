# shell

[Advanced Bash-Scripting Guide](http://tldp.org/LDP/abs/html/index.html)
[Shell 教程](https://www.runoob.com/linux/linux-shell.html)

`cat /etc/shells` get all available shells
`xargs echo`

在bash 脚本中, subshells (写在圆括号里的) 是一个很方便的方式来组合一些命令. 一个常用的例子是临时地到另一个目录中

```sh
# do something in current dir
(cd /some/other/dir && other-command)
# continue in original dir
```

`read -p "Press [Enter] key to continue"`
`read -n 1 -p "Press any key to continue"`

```sh
# echo with date
echo "`date` (print as a date result: Mar  9 17:20:49 CST 2022) end sleep 2 sec; date (print as date string: date)"
```

- `$?` 上一个命令的返回代码. 0为true, 1为false
- `$$` 进程标识号
- `$*` 该变量包含了所有输入的命令行参数值
- `$0` is a magic variable for the full path of the executed script. If your script is invoked as "`sh script-name`", then `$0` will be exactly "script-name". [self-deleting shell script - Stack Overflow](https://stackoverflow.com/questions/8981164/self-deleting-shell-script/1086907#1086907)

## alias

看看别人是怎么用好 alias 的

https://www.cyberciti.biz/tips/bash-aliases-mac-centos-linux-unix.html

https://www.digitalocean.com/community/questions/what-are-your-favorite-bash-aliases

https://www.linuxtrainingacademy.com/23-handy-bash-shell-aliases-for-unix-linux-and-mac-os-x/

https://brettterpstra.com/2013/03/31/a-few-more-of-my-favorite-shell-aliases/

```sh
### Get os name via uname ###
_myos="$(uname)"

### add alias as per os using $_myos ###
case $_myos in
   Linux) alias foo='/path/to/linux/bin/foo';;
   FreeBSD|OpenBSD) alias foo='/path/to/bsd/bin/foo' ;;
   SunOS) alias foo='/path/to/sunos/bin/foo' ;;
   *) ;;
esac
```

## Shell

```sh
# 数学表达式：
i=$(( (i + 1) % 5 ))
# 序列
{1..10}

# 使用括号扩展（{...}）来减少输入相似文本，并自动化文本组合。这在某些情况下会很有用，例如
mv foo.{txt,pdf} some-dir #（同时移动两个文件），
cp somefile{,.bak} #（会被扩展成 cp somefile somefile.bak）
mkdir -p test-{a,b,c}/subtest-{1,2,3} #（会被扩展成所有可能的组合，并创建一个目录树）。

# 在 Bash 中，同时重定向标准输出和标准错误：
通常，为了保证命令不会在标准输入里残留一个未关闭的文件句柄捆绑在你当前所在的终端上，在命令后添加 `</dev/null` 是一个好习惯。
some-command >logfile 2>&1
# 或者
some-command &>logfile
```

### stdin, stdout, stderr, <, >, >>, <<, <<<

[Here Documents](https://tldp.org/LDP/abs/html/here-docs.html)
[How does cat `cat << EOF` exactly work? : r/bash](https://www.reddit.com/r/bash/comments/132dgu9/how_does_cat_cat_eof_exactly_work/)

File 0, aka "standard input" or "stdin" for short, is where the program expects its input to come from;
file 1, aka "standard output"/"stdout", is where it's output goes;
file 2, aka "standard error"/"stderr", is where it sends error or warning messages or anything else it wants to communicate without including it in its output. Interactive programs often send prompts to standard error, for instance.

The redirection operators `<` and `>` let you read and write files instead of connecting two running programs. So

`0<` (or just `<`) redirects stdin from a file,
`1>` (or just `>`) redirects stdout to a file, and
`2>` redirects stderr to a file.
`>>` If you double the `>` in an output redirect, it appends to the file instead of clobbering it.
`<<` it creates a "[here document](https://tldp.org/LDP/abs/html/here-docs.html)", temporarily redirecting the input of the command from the source containing the command itself. It's not actually that useful interactively, because commands read from the terminal by default without any redirection, and you can always press control-D to send end-of-file to them. But it's very handy for shell scripts, since you can effectively embed an input file in the script without having to ship (or create in the script) a second file.
`<<<` here-strings, which allow you to do one-line heredocs by tripling the < and putting the text right after those instead of on following lines delimited by a sentinel. `cat <<<'this is some text'`

```sh
#!/usr/bin/env bash
cat <<EOF
this is some text
EOF

cat > webconfig.yml << EOF
basic_auth_users:
  prometheus: password
EOF

cat <<EOF | sudo tee /etc/hosts
172.17.1.2 middleware01
EOF

sudo tee /etc/hosts <<EOF
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
EOF

kubectl apply -f - <<EOF
...
EOF
```

## Shell 变量

```sh
# 定义变量时，变量名不加美元符号（$，PHP语言中变量需要），注意，变量名和等号之间不能有空格.
var_name="a variable"

# 只读变量 使用 readonly 命令可以将变量定义为只读变量
readonly var_name

# 删除变量
unset var_name

# 变量名外面的花括号是为了帮助解释器识别变量的边界, 非必须
echo ${var_name}


# 在 Bash 中，变量有许多的扩展方式。
# 用于检查变量是否存在。
${name:?error message}
# 当 Bash 脚本只需要一个参数时，可以使用这样的代码
input_file=${1:?usage: $0 input_file}

# 在变量为空时使用默认值：
${name:-default}
# 如果你要在之前的例子中再加一个（可选的）参数，可以使用类似这样的代码
# 如果省略了 $2，它的值就为空，于是 output_file 就会被设为 logfile。
output_file=${2:-logfile}
```

### 引号

双引号 double quotes

1. 双引号里的变量会进行替换.
2. $、\、'、和"这几个字符是特殊字符 (shell 引号嵌套 使用转义 \" \')

单引号 ' '

1. 单引号里的任何字符都会原样输出, 单引号字符串中的变量是无效的
2. 单引号字串中不能出现单引号（对单引号使用转义符后也不行）

反引号 `

1. 反引号括起来的字符串被shell解释为命令行, 在执行时, shell首先执行该命令行, 并以它的标准输出结果取代整个反引号（包括两个反引号）部分
2. 反引号和$()是对等的, $()能够内嵌使用, 而且避免了转义符的麻烦

[ ] 两边要加空格
`if [ $a=$b ]`才是对的. 注意: 这里的[]是test命令的一种形式, [是系统的一个内置命令,存在路径是/bin/[,它是调用test命令的标识, 右中括号是关闭条件判断的标识, 因此与测试语句`if test $a=$b`是等效的

### Shell 字符串

字符串可以用单引号，也可以用双引号，也可以不用引号。

单引号里的任何字符都会原样输出，单引号字符串中的变量是无效的；
双引号: 双引号里可以有变量, 双引号里可以出现转义字符

获得字符串长度 `${#string}` or `expr length $string`
`string="abcd"; echo ${#string}` #输出: 4
截取字符串: 第一个字符的索引值为 0。
`str="hello shell"; echo ${str:2}`  #输出: llo shell
`str="hello shell"; echo ${str:1:3}`  #输出: ell

查找子字符串第一个字母的位置
Numerical position in $string of first character in $substring that matches.
`expr index $string $substring`

```bash
# 截断字符串
${var%suffix}
${var#prefix}
# 例如，假设
var=foo.pdf
echo ${var%.pdf}.txt # 将输出 foo.txt

# 字符串截取（界定字符本身也会被删除）
str="www.runoob.com/linux/linux-shell-variable.html"
echo "str    : ${str}"
echo "str#*/    : ${str#*/}"   # 从 字符串开头 删除到 左数第一个'/'
echo "str##*/    : ${str##*/}"  # 从 字符串开头 删除到 左数最后一个'/'
echo "str%/*    : ${str%/*}"   # 从 字符串末尾 删除到 右数第一个'/'
echo "str%%/*    : ${str%%/*}"  # 从 字符串末尾 删除到 右数最后一个'/'

$ str="www.runoob.com/linux/linux-shell-variable.html"
$ echo "str    : ${str}"
str    : www.runoob.com/linux/linux-shell-variable.html
$ echo "str#*/    : ${str#*/}"   # 从 字符串开头 删除到 左数第一个'/'
str#*/    : linux/linux-shell-variable.html
$ echo "str##*/    : ${str##*/}"  # 从 字符串开头 删除到 左数最后一个'/'
str##*/    : linux-shell-variable.html
$ echo "str%/*    : ${str%/*}"   # 从 字符串末尾 删除到 右数第一个'/'
str%/*    : www.runoob.com/linux
$ echo "str%%/*    : ${str%%/*}"  # 从 字符串末尾 删除到 右数最后一个'/'
str%%/*    : www.runoob.com
```

#### 字符串拼接

`str3=$name": "$url`  #中间可以出现别的字符串
`str4="$name: $url"`  #这样写也可以
`str5="${name}Script: ${url}index.html"`  #变量与字符串挨着 需要给变量名加上大括号

#### 字符串替换 replace

[Shell-Parameter-Expansion - Bash Reference Manual](https://www.gnu.org/software/bash/manual/bash.html#Shell-Parameter-Expansion)

`${parameter/pattern/string}`: To replace the first occurrence of a pattern with a given string
`${parameter//pattern/string}`: To replace all occurrences

- `${var//\"/}` 将"替换成空
- `${var/a/b}` 将a替换成b

```sh
# 替换字符中包含 /
IMAGE="swr.cn-north-4.myhuaweicloud.com/ddn-k8s/docker.io/library/busybox:1.31.1"
in="swr.cn-north-4.myhuaweicloud.com/ddn-k8s"
out="172.17.0.1:8081/ems_pro"
echo ${IMAGE//$in/$out}

172.17.0.1:8081/ems_pro/docker.io/library/busybox:1.31.1
```

### Shell 数组

bash支持一维数组（不支持多维数组），并且没有限定数组的大小。

用括号来表示数组，数组元素用"空格"符号分割开。定义数组的一般形式为：`array_name=(value0 value1 value2 value3)`

或者

```bash
array_name=(
value0
value1
value2
value3
)
```

或者

```bash
# 可以单独定义数组的各个分量：

array_name[0]=value0
array_name[1]=value1
array_name[n]=valuen
```

读取数组元素值: `valuen=${array_name[n]}`
使用 @ 符号获取数组中的所有元素 `echo ${array_name[@]}`

```bash
# 取得数组元素的个数
length=${#array_name[@]}
# 或者
length=${#array_name[*]}
# 取得数组单个元素的长度
lengthn=${#array_name[n]}
```

### Shell 注释

以 # 开头的行就是注释，会被解释器忽略。

多行注释

```bash
# EOF 也可以使用其他符号, 比如 ' !
:<<EOF
注释内容...
注释内容...
注释内容...
EOF
```

### 逻辑与或非

1. `command || exit 1` 只要command有非零返回值，脚本就会停止执行
2. `command || { echo "command failed"; exit 1; }`
3. `if ! command; then echo "command failed"; exit 1; fi`
4. `command if [ "$?" -ne 0 ]; then echo "command failed"; exit 1; fi`
5. `command1 && command2`  只有第一个命令成功了，才能继续执行第二个命令

### test

#### Common Bash comparisons

```sh
Operator    Meaning    Example
-z  Zero-length string    [ -z "$myvar" ]
-z  string string为空
-n  Non-zero-length string  [ -n "$myvar" ]
=  String equality  [ "abc" = "$myvar" ]
!=  String inequality  [ "abc" != "$myvar" ]
-eq  Numeric equality  [ 3 -eq "$myinteger" ]
-ne  Numeric inequality  [ 3 -ne "$myinteger" ]
-lt  Numeric strict less than  [ 3 -lt "$myinteger" ]
-le  Numeric less than or equals  [ 3 -le "$myinteger" ]
-gt  Numeric strict greater than  [ 3 -gt "$myinteger" ]
-ge  Numeric greater than or equals  [ 3 -ge "$myinteger" ]
-f  Exists and is regular file 判断是否是一个文件  [ -f "$myfile" ]
-d  Exists and is directory 是否是目录 [ -d "$mydir" ]
-nt  First file is newer than second one  [ "$myfile" -nt ~/.bashrc ]
-ot  First file is older than second one  [ "$myfile" -ot ~/.bashrc ]
[ -x "/bin/ls" ] : 判断/bin/ls是否存在并有可执行权限
[ -n "$var" ] : 判断$var变量是否有值
[ "$a" = "$b" ] : 判断$a和$b是否相等
[[ $a == z* ]]   # True if $a starts with a "z" (wildcard matching).
[ $# -lt 3 ]判断输入命令行参数是否小于3个 (特殊变量$# 表示包含参数的个数)
[ ! ]
-e file   Check if file exists. Is true even if file is a directory but exists.   [ -e $file ] is true.
-t 1  Check if the file descriptor 1 (standard output) is open and refers to a terminal.

```

#### compound comparison

- -a logical and: exp1 -a exp2 returns true if both exp1 and exp2 are true.
- -o logical or: exp1 -o exp2 returns true if either exp1 or exp2 is true.

These are similar to the Bash comparison operators && and ||, used within double brackets. `[[ condition1 && condition2 ]]`
The `-o` and `-a` operators work with the test command or occur within single test brackets.

``` bash
if [ "$expr1" -a "$expr2" ]
# if  "$expr1" -a "$expr2"
then
    echo "Both expr1 and expr2 are true."
else
    echo "Either expr1 or expr2 is false."
fi
```

### 其他

```sh
# 换行符 new line, return, carriage
echo -e "\n\nCheck permission"
```

#### [`set`](https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html)

执行时传入 `bash -euxo pipefail script.sh` 或者`set -euxo pipefail` 放在脚本开头

- `set -u` 遇到不存在的变量就会报错，并停止执行， 同`set -o nounset`
- `set -x` debug输出, 在运行结果之前，先输出执行的那一行命令, 同`set -o xtrace`
- `set -e` 当有错误发生的时候abort执行
- `set +e` 表示关闭`-e`选项, 同`-o errexit`
- `set -o pipefail` 管道命令中， 只要一个子命令失败，整个管道命令就失败，脚本就会终止执行
- `set -o nounset` 在默认情况下，遇到不存在的变量，会忽略并继续执行，而这往往不符合预期，加入该选项，可以避免恶果扩大，终止脚本的执行。
- `bash -n scriptname`  # don't run commands; check for syntax errors only

有些Linux命令，例如rm的-f参数可以强制忽略错误，此时脚本便无法捕捉到errexit，这样的参数在脚本里是不推荐使用的。

#### `dirname $0`

在命令行状态下单纯执行 $ cd `dirname $0` 是毫无意义的. 因为他返回当前路径的".".
这个命令写在脚本文件里才有作用, 他返回这个脚本文件放置的目录, 并可以根据这个目录来定位所要运行程序的相对位置（绝对位置除外）.
在/home/admin/test/下新建test.sh内容如下:

```sh
cd `dirname $0`
echo `pwd`
echo $PWD
```

然后返回到/home/admin/执行 `sh test/test.sh` 运行结果: `/home/admin/test`
这样就可以知道一些和脚本一起部署的文件的位置了, 只要知道相对位置就可以根据这个目录来定位, 而可以不用关心绝对位置. 这样脚本的可移植性就提高了, 扔到任何一台服务器, （如果是部署脚本）都可以执行.

#### `pwd`, `PWD`

`pwd`命令用于显示当前工作目录.
环境变量`OLDPWD`表示前一次的工作目录,
环境变量`PWD`表示当前的工作目录.

## Script

### 向脚本传递参数

``` bash
#! /bin/sh -xe
# test.sh
echo "$# parameters"; # count of parameters
echo "$@"; # all parameters
echo "$0"; # shell script name, the zero
echo "$1"; # the first parameter

input: test.sh 11 22
output:

2 parameters
11 22
test.sh
11
```

### 封装函数

尽量封装函数使用

```sh
#!/bin/bash -xe

log() { # classic logger
    local prefix=$(date "+%Y-%m-%d %H:%M:%S")
    echo "${prefix} $@" >&2
}

log "INFO" "a message"

# 写日志到文件
LOGFILE="/var/log/repmgr/follow.log"
# Logging function
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOGFILE
}
```

### for

```sh
array=( A B C D E F G )
echo "${array[0]}"
```

the `for` command executes list once for each positional parameter that is set
positional parameter: space, line return

```sh
items=("apple" "banana" "cherry")
for item in "${items[@]}"; do
    echo "$item"
done

for i in *; do cd $i ;gfa; cd -; done
for VAR in LIST; do CMD; done;
for VAR in *.zip; do CMD; done;
for file in $(ls); do echo $file; done;
vars="a b c"; for var in ${vars}; do echo $var; done

# 数字自增
for i in 1 2 3 4 5; do echo $i; done
for i in $(seq 1 5); do echo $i; done
for i in {01..10}; do echo $i; done
for (( i = 0; i < 5; i++)); do echo $i; done;

for (( EXP1; EXP2; EXP3 )); do command1; command2; command3; done;

# 按变量IFS分割字符串并存到单独变量中
IFS=- read -r x y z <<< foo-bar-baz; echo $x, $y, $z
# 按变量IFS分割字符串并存到数组parts中
IFS=- read -ra parts <<< foo-bar-baz; echo $parts, ${parts[0]}, ${parts[1]}

```

```zsh
#!/bin/zsh
# 遍历对象
for_elements=(
    a
    b
    c
)
for e ($for_elements); do
    echo $e
done
```

```bash
# Looping over Arrays
users=(John Harry Jake Scott Philis)
for u in "${users[@]}"; do
    echo "$u is a registered user"
done

IPS="10.0.0.7 10.0.0.8"
for host in ${IPS}; do
    echo $host
done
```

``` bash
for x in one two three four; do
    echo number $x
done

output:
number one
number two
number three
number four

for myfile in /etc/r*; do
    if [ -d "$myfile" ]
    then
        echo "$myfile (dir)"
    else
        echo "$myfile"
    fi
done

for((i=0;i<3;i++)); do
    echo $i
done
```

### while

``` bash
while [ -n "$binnum" ]; do
　　...
done
```

### if/else流程控制

```sh
# Use Built-in Commands
# Whenever possible, leverage built-in shell commands rather than external binaries. Built-in commands execute faster because they don’t require loading an external process. For example, use [[ ]] for conditionals instead of [ ] or test.

# Inefficient
if [ "$var" -eq 1 ]; then
    echo "Equal to 1"
fi

# Efficient
if [[ "$var" -eq 1 ]]; then
    echo "Equal to 1"
fi
```

``` bash
if condition
then
        do something
elif condition
then
    do something
elif condition
then
    do something
else
    do something
fi
```

```bash
VAR1=var
VAR2=var
VAR3=var
if [[ "$VAR1" = "$VAR2" ]] || [[ "$VAR1" = "$VAR3" ]]; then
    echo "字符串是相等的。"
else
    echo "字符串是不相等的。"
fi

 The right side of == is a shell pattern. If you need a regular expression, use =~ then.
if [[ xaa.zip = *.zip ]]; then echo zip; else echo not zip; fi;

```

``` bash
if [ a || b && c ]; then
　 ....
elif ....; then
　 ....
else
　 ....
fi
```

### switch流程控制

``` bash
case expression in
    pattern1|pattern4|pattern5)
        do something...
        ;;
    pattern2)
        do something...
        ;;
    pattern2)
        do something...
        ;;
esac


case test_a_sentence in
    *"test"*)
        echo "in case test"
        ;;
    *)
        echo "default case "
        ;;
esac
```

``` bash

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

## example

### read each line from file

1. while: `while read line;do echo $line; done < filename`
2. cat | while: `cat filename | while read line; do echo $line; done;`
3. for: `for line in $(cat filename); do echo $line; done;`

### 加减乘除

`expr 1 + 2` or `echo $((1+2))`
`expr 1 - 2` or `echo $((1-2))`
`expr 2 \* 3` or `expr 2 "*" 3` or `echo $((2*3))`  multiply should escape it like `\*`
`expr 8 / 2` or `echo $((8/2))`
`expr 8 % 2` or `echo $((8%2))`

```shell
for x in `seq 1 10`
do
    echo $x "   "  $((${x} + 10)) " " $(($x * 10))
done
```

### 处理命令行参数

```sh

while [ "$1" != "" ]; do
    case $1 in
        -s  )   shift
    SERVER=$1 ;;
        -d  )   shift
    DATE=$1 ;;
  --paramter|p ) shift
    PARAMETER=$1;;
        -h|help  )   usage # function call
                exit ;;
        * )     usage # All other parameters
                exit 1
    esac
    shift
done
```

### 命令行菜单

```sh
#!/bin/bash
# Bash Menu Script Example

PS3='Please enter your choice: '
options=("Option 1" "Option 2" "Option 3" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Option 1")
            echo "you chose choice 1"
            ;;
        "Option 2")
            echo "you chose choice 2"
            ;;
        "Option 3")
            echo "you chose choice $REPLY which is $opt"
            ;;
        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
```

### 日期自增

``` bash
#! /bin/bash
# 日期自增
start=20170101
end=20170103
while [ $start -le $end ]
do
    echo $start
    start=`date -d "1 day $start" +%Y%m%d`
done
```

### 时间比较

[Shell比较两个日期的大小](http://www.linuxsong.org/2010/09/shell-date-compare/)
在Shell中我们可以利用date命令比较两个日期的大小, 方法是先把日期转换成时间戳格式, 再进行比较.
date 的+%s可以将日期转换成时间戳格式,看下面的例子:

``` bash
#!/bin/bash
# 时间比较

date1="2008-4-09 12:00:00"
date2="2008-4-10 15:00:00"

t1=`date -d "$date1" +%s`
t2=`date -d "$date2" +%s`

if [ $t1 -gt $t2 ]; then
    echo "$date1 > $date2"
elif [ $t1 -eq $t2 ]; then
    echo "$date1 == $date2"
else
    echo "$date1 < $date2"
fi
```

### 测量请求时间

```bash
#!/bin/bash
# 测量请求时间

DATE=`date -d now "+%Y-%m-%d %H:%M:%S"`
RESPONSE_TIME=`curl -o /dev/null -s -w '%{time_connect} %{time_starttransfer} %{time_total}\n' -I "https://www.baidu.com"`

echo ${DATE} ${RESPONSE_TIME} >> curl.log
```

### batch execute sql

```sh
#!/bin/bash

# for i in $(seq 0 98); do
for (( i = 0; i < 5; i++)); do
    #SQL="select id from db.table_$i limit 1";
    SQL="ALTER TABLE db.table_$i PARTITION BY HASH(role_id % 997) PARTITIONS 997;";

    echo `date` SQL: $SQL
    RESULT=`mysql -h host -u username -ppassword -D db -e "$SQL"`
    SQL="analyze table db.table_$i"
    echo `date` SQL: $SQL
    RESULT=`mysql -h host -u username -ppassword -D db -e "$SQL"`
    echo `date` result: $RESULT

    SEC=300
    echo "sleep $SEC sec"
    sleep $SEC;
done
```

### backup PostgreSQL database

```sh
#!/bin/bash

BACKUP_PATH=/tmp
#BACKUP_PATH=/data/backup

RESULT=$(psql -h localhost -p 5432 -U postgres --tuples-only --no-align -c "select datname from pg_catalog.pg_database where datname not in ('postgres','template0','template1') order by 1;")

echo $RESULT
# demo test

for db in $RESULT; do
    BACKUP_FILE="${BACKUP_PATH}/${db}_$(date +'%Y-%m-%d-%H-%M-%S').dump"
    echo "backup $db to $BACKUP_FILE"
    pg_dump -h localhost -p 5432 -U postgres -Fc -d $db -f $BACKUP_FILE
done

#dbs=("test" "demo")
#for db in "${dbs[@]}"; do
#    BACKUP_FILE="${BACKUP_PATH}/${db}_$(date +'%Y-%m-%d-%H-%M-%S').dump"
#    echo "backup $db to $BACKUP_FILE"
#    pg_dump -h localhost -p 5432 -U postgres -Fc -d $db -f $BACKUP_FILE
#done

#pg_dumpall -h localhost -p 5432 -U postgres -f /tmp/pg_dumpall.sql
```

### monitor process script

```bash
#!/bin/env bash
# Desc:Monitor processs by ps
# config crontab
# * * * * * /data/apps/shell/monitor.sh >> /data/logs/scripts/monitor.log 2>&1

DATE=`date -d now "+%Y-%m-%d %H:%M:%S"`
PROCESS="process_name"
PID=$(ps aux | grep -v grep | grep $PROCESS)
if [ -z "$PID" ]; then
 echo ${DATE} "Restart $PROCESS"
 service $PROCESS start
else
 echo ${DATE} "Service $PROCESS is running"
fi

TARGET="vhost_name"
RESULT=$(/usr/sbin/rabbitmqctl list_vhosts | grep $TARGET)
if [ "$RESULT" == "$TARGET" ];then
 echo ${DATE} "Service RabbitMQ is running. result $RESULT"
else
 echo ${DATE} "Restart RabbitMQ"
 /sbin/service rabbitmq-server start
fi
```

### RabbitMQ monitor

```bash
#!/bin/env bash
# Desc:Monitor RabbitMQ processs
# * * * * * /data/apps/shell/monitor.sh >> /data/logs/scripts/monitor.log 2>&1

DATE=`date -d now "+%Y-%m-%d %H:%M:%S"`
TARGET="vhost_name"
RESULT=$(/usr/sbin/rabbitmqctl list_vhosts | grep $TARGET)
if [ "$RESULT" == "$TARGET" ];then
 echo ${DATE} "Service RabbitMQ is running. result $RESULT"
else
 echo ${DATE} "Restart RabbitMQ"
 /sbin/service rabbitmq-server start
fi
```
