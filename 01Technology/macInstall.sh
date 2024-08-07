# install package
# refer to [高效程序员的MacBook工作环境配置](https://cloud.tencent.com/developer/article/1046070)
# automator [给MAC应用设置系统热键(快捷键)启动](https://www.jianshu.com/p/b83f54888ff9)
# TODO:

# firefox 56.0.2 https://sourceforge.net/projects/ubuntuzilla/files/mozilla/apt/pool/main/f/firefox-mozilla-build/
# https://ftp.mozilla.org/pub/firefox/releases/56.0.2/

## zsh profile
# https://stackoverflow.com/questions/26252591/mac-os-x-and-multiple-java-versions
# Installation of the JDK on macOS
# https://docs.oracle.com/en/java/javase/17/install/installation-jdk-macos.html#GUID-2FE451B0-9572-4E38-A1A5-568B77B146DE
# java path: /Library/Java/JavaVirtualMachines/
#
# to list all installed jdk /usr/libexec/java_home -V
# man java_home
# 
# https://stackoverflow.com/questions/24342886/how-to-install-java-8-on-mac
# /Library/Java/JavaVirtualMachines/adoptopenjdk-8.jdk/Contents/Home
# 
# $HOME/Library/Java/JavaVirtualMachines/openjdk-19.0.2-1/Contents/Home
brew tap adoptopenjdk/openjdk
brew install --cask adoptopenjdk8

echo "export JAVA_HOME=$(/usr/libexec/java_home -v1.8)" >> ~/.zsh.mac
echo "export JAVA_HOME=$(/usr/libexec/java_home -v17)" >> ~/.zsh.mac

echo "#default java8" >> ~/.zsh.mac
echo "export JAVA_HOME=$JAVA_8_HOME" >> ~/.zsh.mac

# brew
# Homebrew / Linuxbrew 镜像使用帮助 https://mirrors.tuna.tsinghua.edu.cn/help/homebrew/
# setting the origin remote:
git -C "/usr/local/Homebrew/Library/Taps/homebrew/homebrew-core" remote set-url origin https://github.com/Homebrew/homebrew-core
# 国内 Mac 安装 Homebrew 可能会跳的坑一览 https://zhuanlan.zhihu.com/p/383707713
# tar: Error opening archive: Failed to open when upgrade using brew https://apple.stackexchange.com/questions/424091/tar-error-opening-archive-failed-to-open-when-upgrade-using-brew
# 替换homebrew-bottles  ~/.zshrc：
# Homebrew-bottles 镜像使用帮助 https://mirrors.tuna.tsinghua.edu.cn/help/homebrew-bottles/
# echo 'export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles' >> ~/.zshrc
export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles

# echo $SHELL
# zsh check version
# zsh --version
# chsh -s $(which zsh)
brew install zsh-completions
# oh my zsh https://github.com/ohmyzsh/ohmyzsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
# or sh -c "$(curl -fsSL https://gitee.com/mirrors/oh-my-zsh/raw/master/tools/install.sh)"
# sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="alanpeabody"/' ~/.zshrc
# sed -i 's/# DISABLE_AUTO_TITLE="true"/DISABLE_AUTO_TITLE="true"/' ~/.zshrc
# sed -i 's/# ENABLE_CORRECTION="true"/ENABLE_CORRECTION="true"/' ~/.zshrc
# sed -i 's/# HYPHEN_INSENSITIVE="true"/HYPHEN_INSENSITIVE="true"/' ~/.zshrc
# sed -i 's/# ENABLE_CORRECTION="true"/ENABLE_CORRECTION="true"/' ~/.zshrc
# Manual Updates with: omz update
## Disable 'Would you like to check for updates' prompt: add DISABLE_AUTO_UPDATE="true" on your .zshrc before the source $ZSH/oh-my-zsh.sh line
# git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
# source ~/.zshrc
brew install google-chrome

# brew install maven
# brew install python@3.11
# export PATH="$(brew --prefix)/opt/python@3.11/libexec/bin:$PATH"

# Install and Set Up kubectl on macOS
# https://kubernetes.io/docs/tasks/tools/install-kubectl-macos/#install-with-homebrew-on-macos
# download a specific version: curl -LO "https://dl.k8s.io/release/v1.16.6/bin/darwin/amd64/kubectl"
# Notice the server and client version: kubectl version
# kubectl version --client
brew install kubectl kubectx kube-ps1 stern

# common software install begin
# autojump jq
#
# autojump
# Add the following line to your ~/.bash_profile or ~/.zshrc file:
#  [ -f /opt/homebrew/etc/profile.d/autojump.sh ] && . /opt/homebrew/etc/profile.d/autojump.sh
#
# jless https://jless.io/user-guide.html
# jless can read files directly, or read JSON data from standard input 
brew install telnet htop ncdu bat jless autojump jq
brew install mycli

