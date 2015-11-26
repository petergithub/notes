[TOC]

## XSS: Cross Site Scripting
A站点被XSS攻击，一个页面织入了获取用户如cookie的JS代码，造成访问此页面的用户信息被它人获取
办法：cookie设置 http only，同时页面对用户提交的数据进行js安全输出，转义

## CSRF: Cross-site request forgery
先登录A站点，再访问被织入了代码的B站点，B站点的代码构造请求访问A站点的某个URL，造成用户在访问B站点的时候被别人操纵了A站点的数据
办法：A站点（我们的站点），所有提交数据的请求加上一个token校验