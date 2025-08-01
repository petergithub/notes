# windows note

Win+V 打开云剪贴板
Win+Shift+S 随时随地截图,支持矩形、任意形状、窗口截图
Windows 睡眠快捷键 Win+X U S 或者设置电源选项关盖即休眠

查看电脑系统属性：dxdiag 命令

软件安装目录 C:\Users\%username%\AppData\Local\

hosts 文件路径 C:\Windows\System32\drivers\etc\hosts

## process manage taskkill

```bat
REM REM 是 "Remark" 的缩写，用于添加注释。
REM 查找端口占用
netstat -ano | findstr :8080

REM 查找进程号
tasklist | findstr 4476

REM 杀掉进程
taskkill /f /pid 1234

# taskkill /pid 13588
# ERROR: Invalid argument/option - 'C:/Program Files/Git/pid'.
# Type "TASKKILL /?" for usage.
# use double slashes in this case:
taskkill //PID 13588
```

## cmd

```bat
@REM open current folder in Explorer
start .

start cmd /k

@REM 启动 WPS 文档
start /B "C:\Programs\WPSOffice\WPS Office\12.2.0.19805\office6\wps.exe" "D:\文档.docx"

@REM startup vscode with workspace
start /B code "D:\Dropbox\work\vscode.document.code-workspace"

@REM keep the cmd console opening
start "" d:\myscripts\pinger.bat
@REM auto close the cmd console
start "" cmd /c d:\myscripts\pinger.bat

@REM 访问网址
explorer http://www.baidu.com

@REM 打开文件夹或文件
start D:\文件夹1
@REM 打开文件
start D:\文件夹1\test.txt

@REM 删除文件
@REM 删除当前目录下的test.txt文件
del test.txt
@REM 删除上级目录下的test.txt文件
del ..\test.txt
@REM 删除当前目录TEST文件夹下的所有.o文件
del .\TEST\*.o

@REM 复制文件
@REM 复制当前目录下所有txt文件到文件夹1，文件夹1需要已经创建
copy *.txt 文件夹1

@REM 复制文件1到文件夹1、文件2到文件夹2、支持多个文件操作，同时支持上级及下级文件路径
copy file1.txt 文件夹1
copy file2.txt 文件夹2

@REM 复制桌面文件到D盘根目录，使用绝对路径
copy C:\Users\user\Desktop\welcome.txt D:\

@REM 重命名
@REM 修改文件扩展名，所有txt扩展名改为mp3扩展名
ren *.txt *.mp3
ren  *.gif *.jpg
@REM 修改文件名称，把aa.txt改为bb.c
ren aa.txt bb.c

创建文件夹
@REM 创建三个文件夹1
md 文件夹1
md 文件夹2
md 文件夹3
@REM 创建文件
@REM 当前目录创建a.txt文件
cd.>a.txt

@REM 把hex文件的第一行之后的内容写入新文件
more +1 "..\OBJ\output.hex" > "..\OBJ\flash_after_del_hex_line1.hex"

@REM 提取文件名
@REM 提取当前目录下扩展名为mp3的文件名，输出到mp3文件名.txt
dir *.mp3 /b > mp3文件名.txt

@REM 提取当前目录下所有文件的文件名到a.txt
dir c:\*.* > a.txt

@REM 输出文件的绝对路径信息
@REM 输出当前目录下mp3文件
dir *.mp3 /b /s > MP3文件信息.txt

@REM 执行另一个批处理文件
call c:\code\run.bat

@REM 自动关机
@REM 300s 后自动关机
shutdown -s -t 300
@REM 取消自动关机
shutdown -a
@REM 立刻重启
shutdown -r -t 0
@REM 自动休眠 60s后休眠
shutdown -h -t 60

@REM 隐藏文件夹
attrib +s +h D:\Secret
@REM 取消隐藏文件夹
attrib -s -h D:\Secret

@REM attrib命令
attrib +/-r
attrib +/-a
attrib +/-s
attrib +/-h
@REM + 设置属性
@REM - 清除属性
@REM r 只读属性
@REM a 存档属性
@REM s 系统属性
@REM h 隐藏属性

@REM 更新DNS缓存
ipconfig /flushdns

@REM Windows Displays the contents of a text file or files.
type fileName
```

## PowerShell

