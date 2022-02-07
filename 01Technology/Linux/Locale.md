# Locale

locale 命名规则：`<语言>_<地区>.<字符集编码><@修正值>`

例如：
`zh_CN.utf8`，zh代表中文，CN代表大陆地区，utf8表示字符集。

`de_DE.UTF-8@euro` de表示德语，DE表示德国，UTF-8表示字符集，euro表示按照欧洲习惯加以修正 

Linux中locale文件存放位置： `/usr/share/i18n/locales`

示例：

```bash
# 优先级级别：LC_ALL>LC_*>LANG

weblogic@YDCK-APP11:~/.ssh> locale
LANG=zh_CN.utf8
LC_CTYPE="zh_CN.utf8"
LC_NUMERIC="zh_CN.utf8"
LC_TIME="zh_CN.utf8"
LC_COLLATE="zh_CN.utf8"
LC_MONETARY="zh_CN.utf8"
LC_MESSAGES="zh_CN.utf8"
LC_PAPER="zh_CN.utf8"
LC_NAME="zh_CN.utf8"
LC_ADDRESS="zh_CN.utf8"
LC_TELEPHONE="zh_CN.utf8"
LC_MEASUREMENT="zh_CN.utf8"
LC_IDENTIFICATION="zh_CN.utf8"
LC_ALL=

# LANG              #LANG的优先级是最低的，它是所有LC_*变量的默认值。下方所有以LC_开头变量（不包括LC_ALL）中，如果存在没有设置变量值的变量，那么系统将会使用LANG的变量值来给这个变量进行赋值。如果变量有值，则保持不变，不受影响。可以看到，我们上面示例中的输出中的LC_*变量的值其实就是LANG变量决定的

# LC_CTYPE          #用于字符分类和字符串处理，控制所有字符的处理方式，包括字符编码，字符是单字节还是多字节，如何打印等，这个变量是最重要的。
# LC_NUMERIC              #用于格式化非货币的数字显示。
# LC_TIME               #用于格式化时间和日期。
# LC_COLLATE                #用于比较和排序。
# LC_MONETORY           #用于格式化货币单位。
# LC_MESSAGES             #用于控制程序输出时所使用的语言，主要是提示信息，错误信息，状态信息， 标题，标签， 按钮和菜单等。
# LC_PAPER                     #默认纸张尺寸大小
# LC_NAME                     #姓名书写方式
# LC_ADDRESS                #地址书写方式
# LC_TELEPHONE            #电话号码书写方式
# LC_MEASUREMENT     #度量衡表达方式
# LC_IDENTIFICATION    #locale对自身包含信息的概述

# LC_ALL                         #它不是环境变量，它是一个宏，可通过该变量的设置覆盖所有的LC_*变量。这个变量设置之后，可以废除LC_*的设置值，使得这些变量的设置值与LC_ALL的值一致，注意，LANG变量不受影响。
```

注意：定义这么多变量在某些情况下是很有用的，例如，当我需要一个能够输入中文的英文环境，我可以把 `LC_CTYPE`设定成`zh_CN.GB18030`，而其他所有的项都是`en_US.UTF-8`。

总结：`LANG` 是`LC_*`的默认值，而`LC_ALL`比`LC_*`的优先级都高，设置完`LC_ALL`之后，会强制重置`LC_*`的值，如果不将`LC_ALL`的值重置为空，则无法再去设置`LC_*`的值

优先级排序：`LC_ALL` > `LC_*` > `LANG`（默认值）

一般来说，我们在新装系统之后，默认的`locale`就是`C`或`POSIX`：C是系统默认的locale，而`POSIX`是`C`的别名，这是标准的`C Locale`。这里说的`C`其实就是`ASCII`编码。

`POSIX`：可移植操作系统接口（Portable Operating System Interface of UNIX，缩写为 `POSIX` ）`POSIX`标准定义了操作系统应该为应用程序提供的接口标准

Set locale:
`LANG=en_US.UTF-8`
`export LANG`

`locale` 查看当前locale设置
`locale -a | less` Query all supported locale 查看当前系统的所有可用locale
or `less /usr/share/i18n/SUPPORTED` on a Debian or Ubuntu based system

## 设置系统的locale

1）编辑文件：/etc/profie，在文件末尾添加以下内容并报错退出

```bash
#vim /etc/profile
export LC_ALL=zh_CN.utf8
export LANG=zh_CN.utf8
2）执行生效命令：
#source /etc/profile
```

[Linux字符集和系统语言设置-LANG,locale,LC_ALL,POSIX等命令及参数详解_1清风揽月1_51CTO博客](https://blog.51cto.com/watchmen/1940609)

## 让容器内可以正常显示中文

需要先安装`locale`,然后设置成`zh_CN.UTF-8`

修改Dockerfile，添加

```bash
RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
    && localedef -i zh_CN -c -f UTF-8 -A /usr/share/locale/locale.alias zh_CN.UTF-8
ENV LANG zh_CN.utf8
```
