# IDEA Notes

Reimport: File -> Invalidate Caches/Restart

## 快捷键

new line above: `Command+Option+Enter`
new line after: `Shift+Enter`
move line up/down: `Option+Shift+up/down`
duplicate line: `Command+D`
import class: `Option+Enter`
`Option+Shift+Space` Smart code completion
`Command+Shift+8`: Column selection mode (Vertical selection)
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
"Fully Expand Tree Node" in settings->Keymap set mouse shortcut like `ALT+[Wheel Down]`
Set "Collapse Node" keyshort to `ALT+[Wheel Up]`

Load/Unload modules is like close project in eclipse

### 调试快捷键

F7：Step into
F8：Step over
F9：Run
Shift+F7：Smart step into（弹出对话框让你选择进入哪个方法）
Shift+F8：Step out
Ctrl+F8 / Command+F8：Toggle Breakpoint
Option+F8：Evaluate expression
Option+F9：Run To Cursor

## Config

### Directories used

[IDEA Directories used](https://intellij-support.jetbrains.com/hc/en-us/articles/206544519)

PRODUCT: IdeaIC2018.3
Configuration (idea.config.path): `~/Library/Preferences/<PRODUCT><VERSION>`
Caches (idea.system.path): `~/Library/Caches/<PRODUCT><VERSION>`
Plugins (idea.plugins.path): `~/Library/Application Support/<PRODUCT><VERSION>`
Logs (idea.log.path): `~/Library/Logs/<PRODUCT><VERSION>`
Location of user-defined keymaps: `~/Library/Preferences/IdeaIC2018.2/keymaps/`

[pycharm: Directories Used by PyCharm](https://www.jetbrains.com/help/pycharm/directories-used-by-the-ide-to-store-settings-caches-plugins-and-logs.html)

Configuration directory: `~/Library/Application Support/JetBrains/PyCharmCE2020.1`
Plugins directory: `~/Library/Application Support/JetBrains/<product><version>/plugins`
Logs directory: `~/Library/Logs/JetBrains/<product><version>`

### Custom

Help > Edit Custom Properties > create default idea.properties under idea.config.path: ~/Library/Preferences/IdeaIC2019.1/idea.properties
soft link: ~/Library/Preferences/IdeaIC2019.1 -> to ~/Dropbox/pcSetting/idea.community/IdeaIC2019.1

ln -s ~/Dropbox/pcSetting/idea.community/IdeaIC2019.1 ~/Library/Preferences/IdeaIC2019.1

1. To enable repeating j: type this in the mac terminal: `defaults write -g ApplePressAndHoldEnabled -bool false`
2. Preference -> KeyMap -> completion ->
    `Ctrl+Space` to `Shift+Space`
    `Ctrl+F` disable (for vim)
3. Code completion match case: Preference > Editor > General > Code Completion > Match case: uncheck
4. Preferences -> Editor -> General -> Show quick documentation on mouse move
5. Preferences -> Editor -> General -> Smart Keys -> Jump outside closing bracket/quote with Tab
6. Preference | Code Style | Java | Imports | Set Class count to use import with '*' and Names count to use static import with '*' fields as 999
7. "Apropos" terminal pops up when typing cmd+shift+A to get actions: System Preferences | Keyboard | Shortcuts | Services | disable Search man Page Index in Terminal
8. Preferences -> Editor -> File and code templates -> Includes tab (on the right). There is a template header
9. Preferences -> Editor -> Java -> Comment Code -> uncheck "Line comment at first column", check "Add a space at comment start"

    ```java
    /**
    * @author Myname
    */
    ```

10. Live template: Preferences -> Editor -> Live template, location: ~/Library/Preferences/IdeaIC2018.3/templates/user.xml

```groovy
// example
log.enter
$LOGGER$.debug("Enter $METHOD_NAME$ $EXPR_COPY$ {}", $EXPR$);
LOGGER resolveLoggerInstance   Default: log
METHOD_NAME methodName()
EXPR variableOfType("")
EXPR_COPY escapeString(EXPR)

log.enter.multiple
$LOGGER$.debug("Enter $METHOD_NAME$ $PARAMS_FORMAT$", $PARAMS$);
METHOD_NAME methodName()
PARAMS_FORMAT groovyScript("_1.collect{it+' {}'}.join(' ')", methodParameters())
PARAMS groovyScript("_1.collect{it}.join(',')", methodParameters())
```

## Plugins

* [Free MyBatis plugin](https://plugins.jetbrains.com/plugin/8321-free-mybatis-plugin)
* [Smart Tomcat](https://plugins.jetbrains.com/plugin/9492-smart-tomcat)
* [IdeaVimExtension](https://plugins.jetbrains.com/plugin/9615-ideavimextension): switch to English input method in normal mode and restore input method in insert mode.
* GsonFormat: 把json格式的内容转成Object
* [Request mapper](https://plugins.jetbrains.com/plugin/9567-request-mapper): `Command+Shift+Back slash` quick navigation to url mapping declaration
* [RestfulToolkit](https://plugins.jetbrains.com/plugin/10292-restfultoolkit) `Command+\` `Command+back slash`
* Rainbow Brackets
* Grep Console: highlight the editor - nice for analyzing logs
* Maven Helper
* Key Promoter
* GenerateAllSetter
* JRebel and XRebel: 热部署插件
* .env files support: 把.env文件中的内容给放到项目运行的环境变量中去
* SequenceDiagram: 梳理代码逻辑，绘制时序图
* Tabnine: AI code assistant
* Spring Assistant

### Vim

config path: `~/.ideavimrc`
Allocating conflicting keystrokes to IdeaVim: Preference -> Editor -> Vim Emulation -> Set Handler as IDE for (CTRL+C, CTRL+R, CTRL+T)
[IdeaVIM Reference Manual SCROLL](http://ideavim.sourceforge.net/vim/scroll.html)
`zz` line [count] at center of window (default cursor line)

### Add External Tool

#### open current path in iTerm

1. Preferences -> Tools -> External Tools -> Add -> Program: open -> Arguments: -a iTerm $FileDir$
2. Preferences -> Apperarance & Behavior -> Menus and Toolbars -> Main Toolbar -> Add
3. Keymap -> search "iTerm" -> Add keyboard shortcut "Command+Shift+i"
