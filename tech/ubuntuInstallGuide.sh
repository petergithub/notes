#Install Ubuntu
#1、引导分区: /boot	256M for personal; 512M for server
#2、交换分区: swap	2G virtual memory
#3、系统分区: / 　　　装系统和软件，我这里给力10G的空间
#4、个人文件分区：/home　你想多大就多大，类似windows的“我的文档” 13G

# Windows 10 install Ubuntu with EasyBCD 添加新条目-neogrub-安装-配置
#title Install Ubuntu
#root (hd0,0)
#kernel (hd0,0)/vmlinuz boot=casper iso->scan/filename=(hd0,0)/ubuntu-14.04.2-desktop-i386.iso ro quiet >splash locale=en_US.UTF-8
#initrd (hd0,0)/initrd.lz

# dpkg -i AdbeRdr*.deb	# install
## installed programs: /usr/share/applications/ or ~/.local/share/applications
## make it available in "Open with other Application" add %f at the end of line "Exec=command" in /usr/share/applications/pdfedit.desktop
## apt-get 下载后，软件所在路径是 /var/cache/apt/archives

## dpkg -S packageName     #显示所有包含该软件包的目录
# apt-cache policy maven	# check the version of package from apt-get
# apt-get-install package-name=version	# install specified version of package
# apt-cache search # ------(package 搜索包)

# update the package lists /etc/apt/sources.list from repositories
# following  to update http://wiki.ubuntu.org.cn/源列表
# mirrors.aliyun.com is the fast
sudo apt-get update # This is very important step to update system first.

########## Config GVim BEGIN ##########
sudo apt-get install vim-gnome
## update configuration to make cut/copy/paste like Windows
#cp /usr/share/vim/vim74/vimrc_example.vim .vimrc
#echo "source \$VIMRUNTIME/mswin.vim" >> .vimrc
#echo "behave mswin" >> .vimrc
## place the backup file into tmp
echo "set backupdir=/tmp,." >> .vimrc
echo "set directory=/tmp,." >> .vimrc
##" set encoding
echo "set termencoding=utf-8" >> .vimrc
echo "set encoding=utf-8" >> .vimrc
echo "set fileencoding=utf-8" >> .vimrc
echo "set fileencodings=ucs-bom,utf-8,cp936,gb18030,big5,euc-jp,euc-kr,latin1" >> .vimrc

# :w !sudo tee % ##saving file as sudo when forgot to start vim using sudo
echo "command W w !sudo tee % > /dev/null" >> .vimrc	## take W as a shortcut
## gvim fileName # open file with gvim
## update default editor from nano to vim when less/more
echo 'export EDITOR=vim' >> ~/.bash_profile
source ~/.bashrc
########## Config GVim END ##########

########## tools BEGIN ##########
sudo apt-get install nautilus-open-terminal # open terminal here
## $ nautilus . # open folder here
# open folder with root permission
sudo apt-add-repository ppa:upubuntu-com/ppa
sudo apt-get update
sudo apt-get install nautilus-gksu
nautilus -q
sudo apt-get install trash-cli
echo del='trash-put' >> ~/.bash_profile
sudo apt-get install fcitx-table-wbpy ## install Chinese input
#sudo apt-get install gconf-editor
# install flash plugin for firefox
#sudo apt-get install flashplugin-nonfree
sudo apt-get install autokey-gtk # quick paste tool
sudo apt-get -y install p7zip p7zip-full p7zip-rar

## put shortcut
mkdir bin
#echo export PATH=.:~/bin:\$PATH >> ~/.bash_profile
echo "Download .bash_profile from https://github.com/petergithub/configuration/blob/master/.bash_profile"
########## tools END ##########

########## development tools BEGIN ##########
sudo apt-get install git
sudo apt-get install tmux

## cheat for command
sudo apt-get install python-pip
sudo pip install docopt pygments
git clone https://github.com/chrisallenlane/cheat.git
cd cheat
sudo python setup.py install
cheat -v

# atom 32 bit installation
sudo add-apt-repository ppa:webupd8team/atom
sudo apt-get update
sudo apt-get install atom
########## development tools END ##########

########## wine BEGIN ##########
sudo add-apt-repository ppa:ubuntu-wine/ppa
sudo apt-get update
## if missing PUBKEY add then sudo apt-get update
# sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys PUBKEY
sudo apt-get install wine1.7
# install mfc42.dll to start windows application
winetricks mfc42
########## wine END ##########

