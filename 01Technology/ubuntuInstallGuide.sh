#Install Ubuntu
#1、引导分区: /boot	256M for personal; 512M for server; try 1G
#2、交换分区: swap	8G 8192M virtual memory
#3、系统分区: / 　　　装系统和软件 27G
#4、个人文件分区：/home　你想多大就多大，类似windows的“我的文档” 35G

## Windows install Ubuntu with EasyBCD from local drive with iso image (硬盘安装 Ubuntu 双系统)
## 1. copy ubuntu.iso/casper/{vmlinuz(.efi),initrd.lz} to C:/
## 2. install EasyBCD -> Add New Entry -> NeoGrub -> Install -> Configure -> Put following lines in menu.lst with the text editor (添加新条目-neogrub-安装-配置)
#title Ubuntu Live CD to install Ubuntu
#root (hd0,0)
#kernel (hd0,0)/vmlinuz boot=casper iso->scan/filename=(hd0,0)/ubuntu-14.04.2-desktop-i386.iso ro quiet >splash locale=en_US.UTF-8
#initrd (hd0,0)/initrd.lz

title Ubuntu Live CD to install Ubuntu
root (hd0,0)
kernel (hd0,0)/vmlinuz.efi boot=casper iso-scan/filename=(hd0,0)/ubuntu-16.04.1-desktop-amd64.iso ro quiet splash locale=en_US.UTF-8
initrd (hd0,0)/initrd.lz

title Ubuntu Live CD to install Ubuntu 16.04
root (hd0,0)
kernel /vmlinuz.efi boot=casper iso-scan/filename=/ubuntu-16.04.3-desktop-amd64.iso ro quiet splash ignore_uuid locale=en_US.UTF-8
initrd /initrd.lz

## 3. restart system with "Ubuntu Live CD to install Ubuntu"
## 4. sudo umount -l /isodevice
## 5. Click "Install ubuntu"
## 6. After install completed, set waiting time for OS 解决Ubuntu 14.04 grub选择启动项10秒等待时间
#sudo vi /etc/default/grub
#update seconds: GRUB_HIDDEN_TIMEOUT=1
#sudo update-grub


# dpkg -i AdbeRdr*.deb	# install
## installed programs: /usr/share/applications/ or ~/.local/share/applications
## make it available in "Open with other Application" add %f at the end of line "Exec=command" in /usr/share/applications/pdfedit.desktop
## apt-get 下载后，软件所在路径是 /var/cache/apt/archives or /var/cache/

## dpkg -S packageName     #显示所有包含该软件包的目录
# apt show maven (apt-cache policy maven)	check the version of package from apt-get
# apt-get-install package-name=version	# install specified version of package
# apt-cache search # ------(package 搜索包)

## dpkg --get-selections # List all package installed
# sudo apt list --installed
# sudo dpkg -l

## uninstall (even install with .debi package from local)
# sudo apt-get remove <package> && sudo apt-get autoremove
# sudo apt-get purge <package>

## add the Apt repository to your Apt source list directory (/etc/apt/sources.list.d) 
# echo "deb https://dl.bintray.com/rabbitmq/debian {distribution} main" | sudo tee /etc/apt/sources.list.d/bintray.rabbitmq.list
# for Ubuntu 16.04, the distribution will be xenial like below
# echo "deb https://dl.bintray.com/rabbitmq/debian xenial main" | sudo tee /etc/apt/sources.list.d/bintray.rabbitmq.list

# update the package lists /etc/apt/sources.list from repositories
# following  to update http://wiki.ubuntu.org.cn/源列表
# mirrors.aliyun.com is the fast
sudo apt-get update # This is very important step to update system first.

## In Ubuntu, /bin/sh is link to Dash default. Change it to /bin/bash
# sudo dpkg-reconfigure dash

## auto mount your NTFS disk: Install pysdm or ntfs-config for Ubuntu 14.04
# vi /etc/fstab
# /dev/sda5 /media/<username>/works            ntfs    defaults,utf8,uid=1000,gid=1000,dmask=022,fmask=033,exec              0       0

########## GVim config: clone configuration files from stash ##########
##sudo apt-get -y install vim-gnome

