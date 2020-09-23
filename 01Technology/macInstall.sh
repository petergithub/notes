# install package
# refer to [高效程序员的MacBook工作环境配置](http://www.codeceo.com/article/programmer-macbook-workplace.html)
# automator [给MAC应用设置系统热键(快捷键)启动](https://www.jianshu.com/p/b83f54888ff9)
# TODO: 

# firefox 56.0.2 https://sourceforge.net/projects/ubuntuzilla/files/mozilla/apt/pool/main/f/firefox-mozilla-build/
# https://ftp.mozilla.org/pub/firefox/releases/56.0.2/

## zsh profile
# https://stackoverflow.com/questions/26252591/mac-os-x-and-multiple-java-versions
# java path: /Library/Java/JavaVirtualMachines/
echo "export JAVA_HOME=$(/usr/libexec/java_home -v1.8)" >> ~/.zsh.mac 
echo "export JAVA_HOME=$(/usr/libexec/java_home -v11)" >> ~/.zsh.mac 

echo "#default java8" >> ~/.zsh.mac 
echo "export JAVA_HOME=$JAVA_8_HOME" >> ~/.zsh.mac 

# zsh
brew install zsh
chsh -s $(which zsh)
# oh my zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
# sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="alanpeabody"/' ~/.zshrc
# sed -i 's/# DISABLE_AUTO_TITLE="true"/DISABLE_AUTO_TITLE="true"/' ~/.zshrc
# sed -i 's/# ENABLE_CORRECTION="true"/ENABLE_CORRECTION="true"/' ~/.zshrc
## Disable 'Would you like to check for updates' prompt: add DISABLE_AUTO_UPDATE="true" on your .zshrc before the source $ZSH/oh-my-zsh.sh line
# source ~/.zshrc

# common software install begin
brew install tig autojump iproute2mac tldr jq
brew cask install atom google-chrome
brew install node

# develop software install
# download from mysql official website mysql-5.7.23-macos10.13-x86_64.tar.gz
#brew install mysql
#brew services start mysql
#mysql_secure_installation
#mysql -u root -proot
#
#brew cask install mysqlworkbench
#
## install mysql older version  https://gist.github.com/benlinton/d24471729ed6c2ace731
#brew install mysql@5.7
### change to 5.7 version
## Unlink current mysql version
#brew unlink mysql 
#brew switch mysql@5.7 5.7.23
## Check older mysql version
#ln -s /usr/local/Cellar/mysql@5.7/5.7.23/bin/mysql /usr/local/bin/mysql
## Or using the mysql command
#mysql --version

## nginx
#Docroot is: /usr/local/var/www
#The default port has been set in /usr/local/etc/nginx/nginx.conf to 8080 so that
#nginx can run without sudo.
#nginx will load all files in /usr/local/etc/nginx/servers/.
#To have launchd start nginx now and restart at login:  brew services start nginx
#Or, if you don't want/need a background service you can just run: nginx


# other software
brew install mycli
# How to replace Mac OS X utilities with GNU core utilities?
# https://apple.stackexchange.com/questions/69223/how-to-replace-mac-os-x-utilities-with-gnu-core-utilities
# https://liyang85.com/install-gnu-utilities-on-macos
# 如果不启用--with-default-names，安装的工具会被添加g前缀，使用的时候就是gsed、gfind、gtar，查看帮助文件就是man gsed
# replace mac default sed
brew install gnu-sed --with-default-names 
brew install coreutils findutils gnu-tar gnu-sed gawk gnutls gnu-indent gnu-getopt grep --with-default-names 
brew cask install xmind calibre virtualbox alfred
# Devices > Optical Drivers > Choose disk image > /Applications/VirtualBox.app/Contents/MacOS/VBoxGuestAdditions.iso

# Visual Studio Code (vscode)
# Customize shortcut:
# 1. "Control space" -> "Shift space"
# 2. "duplicate selection" -> "command+D"
# 3. use CMD+[1-9] to switch between tabs: Code > Preferences > Keyboard Shortcuts > keybindings.json add line in https://stackoverflow.com/a/46087295/1086907
#    https://stackoverflow.com/questions/39245966/vs-code-possible-to-switch-tabs-files-with-cmdnumbers/41112036
# File->Open Recent->Reopen Closed Editor: `Ctrl+Shift+T`
# add to PATH environment: `command palette -> shell command install`
#### VScode Plugin
# [VSCodeVim](https://github.com/VSCodeVim/Vim) config with [Input Method](https://github.com/VSCodeVim/Vim#input-method)


# atom
# Generate TOC (table of contents) of headlines from parsed markdown file. https://atom.io/packages/markdown-toc
#apm install markdown-toc 

# docker
brew cask install docker
# docker tool for mac
#brew install docker docker-compose docker-machine xhyve docker-machine-driver-xhyve

