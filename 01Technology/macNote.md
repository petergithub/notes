# Mac Note

`System Preference -> Keyboard -> Shortcuts -> App Shortcuts -> +` 为任何软件菜单里的项目设置快捷键

[在 Mac 上截屏或录制屏幕](https://support.apple.com/zh-cn/guide/mac-help/mh26782/mac)
`Command+Shift+5` capture screenshot
`Command+Shift+3` 捕捉整个屏幕
`Command+Shift+4` 捕捉屏幕的一部分
`Command-Control-Esc` 停止屏幕录制
Options:
`defaults write com.apple.screencapture location ~/Desktop/`
`defaults write com.apple.screencapture target clipboard` Save to clipboard
`killall SystemUIServer` to make the command effective
录制 Mac 播放的声音需要安装 [Loopback](https://rogueamoeba.com/loopback/)

分屏功能 1、当窗口不处于全屏状态时，长按两秒左上角绿色按钮松手，即可选择右边窗口。

`unar -encoding GBK file.zip` 解压缩文件避免乱码
`md5 -s string`
`md5 /path/to/file` or `openssl md5 /path/to/file`
`shasum -a 1 /path/to/file` or `openssl sha1 /path/to/file`
`shasum -a 256 /path/to/file` or `openssl sha256 /path/to/file`
`brew install sleepwatcher` [sleepwatcher](https://formulae.brew.sh/formula/sleepwatcher)

got error message `find: message_uk.xml: unknown primary or operator` with command `find . -name *_uk.xml`
correct with quote: `find . -name '*_uk.xml'`

`gcc -v` `gcc --version`
`sw_vers -productVersion` return the OS version
`system_profiler SPSoftwareDataType` more info about OS

Safari Developer Tools: Safari > Preferences > Advanced > Show Develop menu in menu bar, Then from the Safari “Develop” menu select  “Show Web Inspector” or use the keyboard shortcut Option+Command+i

## Software

### vs code

`Command+P` 快速跳转文件
    `?` 其他用法输
    `@/#{symbol}` 跳转到 当前文件/workspace 中的 symbol
    `:{Number}` 跳转到任意行
`Command+Shift+P` open command palette
`Command+Shift+N` open a new window
`Command+Shift+\` 跳转到匹配的括号
`Command+\` split editor

`Shift+Option+鼠标拖动` block selection
`Command+Option+上下键` 在连续的多列上，同时出现光标
`Option + 鼠标点击任意位置` 在任意位置，同时出现光标
`Cmd + Shift + L` 在选中文本的所有相同内容处，出现光标
File->Open Recent->Reopen Closed Editor: `Ctrl+Shift+T`

add to PATH environment: `command palette -> shell command install`

configure control + scroll-wheel to increase/decrease zoom in VS Code:
edit settings.json and add this line: "editor.mouseWheelZoom": true
or go to settings CTRL + , or File > Preferences > Settings and search for mouseWheelZoom

执行文字相关的导航或操作时将用作文字分隔符的字符(比如双击选中文字, 只会选中下面分隔符中的文字)

```sh
"editor.wordSeparators": "`~!@#$%^&*()-=+[{]}\\|;:'\",.<>/！（）｛｝【】、；：’”，。《》？?"
```

#### vs code plugin

`code --list-extensions | xargs -L 1 echo code --install-extension` to list all extensions with installation command

[Markdown Preview Enhanced is a SUPER POWERFUL markdown extension](https://shd101wyy.github.io/markdown-preview-enhanced/)
[Markdown All in One](https://marketplace.visualstudio.com/items?itemName=yzhang.markdown-all-in-one#keyboard-shortcuts-1)
[PicGo - A fast and powerful image uploading plugin](https://marketplace.visualstudio.com/items?itemName=Spades.vs-picgo)
[Better Outline](https://marketplace.visualstudio.com/items?itemName=adamerose.better-outline): text outline
[To delete an entire block of whitespace or tab, and reduce the time programmers need to press backspace](https://marketplace.visualstudio.com/items?itemName=jasonlhy.hungry-delete)

### Mac common

通过 全键盘控制(Tab 键和箭头浏览、空格键选择) 将键盘当作鼠标使用: 系统偏好设置 -> 键盘 -> 快捷键 -> 全键盘控制
`Ctrl+F2` 激活菜单
`Ctrl+F8` 激活状态栏
`Command+Shift+/` 帮助
`Command+Shift+4` snapshot
Home键=Fn+左方向 End键=Fn+右方向 PageUP=Fn+上方向 PageDOWN=Fn+下方向
向前Delete=Fn+delete键
commond+上箭头（就是右下角的方向键）可以直达页面顶部
commond+下箭头可以直达页面底部

`Fn+Right/Left` windows-style home/end
`Fn+Up/Down` windows-style page up/down

`brew install bat` alternative to `cat`
`alt+e` eclipse plugin EasyShell Main pop menu
`tldr` TL;DR project for help

#### Finder shortcut

`Command+Option+Space` Show Finder search window

Create new folder: `Command+Shift+n`
`Command-Option-P` to show or hide the path bar
`Command-Option-C` 复制文件夹路径
`Command-/` to show or hide the status bar
`Command-Option-S` show or hide Finder's sidebar
`Command+Shift+G` 快捷键可以完成到达某路径的操作
Display hidden file: `Command+Shift+.`
强制退出程序窗口 `Command+Option+Esc`

#### open terminal in Finder

在Finder打开terminal这个功能其实是有的，但是系统默认没有打开，我们可以通过如下方法将其打开
进入系统偏好设置->键盘->快捷键->服务。 在右边新建位于文件夹位置的终端窗口上打勾。
如此设置后，在Finder中右击某文件，在出现的菜单中找到服务，然后点击新建位于文件夹位置的终端窗口即可！

#### other

[网页内容监视 Netqon OpenWebMonitor](https://github.com/fateleak/openwebmonitor)

**Your security preferences allow installation of only apps from the App Store and identified developers**
By default Apple has changed the security settings to only allow installation of apps from the Mac App Store and identified developers.
To temporarily get around the error message, control-click the application and choose Open. Click the Open button in the warning dialog that appears.
To change this permanently go to System Preferences > Security & Privacy. On the General Tab click the little lock in the lower left corner to unlock the general preference pane. Then select the Anywhere radio button beneath Allow applications downloaded from.

### iTerm

block selection: `Command+Option+Left Click`

iTerm 在远程的服务器上右键 scp 下载：

1. 在远程的服务器上安装安装 Shell Integration
2. 在启动脚本中添加 export hostname

    ```sh
    export iterm2_hostname=YOUR_REMOTE_HOSTNAME_IN_LOCAL_SSH_CONFIG
    test -e "${HOME}/.iterm2_shell_integration.`basename $SHELL`" && source "${HOME}/.iterm2_shell_integration.`basename $SHELL`"
    ```

3. 重新登陆，或者手动 source 文件 `iterm2_shell_integration`，当命令行最左边出现小的蓝色三角形的时候就是成功了，这时候 ls 到文件就可以右键下载了

#### Settings

Display: `Preference -> Profiles -> Colors -> Foreground: black, Background: white, Bold: gray, Minimum contrast: middle`

### chrome

Alt+U or click the icon to copy URL without encoding from address bar

#### Extension

[Bypass Paywalls web browser extension for Chrome and Firefox.](https://github.com/iamadamdev/bypass-paywalls-chrome)

尝试油猴脚本

#### 在Chrome 浏览器上滚动截屏

1. 打开 Chrome 浏览器，进入需要截图的网站页面
2. 打开开发者工具：在页面任何地方点击鼠标右键，在弹出菜单中选择「检查」选项。或者使用快捷键组合：option + command + i。
3. 打开命令行（command palette）：command + shift + p。
4. 在命令行中输入「screen」，这时自动补齐功能会显示出一些包含 「Screen」 关键字的命令。移动方向键到「Capture full size screenshot」并回车,chrome就会自动下载整个页面截屏文件。

#### How to Enable DNS Over HTTPS (DoH)

1. Select the three-dot menu in your browser > Settings.
2. Select Privacy and security > Security.
3. Scroll down and enable Use secure DNS.
4. Select the With option, and from the drop-down menu choose Cloudflare (1.1. 1.1).
5. [Browser Security Check | Cloudflare](https://www.cloudflare.com/ssl/encrypted-sni)

### firefox

firefox profile location: `/users/$user/library/application support/firefox/profiles`

### shell

1. last parameter from last command: `esc+.`, `!$`
 Move in command line:
`esc+delete` delete one word backward, like `ctrl+w`
`option+click` cursor will move to clicked position. This even works inside `vim`

`open .` open Finder in terminal
`open -a Finder`
`open -a iTerm`

#### date

`date -r 1444645890` convert timestamp to date
`date +%s` get current timstamp
`date +%U` display week number of this year

### mycli

[Docs](https://www.mycli.net/docs)

Connect using a username, hostname and database name: `mycli -u my_user -h my_host.com my_database`

Connect using a DSN: `mycli mysql://my_user@my_host.com:3306/my_database`

[Commands](https://www.mycli.net/commands)

### 代理服务器 AnyProxy

1. 以支持 Https 方式启动 `anyproxy --intercept`
2. 启动浏览器 [链接](http://localhost:8002)
3. 客户端设置代理 [链接](ip:8001)
 [安装使用文档 代理服务器 AnyProxy](https://www.jianshu.com/p/2074f7572694)
 [alibaba/anyproxy: A fully configurable http/https proxy in NodeJS](https://github.com/alibaba/anyproxy)

移动端安装证书
浏览器打开地址 http://localhost:8002/fetchCrtFile 进行证书下载
扫描二维码地址 http://localhost:8002/qr_root 进行证书下载
手机打开链接下载 http://ip:8002/downloadCrt

下载后，先添加配置描述文件，然后信任证书

设置》通用》 VPN 与设备管理》添加配置描述文件
设置》通用》关于本机》证书信任设置 选择信任

安装流程

```sh
brew install node
node --version
# 安装稳定正式版
npm install -g anyproxy
```

启动

```sh
# 启动 AnyProxy
anyproxy

# 以支持 Https 方式启动
anyproxy --intercept
```

### WPS

`COMMAND+Fn+Up/Down (Ctrl+PageUp/PageDown)` 切换到上/下一个工作表 Sheet
Cloud document storage location: /Users/pu/Library/Containers/com.kingsoft.wpsoffice.mac/Data/Library/Application Support/Kingsoft/WPS Cloud Files/userdata/qing/filecache

### Calibre

自定义翻译源，打开 Ebook viewer，双击查询，然后点击 `Add sources`，加入以下格式的链接

```sh
https://cn.bing.com/search?q=define:{word}
https://www.google.com/search?q=define:{word}
https://fanyi.baidu.com/#en/zh/{word}
```

#### plugin

Ebook Translator是由书伴开发的一个Calibre插件。该插件可以将不同格式、不同语言的电子书翻译成指定语言，并在原文段落之后形成对照排版，方便辅助阅读和理解原文

## Manage

[苹果 Mac 重置 SMC、NVRAM、PRAM 方法教程 - 解决 macOS 卡顿，风扇响或无法启动](https://www.iplaysoft.com/p/mac-reset-smc-nvram-pram)
[How to Reset your Mac or MacBook's PRAM and SMC | Avast](https://www.avast.com/c-reset-mac-pram-smc)

### stop programs from opening on startup

System Preferences -> Users & Groups -> Login Items

### launchctl

[mac启动项](https://faichou.space/mac-startups/)
man launchctl 查看, 比如很实用的有:

```text
launchctl load **
launchctl unload **
launchctl list
launchctl print user/$(id -u)
launchctl print-disabled user/$(id -u)

登录之后启动的进程
~/Library/LaunchAgents         Per-user agents provided by the user.
/Library/LaunchAgents          Per-user agents provided by the administrator.
/Library/LaunchDaemons         System wide daemons provided by the administrator.
/System/Library/LaunchAgents   OS X Per-user agents.
/System/Library/LaunchDaemons  OS X System wide daemons.
```

#### disable auto start

load from `/Library/LaunchAgents`
disable it `launchctl unload -w /Library/LaunchAgents/com.adobe.AdobeCreativeCloud.plist`
turn it back on `launchctl load -w /Library/LaunchAgents/com.adobe.AdobeCreativeCloud.plist`

### mac新建全局快捷键 Open Terminal

[mac新建全局快捷键 - 简书](https://www.jianshu.com/p/afee9aeb41a8)

1. 在Launchpad中打开mac自带软件自动操作
2. 选取文稿类型为服务
3. “服务”收到选定的选项中选择没有输入
4. 在当前页左侧导航栏中找到运行AppleScript并双击，在命令框中输入图示1内容（这里以快捷打开mac Terminal为例）

    ```AppleScript
    on run {input, parameters}

    (* Your script goes here *)
    tell application "Terminal" reopen
    activate

    end tell
    end run
    ```

5. command+s保存为 Open Terminal
6. 打开设置-键盘-快捷键-服务-通用-找到“Open Terminal” 单机右侧添加快捷键，键入你想要设置的按键保存即可，图示2

### 停止系统更新提示

```sh
# 忽略系统升级到 macOS Monterey 更新提醒
sudo softwareupdate --ignore "macOS Monterey"
# prevent the red badge in System Preferences
defaults write com.apple.systempreferences AttentionPrefBundleIDs 0
# restart the Dock (without affecting the rest of your system) to reset the state of the System Preferences icon.
killall Dock

# 要使系统升级更新再次出现在 “软件更新” 中
sudo softwareupdate --reset-ignored
```

[How to stop getting a reminder to update to Catalina in macOS](https://www.macworld.com/article/233450/how-to-stop-getting-a-reminder-to-update-to-catalina-in-macos.html)

### How to Prevent Mac Sleeping When Display is Off

MacOS Ventura 13.0
System Settings > Displays > Advanced > Toggle the switch for “Prevent automatic sleeping on power adapter when the display is off”

### macbook pro合盖之后耗电很快:休眠时关闭 WiFi

安装一个监听工具 `brew install sleepwatcher`
设置软件服务自启动 `brew services start sleepwatcher`
查看进程是否启动 `ps aux | grep sleepwatcher`
~/.sleep ~/.wakeup 写入需要执行的语句: 关闭/打开 网络连接的命令
echo "sudo ifconfig en0 up" > ~/.wakeup
echo "sudo ifconfig en0 down" > ~/.sleep

参考 https://github.com/xinstein/PleaseSleep
https://www.zhihu.com/question/34902513

### [How to open a port](https://gauravsohoni.wordpress.com/2015/04/14/mac-osx-open-port/)

To open this port, add the following line in /etc/pf.conf

sudo vim /etc/pf.conf

```shell
# Open port 1234 for TCP on all interfaces
pass in proto tcp from any to any port 1234
# You can limit the ip addresses .. replace any with allowed addresses ..
```

restart the service  `sudo pfctl -f /etc/pf.conf`

### How to Set a Short User Password?

[command line - How to Set a Short User Password in macOS Mojave and Later (10.14+) - Ask Different](https://apple.stackexchange.com/questions/337468/how-to-set-a-short-user-password-in-macos-mojave-and-later-10-14)

edit policy file

1. Export current policy: `pwpolicy getaccountpolicies | awk 'NR>1' > ~/Downloads/accountpolicies`
2. Edit the policy file, change the quoted part to your Regex (default: `^(?=.*[0-9])(?=.*[a-zA-Z]).+`). `policyAttributePassword matches '^$|.{4,}+'`
3. Import policy file for account username: `pwpolicy setaccountpolicies -u username ~/Downloads/accountpolicies`
4. chang password for account: `sudo passwd username`

`^$|.{3,}+` for a 4 character length password.

### How to Write NTFS Drives on macOS Monterey

[How to Write NTFS Drives on macOS Monterey](https://techsviewer.com/how-to-write-ntfs-drives-on-macos-monterey/)

Method 1: Using Terminal to Enable Writing to NTFS Drives

```sh
diskutil list
# Replace the “disk2s1” section with the Indentifier of your NTFS drive.
sudo mkdir /Volumes/disk2s1
sudo mount -t ntfs -o rw,auto,nobrowse /dev/disk2s1 /Volumes/disk2s1

sudo mkdir -p /Volumes/documentShelf && sudo mount -w -t ntfs -o rw,nobrowse /dev/disk3s5 /Volumes/documentShelf
sudo mkdir -p /Volumes/entertainmentBox && sudo mount -w -t ntfs -o rw,nobrowse /dev/disk3s6 /Volumes/entertainmentBox
sudo mkdir -p /Volumes/softwareToolkit && sudo mount -w -t ntfs -o rw,nobrowse /dev/disk3s7 /Volumes/softwareToolkit

# macOS Ventura 13.2
# [How to Write NTFS Drives on macOS Ventura](https://techsviewer.com/how-to-write-ntfs-drives-on-macos-ventura/)
# 1. install MacFuse from [Home - macFUSE](https://osxfuse.github.io/)
# 2. Install NTFS-3G from Homebrew
# 2.1 brew tap gromgit/homebrew-fuse
# 2.2 brew install ntfs-3g-mac
# 3. # List volume in macOS: diskutil list
# 3.1 Unmount USB NTFS Drive (your NTFS drive identifier: disk2s2): sudo diskutil unmount /dev/disk2s2
# 3.2 Mount and Enable NTFS Write permission
sudo umount /Volumes/documentShelf && sudo mkdir -p /Volumes/documentShelf && sudo mount_ntfs /dev/disk4s5 /Volumes/documentShelf
sudo umount /Volumes/entertainmentBox && sudo mkdir -p /Volumes/entertainmentBox && sudo mount_ntfs /dev/disk4s6 /Volumes/documentShelf
sudo umount /Volumes/softwareToolkit && sudo mkdir -p /Volumes/softwareToolkit && sudo mount_ntfs /dev/disk4s7 /Volumes/softwareToolkit

```

## Network

[Mac 抓包 Recording a Packet Trace | Apple Developer Documentation](https://developer.apple.com/documentation/network/recording_a_packet_trace)

## brew Homebrew

```sh
brew install default location: /usr/local/Cellar
brew search <package_name>      # 搜索
brew install <package_name>     # 安装一个软件
brew update                     # 从服务器上拉取，并更新本地 brew 的包目录
brew upgrade <package_name>     # 更新软件
brew outdated                   # 查看你的软件中哪些有新版本可用
brew cleanup                    # 清理老版本。使用 `-n` 参数，不会真正执行，只是打印出真正运行时会做什么。
brew list --versions            # 查看你安装过的包列表（包括版本号）
brew link <package_name>        # 将软件的当前最新版本软链到`/usr/local`目录下
brew unlink <package_name>      # 将软件在`/usr/local`目录下的软链接删除。
brew info                       # 显示软件的信息
brew deps                       # 显示包依赖
brew services start <package_name>  # 设置自启动
brew services stop <package_name>  # 去掉自启动

check software info from brew: brew info mysql
install with brew: brew install tig autojump
search with brew cask: brew cask search chrome
install with brew cask: brew install --cask google-chrome
startup with brew: brew services start nginx
brew switch another version: brew switch python 3.6.5_1
brew uninstall <package_name>
```

### Homebrew update 慢 设置代理

设置代理 `alias setproxy="export http_proxy=http://127.0.0.1:1087;export https_proxy=http://127.0.0.1:1087;"`

### 使用国内镜像

[homebrew | 镜像站使用帮助 | 清华大学开源软件镜像站 | Tsinghua Open Source Mirror](https://mirrors.tuna.tsinghua.edu.cn/help/homebrew/)

[Homebrew更换国内镜像源_mb5fed4c003aebe的技术博客_51CTO博客](https://blog.51cto.com/u_15072811/3441116)

Homebrew主要由四部分组成：

| 名称             | 说明                       | 文件位置                    |
| ---------------- | ------------------------ | --------------------------- |
| brew             | Homebrew源代码仓库         | brew --repo                 |
| homebrew-core    | Homebrew核心软件仓库       | brew --repo homebrew/core   |
| homebrew-bottles | Homebrew预编译二进制软件包 | 设置 HOMEBREW_BOTTLE_DOMAIN |
| homebrew-cask    | MacOS客户端应用            |                             |

默认数据源

* brew.git: `https://github.com/Homebrew/brew.git`
* brew-core.git: `https://github.com/Homebrew/homebrew-core.git`

其他数据源，替换域名使用

* 阿里云数据源： `https://mirrors.aliyun.com`
* 清华大学数据源：`https://mirrors.tuna.tsinghua.edu.cn`

#### 查看当前使用的数据源

```sh
# 查看配置信息命令
brew config

# Git仓库直接查看
cd "$(brew --repo)" && git remote -v
cd "$(brew --repo homebrew/core)" && git remote -v
```

#### 更新数据源

```sh
# 如果用户设置了环境变量 HOMEBREW_BREW_GIT_REMOTE 和 HOMEBREW_CORE_GIT_REMOTE，则每次执行 brew update 时，brew 程序本身和 Core Tap (homebrew-core) 的远程将被自动设置。推荐用户将这两个环境变量设置加入 shell 的 profile 设置中

export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"
export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew/homebrew-bottles"

# # 手动更换 brew.git
cd "$(brew --repo)" && git remote set-url origin https://mirrors.tuna.tsinghua.edu.cn/homebrew/brew.git
# 手动更换 core, cask, cask-fonts, cask-drivers, cask-versions, command-not-found
for tap in core cask{,-fonts,-drivers,-versions} command-not-found; do
    brew tap --custom-remote --force-auto-update "homebrew/${tap}" "https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-${tap}.git"
done
brew update # 执行更新

brew config # 查看当前配置

# 更换 homebrew-bottles
echo 'export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.tuna.tsinghua.edu.cn/homebrew/homebrew-bottles' >> ~/.zshrc
```

#### 复原数据源

```sh
# 删除 shell 的 profile 设置中的环境变量 HOMEBREW_BREW_GIT_REMOTE, HOMEBREW_CORE_GIT_REMOTE 和 HOMEBREW_BOTTLE_DOMAIN
brew update # 执行更新

# brew 程序本身，Homebrew / Linuxbrew 相同
unset HOMEBREW_BREW_GIT_REMOTE
git -C "$(brew --repo)" remote set-url origin https://github.com/Homebrew/brew

# 以下针对 macOS 系统上的 Homebrew
unset HOMEBREW_CORE_GIT_REMOTE
BREW_TAPS="$(BREW_TAPS="$(brew tap 2>/dev/null)"; echo -n "${BREW_TAPS//$'\n'/:}")"
for tap in core cask{,-fonts,-drivers,-versions} command-not-found; do
    if [[ ":${BREW_TAPS}:" == *":homebrew/${tap}:"* ]]; then  # 只复原已安装的 Tap
        brew tap --custom-remote "homebrew/${tap}" "https://github.com/Homebrew/homebrew-${tap}"
    fi
done

```

## Issue

### dyld: Library not loaded: /usr/local/opt/openssl/lib/libssl.1.0.0.dylib

`ls -al /usr/local/Cellar/openssl`

[dyld: Library not loaded error on macOS (OpenSSL missing) #86](https://github.com/kelaberetiv/TagUI/issues/86#issue-303370944)
This error is happening because macOS decided to drop OpenSSL and switched to LibreSSL. Furthermore, macOS Homebrew switched from OpenSSL v.1.0 to v1.1, breaking many other apps that are dependent on OpenSSL v1.0.
`brew uninstall openssl; brew install https://github.com/tebelorg/Tump/releases/download/v1.0.0/openssl.rb`

`brew switch openssl 1.0.2s`

### dyld: Library not loaded: /usr/local/opt/readline/lib/libreadline.7.dylib

1. find readline version: `brew info readline`
2. switch to the version above: `brew switch readline 8.0.0`

## Apps

* [精品MAC应用分享](https://xclient.info/)
* [Cmacked - Cracked Mac Apps & Games](https://cmacked.com/page/2/)
* [XMac.App](https://xmac.app/)
* [IINA /ˈiːnə/ The modern media player for macOS.](https://iina.io/)
* NTFS 读写工具：Paragon NTFS / Tuxera NTFS（100+ 元）—— NTFS Tool（免费）
* [ToDesk 安全流畅的远程控制软件](https://www.todesk.com/download.html)
* [rustdesk 远程桌面软件](https://rustdesk.com/zh/)
* [Joplin is a free, open source note taking and to-do application](https://github.com/laurent22/joplin)
* [Typora — a markdown editor, markdown reader](https://typora.io/)
* [TablePlus | Modern, Native Tool for Database Management](https://tableplus.com/)
* [Go2Shell](http://zipzapmac.com/Go2Shell): Opens a terminal window to the current directory in Finder: `open -a iTerm`
* [Mos](https://mos.caldis.me/) set scroll direction independently for your mouse
* [Fantastical Calendar](https://flexibits.com/fantastical)
* [jd-GUI](http://jd.benow.ca)
* [SizeUp](http://www.irradiatedsoftware.com/sizeup/)
* 窗口管理神器：Magnet（18 元）—— Rectangle（免费）
* [Better And Better](http://www.better365.cn/col.jsp?id=114):状态栏,键盘鼠标手势设置
* [Vanilla](https://matthewpalmer.net/vanilla/): Hide menu bar icons on your Mac, Command+drag; start with open -a /Applications/Vanilla.app in a script ~/.script/mac_startup.sh
* 菜单栏图标管理：Bartender（109 元）—— Hidden Bar（免费）
* [Open Web Monitor](http://openwebmonitor.netqon.com/)
* [kap: screen record to gif](https://getkap.co/)
* Airtest - UI Auto test
* SwitchHosts - hosts /etc/hosts switch
* [Bagel is a little native iOS network debugger](https://github.com/yagiz/Bagel)
* NewFileMenuFree
* Maccy: Lightweight clipboard manager for macOS
* [DevToys For mac - ObuchiYuki/DevToysMac](https://github.com/ObuchiYuki/DevToysMac)
* [Open Source SQL Editor and Database Manager | Beekeeper Studio](https://www.beekeeperstudio.io/) sqllite
* VeraCrypt, TrueCrypt-7.2-Mac-OS-X
* 垃圾清理：CleanMyMac X（248 元/年）——腾讯柠檬清理（免费）
* 全能截图工具：CleanShot X（200 元）/ Xnip（50 元）iShot（免费）
* 解压缩：360rar
* [Proxyman · Native, Modern Web Debugging Proxy 代理抓包工具](https://proxyman.io/)
* [MacWhisper](https://app.gumroad.com/d/29e33b796f6ce9bb186f87cdf2fadb16) License key 0E077F0E-B40C4044-B5FAFD74-41DE25A7
* [Downie：Mac OS平台最强大的嗅探下载工具，视频、音频、PDF手到擒来](https://xuebajiajiayou.com/714/)
* [testdisk: data recovery utilities](https://www.cgsecurity.org/testdisk_doc/#) `brew install testdisk`
* [Easydict: 翻译，支持离线 OCR 识别](https://github.com/tisfeng/Easydict) 类似 Bob
* [Mp3tag 1.8.16 音频元数据编辑 - 精品MAC应用分享](https://xclient.info/s/mp3tag.html)
* [Aiko — Sindre Sorhus 语音转文字](https://sindresorhus.com/aiko)
* [Switch - Convert Audio Formats: Switch Audio File Converter Software](https://www.nch.com.au/switch/index.html)
