# Netty 中的粘包和拆包

[Reference](https://www.cnblogs.com/rickiyang/p/12904552.html)

Netty 底层是基于 TCP 协议来处理网络数据传输。我们知道 TCP 协议是面向字节流的协议，数据像流水一样在网络中传输那何来 “包” 的概念呢？

TCP是四层协议不负责数据逻辑的处理，但是数据在TCP层 “流” 的时候为了保证安全和节约效率会把 “流” 做一些分包处理，比如：

发送方约定了每次数据传输的最大包大小，超过该值的内容将会被拆分成两个包发送；
发送端 和 接收端 约定每次发送数据包长度并随着网络状况动态调整接收窗口大小，这里也会出现拆包的情况；
Netty 本身是基于 TCP 协议做的处理，如果它不去对 “流” 进行处理，到底这个 “流” 从哪到哪才是完整的数据就是个迷。我们先来看在 TCP 协议中有哪些步骤可能会让 “流” 不完整或者是出现粘滞的可能。

## 1. TCP 中可能出现粘包/拆包的原因

数据流在TCP协议下传播，因为协议本身对于流有一些规则的限制，这些规则会导致当前对端接收到的数据包不完整，归结原因有下面三种情况：

* Socket 缓冲区与滑动窗口
* MSS/MTU限制：MTU (Maxitum Transmission Unit,最大传输单元)是链路层对一次可以发送的最大数据的限制。MSS(Maxitum Segment Size,最大分段大小)是 TCP 报文中 data 部分的最大长度，是传输层对一次可以发送的最大数据的限制。
    `MSS = MTU(1500) -IP Header(20 or 40)-TCP Header(20)`
    由于 IPV4 和 IPV6 的长度不同，在 IPV4 中，以太网 MSS 可以达到 1460byte。在 IPV6 中，以太网 MSS 可以达到 1440byte。
* Nagle算法：尽可能发送大块数据，避免网络中充斥着许多小数据块。

## 2. 业界常用解决方案

### 1. 定长协议

指定一个报文具有固定长度。比如约定一个报文的长度是 5 字节，那么：

报文：1234，只有4字节，但是还差一个怎么办呢，不足部分用空格补齐。就变为：1234 。

如果不补齐空格，那么就会读到下一个报文的字节来填充上一个报文直到补齐为止，这样粘包了。

定长协议的优点是使用简单，缺点很明显：浪费带宽。

Netty 中提供了 `FixedLengthFrameDecoder` ，支持把固定的长度的字节数当做一个完整的消息进行解码。

### 2. 特殊字符分割协议

很好理解，在每一个你认为是一个完整的包的尾部添加指定的特殊字符，比如：\n，\r等等。

需要注意的是：约定的特殊字符要保证唯一性，不能出现在报文的正文中，否则就将正文一分为二了。

Netty 中提供了 `DelimiterBasedFrameDecoder` 根据特殊字符进行解码，`LineBasedFrameDecoder` 默认以换行符作为分隔符。

### 3. 变长协议

变长协议的核心就是：将消息分为消息头和消息体，消息头中标识当前完整的消息体长度。

发送方在发送数据之前先获取数据的二进制字节大小，然后在消息体前面添加消息大小；
接收方在解析消息时先获取消息大小，之后必须读到该大小的字节数才认为是完整的消息。
Netty 中提供了 `LengthFieldBasedFrameDecoder` ，通过 `LengthFieldPrepender` 来给实际的消息体添加 length 字段。