## get customized vim configuration file .vimrc
# wget --no-check-certificate -O ~/.vimrc https://raw.githubusercontent.com/petergithub/configuration/master/.vimrc

## update configuration to make cut/copy/paste like Windows
#cp /usr/share/vim/vim74/vimrc_example.vim .vimrc
#echo "source \$VIMRUNTIME/mswin.vim" >> .vimrc
#echo "behave mswin" >> .vimrc

## place the backup file into tmp
#echo "set backupdir=/tmp,." >> .vimrc
#echo "set directory=/tmp,." >> .vimrc
##" set encoding
#echo "set termencoding=utf-8" >> .vimrc
#echo "set encoding=utf-8" >> .vimrc
#echo "set fileencoding=utf-8" >> .vimrc
#echo "set fileencodings=ucs-bom,utf-8,cp936,gb18030,big5,euc-jp,euc-kr,latin1" >> .vimrc


# :w !sudo tee % ##saving file as sudo when forgot to start vim using sudo
#echo "command W w !sudo tee % > /dev/null" >> .vimrc	## take W as a shortcut
## gvim fileName # open file with gvim
## update default editor from nano to vim when less/more
#echo 'export EDITOR=vim' >> ~/.bashp

## Make configuration effective
echo ". ~/.bashp" >> ~/.bashrc
#echo ". ~/.bashwork" >> ~/.bashrc
source ~/.bashrc
########## GVim config END ##########

########## tools BEGIN ##########
#sudo apt-get -y install nautilus-open-terminal # open terminal here
## $ nautilus . # open folder here
# open folder with root permission
sudo apt-add-repository ppa:upubuntu-com/ppa
sudo apt-get update

## gdebi lets you install local deb packages resolving and installing its dependencies
sudo apt-get -y install gdebi ncdu xclip
#sudo apt-get -y install nautilus-gksu
#nautilus -q

## firefox
# https://sourceforge.net/projects/ubuntuzilla/files/mozilla/apt/pool/main/f/firefox-mozilla-build/
# https://ftp.mozilla.org/pub/firefox/releases/56.0.2/
## flashplugin-nonfree: flash plugin for firefox
## autokey-gtk: quick paste tool
sudo apt-get -y install p7zip p7zip-full p7zip-rar unrar autokey-gtk trash-cli adobe-flashplugin flashplugin-nonfree
#echo del='trash-put' >> ~/.bashp

## put shortcut
mkdir bin
#echo export PATH=.:~/bin:\$PATH >> ~/.bashp
#echo "Download .bashp from https://github.com/petergithub/configuration/blob/master/.bashp"

sudo mkdir /data && sudo chmod 1777 /data  # sudo chmod o+t /data
########## tools END ##########

########## development tools BEGIN ##########
# atom 32 bit installation
sudo add-apt-repository -y ppa:webupd8team/atom
sudo apt-get update
apm install auto-encoding convert-file-encoding open-path open-recent

# Performance Monitoring Tools: sysstat include sar
sudo apt-get -y install git tig curl tmux maven traceroute python-pip sysstat dstat wireshark atom
git config --global core.quotepath false
sudo adduser $USER wireshark

## update hosts
mkdir -p ~/work/ubuntuGitWorkspace/peter; cd ~/work/ubuntuGitWorkspace/peter; git clone https://github.com/racaljk/hosts.git

## configuration file setup, CLEAN THE FOLDER AFTER DOWNLOAD
cd ~; git clone https://github.com/petergithub/configuration.git

## cheat for command
## pip install --install-option="--prefix=/path/to/install" package_name
sudo pip install docopt pygments
git clone https://github.com/chrisallenlane/cheat.git && cd cheat && sudo python setup.py install
cheat -v && cd .. && rm -r cheat

# tcpdump preparation
# Reference: https://ubuntuforums.org/showthread.php?t=1501339
(sudo grep tcpdump /sys/kernel/security/apparmor/profiles | grep enforce) && sudo apt-get -y install apparmor-utils && sudo aa-complain /usr/sbin/tcpdump && (sudo grep tcpdump /sys/kernel/security/apparmor/profiles | grep complain) && echo setup for tcpdump

