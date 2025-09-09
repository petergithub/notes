# Toolbox

## iOS remember list

[ElevenReader - Free Read Aloud Text App | ElevenLabs](https://elevenreader.io/) 一个手机 App（支持 iOS 和安卓），把电子书转成有声书，支持中文，但是内置的老外语音读起来很生硬。

## macOS remember list

mathpix: converting equations in images to LaTeX

## Ubuntu remember list

From OSX to Ubuntu https://nicolas.perriault.net/code/2016/from-osx-to-ubuntu/

Scala tool: ./kojo
mongoDB: MongoDB Compass, Robomongo
Xmind: xmind
Book: calibre
vpn: firefly

VLC media player
ncdu - NCurses Disk Usage: ncdu (NCurses Disk Usage) is a curses-based version of the well-known 'du', and provides a fast way to see what directories are using your disk space.

Disk usage analyzer
Visio like: Dia, sudo apt-get install -y dia
Graph Editor: yEd
RemoteMouse: mono ~/opt/RemoteMouse/RemoteMouse.exe http://remotemouse.net
Pocket Files: share files and private files http://app.rambax.com/pocketfiles
Team viewer: desktop share

lzop: lzo file
jd-gui: jad decompile
mkcert is a simple tool for making locally-trusted development certificates. https://localhost

gmtp connect to android
ncdu NCurses Disk Usage: ncdu (NCurses Disk Usage) is a curses-based version of the well-known 'du'
Transmission: Transmission is a cross-platform BitTorrent client https://transmissionbt.com/about/
linux 多线程下载工具 multiget
linux 下读书软件 fbreader
phpBB-3.1.10 forum
Gimp: alternatives to Photoshop
Autokey
mail client: thunderbird
  plugin: Lightning (for calendar) + EWS, ExQuilla, FireTray, Thunderbird Indicator App
  Exchange EWS Provider (connect with exchange server https://github.com/Ericsson/exchangecalendar/wiki/Exchange-EWS-Provider)
  [link](https://mailsz.tct.tcl.com/EWS/Exchange.asmx) (https://yourcompany.com/owa  Replace the "owa" with "EWS/Exchange.asmx")

Diodon: paste clipboard
sudo add-apt-repository ppa:diodon-team/stable

f.lux GUI
sudo add-apt-repository ppa:nathan-renniewaldock/flux

webtorrent-desktop
DVD Decrypter [link](http://www.dvddecrypter.org.uk/ http://arch.pconline.com.cn//pcedu/soft/gj/media/0511/724509_1.html)

Sandboxie sandbox for windows
ssl vpn client: openFortiGUI https://hadler.me/linux/openfortigui/

1. 博客：GitHub + Jeklly + MarkDown Syntax。自己可以任意定义版式，Github来发布。同时Jeklly自带的主题就很漂亮。又漂亮又优雅。
2. 我使用 Balsamiq 3、Slack、DropBox、Chrome、Hangout、Google 办公套件、GoToMeeting、WebStorm、Skype、Gimp、Insync等软件…对了，在休息时间我会在 Steam 上玩会游戏
3. 「石墨文档」或是「一起写」这样的在线协作工具Word
4. Read response data in Jmeter: BeanShell PostProcessor

## windows remember list

[Great Image and File Content Search Freeware](https://anytxt.net/) Searcher A Desktop Search Tool with A Powerful Full-Text Search Engine

## VS Code

[10 VS Code Extensions I Can't Live Without](https://www.howtogeek.com/vs-code-extensions-i-cant-live-without/)

[wanniwa/EditorJumper: EditorJumper is a JetBrains IDE plugin that allows you to seamlessly jump between JetBrains IDE and other popular code editors (such as VS Code, Cursor, Trae, and Windsurf). It maintains your cursor position and editing context, greatly improving development efficiency in multi-editor environments.](https://github.com/wanniwa/EditorJumper)

### VS Code Windows

`Shift+Delete` Delete line
`Ctrl+Enter` new line after current line
`Ctrl+;` to invoke the extension Maximize Terminal
`Ctrl+Alt+M;` workbench.action.toggleMaximizedPanel

[Can't enter Vim visual block mode in integrated terminal](https://github.com/microsoft/vscode/issues/88395#issuecomment-572822979)
[Integrated Terminal - Azure Data Studio | Microsoft Learn](https://learn.microsoft.com/en-us/azure-data-studio/integrated-terminal#forcing-key-bindings-to-pass-through-the-terminal)

```json
    "terminal.integrated.commandsToSkipShell": [
        "-workbench.action.terminal.paste"
    ],
```

### VS Code Mac

`Cmd + Shift + P` Show and run command

## DBeaver

Database > Driver Manager > MySQL > Edit > Libraries > 展开 mysql-connector > double click jar file to open Driver location

Driver location:  %USERPROFILE%\AppData\Roaming\DBeaverData

## Chrome

Alt+U or click the icon to copy URL without encoding from address bar

### chrome解决http自动跳转https问题

地址栏输入： chrome://net-internals/#hsts.
找到底部 Delete domain security policies一栏，输入想处理的域名，点击delete。
搞定了，再次访问http域名不再自动跳转https了。

### Extension

1. [Bypass Paywalls web browser extension for Chrome and Firefox.](https://github.com/iamadamdev/bypass-paywalls-chrome)
2. ARC: chrome extension to run APKs

### 油猴脚本

[油猴脚本 Q105: How can I sync all scripts installed at Tampermonkey to another browser?](https://www.tampermonkey.net/faq.php#Q105)

1. Go to Tampermonkey's Dashboard and select the "Settings" tab
2. now set the "Config Mode" to either "Beginner" or "Advanced"
3. search for the "Script Sync" section and
4. Choose your favorite sync service WebDAV `https://dav.jianguoyun.com/dav`
5. Finally you need to "Enable Script Sync" and press the "Save" button

### 在Chrome 浏览器上滚动截屏

1. 打开 Chrome 浏览器，进入需要截图的网站页面
2. 打开开发者工具：在页面任何地方点击鼠标右键，在弹出菜单中选择「检查」选项。或者使用快捷键组合：option + command + i。
3. 打开命令行（command palette）：command + shift + p。
4. 在命令行中输入「screen」，这时自动补齐功能会显示出一些包含 「Screen」 关键字的命令。移动方向键到「Capture full size screenshot」并回车,chrome就会自动下载整个页面截屏文件。

### How to Enable DNS Over HTTPS (DoH)

1. Select the three-dot menu in your browser > Settings.
2. Select Privacy and security > Security.
3. Scroll down and enable Use secure DNS.
4. Select the With option, and from the drop-down menu choose Cloudflare (1.1. 1.1).
5. [Browser Security Check | Cloudflare](https://www.cloudflare.com/ssl/encrypted-sni)

## Application Usage

### 写作工具

- [GitHub - microsoft/markitdown: Python tool for converting files and office documents to Markdown.](https://github.com/microsoft/markitdown)
- Meta 学术文档OCR神器 [Nougat](https://facebookresearch.github.io/nougat/)
- Obsidian 写作、同步所有整理后的 markdown 文件。

### Firefox

1. FF clearing the cookies & cache `Ctrl + Shift + Delete`
2. Toggle Developer Tools `F12`, `Ctrl + Shift + I`
3. Disable Ctrl + Shift + C shortcut in firefox, refer to [how-to-disable-ctrl-shift-c-shortcut-in-firefox](https://stackoverflow.com/questions/36007119/how-to-disable-ctrl-shift-c-shortcut-in-firefox)
4. SwitchOmega rule list URL: [gfwlist](https://raw.githubusercontent.com/gfwlist/gfwlist/master/gfwlist.txt)

firefox profile location: `/users/$user/library/application support/firefox/profiles`

### Atom

Atom configuration files with shortcuts: `~/.atom/keymap.cson`
atom package location `~/.atom/packages`
`Shift+Enter` Atom find backward
`CTRL+SHIFT+M` markdown preview
`CTRL+\` Tree view toggle

### WPS

`COMMAND+Fn+Up/Down (Ctrl+PageUp/PageDown)` 切换到上/下一个工作表 Sheet
`Ctrl+L` Create table
Cloud document storage location: /Users/pu/Library/Containers/com.kingsoft.wpsoffice.mac/Data/Library/Application Support/Kingsoft/WPS Cloud Files/userdata/qing/filecache


### LibreOffice Calc

1. right-click on the row header -> choose Optimal Row Height
2. Q: libre office calc default optimal row height
3. Automatic count of the rows in a filtered list: At the right end of the status bar you can pick a function (right-click). "Count" counts unfiltered numbers within the selection, "CountA" counts non-empty unfiltered cells. When using "CountA" you may sustract 1 due to the column header
4. Tools -> Options -> LibreOffice Calc -> General
    -> Press Enter to switch to edit mode
    -> Press Enter to move selection -> Right
5. Tools -> Auto Correct -> Options -> uncheck "Capitalize first letter of every sentence", uncheck "URL Recognition"
6. Format -> Styles -> Styles and Formatting -> Right-click on Default -> Modify -> Font -> update font -> Save

### LibreOffice Writer

1. Document structure navigation: press "Listbox ON/OFF" Listbox ON/OFF in Navigator -> it is under "Headings".

### Calibre

自定义翻译源，打开 Ebook viewer，双击查询，然后点击 `Add sources`，加入以下格式的链接

```sh
https://cn.bing.com/search?q=define:{word}
https://www.google.com/search?q=define:{word}
https://fanyi.baidu.com/#en/zh/{word}
```

### Confluence

#### Anchor

HTML or Markdown syntax

1. To insert an anchor point of that name use HTML: `<a name="pookie"></a>`
2. HTML syntax: Take me to `<a href="#pookie" rel="nofollow">pookie</a>`
 or Markdown syntax: Take me to [pookie](#pookie)

[Confuluence Anchors] (https://confluence.atlassian.com/conf55/confluence-user-s-guide/creating-content/using-the-editor/working-with-anchors#WorkingwithAnchors-Creatingananchor)

1. Create anchor: Ctrl+Shift+A (Click + -> Other macro -> Anchor)
  or input { -> select "open macro browser" -> Anchor
2. Creating link to an anchor (view HTML source to get anchor id):
  user guide:   https://confluence.atlassian.com/conf55/confluence-user-s-guide/creating-content/using-the-editor/working-with-anchors#WorkingwithAnchors-Creatingalinktoananchor
  or page name is in English: http://confluence.lab.tclclouds.com/display/TCLOUD/gateway.pay#gateway.pay-returnValues
  or page name is not in English: http://confluence.lab.tclclouds.com/pages/viewpage.action?pageId=7595848#id-账户中心常用相关整理-staticPageDeploy

## Network

MagicDNS automatically registers DNS names for devices in your network. [MagicDNS · Tailscale Docs](https://tailscale.com/kb/1081/magicdns)

### putty显示中文

在window-〉Appearance-〉Translation中，Received data assumed to be in which character set 中,把Use font encoding改为UTF-8.
如果经常使用,把这些设置保存在session里面.

### Proxy

[mitmproxy](https://docs.mitmproxy.org/stable/)

#### Proxy configuration

file://path
    On Windows, you have to use that syntax: file://C:/proxy.pac
    On Unix, you have to use that syntax: file:///path/to/proxy.pac

https://pac.itzmx.com/abc.pac
