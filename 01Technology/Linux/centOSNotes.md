# CentOS

## SELinux

### Disable SELinux Temporarily until the next reboot

enable status: `sestatus | grep Current` return `Current mode:enforcing`

Disable Temporarily `setenforce Permissive`
Check: `sestatus | grep Current` return `Current mode:permissive`

Enable: `setenforce enforcing`

### Disable SELinux Permanently

`sed -i 's/SELinux=enforcing/SELinux=disabled/' /etc/sysconfig/selinux` then reboot system and then check the status with `sestatus`

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

1、关闭防火墙 firewalld
`systemctl stop firewalld` #停止firewall
`systemctl disable firewalld` #禁止firewall开机启动
`systemctl mask firewalld` `mask`是注销服务的意思。 注销服务意味着：. 该服务在系统重启的时候不会启动. 该服务无法进行做systemctl start/stop操作

2、设置 iptables service `yum -y install iptables-services`
如果要修改防火墙配置，如增加防火墙端口3306 `vi /etc/sysconfig/iptables`
增加规则 `-A INPUT -m state --state NEW -m tcp -p tcp --dport 3306 -j ACCEPT`

保存退出后
`systemctl restart iptables` #重启防火墙使配置生效
`systemctl enable iptables` #设置防火墙开机启动

最后重启系统使设置生效即可。
`systemctl start iptables` #打开防火墙
`systemctl stop iptables` #关闭防火墙

Other command `systemctl disable iptables`

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

## Software

### yum

```bash
yum remove git
yum clean all
yum install git
yum reinstall git
# search for what package
yum provides git
```

`yum install {package-name-1} {package-name-2}` install the specified packages [ RPM(s) ]
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

### [阿里云CentOS 6 EOL如何切换源](https://help.aliyun.com/document_detail/193569.htm)

[CentOS 镜像](https://developer.aliyun.com/mirror/centos)

```bash
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
wget -O /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-6.repo

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
`dnf reinstall httpd` Reinstalling Packages
`dnf remove httpd` Removing Packages

#### Doing a System Upgrade

`dnf check-update`  check for whether software updates are available
`dnf upgrade-minimal` do a minimal software update. Minimal software update will only install absolutely required security patches.

`dnf upgrade` full system update

`dnf clean all` clean DNF package caches
`dnf autoremove` Remove Unnecessary Packages