在 PowerShell 中，Write-Host 和 Write-Output 都可以用来输出内容到控制台，但 Write-Host 通常用于输出信息给用户，而 Write-Output 则用于输出数据流。

some basic cmdlets and its CMD equivalents

| Task                       | CMD Command | PowerShell Cmdlet       |
|----------------------------|-------------|-------------------------|
| List directory contents    | dir         | Get-ChildItem           |
| Copy a file                | copy        | Copy-Item               |
| Move a file                | move        | Move-Item               |
| Delete a file              | del         | Remove-Item             |
| View network configuration | ipconfig    | Get-NetIPConfiguration  |
| Change current directory   | cd          | Set-Location            |
| Ping a server              | ping        | Test-Connection         |

```ps1
# get alias
Get-Alias
Get-Alias -Name list
# [Set-Alias - PowerShell | Microsoft Learn](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/set-alias?view=powershell-7.5)
Set-Alias -Name list -Value Get-ChildItem
Set-Alias -Name o -Value ollama

# $profile = %userprofile%\OneDrive\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
echo "Set-Alias -Name o -Value ollama" >> $profile
# refresh the current session profile
. $profile

# 展示文件内容
Get-Content .wslconfig
# alias cat = Get-Content
cat .wslconfig

# 调用和执行打开文件
Invoke-Item "C:\Programs\WPSOffice\WPS Office\ksolaunch.exe"
```

### PowerShell 环境变量

查看

```ps1
# 查看当前用户的PATH环境变量
$env:PATH
# 查看所有环境变量
Get-ChildItem Env:
# 获取特定的环境变量
Get-ChildItem env:PATH
Get-ChildItem -Path env:PATH

# 使用 Get-Content 读取环境变量
Get-Content env:PATH

# 使用 Write-Output 显示环境变量
Write-Output $env:PATH
# 使用 Write-Host 显示 PATH 环境变量
Write-Host $env:PATH
```

设置

```ps1
# 设置或修改环境变量
# 在当前会话中有效，一旦会话结束，变量就会被清除。
$env:MY_VARIABLE = "some_value"

# 设置环境变量（全局）
# 在用户级别设置环境变量，只需将 Machine 替换为 User 即可。
[Environment]::SetEnvironmentVariable("MY_VARIABLE", "some_value", [EnvironmentVariableTarget]::Machine)

# 获取环境变量的类型
# 环境变量可以存储为不同的类型，如字符串、数字等。要获取环境变量的类型，可以使用 GetType() 方法：
$env:PATH | ForEach-Object { $_.GetType() }
```

使用环境变量

假设您想使用 PATH 环境变量来查找特定文件的路径，可以这样做：

```ps1
# 这段脚本会在 PATH 环境变量指定的所有目录中查找 notepad.exe 文件，并输出其完整路径。

$file = "notepad.exe"
$path = $env:PATH -split ';'
foreach ($p in $path) {
    $fullPath = Join-Path -Path $p -ChildPath $file
    if (Test-Path -Path $fullPath) {
        Write-Host "Found $file at $fullPath"
        break
    }
}
```

### Invoke-WebRequest 类似 curl

在 PowerShell 中，您可以使用 `Invoke-WebRequest` 命令来执行类似于 Unix/Linux 中 `curl` 命令的操作。`Invoke-WebRequest` 是 PowerShell 中用于向 web 服务器发送 HTTP 请求的命令。

```ps1
# 获取帮助文档
Get-Help Invoke-WebRequest -Full
```

以下是一些使用 `Invoke-WebRequest` 的基本语法示例：

#### 发送 GET 请求

```ps1
# 发送 GET 请求并获取响应内容
Invoke-WebRequest -Uri "http://example.com/api/data"
```

#### 获取网页内容

```ps1
# 获取网页内容并将其存储在变量中
$content = Invoke-WebRequest -Uri "http://example.com"

# 显示获取的网页内容
$content.Content
```

#### 发送 POST 请求

```ps1
# 发送 POST 请求
Invoke-WebRequest -Uri "http://example.com/api/post" -Method POST -Body $body -ContentType "application/json"
```

其中 `$body` 是一个包含 POST 数据的对象，例如：

```ps1
$body = @{
    param1 = "value1"
    param2 = "value2"
} | ConvertTo-Json
```

