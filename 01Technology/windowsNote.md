# windows note

Win+V 打开云剪贴板
Win+Shift+S 随时随地截图,支持矩形、任意形状、窗口截图
Windows 睡眠快捷键 Win+X U S 或者设置电源选项关盖即休眠

## process manage

```bat
REM REM 是 "Remark" 的缩写，用于添加注释。
REM 查找端口占用
netstat -ano | findstr :8080

REM 查找进程号
tasklist | findstr 4476

REM 杀掉进程
taskkill /f /pid 1234
```

## 执行策略

[关于执行策略 - PowerShell | Microsoft Learn](https://learn.microsoft.com/zh-cn/powershell/module/microsoft.powershell.core/about/about_execution_policies?view=powershell-7.4)

```bat
Get-ExecutionPolicy
Set-ExecutionPolicy -ExecutionPolicy Bypass
```

## tool

Ditto - 剪贴板管理工具 Ctrl+`
Windows Terminal
    Comment out Copy/Paste shortcut in setings.json, which are conflict with vim block selection
PowerToy
    将窗口最大化至全屏	Control+Command+F	WindowsKey+Up
    保存屏幕（截图）	Command+Shift+3	WindowsKey+Shift+S

MobaXterm
XShell Esc+. (escape+dot) == Alt+.
[QuickLook](https://github.com/QL-Win/QuickLook/releases)
[EverythingToolbar](https://github.com/srwi/EverythingToolbar/releases)
[pot-desktop: 一个跨平台的划词翻译和OCR软件 | A cross-platform software for text translation and recognition.](https://github.com/pot-app/pot-desktop)

[5 Windows Alternatives to Mac's Alfred App](https://www.makeuseof.com/free-windows-alternatives-to-macs-alfred-app/)
[6 Best Alfred App Alternatives for Windows to Be More Productive - TechWiser](https://techwiser.com/alfred-alternatives-windows/)
[个人在 Windows 上常用软件清单 · Dejavu's Blog](https://blog.dejavu.moe/posts/windows-apps/)
[DevToys - A Swiss Army knife for developers](https://devtoys.app/)

git config --list --show-origin
git config path C:\Program Files\Git\etc\gitconfig

### VSCode

`Shift+Delete` Delete line
`Ctrl+Enter` new line after current line

### Virtualbox

#### share foler with host

virtualbox windows 宿主机 CentOS 7 虚拟机 共享文件

[VirtualBox虚拟机设置共享文件夹（CentOS） - Excel2016 - 博客园](https://www.cnblogs.com/skyvip/p/18151918)

```sh
# yum install -y perl gcc dkms kernel-devel kernel-headers make bzip2
# yum -y install bzip2 xorg-x11-drivers xorg-x11-utils

# 挂载virtualbox 的光盘 VBoxGuestAdditions.iso
mkdir /mnt/cd
sudo mount /dev/cdrom /mnt/cd
cd /mnt/cd
sudo sh VBoxLinuxAdditions.run

sudo yum install -y kernel-devel gcc
sudo yum -y upgrade kernel kernel-devel

uname -r                 #查看内核版本
sudo yum install -y kernel-devel-3.10.0-1160.71.1.el7.x86_64   #安装内核头文件
/sbin/rcvboxadd setup    #运行 VirtualBox Guest Additions 的设置脚本

# 安装成功会提示 restart system，如果没有查看 /var/log/vboxadd-setup.log 的错误提示
# 如果/var/log/vboxadd-setup.log里面的错误提示为：

# Could not find the X.Org or XFree86 Window System, skipping.
sudo yum install -y xorg-x11-server-Xorg

# libXrandr.so.2: cannot open shared object file: No such file or directory
sudo yum install -y libXrandr.x86_64

# 添加共享文件夹
# 在VirtualBox中打开“设置”，选择“共享文件夹”，点击添加。
# Folder Path 是宿主机路径，Folder Name 是挂载时使用的名字 比如使用 D_DRIVE
sudo mkdir /d
sudo chown user:user /d
sudo mount -t vboxsf -o uid=$UID,gid=$(id -g) D_DRIVE /d
sudo mkdir /e
sudo chown user:user /e
sudo mount -t vboxsf -o uid=$UID,gid=$(id -g) E_DRIVE /e

# 设置自动挂载
#  -a 追加文件
sudo tee -a /etc/rc.local <<EOF
mount -t vboxsf -o uid=$UID,gid=$(id -g) D_DRIVE /d
mount -t vboxsf -o uid=$UID,gid=$(id -g) E_DRIVE /e
EOF
chmod +x /etc/rc.local
```

#### config NAT and host network

[networking - How to connect to a VirtualBox guest OS through a VPN? - Super User](https://superuser.com/questions/987150/how-to-connect-to-a-virtualbox-guest-os-through-a-vpn)

1. The first adapter must be set to NAT mode, which enables the guest to access network resources (including the Internet) through the host's network interface.
2. The second adapter must be set to Host-only, which enables bidirectional communication between the host and the guest.

[virtualbox centos7 nat+host-only方式联网踩坑总结-阿里云开发者社区](https://developer.aliyun.com/article/1150470)

1. 设置Nat网络
   1. 在 VirtualBox 主控制界面点击 Files > Tools > Network Manager
   2. 【添加新NAT网络】 在弹出的对话框中，设置【网络CIDR】为【192.168.100.0/24】，【确定】
   3. 在需要设置的虚拟机页面【设置】–【网络】–【网卡1】，【连接方式】选择【NAT网络】，【界面名称】选【NATNetwork】，【确定】
   4. 启动系统后 `vi /etc/sysconfig/network-scripts/ifcfg-enp0s3`
   5. 将【ONBOOT】改为【yes】 配置其他网络设置
   6. 重启网络服务 `systemctl restart network`
   7. 此时可以正常访问公网 `curl www.baidu.com`，但还不能通过 SSH 连接虚拟机
2. 设置Host-only网络
   1. 在安装完 VirtualBox后，在宿主机的【网络和共享中心】–【更改适配器设置】中可以看到【VirtualBox Host-Only Network】：右键【属性】–【Internet协议版本4（TCP/IPv4）】中可以看到 IP 地址是【192.168.56.1】
   2. 在 VirtualBox 主控制界面点击 Files > Tools > Network Manager
   3. Host-only Networks > Create > IPv4 Address 192.168.56.1 > IPv4 Network Mask:255.255.255.0 > DHCP Server > Server Address ：192.168.56.100 > Server Mask:255.255.255.0 > Lower Address Bound ：192.168.56.101 > Upper Address Bound ：192.168.56.254
   4. 在需要设置的虚拟机页面【设置】–【网络】–【网卡2】–【启用网络连接】，【连接方式】选【仅主机（Host-Only）网络】
   5. (可选，网卡自动配置好了，通过 `ip a` 查看，出现 Host only IP 192.168.56.x 即已经自动配置)开机后 执行命令 `cp ifcfg-enp0s3  ifcfg-enp0s8` 复制一份网卡配置
   6. (可选)vi ifcfg-enp0s8，内容如下文
   7. (可选)重启网络服务 `systemctl restart network`
   8. 此时可以 SSH 192.168.56.x 连接虚拟机

```sh
# ifcfg-enp0s3
TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=dhcp
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
IPV6_ADDR_GEN_MODE=stable-privacy
NAME=enp0s3
UUID=3b8d1c63-5d2e-43d2-9508-6c1ecec961346
DEVICE=enp0s3
ONBOOT=yes
HWADDR=08:00:27:AF:90:BF
```

```sh
# ifcfg-enp0s8
TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=static
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
IPV6_ADDR_GEN_MODE=stable-privacy
NAME=enp0s8
UUID=3b8d1c63-5d2e-43d2-9508-6c1ecec96146
DEVICE=enp0s8
ONBOOT=yes
IPADDR=192.168.56.42
NETMASK=255.255.255.0
```

CentOS 网卡文件 /etc/sysconfig/network-scripts/ifcfg-enp0s3

### Git bash

设置环境变量，更改 home 目录
HOME=D:\home

```sh
# get ln working correctly with a single line in a .bashrc file
export MSYS=winsymlinks:nativestrict
```

[Installing Zsh (and oh-my-zsh) in Windows Git Bash | Dominik Rys](https://dominikrys.com/posts/zsh-in-git-bash-on-windows/)

### MobaXterm

D:\Programs\MobaXterm_Portable_v24.1\MobaXterm_Personal_24.1.exe

```sh
Persistent home directory: _AppDataDir_\MobaXterm\home
%USERPROFILE%\AppData\MobaXterm\home
%USERPROFILE%\AppData\Roaming\MobaXterm\home
# _CurrentDrive_:\home
Persistent root （/） directory: _AppDataDir_\MobaXterm\slash
```

/home/mobaxterm/.oh-my-zsh/lib/async_prompt.zsh:5: failed to load module: zsh/system
/home/mobaxterm/.shell.base:159: defining function based on alias `cls'
/home/mobaxterm/.shell.base:159: parse error near `()'

#### MobaXterm 上传下载文件的几种情况

1. 通过 堡垒机 Web 页面 SSO 调用 MobaXterm 登录目标服务器，可以自动打开 sftp browser 来上传下载文件。
2. 通过 MobaXterm 先连接堡垒机，再跳到目标服务器，此时不会打开 sftp browser，是因为 MobaXterm 本身不知道后一次跳转。此时上传下载可以使用 rz、sz。
3. 通过 MobaXterm 直接登录目标服务器，配置方式：SSH > Network Settings > SSH gateway (jump host) 配置堡垒机信息 > Basic SSH settings 设置目标服务器信息。登录后，可以自动打开 sftp browser 来上传下载文件。

参考 [MobaXterm file browser not following terminal after multiple SSH hops - Super User](https://superuser.com/questions/1804247/mobaxterm-file-browser-not-following-terminal-after-multiple-ssh-hops)

#### MobaXterm 使用 rz sz

服务器安装 lrzsz

yum -y install lrzsz

下载

1. sz filename
2. 鼠标右键
3. Receive file using Z-modem

上传

1. rz
2. 鼠标右键
3. Send file using Z-modem
4. 选择上传文件

## network

### tracert

tracert 命令格式如下

tracert [-d] [-h maximum_hops] [-j computer-list] [-w timeout] target_name

如果不带选项的话，会将IP地址解析成主机名，因为需要查询DNS，所以速度比较慢。

* -d 选项：不将IP地址解析成主机名，因此路由追踪速度快很多。
* -h 选项：说明路由的最大跳数，默认是30跳。
* -w 选项：说明等待每一个ICMP响应报文的时间，默认4s，如果接收超时，则显示星号*。跳数和等待时间，使用默认值即可，所以平时一般都不需要添加这两个选项。
* -j 选项：说明ICMP报文要使用IP头中的松散源路由选项，后面是经过的中间节点的地址或主机名字,最多9个，各个中间节点用空格隔开。

这里说明下松散源路由和严格源路由，严格源路由是指，相邻路由器之间不得有中间路由器，并且所经过路由器的顺序不可更改。而松散源路由，则相反，相邻路由器之间可以有中间路由器。一般的路由追踪，也用不到-j这个选项。除非是针对大的网络故障，需要检测几条路径到达同一个目的地址，才需要使用-j选项。所以，通常情况下，我们使用tracert–d这种格式就可以了。我们以追踪百度网站为例。

```batch
tracert -d www.baidu.com
```

### Pathping

Pathping 命令的格式如下：pathping [-g host-list] [-hmaximum_hops] [-n] [-p period] [-q num_queries] [-w timeout] target_name

-g选项：使用松散源路由，功能与tracert 命令的-j选项相同。
-h选项：追踪的最大跳数，功能与tracert 命令的-h选项相同。
-n选项：不将IP地址解析成主机名，功能与tracert 命令的-d选项相同。
-q选项：发送给每个路由器的请求报文的数量，默认100个。
-p选项：两次ping之间的时间间隔，默认0.25秒。
-w选项：每次等待回声响应的时间，默认3秒。功能与tracert 命令的-w选项相同。
因此，在通常情况下，我们使用pathping -n格式就行了，路由追踪速度更快。下面，还是以百度为例：Pathping运行的第一个结果就是路由表，这个和tracert的结果是一致的。

```batch
PATHPING -n www.baidu.com
```

## WSL

https://wslstorestorage.blob.core.windows.net/wslblob/Ubuntu2404-240425.AppxBundle
Add-AppxPackage .\Ubuntu2404-240425.AppxBundle

```sh
wsl --status //检查 WSL 状态
wsl //进入默认的发行版本，退出执行 exit
wsl -l -v //列出已安装的 Linux 发行版
wsl --list --online
wsl --install -d Ubuntu-24.04
wsl --set-default Ubuntu-24.04
wsl --terminate //终止指定的发行版或阻止其运行
例：wsl --terminate Ubuntu-18.04
wsl --shutdown //重启wsl服务
wsl --set-default //设置默认 Linux 发行版
wsl --set-version //将WSL版本设置为1或2
wsl --set-default-version //设置默认 WSL 版本
wsl --distribution --user //运行特定的Linux发行版
wsl -u , wsl --user //以特定用户的身份运行
wsl config --default-user //更改发行版的默认用户
wsl --unregister //注销或卸载 Linux 发行版
```

### Windows 子系统实例已终止

重启wsl
管理员模式打开终端，输入

```sh
#停止LxssManager服务
# net stop LxssManager

#启动LxssManager服务
# net start LxssManager

# 或者杀掉 LxssManager
tasklist /svc /fi "services eq LxssManager"
# 结束指定PID进程
wmic process where processid=21200 delete

taskkill /pid 1234
taskkill /f /pid 1234 /PID 1241
```

### WSL install Ubuntu

[My Windows Subsystem for Linux setup - Matthew Somerville](https://dracos.co.uk/wrote/wsl/)

[Working across file systems | Microsoft Learn](https://learn.microsoft.com/en-us/windows/wsl/filesystems)

OS default location：
Ubuntu-20.04 /mnt/c/Users/user/AppData/Local/Packages/CanonicalGroupLimited.UbuntuonWindows_79rhkp1fndgsc/
Ubuntu-24.04 /mnt/c/Users/user/AppData/Local/Packages/CanonicalGroupLimited.Ubuntu24.04LTS_79rhkp1fndgsc
LocalState E:\WSL\Ubuntu2004

path：\\wsl$\Ubuntu\home\pu\.zshrc
explorer.exe .

```sh
$ sudo apt -y install zsh

# 将 zsh 设置为默认 Shell
$ chsh -s /bin/zsh

# 安装 Oh My Zsh
$ sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# 网络不佳时
$ sh -c "$(curl -fsSL https://raw.fastgit.org/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# 安装 zsh-autosuggestions 插件
# ref: https://github.com/zsh-users/zsh-autosuggestions/blob/master/INSTALL.md#oh-my-zsh
$ git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

sudo apt install -y tig ncdu bat autojump jq zsh

cp ~/Downloads/.oh-my-zsh.tgz ~/.oh-my-zsh.tgz
cp ~/Downloads/.zshrc ~/.zshrc

# 查看tcp端口
ss -tap

git clone https://petergite@gitee.com/petergite/configuration.git
url = git@gitee.com:petergite/configuration.git

git init .
git remote add origin https://petergite@gitee.com/petergite/configuration.git
git pull origin work
```

### wsl config

[Rename tab title not working for WSL and Bash · Issue #5333 · microsoft/terminal · GitHub](https://github.com/microsoft/terminal/issues/5333)

`"suppressApplicationTitle": true,`

### System config

[networking - Make /etc/resolv.conf changes permanent in WSL 2 - Ask Ubuntu](https://askubuntu.com/questions/1347712/make-etc-resolv-conf-changes-permanent-in-wsl-2)
sudo sed -i 's/nameserver 172.20.128.1/nameserver 114.114.114.114/g' /etc/resolv.conf
sudo sed -i 's/nameserver 114.114.114.114/nameserver 172.20.128.1/g' /etc/resolv.conf

sudo rm /etc/resolv.conf
sudo bash -c 'echo "nameserver 172.20.128.1" > /etc/resolv.conf'
sudo bash -c 'echo "nameserver 114.114.114.114" >> /etc/resolv.conf'
sudo bash -c 'echo "[network]" > /etc/wsl.conf'
sudo bash -c 'echo "generateResolvConf = false" >> /etc/wsl.conf'
sudo chattr +i /etc/resolv.conf

### Move to other drive from C drive

[Move WSL to another drive. WSL (Windows Subsystem for Linux) is a… | by Hafiz Azhar | Medium](https://medium.com/@rahmanazhar/move-wsl-to-another-drive-ab8002152cf2)

```sh
# wsl.exe --export <DistroName> <Tar-FileName>
# wsl --export Ubuntu-22.04 D:\WSL\Ubuntu-22.04\Ubuntu-22.04.tar
wsl --export Ubuntu E:\WSL\Ubuntu-20.04\Ubuntu-20.04.tar
wsl --unregister Ubuntu
# wsl.exe --import <DistroName> <Folder-To-Install> <Tar-FileName>
wsl --import Ubuntu E:\WSL\Ubuntu2004\ E:\WSL\Ubuntu-20.04\Ubuntu-20.04.tar

# Ubuntu 24.04
wsl --export Ubuntu-24.04 E:\WSL\Ubuntu-24.04-export\Ubuntu-24.04.tar
wsl --unregister Ubuntu-24.04
# wsl.exe --import <DistroName> <Folder-To-Install> <Tar-FileName>
wsl --import Ubuntu-24.04 E:\WSL\Ubuntu2404\ E:\WSL\Ubuntu-24.04-export\Ubuntu-24.04.tar
```

[linux - How to set default user for manually installed WSL distro? - Super User](https://superuser.com/questions/1566022/how-to-set-default-user-for-manually-installed-wsl-distro/1627461#1627461)

The username can be selected when starting any WSL instance by:
`wsl -d distroname -u username`

or config in wsl.conf

```sh
echo "[user]" >> /etc/wsl.conf
echo "default=pu" >> /etc/wsl.conf
# turn off
wsl --terminate Ubuntu-24.04
```

### MySQL

[How to install MySQL on WSL 2 (Ubuntu) · Pen-y-Fan](https://pen-y-fan.github.io/2021/08/08/How-to-install-MySQL-on-WSL-2-Ubuntu/)
log /var/log/mysql/error.log
Windows client: HeidiSQL

```sh
sudo apt install mysql-server
# First start the MySQL server
sudo /etc/init.d/mysql start
# run the security script
sudo mysql_secure_installation
# Failed! Error: SET PASSWORD has no significance for user 'root'@'localhost' as the authentication method used doesn't store authentication data in the MySQL server
# kill the process mysql_secure_installation
# then sudo mysql
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password by 'root';
ALTER USER 'root'@'localhost' IDENTIFIED by 'root';
CREATE USER 'sp'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password';

# Allow remote access
# [ubuntu - How to connect to WSL mysql from Host Windows - Stack Overflow](https://stackoverflow.com/questions/54377052/how-to-connect-to-wsl-mysql-from-host-windows)
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root';

# Manually start MySQL
sudo service mysql start

# To fix the error with /nonexistent directory
sudo service mysql stop
sudo usermod -d /var/lib/mysql/ mysql
sudo service mysql start

```

For mysql 8.0 the command to disable password validation component is:

UNINSTALL COMPONENT 'file://component_validate_password';

```sh
# /etc/mysql/conf.d/enable-mysql-native-password.cnf
# # Enable mysql_native_password plugin
[mysqld]
mysql_native_password=ON
```

CREATE USER 'sp1'@'%' IDENTIFIED WITH mysql_native_password BY 'password';
GRANT ALL PRIVILEGES on *.* to sp@'%';

```sql
-- ERROR 1396 (HY000): Operation ALTER USER failed for
UPDATE mysql.user SET host='%' WHERE user='root' AND host='localhost';
FLUSH PRIVILEGES;
ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY 'root';
```

select user,host from user;

### Redis

[Install Redis on Windows | Docs](https://redis.io/docs/latest/operate/oss_and_stack/install/install-redis/install-redis-on-windows/)

The latest version is 7.2.5

```sh
curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list

sudo apt-get update
sudo apt-get install redis
# start the Redis server
sudo service redis-server start
```

unsupported locale setting

get current locale with `locale`
all available locale with `locale -a`

sudo apt-get install language-pack-id
sudo dpkg-reconfigure locales

### Node

[Set up Node.js on native Windows | Microsoft Learn](https://learn.microsoft.com/en-us/windows/dev-environment/javascript/nodejs-on-windows)

start node as a non-root user

package.json

specify port number in run command `npm run dev -- -p 3005`

vi vite.config.ts

```sh
# error when starting dev server: Error: listen EACCES: permission denied 0.0.0.0:80
sudo apt-get install libcap2-bin
sudo setcap cap_net_bind_service=+ep `readlink -f \`which node\``
```

### Network

```sh
# In Windows, forward your port from the public IP port to the WSL port in powershell as admin using:

netsh interface portproxy add v4tov4 listenport=$EXT_PORT listenaddress=0.0.0.0 connectport=$WSL_PORT connectaddress=127.0.0.1
netsh interface portproxy add v4tov4 listenport=3006 listenaddress=0.0.0.0 connectport=3006 connectaddress=127.0.0.1
netsh interface portproxy delete v4tov4 listenport=3006 listenaddress=0.0.0.0
netsh interface portproxy add v4tov4 listenport=48080 listenaddress=0.0.0.0 connectport=48080 connectaddress=127.0.0.1
netsh interface portproxy delete v4tov4 listenport=48080 listenaddress=0.0.0.0

http://10.10.67.90:3006

# To forward SSH access to WSL, $EXT_PORT=2222, $WSL_PORT=22 After above set up, from another computer in same LAN or VPN, do
ssh user@wslhostip -p 2222
```
