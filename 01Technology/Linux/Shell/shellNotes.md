# shell

[Advanced Bash-Scripting Guide](http://tldp.org/LDP/abs/html/index.html)
[Shell 教程](https://www.runoob.com/linux/linux-shell.html)

`cat /etc/shells` get all available shells
`xargs echo`

在bash 脚本中, subshells (写在圆括号里的) 是一个很方便的方式来组合一些命令. 一个常用的例子是临时地到另一个目录中

`read -p "Press [Enter] key to continue"`
`read -n 1 -p "Press any key to continue"`

```sh
# echo with date
echo "`date` (print as a date result: Mar  9 17:20:49 CST 2022) end sleep 2 sec; date (print as date string: date)"
```

* `$?` 上一个命令的返回代码. 0为true, 1为false
* `$$` 进程标识号
* `$*` 该变量包含了所有输入的命令行参数值
* `$0` is a magic variable for the full path of the executed script. If your script is invoked as "`sh script-name`", then `$0` will be exactly "script-name". [self-deleting shell script - Stack Overflow](https://stackoverflow.com/questions/8981164/self-deleting-shell-script/1086907#1086907)

## Shell 变量

定义变量时，变量名不加美元符号（$，PHP语言中变量需要），注意，变量名和等号之间不能有空格. 如： `var_name="a variable"`
只读变量 使用 readonly 命令可以将变量定义为只读变量， `readonly var_name`

删除变量 `unset var_name`

`echo ${var_name}` 变量名外面的花括号是为了帮助解释器识别变量的边界, 非必须

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
# 字符串截取（界定字符本身也会被删除）
str="www.runoob.com/linux/linux-shell-variable.html"
echo "str    : ${str}"
echo "str#*/    : ${str#*/}"   # 从 字符串开头 删除到 左数第一个'/'
echo "str##*/    : ${str##*/}"  # 从 字符串开头 删除到 左数最后一个'/'
echo "str%/*    : ${str%/*}"   # 从 字符串末尾 删除到 右数第一个'/'
echo "str%%/*    : ${str%%/*}"  # 从 字符串末尾 删除到 右数最后一个'/'

```

#### 字符串拼接

`str3=$name": "$url`  #中间可以出现别的字符串
`str4="$name: $url"`  #这样写也可以
`str5="${name}Script: ${url}index.html"`  #变量与字符串挨着 需要给变量名加上大括号

#### 字符串替换 replace

* `${var//\"/}` 将"替换成空
* `${var/a/b}` 将a替换成b

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

```text
Operator    Meaning    Example
-z    Zero-length string    [ -z "$myvar" ]
-z string string为空
-n    Non-zero-length string    [ -n "$myvar" ]
=    String equality    [ "abc" = "$myvar" ]
!=    String inequality    [ "abc" != "$myvar" ]
-eq    Numeric equality    [ 3 -eq "$myinteger" ]
-ne    Numeric inequality    [ 3 -ne "$myinteger" ]
-lt    Numeric strict less than    [ 3 -lt "$myinteger" ]
-le    Numeric less than or equals    [ 3 -le "$myinteger" ]
-gt    Numeric strict greater than    [ 3 -gt "$myinteger" ]
-ge    Numeric greater than or equals    [ 3 -ge "$myinteger" ]
-f    Exists and is regular file    [ -f "$myfile" ]
[ -f "somefile" ] : 判断是否是一个文件
-d    Exists and is directory    [ -d "$mydir" ]
-d 是否是目录
-nt    First file is newer than second one    [ "$myfile" -nt ~/.bashrc ]
-ot    First file is older than second one    [ "$myfile" -ot ~/.bashrc ]
[ -x "/bin/ls" ] : 判断/bin/ls是否存在并有可执行权限
[ -n "$var" ] : 判断$var变量是否有值
[ "$a" = "$b" ] : 判断$a和$b是否相等
[[ $a == z* ]]   # True if $a starts with a "z" (wildcard matching).
[ $# -lt 3 ]判断输入命令行参数是否小于3个 (特殊变量$# 表示包含参数的个数)
[ ! ]
-e file     Check if file exists. Is true even if file is a directory but exists.     [ -e $file ] is true.
```

#### compound comparison

* -a logical and: exp1 -a exp2 returns true if both exp1 and exp2 are true.
* -o logical or: exp1 -o exp2 returns true if either exp1 or exp2 is true.

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

#### [`set`](https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html)

执行时传入 `bash -euxo pipefail script.sh` 或者`set -euxo pipefail` 放在脚本开头

* `set -u` 遇到不存在的变量就会报错，并停止执行， 同`set -o nounset`
* `set -x` debug输出, 在运行结果之前，先输出执行的那一行命令, 同`set -o xtrace`
* `set -e` 当有错误发生的时候abort执行
* `set +e` 表示关闭`-e`选项, 同`-o errexit`
* `set -o pipefail` 管道命令中， 只要一个子命令失败，整个管道命令就失败，脚本就会终止执行
* `set -o nounset` 在默认情况下，遇到不存在的变量，会忽略并继续执行，而这往往不符合预期，加入该选项，可以避免恶果扩大，终止脚本的执行。
* `bash -n scriptname`  # don't run commands; check for syntax errors only

有些Linux命令，例如rm的-f参数可以强制忽略错误，此时脚本便无法捕捉到errexit，这样的参数在脚本里是不推荐使用的。

#### `dirname $0`

在命令行状态下单纯执行 $ cd `dirname $0` 是毫无意义的. 因为他返回当前路径的".".
这个命令写在脚本文件里才有作用, 他返回这个脚本文件放置的目录, 并可以根据这个目录来定位所要运行程序的相对位置（绝对位置除外）.
在/home/admin/test/下新建test.sh内容如下:

   cd `dirname $0`
   echo `pwd`

然后返回到/home/admin/执行 `sh test/test.sh` 运行结果: `/home/admin/test`
这样就可以知道一些和脚本一起部署的文件的位置了, 只要知道相对位置就可以根据这个目录来定位, 而可以不用关心绝对位置. 这样脚本的可移植性就提高了, 扔到任何一台服务器, （如果是部署脚本）都可以执行.

#### `pwd`, `PWD`

`pwd`命令用于显示当前工作目录.
环境变量`OLDPWD`表示前一次的工作目录,
环境变量`PWD`表示当前的工作目录.

## Script

### 向脚本传递参数

``` bash
#! /bin/sh
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
log() { # classic logger
    local prefix=$(date "+%Y-%m-%d %H:%M:%S")
    echo "${prefix} $@" >&2
}

log "INFO" "a message"
```

### for

`array=( A B C D E F G )`
`echo "${array[0]}"`

the  for  command  executes  list once for each positional parameter that is set
positional parameter: space, line return

```sh
for i in *; do cd $i ;gfa; cd -; done

for VAR in LIST; do CMD; done;

for VAR in *.zip; do CMD; done;
for file in $(ls); do echo $file; done;

# 数字自增
for i in 1 2 3 4 5; do echo $i; done;
for i in $(seq 1 5); do echo $i; done
for i in {01..10}; do echo $i; done
for (( i = 0; i < 5; i++)); do echo $i; done;

for (( EXP1; EXP2; EXP3 )); do command1; command2; command3; done;

# 按变量IFS分割字符串并存到单独变量中
IFS=- read -r x y z <<< foo-bar-baz; echo $x, $y, $z
# 按变量IFS分割字符串并存到数组parts中
IFS=- read -ra parts <<< foo-bar-baz; echo $parts, ${parts[0]}, ${parts[1]}

```

```bash
# 遍历对象
for_elements=(
    a
    b
    c
)
for e ($for_elements); do
    echo $e
done

# Looping over Arrays

users=(John Harry Jake Scott Philis)
for u in "${users[@]}"
do
    echo "$u is a registered user"
done
```

``` bash

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

    for((i=0;i<3;i++))
    do
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

    for x in ` seq 1 10 `
    do
        echo $x "   "  $((${x} + 10)) " " $(($x * 10))
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
