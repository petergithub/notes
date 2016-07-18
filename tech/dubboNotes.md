# Dubbo notes

[TOC]

## Question
DefaultFuture
Dubbo管理控制台 except dubbo-admin

1) hessian serialization bug?:  private entity id is missing if parent class id existing

TCP粘包英文 tcp stick package/unpacking 
Netty FixedLengthFrameDecoder
Fragmentation should be transparent to a TCP application. Keep in mind that TCP is a stream protocol: you get a stream of data, not packets! If you are building your application based on the idea of complete data packets then you will have problems unless you add an abstraction layer to assemble whole packets from the stream and then pass the packets up to the application.
A the "application layer" a TCP packet (well, segment really; TCP at its own layer doesn't know from packets) is never fragmented, since it doesn't exist. The application layer is where you see the data as a stream of bytes, delivered reliably and in order.

在启动脚本里面添加配置如下,以防止多个应用启动lock同一个文件dubbo-registry-zookeeper1.cache
`-Ddubbo.registry.file=/home/work/.dubbo/dubbo-registry-zookeeper1-<PROJECT>.cache`
Warn:
`Failed to save registry store file, cause: Can not lock the registry cache file /home/work/.dubbo/dubbo-registry-zookeeper1.cache, ignore and retry later, maybe multi java process use the file, please config: dubbo.registry.file=xxx.properties`

###
分布式架构下系统间交互的5种通信模式
1. request/response模式（同步模式）：客户端发起请求一直阻塞到服务端返回请求为止。
2. Callback（异步模式）：客户端发送一个RPC请求给服务器，服务端处理后再发送一个消息给消息发送端提供的callback端点，此类情况非常合适以下场景：A组件发送RPC请求给B，B处理完成后，需要通知A组件做后续处理。
3. Future模式：客户端发送完请求后，继续做自己的事情，返回一个包含消息结果的Future对象。客户端需要使用返回结果时，使用Future对象的.get(),如果此时没有结果返回的话，会一直阻塞到有结果返回为止。
4. Oneway模式：客户端调用完继续执行，不管接收端是否成功。
5. Reliable模式：为保证通信可靠，将借助于消息中心来实现消息的可靠送达，请求将做持久化存储，在接收方在线时做送达，并由消息中心保证异常重试。

## Usage
只有group，interface，version是服务的匹配条件，三者决定是不是同一个服务，其它配置项均为调优和治理参数。
服务分组
	当一个接口有多种实现时，可以用group区分。
<dubbo:service group="feedback" interface="com.xxx.IndexService" />
<dubbo:service group="member" interface="com.xxx.IndexService" />
多版本
	当一个接口实现，出现不兼容升级时，可以用版本号过渡，版本号不同的服务相互间不引用。
在低压力时间段，先升级一半提供者为新版本
再将所有消费者升级为新版本
然后将剩下的一半提供者升级为新版本

消费端实现了对于服务端调用的负载均衡算法、支持服务的集群

## Introduction
### dubbo一次接口调用的过程
http://dubbo.io/Developer+Guide-zh.htm#DeveloperGuide-zh-远程调用细节

![消费和提供者](http://dubbo.io/dubbo_rpc_invoke.jpg-version=1&modificationDate=1335250516000.jpg)
Invoker是Dubbo领域模型中非常重要的一个概念，很多设计思路都是向它靠拢。这就使得Invoker渗透在整个实现代码里

#### 提供者暴露一个服务的详细过程
![提供者暴露一个服务的详细过程](http://dubbo.io/dubbo_rpc_export.jpg-version=1&modificationDate=1335250516000.jpg)
上图是服务提供者暴露服务的主过程：
首先ServiceConfig类拿到对外提供服务的实际类ref(如：HelloWorldImpl),然后通过ProxyFactory类的getInvoker方法使用ref生成一个AbstractProxyInvoker实例，到这一步就完成具体服务到Invoker的转化。接下来就是Invoker转换到Exporter的过程。

##### Dubbo的实现
Dubbo协议的Invoker转为Exporter发生在DubboProtocol类的export方法，它主要是打开socket侦听服务，并接收客户端发来的各种请求，通讯细节由Dubbo自己实现。

##### RMI的实现
RMI协议的Invoker转为Exporter发生在RmiProtocol类的export方法，
它通过Spring或Dubbo或JDK来实现RMI服务，通讯细节这一块由JDK底层来实现，这就省了不少工作量。

#### 消费者消费一个服务的详细过程
![消费者消费一个服务的详细过程](http://dubbo.io/dubbo_rpc_export.jpg-version=1&modificationDate=1335250516000.jpg)
上图是服务消费的主过程：
首先ReferenceConfig类的init方法调用Protocol的refer方法生成Invoker实例(如上图中的红色部分)，这是服务消费的关键。接下来把Invoker转换为客户端需要的接口(如：HelloWorld)。
关于每种协议如RMI/Dubbo/Web service等它们在调用refer方法生成Invoker实例的细节和上一章节所描述的类似。

### 通信机制
网络传输扩展
com.alibaba.dubbo.remoting.Transporter
com.alibaba.dubbo.remoting.Server
com.alibaba.dubbo.remoting.Client

缺省协议，使用基于netty3.2.5.Final+hessian3.2.1交互。
连接个数：单连接
连接方式：长连接
传输协议：TCP
传输方式：NIO异步传输
序列化：Hessian二进制序列化
适用范围：传入传出参数数据包较小（建议小于100K），消费者比提供者个数多，单一消费者无法压满提供者，尽量不要用dubbo协议传输大文件或超大字符串。
适用场景：常规远程服务方法调用

为什么要消费者比提供者个数多：
因dubbo协议采用单一长连接，
假设网络为千兆网卡(1024Mbit=128MByte)，
根据测试经验数据每条连接最多只能压满7MByte(不同的环境可能不一样，供参考)，
理论上1个服务提供者需要20个服务消费者才能压满网卡。

为什么不能传大包：
因dubbo协议采用单一长连接，
如果每次请求的数据包大小为500KByte，假设网络为千兆网卡(1024Mbit=128MByte)，每条连接最大7MByte(不同的环境可能不一样，供参考)，
单个服务提供者的TPS(每秒处理事务数)最大为：128MByte / 500KByte = 262。
单个消费者调用单个服务提供者的TPS(每秒处理事务数)最大为：7MByte / 500KByte = 14。
如果能接受，可以考虑使用，否则网络将成为瓶颈。

为什么采用异步单一长连接：
因为服务的现状大都是服务提供者少，通常只有几台机器，
而服务的消费者多，可能整个网站都在访问该服务，
比如Morgan的提供者只有6台提供者，却有上百台消费者，每天有1.5亿次调用，
如果采用常规的hessian服务，服务提供者很容易就被压跨，
通过单一连接，保证单一消费者不会压死提供者，
长连接，减少连接握手验证等，
并使用异步IO，复用线程池，防止C10K问题。 

dubbo 通信机制 分布式架构下系统间交互的5种通信模式
1. request/response模式（同步模式）：客户端发起请求一直阻塞到服务端返回请求为止。
2. Callback（异步模式）：客户端发送一个RPC请求给服务器，服务端处理后再发送一个消息给消息发送端提供的callback端点，此类情况非常合适以下场景：A组件发送RPC请求给B，B处理完成后，需要通知A组件做后续处理。
3. Future模式：客户端发送完请求后，继续做自己的事情，返回一个包含消息结果的Future对象。客户端需要使用返回结果时，使用Future对象的.get(),如果此时没有结果返回的话，会一直阻塞到有结果返回为止。
4. Oneway模式：客户端调用完继续执行，不管接收端是否成功。
5. Reliable模式：为保证通信可靠，将借助于消息中心来实现消息的可靠送达，请求将做持久化存储，在接收方在线时做送达，并由消息中心保证异常重试。

dubbo协议默认使用Netty作为高性能异步通信框架，为分布式服务节点之间提供高性能的NIO客户端和服务端通信
dubbo协议下的单一长连接如何理解
在长连接的应用场景下，client端一般不会主动关闭它们之间的连接，Client与server之间的连接如果一直不关闭的话，会存在一个问题，随着客户端连接越来越多，server早晚有扛不住的时候，这时候server端需要采取一些策略，如关闭一些长时间没有读写事件发生的连接
dubbo how to handle this?单一
维护任何一个长连接都需要心跳机制

Dubbo的性能如何？compare with http connection
采用NIO复用单一长连接，并使用线程池并发处理请求，减少握手和加大并发效率，性能较好（推荐使用） 
Dubbo通过长连接减少握手，通过NIO及线程池在单连接上并发拼包处理消息，通过二进制流压缩数据，比常规HTTP等短连接协议更快。在阿里巴巴内部，每天支撑2000多个服务，30多亿访问量，最大单机支撑每天近1亿访问量

#### 序列化
序列化扩展
com.alibaba.dubbo.common.serialize.Serialization
com.alibaba.dubbo.common.serialize.ObjectInput
com.alibaba.dubbo.common.serialize.ObjectOutput
Hessian Serialization 	Stable 	性能较好，多语言支持（推荐使用） 	Hessian的各版本兼容性不好，可能和应用使用的Hessian冲突，Dubbo内嵌了hessian3.2.1的源码 

DubboCodec类中序列化工作的入口
com.alibaba.dubbo.rpc.protocol.dubbo.DubboCodec.decodeBody(Channel, InputStream, byte[])
com.alibaba.dubbo.rpc.protocol.dubbo.DubboCodec.deserialize(Serialization, URL, InputStream)

序列化方式在META-INF/dubbo/com.alibaba.dubbo.common.serialize.Serialization

## Code Logic
client(url: dubbo://52.0.147.224:20893/com.tcl.settlement.api.service.ISettleService?anyhost=true&application=operation-web&check=false&codec=dubbo&dubbo=2.5.3&heartbeat=60000&interface=com.tcl.settlement.api.service.ISettleService&loadbalance=random&methods=getSettleStatements,getSettleCards&owner=yangchen&payload=209715200&pid=2203&retries=2&revision=1.0.0-20151118.094911-5&side=consumer&timeout=100000&timestamp=1449214275206&version=1.0.0)
### Miscellaneous(Misc)
(1)com.alibaba.dubbo.container.Main 
(2)java.util.ServiceLoader 
(3)com.alibaba.dubbo.common.extension.ExtensionLoader 
(4)com.alibaba.dubbo.rpc.protocol.ProtocolFilterWrapper 
(5)com.alibaba.dubbo.demo.consumer.DemoConsumer 
(6)com.alibaba.dubbo.demo.provider.DemoProvider 
(7)com.alibaba.dubbo.container.spring.SpringContainer 
(8)com.alibaba.dubbo.config.spring.schema.DubboNamespaceHandler 
(9)com.alibaba.dubbo.config.spring.schema.DubboBeanDefinitionParser 
(A)com.alibaba.dubbo.config.spring.ServiceBean 
(B)com.alibaba.dubbo.config.spring.ReferenceBean 
 (1)读代码第三招(debug)和一个心法(思路) (2)钩子 ShutdownHook，kill 和man的使用 (3)守护线程 Thread.setDaemon(true) (4)同步块范围对象控制，CountDownLatch (5)SPI基本思想，DCL，动态编译，包装调用链 (6)Dubbo RPC调用的实际动作 (7)jenv(jevn.io)管理java环境 (8)Spring的一点handler和listener知识

### Dubbo project
可以通过Dubbo的代码（使用Maven管理）组织，与上面的模块进行比较。简单说明各个包的情况：
dubbo-common 公共逻辑模块，包括Util类和通用模型。
dubbo-remoting 远程通讯模块，相当于Dubbo协议的实现，如果RPC用RMI协议则不需要使用此包。
dubbo-rpc 远程调用模块，抽象各种协议，以及动态代理，只包含一对一的调用，不关心集群的管理。
dubbo-cluster 集群模块，将多个服务提供方伪装为一个提供方，包括：负载均衡、容错、路由等，集群的地址列表可以是静态配置的，也可以是由注册中心下发。
dubbo-registry 注册中心模块，基于注册中心下发地址的集群方式，以及对各种注册中心的抽象。
dubbo-monitor 监控模块，统计服务调用次数，调用时间的，调用链跟踪的服务。
dubbo-config 配置模块，是Dubbo对外的API，用户通过Config使用Dubbo，隐藏Dubbo所有细节。
dubbo-container 容器模块，是一个Standalone的容器，以简单的Main加载Spring启动，因为服务通常不需要Tomcat/JBoss等Web容器的特性，没必要用Web容器去加载服务。

服务接口层（Service）：该层是与实际业务逻辑相关的，根据服务提供方和服务消费方的业务设计对应的接口和实现。
配置层（Config）：对外配置接口，以ServiceConfig和ReferenceConfig为中心，可以直接new配置类，也可以通过spring解析配置生成配置类。

服务代理层（Proxy）：服务接口透明代理，生成服务的客户端Stub和服务器端Skeleton，以ServiceProxy为中心，扩展接口为ProxyFactory。

服务注册层（Registry）：封装服务地址的注册与发现，以服务URL为中心，扩展接口为RegistryFactory、Registry和RegistryService。可能没有服务注册中心，此时服务提供方直接暴露服务。
集群层（Cluster）：封装多个提供者的路由及负载均衡，并桥接注册中心，以Invoker为中心，扩展接口为Cluster、Directory、Router和LoadBalance。将多个服务提供方组合为一个服务提供方，实现对服务消费方来透明，只需要与一个服务提供方进行交互。
监控层（Monitor）：RPC调用次数和调用时间监控，以Statistics为中心，扩展接口为MonitorFactory、Monitor和MonitorService。

远程调用层（Protocol）：封将RPC调用，以Invocation和Result为中心，扩展接口为Protocol、Invoker和Exporter。Protocol是服务域，它是Invoker暴露和引用的主功能入口，它负责Invoker的生命周期管理。Invoker是实体域，它是Dubbo的核心模型，其它模型都向它靠扰，或转换成它，它代表一个可执行体，可向它发起invoke调用，它有可能是一个本地的实现，也可能是一个远程的实现，也可能一个集群实现。

信息交换层（Exchange）：封装请求响应模式，同步转异步，以Request和Response为中心，扩展接口为Exchanger、ExchangeChannel、ExchangeClient和ExchangeServer。

网络传输层（Transport）：抽象mina和netty为统一接口，以Message为中心，扩展接口为Channel、Transporter、Client、Server和Codec。

数据序列化层（Serialize）：可复用的一些工具，扩展接口为Serialization、 ObjectInput、ObjectOutput和ThreadPool。

从上图可以看出，Dubbo对于服务提供方和服务消费方，从框架的10层中分别提供了各自需要关心和扩展的接口，构建整个服务生态系统（服务提供方和服务消费方本身就是一个以服务为中心的）。
根据官方提供的，对于上述各层之间关系的描述，如下所示：
在RPC中，Protocol是核心层，也就是只要有Protocol + Invoker + Exporter就可以完成非透明的RPC调用，然后在Invoker的主过程上Filter拦截点。
图中的Consumer和Provider是抽象概念，只是想让看图者更直观的了解哪些类分属于客户端与服务器端，不用Client和
Server的原因是Dubbo在很多场景下都使用Provider、Consumer、Registry、Monitor划分逻辑拓普节点，保持统一概
念。
而Cluster是外围概念，所以Cluster的目的是将多个Invoker伪装成一个Invoker，这样其它人只要关注Protocol层
Invoker即可，加上Cluster或者去掉Cluster对其它层都不会造成影响，因为只有一个提供者时，是不需要Cluster的。
Proxy层封装了所有接口的透明化代理，而在其它层都以Invoker为中心，只有到了暴露给用户使用时，才用Proxy将Invoker转成
接口，或将接口实现转成Invoker，也就是去掉Proxy层RPC是可以Run的，只是不那么透明，不那么看起来像调本地服务一样调远程服务。
而Remoting实现是Dubbo协议的实现，如果你选择RMI协议，整个Remoting都不会用上，Remoting内部再划为
Transport传输层和Exchange信息交换层，Transport层只负责单向消息传输，是对Mina、Netty、Grizzly的抽象，它
也可以扩展UDP传输，而Exchange层是在传输层之上封装了Request-Response语义。
Registry和Monitor实际上不算一层，而是一个独立的节点，只是为了全局概览，用层的方式画在一起。


整体上按照分层结构进行分包，与分层的不同点在于：
container为服务容器，用于部署运行服务，没有在层中画出。
protocol层和proxy层都放在rpc模块中，这两层是rpc的核心，在不需要集群时(只有一个提供者)，可以只使用这两层完成rpc调用。
transport层和exchange层都放在remoting模块中，为rpc调用的通讯基础。
serialize层放在common模块中，以便更大程度复用。


### Remote模块分析
客户端: dubbo协议，netty实现

#### 发送请求：
```
HeaderExchangeClient --> request -->
   HeaderExchangeChannel-->request--> 
-->req=new Request()
-->DefaultFuture future = new DefaultFuture(channel, req, timeout);
-->NettyClient->send(req)
-->NettyChannel-->send(req,boolean sent) 
-->NettyHander-->writeRequested
---> encode 
--->Netty->channel+writebuffer,writetask （放到IO线程的任务队列）
--->NioWorker -->processWriteTaskQueue
--->write0 （在IO线程里发送数据）
--->NettyClient-->sent
--->DefaultChannelHandler-->sent
--->HeaderExchangeHandler-->sent
--->DubboProtocol requestHandler -->sent
--->DefaultFuture.sent(channel, request);
--->DefaultFuture.doSent()  标记数据发送完的时间
```

#### 接收返回结果：
```
--->decode
NettyHander --> messageReceived
--->DefaultChannelHandler --->received
--> （O线程解码完后，交给线程池处理。）
executor.execute(new ChannelEventRunnable(channel, handler ,ChannelState.RECEIVED, message));
-->ChannelEventRunnable -->run 
-->HeaderExchangeHandler.received
----->HeaderExchangeHandler--》handleResponse
--->DefaultFuture.received(channel, response);
com.alibaba.dubbo.remoting.transport.netty.NettyServer.doOpen()
```
dubbo处理handler所使用的线程并非来自netty提供的I/O Work线程，而是dubbo自身来维护的一个java原生线程池，源码见com.alibaba.dubbo.remoting.transport.dispatcher.WrappedChannelHandler。why？

#### Channel events
`com.alibaba.dubbo.remoting.transport.dispatcher.ChannelEventRunnable.run()`

#### Consumer send message
```
Thread [main] (Suspended (breakpoint at line 233 in DefaultFuture))	
	DefaultFuture.doSent() line: 233	
	DefaultFuture.sent(Channel, Request) line: 228	
	HeaderExchangeHandler.sent(Channel, Object) line: 137	
	DecodeHandler(AbstractChannelHandlerDelegate).sent(Channel, Object) line: 36	
	AllChannelHandler(WrappedChannelHandler).sent(Channel, Object) line: 78	
	HeartbeatHandler.sent(Channel, Object) line: 58	
	MultiMessageHandler(AbstractChannelHandlerDelegate).sent(Channel, Object) line: 36	
	NettyClient(AbstractPeer).sent(Channel, Object) line: 116	
	NettyHandler.writeRequested(ChannelHandlerContext, MessageEvent) line: 102	
	NettyHandler(SimpleChannelHandler).handleDownstream(ChannelHandlerContext, ChannelEvent) line: 266	
	DefaultChannelPipeline.sendDownstream(DefaultChannelPipeline$DefaultChannelHandlerContext, ChannelEvent) line: 591	
	DefaultChannelPipeline.sendDownstream(ChannelEvent) line: 582	
	Channels.write(Channel, Object, SocketAddress) line: 611	
	Channels.write(Channel, Object) line: 578	
	NioClientSocketChannel(AbstractChannel).write(Object) line: 251	
	NettyChannel.send(Object, boolean) line: 98	
	NettyClient(AbstractClient).send(Object, boolean) line: 270	
	NettyClient(AbstractPeer).send(Object) line: 51	
	HeaderExchangeChannel.request(Object, int) line: 112	
	HeaderExchangeClient.request(Object, int) line: 91	
	ReferenceCountExchangeClient.request(Object, int) line: 81	
	DubboInvoker<T>.doInvoke(Invocation) line: 96	
	DubboInvoker<T>(AbstractInvoker<T>).invoke(Invocation) line: 144	
	ListenerInvokerWrapper<T>.invoke(Invocation) line: 74	
	MonitorFilter.invoke(Invoker<?>, Invocation) line: 75	
	ProtocolFilterWrapper$1.invoke(Invocation) line: 91	
	FutureFilter.invoke(Invoker<?>, Invocation) line: 53	
	ProtocolFilterWrapper$1.invoke(Invocation) line: 91	
	ConsumerContextFilter.invoke(Invoker<?>, Invocation) line: 48	
	ProtocolFilterWrapper$1.invoke(Invocation) line: 91	
	RegistryDirectory$InvokerDelegete<T>(InvokerWrapper<T>).invoke(Invocation) line: 53	
	FailoverClusterInvoker<T>.doInvoke(Invocation, List<Invoker<T>>, LoadBalance) line: 77	
	FailoverClusterInvoker<T>(AbstractClusterInvoker<T>).invoke(Invocation) line: 227	
	MockClusterInvoker<T>.invoke(Invocation) line: 72	
	InvokerInvocationHandler.invoke(Object, Method, Object[]) line: 52	
	proxy0.sayHello(String) line: not available	
	Consumer.main(String[]) line: 40	
```

#### Consumer await()
`done.await(timeout, TimeUnit.MILLISECONDS)`
```
Thread [main] (Suspended (breakpoint at line 96 in DefaultFuture))	
	DefaultFuture.get(int) line: 96	
	DefaultFuture.get() line: 84	
	DubboInvoker<T>.doInvoke(Invocation) line: 96	
	DubboInvoker<T>(AbstractInvoker<T>).invoke(Invocation) line: 144	
	ListenerInvokerWrapper<T>.invoke(Invocation) line: 74	
	MonitorFilter.invoke(Invoker<?>, Invocation) line: 75	
	ProtocolFilterWrapper$1.invoke(Invocation) line: 91	
	FutureFilter.invoke(Invoker<?>, Invocation) line: 53	
	ProtocolFilterWrapper$1.invoke(Invocation) line: 91	
	ConsumerContextFilter.invoke(Invoker<?>, Invocation) line: 48	
	ProtocolFilterWrapper$1.invoke(Invocation) line: 91	
	RegistryDirectory$InvokerDelegete<T>(InvokerWrapper<T>).invoke(Invocation) line: 53	
	FailoverClusterInvoker<T>.doInvoke(Invocation, List<Invoker<T>>, LoadBalance) line: 77	
	FailoverClusterInvoker<T>(AbstractClusterInvoker<T>).invoke(Invocation) line: 227	
	MockClusterInvoker<T>.invoke(Invocation) line: 72	
	InvokerInvocationHandler.invoke(Object, Method, Object[]) line: 52	
	proxy0.sayHello(String) line: not available	
	Consumer.main(String[]) line: 41	
```

#### Consumer messageReceived
```
Daemon Thread [New I/O client worker #1-1] (Suspended (breakpoint at line 116 in DubboCodec))	
	DubboCodec.decodeBody(Channel, InputStream, byte[]) line: 116	
	DubboCodec(ExchangeCodec).decode(Channel, ChannelBuffer, int, byte[]) line: 126	
	DubboCodec(ExchangeCodec).decode(Channel, ChannelBuffer) line: 87	
	DubboCountCodec.decode(Channel, ChannelBuffer) line: 46	
	NettyCodecAdapter$InternalDecoder.messageReceived(ChannelHandlerContext, MessageEvent) line: 134	
	NettyCodecAdapter$InternalDecoder(SimpleChannelUpstreamHandler).handleUpstream(ChannelHandlerContext, ChannelEvent) line: 80	
	DefaultChannelPipeline.sendUpstream(DefaultChannelPipeline$DefaultChannelHandlerContext, ChannelEvent) line: 564	
	DefaultChannelPipeline.sendUpstream(ChannelEvent) line: 559	
	Channels.fireMessageReceived(Channel, Object, SocketAddress) line: 274	
	Channels.fireMessageReceived(Channel, Object) line: 261	
	NioWorker.read(SelectionKey) line: 349	
	NioWorker.processSelectedKeys(Set<SelectionKey>) line: 280	
	NioWorker.run() line: 200	
	ThreadRenamingRunnable.run() line: 108	
	DeadLockProofWorker$1.run() line: 44	
	ThreadPoolExecutor.runWorker(ThreadPoolExecutor$Worker) line: 1142	
	ThreadPoolExecutor$Worker.run() line: 617	
	Thread.run() line: 745	
	
com.alibaba.dubbo.remoting.transport.dispatcher.ChannelEventRunnable.run()
Daemon Thread [DubboClientHandler-172.17.42.1:20880-thread-1] (Suspended (breakpoint at line 57 in ChannelEventRunnable$1))	
ChannelEventRunnable$1.<clinit>() line: 57	
ChannelEventRunnable.run() line: 57	
ThreadPoolExecutor.runWorker(ThreadPoolExecutor$Worker) line: 1142	
ThreadPoolExecutor$Worker.run() line: 617	
Thread.run() line: 745	
```

#### Consumer signal
`done.signal()`
```
Daemon Thread [DubboClientHandler-172.17.42.1:20880-thread-2] (Suspended (breakpoint at line 257 in DefaultFuture))	
	DefaultFuture.doReceived(Response) line: 257	
	DefaultFuture.received(Channel, Response) line: 240	
	HeaderExchangeHandler.handleResponse(Channel, Response) line: 96	
	HeaderExchangeHandler.received(Channel, Object) line: 177	
	DecodeHandler.received(Channel, Object) line: 52	
	ChannelEventRunnable.run() line: 82	
	ThreadPoolExecutor.runWorker(ThreadPoolExecutor$Worker) line: 1142	
	ThreadPoolExecutor$Worker.run() line: 617	
	Thread.run() line: 745	
```

#### Registry 

#### Notify



### dubbo的编解码，序列化和通信 
http://blog.kazaff.me/2015/02/11/dubbo的编解码，序列化和通信/

#### 通信实现
DubboProtocol.export()  -->  openServer()  -->  createServer() -> HeaderExchanger.bind
```
	com.alibaba.dubbo.rpc.protocol.dubbo.DubboProtocol.export(Invoker<T>)
->	openServer() -> createServer()
->	com.alibaba.dubbo.remoting.exchange.Exchangers.bind(URL, ExchangeHandler)
->	com.alibaba.dubbo.remoting.exchange.support.header.HeaderExchanger.bind(URL, ExchangeHandler)
->	com.alibaba.dubbo.remoting.Transporters.bind(URL, ChannelHandler...)
->	{NettyTransporter,MinaTransporter,GrizzlyTransporter}
->	com.alibaba.dubbo.remoting.transport.netty.NettyTransporter.bind(URL, ChannelHandler)
->	com.alibaba.dubbo.remoting.transport.netty.NettyServer.NettyServer(URL, ChannelHandler)
(->	com.alibaba.dubbo.remoting.transport.AbstractServer.AbstractServer(URL, ChannelHandler)
->	{NettyServer,MinaServer,GrizzlyServer}.doOpen())
->	com.alibaba.dubbo.remoting.transport.netty.NettyServer.doOpen()
```

#### 编解码
```
com.alibaba.dubbo.remoting.transport.netty.NettyServer.doOpen() {
	...
 	bootstrap.setPipelineFactory(new ChannelPipelineFactory() {
	    public ChannelPipeline getPipeline() {
	        NettyCodecAdapter adapter = new NettyCodecAdapter(getCodec() ,getUrl(), NettyServer.this);
	        ChannelPipeline pipeline = Channels.pipeline();
	        /*int idleTimeout = getIdleTimeout();
	        if (idleTimeout > 10000) {
	            pipeline.addLast("timer", new IdleStateHandler(timer, idleTimeout / 1000, 0, 0));
	        }*/
	        pipeline.addLast("decoder", adapter.getDecoder());
	        pipeline.addLast("encoder", adapter.getEncoder());
	        pipeline.addLast("handler", nettyHandler);
	        return pipeline;
	    }
	});
	...
}

com.alibaba.dubbo.remoting.transport.AbstractEndpoint.getCodec() ->	getChannelCodec(URL)
String codecName = url.getParameter(Constants.CODEC_KEY, "telnet");
codecName is added in `com.alibaba.dubbo.rpc.protocol.dubbo.DubboProtocol.createServer(URL)`
url = url.addParameter(Constants.CODEC_KEY, Version.isCompatibleVersion() ? COMPATIBLE_CODEC_NAME : DubboCodec.NAME);

adapter.getDecoder()
	com.alibaba.dubbo.remoting.transport.netty.NettyCodecAdapter.getDecoder()
->	com.alibaba.dubbo.remoting.transport.netty.NettyCodecAdapter.InternalDecoder

adapter.getEncoder()
	com.alibaba.dubbo.remoting.transport.netty.NettyCodecAdapter.getEncoder()
->	com.alibaba.dubbo.remoting.transport.netty.NettyCodecAdapter.InternalEncoder
```
the implementation can be found in file: META-INF/dubbo/internal/com.alibaba.dubbo.remoting.Codec2

##### Dubbo处理TCP拆包粘包问题
http://bbs.dubboclub.net/read-46.html
在TCP网络传输工程中，由于TCP包的缓存大小限制，每次请求数据有可能不在一个TCP包里面，或者也可能多个请求的数据在一个TCP包里面。那么如果合理的decode接受的TCP数据很重要，需要考虑TCP拆包和粘包的问题。我们知道在Netty提供了各种Decoder来解决此类问题，比如LineBasedFrameDecoder,LengthFieldBasedFrameDecoder等等，但是这些都是处理一些通用简单的协议栈，并不能处理高度自定义的协议栈。由于dubbo协议是自定义协议栈，并且包含消息头和消息体两部分，而消息头中包含消息类型、协议版本、协议魔数以及playload长度等信息。所以使用Netty自带的处理方案可能无法满足Dubbo解析自身协议的需求，所以需要Dubbo自己来处理，那自己处理，就需要自己处理TCP的拆包和粘包的问题。这里就对Dubbo处理此类问题进行探讨，从而加深自己对它的理解。

###### NettyCodecAdapter
NettyCodecAdapter是对dubbo协议解析的入口，里面包含decoder和encoder两部分，而TCP的拆包和粘包主要是decoder部分，所以encoder这里不进行讨论。在NettyCodecAdapter中的decoder是由InternalDecoder来实现，它的父类是Netty的SimpleChannelUpstreamHandler可以接受所有inbound消息，那么就可以对接受的消息进行decode。这里需要说明一下对于某一个Channel都有一个私有的InternalDecoder对象，并不是和其他的Channel共享，这里就避免了并发问题，所以在InternalDecoder里面可以用单线程的方式去看待，这样就比较容易理解。

###### InternalDecoder
com.alibaba.dubbo.remoting.transport.netty.NettyCodecAdapter.InternalDecoder.messageReceived(ChannelHandlerContext, MessageEvent)
每个channel的inbound消息都会发送到InternalDecoder的messageReceived方法，而dubbo会先将接受的消息缓存到InternalDecoder的buffer属性中，这个变量很重要，后面会讨论。下面是messageReceived方法中将接受的消息负载到buffer实现。
首先是判断当前decoder对象的buffer中是否有可以读取的消息，如果有则进行合并，并且把对象引用赋予message局部变量，所以message则获取了当前channel的inbound消息。得到inbound消息之后，那么接下来就是对协议的解析了。

```

	do {
	    saveReaderIndex = message.readerIndex();
	    try {
	        msg = codec.decode(channel, message);
	    } catch (IOException e) {
	        buffer = com.alibaba.dubbo.remoting.buffer.ChannelBuffers.EMPTY_BUFFER;
	        throw e;
	    }
	    if (msg == Codec2.DecodeResult.NEED_MORE_INPUT) {
	        message.readerIndex(saveReaderIndex);
	        break;
	    } else {
	        if (saveReaderIndex == message.readerIndex()) {
	            buffer = com.alibaba.dubbo.remoting.buffer.ChannelBuffers.EMPTY_BUFFER;
	            throw new IOException("Decode without read data.");
	        }
	        if (msg != null) {
	            Channels.fireMessageReceived(ctx, msg, event.getRemoteAddress());
	        }
	    }
	} while (message.readable());
```                
这里首先要做的是把当前message的读索引保存到局部变量saveReaderIndex中，用于后面的消息回滚。后面紧接着是对消息的decode，这里的codec是DubboCountCodec对象实体，这里需要注意一点，DubboCountCodec的decode每次只会解析出一个完整的dubbo协议栈，带着这个看看decode的实现。

`com.alibaba.dubbo.rpc.protocol.dubbo.DubboCountCodec.decode(Channel, ChannelBuffer)`
这里暂存了当前buffer的读索引，同样也是为了后面的回滚。可以看到当decode返回的是NEED_MORE_INPUT则表示当前的buffer中数据不足，不能完整解析出一个dubbo协议栈，同时将buffer的读索引回滚到之前暂存的索引并且退出循环，将结果返回。那接下来看看什么时候会返回NEED_MORE_INPUT，最终会定位到在ExchangeCodec的decode方法会解析出协议栈。

`com.alibaba.dubbo.remoting.exchange.codec.ExchangeCodec.decode(Channel, ChannelBuffer, int, byte[])`
这个方法开始是对telnet协议进行解析（由于dubbo支持telnet连接，所以这里提供了支持，可以忽略这一部分）。看到会有两个地方返回NEED_MORE_INPUT，一个是当前buffer的可读长度还没有消息头长，说明当前buffer连协议栈的头都不完整，所以需要继续读取inbound数据，另一个是当前buffer包含了完整的消息头，便可以得到playload的长度，发现它的可读的长度，并没有包含整个协议栈的数据，所以也需要继续读取inbound数据。如果上面两个情况都不复核，那么说明当前的buffer至少包含一个dubbo协议栈的数据，那么从当前buffer中读取一个dubbo协议栈的数据，解析出一个dubbo数据，当然这里可能读取完一个dubbo数据之后还会有剩余的数据。
上面对dubbo解析出一个完整的dubbo协议栈过程进行了讨论，但是还没有对TCP的拆包和粘包问题做过多的讨论。下面结合上面内容做一个综合讨论。
我这里对TCP拆包和粘包分别列举一个场景来讨论。

###### 当发生TCP拆包问题时候
这里假设之前还没有发生过任何数据交互，系统刚刚初始化好，那么这个时候在InternalDecoder里面的buffer属性会是EMPTY_BUFFER。当发生第一次inbound数据的时候，第一次在InternalDecoder里面接收的肯定是dubbo消息头的部分（这个由TCP协议保证），由于发生了拆包情况，那么此时接收的inbound消息可能存在一下几种情况
1、当前inbound消息只包含dubbo协议头的一部分
2、当前inbound消息只包含dubbo的协议头
3、当前inbound消息只包含dubbo消息头和部分playload消息
通过上面的讨论，我们知道发生上面三种情况，都会触发ExchangeCodec返回NEED_MORE_INPUT，由于在DubboCountCodec对余返回NEED_MORE_INPUT会回滚读索引，所以此时的buffer里面的数据可以当作并没有发生过读取操作，并且DubboCountCodec的decode也会返回NEED_MORE_INPUT，在InternalDecoder对于当判断返回NEED_MORE_INPUT，也会进行读索引回滚，并且退出循环，最后会执行finally内容，这里会判断inbound消息是否还有可读的，由于在DubboCountCodec里面进行了读索引回滚，所以次数的buffer里面是完整的inbound消息，等待第二次的inbound消息的到来，当第二次inbound消息过来的时候，再次经过上面的判断。

###### 当发生TCP粘包的时候
当发生粘包的时候是tcp将一个以上的dubbo协议栈放在一个tcp包中，那么有可能发生下面几种情况
1、当前inbound消息只包含一个dubbo协议栈
2、当前inbound消息包含一个dubbo协议栈，同时包含部分另一个或者多个dubbo协议栈内容
如果发生只包含一个协议栈，那么当前buffer通过ExchangeCodec解析协议之后，当前的buffer的readeIndex位置应该是buffer尾部，那么在返回到InternalDecoder中message的方法readable返回的是false,那么就会对buffer重新赋予EMPTY_BUFFER实体，而针对包含一个以上的dubbo协议栈，当然也会解析出其中一个dubbo协议栈，但是经过ExchangeCodec解析之后，message的readIndex不在message尾部，所以message的readable方法返回的是true。那么则会继续遍历message，读取下面的信息。最终要么message刚好整数倍包含完整的dubbo协议栈，要不ExchangeCodec返回NEED_MORE_INPUT,最后将未读完的数据缓存到buffer中,等待下次inbound事件，将buffer中的消息合并到下次的inbound消息中，种类又回到了拆包的问题上。

###### 总结
dubbo在处理tcp的粘包和拆包时是借助InternalDecoder的buffer缓存对象来缓存不完整的dubbo协议栈数据，等待下次inbound事件，合并进去。所以说在dubbo中解决TCP拆包和粘包的时候是通过buffer变量来解决的。理解了buffer的用处，也就理解了dubbo解决TCP拆包和粘包的问题。


#### Lock and unlock
http://blog.kazaff.me/2014/09/20/dubbo协议下的单一长连接与多线程并发如何协同工作/
既然在dubbo中描述消费者和提供者之间采用的是单一长连接，那么如果消费者端是高并发多线程模型的web应用，单一长连接如何解决多线程并发请求问题呢？
socket中的粘包问题是怎么解决的？用的最多的其实是定义一个定长的数据包头，其中包含了完整数据包的长度，以此来完成服务器端拆包工作。

那么解决多线程使用单一长连接并发请求时包干扰的方法也有点雷同，就是给包头中添加一个标识id，服务器端响应请求时也要携带这个id，供客户端多线程领取对应的响应数据提供线索。

##### Lock
com.alibaba.dubbo.remoting.exchange.support.header.HeaderExchangeChannel.request(Object, int)
DefaultFuture future = new DefaultFuture(channel, req, timeout);
com.alibaba.dubbo.remoting.exchange.support.DefaultFuture.get(int)
Lock here.

DefaultFuture就是客户端并发请求线程阻塞的对象
 
	com.alibaba.dubbo.rpc.protocol.dubbo.DubboInvoker.doInvoke(Invocation)
->	com.alibaba.dubbo.remoting.exchange.support.DefaultFuture.get(int)

##### Unlock
	com.alibaba.dubbo.remoting.exchange.support.header.HeaderExchangeHandler.received(Channel, Object)
-> 	com.alibaba.dubbo.remoting.exchange.support.header.HeaderExchangeHandler.handleResponse(Channel, Response)
-> 	com.alibaba.dubbo.remoting.exchange.support.DefaultFuture.received(Channel, Response)
-> 	com.alibaba.dubbo.remoting.exchange.support.DefaultFuture.doReceived(Response)
Unlock here.

DefaultFuture.received(Channel, Response)中通过id，DefaultFuture.FUTURES可以拿到具体的那个DefaultFuture对象，它就是上面我们提到的，阻塞请求线程的那个对象	


	com.alibaba.dubbo.remoting.transport.netty.NettyHandler.messageReceived(ChannelHandlerContext, MessageEvent) 
-> 	com.alibaba.dubbo.remoting.exchange.support.header.HeaderExchangeHandler.received(Channel, Object)
-> 	com.alibaba.dubbo.remoting.exchange.support.header.HeaderExchangeHandler.handleRequest(ExchangeChannel, Request)
-> 	com.alibaba.dubbo.rpc.protocol.dubbo.DubboProtocol.requestHandler.new ExchangeHandlerAdapter() {...}.reply(ExchangeChannel, Object)


### 注册中心启动过程:RegistryProtocol?
启动注册中心服务.默认使用netty框架，NettyServer来完成的.接收消息时，抛开dubbo协议的解码器，调用类的顺序是
1 NettyHandler -> NettyServer -> MultiMessageHandler -> HeartbeatHandler -> AllDispatcher -> 
2 DecodeHandler -> HeaderExchangeHandler -> RegistryReceiver -> RegistryValidator -> RegistryFailover -> RegistryExecutor

### Provider start process:ServiceConfig,DubboProtocol
provider的启动过程是从ServiceConfig的export方法开始进行的，具体步骤是:
(1)进行本地jvm的暴露，不开放任何端口，以提供injvm这种形式的调用，这种调用只是本地调用，不涉及进程间通信
(2)调用RegistryProtocol的export
(3)调用DubboProtocol的export，默认开启20880端口，用以提供接收consumer的远程调用服务
(4)通过新建RemoteRegistry来建立与注册中心的连接
(5)将服务地址注册到注册中心
(6)去注册中心订阅自己的服务

Invoker – 执行具体的远程调用
Protocol – 服务地址的发布和订阅
Exporter – 暴露服务的引用，或取消暴露
Protocol的具体实现类由配置指定，默认创建一个DubboProtocol，其export()方法转到openServer()与createServer()

核心类包括:
DubboNamespaceHandler
ServiceBean
ServiceConfig
DubboProtocol
Exchangers
HeaderExchanger
HeaderExchangeServer
NettyTransporter
NettyServer

com.alibaba.dubbo.config.spring.schema.DubboNamespaceHandler.init()
实现了InitializingBean接口，在设置了bean的所有属性后会调用afterPropertiesSet方法
org.springframework.beans.factory.InitializingBean.afterPropertiesSet()

Entry class: com.alibaba.dubbo.config.spring.ServiceBean

``` java
[23/11/15 04:04:31:031 CST] main ERROR container.Main:  [DUBBO] Fail to start server(url: dubbo://172.27.2.27:20880/com.alibaba.dubbo.demo.DemoService?anyhost=true&application=demo-provider&channel.readonly.sent=true&codec=dubbo&dubbo=2.0.0&generic=false&heartbeat=60000&interface=com.alibaba.dubbo.demo.DemoService&loadbalance=roundrobin&methods=sayHello&owner=william&pid=24622&side=provider&timestamp=1448265869456) Failed to bind NettyServer on /172.27.2.27:20880, cause: Failed to bind to: /0.0.0.0:20880, dubbo version: 2.0.0, current host: 127.0.0.1
com.alibaba.dubbo.rpc.RpcException: Fail to start server(url: dubbo://172.27.2.27:20880/com.alibaba.dubbo.demo.DemoService?anyhost=true&application=demo-provider&channel.readonly.sent=true&codec=dubbo&dubbo=2.0.0&generic=false&heartbeat=60000&interface=com.alibaba.dubbo.demo.DemoService&loadbalance=roundrobin&methods=sayHello&owner=william&pid=24622&side=provider&timestamp=1448265869456) Failed to bind NettyServer on /172.27.2.27:20880, cause: Failed to bind to: /0.0.0.0:20880
	at com.alibaba.dubbo.rpc.protocol.dubbo.DubboProtocol.createServer(DubboProtocol.java:289)
	at com.alibaba.dubbo.rpc.protocol.dubbo.DubboProtocol.openServer(DubboProtocol.java:266)
	at com.alibaba.dubbo.rpc.protocol.dubbo.DubboProtocol.export(DubboProtocol.java:253)
	at com.alibaba.dubbo.rpc.protocol.ProtocolListenerWrapper.export(ProtocolListenerWrapper.java:56)
	at com.alibaba.dubbo.rpc.protocol.ProtocolFilterWrapper.export(ProtocolFilterWrapper.java:55)
	at com.alibaba.dubbo.rpc.Protocol$Adpative.export(Protocol$Adpative.java)
	at com.alibaba.dubbo.registry.integration.RegistryProtocol.doLocalExport(RegistryProtocol.java:153)
	at com.alibaba.dubbo.registry.integration.RegistryProtocol.export(RegistryProtocol.java:107)
	at com.alibaba.dubbo.rpc.protocol.ProtocolListenerWrapper.export(ProtocolListenerWrapper.java:54)
	at com.alibaba.dubbo.rpc.protocol.ProtocolFilterWrapper.export(ProtocolFilterWrapper.java:53)
	at com.alibaba.dubbo.rpc.Protocol$Adpative.export(Protocol$Adpative.java)
	at com.alibaba.dubbo.config.ServiceConfig.doExportUrlsFor1Protocol(ServiceConfig.java:488)
	at com.alibaba.dubbo.config.ServiceConfig.doExportUrls(ServiceConfig.java:284)
	at com.alibaba.dubbo.config.ServiceConfig.doExport(ServiceConfig.java:245)
	at com.alibaba.dubbo.config.ServiceConfig.export(ServiceConfig.java:144)
	at com.alibaba.dubbo.config.spring.ServiceBean.onApplicationEvent(ServiceBean.java:109)
	at org.springframework.context.event.SimpleApplicationEventMulticaster$1.run(SimpleApplicationEventMulticaster.java:78)
	at org.springframework.core.task.SyncTaskExecutor.execute(SyncTaskExecutor.java:49)
	at org.springframework.context.event.SimpleApplicationEventMulticaster.multicastEvent(SimpleApplicationEventMulticaster.java:76)
	at org.springframework.context.support.AbstractApplicationContext.publishEvent(AbstractApplicationContext.java:274)
	at org.springframework.context.support.AbstractApplicationContext.finishRefresh(AbstractApplicationContext.java:736)
	at org.springframework.context.support.AbstractApplicationContext.refresh(AbstractApplicationContext.java:383)
	at org.springframework.context.support.ClassPathXmlApplicationContext.<init>(ClassPathXmlApplicationContext.java:139)
	at org.springframework.context.support.ClassPathXmlApplicationContext.<init>(ClassPathXmlApplicationContext.java:93)
	at com.alibaba.dubbo.container.spring.SpringContainer.start(SpringContainer.java:50)
	at com.alibaba.dubbo.container.Main.main(Main.java:80)
	at com.alibaba.dubbo.demo.provider.DemoProvider.main(DemoProvider.java:21)
```

### Consumer start process: ReferenceConfig,DubboProtocol.refer()
(1)通过新建RemoteRegistry来建立与注册中心的连接
(2)新建RegistryDirectory并向注册中心订阅服务，RegistryDirectory用以维护注册中心获取的服务相关信息
(3)创建代理类，发起consumer远程调用时，实际调用的是InvokerInvocationHandler

consumer的启动过程是通过ReferenceConfig的get方法进行的，具体步骤是:
1. 配置文件的解析ReferenceBean`com.alibaba.dubbo.config.spring.schema.DubboNamespaceHandler`实现对dubbo:reference的解析 
2. 获得服务代理
	 在`DemoService demoService = (DemoService)context.getBean("demoService")`时ReferenceBean作为FactoryBean实现DemoService接口的代理对象的创建，见源码：

```java
com.alibaba.dubbo.config.spring.ReferenceBean.getObject()
com.alibaba.dubbo.config.ReferenceConfig.get()
com.alibaba.dubbo.config.ReferenceConfig.init() 
```

 获得protocol,cluster,proxyFactory接口的实例，实际调用如下：
protocol -> Protocol$Adaptive -> ProtocolListenerWrapper
cluster -> FailoverCluster
proxyFactory -> JavassistProxyFactory 

 createProxy 方法解析：
 1. 获得URL，从dubbo:reference ，url属性或者从loadRegistries();通过注册中心配置拼装URL。设置URL的protocol为Constants.REGISTRY_PROTOCOL registry
 2. 获得 invoker = protocol.refer(interfaceClass, urls.get(0)); 
 Protocol$Adaptive-->根据URL的协议获得 com.alibaba.dubbo.rpc.protocol.ProtocolListenerWrapper->com.alibaba.dubbo.rpc.protocol.ProtocolFilterWrapper-->com.alibaba.dubbo.registry.support.RegistryProtocol.refer(interfaceClass, urls.get(0)) ->  com.alibaba.dubbo.registry.support.RegistryProtocol.refer->
	  1. RegistryFactory--getRegistry  RegistryFactory根据url配置可能是DubboRegistryFactory，MulticastRegistryFactory，ZookeeperRegistryFactory
	  2. new RegistryDirectory  创建注册中心目录服务
	  3. registry.subscribe 订阅服务，--》rpc远程访问registryService,RegistryDirectory作为 NotifyListener-->RegistryDirectory.notify(urls)-->urls-toInvokers //此时生成了接口及接口的方法对应的invoker列表
	  4. cluster.merge(directory)   默认由FailoverCluster生成FailoverClusterInvoker(RegistryDirectory)
创建invoker完成。

 3. 创建代理(T) proxyFactory.getProxy(invoker)  --》JavassistProxyFactory-》  (T) Proxy.getProxy(interfaces).newInstance(new InvokerInvocationHandler(invoker));
使用Javassist创建了两个CLASS
``` java

	public class Proxy1 extends Proxy implements ClassGenerator.DC {
	 public Object newInstance(InvocationHandler paramInvocationHandler) {
	   return new proxy1(paramInvocationHandler);
	 }
	}
	public class proxy1 implements ClassGenerator.DC, EchoService, DemoService {
	  public static Method[] methods;
	  private InvocationHandler handler;
	  public String sayHello(String paramString) {
	    Object[] arrayOfObject = new Object[1];
	    arrayOfObject[0] = paramString;
	    Object localObject = this.jdField_handler_of_type_JavaLangReflectInvocationHandler.invoke(this, jdField_methods_of_type_ArrayOfJavaLangReflectMethod[0], arrayOfObject);
	    return ((String)localObject);
	  }
	
	  public Object $echo(Object paramObject) {
	    Object[] arrayOfObject = new Object[1];
	    arrayOfObject[0] = paramObject;
	    Object localObject = this.jdField_handler_of_type_JavaLangReflectInvocationHandler.invoke(this, jdField_methods_of_type_ArrayOfJavaLangReflectMethod[1], arrayOfObject);
	    return ((Object)localObject);
	  }
	
	  public proxy1(InvocationHandler paramInvocationHandler) {
	    this.jdField_handler_of_type_JavaLangReflectInvocationHandler = paramInvocationHandler;
	  }
	}
```
返回proxy1，xxx接口的子类。 
 4. 动态代理背后的故事，以dubbo协议的通信为例
  从生成的proxy1的代码我们可以看到  sayHello(String str)时调用了 InvokerInvocationHandler.invoke(Object proxy, Method method, Object[] args) -> invoker.invoke(new RpcInvocation(method, args)).recreate();
这里的invoker是对 com.alibaba.dubbo.rpc.protocol.dubbo.DubboInvoker 的层层包装，实现负载均衡、失败转移（FailoverClusterInvoker）、InvokerListener，InvokerChain的顺序调用。由Protocol.refer生成 
FailoverClusterInvoker.doInvoke(Invocation, List<Invoker<T>>, **LoadBalance**)
再来具体看看实际执行远程调用DubboInvoker
DubboInvoker.doInvoke() -> (Result) currentClient.request();  调用ExchangeClient发起请求

默认通过NETTY框架通信。见`com.alibaba.dubbo.remoting.transport.netty.NettyClient`
对协议的encode,decode实现：`com.alibaba.dubbo.rpc.protocol.dubbo.DubboCodec`
对于配置文件中的
```
<dubbo:method name="subscribe">
	<dubbo:argument index="1" callback="true" />
</dubbo:method>
```
callback为true的，DubboCodec在服务端自动生成参数代理， 通过RPC远程调用消费者的方法。此时的invoker为ChannelWrappedInvoker发起的请求，由DubboProtocol得requestHandler处理received--》  
```
	if (message instanceof Invocation) {
		reply((ExchangeChannel) channel, message);
	}
```
 比如消费者 subscribe 时，com.alibaba.dubbo.registry.support.SimpleRegistryService 处理完成后要调用消费者的NotifyLisenter.notify(urls)  
 消费者在发送请求时，DubboCodec根据URL中配置的方法的某一个参数的callback属性是否为true来自动发布服务，以接受服务端的callback

Entry class: com.alibaba.dubbo.config.spring.ReferenceBean

通观全部Dubbo代码，有两个很重要的对象就是Invoker和Exporter，Dubbo会根据用户配置的协议调用不同协议的Invoker，再通过ReferenceFonfig将Invoker的引用关联到Reference的ref属性上提供给消费端调用.当用户调用一个Service接口的一个方法后由于Dubbo使用javassist动态代理，会调用Invoker的Invoke方法从而初始化一个RPC调用访问请求访问服务端的Service返回结果
Spring在初始化IOC容器时会利用这里注册的BeanDefinitionParser的parse方法获取对应的ReferenceBean的BeanDefinition实例，由于ReferenceBean实现了InitializingBean接口，在设置了bean的所有属性后会调用afterPropertiesSet方法
com.alibaba.dubbo.config.spring.schema.DubboNamespaceHandler.init()
com.alibaba.dubbo.config.spring.ReferenceBean.afterPropertiesSet()
com.alibaba.dubbo.config.ReferenceConfig.init()
com.alibaba.dubbo.config.ReferenceConfig.createProxy(Map<String, String>)
Protocol$Adpative.refer(Class, URL) line: 392
ProtocolFilterWrapper.refer(Class<T>, URL) line: 60	
ProtocolListenerWrapper.refer(Class<T>, URL) line: 63	
RegistryProtocol.refer(Class<T>, URL) line: 254	
RegistryProtocol.doRefer(Cluster, Registry, Class<T>, URL) line: 271	
RegistryDirectory<T>.subscribe(URL) line: 133	
ZookeeperRegistry(FailbackRegistry).subscribe(URL, NotifyListener) line: 189	
ZookeeperRegistry.doSubscribe(URL, NotifyListener) line: 114	

### Invocation
Consumer对于服务接口的透明调用
基于Javassist的动态代理模式，自动生成代理类。通过InvokerInvocationHandler的invoker调用：
return invoker.invoke(new RpcInvocation(method, args)).recreate(); 

invoker RPC通信，基于mina、netty等
1. Invocation，一次具体的调用，包含方法名、参数类型、参数
2. Result，一次调用结果，包含value和exception
3. Invoker，调用者，对应一个服务接口，通过invoke方法执行调用，参数为Invocation，返回值为Result

### 实际调用过程
1、consumer端发起调用时，实际调用经过的类是:
InvokerInvocationHandler -> MockClusterInvoker(如果配置了Mock，则直接调用本地Mock类) -> FailoverClusterInvoker(负载均衡，容错机制，默认在发生错误的情况下，进行两次重试) -> RegistryDirectory$InvokerDelegete -> ConsumerContextFilter -> FutureFilter -> DubboInvoker
2、provider:
NettyServer -> MultiMessageHandler -> HeartbeatHandler -> AllDispatcher -> DecodeHandler -> HeaderExchangeHandler -> DubboProtocol.requestHandler -> EchoFilter -> ClassLoaderFilter -> GenericFilter -> ContextFilter -> ExceptionFilter -> TimeoutFilter -> MonitorFilter -> TraceFilter -> 实际service

#### DubboInvoker
通过ExchangeClient发送调用请求(Invocation)
doInvoke()分为oneWay、async、sync调用
对client的选择采用轮询的方式

#### Wrapper帮助类
提高调用某一个类的某一个方法的性能（避免反射调用）
使用javassist动态生成一个Wrapper的子类，实现抽象方法invokeMethod， 

#### Exchanger
http://gaofeihang.cn/archives/255

从Client的角度对通信流程进行梳理
在一个框架中我们通常把负责数据交换和网络通信的组件叫做Exchanger.Dubbo中每个Invoker都维护了一个ExchangeClient的引用，并通过它和远程的Server进行通信.整个与ExchangeClient相关的类图如下
![Dubbo-Exchanger](http://gaofeihang.cn/wp-content/uploads/2015/04/Dubbo-Exchanger.jpg "Dubbo-Exchanger") 
1. ExchangeClient只有一个常用的实现类，HeaderExchangeClient
2. 在Invoker需要发送数据时，单程发送使用的是ExchangeClient的send方法，需要返回结果的使用request方法
3. 最终send方法传递到channel的send，而request方法则是通过构建ResponseFuture和调用send组合实现的.接下来的重点就是这个Channel参数如何来构建
4. 它来自Transporters的connect方法，具体的Transporter来源于ExtensionLoader，默认为NettyTransporter，由它构建的是NettyClient.NettyClient再次维护了一个Channel引用，来自NettyChannel的getOrAddChannel()方法，创建的是NettyChannel.最终由基类AbstractClient实现的send方法调用了NettyChannel
5. 执行Netty的channel.write()将数据真正发送出去，也可以由此看出boolean sent;参数的含义:是否去等待发送完成、是否执行超时的判断

本文主要以Client的角度对通信流程进行了介绍，Server端也可以遵循这样的路径去梳理，这里就不再赘述了

#### Handler & Filter
http://gaofeihang.cn/archives/264

本文介绍Server端处理一次请求的流程，同时讲解一个比较巧妙的设计——Filter
根据前面的分析我们可以推断出Server端处理网络通信的组件为NettyServer，对应处理具体事件的handler为NettyHandler，它的构造函数需要一个ChannelHandler的参数，这里传递的就是NettyServer实例的引用.这样一来，handler对messageReceived()的事件处理，又传递给了NettyServer的receive()方法

``` java
@Override
public void messageReceived(ChannelHandlerContext ctx, MessageEvent e) throws Exception {
    NettyChannel channel = NettyChannel.getOrAddChannel(ctx.getChannel(), url, handler);
    try {
        handler.received(channel, e.getMessage());
    } finally {
        NettyChannel.removeChannelIfDisconnected(ctx.getChannel());
    }
}
```
NettyServer本身没有实现receive方法，这个调用由基类AbstractPeer处理，而它也是再调用自己维护的ChannelHandler，也就是构造NettyServer时传入的handler.这是一个ChannelHandlerDispatcher实例，它允许同时触发一组普通的handler.实际构建时的handler为new DecodeHandler(new HeaderExchangeHandler(handler))，HeaderExchangeHandler中有一部分处理的逻辑，同时还会调用外部传递handler.

HeaderExchangeHandler.received() -> HeaderExchangeHandler.{handleRequest(),handleResponse()}
最后调用了handler.reply()方法， 它的实现与具体的协议有关，比如默认配置下就是在DubboProtocol中构建的requestHandler，在createServer()方法中传递给Exchanger.
`DubboProtocol.requestHandler`

看到了invoker.invoke()，也就是真正执行调用的地方.这个Invoker实例来自于根据serviceKey查找的Exporter，它是通过ExtensionLoader创建的，是一个ProtocolFilterWrapper实例.
`ProtocolFilterWrapper.export()`
`ProtocolFilterWrapper.buildInvokerChain()`

这里会将原来的Invoker通过各种Filter包装成一个InvokerChain，一次调用会依次经过这些FilterChain到达最终的Filter.在这些Filter中可以进行超时校验、数据监控等工作，每个Filter相对独立，使得代码结构非常清晰，也便于为新功能进行扩展.

这个链的结构是:除了初始传入的Invoker外，对于每个Filter都新建一个Invoker，并返回最后一个创建的Invoker.当执行这些后来构建的Invoker.invoker()方法时，实际调用了filter.invoker(next, invocation)，这样会去执行filter中的逻辑，然后再由filter调用下一个Invoker的invoke方法.直至最后一个原始的Invoker，它的invoke方法不会调用filter，而是正常的invoke逻辑.

核心类包括
NettyServer
NettyHandler
HeaderExchangeHandler
DubboProtocol
ProtocolFilterWrapper
JavassistProxyFactory

### Register process
#### Provider
Provider初始化时会调用doRegister方法向注册中心发起注册

``` java
ZookeeperRegistry.doSubscribe(URL, NotifyListener) line: 114	
ZookeeperRegistry(FailbackRegistry).subscribe(URL, NotifyListener) line: 189	
RegistryProtocol.export(Invoker<T>) line: 117	
ProtocolListenerWrapper.export(Invoker<T>) line: 54	
ProtocolFilterWrapper.export(Invoker<T>) line: 53	
Protocol$Adpative.export(Invoker) line: not available	
ServiceBean<T>(ServiceConfig<T>).doExportUrlsFor1Protocol(ProtocolConfig, List<URL>) line: 488	
ServiceBean<T>(ServiceConfig<T>).doExportUrls() line: 284	
ServiceBean<T>(ServiceConfig<T>).doExport() line: 245	
ServiceBean<T>(ServiceConfig<T>).export() line: 144	
ServiceBean<T>.onApplicationEvent(ApplicationEvent) line: 109	
SimpleApplicationEventMulticaster$1.run() line: 78	
SyncTaskExecutor.execute(Runnable) line: 49	
SimpleApplicationEventMulticaster.multicastEvent(ApplicationEvent) line: 76	
ClassPathXmlApplicationContext(AbstractApplicationContext).publishEvent(ApplicationEvent) line: 274	
ClassPathXmlApplicationContext(AbstractApplicationContext).finishRefresh() line: 736	
ClassPathXmlApplicationContext(AbstractApplicationContext).refresh() line: 383	
ClassPathXmlApplicationContext.<init>(String[], boolean, ApplicationContext) line: 139	
ClassPathXmlApplicationContext.<init>(String[]) line: 93	
SpringContainer.start() line: 50	
Main.main(String[]) line: 80	
DemoProvider.main(String[]) line: 21	
```

#### Consumer
Provider初始化时会调用doRegister方法向注册中心发起注册.那么客户端又是怎么subscribe在注册中心订阅服务的呢？答案是服务消费者在初始化ConsumerConfig时会调用RegistryProtocol的refer方法进一步调用RegistryDirectory的subscribe方法最终调用ZookeeperRegistry的subscribe方法向注册中心订阅服务.
com.alibaba.dubbo.registry.support.FailBackRegistry的subscribe方法

``` java
ZookeeperRegistry.doSubscribe(URL, NotifyListener) line: 114	
ZookeeperRegistry(FailbackRegistry).subscribe(URL, NotifyListener) line: 189	
RegistryDirectory<T>.subscribe(URL) line: 133	
RegistryProtocol.doRefer(Cluster, Registry, Class<T>, URL) line: 271	
RegistryProtocol.refer(Class<T>, URL) line: 254	
ProtocolListenerWrapper.refer(Class<T>, URL) line: 63	
ProtocolFilterWrapper.refer(Class<T>, URL) line: 60	
Protocol$Adpative.refer(Class, URL) line: not available	
ReferenceBean<T>(ReferenceConfig<T>).createProxy(Map<String,String>) line: 392	
ReferenceBean<T>(ReferenceConfig<T>).init() line: 300	
ReferenceBean<T>(ReferenceConfig<T>).get() line: 138	
ReferenceBean<T>.getObject() line: 65	
FactoryBeanRegistrySupport$1.run() line: 121	
AccessController.doPrivileged(PrivilegedAction<T>, AccessControlContext) line: not available [native method]	
DefaultListableBeanFactory(FactoryBeanRegistrySupport).doGetObjectFromFactoryBean(FactoryBean, String, boolean) line: 116	
DefaultListableBeanFactory(FactoryBeanRegistrySupport).getObjectFromFactoryBean(FactoryBean, String, boolean) line: 91	
DefaultListableBeanFactory(AbstractBeanFactory).getObjectForBeanInstance(Object, String, String, RootBeanDefinition) line: 1288	
DefaultListableBeanFactory(AbstractBeanFactory).doGetBean(String, Class, Object[], boolean) line: 275	
DefaultListableBeanFactory(AbstractBeanFactory).getBean(String, Class, Object[]) line: 185	
DefaultListableBeanFactory(AbstractBeanFactory).getBean(String) line: 164	
BeanDefinitionValueResolver.resolveReference(Object, RuntimeBeanReference) line: 269	
BeanDefinitionValueResolver.resolveValueIfNecessary(Object, Object) line: 104	
DefaultListableBeanFactory(AbstractAutowireCapableBeanFactory).applyPropertyValues(String, BeanDefinition, BeanWrapper, PropertyValues) line: 1245	
DefaultListableBeanFactory(AbstractAutowireCapableBeanFactory).populateBean(String, AbstractBeanDefinition, BeanWrapper) line: 1010	
DefaultListableBeanFactory(AbstractAutowireCapableBeanFactory).doCreateBean(String, RootBeanDefinition, Object[]) line: 472	
AbstractAutowireCapableBeanFactory$1.run() line: 409	
AccessController.doPrivileged(PrivilegedAction<T>, AccessControlContext) line: not available [native method]	
DefaultListableBeanFactory(AbstractAutowireCapableBeanFactory).createBean(String, RootBeanDefinition, Object[]) line: 380	
AbstractBeanFactory$1.getObject() line: 264	
DefaultListableBeanFactory(DefaultSingletonBeanRegistry).getSingleton(String, ObjectFactory) line: 222	
DefaultListableBeanFactory(AbstractBeanFactory).doGetBean(String, Class, Object[], boolean) line: 261	
DefaultListableBeanFactory(AbstractBeanFactory).getBean(String, Class, Object[]) line: 185	
DefaultListableBeanFactory(AbstractBeanFactory).getBean(String) line: 164	
DefaultListableBeanFactory.preInstantiateSingletons() line: 429	
ClassPathXmlApplicationContext(AbstractApplicationContext).finishBeanFactoryInitialization(ConfigurableListableBeanFactory) line: 728	
ClassPathXmlApplicationContext(AbstractApplicationContext).refresh() line: 380	
ClassPathXmlApplicationContext.<init>(String[], boolean, ApplicationContext) line: 139	
ClassPathXmlApplicationContext.<init>(String[]) line: 93	
SpringContainer.start() line: 50	
Main.main(String[]) line: 80	
DemoConsumer.main(String[]) line: 21	
```

#### Notify
Thread [main] (Suspended (breakpoint at line 410 in AbstractRegistry))	
	owns: ReferenceBean<T>  (id=46)	
	owns: ConcurrentHashMap<K,V>  (id=47)	
	ZookeeperRegistry(AbstractRegistry).notify(URL, NotifyListener, List<URL>) line: 410	
	ZookeeperRegistry(FailbackRegistry).doNotify(URL, NotifyListener, List<URL>) line: 273	
	ZookeeperRegistry(FailbackRegistry).notify(URL, NotifyListener, List<URL>) line: 259	
	ZookeeperRegistry.doSubscribe(URL, NotifyListener) line: 170	
	ZookeeperRegistry(FailbackRegistry).subscribe(URL, NotifyListener) line: 189	
	RegistryDirectory<T>.subscribe(URL) line: 133	
	RegistryProtocol.doRefer(Cluster, Registry, Class<T>, URL) line: 271	
	RegistryProtocol.refer(Class<T>, URL) line: 254	
	ProtocolListenerWrapper.refer(Class<T>, URL) line: 63	
	ProtocolFilterWrapper.refer(Class<T>, URL) line: 60	
	Protocol$Adpative.refer(Class, URL) line: 18	
	ReferenceBean<T>(ReferenceConfig<T>).createProxy(Map<String,String>) line: 392	
	ReferenceBean<T>(ReferenceConfig<T>).init() line: 300	
	ReferenceBean<T>(ReferenceConfig<T>).get() line: 138	
	ReferenceBean<T>.getObject() line: 65	
	DefaultListableBeanFactory(FactoryBeanRegistrySupport).doGetObjectFromFactoryBean(FactoryBean<?>, String) line: 168	
	DefaultListableBeanFactory(FactoryBeanRegistrySupport).getObjectFromFactoryBean(FactoryBean<?>, String, boolean) line: 103	
	DefaultListableBeanFactory(AbstractBeanFactory).getObjectForBeanInstance(Object, String, String, RootBeanDefinition) line: 1512	
	DefaultListableBeanFactory(AbstractBeanFactory).doGetBean(String, Class<T>, Object[], boolean) line: 250	
	DefaultListableBeanFactory(AbstractBeanFactory).getBean(String) line: 193	
	ClassPathXmlApplicationContext(AbstractApplicationContext).getBean(String) line: 956	
	Consumer.main(String[]) line: 40	


Daemon Thread [ZkClient-EventThread-15-127.0.0.1:2181] (Suspended (breakpoint at line 410 in AbstractRegistry))	
	ZookeeperRegistry(AbstractRegistry).notify(URL, NotifyListener, List<URL>) line: 410	
	ZookeeperRegistry(FailbackRegistry).doNotify(URL, NotifyListener, List<URL>) line: 273	
	ZookeeperRegistry(FailbackRegistry).notify(URL, NotifyListener, List<URL>) line: 259	
	ZookeeperRegistry.access$400(ZookeeperRegistry, URL, NotifyListener, List) line: 45	
	ZookeeperRegistry$3.childChanged(String, List<String>) line: 159	
	ZkclientZookeeperClient$2.handleChildChange(String, List<String>) line: 82	
	ZkClient$7.run() line: 568	
	ZkEventThread.run() line: 71	


### ExtensionLoader
http://bbs.dubboclub.net/read-32.html

#### SPI
SPI是一种协议，并没有提供相关插件化实施的接口，不像OSGI那样有一成套实施插件化API。它只是规定在META-INF目录下提供接口的实现描述文件，框架本身定义接口、规范，第三方只需要将自己实现在META-INF下描述清楚，那么框架就会自动加载你的实现，至于怎么加载，JDK并没有提供相关API，而是框架设计者需要考虑和实现的,并且在META-INF下面对实现描述规则，也是需要框架设计者来规定。比如Dubbo的规则是在META-INF/dubbo、META-INF/dubbo/internal或者META-INF/services下面以需要实现的接口全面去创建一个文件，并且在文件中以properties规则一样配置实现类的全面以及分配实现一个名称。

JDK标准的SPI扩展机制，参见：java.util.ServiceLoader
也就是扩展者在jar包的META-INF/services/目录下放置与接口同名的文本文件，
内容为接口实现类名，多个实现类名用换行符分隔，
比如，需要扩展Dubbo的协议，只需在xxx.jar中放置：
文件：META-INF/services/com.alibaba.dubbo.rpc.Protocol
内容为：com.alibaba.xxx.XxxProtocol
Dubbo通过ServiceLoader扫描到所有Protocol实现

Dubbo中具有SPI标记的接口有:
http://gaofeihang.cn/archives/278 
CacheFactory
Compiler
ExtensionFactory
LoggerAdapter
Serialization
StatusChecker
DataStore
ThreadPool
Container
PageHandler
MonitorFactory
RegistryFactory
ChannelHandler
Codec
Codec2
Dispatcher
Transporter
Exchanger
HttpBinder
Networker
TelnetHandler
ZookeeperTransporter
ExporterListener
Filter
InvokerListener
Protocol
ProxyFactory
Cluster
ConfiguratorFactory
LoadBalance
Merger
RouterFactory
RuleConverter
ClassNameGenerator
Validation

#### URL为总线的模式
Dubbo框架是以URL为总线的模式，即运行过程中所有的状态数据信息都可以通过URL来获取，比如当前系统采用什么序列化，采用什么通信，采用什么负载均衡等信息，都是通过URL的参数来呈现的，所以在框架运行过程中，运行到某个阶段需要相应的数据，都可以通过对应的Key从URL的参数列表中获取，比如在cluster模块，到服务调用触发到该模块，则会从URL中获取当前调用服务的负载均衡策略，以及mock信息等。

#### ExtensionLoader
ExtensionLoader是一个单例工厂类，它对外暴露getExtensionLoader静态方法返回一个ExtensionLoader实体，这个方法的入参是一个Class类型，这个方法的意思是返回某个接口的ExtensionLoader。那么对于某一个接口，只会有一个ExtensionLoader实体。ExtensionLoader实体对外暴露了一些方法接口来获取扩展实现。方法归为几类，分别是activate extension、adaptive extension、default extension、get
extension by name以及supported extension。

#### Activate extension
getActivateExtension(URL url, String[] values, String group) 
activate extension都需要传入url参数，这里涉及到Activate注解，这个注解主要用处是标注在插件接口实现类上，用来配置该扩展实现类激活条件。在Dubbo框架里面的Filter的各种实现类都通过Activate标注，用来描述该Filter什么时候生效。比如MonitorFilter通过Activate标注用来告诉Dubbo框架这个Filter是在服务提供端和消费端会生效的；而TimeoutFilter则是只在服务提供端生效，消费端是不会调用该Filter；ValidationFilter要激活的条件除了在消费端和服务提供端激活，它还配置了value，这个表述另一个激活条件，上面介绍要获取activate extension都需要传入URL对象，那么这个value配置的值则表述URL必须有指定的参数才可以激活这个扩展。例如ValidationFilter则表示URL中必须包含参数validation(Constants.VALIDATION_KEY常量的值就是validation)，否则即使是消费端和服务端都不会激活这个扩展实现，仔细的同学还会发现在ValidationFilter中的Activate注解还有一个参数order，这是表示一种排序规则。因为一个接口的实现有多种，返回的结果是一个列表，如果不指定排序规则，那么可能列表的排序不可控，为了实现这个所以添加了order属性用来控制排序，其中order的值越大，那么该扩展实现排序就越靠前。除了通过order来控制排序，还有before和after来配置当前扩展的位置，before和after配置的值是扩展的别名（扩展实现的别名是在图23中等号左边内容，下面出现的别名均是此内容）。

``` java

	@Activate(group = {Constants.PROVIDER, Constants.CONSUMER})
	public class MonitorFilter implements Filter {……}
	@Activate(group = Constants.PROVIDER)
	public class TimeoutFilter implements Filter {……}
	@Activate(group = { Constants.CONSUMER, Constants.PROVIDER }, value = Constants.VALIDATION_KEY, order = 10000)
	public class ValidationFilter implements Filter {……}
```

#### Filter
上面基本对activate介绍的差不多了，在Dubbo框架中对这个用的最多的就是Filter的各种实现，因为Dubbo的调用会经过一个过滤器链，哪些Filter这个链中是通过各种Filter实现类的Activate注解来控制的。包括上面说的排序，也可以理解为过滤器链中各个Filter的前后顺序。这里的顺序需要注意一个地方，这里的排序均是框架本身实现扩展的进行排序，用户自定义的扩展默认是追加在列表后面。说到这里具体例子：
<dubbo:reference id=”fooRef” interface=”com.foo.Foo” ….. filter=”A,B,C”/>
假设上面是一个有效的消费端服务引用，其中配置了一个filter属性，并且通过逗号隔开配置了三个过滤器A,B,C（A,B,C均为Filter实现的别名），那么对于接口Foo调用的过滤器链是怎么样的呢？首先Dubbo会加载默认的过滤器（一般消费端有三个ConsumerContextFilter,MonitorFilter,FutureFilter），并且对这些默认的过滤器实现进行排序（ActivateComparator实现排序逻辑），这写默认过滤器实现会在过滤器链前面，后面紧接着的才是A，B，C三个自定义过滤器。

#### Adaptive extension
createAdaptiveExtensionClassCode()
Dubbo框架提供的各种接口均有很多种类的实现，在引用具体实现的时候不可能通过硬编码制定引用哪个实现，这样整个框架的灵活性严重降低。所以为了能够适配一个接口的各种实现，便有了adaptive extension这一说。对一个接口实现的适配器Dubbo提供两种途径，第一种途径是对某个接口实现对应的适配器，第二种是Dubbo框架动态生成适配器类。
getAdaptiveExtension 利用代码生成创建以下接口的适配器类：
Protocol
Cluster
ProxyFactory
等等 

##### 某个接口实现对应的适配器
先对第一种途径进行介绍，这种途径也最好理解，对于这种途径Dubbo也提供了一个注解Adaptive，他用来标注在接口的某个实现上，表示这个实现并不是提供具体业务支持，而是作为该接口的适配器。对于这种途径的使用在Dubbo框架中ExtensionFactory的实现类AdaptiveExtensionFactory就是实现适配的功能，它的类被Adaptive进行了标注，那么当调用ExtensionLoader.getExtensionLoader(ExtensionFactory.class).getAdaptiveExtension()的时候将会返回AdaptiveExtensionFactory实体，用来适配ExtensionFactory接口的SPIExtensionFactory和SpringExtensionFactory两种实现，在AdaptiveExtensionFactory将会根据运行时的状态来确定具体调用ExtensionFactory的哪个实现。

##### Dubbo框架动态生成适配器类
而第二种相对于第一种来说就隐晦一点，是ExtensionLoader通过分析接口配置的adaptive规则动态生成adaptive类并且加载到ClassLoader中，来实现动态适配。配置adaptive的规则也是通过Adaptive注解来设置，该注解有一个value属性，通过设置这个属性便可以设置该接口的Adaptive的规则，上面说过服务调用的所有数据均可以从URL获取（Dubbo的URL总线模式），那么需要Dubbo帮我们动态生成adaptive的扩展接口的方法入参必须包含URL，这样才能根据运行状态动态选择具体实现。这里列举一下Transporter接口中配置adaptive规则。 

##### Transporter接口中配置adaptive规则
```java

	@SPI("netty")
	public interface Transporter {
	    /**
	     * Bind a server.
	     *
	     * @see com.alibaba.dubbo.remoting.Transporters#bind(URL, Receiver, ChannelHandler)
	     * @param url server url
	     * @param handler
	     * @return server
	     * @throws RemotingException
	     */
	    @Adaptive({Constants.SERVER_KEY, Constants.TRANSPORTER_KEY})
	    Server bind(URL url, ChannelHandler handler) throws RemotingException;
	    /**
	     * Connect to a server.
	     *
	     * @see com.alibaba.dubbo.remoting.Transporters#connect(URL, Receiver, ChannelListener)
	     * @param url server url
	     * @param handler
	     * @return client
	     * @throws RemotingException
	     */
	    @Adaptive({Constants.CLIENT_KEY, Constants.TRANSPORTER_KEY})
	    Client connect(URL url, ChannelHandler handler) throws RemotingException;
	}
```
Transporter接口提供了两个方法，一个是connect（用来创建客户端连接），另一个是bind（用来绑定服务端端口提供服务），并且这两个方法上面均通过Adaptive注解配置了value属性，bind配置的是server和transporter，connect配置的是client和transporter。那么配置这些值有什么用呢？下面看看ExtensionLoader根据这些生成了什么样的adaptive代码。
``` java

	package com.alibaba.dubbo.remoting;
	import com.alibaba.dubbo.common.extension.ExtensionLoader;
	
	public class Transporter$Adpative implements com.alibaba.dubbo.remoting.Transporter{
	public com.alibaba.dubbo.remoting.Client connect(
		com.alibaba.dubbo.common.URL arg0, com.alibaba.dubbo.remoting.ChannelHandler arg1)
		throws com.alibaba.dubbo.remoting.RemotingException {
		if (arg0 == null)
			throw new IllegalArgumentException("url == null");
		com.alibaba.dubbo.common.URL url = arg0;
		String extName = url.getParameter("client", url.getParameter("transporter", "netty"));
		if(extName == null)
			throw new IllegalStateException("Fail to get extension(com.alibaba.dubbo.remoting.Transporter) name from url(" + url.toString() + ") use keys([client, transporter])");
		com.alibaba.dubbo.remoting.Transporter extension = (com.alibaba.dubbo.remoting.Transporter)ExtensionLoader.getExtensionLoader(com.alibaba.dubbo.remoting.Transporter.class).getExtension(extName);
		
		return extension.connect(arg0, arg1);
	}
	
	public com.alibaba.dubbo.remoting.Server bind(
		com.alibaba.dubbo.common.URL arg0, com.alibaba.dubbo.remoting.ChannelHandler arg1)
		throws com.alibaba.dubbo.remoting.RemotingException {
		if (arg0 == null)
			throw new IllegalArgumentException("url == null");
		com.alibaba.dubbo.common.URL url = arg0;
		String extName = url.getParameter("server", url.getParameter("transporter", "netty"));
		if(extName == null)
			throw new IllegalStateException("Fail to get extension(com.alibaba.dubbo.remoting.Transporter) name from url(" + url.toString() + ") use keys([server, transporter])");
		com.alibaba.dubbo.remoting.Transporter extension = (com.alibaba.dubbo.remoting.Transporter)ExtensionLoader.getExtensionLoader(com.alibaba.dubbo.remoting.Transporter.class).getExtension(extName);
		
		return extension.bind(arg0, arg1);
	}
	}
```
上面是ExtensionLoader自动生成的Transporter$Adpative类，并且实现了Transporter接口，下面我们分别看看在它connect和bind中分别做了哪些逻辑。先看看bind方法代码段`bind(com.alibaba.dubbo.common.URL arg0, com.alibaba.dubbo.remoting.ChannelHandler arg1)`, 先对url参数`arg0`进行了非空判断，然后便是调用url.getParameter方法，首先是获取server参数，如果没有边获取transporter参数，最后如果两个参数均没有，extName便是netty。获取完参数之后，紧接着对extName进行非空判断，接下来便是获取Transporter的ExtensionLoader，并且获取别名为extName的Transporter实现，并调用对应的bind，进行绑定服务端口操作。connect也是类似，只是它首先是从url中获取client参数，在获取transporter参数，同样如果最后两个参数都没有，那么extName也是netty，也依据extName获取对已的接口扩展实现，调用connect方法。
到这里或许你已经明白了ExtensionLoader是怎么动态生成adaptive,上面从url中获取server，client还是transporter参数均是在Transporter接口的方法通过Adaptive注解配置的value属性。其中netty是通过注解SPI制定当前接口的一种默认实现。这便是Dubbo通过ExtensionLoader动态生成adaptive类来动态适配接口的所有实现。

#### get extension by name
通过接口实现的别名来获取某一个具体的服务

#### default extension
Dubbo的SPI规范除了上面说的在制定文件夹下面描述服务的实现信息之外，在被实现的接口必须标注SPI注解，用来告诉Dubbo这个接口是通过SPI来进行扩展实现的，否则ExtensionLoader则不会对这个接口创建ExtensionLoader实体，并且调用ExtensionLoader.getExtensionLoader方法会出现IllegalArgumentException异常。那说这些和默认扩展实现有什么关系呢？在接口上标注SPI注解的时候可以配置一个value属性用来描述这个接口的默认实现别名，

##### Transporter and NettyTransporter
例如上面Transporter的@SPI(“netty”)就是指定Transporter默认实现是NettyTransporter，因为NettyTransporter的别名是netty。

这里再对服务别名补充有点，别名是站在某一个接口的维度来区分不同实现的，所以一个接口的实现不能有相同的别名，否则Dubbo框架将启动失败，当然不同接口的各自实现别名可以相同。到此ExtensionLoader的实现原则和基本原理介绍完了，接下来我们来看看怎么基于Dubbo的ExtensionLoader来实施我们自己的插件化。同样还是dubbo-demo项目中进行演示，在其中创建了一个demo-extension模块。

#### Example: 基于Dubbo的ExtensionLoader实施插件化

插件化的第一步是抽象一个接口，从定义了插件的规范，那么我们先创建一个MyExtension接口，并且标注了SPI注解，同时制定默认实现是别名为default的扩展实现。 
``` java

	@SPI("default")
	public interface MyExtension {
		public String sayHello(String name, ExtensionType type);
	}
```
接下来就是对这个插件接口提供不同的实现，可以看到我上面接口方法sayHello方法入参中并没有URL类型，所以不能通过Dubbo动态给我生成adaptive类，需要我自己来实现一个适配类。我的适配类如下

``` java

	@Adaptive
	public class AdaptiveExtension implements MyExtension {
		@Override
		public String sayHello(String name, ExtensionType type) {
			ExtensionLoader<MyExtension> extensionLoader = ExtensionLoader
					.getExtensionLoader(MyExtension.class);
			MyExtension extension = (MyExtension) extensionLoader.getDefaultExtension();
			switch (type) {
			case DEFAULT:
				extension = (MyExtension) extensionLoader.getExtension(ExtensionType.DEFAULT.getType());
				break;
			case OTHER:
				extension = (MyExtension) extensionLoader.getExtension(ExtensionType.OTHER.getType());
				break;
			}
			return extension.sayHello(name, type);
		}
	}
```
可见在AdaptiveExtension中将会根据ExtensionType分发扩展的具体实现，并触发sayHello方法。对MyExtension接口提供了两种实现,
``` java

public class DefaultExtensionImpl implements MyExtension {
	@Override
	public String sayHello(String name, ExtensionType type) {
		return "Default sayHello: " + name;
	}
}

public class OtherExtensionImpl implements MyExtension {
	@Override
	public String sayHello(String name, ExtensionType type) {
		return "Other sayHello: " + name;
	}
}
```
并且在META-INF/dubbo下面创建了文件org.peter.extension.MyExtension
```
default=org.peter.extension.DefaultExtensionImpl
other=org.peter.extension.OtherExtensionImpl
Adaptive=org.peter.extension.AdaptiveExtension
```
到此插件的定义以及插件的实现都已经完毕，下面我们来验证一下是否成功依托Dubbo的插件机制管理了我们的插件。创建了一个测试类TestExtension来验证. 项目结构如下:

WEB-INF$ tree classes/
classes/
├── META-INF
│   └── dubbo
│       └── org.peter.extension.MyExtension
└── org
    └── peter
        └── extension
            ├── AdaptiveExtension.class
            ├── DefaultExtensionImpl.class
            ├── ExtensionType.class
            ├── MyExtension.class
            ├── OtherExtensionImpl.class
            └── TestExtension.class
``` java

	ExtensionLoader<T>.injectExtension(T) line: 547	
	ExtensionLoader<T>.createExtension(String) line: 509	
	ExtensionLoader<T>.getExtension(String) line: 319	
	AdaptiveExtensionFactory.<init>() line: 40	
	NativeConstructorAccessorImpl.newInstance0(Constructor<?>, Object[]) line: not available [native method]	
	NativeConstructorAccessorImpl.newInstance(Object[]) line: 62	
	DelegatingConstructorAccessorImpl.newInstance(Object[]) line: 45	
	Constructor<T>.newInstance(Object...) line: 422	
	Class<T>.newInstance() line: 442	
	ExtensionLoader<T>.createAdaptiveExtension() line: 721	
	ExtensionLoader<T>.getAdaptiveExtension() line: 455	
	ExtensionLoader<T>.<init>(Class<?>) line: 129	
	ExtensionLoader<T>.getExtensionLoader(Class<T>) line: 121	
	TestExtension.main(String[]) line: 13	
```
Example: get DefaultExtention	
``` java

	ExtensionLoader<T>.injectExtension(T) line: 547	
	ExtensionLoader<T>.createExtension(String) line: 509	
	ExtensionLoader<T>.getExtension(String) line: 319	
	ExtensionLoader<T>.getDefaultExtension() line: 336	
	AdaptiveExtension.sayHello(String, ExtensionType) line: 12	
	TestExtension.main(String[]) line: 17	
	
```

#### ExtensionLoader几个重要的属性结构
http://bbs.dubboclub.net/read-3.html
基本上Dubbo的所有东西都是在扩展点的基础上实现的。比如dubbo支持netty，mima或者zookeeper，这些东西都是dubbo中的一个扩展点。所以理解了dubbo的扩展点的思想，那么dubbo的其他每个扩展点怎么实现，那么就相对容易点了。
扩展点是Dubbo的核心，而扩展点的核心则是ExtensionLoader，这个类有点类似ClassLoader，但是ExtensionLoader是加载Dubbo的扩展点的。下面列出ExtensionLoader几个重要的属性结构。

``` java

	public class ExtensionLoader<T> {
	private static final ConcurrentMap<Class<?>, ExtensionLoader<?>> EXTENSION_LOADERS = new ConcurrentHashMap<Class<?>, ExtensionLoader<?>>();
	      
	private static final ConcurrentMap<Class<?>, Object> EXTENSION_INSTANCES = new ConcurrentHashMap<Class<?>, Object>();
	      
	private final Class<?> type;
	      
	private final ExtensionFactory objectFactory;
	      
	private final Holder<Map<String, Class<?>>> cachedClasses = new Holder<Map<String,Class<?>>>();
	private final Holder<Object> cachedAdaptiveInstance = new Holder<Object>();
}
```
1、可以看到EXTENSION_LOADERS属性是一个static final的，那么说明应该是一个常量，这个就是用来装载dubbo的所有扩展点的ExtensionLoader，在Dubbo中，每种类型的扩展点都会有一个与其对应的ExtensionLoader，类似jvm中每个Class都会有一个ClassLoader,每个ExtensionLoader会包含多个该扩展点的实现，类似一个ClassLoader可以加载多个具体的类，但是不同的ExtensionLoader之间是隔离的，这点也和ClassLoader类似。那么理解dubbo的ExtensionLoader可以拿ClassLoader来进行类比，这样会加快自己对它的理解。
2、另一个常量属性是EXTENSION_INSTANCES，他是一个具体扩展类的实体，用于缓存，防止由于扩展点比较重，导致会浪费没必要的资源，所以在实现扩展点的时候，一定要确保扩展点可单例化，否则可能会出现问题。
3、另一个重要的属性是type，这里的type一般是接口，用于制定扩展点的类型，因为dubbo的扩展点申明是SPI的方式，所以某一个类型扩展点，就需要申明一个扩展点接口。比如ExtensionFactory扩展点申明如下： 

``` java 

	@SPI
	public interface ExtensionFactory {
	      
	/**
	 * Get extension.
	 *
	 * @param type object type.
	 * @param name object name.
	 * @return object instance.
	 */
	<T> T getExtension(Class<T> type, String name);
	      
	}
```
dubbo加载某个类型的扩展点是会遍历三个目录(META-INF/services/,META-INF/dubbo/,META-INF/dubbo/internal/)下面查找type.getName的文件，里面的内容格式是extendName=classFullName,所以说type是告诉dubbo扩展点的类型，以及查找该类型扩展点的方式。
4、扩展点相互依赖注入，dubbo通过ExtensionFactory来解决，比如SpringExtensionFactory和SpiExtensionFactory,不同扩展点之间肯定存在依赖，那么其扩展点从哪里获取，就全部交给ExtensionFactory来实现，通过上面ExtensionFactory代码可以了解，要获取某个个具体的扩展点实现需要知道两个参数，第一个是扩展点类型，用于得到是哪个类型的扩展点，第二个是该扩展实现的名称，用于在某一类型的扩展中找到对应的实现。注意：在dubbo中ExtensionFactory也被当作是一个扩展，那么就更说明在dubbo中无处不是扩展，另一个注意点是：只有ExtensionFactory扩展的ExtensionLoader的objectFactory是null，其他的扩展的都必须有一个ExtensionFactory实现赋值给objectFactory属性。通过下面代码可以得知： 
``` java

	private ExtensionLoader(Class<?> type) {
    this.type = type;
    objectFactory = (type == ExtensionFactory.class ? null : ExtensionLoader.getExtensionLoader(ExtensionFactory.class).getAdaptiveExtension());
}
```
5、上面的代码又告诉我们一个信息，在ExtensionLoader.getExtensionLoader(ExtensionFactory.class)之后，不是直接返回某个扩展点，而是调用getAdaptiveExtension来获取一个扩展的适配器，这是为什么呢？因为一个扩展点有多个具体扩展的实现，那么直接通过ExtensionLoader直接返回一个扩展是不可靠的，需要一个适配器来根据实际情况返回具体的扩展实现。所以这里就有了cachedAdaptiveInstance属性的存在，dubbo里面的每个扩展的ExtensionLoader都有一个cachedAdaptiveInstance，这个属性的类型必须实现ExtensionLoader.type接口，这就是设计模式中的适配器模式。比如ExtensionFactory扩展点就有AdaptiveExtensionFactory适配器。扩展点的适配器可以是自己通过@Adaptive，也可以不提供实现，由dubbo通过动态生成Adaptive来提供一个适配器类。此处需要注意：Adaptive也是扩展点的某个实现，下面例举出ExtensionFactory扩展点的适配器： 
``` java

	@Adaptive
	public class AdaptiveExtensionFactory implements ExtensionFactory {
	      
	private final List<ExtensionFactory> factories;
	      
	public AdaptiveExtensionFactory() {
	    ExtensionLoader<ExtensionFactory> loader = ExtensionLoader.getExtensionLoader(ExtensionFactory.class);
	    List<ExtensionFactory> list = new ArrayList<ExtensionFactory>();
	    for (String name : loader.getSupportedExtensions()) {
	        list.add(loader.getExtension(name));
	    }
	    factories = Collections.unmodifiableList(list);
	}
	      
	public <T> T getExtension(Class<T> type, String name) {
	    for (ExtensionFactory factory : factories) {
	        T extension = factory.getExtension(type, name);
	        if (extension != null) {
	            return extension;
	        }
	    }
	    return null;
	}
	}
```
6、关于dubbo扩展点最后一个重要的属性就是cachedClasses,这个就是存储当前ExtensionLoader有哪些扩展点实现，从而可以实例化出某个具体的扩展点实体，cachedClasses声明为Holder<Map<String, Class<?>>>类型，其实可以理解为是Map<String, Class<?>>类型，Map的key是在type.getName文件中的=之前的内容，value这是这个扩展点实现的类对象了。 

通过上面分析，已经知道了dubbo可以做什么，以及dubbo的扩展点实现有了基本的了解。那么总结一下dubbo扩展点几个要点
1、一个扩展点类型一定是一个接口
2、一个扩展点一定对应一个ExtensionLoader
3、一个ExtensionLoader一定有一个Adapter
4、一个扩展点可以有多个实现，并且都是用一个ExtensionLoader进行加载
5、一个ExtensionLoader（除去ExtensionFactory扩展）都要有一个ExtensionFactory 

### Dubbo回声测试
http://my.oschina.net/jasonultimate/blog/420580
Dubbo的用户手册，看到了回声测试一小节:
>所有服务自动实现EchoService接口，只需将任意服务引用强制转型为EchoService，即可使用。
java中关于强制转换的一个限制：必须有继承关系，就是说两个类之间要能够进行类型转换，必须有继承关系才可以。 可是很明显，我们写的Dubbo服务接口是与EchoService接口没有任何集成关系的，这是如何实现的呢？

```
com.alibaba.dubbo.rpc.proxy.AbstractProxyFactory.getProxy(Invoker<T>)
interfaces[0] = invoker.getInterface();
interfaces[1] = EchoService.class;
```
Dubbo在为我们写的服务创建动态代理的时候，是在传入的接口中人为的增加了“EchoService.class”接口的，也就是说，通过创建动态代理的时候向接口中增加一个接口，来保证强制转换的合法性,这样就解决了强制转换的问题.
但是又一个问题来了，EchoService接口中的方法`$echo`是怎么实现的呢?因为我们写的接口是没有实现这个接口的，所以EchoService接口类中定义的方法也必然没有实现。
Dubbo提供了很多Filter，针对这个EchoService提供了一个EchoFilter实现：
```
com.alibaba.dubbo.rpc.filter.EchoFilter
return invoker.invoke(inv);
```
在方法里，直接判断当前执行的方法是不是$echo，如果是，则直接将参数返回，结束执行过程，否则继续执行后面的Filter。


## Dubbo一些逻辑
Dubbo分为注册中心、服务提供者(provider)、服务消费者(consumer)三个部分


### Alibaba Dubbo框架同步调用原理分析-1 - sun - 学无止境
[Source](http://sunjun041640.blog.163.com/blog/static/256268322011111874633997/)

Dubbo缺省协议采用单一长连接和NIO异步通讯，适合于小数据量大并发的服务调用，以及服务消费者机器数远大于服务提供者机器数的情况.

#### Dubbo缺省协议，使用基于mina1.1.7+hessian3.2.1的tbremoting交互
连接个数:单连接
连接方式:长连接
传输协议:TCP
传输方式:NIO异步传输
序列化:Hessian二进制序列化
适用范围:传入传出参数数据包较小(建议小于100K)，消费者比提供者个数多，单一消费者无法压满提供者，尽量不要用dubbo协议传输大文件或超大字符串.
适用场景:常规远程服务方法调用

#### 通常，一个典型的同步远程调用应该是这样的:
1， 客户端线程调用远程接口，向服务端发送请求，同时当前线程应该处于“暂停“状态，即线程不能向后执行了，必需要拿到服务端给自己的结果后才能向后执行
2， 服务端接到客户端请求后，处理请求，将结果给客户端
3， 客户端收到结果，然后当前线程继续往后执行

Dubbo里使用到了Socket(采用Apache mina框架做底层调用)来建立长连接，发送、接收数据，底层使用Apache mina框架的IoSession进行发送消息.

查看Dubbo文档及源代码可知，Dubbo底层使用Socket发送消息的形式进行数据传递，结合了mina框架，使用IoSession.write()方法，这个方法调用后对于整个远程调用(从发出请求到接收到结果)来说是一个异步的，即对于当前线程来说，将请求发送出来，线程就可以往后执行了，至于服务端的结果，是服务端处理完成后，再以消息的形式发送给客户端的.

#### 于是这里出现了2个问题:
1. 当前线程怎么让它“暂停”，等结果回来后，再向后执行？
2. 正如前面所说，Socket通信是一个全双工的方式，如果有多个线程同时进行远程方法调用，这时建立在client server之间的socket连接上会有很多双方发送的消息传递，前后顺序也可能是乱七八糟的，server处理完结果后，将结果消息发送给client，client收到很多消息，怎么知道哪个消息结果是原先哪个线程调用的？

#### 分析源代码，基本原理如下:
1. client一个线程调用远程接口，生成一个唯一的ID(比如一段随机字符串，UUID等)，Dubbo是使用AtomicLong从0开始累计数字的
2. 将打包的方法调用信息(如调用的接口名称，方法名称，参数值列表等)，和处理结果的回调对象callback，全部封装在一起，组成一个对象object
3. 向专门存放调用信息的全局ConcurrentHashMap里面put(ID, object)
4. 将ID和打包的方法调用信息封装成一对象connRequest，使用IoSession.write(connRequest)异步发送出去
5. 当前线程再使用callback的get()方法试图获取远程返回的结果，在get()内部，则使用synchronized获取回调对象callback的锁， 再先检测是否已经获取到结果，如果没有，然后调用callback的wait()方法，释放callback上的锁，让当前线程处于等待状态.
6. 服务端接收到请求并处理后，将结果(此结果中包含了前面的ID，即回传)发送给客户端，客户端socket连接上专门监听消息的线程收到消息，分析结果，取到ID，再从前面的ConcurrentHashMap里面get(ID)，从而找到callback，将方法调用结果设置到callback对象里
7. 监听线程接着使用synchronized获取回调对象callback的锁(因为前面调用过wait()，那个线程已释放callback的锁了)，再notifyAll()，唤醒前面处于等待状态的线程继续执行(callback的get()方法继续执行就能拿到调用结果了)，至此，整个过程结束

这里还需要画一个大图来描述，后面再补了
需要注意的是，这里的callback对象是每次调用产生一个新的，不能共享，否则会有问题；另外ID必需至少保证在一个Socket连接里面是唯一的.

#### 现在，前面两个问题已经有答案了，
1. 当前线程怎么让它“暂停”，等结果回来后，再向后执行？
 答:先生成一个对象obj，在一个全局map里put(ID,obj)存放起来，再用synchronized获取obj锁，再调用obj.wait()让当前线程处于等待状态，然后另一消息监听线程等到服务端结果来了后，再map.get(ID)找到obj，再用synchronized获取obj锁，再调用obj.notifyAll()唤醒前面处于等待状态的线程.

2. 正如前面所说，Socket通信是一个全双工的方式，如果有多个线程同时进行远程方法调用，这时建立在client server之间的socket连接上会有很多双方发送的消息传递，前后顺序也可能是乱七八糟的，server处理完结果后，将结果消息发送给client，client收到很多消息，怎么知道哪个消息结果是原先哪个线程调用的？
 答:使用一个ID，让其唯一，然后传递给服务端，再服务端又回传回来，这样就知道结果是原先哪个线程的了.


### Dubbo整体架构
#### 1、Dubbo与Spring的整合
Dubbo在使用上可以做到非常简单，不管是Provider还是Consumer都可以通过Spring的配置文件进行配置，配置完之后，就可以像使用spring bean一样进行服务暴露和调用了，完全看不到dubbo API的存在.这是因为dubbo使用了spring提供的可扩展Schema自定义配置支持.在spring配置文件中，可以像、这样进行配置.META-INF下的spring.handlers文件中指定了dubbo的XML解析类:DubboNamespaceHandler.像前面的被解析成ServiceConfig，被解析成ReferenceConfig等等.

#### 2、JDK SPI扩展
由于Dubbo是开源框架，必须要提供很多的可扩展点.Dubbo是通过扩展JDK SPI机制来实现可扩展的.具体来说，就是在META-INF目录下，放置文件名为接口全称，文件中为key、value键值对，value为具体实现类的全类名，key为标志值.由于dubbo使用了url总线的设计，即很多参数通过URL对象来传递，在实际中，具体要用到哪个值，可以通过url中的参数值来指定.
Dubbo对SPI的扩展是通过ExtensionLoader来实现的，查看ExtensionLoader的源码，可以看到Dubbo对JDK SPI做了三个方面的扩展:
(1)JDK SPI仅仅通过接口类名获取所有实现，而ExtensionLoader则通过接口类名和key值获取一个实现；
(2)Adaptive实现，就是生成一个代理类，这样就可以根据实际调用时的一些参数动态决定要调用的类了.
(3)自动包装实现，这种实现的类一般是自动激活的，常用于包装类，比如Protocol的两个实现类:ProtocolFilterWrapper、ProtocolListenerWrapper.

#### 3、url总线设计
Dubbo为了使得各层解耦，采用了url总线的设计.我们通常的设计会把层与层之间的交互参数做成Model，这样层与层之间沟通成本比较大，扩展起来也比较麻烦.因此，Dubbo把各层之间的通信都采用url的形式.比如，注册中心启动时，参数的url为:
registry://0.0.0.0:9090?codec=registry&transporter=netty
这就表示当前是注册中心，绑定到所有ip，端口是9090，解析器类型是registry，使用的底层网络通信框架是netty.

### Dubbo使用的设计模式
1、工厂模式
ServiceConfig中有个字段，代码是这样的:
```
private  static  final  Protocol protocol = ExtensionLoader.getExtensionLoader(Protocol. class ).getAdaptiveExtension();
```
Dubbo里有很多这种代码.这也是一种工厂模式，只是实现类的获取采用了JDK SPI的机制.这么实现的优点是可扩展性强，想要扩展实现，只需要在classpath下增加个文件就可以了，代码零侵入.另外，像上面的Adaptive实现，可以做到调用时动态决定调用哪个实现，但是由于这种实现采用了动态代理，会造成代码调试比较麻烦，需要分析出实际调用的实现类.

2、装饰器模式
Dubbo在启动和调用阶段都大量使用了装饰器模式.以Provider提供的调用链为例，具体的调用链代码是在ProtocolFilterWrapper的buildInvokerChain完成的，具体是将注解中含有group=provider的Filter实现，按照order排序，最后的调用顺序是
```
EchoFilter -> ClassLoaderFilter -> GenericFilter -> ContextFilter -> ExceptionFilter -> 
TimeoutFilter -> MonitorFilter -> TraceFilter
```
更确切地说，这里是装饰器和责任链模式的混合使用.例如，EchoFilter的作用是判断是否是回声测试请求，是的话直接返回内容，这是一种责任链的体现.而像ClassLoaderFilter则只是在主功能上添加了功能，更改当前线程的ClassLoader，这是典型的装饰器模式.

3、观察者模式
Dubbo的provider启动时，需要与注册中心交互，先注册自己的服务，再订阅自己的服务，订阅时，采用了观察者模式，开启一个listener.注册中心会每5秒定时检查是否有服务更新，如果有更新，向该服务的提供者发送一个notify消息，provider接受到notify消息后，即运行NotifyListener的notify方法，执行监听器方法.

4、动态代理模式
Dubbo扩展JDK SPI的类ExtensionLoader的Adaptive实现是典型的动态代理实现.Dubbo需要灵活地控制实现类，即在调用阶段动态地根据参数决定调用哪个实现类，所以采用先生成代理类的方法，能够做到灵活的调用.生成代理类的代码是ExtensionLoader的createAdaptiveExtensionClassCode方法.代理类的主要逻辑是，获取URL参数中指定参数的值作为获取实现类的key.

#### Dubbo Main启动方式浅析
服务容器是一个standalone的启动程序，因为后台服务不需要Tomcat或JBoss等Web容器的功能，如果硬要用Web容器去加载服务提供方，增加复杂性，也浪费资源.
服务容器只是一个简单的Main方法，并加载一个简单的Spring容器，用于暴露服务.
服务容器的加载内容可以扩展，内置了spring, jetty, log4j等加载，可通过Container扩展点进行扩展，参见:Container
Spring Container
    自动加载META-INF/spring目录下的所有Spring配置
    配置:(配在java命令-D参数或者dubbo.properties中)
        dubbo.spring.config=classpath*:META-INF/spring/*.xml ----配置spring配置加载位置

Jetty Container
    启动一个内嵌Jetty，用于汇报状态
    配置:(配在java命令-D参数或者dubbo.properties中)
        dubbo.jetty.port=8080 ----配置jetty启动端口
        dubbo.jetty.directory=/foo/bar ----配置可通过jetty直接访问的目录，用于存放静态文件
        dubbo.jetty.page=log,status,system ----配置显示的页面，缺省加载所有页面

Log4j Container
    自动配置log4j的配置，在多进程启动时，自动给日志文件按进程分目录
    配置:(配在java命令-D参数或者dubbo.properties中)
        dubbo.log4j.file=/foo/bar.log ----配置日志文件路径
        dubbo.log4j.level=WARN ----配置日志级别
        dubbo.log4j.subdirectory=20880 ----配置日志子目录，用于多进程启动，避免冲突

容器启动

如:(缺省只加载spring)
`java com.alibaba.dubbo.container.Main`

或:(通过main函数参数传入要加载的容器)
`java com.alibaba.dubbo.container.Main spring jetty log4j`

或:(通过JVM启动参数传入要加载的容器)
`java com.alibaba.dubbo.container.Main -Ddubbo.container=spring,jetty,log4j`

或:(通过classpath下的dubbo.properties配置传入要加载的容器)
`dubbo.properties`
`dubbo.container=spring,jetty,log4j`

## 分布式服务框架远程服务通讯介绍 
[Hessian 原理分析](http://blog.sina.com.cn/s/blog_56fd58ab0100mrl6.html)
[java 几种远程服务调用协议的比较](http://www.cnblogs.com/jifeng/archive/2011/07/20/2111183.html)
在分布式服务框架中，一个最基础的问题就是远程服务是怎么通讯的，在Java领域中有很多可实现远程通讯 的技术，例如:RMI、MINA、ESB、Burlap、Hessian、SOAP、EJB和JMS等
那么在了解这些远程通讯的框架或library时，会带着什么问题去学 习呢？
1、是基于什么协议实现的？
2、怎么发起请求？
3、怎么将请求转化为符合协议的格式的？
4、使用什么传输协议传输？
5、响应端基于什么机制来接收请求？
6、怎么将流还原为传输格式的？
7、处理完毕后怎么回应？