# How to replace Mac OS X utilities with GNU core utilities?
# https://apple.stackexchange.com/questions/69223/how-to-replace-mac-os-x-utilities-with-gnu-core-utilities
# https://liyang85.com/install-gnu-utilities-on-macos
# 如果不启用--with-default-names，安装的工具会被添加g前缀，使用的时候就是gsed、gfind、gtar，查看帮助文件就是man gsed
# replace mac default sed
# --with-default-names was removed https://discourse.brew.sh/t/why-was-with-default-names-removed/4405/17
# coreutils include gdate
brew install grep coreutils findutils gawk gnu-tar gnu-sed
brew install gnutls gnu-indent gnu-getopt

# All commands have been installed with the prefix "g".
# If you need to use these commands with their normal names, you
# can add a "gnubin" directory to your PATH from your bashrc like:
#   PATH="/opt/homebrew/opt/grep/libexec/gnubin:$PATH"
sudo mkdir -p /usr/local/gnubin/
for gnuutil in /opt/homebrew/opt/*/libexec/gnubin/*; do
    sudo ln -sfn $gnuutil /usr/local/gnubin
done
echo "Add /usr/local/gnubin to /etc/paths"
PATH="/usr/local/gnubin:$PATH"
# TODO MANPATH
# Additionally, you can access their man pages with normal names if you add
# the "gnuman" directory to your MANPATH from your bashrc as well:
# MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"
BREW_OPT="$(brew --prefix)/opt"
BREW_MAN="libexec/gnuman"
# MANPATH="$BREW_OPT/grep/$BREW_MAN:${MANPATH-/usr/share/man}"
MANPATH="$BREW_OPT/grep/$BREW_MAN:$BREW_OPT/coreutils/$BREW_MAN:$BREW_OPT/findutils/$BREW_MAN:$BREW_OPT/gawk/$BREW_MAN:$BREW_OPT/gnu-tar/$BREW_MAN:$BREW_OPT/gnu-sed/$BREW_MAN:$BREW_MAN:$BREW_OPT/gnu-indent/$BREW_MAN:${MANPATH-/usr/share/man}"

### karabiner-elements ⌘ ⇧
##keyboard mapping https://karabiner-elements.pqrs.org/docs/
## refer https://v2ex.com/t/565667 短按左 Shift ⇧（英文快捷键) , 短按右 Shift ⇧（中文快捷键）
## 配置文件放到~/.config/karabiner/assets/complex_modifications目录下
## Complex modifications > rules > Add rule > 共四个 "短按 Shift", "Control 空格"
## Complex modifications > parameters > to_if_alone_timeout_millisenconds 500, to_if_held_down_threshold_milliseconds 100
#
### Alfred
# Troubleshooting File Indexing Issues https://www.alfredapp.com/help/troubleshooting/indexing/
# how can I filter out unwanted search results in Alfred (ie node_modules folder, caches)
# https://apple.stackexchange.com/questions/310443/how-can-i-filter-out-unwanted-search-results-in-alfred-ie-node-modules-folder
# Go to Preferences -> Spotlight -> Privacy (TAB) Then add the folders you want to exclude to that list.
# 
# Sync Alfred preferences 
# [Disabling Sync Folder - Alfred Help and Support](https://www.alfredapp.com/help/advanced/sync/disable-sync/)
# ln -s $HOME/.config/Alfred.alfredpreferences $HOME/Library/"Application Support"/Alfred/Alfred.alfredpreferences
#
### Maccy: Lightweight clipboard manager for macOS
brew install --cask alfred karabiner-elements maccy

### VirtualBox
## Devices > Optical Drivers > Choose disk image > /Applications/VirtualBox.app/Contents/MacOS/VBoxGuestAdditions.iso
brew install calibre xmind virtualbox postman broot

# develop software install
# download from mysql official website mysql-5.7.23-macos10.13-x86_64.tar.gz
#brew install mysql
#brew services start mysql
#mysql_secure_installation
#mysql -u root -proot
#
#brew install mysqlworkbench
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
#
## mysql client mycli
brew install mycli
#brew install node

## nginx
#Docroot is: /usr/local/var/www
#The default port has been set in /usr/local/etc/nginx/nginx.conf to 8080 so that
#nginx can run without sudo.
#nginx will load all files in /usr/local/etc/nginx/servers/.
#To have launchd start nginx now and restart at login:  brew services start nginx
#Or, if you don't want/need a background service you can just run: nginx

# Visual Studio Code (vscode)
## Setting for IntelliSense https://code.visualstudio.com/docs/editor/intellisense
# Tab Completion: By default, tab completion is disabled. Use the editor.tabCompletion setting to enable it
#
## Customize shortcut:
# 1. Trigger Support: "Control space" -> "Shift space"
# 2. "duplicate selection" -> "command+D"
# 3. use CMD+[1-9] to switch between tabs: Code > Preferences > Keyboard Shortcuts > keybindings.json add line in https://stackoverflow.com/a/46087295/1086907
#    https://stackoverflow.com/questions/39245966/vs-code-possible-to-switch-tabs-files-with-cmdnumbers/41112036
#
# File->Open Recent->Reopen Closed Editor: `Ctrl+Shift+T`
# add to PATH environment: `command palette -> shell command install`
#

# iTerm2
# shortcut Alt+I Perference -> keys -> Hotkey -> Show/hide all windows with a system-wide hotkey
#
# Open iTerm external
# User Setting: Command+Shift+P
#"terminal.external.osxExec": "iTerm.app",
#"terminal.integrated.fontFamily": "Monaco",
#"terminal.explorerKind": "external",
# Defalut shortcut is @command:workbench.action.terminal.openNativeConsole Command+Shift+c, replace to Command+Shift+I

# shortcut Ctrl+Shift+I
#
#### VScode Plugin
# [VSCodeVim](https://github.com/VSCodeVim/Vim) config with [Input Method](https://github.com/VSCodeVim/Vim#input-method)
# change input method for VSCodeVim required im-select
# curl -Ls https://raw.githubusercontent.com/daipeihust/im-select/master/install_mac.sh | sh


# docker
brew install --cask docker
# docker tool for mac
#brew install docker docker-compose docker-machine xhyve docker-machine-driver-xhyve

# config for docker for mac
# Docker for mac icon -> Perferences -> Daemon -> Registry mirros -> Add https://registry.docker-cn.com -> Apply & Restart
# check: docker info | grep -A 1 "Registry Mirrors"

# ali oss config
ln -sfn ~/.config/ossutil/.ossutilconfig ~/.ossutilconfig

# Creating root-level directories and symbolic links on macOS Catalina
# https://derflounder.wordpress.com/2020/01/18/creating-root-level-directories-and-symbolic-links-on-macos-catalina/
# https://apple.stackexchange.com/questions/388236/unable-to-create-folder-in-root-of-macintosh-hd
# create the file /etc/synthetic.conf, which should be owned by root and group wheel with permissions 0644.
# TO create a /data link to $HOME/Documents/data
# OR call a shell with ~/.script/mac.create.folder.under.root.sh
copy ~/.config/etc/synthetic.conf /etc/synthetic.conf
chmod 0644 /etc/synthetic.conf

## software
# sougou input method
# [Go2Shell](http://zipzapmac.com/Go2Shell): Opens a terminal window to the current directory in Finder: `open -a iTerm`
# [Mos](https://mos.caldis.me/) set scroll direction independently for your mouse
# [Fantastical Calendar](https://flexibits.com/fantastical)
# [jd-GUI](http://jd.benow.ca) 
#    export JAVA_HOME=$(/usr/libexec/java_home -v1.8) in /Applications/JD-GUI.app/Contents/MacOS/universalJavaApplicationStub.sh  
# [SizeUp](http://www.irradiatedsoftware.com/sizeup/)
# [Better And Better](http://www.better365.cn/col.jsp?id=114):状态栏,键盘鼠标手势设置
# [Vanilla](https://matthewpalmer.net/vanilla/): Hide menu bar icons on your Mac, Command+drag; start with open -a /Applications/Vanilla.app in a script ~/.script/mac_startup.sh
# [Open Web Monitor](http://openwebmonitor.netqon.com/)
# [kap: screen record to gif](https://getkap.co/)
# [IINA - The modern media player for macOS](https://iina.io/)
# [Airtest - UI Auto test]
# [SwitchHosts - hosts /etc/hosts switch]
# [Bagel is a little native iOS network debugger](https://github.com/yagiz/Bagel)
# NewFileMenuFree
# Maccy: Lightweight clipboard manager for macOS
# [Broot](https://dystroy.org/broot/) Get an overview of a directory
# [Microsoft Remote Desktop Beta - App Center](https://install.appcenter.ms/orgs/rdmacios-k2vy/apps/microsoft-remote-desktop-for-mac/distribution_groups/all-users-of-microsoft-remote-desktop-for-mac)

## Config
### Tap to click
# Preference -> Trackpad -> Point & Click -> Tap to click

### Enable dragging with three fingers
# Preference > Accessibility > Pointer Control > Trackpad Options > Turn on “Use trackpad for dragging” > dragging style “three finger drag” 

### Turn the Mac startup sound on or off
# Choose Apple menu  > System Settings > Click Sound in the sidebar > Turn “Play sound on startup” on or off.

### Login Item with startup.sh
# Make startup.sh open with console
# Preference > Users & Gruops > Login Items > add '~/.script/mac_startup.sh'

## iTerm2 profile backup
### Shell jump word-wise left and right in iTerm2 with Alt+F/B
# Preferences(command+,) > Profiles > Keys -> set "Left Alt/Right Key" Esc+
# refer to https://blog.csdn.net/fungleo/article/details/78055768
#### Preferences(command+,) > Profiles > Keys -> Click the plus -> add (Alt+F, send escape sequence, f) and (Alt+B, send escape sequence, b)
#### refer to https://apple.stackexchange.com/questions/154292/iterm-going-one-word-backwards-and-forwards
## Open new tabs in iTerm in the current directory
# Preference -> General -> Wroking Directory -> Reuse previous session's directory
## Launching iTerm2 from macOS Finder https://gist.github.com/pdanford/158d74e2026f393e953ed43ff8168ec1

### Open file with default application
# Command+I or right (or control) click a file of the type you want to change and:
# "Get Info" -> "Open with:" -> (Select TextMate) -> "Change All"

### Disable/change shortcut
# Open Apple menu | System Preferences | Keyboard | Shortcuts | Services
# uncheck Search man Page Index in Terminal: Command+Shift+A
# uncheck Make New Sticky Note
#
### showing FN keys on touchbar
# System preferences -> Keyboard -> Shortcuts -> Functions keys
# Click the + icon
# For JetBrains products: CMD+SHIFT+G to open up a path window. Enter: ~/Library/Application Support/JetBrains/Toolbox/apps


### Mac with NTFS
# Big Sur
    # https://apple.stackexchange.com/a/426887/364260
    # https://shivang-iitk.medium.com/ntfs-write-in-macos-bigsur-using-osxfuse-and-ntfs-3g-3f3253ba2365
    # 无法再启用SSV机制，但是可以启用SIP机制，因为系统已修改，导致签名不一致，若启用SSV，则校验失败，报错禁止启动。
    # csrutil enable
    # csrutil authenticated-root disable
    # https://eclecticlight.co/2020/06/25/big-surs-signed-system-volume-added-security-protection/
#Mojave and Sierra
    # Write to Windows NTFS USB Disk Drives on macOS Mojave and Sierra with FUSE for macOS
    # https://coolestguidesontheplanet.com/how-to-write-to-windows-ntfs-external-disk-drives-on-macos-mojave-and-sierra/
    # https://www.howtogeek.com/236055/how-to-write-to-ntfs-drives-on-a-mac/

# Try NTFS Tool https://github.com/ntfstool/ntfstool

# 格式化为exfat格式 windows cmd: format e: /fs:exfat /q
# The best file formats supported on Mac and Windows are exFAT and FAT32

1. Disable SIP(System Integrity Protection)
1.1 Reboot Mac into Recovery Mode by rebooting and holding down Command+R
1.2 Utilities -> Terminal
1.3 run command: csrutil disable
# check impact for authenticated-root disable
# It cannot be enable after editing /sbin/mount_ntfs
csrutil authenticated-root disable
1.4 Reboot – (to enable it back after you finish the process)
2. Install FUSE for macOS https://osxfuse.github.io/
3. Install ntfs-3g
# https://apple.stackexchange.com/questions/422521/cant-install-ntfs-3g-on-macos-bigsur
# https://github.com/gromgit/homebrew-fuse
brew install gromgit/fuse/ntfs-3g-mac

4. Update /sbin/mount_ntfs
# ll /sbin/mount_ntfs
# lrwxr-xr-x 1 root 65 Jan  1  2020 /sbin/mount_ntfs -> /System/Library/Filesystems/ntfs.fs/Contents/Resources/mount_ntfs
# Find your root mount's device - run mount and chop off the last s, e.g. if your root is /dev/disk2s5s1, you'll mount /dev/disk2s5
#  mount
# /dev/disk2s5s1 on / (apfs, sealed, local, read-only, journaled)
DISK_PATH=/dev/disk2s5
MOUNT_PATH=~/mount
mkdir $MOUNT_PATH
sudo mount -o nobrowse -t apfs $DISK_PATH $MOUNT_PATH
sudo mv $MOUNT_PATH/sbin/mount_ntfs $MOUNT_PATH/sbin/mount_ntfs.original
sudo ln -s /usr/local/sbin/mount_ntfs $MOUNT_PATH/sbin/mount_ntfs
# sudo mv /sbin/mount_ntfs /sbin/mount_ntfs.original
# sudo ln -s /usr/local/sbin/mount_ntfs /sbin/mount_ntfs
sudo bless --folder $MOUNT_PATH/System/Library/CoreServices --bootefi --create-snapshot

5. Reboot and re-enable SIP with command: csrutil enable
6. Check status: csrutil status