sudo pip install shadowsocks

########## development tools END ##########

########## wine BEGIN ##########
## https://wiki.winehq.org/Ubuntu
## winecfg: wine configuration
sudo dpkg --add-architecture i386  # check by dpkg --print-foreign-architectures
## if missing PUBKEY add then sudo apt-get update
sudo apt-get -y install --install-recommends winehq-staging
## 64位系统出错，安装libgtk2.0即可
sudo apt -y install libgtk2.0-0:i386 lib32z1 lib32ncurses5
# install mfc42.dll to start windows application
sudo apt-get -y install winetricks
winetricks mfc42
########## wine END ##########

#install JDK, oracle JDK is no longer provided as a PPA source
#https://www.digitalocean.com/community/tutorials/how-to-install-java-on-ubuntu-with-apt-get
sudo apt-get -y install python-software-properties
sudo add-apt-repository ppa:webupd8team/java
sudo apt-get update
sudo apt-get -y install oracle-java7-installer
#sudo apt-get -y install oracle-java8-installer
#sudo apt-get -y install oracle-java9-installer
sudo mkdir -p ~/opt/
ln -s /usr/lib/jvm/java-8-oracle ~/opt/java-8-oracle
ln -s ~/opt/java-8-oracle ~/opt/java

## Workaround for Not Found Error 404 when installing oracle-java9-installer
cd /var/lib/dpkg/info
sudo sed -i 's|SHA256SUM_TGZ="2ef49c97ddcd5e0de20226eea4cca7b0d7de63ddec80eff8291513f6474ca0dc"|SHA256SUM_TGZ="1c6d783a54fcc0673ed1f8c5e8650b1d8977ca3e856a03fba0090198e0f16f6d"|' oracle-java9-installer.*
sudo sed -i 's|JAVA_VERSION_MINOR=181|JAVA_VERSION_MINOR=181|' oracle-java9-installer.*
sudo sed -i 's|FILENAME=jdk-${JAVA_VERSION_MAJOR}+${JAVA_VERSION_MINOR}_linux-${dld}_bin.tar.gz|FILENAME=jdk-${JAVA_VERSION_MAJOR}_linux-${dld}_bin.tar.gz|' oracle-java9-installer.*
sudo sed -i 's|PARTNER_URL=http://download.java.net/java/jdk${JAVA_VERSION_MAJOR}/archive/${JAVA_VERSION_MINOR}/binaries/$FILENAME|PARTNER_URL=http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION_MAJOR}+${JAVA_VERSION_MINOR}/$FILENAME|' oracle-java9-installer.*


## Managing Java
## Listing all java installed version
#sudo update-alternatives --config java
#sudo update-alternatives --config javac
## Add new
#sudo update-alternatives --install /usr/bin/java java /path/to/jdk1.6.0_26/bin/java 300  
#sudo update-alternatives --install /usr/bin/javac javac /path/to/jdk1.6.0_26/bin/javac 300 

###### Setting JAVA_HOME environemnt variable #######
#$ echo $JAVA_HOME
#//show nothing
#vim ~/.bashrc add lines or using >>
#echo export JAVA_HOME=~/opt/java >> ~/.bashp
#echo export PATH=.:\$JAVA_HOME/bin:\$PATH >> ~/.bashp
#echo export CLASSPATH=.:\$JAVA_HOME/lib:\$CLASSPATH >> ~/.bashp
##restart terminal or source ~/.bashrc or . ~/.bashrc

sudo echo export JAVA_HOME=/home/$USER/opt/java >> /etc/profile
source ~/.bashrc

##install MySQL http://wiki.ubuntu.org.cn/MySQL
sudo apt-get -y install mysql-server-5.7
#sudo start mysql #手动的话这样启动
# sudo service mysql start
#sudo stop mysql #手动停止
##enter MySQL
#mysql -uroot -p
##update admin password
#sudo mysqladmin -uroot password newpassword
## configuration file /etc/mysql/my.cnf
## install GUI client
## sudo apt-get -y install mysql-workbench #version is not the latest

## install Nginx
sudo add-apt-repository -y ppa:nginx/stable
sudo apt-get update
sudo apt-get -y install nginx