# config for docker for mac
# Docker for mac icon -> Perferences -> Daemon -> Registry mirros -> Add https://registry.docker-cn.com -> Apply & Restart
# check: docker info | grep -A 1 "Registry Mirrors"

## software
# sougou input method
# [Go2Shell](http://zipzapmac.com/Go2Shell): Opens a terminal window to the current directory in Finder: `open -a iTerm`
# [Scroll Reverser](https://pilotmoon.com/scrollreverser) is a free Mac app that reverses the direction of scrolling
# [Fantastical Calendar](https://flexibits.com/fantastical)
# [jd-GUI](http://jd.benow.ca)
# [SizeUp](http://www.irradiatedsoftware.com/sizeup/)
# [Better And Better](http://www.better365.cn/col.jsp?id=114):状态栏,键盘鼠标手势设置
# [Vanilla](https://matthewpalmer.net/vanilla/): Hide menu bar icons on your Mac
# [Open Web Monitor](http://openwebmonitor.netqon.com/)
# [kap: screen record to gif](https://getkap.co/)
# [IINA - The modern media player for macOS](https://iina.io/)
# [Airtest - UI Auto test]
# [SwitchHosts - hosts /etc/hosts switch]
# [Bagel is a little native iOS network debugger](https://github.com/yagiz/Bagel)

## Config
### Tap to click
# Preference -> Trackpad -> Point & Click -> Tap to click

### Enable dragging with three fingers
# Preference -> Accessibility -> Mouse & Trackpad -> Trackpad Options -> Enable dragging

### Shell jump word-wise left and right in iTerm2 with Alt+F/B
# Preferences(command+,) > Profiles > Keys -> set "Left Alt/Right Key" Esc+
# refer to https://blog.csdn.net/fungleo/article/details/78055768
#### Preferences(command+,) > Profiles > Keys -> Click the plus -> add (Alt+F, send escape sequence, f) and (Alt+B, send escape sequence, b)
#### refer to https://apple.stackexchange.com/questions/154292/iterm-going-one-word-backwards-and-forwards
## Open new tabs in iTerm in the current directory
# Preference -> General -> Wroking Directory -> Reuse previous session's directory

### Open file with default application 
# Command+I or right (or control) click a file of the type you want to change and:
# "Get Info" -> "Open with:" -> (Select TextMate) -> "Change All"

### Write to Windows NTFS USB Disk Drives on macOS Mojave and Sierra with FUSE for macOS
reference: https://coolestguidesontheplanet.com/how-to-write-to-windows-ntfs-external-disk-drives-on-macos-mojave-and-sierra/
		   https://www.howtogeek.com/236055/how-to-write-to-ntfs-drives-on-a-mac/
1. Disable SIP(System Integrity Protection) 
1.1 Reboot Mac into Recovery Mode by rebooting and holding down Command+R
1.2 Utilities -> Terminal
1.3 run command: csrutil disable
1.4 Reboot – (to enable it back after you finish the process)
2. Install FUSE for macOS https://osxfuse.github.io/
3. Install ntfs-3g
brew install ntfs-3g
sudo mv /sbin/mount_ntfs /sbin/mount_ntfs.orig
sudo ln -s /usr/local/sbin/mount_ntfs /sbin/mount_ntfs
4. Reboot and re-enable SIP with command: csrutil enable
5. Check status: csrutil status

## brew command
# brew install default location: /usr/local/Cellar
# brew search <package_name>      # 搜索
# brew install <package_name>     # 安装一个软件
# brew update                     # 从服务器上拉取，并更新本地 brew 的包目录
# brew upgrade <package_name>     # 更新软件
# brew outdated                   # 查看你的软件中哪些有新版本可用
# brew cleanup                    # 清理老版本。使用 `-n` 参数，不会真正执行，只是打印出真正运行时会做什么。
# brew list --versions            # 查看你安装过的包列表（包括版本号）
# brew link <package_name>        # 将软件的当前最新版本软链到`/usr/local`目录下
# brew unlink <package_name>      # 将软件在`/usr/local`目录下的软链接删除。
# brew info                       # 显示软件的信息 
# brew deps                       # 显示包依赖
# brew services start <package_name>	# 设置自启动
# check software info from brew: brew info mysql
# install with brew: brew install tig autojump
# search with brew cask: brew cask search chrome
# install with brew cask: brew cask install atom google-chrome
# startup with brew: brew services start nginx
# brew switch another version: brew switch python 3.6.5_1
# brew uninstall <package_name>  

## issues

### dyld: Library not loaded: /usr/local/opt/readline/lib/libreadline.7.dylib

1. find readline version: `brew info readline`
2. switch to the version above: `brew switch readline 8.0.0`


