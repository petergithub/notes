# CentOS

## SELinux

### Disable SELinux Temporarily until the next reboot

enable status: `sestatus | grep Current` return `Current mode:enforcing`

Disable Temporarily `setenforce Permissive`
Check: `sestatus | grep Current` return `Current mode:permissive`

Enable: `setenforce enforcing`

### Disable SELinux Permanently

`sed -i 's/SELinux=enforcing/SELinux=disabled/' /etc/sysconfig/selinux` then reboot system and then check the status with `sestatus`

## 关机

centos关机命令：

1. `halt` 立马关机
2. `shutdown -h 10` 10分钟后自动关机
3. `poweroff` 立刻关机,并且电源也会断掉
4. `shutdown -h now` 立刻关机(root用户使用)

如果是通过shutdown命令设置关机的话，可以用`shutdown -c`命令取消重启

## 自动启动

### CentOS 7 配置系统服务来设置自启动

`systemctl enable mysqld` 把MySQL服务设置成自启动

`systemctl status mysqld` 检查一下状态

### CentOS 6 自动启动

/etc/rc.d/rc.local

## Firewall

[Centos 7 和 Centos 6 开放查看端口 防火墙关闭打开](https://www.cnblogs.com/eaglezb/p/6073739.html)

### CentOS 6.5 使用 iptables

防火墙状态 `service iptables status`
关闭防火墙 `service iptables stop`
重启防火墙 `service iptables restart`
去掉开机启动 `chkconfig --del iptables`

#### 开放端口

开放 22 端口 `iptables -I INPUT -p tcp --dport 22 -j ACCEPT`
保存： `service iptables save`

Debian/Ubuntu: `iptables-save > /etc/iptables/rules.v4`
RHEL/CentOS: `iptables-save > /etc/sysconfig/iptables`

#### 关闭防火墙

1） 永久性生效
开启： `chkconfig iptables on`
关闭： `chkconfig iptables off`

2） 临时生效 重启服务器复原
开启： `service iptables start`
关闭： `service iptables stop`

### Centos 7 firewall 使用 systemd 管理

查看已经开放的端口：`firewall-cmd --list-ports`

开启端口 `firewall-cmd --zone=public --add-port=80/udp --permanent` `firewall-cmd --reload`
多个端口 `firewall-cmd --zone=public --add-port=80-90/tcp --permanent`
删除 `firewall-cmd --zone=public --remove-port=80/tcp --permanent`

命令含义：
`–zone` #作用域
`–add-port=80/tcp` #添加端口，格式为：端口/通讯协议
`–permanent` #永久生效，没有此参数重启后失效

`firewall-cmd --reload` #重启firewall
`firewall-cmd --state` #查看默认防火墙状态（关闭后显示notrunning，开启后显示running）
`systemctl restart firewalld`
`systemctl stop firewalld` #停止firewall
`systemctl disable firewalld` #禁止firewall开机启动

#### CentOS 7 启用 iptables

CentOS 7默认使用的是firewall作为防火墙，使用iptables必须重新设置一下

1. 关闭防火墙 firewalld
`systemctl stop firewalld` #停止firewall
`systemctl disable firewalld` #禁止firewall开机启动
`systemctl mask firewalld` `mask`是注销服务的意思。 注销服务意味着：. 该服务在系统重启的时候不会启动. 该服务无法进行做systemctl start/stop操作

2. 设置 iptables service `yum -y install iptables-services`
如果要修改防火墙配置，如增加防火墙端口3306 `vi /etc/sysconfig/iptables`
增加规则 `-A INPUT -m state --state NEW -m tcp -p tcp --dport 3306 -j ACCEPT`

保存退出后
`systemctl restart iptables` #重启防火墙使配置生效
`systemctl enable iptables` #设置防火墙开机启动

最后重启系统使设置生效即可。
`systemctl start iptables` #打开防火墙
`systemctl stop iptables` #关闭防火墙

Other command `systemctl disable iptables`

#### iptables 简介

[iptables简介及命令用法](https://liu2lin600.github.io/2016/07/23/iptables简介及命令用法)

Linux上的防火墙套件为iptables/netfilter，iptables是用户空间上配置与修改过滤规则的命令，生成的规则直接送往linux内核空间netfilter中，netfilter是Linux核心中的一个通用架构，用于接收并生效规则，起到防火墙作用

[iptables 和 netfilter 的关系](https://liu2lin600.github.io/2016/07/23/iptables简介及命令用法/iptables.png)

在netfilter上定义了5个钩子函数(hook function)，分别作用于5个链上：

1. 路由前，目标地址转换 == > PREROUTING
2. 到达本机内部的报文必经之路 == > INPUT
3. 由本机转发的报文必经之路 == > FORWARD
4. 由本机发出的报文的必经之路 == > OUTPUT
5. 路由后，源地址转换 == > POSTROUTING

netfilter提供了一系列的表(tables),每个表由若干个链(chains)组成，而每条链可以由一条或若干条规则(rules)组成，关系如下：

[iptables 的表 tables 和链 chains 的关系](https://liu2lin600.github.io/2016/07/23/iptables简介及命令用法/iptables1.png/)

4表

1. raw：用于配置数据包，raw 中的数据包不会被系统跟踪
2. mangle：用于对特定数据包的修改
3. nat：用于网络地址转换，如SNAT、DNAT、MASQUERADE、REDIRECT
4. filter：过滤，定义是否允许通过防火墙

5链

1. INPUT链：当接收到防火墙本机地址的数据包（入站）时，应用此链中的规则
2. OUTPUT链：当防火墙本机向外发送数据包（出站）时，应用此链中的规则
3. FORWARD链：当接收到需要通过防火墙发送给其他地址的数据包（转发）时，应用此链中的规则
4. PREROUTING链：在对数据包作路由选择之前，应用此链中的规则
5. POSTROUTING链：在对数据包作路由选择之后，应用此链中的规则

规则(处理机制)

1. ACCEPT：允许数据包通过
2. DROP：直接丢弃数据包，不给任何回应信息
3. REJECT：拒绝数据包通过，同时会给数据发送端一个响应的信息
4. SNAT：源地址转换，解决内网用户用同一个公网地址上网的问题，仅作用于nat表上POSTROUTING，INPUT上。在进入路由层面的route之前，重新改写源地址，目标地址不变，并在本机建立NAT表项，当数据返回时，根据NAT表将目的地址数据改写为数据发送出去时候的源地址，并发送给主机
5. MASQUERADE：是SNAT的一种特殊形式，适用于像adsl这种临时会变的ip上
6. DNAT:目标地址转换，让互联网上主机访问本地内网上的某服务器上的服务，仅作用于nat表上PREROUTING和OUTPUT。和SNAT相反，IP包经过route之后、出本地的网络栈之前，重新修改目标地址，源地址不变，在本机建立NAT表项，当数据返回时，根据NAT表将源地址修改为数据发送过来时的目标地址，并发给远程主机，可以隐藏后端服务器的真实地址
7. REDIRECT：是DNAT的一种特殊形式，将网络包转发到本地host上（不管IP头部指定的目标地址是啥），方便在本机做端口转发
8. LOG：仅记录日志信息，然后将数据包传递给下一条规则
9. RETURN：一般用于自定义链上，自定义链被内置链引用时，当没有规则被匹配时，返回内置链的下一条规则

数据流向

与本机内部进程通信：

进入：–> PREROUTING –> INPUT
出去：–> OUTPUT –> POSTROUTING

由本机转发：

请求：–>PREROUTING–>FORWARD–>POSTROUTING
响应：–>PREROUTING–>FORWARD–>POSTROUTING

[iptables 数据流向及相应的表链关系图](https://liu2lin600.github.io/2016/07/23/iptables简介及命令用法/iptables2.jpg)

##### iptables命令用法

iptables [-t table] COMMAND chain [num] [-m match [match-options]] [-j target [target-options]]

查看

iptables -L -n

常用选项

链管理

-F：flush, 清空规则链，无法还原
-N：new, 新建一条自定义链，被内建链上规则调用才能生效
-X：delete, 删除引用计数为0的自定义空链
-P：policy，设置默认策略，对filter表来讲，默认规则为ACCEPT或DROP
-E：重命名引用计数为0的自定义链
-Z：zero，计数器归零

规则管理

-A：Append，在尾后追加
-I：Insert，在指定位插入规则，省略位置则为链首
-D：Delete，删除指定规则
-R：Replace，将指定规则替换为新规则

显示

-L：list，列出表中的链上的规则；
-n：numeric，以数值格式显示；
-v：verbose，显示详细格式信息，更详细-vv, -vvv
-x：exactly，计数器的精确结果；
--line-numbers：显示链中的规则编号

```sh
iptables -vnL               # 默认显示filter表规则，可指定表显示
iptables -F -t filter       # 清空filter表中规则，不指定则清空所有表中的规则
iptables -P INPUT DROP      # 设置INPUT链默认处理机制为DROP
iptables -D INPUT 2         # 删除INPUT链上第2条规则
iptables -N test_chain      # 添加自定义链test_chain，其只能被内置链接所引用
iptables -X test_chain      # 删除引用计数为0的自定义空链
iptables -I INPUT 2 xxxx    # 添加规则到INPUT上第2条
iptables -A OUTPUT xxxx     # 在OUTPUT链尾添加
```

保存和重载规则

使用iptables命令生成的规则在重启后将失效，所以可将规则保存至文件，重启时从文件中读取

```sh
iptables-save > /PATH/TO/SOME_RULE_FILE       # 将编写的规则保存到指定文件中
iptables-restore < /PATH/FROM/SOME_RULE_FILE  # 从指定文件中恢复规则

# centos6上也可使用如下命令
service iptables save       # 自动保存规则至/etc/sysconfig/iptables文件中
server iptables restore     # 从/etc/sysconfig/iptables文件中重载规则
```

规则优化:

1. 可安全放行所有入站及出站，且状态为ESTABLISHED的连接
2. 服务于同一类功能的规则，匹配条件严格的放前面，宽松放后面
3. 服务于不同类功能的规则，匹配报文可能性较大扩前面，较小放后面
4. 设置默认策略：
   1. (a) 最后一条规则设定
   2. (b) 默认策略设定

iptables-save 输出的解释

* -s 指明”匹配条件”中的”源地址”，即如果报文的源地址属于-s对应的地址，那么报文则满足匹配条件，-s为source之意，表示源地址。
* -j 指明当”匹配条件”被满足时，所对应的动作，上例中指定的动作为DROP，在上例中，当报文的源地址为192.168.1.146时，报文则被DROP（丢弃）。
* -m 模块关键字 调用显示匹配
* -p 协议
* -d 目标地址

[iptables详解示例](https://www.cnblogs.com/sunsky303/p/12327863.html)

```sh
[root@worker01 docker]# iptables-save | grep backend
-A KUBE-SEP-FJGLA3RP7W3WND5T -s 10.244.3.54/32 -m comment --comment "test/backend:backend" -j KUBE-MARK-MASQ
-A KUBE-SEP-FJGLA3RP7W3WND5T -p tcp -m comment --comment "test/backend:backend" -m tcp -j DNAT --to-destination 10.244.3.54:28080
-A KUBE-SERVICES -d 10.99.56.175/32 -p tcp -m comment --comment "test/backend:backend cluster IP" -m tcp --dport 80 -j KUBE-SVC-F7FBEKZZKTJ6WYRO
-A KUBE-SVC-F7FBEKZZKTJ6WYRO ! -s 10.244.0.0/16 -d 10.99.56.175/32 -p tcp -m comment --comment "test/backend:backend cluster IP" -m tcp --dport 80 -j KUBE-MARK-MASQ
-A KUBE-SVC-F7FBEKZZKTJ6WYRO -m comment --comment "test/backend:backend -> 10.244.3.54:28080" -j KUBE-SEP-FJGLA3RP7W3WND5T


# iptables-save -t nat -c
# 说明：-t 表示要dump的表(不指定的话dump所有表的配置)。-c 表示输出中显示每条规则当前报文计数。

# Generated by iptables-save v1.4.21 on Tue Jan 15 15:42:32 2019
--这是注释
*nat
-- 这表示下面这些是nat表中的配置
:PREROUTING ACCEPT [5129516:445315174]
-- :PREROUTING ACCEPT，表示nat表中的PREROUTING 链默认报文策略是接受（匹配不到规则继续） ，

-- [5129516:445315174] 即[packet, bytes]，表示当前有5129516个包(445315174字节)经过nat表的PREROUTING 链
:INPUT ACCEPT [942957:151143842]
:OUTPUT ACCEPT [23898:3536261]
:POSTROUTING ACCEPT [23898:3536261]
-- 解释同上
:DOCKER - [0:0]
-- 解释同上（此条是自定义链）
---------- 下面开始按条输出所有规则----------
[4075:366986] -A PREROUTING -m addrtype --dst-type LOCAL -j DOCKER
-- [4075:366986]即[packet, bytes]，表示经过此规则的包数，字节数。 后面部分则是用iptables命令配置此规则的命令（详解选项可参考iptables帮助）。
[0:0] -A OUTPUT ! -d 127.0.0.0/8 -m addrtype --dst-type LOCAL -j DOCKER
[0:0] -A POSTROUTING -s 172.17.0.0/16 ! -o docker0 -j MASQUERADE
[2:188] -A POSTROUTING -s 192.168.122.0/24 -d 224.0.0.0/24 -j RETURN
[0:0] -A POSTROUTING -s 192.168.122.0/24 -d 255.255.255.255/32 -j RETURN
[0:0] -A POSTROUTING -s 192.168.122.0/24 ! -d 192.168.122.0/24 -p tcp -j MASQUERADE --to-ports 1024-65535
[0:0] -A POSTROUTING -s 192.168.122.0/24 ! -d 192.168.122.0/24 -p udp -j MASQUERADE --to-ports 1024-65535
[0:0] -A POSTROUTING -s 192.168.122.0/24 ! -d 192.168.122.0/24 -j MASQUERADE
[0:0] -A DOCKER -i docker0 -j RETURN
--以上规则同第一条规则的解释
COMMIT
-- 应用上述配置
# Completed on Tue Jan 15 15:42:32 2019
```

### 排查案例

解决主机不能访问虚拟机CentOS中的站点
前阵子在虚拟机上装好了CentOS6.2，并配好了apache+php+mysql，但是本机就是无法访问。一直就没去折腾了

具体情况如下

1. 本机能ping通虚拟机
2. 虚拟机也能ping通本机
3. 虚拟机能访问自己的web
4. 本机无法访问虚拟机的web

后来发现是防火墙将80端口屏蔽了的缘故。
检查是不是服务器的80端口被防火墙堵了，可以通过命令：`telnet server_ip 80` 来测试。

解决方法如下 `iptables -I INPUT -p tcp --dport 80 -j ACCEPT`
然后保存 `service ptables save`
重启防火墙 `service iptables restart`

CentOS防火墙的关闭，关闭其服务即可：
查看CentOS防火墙信息：`service iptables status`
关闭CentOS防火墙服务：`service iptables stop`

## Install

[Windows 7 下硬盘安装 CentOS 7](https://segmentfault.com/a/1190000017744754)

hostnamectl set-hostname new-hostname

### U盘启动盘制作

[Mac下制作CentOS7启动盘](https://github.com/jaywcjlove/handbook/blob/master/CentOS/Mac%E4%B8%8B%E5%88%B6%E4%BD%9CCentOS7%E5%90%AF%E5%8A%A8%E7%9B%98.md)

将ISO写入U盘可使用命令行工具dd，操作如下：

1. 找出U盘挂载的路径，使用如下命令：`diskutil list`
2. 将U盘unmount（将N替换为挂载路径）：`diskutil unmountDisk /dev/disk[N]` eg: `diskutil unmountDisk /dev/disk5`
3. 写入U盘：`sudo dd if=iso路径 of=/dev/rdisk[N] bs=1m` rdisk 中加入r可以让写入速度加快 eg: `sudo dd if=/Users/pu/Downloads/CentOS-7-x86_64-DVD-1810.iso of=/dev/rdisk5 bs=1m`

### 设置IP地址、网关DNS

说明：CentOS 7.x默认安装好之后是没有自动开启网络连接的，所以需要我们自己配置。
在命令行输入 `vi /etc/sysconfig/network-scripts/ifcfg-ens33`  #编辑配置文件，添加修改或添加以下内容。

``` bash
ONBOOT=yes  #开启自动启用网络连接
BOOTPROTO=static #启用静态IP地址
IPADDR=172.17.0.22
GATEWAY=172.17.0.1   #设置网关
NETMASK=255.255.254.0
DNS1=114.114.114.114
DNS2=8.8.8.8
```

`service network restart`   #重启网络
`yum install initscripts` #如果遇到错误 `Failed to restart network.service: Unit not found.`
`touch /etc/sysconfig/network` # The file can be empty. Just has to exist. 如果遇到错误 [`Failed to start LSB: Bring up/down networking - Centos 7`](https://unix.stackexchange.com/questions/278155/network-service-failed-to-start-lsb-bring-up-down-networking-centos-7)
`ping www.baidu.com`  #测试网络是否正常
`ip addr`  #查看IP地址

### 自定义yum源、NTP服务和DNS服务

```sh
#!/bin/sh
# Modify DNS
echo "nameserver 8.8.8.8" | tee /etc/resolv.conf

# Modify yum repo and update

# example 1 https://help.aliyun.com/document_detail/120851.html
sudo mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
sudo wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
sudo yum clean all && sudo yum makecache

# example 2
rm -rf /etc/yum.repos.d/*
touch myrepo.repo
echo "[base]" | tee /etc/yum.repos.d/myrepo.repo
echo "name=myrepo" | tee -a /etc/yum.repos.d/myrepo.repo
echo "baseurl=http://mirror.centos.org/centos" | tee -a /etc/yum.repos.d/myrepo.repo
echo "gpgcheck=0" | tee -a /etc/yum.repos.d/myrepo.repo
echo "enabled=1" | tee -a /etc/yum.repos.d/myrepo.repo

yum update -y
# Modify NTP Server
echo "server ntp1.aliyun.com" | tee /etc/ntp.conf
systemctl restart ntpd.service
```

### 设置语言

```sh
# check what is the current language of your system
cat /etc/locale.conf
# or
locale |grep -i lang

# To check what locale are available on your system you can use “localectl” command with “list-locales” option.
localectl list-locales |grep en_US.utf8

# change the language
localectl set-locale LANG=en_US.utf8
# logout and login and you will see new locale is effective
```

### virtualbox windows 宿主机 CentOS 7 虚拟机 共享文件

[VirtualBox虚拟机设置共享文件夹（CentOS） - Excel2016 - 博客园](https://www.cnblogs.com/skyvip/p/18151918)

```sh
# yum install -y perl gcc dkms kernel-devel kernel-headers make bzip2
# yum -y install bzip2 xorg-x11-drivers xorg-x11-utils

# 挂载virtualbox 的光盘 VBoxGuestAdditions.iso
mkdir /mnt/cd
sudo mount /dev/cdrom /mnt/cd
cd /mnt/cd
./VBoxLinuxAdditions.run

# (⎈|qjca:kube-system)/mnt/cd sudo sh VBoxLinuxAdditions.run
# Verifying archive integrity...  100%   MD5 checksums are OK. All good.
# Uncompressing VirtualBox 7.0.12 Guest Additions for Linux  100%
# VirtualBox Guest Additions installer
# Removing installed version 7.0.12 of VirtualBox Guest Additions...
# Copying additional installer modules ...
# Installing additional modules ...
# VirtualBox Guest Additions: Starting.
# VirtualBox Guest Additions: Setting up modules
# VirtualBox Guest Additions: Building the VirtualBox Guest Additions kernel
# modules.  This may take a while.
# VirtualBox Guest Additions: To build modules for other installed kernels, run
# VirtualBox Guest Additions:   /sbin/rcvboxadd quicksetup <version>
# VirtualBox Guest Additions: or
# VirtualBox Guest Additions:   /sbin/rcvboxadd quicksetup all
# VirtualBox Guest Additions: Kernel headers not found for target kernel
# 3.10.0-1160.71.1.el7.x86_64. Please install them and execute
#   /sbin/rcvboxadd setup
# VirtualBox Guest Additions: reloading kernel modules and services
# VirtualBox Guest Additions: unable to load vboxguest kernel module, see dmesg
# VirtualBox Guest Additions: kernel modules and services were not reloaded
# The log file /var/log/vboxadd-setup.log may contain further information.

sudo yum install -y kernel-devel gcc
sudo yum -y upgrade kernel kernel-devel

uname -r                                               #查看内核版本
sudo yum install -y kernel-devel-3.10.0-1160.71.1.el7.x86_64   #安装内核头文件
/sbin/rcvboxadd setup                                  #运行 VirtualBox Guest Additions 的设置脚本

# VirtualBox Guest Additions: Starting.
# VirtualBox Guest Additions: Setting up modules
# VirtualBox Guest Additions: Building the VirtualBox Guest Additions kernel
# modules.  This may take a while.
# VirtualBox Guest Additions: To build modules for other installed kernels, run
# VirtualBox Guest Additions:   /sbin/rcvboxadd quicksetup <version>
# VirtualBox Guest Additions: or
# VirtualBox Guest Additions:   /sbin/rcvboxadd quicksetup all
# VirtualBox Guest Additions: Building the modules for kernel
# 3.10.0-1160.71.1.el7.x86_64.
# VirtualBox Guest Additions: reloading kernel modules and services
# VirtualBox Guest Additions: kernel modules and services 7.0.12 r159484 reloaded
# VirtualBox Guest Additions: NOTE: you may still consider to re-login if some
# user session specific services (Shared Clipboard, Drag and Drop, Seamless or
# Guest Screen Resize) were not restarted automatically


# 安装成功会提示 restart system，如果没有查看 /var/log/vboxadd-setup.log 的错误提示
# 如果/var/log/vboxadd-setup.log里面的错误提示为：

# Could not find the X.Org or XFree86 Window System, skipping.
sudo yum install -y xorg-x11-server-Xorg

# libXrandr.so.2: cannot open shared object file: No such file or directory
sudo yum install -y libXrandr.x86_64


# 添加共享文件夹
# 在VirtualBox中打开“设置”，选择“共享文件夹”，点击添加。
# Folder Path 是宿主机路径，Folder Name 是挂载时使用的名字 比如使用 share

sudo mkdir /d
sudo chown jasolar:jasolar /d
sudo mount -t vboxsf -o uid=$UID,gid=$(id -g) D_DRIVE /d
sudo mkdir /e
sudo chown jasolar:jasolar /e
sudo mount -t vboxsf -o uid=$UID,gid=$(id -g) E_DRIVE /e

# 设置自动挂载
#  -a 追加文件
sudo tee -a /etc/rc.local <<EOF
mount -t vboxsf -o uid=$UID,gid=$(id -g) D_DRIVE /d
mount -t vboxsf -o uid=$UID,gid=$(id -g) E_DRIVE /e
EOF
chmod +x /etc/rc.local
```

## Software

### yum

[How to Setup Local HTTP Yum Repository on CentOS 7](https://www.tecmint.com/setup-local-http-yum-repository-on-centos-7/)

```bash
yum remove git
yum clean all
yum install git
yum reinstall git
# search for what package
yum provides git
```

`yum install {package-name-1} {package-name-2}` install the specified packages [ RPM(s) ]
`yum install --downloadonly --downloaddir=/root/docker docker-ce-24.0.6-1.el7.x86_64` download rpm package without install
`rpm -ivh --replacefiles --replacepkgs /root/docker/*.rpm` install packages

问题：yum命令Header V3 RSA/SHA1 Signature, key ID c105b9de: NOKEY
原因：缺少公钥验证
解决办法：1. 导入缺少的公钥  或者 2. 关掉gpg检查
列出公钥 `rpm -q gpg-pubkey --qf '%{name}-%{version}-%{release} --> %{summary}\n'`
导入公钥 `rpm --import /media/CentOS_6.4_Final/RPM-GPG-KEY-CentOS-6`
关掉 GPG 检查 `echo gpgcheck=0 >> /etc/yum.conf`

`yum localinstall foo.rpm` `yum https://server1.cyberciti.biz/foo.rpm` To install a package from a local file called foo.rpm or http, or ftp mirror:
`yum downgrade {pkg}` downgrade a package to an earlier version
`yum reinstall {pkg}` reinstall a package again

`yum remove {package-name-1} {package-name-2}` remove / uninstall the specified packages [ RPM(s) ]
`yum autoremove` remove unneeded/unwanted packages/deps
`yum clean all` clean yum cache, delete all cached and downloaded package, headers and other info

`yum check-update` find out whether updates exist for packages that are already installed on my system
`yum update` Patch up system by applying all updates
`yum update --security` only apply security-related package updates
`yum update {package-name-1}` update specified packages
`yum update-to nginx-1.12.2-1.el7` update one packages to a particular version

`yum list all` List all installed packages
`rpm -qa` ## not recommend just use yum
`yum list installed`
`yum list installed httpd` Find out if httpd package installed or not on the system
`yum list available` Lists all packages that are available for installation
`yum list updates` display a list of updated software and security fix
`yum search {package-name}` search for packages by name
`yum info {pkg-1} {pkg-2}` see detailed information about a package
`yum --showduplicates list php` To find or show duplicates, in repos, in list/search commands
`yum deplist {pkg}` show dependencies list for a package

`yum grouplist` `yum groups list` Display list of group software
`yum groupinstall "Development Tools"` Install all the default packages by group
`yum groupinfo 'Development Tools'` Display description and contents of a package group

`yum provides /etc/passwd` or `yum whatprovides /etc/passwd` Display what package provides the file
`yum provides /usr/bin/ab`  discover which package contains the program `ab`

`yum check` check the local RPM database for problems
`yum repolist` list software repositories
`yum repoinfo base` get info about base repo
`yum repo-pkgs repo_name_id <list|install|remove|upgrade|reinstall> [pkg]` work with given repository

### 查询服务器的系统版本

```shell
[root@nys yum.repos.d]# rpm -qi centos-release
Name        : centos-release               Relocations: (not relocatable)
Version     : 6                                 Vendor: CentOS
Release     : 10.el6.centos.12.3            Build Date: Tue 26 Jun 2018 10:52:41 PM CST
Install Date: Mon 23 Jul 2018 11:48:26 AM CST      Build Host: x86-01.bsys.centos.org
Group       : System Environment/Base       Source RPM: centos-release-6-10.el6.centos.12.3.src.rpm
Size        : 38232                            License: GPLv2
Signature   : RSA/SHA1, Tue 26 Jun 2018 11:35:30 PM CST, Key ID 0946fca2c105b9de
Packager    : CentOS BuildSystem <http://bugs.centos.org>
Summary     : CentOS release file
Description :
CentOS release files

# Version,Release两项，当前服务器操作系统的版本就是：6.10
```

### [CentOS 切换阿里云源](https://help.aliyun.com/document_detail/193569.htm)

[CentOS 镜像](https://developer.aliyun.com/mirror/centos)

```bash
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
# CentOS 6 切换阿里云镜像源
wget -O /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-6.repo
# CentOS 7 切换阿里云镜像源
curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo

# 非阿里云ECS用户会出现 Couldn't resolve host 'mirrors.cloud.aliyuncs.com' 信息，不影响使用。用户也可自行修改相关配置: eg:
sed -i -e '/mirrors.cloud.aliyuncs.com/d' -e '/mirrors.aliyuncs.com/d' /etc/yum.repos.d/CentOS-Base.repo

# http://mirrors.aliyun.com/centos/6/os/x86_64/repodata/repomd.xml: [Errno 14] PYCURL ERROR 22 - "The requested URL returned error: 404 Not Found"
# change to http://mirrors.aliyun.com/centos http://mirrors.aliyun.com/centos-vault/centos
vi then `%s#/centos/#/centos-vault/centos/#g`
sed -i -e '#/centos/#/centos-vault/centos/' /etc/yum.repos.d/CentOS-Base.repo

yum clean all && yum check-update && yum makecache

# 把CentOS-Base.repo文件中的以下网址
# http://mirrors.aliyun.com/centos/
# http://mirrors.aliyuncs.com/centos/
# http://mirrors.cloud.aliyuncs.com/centos/
# 修改成
# http://mirrors.aliyun.com/centos-vault/centos/

# 把epel.repo文件中的
# enabled=1
# 修改成
# enabled=0

```

### git

[How to install latest version of git on CentOS 7.x/6.x](https://stackoverflow.com/questions/21820715/how-to-install-latest-version-of-git-on-centos-7-x-6-x)

``` bash
yum install -y http://opensource.wandisco.com/centos/6/git/x86_64/wandisco-git-release-6-1.noarch.rpm
- or -
yum install -y http://opensource.wandisco.com/centos/7/git/x86_64/wandisco-git-release-7-1.noarch.rpm
- or -
yum install http://opensource.wandisco.com/centos/7/git/x86_64/wandisco-git-release-7-2.noarch.rpm

yum install -y git tig

#check version
git --version
```

### zsh

```bash
echo $SHELL
yum install -y zsh
chsh -s $(which zsh)
chsh -s "$(command -v zsh)" "${USER}"
# chsh -s /bin/zsh root
# sudo vipw
logout
login
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
# plugin location: ~/.oh-my-zsh/plugins/
# ZSH_THEME='risto'
sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="alanpeabody"/' ~/.zshrc
sed -i 's/# DISABLE_AUTO_TITLE="true"/DISABLE_AUTO_TITLE="true"/' ~/.zshrc
```

### [Systemd 入门教程：命令篇](http://www.ruanyifeng.com/blog/2016/03/systemd-tutorial-commands.html)

使用了 Systemd，就不需要再用init了。Systemd 取代了initd，成为系统的第一个进程（PID 等于 1），其他进程都是它的子进程

`systemctl --version`

#### systemctl Systemd 的主命令，用于管理系统

`systemctl reboot` 重启系统
`systemctl poweroff` 关闭系统，切断电源
`systemctl list-units` 命令可以查看当前系统的所有 Unit

命令格式 `systemctl [command] [unit]`
`start/stop` 立刻启动/关闭后面接的 unit。
`restart` 立刻关闭后启动后面接的 unit，亦即执行 stop 再 start 的意思。
`reload` 不关闭 unit 的情况下，重新载入配置文件，让设置生效。
`enable/disable` 设置下次开机时，后面接的 unit 会/不会 被启动。
`status` 目前后面接的这个 unit 的状态，会列出有没有正在执行、开机时是否启动等信息。
`is-active` 目前有没有正在运行中。
`is-enable` 开机时有没有默认要启用这个 unit。
`kill`  不要被 kill 这个名字吓着了，它其实是向运行 unit 的进程发送信号。
`show` 列出 unit 的配置。
`mask/unmask` 注销/取消注销 unit，注销后你就无法启动这个 unit 了。

`systemctl list-dependencies nginx.service` 列出一个 Unit 的所有依赖
`systemctl list-dependencies --all nginx.service` 上面命令的输出结果之中，有些依赖是 Target（就是 Unit 组） 类型，默认不会展开显示。如果要展开 Target，就需要使用`--all`参数

#### systemd-analyze 查看系统启动

#### hostnamectl 查看当前主机信息

`hostnamectl` 显示当前主机的信息
`hostnamectl set-hostname rhel7` 设置主机名

#### localectl 查看本地化设置

```bash
# 查看本地化设置
$ localectl

# 设置本地化参数。
$ sudo localectl set-locale LANG=en_GB.utf8
$ sudo localectl set-keymap en_GB
```

#### timedatectl 查看时区设置

```bash
# 查看当前时区设置
$ timedatectl

# 显示所有可用的时区
$ timedatectl list-timezones

# 设置当前时区
$ sudo timedatectl set-timezone America/New_York
$ sudo timedatectl set-time YYYY-MM-DD
$ sudo timedatectl set-time HH:MM:SS
```

#### loginctl 查看登录用户

```bash
# 列出当前session
$ loginctl list-sessions

# 列出当前登录用户
$ loginctl list-users

# 列出显示指定用户的信息
$ loginctl show-user ruanyf
```

#### Unit 的配置文件

`Systemd` 默认从目录`/etc/systemd/system/`读取配置文件
配置文件的后缀名，就是该 Unit 的种类，比如sshd.socket。如果省略，Systemd 默认后缀名为.service，所以sshd会被理解成sshd.service

`systemctl list-unit-files` 列出所有配置文件, 一共有四种

* enabled：已建立启动链接
* disabled：没建立启动链接
* static：该配置文件没有[Install]部分（无法执行），只能作为其他配置文件的依赖
* masked：该配置文件被禁止建立启动链接

`systemctl daemon-reload` 修改配置文件要让 SystemD 重新加载配置文件
`systemctl restart httpd.service`

#### journalctl 日志管理

日志的配置文件是`/etc/systemd/journald.conf`
`journalctl` 查看所有日志（内核日志和应用日志）
`journalctl -n 20` 显示尾部指定行数的日志
`journalctl -f` 实时滚动显示最新日志
`journalctl --since "2015-01-10" --until "2015-01-11 03:00"` 查看指定时间的日志

`journalctl -b` 查看系统本次启动的日志
`journalctl -b -1` 查看上一次启动的日志（需更改设置）

## CentOS Stream 8

[CentOS Stream 8 : Server World](https://www.server-world.info/en/note?os=CentOS_Stream_8&p=ssh&f=6)

### Package Management with dnf Package Manager

`DNF` is simply the next generation package manager (after `YUM`) for RPM based Linux distributions such as CentOS, RHEL, Fedora etc.

`dnf makecache` Updating Package Repository Cache
`dnf repolist --all` Listing Enabled and Disabled Package Repositories
`dnf repolist --enabled`  list only the enabled repositories
`dnf list --all` Listing All Available Packages
`dnf list --installed` Listing All Installed Packages
`dnf search "Programming Language"` Searching for Packages
`dnf repoquery *kvm*` Searching for Packages in Specific Repositories, search for packages by their package name, all the packages that has kvm in the package name is listed.
`dnf repoquery *centos* --repo extras` Searching for Packages in Specific Repositories, use `–repo` option to define which package repository to search
`dnf repoquery *centos* --repo BaseOS`

`dnf provides */ifconfig` Searching for Packages that Provides Specific File
`dnf provides */bin/tree` find the package name that provides the tree command
`dnf provides */libssl.so*`

`dnf info tree` Learning More about Packages

`dnf install httpd` Installing Packages
`dnf --enablerepo=powertools install graphviz-gd` enable repository powertools to install package
`dnf reinstall httpd` Reinstalling Packages
`dnf remove httpd` Removing Packages

#### Doing a System Upgrade

`dnf check-update`  check for whether software updates are available
`dnf upgrade-minimal` do a minimal software update. Minimal software update will only install absolutely required security patches.

`dnf upgrade` full system update

`dnf clean all` clean DNF package caches
`dnf autoremove` Remove Unnecessary Packages
