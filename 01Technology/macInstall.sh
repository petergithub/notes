# install package
# refer to [高效程序员的MacBook工作环境配置](http://www.codeceo.com/article/programmer-macbook-workplace.html)
# TODO: 

# check software info from brew: brew info mysql
# install with brew: brew install tig autojump
# search with brew cask: brew cask search chrome
# install with brew cask: brew cask install atom google-chrome
# firefox 56.0.2 https://sourceforge.net/projects/ubuntuzilla/files/mozilla/apt/pool/main/f/firefox-mozilla-build/
# https://ftp.mozilla.org/pub/firefox/releases/56.0.2/

## zsh profile
echo "export JAVA_HOME=$(/usr/libexec/java_home)" >> ~/.zsh.mac 

# zsh
brew install zsh
chsh -s $(which zsh)
# oh my zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
# sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="alanpeabody"/'
# source ~/.zshrc

# common software install begin
brew install tig autojump
brew cask install atom google-chrome

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

# sougou input method
# [Scroll Reverser](https://pilotmoon.com/scrollreverser) is a free Mac app that reverses the direction of scrolling
# [jd-GUI](http://jd.benow.ca)
# [SizeUp](http://www.irradiatedsoftware.com/sizeup/)

