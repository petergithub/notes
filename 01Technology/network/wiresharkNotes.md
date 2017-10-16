# Wireshark notes

## Common
1. `ip.addr == 124.251.36.121 && tcp.port == portNumber`  
2. `Follow TCP/UDP Stream`  
3. Wireshark的`Analyze-->Expert Info Composite`，就可以在不同标签下看到不同级别的提示信息。比如重传的统计、连接的建立和重置统计，等等。在分析网络性能和连接问题时，我们经常需要借助这个功能
4. 单击`Statistics-->Service Response Time`，再选定协议名称，可以得到响应时间的统计表
5. 单击`Statistics-->TCP Stream Graph`，可以生成几类统计图。比如我曾经用Time-Sequence Graph (Stevens)
6. 单击`Statistics-->Summary`，可以看到一些统计信息，比如平均流量等

## Filter
### Capture filter:
`host domainName`  
`host IP`  

### Display filter
http.host == login.tclclouds.com
ip.addr == 124.251.36.121 or ip.addr == 124.251.36.122
http and ip.addr == 124.251.36.121 and ip.dst ==124.251.43.33
`tcp.port == portNumber`  

wireshark http数据包过滤条件列表

http.host==6san.com
http.host contains 6san.com
//过滤经过指定域名的http数据包，这里的host值不一定是请求中的域名

http.response.code==302
//过滤http响应状态码为302的数据包
http.response==1
//过滤所有的http响应包

http.request==1
//过滤所有的http请求，貌似也可以使用http.request
http.request.method==POST
//wireshark过滤所有请求方式为POST的http请求包，注意POST为大写

http.cookie contains guid
//过滤含有指定cookie的http数据包

http.request.uri==”/online/setpoint”
//过滤请求的uri，取值是域名后的部分

http.request.full_uri==” http://task.browser.360.cn/online/setpoint”
//过滤含域名的整个url则需要使用http.request.full_uri

http.server contains “nginx”
//过滤http头中server字段含有nginx字符的数据包
http.content_type == “text/html”
//过滤content_type是text/html的http响应、post包，即根据文件类型过滤http数据包

http.content_encoding == “gzip”
//过滤content_encoding是gzip的http包
http.transfer_encoding == “chunked”
//根据transfer_encoding过滤
http.content_length == 279
http.content_length_header == “279”
//根据content_length的数值过滤

http.server
//过滤所有含有http头中含有server字段的数据包

http.request.version == “HTTP/1.1”
//过滤HTTP/1.1版本的http包，包括请求和响应
http.response.phrase == “OK”
//过滤http响应中的phrase
