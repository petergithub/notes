# Wireshark & tcpdump notes

[Manpage of TCPDUMP](http://www.tcpdump.org/manpages/tcpdump.1.html#lbAG)

## Recent

1. Display filter `ip.addr == 124.251.36.121 && tcp.port == portNumber`
2. `Follow TCP/UDP Stream`
3. Wireshark的`Analyze-->Expert Info Composite`，就可以在不同标签下看到不同级别的提示信息。比如重传的统计、连接的建立和重置统计，等等。在分析网络性能和连接问题时，我们经常需要借助这个功能
4. 单击`Statistics-->Service Response Time`，再选定协议名称，可以得到响应时间的统计表
5. 单击`Statistics-->TCP Stream Graph`，可以生成几类统计图。比如我曾经用Time-Sequence Graph (Stevens)
6. 单击`Statistics-->Summary`，可以看到一些统计信息，比如平均流量等

## tcpdump

[《神探tcpdump第一招》-linux命令五分钟系列之三十五](http://roclinux.cn/?p=2474)
[Linux tcpdump命令详解](https://www.cnblogs.com/ggjucheng/archive/2012/01/14/2322659.html)

tcpdump是一种嗅探器（sniffer），利用以太网的特性，通过将网卡适配器（NIC）置于混杂模式（promiscuous）来获取传输在网络中的信息包
一般计算机网卡都工作在非混杂模式下，此时网卡只接受来自网络端口的目的地址指向自己的数据。当网卡工作在混杂模式下时，网卡将来自接口的所有数据都捕获并交给相应的驱动程序。网卡的混杂模式一般在网络管理员分析网络数据作为网络故障诊断手段时用到，同时这个模式也被网络黑客利用来作为网络数据窃听的入口。在Linux操作系统中设置网卡混杂模式时需要管理员权限。在Windows操作系统和Linux操作系统中都有使用混杂模式的抓包工具，比如著名的开源软件Wireshark

### tcpdump 常用选项

* `-i` 是interface的含义，告诉tcpdump去监听哪一个网卡, any 抓所有网卡
* `-D, --list-interfaces` 捕获所有网络接口 Print the list of the network interfaces available
* `-s` 设置包大小限制值，如果你要追求高性能，建议把这个值调低，这样可以有效避免在大流量情况下的丢包现象
* `-v` 输出更详细的信息: 加了-v选项之后，在原有输出的基础之上，你还会看到tos值、ttl值、ID值、总长度、校验值等。
* `-nn` 当tcpdump遇到协议号或端口号时，不要将这些号码转换成对应的协议名称或端口名称。比如，众所周知21端口是FTP端口，我们希望显示21，而非tcpdump自作聪明的将它显示成FTP
* `-c` 是Count的含义，设置tcpdump抓几个包
* `-X` 把协议头和包内容都原原本本的显示出来（tcpdump会以16进制和ASCII的形式显示），这在进行协议分析时是绝对的利器. 对具体的数据包解释见[链接](http://roclinux.cn/?p=2820)
* `-XX` tcpdump会从以太网部分就开始显示网络包内容，而不是仅从网络层协议开始显示
* `-e` 增加以太网帧头部信息输出

至于上述值的含义，需要你专门去研究下IP头、TCP头的具体协议定义

* `-t` 输出时不打印时间戳
* `-l` 使得输出变为行缓冲. Linux/UNIX的标准I/O提供了全缓冲、行缓冲和无缓冲三种缓冲方式。标准错误是不带缓冲的，终端设备常为行缓冲，而其他情况默认都是全缓冲的
* `-q` 就是quiet output, 尽量少的打印一些信息
* `-N` 不打印出host 的域名部分. 设置此选项后 tcpdump 将会打印'nic' 而不是 'nic.ddn.mil'
* `-S` 打印TCP 数据包的顺序号时, 使用绝对的顺序号, 而不是相对的顺序号.(nt: 相对顺序号可理解为, 相对第一个TCP 包顺序号的差距,比如, 接受方收到第一个数据包的绝对顺序号为232323, 对于后来接收到的第2个,第3个数据包, tcpdump会打印其序列号为1, 2分别表示与第一个数据包的差距为1 和 2. 而如果此时-S 选项被设置, 对于后来接收到的第2个, 第3个数据包会打印出其绝对顺序号:232324, 232325)

* `-w` 将流量保存到文件中, 把raw packets（原始网络包）直接存储到文件中
* `-r` 读取raw packets文件进行了"流量回放"，网络包被"抓"的速度都按照历史进行了回放, 可以使用`-e`、`-l`和过滤表达式来对输出信息进行控制
* `-C 10` 限制每个转储文件的上限, 达到上限后将文件分卷(以MB为单位)
* `-W 5` 不仅限制每个卷的上限, 而且限制卷的总数

* `-A` tcpdump只会显示ASCII形式的数据包内容，不会再以十六进制形式显示
* `tcpdump -D` 列出所有可以选择的抓包对象
* `-F` 指定过滤表达式所在的文件 `tcpdump -i eth0 -c 1 -t -F filter.txt`

Common usage:

* `ssh target "sudo tcpdump -s 0 -U -n -i eth0 not port 22 -w -" | wireshark -k -i -` 在远端调用tcpdump抓包，通过管道传回本地，然后让wireshark抓包
* `tcpdump -l > dump.log & tail -f dump.log`
* 在屏幕上显示dump内容，并把内容输出到dump.log中 `tcpdump -l | tee dump.log`
* 抓取所有经过eth1，目的地址是192.168.1.254或192.168.1.200端口是80的TCP数据
    `tcpdump -i eth1 '((tcp) and (port 80) and ((dst host 192.168.1.254) or (dst host 192.168.1.200)))'`
* The following command prints only TCP segments with a source port between 7001 and 7005. `tcpdump 'tcp and tcp[0:2] > 7000 and tcp[0:2] <= 7005'`
* 抓取所有经过eth1，目标MAC地址是00:01:02:03:04:05的ICMP数据 `tcpdump -i eth1 '((icmp) and ((ether dst host 00:01:02:03:04:05)))'`
* 抓取所有经过eth1，目的网络是192.168，但目的主机不是192.168.1.200的TCP数据 `tcpdump -i eth1 '((tcp) and ((dst net 192.168) and (not dst host 192.168.1.200)))'`

* 去除特定流量 `tcpdump not icmp` 不抓 ICMP 的流量。
* 去除特定流量 `tcpdump dst 192.168.0.2 and src net and not icmp` 显示所有到 192.168.0.2 的 非 ICMP 的流量。
* 去掉非指定端口的流量 `tcpdump -vv src mars and not dst port 22` 显示来自不是 port 22 流量的主机的所有流量。
* 抓起 ICMP ping 包 `tcpdump dst 192.168.0.2 and src net and icmp`
* 抓取HTTP包 `tcpdump -i eth0 -lXvvennSs 0 tcp[20:2]=0x4745 or tcp[20:2]=0x4854` 0x4745 为"GET"前两个字母"GE",0x4854 为"HTTP"前两个字母"HT"
* 抓HTTP GET数据 `tcpdump -i eth1 'tcp[(tcp[12]>>2):4] = 0x47455420'`, GET的十六进制是47455420
* 抓 SMTP 数据 `tcpdump -i eth1 '((port 25) and (tcp[(tcp[12]>>2):4] = 0x4d41494c))'`，抓取数据区开始为"MAIL"的包，"MAIL"的十六进制为 0x4d41494c
* 抓SSH返回 `tcpdump -i eth1 'tcp[(tcp[12]>>2):4] = 0x5353482D'` SSH-的十六进制是0x5353482D
* 抓包并保存,重放
    `tcpdump -i eth0 -lXvvenns 1500 \( host 172.27.35.150 or host 172.27.33.222 \) -w tcpdump.pcapng &`
    `tcpdump -r tcpdump.pcapng`
    `tcpdump -i eno16780032 -lXvvennNs 1500 \( host 172.27.35.150 or host 172.27.33.222 \) -r tcpdump.pcapng`

```sh
tcpdump -i eth0 -nn -X 'port 53' -c 1
tcpdump -i eth0 -lXvvenns host 172.25.4.80 and port 2381
tcpdump -i eth0 -vvv -nnnn host 172.25.4.80 and port 2381
#  对 3306 端口进行抓包
tcpdump -i eth0 -s 0 -w /tmp/1.pcapng port 3306
```

### 过滤表达式

`man pcap-filter` packet filter syntax
表达式是大体可以分成三种过滤条件

* 类型: 主要包括host，net，port
* 方向: 主要包括src，dst，dst or src，dst and src
* 协议: 主要包括fddi，ip，arp，rarp，tcp，udp等类型
除了这三种类型的关键字之外，其他重要的关键字如下：gateway， broadcast，less， greater
还有三种逻辑运算，取非运算 `not` or `!`， 与运算是`and` or `&&`, 或运算是`or` or `||`

1. `host`：指定主机名或IP地址，例如`host roclinux.cn`或`host 202.112.18.34`
2. `net` ：指定网络段，例如`arp net 128.3`或`dst net 128.3`
3. `portrange`：指定端口区域，例如`src or dst portrange 6000-6008`
4. `protocol [ expr : size]`
    `protocol`指定协议名称，比如ip、tcp and udp、ether, fddi, arp, rarp, decnet, lat, sca, moprc, mopdl.
    `expr`用来指定数据报偏移量，表示从某个协议的数据报的第多少位开始提取内容，默认的起始位置是0；
    `size`表示从偏移量的位置开始提取多少个字节，可以设置为1、2、4, 默认提取1个字节
    例题：`ip[0] & 0xf != 5`
    IP协议的第0-4位，表示IP版本号，可以是IPv4（值为0100）或者IPv6（0110）；第5-8位表示首部长度，单位是"4字节"，如果首部长度为默认的20字节的话，此值应为5，即"0101″。ip[0]则是取这两个域的合体。0xf中的0x表示十六进制，f是十六进制数，转换成8位的二进制数是"0000 1111"。而5是一个十进制数，它转换成8位二进制数为"0000 0101″。
    这个语句中!=的左侧部分就是提取IP包首部长度域，如果首部长度不等于5，就满足过滤条件。言下之意也就是说，要求IP包的首部中含有可选字段

* `host IP`  `port 53` 监视指定主机和端口的数据包 `tcpdump host 210.27.48.1 and \ (port 53 or  port 21 \)`
* `tcpdump -i eth0 'udp'` 抓取udp包, 这里还可以把udp改为ether、ip、ip6、arp、tcp、rarp等
* `tcpdump -i eth0 'dst 8.8.8.8'` 设置src（source）和dst（destination）指定机器IP, 如果没有设置的话，默认是src or dst
* `tcpdump -i eth0 'dst port 53 or dst port 80'` 查目标机器端口是53或80的网络包
* `tcpdump 'port ftp or ftp-data'` 获取使用ftp端口和ftp数据端口的网络包, /etc/services存储着所有知名服务和传输层端口的对应关系
* `tcpdump 'tcp[tcpflags] & tcp-syn != 0 and not dst host qiyi.com'` 获取roclinux.cn和baidu.com之间建立TCP三次握手中第一个网络包，即带有SYN标记位的网络包，另外，目的主机不能是qiyi.com
* 要提取TCP协议的SYN、ACK、FIN标识字段，语法是`tcp[tcpflags] & tcp-syn`, `tcp[tcpflags] & tcp-ack`, `tcp[tcpflags] & tcp-fin`
* 查看哪些ICMP包中"目标不可达、主机不可达"的包的表达式`icmp[0:2]==0x0301`
* 提取TCP协议里的SYN-ACK数据包，不但可以使用上面的方法，也可以直接使用最本质的方法 `tcp[13]==18`
* 如果要抓取一个区间内的端口，可以使用portrange语法: `tcpdump -i eth0 -nn 'portrange 52-55' -c 1  -XX`

## Wireshark Filter

Wireshark 编辑 > 首选项 > 协议 > 找到 TLS > RSA keys list > Edit > Keyfile > 更改目录 确保路径正确

### Capture filter

`host domainName`
`host IP`
`port portNumber`

#### Protocol（协议）

可能的值: ether, fddi, ip, arp, rarp, decnet, lat, sca, moprc, mopdl, tcp and udp.
如果没有特别指明是什么协议，则默认使用所有支持的协议。

#### Direction（方向）

可能的值: src, dst, src and dst, src or dst
如果没有特别指明来源或目的地，则默认使用 "src or dst" 作为关键字。
例如，"host 10.2.2.2″与"src or dst host 10.2.2.2″是一样的。

#### Host(s)

可能的值： net, port, host, portrange.
如果没有指定此值，则默认使用"host"关键字。
例如，"src 10.1.1.1″与"src host 10.1.1.1″相同。

#### Logical Operations（逻辑运算）

可能的值：not, and, or.
否("not")具有最高的优先级。或("or")和与("and")具有相同的优先级，运算时从左至右进行。
例如，
"not tcp port 3128 and tcp port 23″与"(not tcp port 3128) and tcp port 23″相同。
"not tcp port 3128 and tcp port 23″与"not (tcp port 3128 and tcp port 23)"不同。

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

```sh
http.host == login.tclclouds.com
ip.addr == 124.251.36.121 or ip.addr == 124.251.36.122
http and ip.addr == 124.251.36.121 and ip.dst ==124.251.43.33
tcp.port == portNumber

# wireshark http数据包过滤条件列表

http.host==6san.com
http.host contains 6san.com
# 过滤经过指定域名的http数据包，这里的host值不一定是请求中的域名

http.response.code==302
# 过滤http响应状态码为302的数据包
http.response==1
# 过滤所有的http响应包

http.request==1
# 过滤所有的http请求，貌似也可以使用http.request
http.request.method==POST
# wireshark过滤所有请求方式为POST的http请求包，注意POST为大写

http.cookie contains guid
# 过滤含有指定cookie的http数据包

http.request.uri=="/online/setpoint"
# 过滤请求的uri，取值是域名后的部分

http.request.full_uri==" http://task.browser.360.cn/online/setpoint"
# 过滤含域名的整个url则需要使用http.request.full_uri

http.server contains "nginx"
# 过滤http头中server字段含有nginx字符的数据包
http.content_type == "text/html"
# 过滤content_type是text/html的http响应、post包，即根据文件类型过滤http数据包

http.content_encoding == "gzip"
# 过滤content_encoding是gzip的http包
http.transfer_encoding == "chunked"
# 根据transfer_encoding过滤
http.content_length == 279
http.content_length_header == "279"
# 根据content_length的数值过滤

http.server
# 过滤所有含有http头中含有server字段的数据包

http.request.version == "HTTP/1.1"
# 过滤HTTP/1.1版本的http包，包括请求和响应
http.response.phrase == "OK"
# 过滤http响应中的phrase

snmp || dns || icmp # 显示SNMP或DNS或ICMP封包。
ip.addr == 10.1.1.1  # 显示来源或目的IP地址为10.1.1.1的封包。
ip.src != 10.1.2.3 or ip.dst != 10.4.5.6  # 显示来源不为10.1.2.3或者目的不为10.4.5.6的封包。
换句话说，显示的封包将会为：
来源IP：除了10.1.2.3以外任意；目的IP：任意
以及
来源IP：任意；目的IP：除了10.4.5.6以外任意
ip.src != 10.1.2.3 and ip.dst != 10.4.5.6  # 显示来源不为10.1.2.3并且目的IP不为10.4.5.6的封包。
换句话说，显示的封包将会为：
来源IP：除了10.1.2.3以外任意；同时须满足，目的IP：除了10.4.5.6以外任意
tcp.port == 25  # 显示来源或目的TCP端口号为25的封包。
tcp.dstport == 25  # 显示目的TCP端口号为25的封包。
tcp.flags  # 显示包含TCP标志的封包。
tcp.flags.syn == 0×02  # 显示包含TCP SYN标志的封包。
# 如果过滤器的语法是正确的，表达式的背景呈绿色。如果呈红色，说明表达式有误。
```

## Example

### [wireshark如何扑捉无线局域网数据](https://www.zhihu.com/question/28838507)

[WLAN (IEEE 802.11) capture setup](https://wiki.wireshark.org/CaptureSetup/WLAN)

tcpdump capture with monitor mode: `sudo tcpdump -I`
