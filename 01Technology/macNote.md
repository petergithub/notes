# Mac Note

### IDEA
new line above: `Alt + Command + Enter`
new line after: `Shift + Enter`
move line up/down: `Alt + Shift + up/down`
duplicate line: `Command + D'
import class: `Alt + Enter`
`Alt + Shift + Space` Smart code completion
`Shift + Command + A`: Display all command, Help -> Find Action
`Command + F12`: list all method in current file
`F3` Toggle bookmark
`Comand + F3` show bookmark list
`Alt + Command + L`: reformat code
`Alt + Command + O`: list all method and variable
`Alt + Command + B` or `Alt + Command + Left Click` : Implementation code
`Alt + F7` 代码调用
`Command+Shift+F12` 代码窗口最大化
`Command + ;` Project structure > `Command + N` import module
`Fn + Command + Right' go to end of the file
`Fn + Command + Left` go to home of the file
`Command + J` to complete any valid Live Template abbreviation
`Esc` The ⎋ key in any tool window moves the focus to the editor.
`Shift + Esc` moves the focus to the editor and also hides the current (or last active) tool window.
`F12` key moves the focus from the editor to the last focused tool window.

Load/Unload modules is like close project in eclipse

调试快捷键：
    F7：Step into
    F8：Step over
    F9：Run
    Shift+F7：Smart step into（弹出对话框让你选择进入哪个方法）
    Shift+F8：Step out
    Ctrl+F8 / Command+F8：Toggle Breakpoint
    Alt+F8：Evaluate expression
    Alt+F9：Run To Cursor

Add External Tool iTerm
1. Preferences -> Tools -> External Tools -> Add -> Program: open -> Arguments: -a iTerm $FileDir$
2. Preferences -> Menus and Toolbars -> Main Toolbar -> Add

[Directories used](https://intellij-support.jetbrains.com/hc/en-us/articles/206544519)
    Configuration (idea.config.path): ~/Library/Preferences/<PRODUCT><VERSION>
    Caches (idea.system.path): ~/Library/Caches/<PRODUCT><VERSION>
	Plugins (idea.plugins.path): ~/Library/Application Support/<PRODUCT><VERSION>
    Logs (idea.log.path): ~/Library/Logs/<PRODUCT><VERSION>
	Location of user-defined keymaps: ~/Library/Preferences/IdeaIC2018.2/keymaps/

Plugin: 
[Free MyBatis plugin](https://plugins.jetbrains.com/plugin/8321-free-mybatis-plugin)
[Smart Tomcat](https://plugins.jetbrains.com/plugin/9492-smart-tomcat)
Maven Helper, Key Promoter

### vs code
`Command + Shift + P` open command palette
`Shift + Option + Click` block selection

### Mac common 
`Command+Shift+4` snapshot
Home键=Fn+左方向 End键=Fn+右方向 PageUP=Fn+上方向 PageDOWN=Fn+下方向
向前Delete=Fn+delete键 
commond+上箭头（就是右下角的方向键）可以直达页面顶部
commond+下箭头可以直达页面底部

`Fn + Right/Left` windows-style home/end
`Fn + Up/Down` windows-style page up/down

`brew install bat` alternative to `cat`
`alt+e` eclipse plugin EasyShell Main pop menu  
`tldr` TL;DR project for help

#### Finder shortcut:
`Command+Shift+G` 快捷键可以完成到达某路径的操作 
Create new folder: `Command+Shift+n`
Display hidden file: `Command+Shift+.`    
强制退出程序窗口 `Command+Option+Esc`  
`Command+Alt+Space` Show Finder search window  

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
block selection: `Alt + Command + Left Click`

### firefox
firefox profile location: /users/$user/library/application support/firefox/profiles

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
2. 启动浏览器 http://localhost:8002
3. 客户端设置代理 http://ip:8001
[代理服务器 AnyProxy](https://www.jianshu.com/p/2074f7572694)  
[AnyProxy](http://anyproxy.io/cn)

## Manage
### disable auto start
load from `/Library/LaunchAgents`  
disable it `launchctl unload -w /Library/LaunchAgents/com.adobe.AdobeCreativeCloud.plist`  
turn it back on `launchctl load -w /Library/LaunchAgents/com.adobe.AdobeCreativeCloud.plist`  