## perf https://github.com/brendangregg/perf-tools
sudo apt install linux-tools-common gawk

##check the architecture of containers binaries
#file /bin/bash

##add Advanced settings设置
#sudo apt-get install gnome-system-tool
#sudo apt-get install gnome-tweak-tool
sudo apt-get -y install unity-tweak-tool
#sudo apt-get install ccsm # Ubuntu 14.04

# Disable ctrl+alt+down in Ubuntu 16.04 (make it availabel in eclipse)
sudo apt install -y compizconfig-settings-manager
## Dash->CompizConfig Settings Manager->Desktop->Desktop Wall->Bindings->disable Moving down/up

###### Chinese input #######
sudo apt install fcitx-googlepinyin
## sudo apt-get install fcitx-table-wbpy ## install Chinese input

## download from http://pinyin.sogou.com/linux/ and config Ctrl + space for sogou
## 0. dpkg -i sogou.deb
## 1. System Settings -> Language Support -> Keyboard input method system: fcitx -> Restart ubuntu
## 1.1. Dash -> Fcitx Configuration -> click + at the left corner -> add Sogou Pinyin
## 2. System Settings -> Keyboard -> Text Entry -> Switch to next source using: empty
## 3. Dash -> Fcitx Configuration -> Global Config
## 4. Disable "Spell Hint": Dash -> Fcitx Configuration -> Double click "Keyboard-English" -> "Toggle the word hint" field uses "Ctrl+Alt+H" -> hit "Esc" -> OK
## 5. Disable "C-semicolon": Dash -> Fcitx Configuration -> Tab "Addon" -> Double click ClipBoard -> "Trigger key for ClipBoard history list" -> hit "Esc" -> OK

### wechat
sudo snap install electronic-wechat

### TM2013
#ln -sfn ~/.longene/tm2013/drive_c/Program\ Files/Tencent/tm2013/Users ~/Documents/Tencent.tm2013.Users

# Linux字体渲染
# 一条命令搞定Linux字体渲染——Ubuntu系发行版微软雅黑+宋体终极解决方案【原创推荐】 http://www.lulinux.com/archives/278

#最后动一下字体设置，我用的是(Autohinting->Always->No bitmaps），这个命令需要回答问题。
#sudo dpkg-reconfigure fontconfig-config
#sudo dpkg-reconfigure fontconfig
#退出重新登录，字体是不是清晰了很多？注意你浏览器地址栏里的“www“，斜线没有了毛边。


## install Adobe reader DEB package 32 or 64-bit
# nohup wget ftp://ftp.adobe.com/pub/adobe/reader/unix/9.x/9.5.5/enu/AdbeRdr9.5.5-1_i386linux_enu.deb &
#安装PDF阅读器－－Acrobat7.0
#虽然ubuntu自带的文档查看器可以看PDF，但有些PDF文件不太规范，从而导致乱码。这时就需要用官方的 Acrobat了，不过这个软件较大，启动也较慢。
sudo apt-get -y install acroread --force-yes -y
## To see the Acrobat reader option when you right-click on the file
sudo vi /usr/share/applications/AdobeReader.desktop
## Edit the Exec=acroread line to be Exec=acroread %U
## Edit -> Preferences -> Documents -> Restore last view settings when reopening documents

#再下载其中文语言包
#wget http://download.adobe.com/pub/adobe/reader/unix/7x/7.0.8/misc/FontPack708_chs_i386-linux.tar.gz
#tar zxvf FontPack708_chs_i386-linux.tar.gz
#解压后，运行其中的INSTALL
#sudo ./INSTALL
#我事先把FontPack708_chs_i386-linux.tar.gz解压到acrobat7_cn目录
sudo /var/cache/apt/archives/acrobat7_cn/INSTALL
#第一问题问你是否继续安装，直接回车；
#第二个问题问你是否接受协议，键入accept后回车；
#第三个问题要你定义Acrobat的安装目录，输入/usr/lib/Adobe/Acrobat7.0 or /opt/Adobe/Reader9 后回车。

