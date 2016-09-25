# TCP/IP Notes

[The TCP/IP Guide](http://www.tcpipguide.com/free/index.htm)

### TIME_WAIT
`netstat -an|awk '/tcp/ {print $6}'|sort|uniq -c` or `netstat -n | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a, S[a]}'`  
常用的三个状态是：ESTABLISHED 表示正在通信，TIME_WAIT 表示主动关闭，CLOSE_WAIT 表示被动关闭  

[再叙TIME_WAIT](http://huoding.com/2013/12/31/316)

服务器保持了大量TIME_WAIT状态(基准数値是多少?)
HTTP关闭连接的不是客户端，而是服务器，所以web服务器也是会出现大量的TIME_WAIT的情况的  
解决思路: 让服务器快速回收和重用那些TIME_WAIT的资源, 对/etc/sysctl.conf文件进行修改, 改完之后执行`/sbin/sysctl -p`让参数生效

服务器保持了大量CLOSE_WAIT状态(基准数値是多少?)
如果一直保持在CLOSE_WAIT状态，说明在对方关闭连接之后服务器程序自己没有进一步发出ack信号。换句话说，就是在对方连接关闭之后，程序没有关闭连接，这个资源就一直被程序占着。  
解决思路: 检查代码是否没有关闭连接. 比如HttpClient未释放连接

#### TCP连接状态
  # netstat -an|awk '/tcp/ {print $6}'|sort|uniq -c

     16 CLOSING
    130 ESTABLISHED
    298 FIN_WAIT1
     13 FIN_WAIT2
      9 LAST_ACK
      7 LISTEN
    103 SYN_RECV
   5204 TIME_WAIT

状态：描述
CLOSED：无连接是活动的或正在进行
LISTEN：服务器在等待进入呼叫
SYN_RECV：一个连接请求已经到达，等待确认
SYN_SENT：应用已经开始，打开一个连接
ESTABLISHED：正常数据传输状态
FIN_WAIT1：应用说它已经完成
FIN_WAIT2：另一边已同意释放
ITMED_WAIT：等待所有分组死掉
CLOSING：两边同时尝试关闭
TIME_WAIT：另一边已初始化一个释放
LAST_ACK：等待所有分组死掉
