
## Recent

memory-free-min：强制resin重启时的最小空闲内存
thread-max：resin最大线程数
socket-timeout：套接字最大等待时间
keepalive-max：keepalived连接的最大数量，对网络性能有影响
keepalive-timeout：keepalived的最大保持时间

### access.log format
resin access.log format configured in resin.xml
<access-log path='/data/log/resin/account/access.log' format='%h %l %u %t "%r" %s %b %T %D "%{Referer}i" "%{User-Agent}i"' rollover-period='1D' />
%h %l %u %t "%r"
%s %b %T %D "%{Referer}i
"%h: remote IP addr" %l "%u: remote user" "%t: request date with optional time format string." "%r: request URL"
"%s: status code" "%b: result content length" "%T: time taken to complete the request in seconds" "%D: time taken to complete the request in microseconds (since 3.0.16)" "%i: request header xxx"

192.168.3.58 - "null-user" [08/Sep/2016:17:35:22 +0800] "GET /account/rollPictures?esdfsd=140_499 HTTP/1.0" 200 40 0 0 "-" "Apache-HttpClient/4.5.2 (Java/1.8.0_101)"


### Configuration
#### 调整检查程序更新时间间隔的配置
Resin 会在一个指定的周期内，检查一下web-app目录下的classes、jsp、jar以及配置文件是否更新，并且根据检查的情况，确定是否重新装载这些文件。对于生产系统来说，不会经常更新文件，时间间隔应该加长，提高系统的效率。文本框中配置的时间间隔为20分钟。

`resin.xml: <dependency-check-interval>1200s</dependency-check-interval>`
`resin.properties: dependency_check_interval`

#### resin-server Timeouts TIME_WAIT 过多的处理
http://www.caucho.com/resin-3.1/doc/tuning.xtp#Timeouts
http://www.caucho.com/resin-3.1/doc/tuning.xtp#TCPlimitsTIMEWAIT
http://yangzhiming.blog.51cto.com/4849999/834916
thread-max指定了最大连接数，socket-timeout是socket超时时间   
keepalive-max指定了长连接的数量，这是可以重复使用的连接，netstat -an时系统可以看到响应数量的ESTABLISHED状态  
设定keepalive-max和把keepalive-timeout调小可以减少TIME_WAIT的数量。
在<server-default>节点下增加配置

```
      <thread-max>10000</thread-max>
      <socket-timeout>30s</socket-timeout>
      <keepalive-max>512</keepalive-max>
      <keepalive-timeout>60s</keepalive-timeout>
```