########### gedit config
## Ubuntu gedit recent files dconf set max recents to something like 40
gsettings set org.gnome.gedit.preferences.ui max-recents "uint32 40"
## gedit add encoding for Chinese GB18030
gsettings set org.gnome.gedit.preferences.encodings auto-detected "['UTF-8', 'CURRENT', 'GB18030', 'ISO-8859-15', 'UTF-16']"
#gsettings set org.gnome.gedit.preferences.encodings auto-detected "['GB18030', 'GB2312', 'GBK', 'UTF-8', 'BIG5', 'CURRENT', 'UTF-16']"

# dconf-editor - Graphical editor for dconf
#sudo apt-get -y install dconf-editor
sudo apt-get -y install dconf-tools
#sudo apt-get -y install gconf-editor
#mkdir -p ~/.local/share/gedit/plugins
## plugin to restore tabs opened last time
## https://github.com/raelgc/gedit-restore-tabs

########### Disable auto-opening nautilus window after auto-mount USB
gsettings set org.gnome.desktop.media-handling automount-open false
#gsettings set org.gnome.desktop.media-handling automount false

## startup
# Dash -> startup -> add thunderbird, /usr/bin/autokey, atom, firefox, startup.sh

########### Linux Tools
## Calibre: calibre is a powerful and easy to use e-book manager.
## Binary install https://calibre-ebook.com/download_linux
sudo -v && wget -nv -O- https://download.calibre-ebook.com/linux-installer.py | sudo python -c "import sys; main=lambda:sys.stderr.write('Download failed\n'); exec(sys.stdin.read()); main()"

## Disable Desktop Notifications
sudo add-apt-repository -y ppa:vlijm/nonotifs
sudo apt-get update
sudo apt-get -y install nonotifs

## Chrome
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list
sudo apt-get update
sudo apt-get install google-chrome-stable

## CacheBrowser https://cachebrowser.info/#/download
#sudo apt-get -y install python-setuptools
#sudo apt-get -y install python-dev

## virtual box
## virtual box connect usb: host Ubuntu 16.04, guest WinXP
## 1. Add current user into group vboxusers, restart Ubuntu is required
## 2. Setting -> USB -> Enable USB Controller -> USB 2.0 or 3.0 depends on your USB type (Try each one by one)
## 3. Check device management if any driver required. (USB 3.0 driver is required for XP).
## 4. Add 
sudo adduser $USER vboxusers
## add user to group vboxsf
sudo usermod -a -G vboxsf $USER

## 安装ubuntu受限的额外的解码器
sudo apt-get -y install ubuntu-restricted-extras

## playonlinux
#sudo add-apt-repository -y ppa:noobslab/apps && sudo apt-get update
sudo apt-get install playonlinux

## Transmission 
## Transmission is a cross-platform BitTorrent client https://transmissionbt.com/about/

## Snap
sudo snap install <snap name> # To install a snap
sudo snap remove <snap name> # remove the snap
other command: list / find <text to search> / revert <snap name> / refresh <snap name> 

## init
# git
wget --no-check-certificate -O ~/.git-completion.bash https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash && echo >> ~/.bashrc && echo "if [ -f ~/.git-completion.bash ]; then . ~/.git-completion.bash; fi" >> ~/.bashrc && source ~/.bashrc

# vim config
wget --no-check-certificate -O ~/.vimrc https://raw.githubusercontent.com/petergithub/configuration/master/.vimrc

#如果必须要用源码包安装，请在安装的时候指定--prefix安装目录，另外安装的时候请使用
#configure --prefix=/path/to/target/opt;make;sudo make install 
#make PREFIX=/path/to/target >& make.log &
#make PREFIX=/path/to/target install >& make.install.log &
#用于保存安装信息日志，这样需要卸载的时候方便查看哪些文件安装在了系统目录中，例如/usr/lib下的库文件
#Install Ubuntu
#1、引导分区: /boot	256M for personal; 512M for server; try 1G
#2、交换分区: swap	8G 8192M virtual memory
#3、系统分区: / 　　　装系统和软件 27G

#rpm --install file.rpm
#rpm 查看安装的Mysql版本 `rpm -qa |grep -i mysql`
#卸载 `rpm -e MySQL-client-5.1.17-0.glibc23`