#install JDK, oracle JDK is no longer provided as a PPA source
#https://www.digitalocean.com/community/tutorials/how-to-install-java-on-ubuntu-with-apt-get
sudo apt-get install python-software-properties
sudo add-apt-repository ppa:webupd8team/java
sudo apt-get update
#sudo apt-get install oracle-java7-installer
sudo apt-get install oracle-java8-installer
mkdir -p {/home/share,~/opt/java}
ln -s /usr/lib/jvm/java-8-oracle/ /home/share/java-8-oracle
ln -s /home/share/java-8-oracle ~/opt/java/jdk
sudo apt-get install maven

#Managing Java
#Listing all java installed version
#sudo update-alternatives --config java

###### Setting JAVA_HOME environemnt variable #######
#$ echo $JAVA_HOME
#//show nothing
#vim ~/.bashrc add lines or using >>
echo export JAVA_HOME=~/opt/java/jdk >> ~/.bash_profile
echo export PATH=.:\$JAVA_HOME/bin:\$PATH >> ~/.bash_profile
echo export CLASSPATH=.:\$JAVA_HOME/lib:\$CLASSPATH >> ~/.bash_profile
##restart terminal or source ~/.bashrc or . ~/.bashrc
source ~/.bashrc

##install MySQL http://wiki.ubuntu.org.cn/MySQL
sudo apt-get install mysql-server-5.6
#sudo start mysql #手动的话这样启动
#sudo stop mysql #手动停止
##enter MySQL
#mysql -uroot -p
##update admin password
#sudo mysqladmin -uroot password newpassword
## configuration file /etc/mysql/my.cnf
## install GUI client
## sudo apt-get install mysql-workbench #version is not the latest

##check the architecture of containers binaries
#file /bin/bash

##add Advanced settings设置
#sudo apt-get install gnome-tweak-tool
sudo apt-get install unity-tweak-tool
sudo apt-get install ccsm

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
sudo apt-get install acroread --force-yes -y
#再下载其中文语言包
#wget http://download.adobe.com/pub/adobe/reader/unix/7x/7.0.8/misc/FontPack708_chs_i386-linux.tar.gz
#tar zxvf FontPack708_chs_i386-linux.tar.gz
#解压后，运行其中的INSTALL
#sudo ./INSTALL
#我事先把FontPack708_chs_i386-linux.tar.gz解压到acrobat7_cn目录
sudo /var/cache/apt/archives/acrobat7_cn/INSTALL
#第一问题问你是否继续安装，直接回车；
#第二个问题问你是否接受协议，键入accept后回车；
#第三个问题要你定义Acrobat的安装目录，输入/usr/lib/Adobe/Acrobat7.0后回车。

########### gedit config
## Ubuntu gedit recent files dconf set max recents to something like 40
gsettings set org.gnome.gedit.preferences.ui max-recents "uint32 40"
## gedit add encoding for Chinese GB18030
gsettings set org.gnome.gedit.preferences.encodings auto-detected "['UTF-8', 'CURRENT', 'GB18030', 'ISO-8859-15', 'UTF-16']"
#gsettings set org.gnome.gedit.preferences.encodings auto-detected "['GB18030', 'GB2312', 'GBK', 'UTF-8', 'BIG5', 'CURRENT', 'UTF-16']"

sudo apt-get install dconf-editor
## under org > gnome > gedit > preferences > ui
#mkdir -p ~/.local/share/gedit/plugins
## plugin to restore tabs opened last time
## https://github.com/raelgc/gedit-restore-tabs

########### CacheBrowser https://cachebrowser.info/#/download
#sudo apt-get install python-setuptools
#sudo apt-get install python-dev

########### virtual box
#virtual box connect usb:	`sudo adduser <user> vboxusers`
#add user to group vboxsf:	`sudo usermod -a -G vboxsf <user>`

########### set waiting time for OS 解决Ubuntu 14.04 grub选择启动项10秒等待时间
#sudo vi /etc/default/grub
#update seconds: GRUB_HIDDEN_TIMEOUT=1
#sudo update-grub

## 安装ubuntu受限的额外的解码器
sudo apt-get install ubuntu-restricted-extras

#如果必须要用源码包安装，请在安装的时候指定--prefix安装目录，另外安装的时候请使用
#make >& LOG_make &
#make install >& LOG_install &
#用于保存安装信息日志，这样需要卸载的时候方便查看哪些文件安装在了系统目录中，例如/usr/lib下的库文件
