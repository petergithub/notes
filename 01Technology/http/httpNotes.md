# HTTP note

## Recent

跨域资源共享（CORS）:Access-Control-Allow-Origin就是所谓的资源共享了，它的值*表示允许任意网站向这个接口请求数据，也可以设置成指定的域名，如：
response.writeHead(200, { "Access-Control-Allow-Origin": "http://yoursite.com"});
configure Access-Control-Allow-Origin to avoid unknown domain visit
在开发RESTful API时，要注意CORS功能的实现，直接拿现有的轮子来用即可

HTTP 接口参数:

1. 首先根据一定的规则生成签名信息，防止信息篡改，对不同传输格式分别进行一下处理，Json格式：一般取指定的字段组成字符串通过MD5生成签名信息，然后放到json中的作为sign的值。
2. 其次通过RSA加解密算法对要传输的字符串进行加密
3. 通过URLBase64进行加密

## HTTP长连接

### 是什么

HTTP1.1规定了默认保持长连接（HTTP persistent connection ，也有翻译为持久连接），数据传输完成了保持TCP连接不断开（不发RST包、不四次握手），等待在同域名下继续用这个通道传输数据；相反的就是短连接

### 长连接的过期时间

服务器有时候会告诉客户端超时时间`Keep-Alive: timeout=20`表示这个TCP通道可以保持20秒
另外还可能有`max=XXX`，表示这个长连接最多接收XXX次请求就断开

### 长连接的数据传输完成识别

1. 是判断传输数据是否达到了Content-Length指示的大小；
2. 动态生成的文件没有Content-Length，它是分块传输（chunked），这时候就要根据chunked编码来判断，chunked编码的数据在最后有一个空chunked块，表明本次传输数据结束

### 并发连接数的数量限制

在web开发中需要关注浏览器并发连接的数量，RFC文档说，客户端与服务器最多就连上两通道，但服务器、个人客户端要不要这么做就随人意了，有些服务器就限制同时只能有1个TCP连接，导致客户端的多线程下载（客户端跟服务器连上多条TCP通道同时拉取数据）发挥不了威力，有些服务器则没有限制

### 容易混淆的概念——TCP的keep alive和HTTP的Keep-alive

TCP的keep alive是检查当前TCP连接是否活着；HTTP的Keep-alive是要让一个TCP连接活久点

TCP keep alive的表现：当一个连接“一段时间”没有数据通讯时，一方会发出一个心跳包（Keep Alive包），如果对方有回包则表明当前连接有效，继续监控

## HTTPS

https CDN方式, 私钥不需要提供给CDN

1. Keyless SSL
2. 网宿推出无证书https加速方案 http://www.chinanetcenter.com/Home/News/420

https SSL增加的时间大概多少 time(ssl) = 3 * time(tcp)
HTTP耗时 = TCP握手(三个包)
HTTPs耗时 = TCP握手(三个包) + SSL握手(需要9个包)
