# Mac Note

System Preferences >> Keyboard >> Shortcuts 的 App Shortcuts 为任何软件菜单里的项目设置快捷键
`Command+Shift+5` capture screenshot
`unar -encoding GBK file.zip` 解压缩文件避免乱码
`md5 -s string`
`md5 /path/to/file` or `openssl md5 /path/to/file`
`shasum -a 1 /path/to/file` or `openssl sha1 /path/to/file`
`shasum -a 256 /path/to/file` or `openssl sha256 /path/to/file`

got error message `find: message_uk.xml: unknown primary or operator` with command `find . -name *_uk.xml` 
correct with quote: `find . -name '*_uk.xml'`

`gcc -v` `gcc --version`
`sw_vers -productVersion` return the OS version
`system_profiler SPSoftwareDataType` more info about OS

## Development

### IDEA

Reimport: File -> Invalidate Caches/Restart

new line above: `Command+Option+Enter`
new line after: `Shift+Enter`
move line up/down: `Option+Shift+up/down`
duplicate line: `Command+D`
import class: `Option+Enter`
`Option+Shift+Space` Smart code completion
`Command+Shift+A`: Display all command, Help -> Find Action
`Command+F12`: list all method in current file
`F3` Toggle bookmark
`Comand+F3` show bookmark list
`Command+Option+L`: reformat code
`Command+Option+O`: list all method and variable, search through all Symbols
`Command+Option+B` or `Command+Option+Left Click` : Implementation code
`Option+F7` 代码调用
`Command+Shift+F12` 代码窗口最大化
`Command+;` Project structure > `Command+N` import module
`Fn+Command+Right` go to end of the file
`Fn+Command+Left` go to home of the file
`Command+J` to complete any valid Live Template abbreviation
`Esc` The ⎋ key in any tool window moves the focus to the editor.
`Shift+Esc` moves the focus to the editor and also hides the current (or last active) tool window.
`F12` key moves the focus from the editor to the last focused tool window.
`Command+Shift+8` block selection

Load/Unload modules is like close project in eclipse

#### 调试快捷键

    F7：Step into
    F8：Step over
    F9：Run
    Shift+F7：Smart step into（弹出对话框让你选择进入哪个方法）
    Shift+F8：Step out
    Ctrl+F8 / Command+F8：Toggle Breakpoint
    Option+F8：Evaluate expression
    Option+F9：Run To Cursor

#### Setup

"Fully Expand Tree Node" in settings->Keymap set mouse shortcut like `ALT+[Wheel Down]`
Set "Collapse Node" keyshort to `ALT+[Wheel Up]`

##### Config

ln -s ~/Dropbox/pcSetting/idea.community/IdeaIC2019.1 ~/Library/Preferences/IdeaIC2019.1

1. To enable repeating j: type this in the mac terminal: `defaults write -g ApplePressAndHoldEnabled -bool false`
2. Preference -> KeyMap -> completion ->
    `Ctrl+Space` to `Shift+Space`
    `Ctrl+F` disable (for vim)
3. Code completion match case: Preference > Editor > General > Code Completion > Match case: uncheck
4. Preferences -> Editor -> General -> Show quick documentation on mouse move
5. Preferences -> Editor -> General -> Smart Keys -> Jump outside closing bracket/quote with Tab
6. Preference | Code Style | Java | Imports | Set Class count to use import with ‘*’ and Names count to use static import with ‘*’ fields as 999

##### Vim

config path: `~/.ideavimrc`
Allocating conflicting keystrokes to IdeaVim: Preference -> Editor -> Vim Emulation -> Set Handler as IDE for (CTRL+C, CTRL+R, CTRL+T)
[IdeaVIM Reference Manual SCROLL](http://ideavim.sourceforge.net/vim/scroll.html)
`zz` line [count] at center of window (default cursor line) 

##### Add External Tool

###### open current path in iTerm

1. Preferences -> Tools -> External Tools -> Add -> Program: open -> Arguments: -a iTerm $FileDir$
2. Preferences -> Apperarance & Behavior -> Menus and Toolbars -> Main Toolbar -> Add
3. Keymap -> search "iTerm" -> Add keyboard shortcut "Command+Shift+i"

##### [Directories used](https://intellij-support.jetbrains.com/hc/en-us/articles/206544519)

PRODUCT: IdeaIC2018.3
    Configuration (idea.config.path): `~/Library/Preferences/<PRODUCT><VERSION>`
    Caches (idea.system.path): `~/Library/Caches/<PRODUCT><VERSION>`
    Plugins (idea.plugins.path): `~/Library/Application Support/<PRODUCT><VERSION>`
    Logs (idea.log.path): `~/Library/Logs/<PRODUCT><VERSION>`
    Location of user-defined keymaps: `~/Library/Preferences/IdeaIC2018.2/keymaps/`

    Help > Edit Custom Properties > create default idea.properties under idea.config.path: ~/Library/Preferences/IdeaIC2019.1/idea.properties
    soft link: ~/Library/Preferences/IdeaIC2019.1 -> to ~/Dropbox/pcSetting/idea.community/IdeaIC2019.1

##### Plugin

[Free MyBatis plugin](https://plugins.jetbrains.com/plugin/8321-free-mybatis-plugin)
[Smart Tomcat](https://plugins.jetbrains.com/plugin/9492-smart-tomcat)
[IdeaVimExtension](https://plugins.jetbrains.com/plugin/9615-ideavimextension): switch to English input method in normal mode and restore input method in insert mode.
GsonFormat: 把json格式的内容转成Object
RestfulToolkit: `Command+back slash`
[Request mapper](https://plugins.jetbrains.com/plugin/9567-request-mapper): `Command+Shift+Back slash` quick navigation to url mapping declaration
[RestfulToolkit](https://plugins.jetbrains.com/plugin/10292-restfultoolkit) `Command+\`
Grep Console: highlight the editor - nice for analyzing logs
Maven Helper, Key Promoter, GenerateAllSetter
JRebel for IntelliJ: 热部署插件

### vs code

`Command+Shift+P` open command palette
`Shift+Option+Click` block selection
Customize shortcut: `System Preference -> Keyboard -> Shortcuts -> App Shortcuts -> +`
File->Open Recent->Reopen Closed Editor: `Ctrl+Shift+T`

add to PATH environment: `command palette -> shell command install`

#### Plugin

[VSCodeVim](https://github.com/VSCodeVim/Vim) config with [Input Method](https://github.com/VSCodeVim/Vim#input-method)

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

#### Settings

Display: `Preference -> Profiles -> Colors -> Foreground: black, Background: white, Bold: gray, Minimum contrast: middle`

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

### 代理服务器 AnyProxy

1. 以支持 Https 方式启动 `anyproxy --intercept`
2. 启动浏览器 [链接](http://localhost:8002)
3. 客户端设置代理 [链接](http://ip:8001)
 [代理服务器 AnyProxy](https://www.jianshu.com/p/2074f7572694)  
 [AnyProxy](http://anyproxy.io/cn)

### WPS
COMMAND+Fn+Up/Down (Ctrl+PageUp/PageDown) 切换到上/下一个工作表 Sheet

## Manage

### stop programs from opening on startup

System Preferences -> Users & Groups -> Login Items

### disable auto start

load from `/Library/LaunchAgents`  
disable it `launchctl unload -w /Library/LaunchAgents/com.adobe.AdobeCreativeCloud.plist`  
turn it back on `launchctl load -w /Library/LaunchAgents/com.adobe.AdobeCreativeCloud.plist`  