#### 发送带有表单数据的 POST 请求

```ps1
# 创建表单数据哈希表
$form = @{
    "username" = "user1"
    "password" = "pass123"
}

# 发送带有表单数据的 POST 请求
Invoke-WebRequest -Uri "http://example.com/login" -Method POST -Form $form
```

#### 发送带有身份验证的请求

```ps1
# 创建基本身份验证的凭据
$cred = Get-Credential

# 发送带有身份验证的请求
Invoke-WebRequest -Uri "http://example.com/secure" -Credential $cred
```

#### 发送带有超时设置的请求

```ps1
# 发送带有超时设置的请求
Invoke-WebRequest -Uri "http://example.com" -TimeoutSec 20
```

#### 下载文件

```ps1
# 下载文件并保存到指定路径
Invoke-WebRequest -Uri "http://example.com/file.zip" -OutFile "C:\Downloads\file.zip"
```

#### 使用代理服务器

```ps1
# 设置代理服务器
[System.Net.WebRequest]::DefaultWebProxy = New-Object System.Net.WebProxy("http://myproxyserver:8080")

# 发送请求
Invoke-WebRequest -Uri "http://example.com"
```

请注意，`Invoke-WebRequest` 命令在 PowerShell 3.0 及更高版本中可用。如果您使用的是 PowerShell 2.0 或更早版本，则需要使用 `New-Object System.Net.WebClient` 或其他方法来发送 HTTP 请求。

这些示例展示了如何使用 PowerShell 的 `Invoke-WebRequest` 命令来执行常见的 HTTP 请求操作。您可以根据需要调整这些示例以适应您的特定场景。


## 执行策略

