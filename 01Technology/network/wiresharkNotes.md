# Wireshark notes

[Manpage of TCPDUMP](http://www.tcpdump.org/manpages/tcpdump.1.html#lbAG)

## Recent

1. Display filter `ip.addr == 124.251.36.121 && tcp.port == portNumber`  
2. `Follow TCP/UDP Stream`  
3. Wireshark的`Analyze-->Expert Info Composite`，就可以在不同标签下看到不同级别的提示信息。比如重传的统计、连接的建立和重置统计，等等。在分析网络性能和连接问题时，我们经常需要借助这个功能
4. 单击`Statistics-->Service Response Time`，再选定协议名称，可以得到响应时间的统计表
5. 单击`Statistics-->TCP Stream Graph`，可以生成几类统计图。比如我曾经用Time-Sequence Graph (Stevens)
6. 单击`Statistics-->Summary`，可以看到一些统计信息，比如平均流量等

## Filter

### Capture filter

`host domainName`  
`host IP`  
`port portNumber`

#### Protocol（协议）

可能的值: ether, fddi, ip, arp, rarp, decnet, lat, sca, moprc, mopdl, tcp and udp.
如果没有特别指明是什么协议，则默认使用所有支持的协议。

#### Direction（方向）

可能的值: src, dst, src and dst, src or dst
如果没有特别指明来源或目的地，则默认使用 “src or dst” 作为关键字。
例如，”host 10.2.2.2″与”src or dst host 10.2.2.2″是一样的。

#### Host(s)

可能的值： net, port, host, portrange.
如果没有指定此值，则默认使用”host”关键字。
例如，”src 10.1.1.1″与”src host 10.1.1.1″相同。

#### Logical Operations（逻辑运算）

可能的值：not, and, or.
否(“not”)具有最高的优先级。或(“or”)和与(“and”)具有相同的优先级，运算时从左至右进行。
例如，
“not tcp port 3128 and tcp port 23″与”(not tcp port 3128) and tcp port 23″相同。
“not tcp port 3128 and tcp port 23″与”not (tcp port 3128 and tcp port 23)”不同。

#### 例子

tcp dst port 3128  //捕捉目的TCP端口为3128的封包。
ip src host 10.1.1.1  //捕捉来源IP地址为10.1.1.1的封包。
host 10.1.2.3  //捕捉目的或来源IP地址为10.1.2.3的封包。
ether host e0-05-c5-44-b1-3c //捕捉目的或来源MAC地址为e0-05-c5-44-b1-3c的封包。如果你想抓本机与所有外网通讯的数据包时，可以将这里的mac地址换成路由的mac地址即可。
src portrange 2000-2500  //捕捉来源为UDP或TCP，并且端口号在2000至2500范围内的封包。
not imcp  //显示除了icmp以外的所有封包。（icmp通常被ping工具使用）
src host 10.7.2.12 and not dst net 10.200.0.0/16 //显示来源IP地址为10.7.2.12，但目的地不是10.200.0.0/16的封包。
(src host 10.4.1.12 or src net 10.6.0.0/16) and tcp dst portrange 200-10000 and dst net 10.0.0.0/8  //捕捉来源IP为10.4.1.12或者来源网络为10.6.0.0/16，目的地TCP端口号在200至10000之间，并且目的位于网络 10.0.0.0/8内的所有封包。
src net 192.168.0.0/24
src net 192.168.0.0 mask 255.255.255.0  //捕捉源地址为192.168.0.0网络内的所有封包。

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

snmp || dns || icmp //显示SNMP或DNS或ICMP封包。
ip.addr == 10.1.1.1  //显示来源或目的IP地址为10.1.1.1的封包。
ip.src != 10.1.2.3 or ip.dst != 10.4.5.6  //显示来源不为10.1.2.3或者目的不为10.4.5.6的封包。
换句话说，显示的封包将会为：
来源IP：除了10.1.2.3以外任意；目的IP：任意
以及
来源IP：任意；目的IP：除了10.4.5.6以外任意
ip.src != 10.1.2.3 and ip.dst != 10.4.5.6  //显示来源不为10.1.2.3并且目的IP不为10.4.5.6的封包。
换句话说，显示的封包将会为：
来源IP：除了10.1.2.3以外任意；同时须满足，目的IP：除了10.4.5.6以外任意
tcp.port == 25  //显示来源或目的TCP端口号为25的封包。
tcp.dstport == 25  //显示目的TCP端口号为25的封包。
tcp.flags  //显示包含TCP标志的封包。
tcp.flags.syn == 0×02  //显示包含TCP SYN标志的封包。
如果过滤器的语法是正确的，表达式的背景呈绿色。如果呈红色，说明表达式有误。

## Example

### [wireshark如何扑捉无线局域网数据](https://www.zhihu.com/question/28838507)

[WLAN (IEEE 802.11) capture setup](https://wiki.wireshark.org/CaptureSetup/WLAN)

tcpdump capture with monitor mode: `sudo tcpdump -I`