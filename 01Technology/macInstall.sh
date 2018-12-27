# install package
# refer to [高效程序员的MacBook工作环境配置](http://www.codeceo.com/article/programmer-macbook-workplace.html)
# TODO: 

# firefox 56.0.2 https://sourceforge.net/projects/ubuntuzilla/files/mozilla/apt/pool/main/f/firefox-mozilla-build/
# https://ftp.mozilla.org/pub/firefox/releases/56.0.2/

## zsh profile
echo "export JAVA_HOME=$(/usr/libexec/java_home)" >> ~/.zsh.mac 

# zsh
brew install zsh
chsh -s $(which zsh)
# oh my zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
# sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="alanpeabody"/' ~/.zshrc
# sed -i 's/# DISABLE_AUTO_TITLE="true"/DISABLE_AUTO_TITLE="true"/' ~/.zshrc
## Disable 'Would you like to check for updates' prompt: add DISABLE_AUTO_UPDATE="true" on your .zshrc before the source $ZSH/oh-my-zsh.sh line
# source ~/.zshrc

# common software install begin
brew install tig autojump iproute2mac tldr jq
brew cask install atom google-chrome
brew install node

# develop software install
brew install mysql
brew services start mysql
mysql_secure_installation
mysql -u root -proot

brew cask install mysqlworkbench

# install mysql older version  https://gist.github.com/benlinton/d24471729ed6c2ace731
brew insall mysql@5.7
## change to 5.7 version
# Unlink current mysql version
brew unlink mysql 
brew switch mysql@5.7 5.7.23
# Check older mysql version
ln -s /usr/local/Cellar/mysql@5.7/5.7.23/bin/mysql /usr/local/bin/mysql
# Or using the mysql command
mysql --version


# other software
brew install mycli
brew cask install xmind calibre virtualbox alfred

# Visual Studio Code (vscode)
# use CMD+[1-9] to switch between tabs: Code > Preferences > Keyboard Shortcuts > keybindings.json add line in https://stackoverflow.com/a/46087295/1086907

# atom
# Generate TOC (table of contents) of headlines from parsed markdown file. https://atom.io/packages/markdown-toc
apm install markdown-toc 

# docker
brew cask install docker
# docker tool for mac
#brew install docker docker-compose docker-machine xhyve docker-machine-driver-xhyve


## Shell jump word-wise left and right in iTerm2 with Alt+F/B
# Preferences(command+,) > Profiles > Keys -> Click the plus -> add (Alt+F, send escape sequence, f) and (Alt+B, send escape sequence, b)
# refer to https://apple.stackexchange.com/questions/154292/iterm-going-one-word-backwards-and-forwards
## Open new tabs in iTerm in the current directory
# Preference -> General -> Wroking Directory -> Reuse previous session's directory

## Open file with default application 
# right (or control) click a file of the type you want to change and:
# "Get Info" -> "Open with:" -> (Select TextMate) -> "Change All"

## software
# sougou input method
# [Go2Shell](http://zipzapmac.com/Go2Shell): Opens a terminal window to the current directory in Finder: `open -a iTerm`
# [Scroll Reverser](https://pilotmoon.com/scrollreverser) is a free Mac app that reverses the direction of scrolling
# [Fantastical Calendar](https://flexibits.com/fantastical)
# [jd-GUI](http://jd.benow.ca)
# [SizeUp](http://www.irradiatedsoftware.com/sizeup/)
# [Better And Better](http://www.better365.cn/col.jsp?id=114):状态栏,键盘鼠标手势设置

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
# check software info from brew: brew info mysql
# install with brew: brew install tig autojump
# search with brew cask: brew cask search chrome
# install with brew cask: brew cask install atom google-chrome
# startup with brew: brew services start nginx
# brew switch another version: brew switch python 3.6.5_1
# brew uninstall <package_name>  