[关于执行策略 - PowerShell | Microsoft Learn](https://learn.microsoft.com/zh-cn/powershell/module/microsoft.powershell.core/about/about_execution_policies?view=powershell-7.4)

```bat
Get-ExecutionPolicy
Set-ExecutionPolicy -ExecutionPolicy Bypass
```

## 系统设置

### 创建本地用户

方法1：通过网络邻居创建账号：win+R，打开运行，输入 netplwiz，添加账号
方法2：管理 win+I > 账号 > 其他用户 > 添加帐户

### 共享文件夹

查看已经共享的文件夹：win+X > 计算机管理 > 系统工具 > 共享文件夹 > 共享

设置文件夹共享：文件夹属性 > 共享 > 共享此文件夹 > 权限 > 添加 用户名

可能需要做的：文件夹属性 > 安全 > 编辑 > 添加 用户名

### 自动启动

win+R，打开运行，输入“shell:startup”，打开Windows启动文件夹

```bat
@REM 启动目录：
%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup

@REM 启动 WPS 文档
start /B "C:\Programs\WPSOffice\WPS Office\12.2.0.19805\office6\wps.exe" "D:\Dropbox\work\jasolar\accountJ.xlsx"

@REM startup vscode with workspace
start /B code "D:\Dropbox\work\vscode.workspace.common.code-win11.code-workspace"
```

### Context Menu 右键

[ContextMenuManager: 纯粹的Windows右键菜单管理程序](https://github.com/BluePointLilac/ContextMenuManager)

[JohanChane/easy-context-menu](https://github.com/JohanChane/easy-context-menu/tree/main)

```sh
# Restore Classic Context Menu on Windows 11 with Cmd

# 1. Open Cmd with Administrator privileges
# 2. Copy and paste the below Code and press enter

reg.exe add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f

# Restore Default Context Menu on Windows 11 with Cmd

# 1. Open Cmd with Administrator privileges
# 2. Copy and paste the below Code and press enter

reg.exe delete "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" /f

# NOTE: Restart the file explorer after the above steps.

taskkill /f /im explorer.exe & start explorer.exe
```

右键打开 WSL `wsl.exe --cd "%V"`

### 语言设置

[How to Change Language of Windows 11 Single Language Without Format - Super User](https://superuser.com/questions/1725144/how-to-change-language-of-windows-11-single-language-without-format?answertab=scoredesc#tab-top)

for those seeking to switch to en-us, i've been able to do it without downloading anything, as it seems preinstalled. in powershell:

```bat
reg add HKLM\SYSTEM\CurrentControlSet\Control\Nls\Language /v InstallLanguage /t REG_SZ /d 0409 /f
reg add HKLM\SYSTEM\CurrentControlSet\Control\Nls\Language /v Default /t REG_SZ /d 1033 /f
```

List was generated from ["Language Identifier Constants and Strings"](http://msdn.microsoft.com/en-us/library/windows/desktop/dd318693(v=vs.85).aspx) in MSDN

| Hex  | Dec  | Country code | Meaning                         |
|------|------|--------------|---------------------------------|
| 0004 | 4    | zh-CHS       | Chinese - Simplified            |
| 0404 | 1028 | zh-TW        | Chinese (Traditional) - Taiwan  |
| 0409 | 1033 | en-US        | English - United States         |

## tool

- [QuickLook](https://github.com/QL-Win/QuickLook/releases)
- [EverythingToolbar](https://github.com/srwi/EverythingToolbar/releases)
- [pot-desktop: 一个跨平台的划词翻译和OCR软件 | A cross-platform software for text translation and recognition.](https://github.com/pot-app/pot-desktop)
- [搜狗输入法产品使用说明](https://docs.qq.com/doc/DTEtkUHl4am9PbnFX?needShowTips=1)

- [5 Windows Alternatives to Mac's Alfred App](https://www.makeuseof.com/free-windows-alternatives-to-macs-alfred-app/)
- [6 Best Alfred App Alternatives for Windows to Be More Productive - TechWiser](https://techwiser.com/alfred-alternatives-windows/)
- [个人在 Windows 上常用软件清单 · Dejavu's Blog](https://blog.dejavu.moe/posts/windows-apps/)
- [DevToys - A Swiss Army knife for developers](https://devtoys.app/)
- [PDFgear - Bring Accessible PDF Software to the Masses](https://www.pdfgear.com/)
- [appstat | Process Monitor for Windows](https://pragmar.com/appstat/)

### shortcut

Ditto - 剪贴板管理工具 Ctrl+`

PowerToy
    将窗口最大化至全屏    Control+Command+F    WindowsKey+Up
    保存屏幕（截图）    Command+Shift+3    WindowsKey+Shift+S

git config --list --show-origin
git config path C:\Program Files\Git\etc\gitconfig

### Windows Terminal

1. Comment out Copy/Paste shortcut in setings.json, which are conflict with vim block selection
2. defaultProfile 定义启动Windows Terminal时用作默认配置文件的GUID。
   1. 将 copyOnSelect 设置为 true 可将选定的文本自动复制到剪贴板，而无需按 Ctrl + Shift +C。
   2. 将 copyFormatting 设置为 false 即可仅复制纯文本而无需任何样式(颜色，字体)。

```json
"copyFormatting": false,
"copyOnSelect": true,

```

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

# correct `git` reporting `detected dubious ownership in repository` without adding `safe.directory` when using WSL?
git config --global safe.directory '*'
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

## GPU

```ps1
nvidia-smi
```

## network

```bat
REM 本地的DSN信息
ipconfig /displaydns

REM 清除Windows 的 DNS 缓存
ipconfig /flushdns
```

### 排查网络

按Windows键 + R打开“运行”窗口，输入cmd并按Enter或单击“确定”来打开命令提示符，分别执行下面两个命令，并截图发回。

ipconfig
tracert -d example.com

### port

```bat
REM REM 是 "Remark" 的缩写，用于添加注释。
REM 查找端口占用
netstat -ano | findstr :8080

REM 查找进程号
tasklist | findstr 4476
```

### tracert

tracert 命令格式如下

tracert [-d] [-h maximum_hops] [-j computer-list] [-w timeout] target_name

如果不带选项的话，会将IP地址解析成主机名，因为需要查询DNS，所以速度比较慢。

- -d 选项：不将IP地址解析成主机名，因此路由追踪速度快很多。
- -h 选项：说明路由的最大跳数，默认是30跳。
- -w 选项：说明等待每一个ICMP响应报文的时间，默认4s，如果接收超时，则显示星号*。跳数和等待时间，使用默认值即可，所以平时一般都不需要添加这两个选项。
- -j 选项：说明ICMP报文要使用IP头中的松散源路由选项，后面是经过的中间节点的地址或主机名字,最多9个，各个中间节点用空格隔开。

这里说明下松散源路由和严格源路由，严格源路由是指，相邻路由器之间不得有中间路由器，并且所经过路由器的顺序不可更改。而松散源路由，则相反，相邻路由器之间可以有中间路由器。一般的路由追踪，也用不到-j这个选项。除非是针对大的网络故障，需要检测几条路径到达同一个目的地址，才需要使用-j选项。所以，通常情况下，我们使用tracert –d这种格式就可以了。我们以追踪百度网站为例。

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

### 搜狗输入法

[搜狗输入法产品使用说明](https://docs.qq.com/doc/DTEtkUHl4am9PbnFX?needShowTips=1)

1. 翻页选字：逗号句号(,。)、减号等号(-=)、左右方括号(【】)默认开启这三种方式翻页选
2. v 模式快速计算
   1. 数字转换(中文大小写数字、99 以内的罗马数字、大小写金额)
   2. 日期格式装换
   3. 加减乘除算式、函数计算
3. 不会读的字用U模式拆分输入
   1. 拆分输入:输入U后，直接输入生僻字的组成部分的拼音或部首即可。搜狗输入法显示正常上屏后显示方框可能是程序不支持该生僻字。
      1. 示例一:部首拆分输入。如【】，可拆分为【氵】和【力】。输入 ushuili
   2. 笔画输入:通过文字构成笔画的拼音首字母来打出想要的字。横(h)、竖(s)、撇(p)、捺(n)、点(d)、折(z)
      1. 示例一:【木】字由横(h)、竖(s)、撇(p)、捺(n)构成。输入 uhspn
      2. 需要注意的是:【忄】的笔顺是点点竖(dds)，不是竖点点、点竖点。
4. tab 快速筛选排序靠后单字
   1. 拆字辅助码功能
      1. 想输入一个汉字【娴】，但是非常靠后，找不到，那么输入【xian】，然后按下【tab】键，在输入【娴】的两部分【女】【闲】的首字母nx，就可以看到只剩下【娴】字了。输入的顺序为:输入 xian+按 tab+输入 nx。
   2. 笔画筛选功能:使用方法是输入一个字或多个字后，按下tab键，然后用h、s竖、p撇、n捺、z折依次输入第一个字的笔顺，一直找到该字为止。
      1. 例如，快速定位【珍】字，输入了zhen后，按下【tab】，然后输入珍的前两笔【hh】，就可定位该字。
5. 快速 0键 筛选单字
   1. 当候选比较多(如:liqi，有 21个候选)，需要多次翻页才能找到单字，选择单字比较花时间。此时可以用0键筛选单字功能，即输入过程中按主键盘区的 0键，即可直接定位到单字候选上，避免多次翻页。
6. 开启自定义短语功能的前提下，在输入框输入拼音串后，把鼠标放到拼音串上可以快速进入添加短语页面。
7. 跨屏输入手机输入在电脑上屏
   1. 跨屏输入只支持“语音输入”和“拍照转文字”输入模式。

## WSL

Windows Subsystem for Linux

[Basic commands for WSL | Microsoft Learn](https://learn.microsoft.com/en-us/windows/wsl/basic-commands#install)

```sh
wsl --status //检查 WSL 状态
wsl //进入默认的发行版本，退出执行 exit
# 列出已安装的 Linux 发行版
wsl -l -v
wsl --list --verbose
wsl --list --online
wsl --install -d Ubuntu-24.04
wsl --set-default Ubuntu-24.04
wsl --terminate //终止指定的发行版或阻止其运行
# 例：
wsl --terminate Ubuntu-18.04
wsl --shutdown //重启wsl服务
wsl --set-default //设置默认 Linux 发行版
wsl --set-version //将WSL版本设置为1或2
wsl --set-default-version //设置默认 WSL 版本
wsl --distribution --user //运行特定的Linux发行版
wsl --distribution <Distribution Name> --user <User Name>
wsl -u , wsl --user //以特定用户的身份运行
wsl config --default-user //更改发行版的默认用户
wsl --unregister //注销或卸载 Linux 发行版
```

### wsl -update 慢解决办法

解决WSL更新速度慢的方案，下载安装WSL 离线包，地址 `https://github.com/microsoft/WSL/releases`

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

[Manual installation steps for older versions of WSL | Microsoft Learn](https://learn.microsoft.com/en-us/windows/wsl/install-manual#step-6---install-your-linux-distribution-of-choice)

[Ubuntu2404-240425 download link](https://wslstorestorage.blob.core.windows.net/wslblob/Ubuntu2404-240425.AppxBundle)

```ps1
Add-AppxPackage .\Ubuntu2404-240425.AppxBundle
wsl --list --online
wsl --install -d Ubuntu-24.04

# 启动系统
wsl --distribution Ubuntu-24.04
```

[My Windows Subsystem for Linux setup - Matthew Somerville](https://dracos.co.uk/wrote/wsl/)

[Working across file systems | Microsoft Learn](https://learn.microsoft.com/en-us/windows/wsl/filesystems)

OS default location：
Ubuntu-20.04 /mnt/c/Users/user/AppData/Local/Packages/CanonicalGroupLimited.UbuntuonWindows_79rhkp1fndgsc/
Ubuntu-24.04 /mnt/c/Users/user/AppData/Local/Packages/CanonicalGroupLimited.Ubuntu24.04LTS_79rhkp1fndgsc
LocalState E:\WSL\Ubuntu2004

path：\\wsl$\Ubuntu\home\pu\.zshrc
explorer.exe .

```sh
sudo visudo

# This preserves proxy settings from user environments of root
# equivalent users (group sudo)
Defaults:%sudo env_keep += "http_proxy https_proxy ftp_proxy all_proxy no_proxy"

# This allows running arbitrary commands, but so does ALL, and it means
# different sudoers have their choice of editor respected.
Defaults:%sudo env_keep += "EDITOR"

# Completely harmless preservation of a user preference.
Defaults:%sudo env_keep += "GREP_COLOR"

# sudo without password
# Allow members of group sudo to execute any command
%sudo   ALL=(ALL:ALL) NOPASSWD: ALL

# install pip
sudo apt-get update
sudo apt install python3-pip

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

# clone config 项目到当前目录
git init .
git remote add origin https://petergite@gitee.com/petergite/configuration.git
git pull origin work
# 修改 URL
# url = git@gitee.com:petergite/configuration.git
```

### wsl config

- .wslconfig to configure global settings across all installed distributions running on WSL 2.
- wsl.conf to configure local settings per-distribution for each Linux distribution running on WSL 1 or WSL 2.

#### 通过 镜像模式 共享 Windows 代理

镜像模式需要 Windows 11 22H2 或更高版本

打开或创建WSL配置文件 `%userprofile%\.wslconfig`，设置使用镜像模式（mirrored），默认是 NAT 模式

mirrored 模式下，wsl

1. 可以使用系统代理
2. 不能使用 Host only 网络

nat 模式下，wsl

1. 不能使用系统代理
2. 可以使用 Host only 网络
3. 会提示信息：wsl: 检测到 localhost 代理配置，但未镜像到 WSL。NAT 模式下的 WSL 不支持 localhost 代理。

```ini
[wsl2]
# default nat
#networkingMode=nat
networkingMode=mirrored
autoProxy=true
```

重启 WSL

```bat
wsl --shutdown
```

#### [Rename tab title not working for WSL and Bash · Issue #5333 · microsoft/terminal · GitHub](https://github.com/microsoft/terminal/issues/5333)

`"suppressApplicationTitle": true,`

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

#### Visual-Block mode not working in Vim with C-v on WSL@Windows 10

[copy paste - Visual-Block mode not working in Vim with C-v on WSL@Windows 10 - Stack Overflow](https://stackoverflow.com/questions/61824177/visual-block-mode-not-working-in-vim-with-c-v-on-wslwindows-10)

Disable paste behaviour in the settings.json. You can do that by pressing CTRL+SHIFT+,.

From version 1.4

```json
  "actions": [
    ...
    // { "command": {"action": "paste", ...}, "keys": "ctrl+v" }, <------ THIS LINE
```

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

### Move WSL to other drive from C drive

change in Docker desktop

[Move WSL to another drive. WSL (Windows Subsystem for Linux) is a… | by Hafiz Azhar | Medium](https://medium.com/@rahmanazhar/move-wsl-to-another-drive-ab8002152cf2)

%USERPROFILE%\AppData\Local\Docker\wsl

```sh
# superceded by changing in Docker desktop
#
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

### Node.js

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
