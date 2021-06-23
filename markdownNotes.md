# Markdown

[TOC]

## Recent

markdown转义: 句点前面加上反斜杠

## Basic syntax

### Text

Sometimes it's useful to have different levels of headings to structure your documents. Start lines with a `#` to create headings. Multiple `##` in a row denote smaller heading sizes.

### This is a third-tier heading

You can use  one `#` all the way up to `######` six for different heading sizes.
If you'd like to quote someone, use the > character before the line:

> Coffee. The finest organic suspension ever devised... I beat the Borg with it.
> Captain Janeway

### Headers

`# This is an <h1> tag`
`## This is an <h2> tag`
`###### This is an <h6> tag`

### Emphasis

*This text will be italic*
_This will also be italic_

**This text will be bold**
__This will also be bold__

_You **can** combine them_

``` code
*This text will be italic*
_This will also be italic_

**This text will be bold**
__This will also be bold__

_You **can** combine them_
```

### Lists

#### Unordered

* Item 1
* Item 2
  * Item 2a
  * Item 2b

``` code
* Item 1
* Item 2
  * Item 2a
  * Item 2b
```

#### Ordered

1. Item 1
2. Item 2
3. Item 3
   * Item 3a
   * Item 3b

``` code
1. Item 1
2. Item 2
3. Item 3
   * Item 3a
   * Item 3b
```

### Images

![Alt text](/path/to/img.jpg "Optional title")

![GitHub Logo](/images/logo.png)
Format: ![Alt Text](url)

``` code
![GitHub Logo](/images/logo.png)
Format: ![Alt Text](url)
```

### Links

`http://github.com - automatic!`
[GitHub](http://github.com)

``` code
http://github.com - automatic!
[GitHub](http://github.com)
```

### Block quotes

As Kanye West said:
> We're living the future so
> the present is our past.

``` code
As Kanye West said:
> We're living the future so
> the present is our past.
```

### Inline code

I think you should use an
`<addr>` element here instead.

``` code
I think you should use an
`<addr>` element here instead.
```

### List

* [x] @mentions, #refs, [links](url), **formatting**, and `<del>tags</del>` supported
* [x] list syntax required (any unordered or ordered list supported)
* [x] this is a complete item
* [ ] this is an incomplete item

``` code
- [x] @mentions, #refs, [links](), **formatting**, and <del>tags</del> supported
- [x] list syntax required (any unordered or ordered list supported)
- [x] this is a complete item
- [ ] this is an incomplete item
```

### Automatic linking for URLs

Any URL (like `http://www.github.com/`) will be automatically converted into a clickable link.

### Strikethrough

Any word wrapped with two tildes (like ~~this~~) will appear crossed out.

### Tables

You can create tables by assembling a list of words and dividing them with hyphens - (for the first row), and then separating each column with a pipe |:

First Header | Second Header
------------ | -------------
Content from cell 1 | Content from cell 2
Content in the first column | Content in the second column

### Extras

GitHub supports many extras in Markdown that help you reference and link to people. If you ever want to direct a comment at someone, you can prefix their name with an @ symbol: Hey @kneath — love your sweater!

But I have to admit, tasks lists are my favorite:

* [x] This is a complete item
* [ ] This is an incomplete item

When you include a task list in the first comment of an Issue, you will see a helpful progress bar in your list of issues. It works in Pull Requests, too!

And, of course emoji! :sparkles: :camel: :boom:

## Advanced

### BACKSLASH ESCAPES

Markdown allows you to use backslash escapes to generate literal characters which
would otherwise have special meaning in Markdown’s formatting syntax.
\*literal asterisks\*
*literal asterisks*

Markdown 支持以下这些符号前面加上反斜杠来帮助插入普通的符号

``` shell
\   反斜线
`   反引号
*   星号
_   底线
{}  花括号
[]  方括号
()  括弧
#   井字号
+   加号
-   减号
.   英文句点
!   惊叹号
--------
\ backslash
` backtick
* asterisk
_ underscore
{} curly braces
[] square brackets
() parentheses
# hash mark
+ plus sign
- minus sign (hyphen)
. dot
! exclamation mark
```

### backtick

如果要在代码区段内插入反引号，你可以用多个反引号来开启和结束代码区段：
``There is a literal backtick (`) here.``
这段语法会产生：

``` html
<p><code>There is a literal backtick (`) here.</code></p>`
```

### Auto compelte

输入 `code` 就会弹出行内代码和代码块两种补全提示
输入 `ul` 或 `li` 就会弹出列表补全提示

## [Plugin: Markdown All in One](https://marketplace.visualstudio.com/items?itemName=yzhang.markdown-all-in-one#keyboard-shortcuts)

### Others

Paste link on selected text

### Keyboard Shortcuts

`Ctrl/Cmd + Shift + ]` Toggle heading (uplevel)
`Ctrl/Cmd + Shift + [` Toggle heading (downlevel)
`Ctrl/Cmd + M` Toggle math environment
`Alt + C` Check/Uncheck task list item
`Ctrl/Cmd + Shift + V` Toggle preview
`Ctrl/Cmd + K V` Toggle preview to side

## [Plugin: Markdown Preview Enhanced is a SUPER POWERFUL markdown extension](https://shd101wyy.github.io/markdown-preview-enhanced/)

Paste to Markdown
Instructions
Find the text to convert to Markdown (e.g., in another browser tab)
Copy it to the clipboard (Ctrl+C, or ⌘+C on Mac)
Paste it into this window (Ctrl+V, or ⌘+V on Mac)
The converted Markdown will appear!
The conversion is carried out by to-markdown, a Markdown converter written in JavaScript and running locally in the browser.
