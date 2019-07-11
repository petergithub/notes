# Otter

## Code
[Otter源代码解析（一）](http://eyuxu.iteye.com/blog/1941894)

### 页面
#### Pipeline管理
channel管理  ->  Pipeline管理 `/pipeline_list.htm?channelId=1`
pipelineList.vm -> com.alibaba.otter.manager.web.home.module.screen.PipelineList
延迟时间:
  延迟时间 = 数据库同步到目标库成功时间 - 数据库源库产生变更时间(binlog事件产生的时间)， 单位秒. (由对应node节点定时推送配置)
  delayStats.get($pipeline.id).delayTime
最后同步时间:
  最后同步时间 = 数据库同步到目标库最近一次的成功时间 (当前同步关注的相关表，同步到目标库的最后一次成功时间)
  throughputStat.gmtModified
最后位点时间:
  最后位点时间 = 数据binlog消费最后一次更新位点的时间 (和同步时间区别：一个数据库可能存在别的表的变更，不会触发同步时间变更，但会触发位点时间变更)
  positionData.modifiedTime

获取延迟时间:
1. pipelineList.vm delayStats.get($pipeline.id).delayTime
2. delayStatService.findRealtimeDelayStat
3. delayStatDao.findRealtimeDelayStat() in sqlmap-mapping-delayStat.xml

更新延迟时间:
1. StatsRemoteServiceImpl()
2. StatsRemoteServiceImpl.flushDelayStat() or StatsRemoteServiceImpl.onDelayCount(DelayCountEvent)
3. DelayStatDAO.insertDelayStat(DelayStatDO) in sqlmap-mapping-delayStat.xml

获取同步时间:
1. pipelineList.vm throughputStat.gmtModified
2. throughputStatService.findThroughputStatByPipelineId()
3. throughputDao.findRealtimeThroughputStat in sqlmap-mapping-throughputStat.xml

更新同步时间:
1. StatsRemoteServiceImpl()
2. StatsRemoteServiceImpl.flushThroughputStat() or StatsRemoteServiceImpl.onThroughputStat(ThroughputStatEvent)
3. throughputDao.insertThroughputStat in sqlmap-mapping-throughputStat.xml

获取位点时间:
1. pipelineList.vm positionData.modifiedTime
2. arbitrateViewService.getCanalCursor()
3. orginZk.getData(path, false, stat): /otter/cacal/destinations/{0}/{1}

更新位点时间:
1. SessionHandler.messageReceived()
2. embeddedServer.ack()
3. canalInstance.getMetaManager().updateCursor(clientIdentity, positionRanges.getAck());
4. ZooKeeperMetaManager.updateCursor(ClientIdentity, Position): /otter/cacal/destinations/{0}/{1}

#### 添加 zookeeper 集群
机器管理 -> zookeeper 管理
addZookeeper.vm
AutoKeeperClusterAction

### CanalServer
[Cannal Introduction](https://github.com/alibaba/canal/wiki/Introduction)

otter默认使用的是内置版的canal server，所以我们主要看CanalServerWithEmbedded这个类。来看下他的启动过程

#### canal的工作原理
1. canal模拟mysql slave的交互协议，伪装自己为mysql slave，向mysql master发送dump协议
2. mysql master收到dump请求，开始推送binary log给slave(也就是canal)
3. canal解析binary log对象(原始为byte流)

#### instance模块：
1. eventParser (数据源接入，模拟slave协议和master进行交互，协议解析): com.alibaba.otter.canal.parse.inbound.mysql.MysqlEventParser
2. eventSink (Parser和Store链接器，进行数据过滤，加工，分发的工作)
3. eventStore (数据存储)
4. metaManager (增量订阅&消费信息管理器)

#### 其他
1. 处理客户端请求, 如ack, rollback等: SessionHandler.messageReceived()

#### CanalServer 启动
com.alibaba.otter.canal.server.embedded.CanalServerWithEmbedded.start(String)
com.alibaba.otter.canal.instance.core.AbstractCanalInstance.start()
com.alibaba.otter.canal.parse.inbound.AbstractEventParser.start()
com.alibaba.otter.canal.parse.inbound.mysql.MysqlEventParser.findStartPosition(ErosaConnection)

com.alibaba.otter.canal.instance.manager.CanalInstanceWithManager.CanalInstanceWithManager(Canal, String)


###  Otter源代码解析概览
包含三部分：Share | Node | Manager。 其中Share是Node和Manager共享的子系统，并不是独立部署的节点。Node和Manager是独立部署的。

#### Manager
管理的节点，逻辑上只有一个（一个Manager管理多个Node节点），如果不考虑HA的话。  
负责管理同步的数据定义，包括数据源、Channel、PipeLine、数据映射等，各个Node节点从Manager处获取并执行这些信息。  
另外还有监控等信息

#### Share各个子系统
1. Common: 公共内容定义
2. Arbitrate: 用于Manager与Node之间、Node与Node之间的调度、S.E.T.L几个过程的调度等；
3. Communication 数据传输的底层，上层的Pipe、一些调度等都是依赖于Communication的, 简单点说它负责点对点的Event发送和接收
4. etl:实际上并不负责ETL的具体实现，只是一些接口&数据结构的定义而已，具体的实现在Node里面。

#### Node各个子系统
1. Common：公共内容定义
2. Canal: Canal的封装，Otter采用的是Embed的方式引入Canal（Canal有Embed和独立运行两种模式）
3. Deployer：内置Jetty的启动
4. etl: S.E.T.L 调度、处理的实现，是Otter最复杂、也是最核心的部分

#### etl_mark
我的理解是具体的业务在执行事务的时候在事务头&尾插入一个标记，在同步BinLog的时候就会发现它，对于不需要同步的数据打上特殊标记（比如_SYNC),  这样在S.E.T.L的过程中就可以过滤掉这些数据（可以参见：`com.alibaba.otter.node.etl.select.selector.MessageParser`这个类的实现）

#### 数据库反查
正常同步的内容是基于BinLog的，即BinLog有什么数据就同步什么数据，但是如果同步的数据延迟时间比较长的话，可能在同步的数据已经发生了变化（即BinLog里面的数据已经是旧的数据了），为了避免这个问题，在Extract阶段根据条件进行数据库查询，可以参见：`com.alibaba.otter.node.etl.extract.extractor.DatabaseExtractor`

#### shared.communication Communication
理解Communication的关键在于Event的模式+EndPoint方式进行远程调用。 Dubbo也是一个阿里开源的远程调用框架，实际上Dubbo支持很多种调用的方式，但是在Otter里面只使用到了EndPoint这一种方式。
1. DefaultCommunicationClientImpl.call(String, Event, Callback)
2. 传递数据到目标server上: DubboCommunicationConnection.call(Event)
3. 处理指定的事件: AbstractCommunicationEndpoint.acceptEvent(Event)
4. 反射调用方法: method.invoke(action, new Object[] { event })

#### node.common Common
[Otter源代码解析(四)](http://eyuxu.iteye.com/blog/1942521)
node节点是在Manager上面管理的，但是Node节点实际上是需要与其他的Node节点及manager通讯的，因此NodeList（Group内的其他节点）的信息在Node节点是需要相互知道的。 Otter采用的是类似于Lazy+cache的模式管理的。即：
1. 真正使用到的时候再考虑去Manager节点取过来；
2. 取过来以后暂存到本地内存，但是伴随着一个失效机制（失效机制的检查是不单独占用线程的，这个同学们可以注意一下，设计框架的时候需要尽可能做到这一点）

com.alibaba.otter.node.common.config.impl.ConfigClientServiceImpl

#### node.canal Canal的接入
1. Canal的接入是Embed方式的 CanalServerWithEmbedded
2. Canal的节点的信息实际上是在Manager节点上面维护
3. CanalEmbedSelector -> CanalServerWithEmbedded, CanalConfigClient

#### node.etl
S.E.T.L模块之间的数据交互工具: com.alibaba.otter.node.etl.common.pipe.Pipe<T, KEY>
[Otter源代码解析(五)](http://eyuxu.iteye.com/blog/1942522)  

PipeLine主要的操作就是Put/Get，对于S-->E、T-->L，还有节点内部的处理，可以使用基于Memory的PipeLine，对于远程的节点数据传输（比如E-->T的跨节点传输），使用的是RPC或者Http
1. 数据传输实际上是Pull的模式，并不是Push的模式，即数据准备好以后等待另外一端需要的时候再传输；
2. 数据的序列化采用的是[ProtoBuf](https://code.google.com/p/protobuf/), 也可以做加密传输，但是使用的Key是Path，一般性的安全需求可以满足，但是如果传输的数据是非常敏感的，还是用专线的好；
3. 压缩也是在Pipe这一层做掉的，具体就不展开了。

基于文件附件的http协议的管道: AttachmentHttpPipe
基于http下载的pipe实现: RowDataHttpPipe
基于内存版本的pipe实现: RowDataMemoryPipe

每个SETL过程的设计基本上都是由xxxTask + OtterXXXFactroy + OtterXXX的设计方式，但是细节上差别比较大。

### SelectTask
[Otter源代码解析（六）](http://eyuxu.iteye.com/blog/1942549)  

CanalSelector 作为 Select 过程的唯一个数据提供源
Select过程是需要串行的（需要保证顺序性），但是为了尽可能提高效率，将Get和ACK（Canal的滑动窗口）分在两个线程里面去做，依据的假定就是绝大多数数据是不需要回滚的

1. `SelectTask.ack(Long)` 进行 batch id 的确认。确认之后，小于等于此 batchId 的 Message 都会被确认。

打印日志: MessageDumper.dumpMessageInfo()
```
****************************************************
* Batch Id: [8] ,total : [3] , normal : [1] , filter :[2] , Time : 2017-12-28 20:15:09:818
* Start : [mysql-bin.000294:66083924:1514463309000(2017-12-28 20:15:09)]
* End : [mysql-bin.000294:66084111:1514463309000(2017-12-28 20:15:09)]
****************************************************
```

### ExtractTask 保存文件
com.alibaba.otter.node.etl.extract.ExtractTask
1. com.alibaba.otter.node.etl.extract.ExtractTask.run()
2. otterExtractorFactory.extract(dbBatch);// 重新装配一下数据
3. List<PipeKey> pipeKeys = rowDataPipeDelegate.put(dbBatch, nextNodeId); //  将对应的数据传递到指定的Node id节点上
3.1 local: RowDataMemoryPipe.put()
3.2 remote: AttachmentHttpPipe.put()

### TransformTask
Transform实际上解决的就是异构数据的映射，在Transform这个节点做相应的转换  
com.alibaba.otter.node.etl.transform.TransformTask
1. TransformTask.run()
2. 获取文件 DbBatch dbBatch = rowDataPipeDelegate.get(keys);
2.0 从zookeeper 获取 processId: `EtlEventData etlEventData = arbitrateEventService.loadEvent().await(pipelineId);`
  `./zkCli.sh -server localhost:2181`, `ls /otter/channel/1/1/process`
2.1 com.alibaba.otter.node.etl.common.pipe.impl.RowDataPipeDelegate.get(List<PipeKey>)
2.2 attachmentHttpPipe.get(pipeKey) -> unpackFile(key)
2.3 下载文件并解压缩: dataRetrieverFactory.createRetriever
3. 传递给下一个流程: rowDataPipeDelegate.put()
3.1 local: RowDataMemoryPipe.put()
3.2 remote: AttachmentHttpPipe.put()

### LoadTask
#### [Otter源代码解析(八)](http://eyuxu.iteye.com/blog/1942780)
1. Load过程是并发执行的，但是受Weight的控制（并非全局的）；
2. 在Load过程中包含了打标记的过程（与Select过程是呼应的，即Load打的标记会被Select过程所识别，然后不会同步回去了，这一点官方文档有相关说明，不过我看了代码之后才最终理解，所以做下补充说明）
3. FileLoadAction没有展开来解析，比较容易理解，读者可自行阅读相关的逻辑。

com.alibaba.otter.node.etl.load.LoadTask
1. LoadTask.run()
2. 获取文件: DbBatch dbBatch = rowDataPipeDelegate.get(keys);
3. OtterLoaderFactory.load(dbBatch)
4. DataBatchLoader.load(DbBatch)
5. 返回结果为已处理成功的记录: DbLoadAction.load(RowBatch, WeightController)
5.1 ddl语句: DbLoadAction.doDdl(DbLoadContext, List<EventData>)
5.2 非ddl语句:
5.2.1 进行一次数据合并，合并相同pk的多次I/U/D操作: DbLoadMerger.merge(items);
5.2.2 DbLoadAction.doLoad(DbLoadContext, DbLoadData)

### Other
#### Alarm
发送邮件进行报警
1. 插入Queue: `AbstractAlarmService.sendAlarm(AlarmMessage)`
2. 读取Queue发送邮件: `AbstractAlarmService.sendAlarmInternal()`
2.1 DefaultAlarmService.doSend(AlarmMessage)

#### User
user: admin 801fc357a5a74743894a  
`insert into user (username,password,AUTHORIZETYPE,DEPARTMENT,REALNAME,GMT_CREATE) values ('admin2','801fc357a5a74743894a', 'ADMIN', 'admin', 'admin', '2017-12-25 13:16:00')`


#### Exception stack
```
  Problem accessing /node_info.htm. Reason:
      Failed to invoke Valve[#2/3, level 3]: com.alibaba.citrus.turbine.pipeline.valve.PerformTemplateScreenValve#d87d449:PerformTemplateScreenValve
  Caused by:
  com.alibaba.citrus.service.pipeline.PipelineException: Failed to invoke Valve[#2/3, level 3]: com.alibaba.citrus.turbine.pipeline.valve.PerformTemplateScreenValve#d87d449:PerformTemplateScreenValve
  	at com.alibaba.citrus.service.pipeline.impl.PipelineImpl$PipelineContextImpl.invokeNext(PipelineImpl.java:161)
  	at com.alibaba.citrus.turbine.pipeline.valve.PerformActionValve.invoke(PerformActionValve.java:73)
  	at com.alibaba.citrus.service.pipeline.impl.PipelineImpl$PipelineContextImpl.invokeNext(PipelineImpl.java:157)
  	at com.alibaba.citrus.service.pipeline.impl.PipelineImpl$PipelineContextImpl.invoke(PipelineImpl.java:210)
  	at com.alibaba.citrus.service.pipeline.impl.valve.ChooseValve.invoke(ChooseValve.java:98)
  	at com.alibaba.citrus.service.pipeline.impl.PipelineImpl$PipelineContextImpl.invokeNext(PipelineImpl.java:157)
  	at com.alibaba.citrus.service.pipeline.impl.PipelineImpl$PipelineContextImpl.invoke(PipelineImpl.java:210)
  	at com.alibaba.citrus.service.pipeline.impl.valve.LoopValve.invokeBody(LoopValve.java:105)
  	at com.alibaba.citrus.service.pipeline.impl.valve.LoopValve.invoke(LoopValve.java:83)
  	at com.alibaba.citrus.service.pipeline.impl.PipelineImpl$PipelineContextImpl.invokeNext(PipelineImpl.java:157)
  	at com.alibaba.citrus.turbine.pipeline.valve.CheckCsrfTokenValve.invoke(CheckCsrfTokenValve.java:123)
  	at com.alibaba.citrus.service.pipeline.impl.PipelineImpl$PipelineContextImpl.invokeNext(PipelineImpl.java:157)
  	at com.alibaba.otter.manager.web.webx.valve.AuthContextValve.invoke(AuthContextValve.java:124)
  	at com.alibaba.citrus.service.pipeline.impl.PipelineImpl$PipelineContextImpl.invokeNext(PipelineImpl.java:157)
  	at com.alibaba.citrus.turbine.pipeline.valve.AnalyzeURLValve.invoke(AnalyzeURLValve.java:126)
  	at com.alibaba.citrus.service.pipeline.impl.PipelineImpl$PipelineContextImpl.invokeNext(PipelineImpl.java:157)
  	at com.alibaba.citrus.turbine.pipeline.valve.SetLoggingContextValve.invoke(SetLoggingContextValve.java:66)
  	at com.alibaba.citrus.service.pipeline.impl.PipelineImpl$PipelineContextImpl.invokeNext(PipelineImpl.java:157)
  	at com.alibaba.citrus.turbine.pipeline.valve.PrepareForTurbineValve.invoke(PrepareForTurbineValve.java:52)
  	at com.alibaba.citrus.service.pipeline.impl.PipelineImpl$PipelineContextImpl.invokeNext(PipelineImpl.java:157)
  	at com.alibaba.citrus.service.pipeline.impl.PipelineImpl$PipelineContextImpl.invoke(PipelineImpl.java:210)
  	at com.alibaba.citrus.webx.impl.WebxControllerImpl.service(WebxControllerImpl.java:43)
  	at com.alibaba.citrus.webx.impl.WebxRootControllerImpl.handleRequest(WebxRootControllerImpl.java:53)
  	at com.alibaba.citrus.webx.support.AbstractWebxRootController.service(AbstractWebxRootController.java:165)
  	at com.alibaba.citrus.webx.servlet.WebxFrameworkFilter.doFilter(WebxFrameworkFilter.java:152)
  	at com.alibaba.citrus.webx.servlet.FilterBean.doFilter(FilterBean.java:147)
  	at org.eclipse.jetty.servlet.ServletHandler$CachedChain.doFilter(ServletHandler.java:1307)
  	at com.alibaba.citrus.webx.servlet.SetLoggingContextFilter.doFilter(SetLoggingContextFilter.java:61)
  	at com.alibaba.citrus.webx.servlet.FilterBean.doFilter(FilterBean.java:147)
  	at org.eclipse.jetty.servlet.ServletHandler$CachedChain.doFilter(ServletHandler.java:1307)
  	at org.eclipse.jetty.servlet.ServletHandler.doHandle(ServletHandler.java:453)
  	at org.eclipse.jetty.server.handler.ScopedHandler.handle(ScopedHandler.java:137)
  	at org.eclipse.jetty.security.SecurityHandler.handle(SecurityHandler.java:559)
  	at org.eclipse.jetty.server.session.SessionHandler.doHandle(SessionHandler.java:231)
  	at org.eclipse.jetty.server.handler.ContextHandler.doHandle(ContextHandler.java:1072)
  	at org.eclipse.jetty.servlet.ServletHandler.doScope(ServletHandler.java:382)
  	at org.eclipse.jetty.server.session.SessionHandler.doScope(SessionHandler.java:193)
  	at org.eclipse.jetty.server.handler.ContextHandler.doScope(ContextHandler.java:1006)
  	at org.eclipse.jetty.server.handler.ScopedHandler.handle(ScopedHandler.java:135)
  	at org.eclipse.jetty.server.handler.HandlerWrapper.handle(HandlerWrapper.java:116)
  	at org.eclipse.jetty.server.Server.handle(Server.java:361)
  	at org.eclipse.jetty.server.AbstractHttpConnection.handleRequest(AbstractHttpConnection.java:485)
  	at org.eclipse.jetty.server.AbstractHttpConnection.headerComplete(AbstractHttpConnection.java:926)
  	at org.eclipse.jetty.server.AbstractHttpConnection$RequestHandler.headerComplete(AbstractHttpConnection.java:988)
  	at org.eclipse.jetty.http.HttpParser.parseNext(HttpParser.java:635)
  	at org.eclipse.jetty.http.HttpParser.parseAvailable(HttpParser.java:235)
  	at org.eclipse.jetty.server.AsyncHttpConnection.handle(AsyncHttpConnection.java:82)
  	at org.eclipse.jetty.io.nio.SelectChannelEndPoint.handle(SelectChannelEndPoint.java:627)
  	at org.eclipse.jetty.io.nio.SelectChannelEndPoint$1.run(SelectChannelEndPoint.java:51)
  	at org.eclipse.jetty.util.thread.QueuedThreadPool.runJob(QueuedThreadPool.java:608)
  	at org.eclipse.jetty.util.thread.QueuedThreadPool$3.run(QueuedThreadPool.java:543)
  	at java.lang.Thread.run(Thread.java:748)
  Caused by: com.alibaba.citrus.webx.WebxException: Failed to execute screen: NodeInfo
  	at com.alibaba.citrus.turbine.pipeline.valve.PerformScreenValve.performScreenModule(PerformScreenValve.java:126)
  	at com.alibaba.citrus.turbine.pipeline.valve.PerformScreenValve.invoke(PerformScreenValve.java:74)
  	at com.alibaba.citrus.service.pipeline.impl.PipelineImpl$PipelineContextImpl.invokeNext(PipelineImpl.java:157)
  	... 51 more
  Caused by: com.alibaba.otter.manager.biz.common.exceptions.ManagerException: com.google.common.collect.ComputationException: com.alibaba.otter.manager.biz.common.exceptions.ManagerException: java.rmi.ConnectException: Connection refused to host: 172.25.70.48; nested exception is:
  	java.net.ConnectException: Connection timed out (Connection timed out)
  	at com.alibaba.otter.manager.biz.remote.impl.NodeMBeanServiceImpl.getAttribute(NodeMBeanServiceImpl.java:192)
  	at com.alibaba.otter.manager.biz.remote.impl.NodeMBeanServiceImpl.getHeapMemoryUsage(NodeMBeanServiceImpl.java:88)
  	at com.alibaba.otter.manager.web.home.module.screen.NodeInfo.execute(NodeInfo.java:46)
  	at com.alibaba.otter.manager.web.home.module.screen.NodeInfo$$FastClassByCGLIB$$e4987a33.invoke(<generated>)
  	at net.sf.cglib.reflect.FastMethod.invoke(FastMethod.java:53)
  	at com.alibaba.citrus.service.moduleloader.impl.adapter.MethodInvoker.invoke(MethodInvoker.java:70)
  	at com.alibaba.citrus.service.moduleloader.impl.adapter.DataBindingAdapter.executeAndReturn(DataBindingAdapter.java:41)
  	at com.alibaba.citrus.turbine.pipeline.valve.PerformScreenValve.performScreenModule(PerformScreenValve.java:111)
  	... 53 more
  Caused by: com.google.common.collect.ComputationException: com.alibaba.otter.manager.biz.common.exceptions.ManagerException: java.rmi.ConnectException: Connection refused to host: 172.25.70.48; nested exception is:
  	java.net.ConnectException: Connection timed out (Connection timed out)
  	at com.google.common.collect.MapMaker$ComputingMapAdapter.get(MapMaker.java:889)
  	at com.alibaba.otter.manager.biz.remote.impl.NodeMBeanServiceImpl.getAttribute(NodeMBeanServiceImpl.java:189)
  	... 60 more
  Caused by: com.alibaba.otter.manager.biz.common.exceptions.ManagerException: java.rmi.ConnectException: Connection refused to host: 172.25.70.48; nested exception is:
  	java.net.ConnectException: Connection timed out (Connection timed out)
  	at com.alibaba.otter.manager.biz.remote.impl.NodeMBeanServiceImpl$1.apply(NodeMBeanServiceImpl.java:80)
  	at com.alibaba.otter.manager.biz.remote.impl.NodeMBeanServiceImpl$1.apply(NodeMBeanServiceImpl.java:57)
  	at com.google.common.collect.ComputingConcurrentHashMap$ComputingValueReference.compute(ComputingConcurrentHashMap.java:356)
  	at com.google.common.collect.ComputingConcurrentHashMap$ComputingSegment.compute(ComputingConcurrentHashMap.java:182)
  	at com.google.common.collect.ComputingConcurrentHashMap$ComputingSegment.getOrCompute(ComputingConcurrentHashMap.java:151)
  	at com.google.common.collect.ComputingConcurrentHashMap.getOrCompute(ComputingConcurrentHashMap.java:67)
  	at com.google.common.collect.MapMaker$ComputingMapAdapter.get(MapMaker.java:885)
  	... 61 more
  Caused by: java.rmi.ConnectException: Connection refused to host: 172.25.70.48; nested exception is:
  	java.net.ConnectException: Connection timed out (Connection timed out)
  	at sun.rmi.transport.tcp.TCPEndpoint.newSocket(TCPEndpoint.java:619)
  	at sun.rmi.transport.tcp.TCPChannel.createConnection(TCPChannel.java:216)
  	at sun.rmi.transport.tcp.TCPChannel.newConnection(TCPChannel.java:202)
  	at sun.rmi.server.UnicastRef.invoke(UnicastRef.java:129)
  	at javax.management.remote.rmi.RMIServerImpl_Stub.newClient(Unknown Source)
  	at javax.management.remote.rmi.RMIConnector.getConnection(RMIConnector.java:2430)
  	at javax.management.remote.rmi.RMIConnector.connect(RMIConnector.java:308)
  	at javax.management.remote.JMXConnectorFactory.connect(JMXConnectorFactory.java:270)
  	at com.alibaba.otter.manager.biz.remote.impl.NodeMBeanServiceImpl$1.apply(NodeMBeanServiceImpl.java:76)
  	... 67 more
  Caused by: java.net.ConnectException: Connection timed out (Connection timed out)
  	at java.net.PlainSocketImpl.socketConnect(Native Method)
  	at java.net.AbstractPlainSocketImpl.doConnect(AbstractPlainSocketImpl.java:350)
  	at java.net.AbstractPlainSocketImpl.connectToAddress(AbstractPlainSocketImpl.java:206)
  	at java.net.AbstractPlainSocketImpl.connect(AbstractPlainSocketImpl.java:188)
  	at java.net.SocksSocketImpl.connect(SocksSocketImpl.java:392)
  	at java.net.Socket.connect(Socket.java:589)
  	at java.net.Socket.connect(Socket.java:538)
  	at java.net.Socket.<init>(Socket.java:434)
  	at java.net.Socket.<init>(Socket.java:211)
  	at sun.rmi.transport.proxy.RMIDirectSocketFactory.createSocket(RMIDirectSocketFactory.java:40)
  	at sun.rmi.transport.proxy.RMIMasterSocketFactory.createSocket(RMIMasterSocketFactory.java:148)
  	at sun.rmi.transport.tcp.TCPEndpoint.newSocket(TCPEndpoint.java:613)
  	... 75 more

  Caused by:

  com.alibaba.citrus.webx.WebxException: Fa


at java.util.concurrent.FutureTask.report(FutureTask.java:122) ~[na:1.8.0_151]
at java.util.concurrent.FutureTask.get(FutureTask.java:192) ~[na:1.8.0_151]
at com.alibaba.otter.shared.communication.core.impl.DefaultCommunicationClientImpl.call(DefaultCommunicationClientImpl.java:152) ~[shared.communication-4.2.15.jar:na]
at com.alibaba.otter.manager.biz.remote.impl.ConfigRemoteServiceImpl.notifyChannel(ConfigRemoteServiceImpl.java:119) ~[manager.biz-4.2.15.jar:na]
at com.alibaba.otter.manager.biz.remote.impl.ConfigRemoteServiceImpl$$FastClassByCGLIB$$3f77feba.invoke(<generated>) ~[cglib-nodep-2.2.jar:na]
at net.sf.cglib.proxy.MethodProxy.invoke(MethodProxy.java:191) ~[cglib-nodep-2.2.jar:na]
at org.springframework.aop.framework.Cglib2AopProxy$CglibMethodInvocation.invokeJoinpoint(Cglib2AopProxy.java:689) ~[spring-aop-3.1.2.RELEASE.jar:3.1.2.RELEASE]
at org.springframework.aop.framework.ReflectiveMethodInvocation.proceed(ReflectiveMethodInvocation.java:150) ~[spring-aop-3.1.2.RELEASE.jar:3.1.2.RELEASE]
at org.springframework.aop.framework.adapter.ThrowsAdviceInterceptor.invoke(ThrowsAdviceInterceptor.java:124) ~[spring-aop-3.1.2.RELEASE.jar:3.1.2.RELEASE]
at org.springframework.aop.framework.ReflectiveMethodInvocation.proceed(ReflectiveMethodInvocation.java:172) ~[spring-aop-3.1.2.RELEASE.jar:3.1.2.RELEASE]
at org.springframework.aop.framework.Cglib2AopProxy$DynamicAdvisedInterceptor.intercept(Cglib2AopProxy.java:622) ~[spring-aop-3.1.2.RELEASE.jar:3.1.2.RELEASE]
at com.alibaba.otter.manager.biz.remote.impl.ConfigRemoteServiceImpl$$EnhancerByCGLIB$$d77c6472.notifyChannel(<generated>) ~[cglib-nodep-2.2.jar:na]
at com.alibaba.otter.manager.biz.config.channel.impl.ChannelServiceImpl$3.doInTransactionWithoutResult(ChannelServiceImpl.java:439) ~[manager.biz-4.2.15.jar:na]
at org.springframework.transaction.support.TransactionCallbackWithoutResult.doInTransaction(TransactionCallbackWithoutResult.java:33) [spring-tx-3.1.2.RELEASE.jar:3.1.2.RELEASE]
at org.springframework.transaction.support.TransactionTemplate.execute(TransactionTemplate.java:130) [spring-tx-3.1.2.RELEASE.jar:3.1.2.RELEASE]
at com.alibaba.otter.manager.biz.config.channel.impl.ChannelServiceImpl.switchChannelStatus(ChannelServiceImpl.java:378) [manager.biz-4.2.15.jar:na]
at com.alibaba.otter.manager.biz.config.channel.impl.ChannelServiceImpl.startChannel(ChannelServiceImpl.java:462) [manager.biz-4.2.15.jar:na]
at com.alibaba.otter.manager.web.home.module.action.ChannelAction.doStatus(ChannelAction.java:141) [manager.web-4.2.15.jar:na]
at com.alibaba.otter.manager.web.home.module.action.ChannelAction$$FastClassByCGLIB$$30bb2ee0.invoke(<generated>) [cglib-nodep-2.2.jar:na]
at net.sf.cglib.reflect.FastMethod.invoke(FastMethod.java:53) [cglib-nodep-2.2.jar:na]
at com.alibaba.citrus.service.moduleloader.impl.adapter.MethodInvoker.invoke(MethodInvoker.java:70) [citrus-webx-all-3.2.0.jar:3.2.0]
at com.alibaba.citrus.service.moduleloader.impl.adapter.AbstractModuleEventAdapter.executeAndReturn(AbstractModuleEventAdapter.java:100) [citrus-webx-all-3.2.0.jar:3.2.0]
at com.alibaba.citrus.service.moduleloader.impl.adapter.AbstractModuleEventAdapter.execute(AbstractModuleEventAdapter.java:58) [citrus-webx-all-3.2.0.jar:3.2.0]
at com.alibaba.citrus.turbine.pipeline.valve.PerformActionValve.invoke(PerformActionValve.java:63) [citrus-webx-all-3.2.0.jar:3.2.0]
at com.alibaba.citrus.service.pipeline.impl.PipelineImpl$PipelineContextImpl.invokeNext(PipelineImpl.java:157) [citrus-webx-all-3.2.0.jar:3.2.0]
at com.alibaba.citrus.service.pipeline.impl.PipelineImpl$PipelineContextImpl.invoke(PipelineImpl.java:210) [citrus-webx-all-3.2.0.jar:3.2.0]
at com.alibaba.citrus.service.pipeline.impl.valve.ChooseValve.invoke(ChooseValve.java:98) [citrus-webx-all-3.2.0.jar:3.2.0]
at com.alibaba.citrus.service.pipeline.impl.PipelineImpl$PipelineContextImpl.invokeNext(PipelineImpl.java:157) [citrus-webx-all-3.2.0.jar:3.2.0]
at com.alibaba.citrus.service.pipeline.impl.PipelineImpl$PipelineContextImpl.invoke(PipelineImpl.java:210) [citrus-webx-all-3.2.0.jar:3.2.0]
at com.alibaba.citrus.service.pipeline.impl.valve.LoopValve.invokeBody(LoopValve.java:105) [citrus-webx-all-3.2.0.jar:3.2.0]
at com.alibaba.citrus.service.pipeline.impl.valve.LoopValve.invoke(LoopValve.java:83) [citrus-webx-all-3.2.0.jar:3.2.0]
at com.alibaba.citrus.service.pipeline.impl.PipelineImpl$PipelineContextImpl.invokeNext(PipelineImpl.java:157) [citrus-webx-all-3.2.0.jar:3.2.0]
at com.alibaba.citrus.turbine.pipeline.valve.CheckCsrfTokenValve.invoke(CheckCsrfTokenValve.java:123) [citrus-webx-all-3.2.0.jar:3.2.0]
at com.alibaba.citrus.service.pipeline.impl.PipelineImpl$PipelineContextImpl.invokeNext(PipelineImpl.java:157) [citrus-webx-all-3.2.0.jar:3.2.0]
at com.alibaba.otter.manager.web.webx.valve.AuthContextValve.invoke(AuthContextValve.java:124) [manager.web-4.2.15.jar:na]
at com.alibaba.citrus.service.pipeline.impl.PipelineImpl$PipelineContextImpl.invokeNext(PipelineImpl.java:157) [citrus-webx-all-3.2.0.jar:3.2.0]
at com.alibaba.citrus.turbine.pipeline.valve.AnalyzeURLValve.invoke(AnalyzeURLValve.java:126) [citrus-webx-all-3.2.0.jar:3.2.0]
at com.alibaba.citrus.service.pipeline.impl.PipelineImpl$PipelineContextImpl.invokeNext(PipelineImpl.java:157) [citrus-webx-all-3.2.0.jar:3.2.0]
at com.alibaba.citrus.turbine.pipeline.valve.SetLoggingContextValve.invoke(SetLoggingContextValve.java:66) [citrus-webx-all-3.2.0.jar:3.2.0]
at com.alibaba.citrus.service.pipeline.impl.PipelineImpl$PipelineContextImpl.invokeNext(PipelineImpl.java:157) [citrus-webx-all-3.2.0.jar:3.2.0]
at com.alibaba.citrus.turbine.pipeline.valve.PrepareForTurbineValve.invoke(PrepareForTurbineValve.java:52) [citrus-webx-all-3.2.0.jar:3.2.0]
at com.alibaba.citrus.service.pipeline.impl.PipelineImpl$PipelineContextImpl.invokeNext(PipelineImpl.java:157) [citrus-webx-all-3.2.0.jar:3.2.0]
at com.alibaba.citrus.service.pipeline.impl.PipelineImpl$PipelineContextImpl.invoke(PipelineImpl.java:210) [citrus-webx-all-3.2.0.jar:3.2.0]
at com.alibaba.citrus.webx.impl.WebxControllerImpl.service(WebxControllerImpl.java:43) [citrus-webx-all-3.2.0.jar:3.2.0]
at com.alibaba.citrus.webx.impl.WebxRootControllerImpl.handleRequest(WebxRootControllerImpl.java:53) [citrus-webx-all-3.2.0.jar:3.2.0]
at com.alibaba.citrus.webx.support.AbstractWebxRootController.service(AbstractWebxRootController.java:165) [citrus-webx-all-3.2.0.jar:3.2.0]
at com.alibaba.citrus.webx.servlet.WebxFrameworkFilter.doFilter(WebxFrameworkFilter.java:152) [citrus-webx-all-3.2.0.jar:3.2.0]
at com.alibaba.citrus.webx.servlet.FilterBean.doFilter(FilterBean.java:147) [citrus-webx-all-3.2.0.jar:3.2.0]
at org.eclipse.jetty.servlet.ServletHandler$CachedChain.doFilter(ServletHandler.java:1307) [jetty-servlet-8.1.7.v20120910.jar:8.1.7.v20120910]
at com.alibaba.citrus.webx.servlet.SetLoggingContextFilter.doFilter(SetLoggingContextFilter.java:61) [citrus-webx-all-3.2.0.jar:3.2.0]
at com.alibaba.citrus.webx.servlet.FilterBean.doFilter(FilterBean.java:147) [citrus-webx-all-3.2.0.jar:3.2.0]
at org.eclipse.jetty.servlet.ServletHandler$CachedChain.doFilter(ServletHandler.java:1307) [jetty-servlet-8.1.7.v20120910.jar:8.1.7.v20120910]
at org.eclipse.jetty.servlet.ServletHandler.doHandle(ServletHandler.java:453) [jetty-servlet-8.1.7.v20120910.jar:8.1.7.v20120910]
at org.eclipse.jetty.server.handler.ScopedHandler.handle(ScopedHandler.java:137) [jetty-server-8.1.7.v20120910.jar:8.1.7.v20120910]
at org.eclipse.jetty.security.SecurityHandler.handle(SecurityHandler.java:559) [jetty-security-8.1.7.v20120910.jar:8.1.7.v20120910]
at org.eclipse.jetty.server.session.SessionHandler.doHandle(SessionHandler.java:231) [jetty-server-8.1.7.v20120910.jar:8.1.7.v20120910]
at org.eclipse.jetty.server.handler.ContextHandler.doHandle(ContextHandler.java:1072) [jetty-server-8.1.7.v20120910.jar:8.1.7.v20120910]
at org.eclipse.jetty.servlet.ServletHandler.doScope(ServletHandler.java:382) [jetty-servlet-8.1.7.v20120910.jar:8.1.7.v20120910]
at org.eclipse.jetty.server.session.SessionHandler.doScope(SessionHandler.java:193) [jetty-server-8.1.7.v20120910.jar:8.1.7.v20120910]
at org.eclipse.jetty.server.handler.ContextHandler.doScope(ContextHandler.java:1006) [jetty-server-8.1.7.v20120910.jar:8.1.7.v20120910]
at org.eclipse.jetty.server.handler.ScopedHandler.handle(ScopedHandler.java:135) [jetty-server-8.1.7.v20120910.jar:8.1.7.v20120910]
at org.eclipse.jetty.server.handler.HandlerWrapper.handle(HandlerWrapper.java:116) [jetty-server-8.1.7.v20120910.jar:8.1.7.v20120910]
at org.eclipse.jetty.server.Server.handle(Server.java:361) [jetty-server-8.1.7.v20120910.jar:8.1.7.v20120910]
at org.eclipse.jetty.server.AbstractHttpConnection.handleRequest(AbstractHttpConnection.java:485) [jetty-server-8.1.7.v20120910.jar:8.1.7.v20120910]
at org.eclipse.jetty.server.AbstractHttpConnection.headerComplete(AbstractHttpConnection.java:926) [jetty-server-8.1.7.v20120910.jar:8.1.7.v20120910]
at org.eclipse.jetty.server.AbstractHttpConnection$RequestHandler.headerComplete(AbstractHttpConnection.java:988) [jetty-server-8.1.7.v20120910.jar:8.1.7.v20120910]
at org.eclipse.jetty.http.HttpParser.parseNext(HttpParser.java:635) [jetty-http-8.1.7.v20120910.jar:8.1.7.v20120910]
at org.eclipse.jetty.http.HttpParser.parseAvailable(HttpParser.java:235) [jetty-http-8.1.7.v20120910.jar:8.1.7.v20120910]
at org.eclipse.jetty.server.AsyncHttpConnection.handle(AsyncHttpConnection.java:82) [jetty-server-8.1.7.v20120910.jar:8.1.7.v20120910]
at org.eclipse.jetty.io.nio.SelectChannelEndPoint.handle(SelectChannelEndPoint.java:627) [jetty-io-8.1.7.v20120910.jar:8.1.7.v20120910]
at org.eclipse.jetty.io.nio.SelectChannelEndPoint$1.run(SelectChannelEndPoint.java:51) [jetty-io-8.1.7.v20120910.jar:8.1.7.v20120910]
at org.eclipse.jetty.util.thread.QueuedThreadPool.runJob(QueuedThreadPool.java:608) [jetty-util-8.1.7.v20120910.jar:8.1.7.v20120910]
at org.eclipse.jetty.util.thread.QueuedThreadPool$3.run(QueuedThreadPool.java:543) [jetty-util-8.1.7.v20120910.jar:8.1.7.v20120910]
at java.lang.Thread.run(Thread.java:748) [na:1.8.0_151]


017-12-25 11:26:02.073 [/?action=channelAction&channelId=1&status=start&pageIndex=1&searchKey=&eventSubmitDoStatus=true] ERROR c.a.o.manager.biz.remote.impl.ConfigRemoteS
erviceImpl - ## notifyChannel error!
com.alibaba.otter.shared.communication.core.exception.CommunicationException: call addr[picooc400:2088] error by null
Caused by: java.lang.InterruptedException: null
        at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.reportInterruptAfterWait(AbstractQueuedSynchronizer.java:2014) ~[na:1.8.0_151]
        at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.await(AbstractQueuedSynchronizer.java:2048) ~[na:1.8.0_151]
        at java.util.concurrent.LinkedBlockingQueue.take(LinkedBlockingQueue.java:442) ~[na:1.8.0_151]
        at java.util.concurrent.ExecutorCompletionService.take(ExecutorCompletionService.java:193) ~[na:1.8.0_151]
        at com.alibaba.otter.shared.communication.core.impl.DefaultCommunicationClientImpl.call(DefaultCommunicationClientImpl.java:151) ~[shared.communication-4.2.15.jar:
na]
        at com.alibaba.otter.manager.biz.remote.impl.ConfigRemoteServiceImpl.notifyChannel(ConfigRemoteServiceImpl.java:119) ~[manager.biz-4.2.15.jar:na]
        at com.alibaba.otter.manager.biz.remote.impl.ConfigRemoteServiceImpl$$FastClassByCGLIB$$3f77feba.invoke(<generated>) [cglib-nodep-2.2.jar:na]
        at net.sf.cglib.proxy.MethodProxy.invoke(MethodProxy.java:191) [cglib-nodep-2.2.jar:na]
        at org.springframework.aop.framework.Cglib2AopProxy$CglibMethodInvocation.invokeJoinpoint(Cglib2AopProxy.java:689) [spring-aop-3.1.2.RELEASE.jar:3.1.2.RELEASE]
        at org.springframework.aop.framework.ReflectiveMethodInvocation.proceed(ReflectiveMethodInvocation.java:150) [spring-aop-3.1.2.RELEASE.jar:3.1.2.RELEASE]
        at org.springframework.aop.framework.adapter.ThrowsAdviceInterceptor.invoke(ThrowsAdviceInterceptor.java:124) [spring-aop-3.1.2.RELEASE.jar:3.1.2.RELEASE]
        at org.springframework.aop.framework.ReflectiveMethodInvocation.proceed(ReflectiveMethodInvocation.java:172) [spring-aop-3.1.2.RELEASE.jar:3.1.2.RELEASE]
        at org.springframework.aop.framework.Cglib2AopProxy$DynamicAdvisedInterceptor.intercept(Cglib2AopProxy.java:622) [spring-aop-3.1.2.RELEASE.jar:3.1.2.RELEASE]
        at com.alibaba.otter.manager.biz.remote.impl.ConfigRemoteServiceImpl$$EnhancerByCGLIB$$caf2a81c.notifyChannel(<generated>) [cglib-nodep-2.2.jar:na]
        at com.alibaba.otter.manager.biz.config.channel.impl.ChannelServiceImpl$3.doInTransactionWithoutResult(ChannelServiceImpl.java:439) [manager.biz-4.2.15.jar:na]
        at org.springframework.transaction.support.TransactionCallbackWithoutResult.doInTransaction(TransactionCallbackWithoutResult.java:33) [spring-tx-3.1.2.RELEASE.jar:
3.1.2.RELEASE]
        at org.springframework.transaction.support.TransactionTemplate.execute(TransactionTemplate.java:130) [spring-tx-3.1.2.RELEASE.jar:3.1.2.RELEASE]
        at com.alibaba.otter.manager.biz.config.channel.impl.ChannelServiceImpl.switchChannelStatus(ChannelServiceImpl.java:378) [manager.biz-4.2.15.jar:na]
        at com.alibaba.otter.manager.biz.config.channel.impl.ChannelServiceImpl.startChannel(ChannelServiceImpl.java:462) [manager.biz-4.2.15.jar:na]
        at com.alibaba.otter.manager.web.home.module.action.ChannelAction.doStatus(ChannelAction.java:141) [manager.web-4.2.15.jar:na]
        at com.alibaba.otter.manager.web.home.module.action.ChannelAction$$FastClassByCGLIB$$30bb2ee0.invoke(<generated>) [cglib-nodep-2.2.jar:na]
        at net.sf.cglib.reflect.FastMethod.invoke(FastMethod.java:53) [cglib-nodep-2.2.jar:na]
        at com.alibaba.citrus.service.moduleloader.impl.adapter.MethodInvoker.invoke(MethodInvoker.java:70) [citrus-webx-all-3.2.0.jar:3.2.0]
        at com.alibaba.citrus.service.moduleloader.impl.adapter.AbstractModuleEventAdapter.executeAndReturn(AbstractModuleEventAdapter.java:100) [citrus-webx-all-3.2.0.jar
:3.2.0]
        at com.alibaba.citrus.service.moduleloader.impl.adapter.AbstractModuleEventAdapter.execute(AbstractModuleEventAdapter.java:58) [citrus-webx-all-3.2.0.jar:3.2.0]
        at com.alibaba.citrus.turbine.pipeline.valve.PerformActionValve.invoke(PerformActionValve.java:63) [citrus-webx-all-3.2.0.jar:3.2.0]
        at com.alibaba.citrus.service.pipeline.impl.PipelineImpl$PipelineContextImpl.invokeNext(PipelineImpl.java:157) [citrus-webx-all-3.2.0.jar:3.2.0]
        at com.alibaba.citrus.service.pipeline.impl.PipelineImpl$PipelineContextImpl.invoke(PipelineImpl.java:210) [citrus-webx-all-3.2.0.jar:3.2.0]
        at com.alibaba.citrus.service.pipeline.impl.valve.ChooseValve.invoke(ChooseValve.java:98) [citrus-webx-all-3.2.0.jar:3.2.0]
        at com.alibaba.citrus.service.pipeline.impl.PipelineImpl$PipelineContextImpl.invokeNext(PipelineImpl.java:157) [citrus-webx-all-3.2.0.jar:3.2.0]
        at com.alibaba.citrus.service.pipeline.impl.PipelineImpl$PipelineContextImpl.invoke(PipelineImpl.java:210) [citrus-webx-all-3.2.0.jar:3.2.0]
        at com.alibaba.citrus.service.pipeline.impl.valve.LoopValve.invokeBody(LoopValve.java:105) [citrus-webx-all-3.2.0.jar:3.2.0]
        at com.alibaba.citrus.service.pipeline.impl.valve.LoopValve.invoke(LoopValve.java:83) [citrus-webx-all-3.2.0.jar:3.2.0]
        at com.alibaba.citrus.service.pipeline.impl.PipelineImpl$PipelineContextImpl.invokeNext(PipelineImpl.java:157) [citrus-webx-all-3.2.0.jar:3.2.0]
        at com.alibaba.citrus.turbine.pipeline.valve.CheckCsrfTokenValve.invoke(CheckCsrfTokenValve.java:123) [citrus-webx-all-3.2.0.jar:3.2.0]
        at com.alibaba.citrus.service.pipeline.impl.PipelineImpl$PipelineContextImpl.invokeNext(PipelineImpl.java:157) [citrus-webx-all-3.2.0.jar:3.2.0]
        at com.alibaba.otter.manager.web.webx.valve.AuthContextValve.invoke(AuthContextValve.java:124) [manager.web-4.2.15.jar:na]
        at com.alibaba.citrus.service.pipeline.impl.PipelineImpl$PipelineContextImpl.invokeNext(PipelineImpl.java:157) [citrus-webx-all-3.2.0.jar:3.2.0]
        at com.alibaba.citrus.turbine.pipeline.valve.AnalyzeURLValve.invoke(AnalyzeURLValve.java:126) [citrus-webx-all-3.2.0.jar:3.2.0]
        at com.alibaba.citrus.service.pipeline.impl.PipelineImpl$PipelineContextImpl.invokeNext(PipelineImpl.java:157) [citrus-webx-all-3.2.0.jar:3.2.0]
        at com.alibaba.citrus.turbine.pipeline.valve.SetLoggingContextValve.invoke(SetLoggingContextValve.java:66) [citrus-webx-all-3.2.0.jar:3.2.0]
        at com.alibaba.citrus.service.pipeline.impl.PipelineImpl$PipelineContextImpl.invokeNext(PipelineImpl.java:157) [citrus-webx-all-3.2.0.jar:3.2.0]
        at com.alibaba.citrus.turbine.pipeline.valve.PrepareForTurbineValve.invoke(PrepareForTurbineValve.java:52) [citrus-webx-all-3.2.0.jar:3.2.0]
        at com.alibaba.citrus.service.pipeline.impl.PipelineImpl$PipelineContextImpl.invokeNext(PipelineImpl.java:157) [citrus-webx-all-3.2.0.jar:3.2.0]
        at com.alibaba.citrus.service.pipeline.impl.PipelineImpl$PipelineContextImpl.invoke(PipelineImpl.java:210) [citrus-webx-all-3.2.0.jar:3.2.0]
        at com.alibaba.citrus.webx.impl.WebxControllerImpl.service(WebxControllerImpl.java:43) [citrus-webx-all-3.2.0.jar:3.2.0]
        at com.alibaba.citrus.webx.impl.WebxRootControllerImpl.handleRequest(WebxRootControllerImpl.java:53) [citrus-webx-all-3.2.0.jar:3.2.0]
        at com.alibaba.citrus.webx.support.AbstractWebxRootController.service(AbstractWebxRootController.java:165) [citrus-webx-all-3.2.0.jar:3.2.0]
        at com.alibaba.citrus.webx.servlet.WebxFrameworkFilter.doFilter(WebxFrameworkFilter.java:152) [citrus-webx-all-3.2.0.jar:3.2.0]
        at com.alibaba.citrus.webx.servlet.FilterBean.doFilter(FilterBean.java:147) [citrus-webx-all-3.2.0.jar:3.2.0]
        at org.eclipse.jetty.servlet.ServletHandler$CachedChain.doFilter(ServletHandler.java:1307) [jetty-servlet-8.1.7.v20120910.jar:8.1.7.v20120910]
        at com.alibaba.citrus.webx.servlet.SetLoggingContextFilter.doFilter(SetLoggingContextFilter.java:61) [citrus-webx-all-3.2.0.jar:3.2.0]
        at com.alibaba.citrus.webx.servlet.FilterBean.doFilter(FilterBean.java:147) [citrus-webx-all-3.2.0.jar:3.2.0]
        at org.eclipse.jetty.servlet.ServletHandler$CachedChain.doFilter(ServletHandler.java:1307) [jetty-servlet-8.1.7.v20120910.jar:8.1.7.v20120910]
        at org.eclipse.jetty.servlet.ServletHandler.doHandle(ServletHandler.java:453) [jetty-servlet-8.1.7.v20120910.jar:8.1.7.v20120910]
        at org.eclipse.jetty.server.handler.ScopedHandler.handle(ScopedHandler.java:137) [jetty-server-8.1.7.v20120910.jar:8.1.7.v20120910]
        at org.eclipse.jetty.security.SecurityHandler.handle(SecurityHandler.java:559) [jetty-security-8.1.7.v20120910.jar:8.1.7.v20120910]
        at org.eclipse.jetty.server.session.SessionHandler.doHandle(SessionHandler.java:231) [jetty-server-8.1.7.v20120910.jar:8.1.7.v20120910]
        at org.eclipse.jetty.server.handler.ContextHandler.doHandle(ContextHandler.java:1072) [jetty-server-8.1.7.v20120910.jar:8.1.7.v20120910]
        at org.eclipse.jetty.servlet.ServletHandler.doScope(ServletHandler.java:382) [jetty-servlet-8.1.7.v20120910.jar:8.1.7.v20120910]
        at org.eclipse.jetty.server.session.SessionHandler.doScope(SessionHandler.java:193) [jetty-server-8.1.7.v20120910.jar:8.1.7.v20120910]
        at org.eclipse.jetty.server.handler.ContextHandler.doScope(ContextHandler.java:1006) [jetty-server-8.1.7.v20120910.jar:8.1.7.v20120910]
        at org.eclipse.jetty.server.handler.ScopedHandler.handle(ScopedHandler.java:135) [jetty-server-8.1.7.v20120910.jar:8.1.7.v20120910]
        at org.eclipse.jetty.server.handler.HandlerWrapper.handle(HandlerWrapper.java:116) [jetty-server-8.1.7.v20120910.jar:8.1.7.v20120910]
        at org.eclipse.jetty.server.Server.handle(Server.java:365) [jetty-server-8.1.7.v20120910.jar:8.1.7.v20120910]
        at org.eclipse.jetty.server.AbstractHttpConnection.handleRequest(AbstractHttpConnection.java:485) [jetty-server-8.1.7.v20120910.jar:8.1.7.v20120910]
        at org.eclipse.jetty.server.AbstractHttpConnection.headerComplete(AbstractHttpConnection.java:926) [jetty-server-8.1.7.v20120910.jar:8.1.7.v20120910]
        at org.eclipse.jetty.server.AbstractHttpConnection$RequestHandler.headerComplete(AbstractHttpConnection.java:988) [jetty-server-8.1.7.v20120910.jar:8.1.7.v20120910]
        at org.eclipse.jetty.http.HttpParser.parseNext(HttpParser.java:635) [jetty-http-8.1.7.v20120910.jar:8.1.7.v20120910]
        at org.eclipse.jetty.http.HttpParser.parseAvailable(HttpParser.java:235) [jetty-http-8.1.7.v20120910.jar:8.1.7.v20120910]
        at org.eclipse.jetty.server.AsyncHttpConnection.handle(AsyncHttpConnection.java:82) [jetty-server-8.1.7.v20120910.jar:8.1.7.v20120910]
        at org.eclipse.jetty.io.nio.SelectChannelEndPoint.handle(SelectChannelEndPoint.java:627) [jetty-io-8.1.7.v20120910.jar:8.1.7.v20120910]
        at org.eclipse.jetty.io.nio.SelectChannelEndPoint$1.run(SelectChannelEndPoint.java:51) [jetty-io-8.1.7.v20120910.jar:8.1.7.v20120910]
        at org.eclipse.jetty.util.thread.QueuedThreadPool.runJob(QueuedThreadPool.java:608) [jetty-util-8.1.7.v20120910.jar:8.1.7.v20120910]
        at org.eclipse.jetty.util.thread.QueuedThreadPool$3.run(QueuedThreadPool.java:543) [jetty-util-8.1.7.v20120910.jar:8.1.7.v20120910]
        at java.lang.Thread.run(Thread.java:748) [na:1.8.0_151]
1
2017-12-26 18:47:28.782 [pipelineId = 1,taskName = TransformTask] INFO  com.alibaba.otter.node.etl.transform.TransformTask - [1] transformTask is interrupted!
java.lang.InterruptedException: null
        at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.reportInterruptAfterWait(AbstractQueuedSynchronizer.java:2014) ~[na:1.8.0_151]
        at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.await(AbstractQueuedSynchronizer.java:2048) ~[na:1.8.0_151]
        at com.alibaba.otter.shared.arbitrate.impl.setl.helper.ReplyProcessQueue.take(ReplyProcessQueue.java:57) ~[shared.arbitrate-4.2.15.jar:na]
        at com.alibaba.otter.shared.arbitrate.impl.setl.rpc.RpcStageController.waitForProcess(RpcStageController.java:81) ~[shared.arbitrate-4.2.15.jar:na]
        at com.alibaba.otter.shared.arbitrate.impl.setl.rpc.TransformRpcArbitrateEvent.await(TransformRpcArbitrateEvent.java:49) ~[shared.arbitrate-4.2.15.jar:na]
        at com.alibaba.otter.shared.arbitrate.impl.setl.delegate.TransformDelegateArbitrateEvent.await(TransformDelegateArbitrateEvent.java:36) ~[shared.arbitrate-4.2.15.jar:na]
        at com.alibaba.otter.shared.arbitrate.impl.setl.delegate.TransformDelegateArbitrateEvent$$FastClassByCGLIB$$3eefb486.invoke(<generated>) ~[cglib-nodep-2.2.jar:na]
        at net.sf.cglib.proxy.MethodProxy.invoke(MethodProxy.java:191) ~[cglib-nodep-2.2.jar:na]
        at org.springframework.aop.framework.Cglib2AopProxy$CglibMethodInvocation.invokeJoinpoint(Cglib2AopProxy.java:689) ~[spring-aop-3.1.2.RELEASE.jar:3.1.2.RELEASE]
        at org.springframework.aop.framework.ReflectiveMethodInvocation.proceed(ReflectiveMethodInvocation.java:150) ~[spring-aop-3.1.2.RELEASE.jar:3.1.2.RELEASE]
        at com.alibaba.otter.shared.arbitrate.impl.interceptor.LogInterceptor.invoke(LogInterceptor.java:53) ~[shared.arbitrate-4.2.15.jar:na]
        at org.springframework.aop.framework.ReflectiveMethodInvocation.proceed(ReflectiveMethodInvocation.java:172) ~[spring-aop-3.1.2.RELEASE.jar:3.1.2.RELEASE]
        at org.springframework.aop.framework.Cglib2AopProxy$DynamicAdvisedInterceptor.intercept(Cglib2AopProxy.java:622) ~[spring-aop-3.1.2.RELEASE.jar:3.1.2.RELEASE]
        at com.alibaba.otter.shared.arbitrate.impl.setl.delegate.TransformDelegateArbitrateEvent$$EnhancerByCGLIB$$2ffdadaf.await(<generated>) ~[cglib-nodep-2.2.jar:na]
        at com.alibaba.otter.node.etl.transform.TransformTask.run(TransformTask.java:57) ~[node.etl-4.2.15.jar:na]
2017-12-26 18:47:28.785 [pipelineId = 1,taskName = LoadTask] INFO  c.a.o.s.a.impl.setl.delegate.LoadDelegateArbitrateEvent -
=======================================
[Class:LoadDelegateArbitrateEvent , Method:await , time:2017-12-26 18:47:28.028 , take:70,119ms]
^M      1
Result^M        java.lang.InterruptedException
=======================================
2017-12-26 18:47:28.786 [pipelineId = 1,taskName = LoadTask] INFO  com.alibaba.otter.node.etl.load.LoadTask - [1] loadTask is interrupted!
java.lang.InterruptedException: null
        at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.reportInterruptAfterWait(AbstractQueuedSynchronizer.java:2014) ~[na:1.8.0_151]
        at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.await(AbstractQueuedSynchronizer.java:2048) ~[na:1.8.0_151]
        at com.alibaba.otter.shared.arbitrate.impl.setl.helper.ReplyProcessQueue.take(ReplyProcessQueue.java:57) ~[shared.arbitrate-4.2.15.jar:na]
        at com.alibaba.otter.shared.arbitrate.impl.setl.rpc.RpcStageController.waitForProcess(RpcStageController.java:81) ~[shared.arbitrate-4.2.15.jar:na]
        at com.alibaba.otter.shared.arbitrate.impl.setl.rpc.LoadRpcArbitrateEvent.await(LoadRpcArbitrateEvent.java:58) ~[shared.arbitrate-4.2.15.jar:na]
        at com.alibaba.otter.shared.arbitrate.impl.setl.delegate.LoadDelegateArbitrateEvent.await(LoadDelegateArbitrateEvent.java:36) ~[shared.arbitrate-4.2.15.jar:na]
        at com.alibaba.otter.shared.arbitrate.impl.setl.delegate.LoadDelegateArbitrateEvent$$FastClassByCGLIB$$df5299b2.invoke(<generated>) ~[cglib-nodep-2.2.jar:na]
        at net.sf.cglib.proxy.MethodProxy.invoke(MethodProxy.java:191) ~[cglib-nodep-2.2.jar:na]
        at org.springframework.aop.framework.Cglib2AopProxy$CglibMethodInvocation.invokeJoinpoint(Cglib2AopProxy.java:689) ~[spring-aop-3.1.2.RELEASE.jar:3.1.2.RELEASE]
        at org.springframework.aop.framework.ReflectiveMethodInvocation.proceed(ReflectiveMethodInvocation.java:150) ~[spring-aop-3.1.2.RELEASE.jar:3.1.2.RELEASE]
        at com.alibaba.otter.shared.arbitrate.impl.interceptor.LogInterceptor.invoke(LogInterceptor.java:53) ~[shared.arbitrate-4.2.15.jar:na]
        at org.springframework.aop.framework.ReflectiveMethodInvocation.proceed(ReflectiveMethodInvocation.java:172) ~[spring-aop-3.1.2.RELEASE.jar:3.1.2.RELEASE]
        at org.springframework.aop.framework.Cglib2AopProxy$DynamicAdvisedInterceptor.intercept(Cglib2AopProxy.java:622) ~[spring-aop-3.1.2.RELEASE.jar:3.1.2.RELEASE]
        at com.alibaba.otter.shared.arbitrate.impl.setl.delegate.LoadDelegateArbitrateEvent$$EnhancerByCGLIB$$1e83edd3.await(<generated>) ~[cglib-nodep-2.2.jar:na]

# Alarm
/data/software/manager/logs/monitor_info.log:2017-12-27 17:45:38.699 INFO  monitorInfo - has send alarm : AlarmMessage[message=pid:1 processIds:70373,70375,70374,70377,70376
 elapsed 79 seconds,receiveKey=qiemiaopu@picooc.com]; rule is com.alibaba.otter.shared.common.model.config.alarm.AlarmRule@14e6e102[id=7,pipelineId=1,status=ENABLE,monitorName=PROCESSTIMEOUT,receiverKey=qiemiaopu@picooc.com,matchValue=60,intervalTime=1800,pauseTime=Wed Dec 27 17:40:08 CST 2017,recoveryThresold=2,autoRecovery=true,description=one key added!,gmtCreate=Tue Dec 26 19:53:53 CST 2017,gmtModified=Wed Dec 27 17:40:10 CST 2017]

2017-12-27 17:45:38.751 ERROR c.a.otter.manager.biz.common.alarm.AbstractAlarmService - send alarm [AlarmMessage[message=pid:1 processIds:70373,70375,70374,70377,70376
elapsed 79 seconds,receiveKey=qiemiaopu@picooc.com]] to drgoon agent error!
java.lang.NullPointerException: null
        at com.alibaba.otter.manager.biz.common.alarm.DefaultAlarmService.doSend(DefaultAlarmService.java:39) ~[manager.biz-4.2.15.jar:na]
        at com.alibaba.otter.manager.biz.common.alarm.AbstractAlarmService.sendAlarmInternal(AbstractAlarmService.java:60) [manager.biz-4.2.15.jar:na]
        at com.alibaba.otter.manager.biz.common.alarm.AbstractAlarmService.access$000(AbstractAlarmService.java:38) [manager.biz-4.2.15.jar:na]
        at com.alibaba.otter.manager.biz.common.alarm.AbstractAlarmService$1.run(AbstractAlarmService.java:77) [manager.biz-4.2.15.jar:na]
        at java.util.concurrent.Executors$RunnableAdapter.call(Executors.java:511) [na:1.8.0_151]
        at java.util.concurrent.FutureTask.run(FutureTask.java:266) [na:1.8.0_151]
        at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1149) [na:1.8.0_151]
        at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624) [na:1.8.0_151]
        at java.lang.Thread.run(Thread.java:748) [na:1.8.0_151]

# Duplicate entry
pid:1 nid:4 exception:setl:com.alibaba.otter.node.etl.load.exception.LoadException: java.util.concurrent.ExecutionException: com.alibaba.otter.node.etl.load.exception.LoadException: com.alibaba.otter.node.etl.load.exception.LoadException: com.alibaba.otter.node.etl.load.exception.LoadException: org.springframework.dao.DuplicateKeyException: PreparedStatementCallback; SQL [update `picooc`.`role` set `time` = ? , `id` = ? , `name` = ? , `user_id` = ? where ( `id` = ? and `name` = ? and `user_id` = ? )]; Duplicate entry '7344875-李飛龍-3818665' for key 'PRIMARY'; nested exception is com.mysql.jdbc.exceptions.jdbc4.MySQLIntegrityConstraintViolationException: Duplicate entry '7344875-李飛龍-3818665' for key 'PRIMARY'
    at org.springframework.jdbc.support.SQLErrorCodeSQLExceptionTranslator.doTranslate(SQLErrorCodeSQLExceptionTranslator.java:241)
    at org.springframework.jdbc.support.AbstractFallbackSQLExceptionTranslator.translate(AbstractFallbackSQLExceptionTranslator.java:72)
    at org.springframework.jdbc.core.JdbcTemplate.execute(JdbcTemplate.java:603)
    at org.springframework.jdbc.core.JdbcTemplate.update(JdbcTemplate.java:812)
    at org.springframework.jdbc.core.JdbcTemplate.update(JdbcTemplate.java:868)
    at com.alibaba.otter.node.etl.load.loader.db.DbLoadAction$DbLoadWorker$2.doInTransaction(DbLoadAction.java:625)
    at org.springframework.transaction.support.TransactionTemplate.execute(TransactionTemplate.java:130)
    at com.alibaba.otter.node.etl.load.loader.db.DbLoadAction$DbLoadWorker.doCall(DbLoadAction.java:617)
    at com.alibaba.otter.node.etl.load.loader.db.DbLoadAction$DbLoadWorker.call(DbLoadAction.java:545)
    at com.alibaba.otter.node.etl.load.loader.db.DbLoadAction.doTwoPhase(DbLoadAction.java:462)
    at com.alibaba.otter.node.etl.load.loader.db.DbLoadAction.doLoad(DbLoadAction.java:275)
    at com.alibaba.otter.node.etl.load.loader.db.DbLoadAction.load(DbLoadAction.java:161)
    at com.alibaba.otter.node.etl.load.loader.db.DbLoadAction$$FastClassByCGLIB$$d932a4cb.invoke()
    at net.sf.cglib.proxy.MethodProxy.invoke(MethodProxy.java:191)
    at org.springframework.aop.framework.Cglib2AopProxy$DynamicAdvisedInterceptor.intercept(Cglib2AopProxy.java:618)
    at com.alibaba.otter.node.etl.load.loader.db.DbLoadAction$$EnhancerByCGLIB$$80fd23c2.load()
    at com.alibaba.otter.node.etl.load.loader.db.DataBatchLoader$2.call(DataBatchLoader.java:198)
    at com.alibaba.otter.node.etl.load.loader.db.DataBatchLoader$2.call(DataBatchLoader.java:189)
    at java.util.concurrent.FutureTask.run(FutureTask.java:266)
    at java.util.concurrent.Executors$RunnableAdapter.call(Executors.java:511)
    at java.util.concurrent.FutureTask.run(FutureTask.java:266)
    at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1149)
    at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
    at java.lang.Thread.run(Thread.java:748)
Caused by: com.mysql.jdbc.exceptions.jdbc4.MySQLIntegrityConstraintViolationException: Duplicate entry '7344875-李飛龍-3818665' for key 'PRIMARY'
    at sun.reflect.GeneratedConstructorAccessor22.newInstance(Unknown Source)
    at sun.reflect.DelegatingConstructorAccessorImpl.newInstance(DelegatingConstructorAccessorImpl.java:45)
    at java.lang.reflect.Constructor.newInstance(Constructor.java:423)
    at com.mysql.jdbc.Util.handleNewInstance(Util.java:389)
    at com.mysql.jdbc.Util.getInstance(Util.java:372)
    at com.mysql.jdbc.SQLError.createSQLException(SQLError.java:973)
    at com.mysql.jdbc.MysqlIO.checkErrorPacket(MysqlIO.java:3835)
    at com.mysql.jdbc.MysqlIO.checkErrorPacket(MysqlIO.java:3771)
    at com.mysql.jdbc.MysqlIO.sendCommand(MysqlIO.java:2435)
    at com.mysql.jdbc.MysqlIO.sqlQueryDirect(MysqlIO.java:2582)
    at com.mysql.jdbc.ConnectionImpl.execSQL(ConnectionImpl.java:2535)
    at com.mysql.jdbc.PreparedStatement.executeInternal(PreparedStatement.java:1911)
    at com.mysql.jdbc.PreparedStatement.executeUpdate(PreparedStatement.java:2145)
    at com.mysql.jdbc.PreparedStatement.executeUpdate(PreparedStatement.java:2081)
    at com.mysql.jdbc.PreparedStatement.executeUpdate(PreparedStatement.java:2066)
    at org.apache.commons.dbcp.DelegatingPreparedStatement.executeUpdate(DelegatingPreparedStatement.java:105)
    at org.apache.commons.dbcp.DelegatingPreparedStatement.executeUpdate(DelegatingPreparedStatement.java:105)
    at org.springframework.jdbc.core.JdbcTemplate$2.doInPreparedStatement(JdbcTemplate.java:818)
    at org.springframework.jdbc.core.JdbcTemplate$2.doInPreparedStatement(JdbcTemplate.java:1)
    at org.springframework.jdbc.core.JdbcTemplate.execute(JdbcTemplate.java:587)
    ... 21 more
:-----------------
- PairId: 379 , TableId: 339 , EventType : U , Time : 1514869785000
- Consistency : , Mode :
-----------------
---Pks
    EventColumn[index=0,columnType=4,columnName=id,columnValue=7344875,isNull=false,isKey=true,isUpdate=false]
    EventColumn[index=1,columnType=12,columnName=name,columnValue=李飛龍,isNull=false,isKey=true,isUpdate=true]
    EventColumn[index=8,columnType=4,columnName=user_id,columnValue=3818665,isNull=false,isKey=true,isUpdate=false]
---oldPks
    EventColumn[index=0,columnType=4,columnName=id,columnValue=7344875,isNull=false,isKey=true,isUpdate=false]
    EventColumn[index=1,columnType=12,columnName=name,columnValue=晓慧,isNull=false,isKey=true,isUpdate=true]
    EventColumn[index=8,columnType=4,columnName=user_id,columnValue=3818665,isNull=false,isKey=true,isUpdate=false]
---Columns
    EventColumn[index=22,columnType=93,columnName=time,columnValue=2018-01-02 13:09:45,isNull=false,isKey=false,isUpdate=true]
---Sql
    update `picooc`.`role` set `time` = ? , `id` = ? , `name` = ? , `user_id` = ? where ( `id` = ? and `name` = ? and `user_id` = ? )


# utf8mb4 字符
:-----------------
- PairId: 321 , TableId: 639 , EventType : U , Time : 1515744532000
- Consistency :  , Mode :  
-----------------
---Pks
        EventColumn[index=0,columnType=4,columnName=id,columnValue=2572404,isNull=false,isKey=true,isUpdate=false]
        EventColumn[index=1,columnType=4,columnName=picooc_uid,columnValue=1134204,isNull=false,isKey=true,isUpdate=false]
---oldPks
        EventColumn[index=0,columnType=4,columnName=id,columnValue=2572404,isNull=false,isKey=true,isUpdate=false]
        EventColumn[index=1,columnType=4,columnName=picooc_uid,columnValue=1134204,isNull=false,isKey=true,isUpdate=false]
---Columns
        EventColumn[index=2,columnType=12,columnName=latin_name,columnValue=Mini<U+1F608>,isNull=false,isKey=false,isUpdate=true]
        EventColumn[index=10,columnType=93,columnName=time,columnValue=2018-01-12 16:08:52,isNull=false,isKey=false,isUpdate=true]
---Sql
        update `picooc`.`v2_user_device` set  `latin_name` = ? , `time` = ? , `id` = ? , `picooc_uid` = ?  where ( `id` = ? and `picooc_uid` = ? )

2018-01-12 16:08:55.908 [DbLoadAction] ERROR com.alibaba.otter.node.etl.load.loader.db.DbLoadAction - ##load phase two failed!
com.alibaba.otter.node.etl.load.exception.LoadException: org.springframework.jdbc.UncategorizedSQLException: PreparedStatementCallback; uncategorized SQLException for SQL [update `picooc`.`v2_user_device` set  `latin_name` = ? , `time` = ? , `id` = ? , `picooc_uid` = ?  where ( `id` = ? and `picooc_uid` = ? )]; SQL state [HY000]; error code [1366]; Incorrect string value: '\xF0\x9F\x98\x88' for column 'latin_name' at row 1; nested exception is java.sql.SQLException: Incorrect string value: '\xF0\x9F\x98\x88' for column 'latin_name' at row 1
        at org.springframework.jdbc.support.AbstractFallbackSQLExceptionTranslator.translate(AbstractFallbackSQLExceptionTranslator.java:83)
        at org.springframework.jdbc.support.AbstractFallbackSQLExceptionTranslator.translate(AbstractFallbackSQLExceptionTranslator.java:80)
        at org.springframework.jdbc.core.JdbcTemplate.execute(JdbcTemplate.java:603)
        at org.springframework.jdbc.core.JdbcTemplate.update(JdbcTemplate.java:812)
        at org.springframework.jdbc.core.JdbcTemplate.update(JdbcTemplate.java:868)
        at com.alibaba.otter.node.etl.load.loader.db.DbLoadAction$DbLoadWorker$2.doInTransaction(DbLoadAction.java:625)
        at org.springframework.transaction.support.TransactionTemplate.execute(TransactionTemplate.java:130)
        at com.alibaba.otter.node.etl.load.loader.db.DbLoadAction$DbLoadWorker.doCall(DbLoadAction.java:617)
        at com.alibaba.otter.node.etl.load.loader.db.DbLoadAction$DbLoadWorker.call(DbLoadAction.java:545)
        at com.alibaba.otter.node.etl.load.loader.db.DbLoadAction.doTwoPhase(DbLoadAction.java:462)
        at com.alibaba.otter.node.etl.load.loader.db.DbLoadAction.doLoad(DbLoadAction.java:275)
        at com.alibaba.otter.node.etl.load.loader.db.DbLoadAction.load(DbLoadAction.java:161)
        at com.alibaba.otter.node.etl.load.loader.db.DbLoadAction$$FastClassByCGLIB$$d932a4cb.invoke(<generated>)
        at net.sf.cglib.proxy.MethodProxy.invoke(MethodProxy.java:191)
        at org.springframework.aop.framework.Cglib2AopProxy$DynamicAdvisedInterceptor.intercept(Cglib2AopProxy.java:618)
        at com.alibaba.otter.node.etl.load.loader.db.DbLoadAction$$EnhancerByCGLIB$$80fd23c2.load(<generated>)
        at com.alibaba.otter.node.etl.load.loader.db.DataBatchLoader$2.call(DataBatchLoader.java:198)
        at com.alibaba.otter.node.etl.load.loader.db.DataBatchLoader$2.call(DataBatchLoader.java:189)
        at java.util.concurrent.FutureTask.run(FutureTask.java:266)
        at java.util.concurrent.Executors$RunnableAdapter.call(Executors.java:511)
        at java.util.concurrent.FutureTask.run(FutureTask.java:266)
        at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1149)
        at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
        at java.lang.Thread.run(Thread.java:748)
Caused by: java.sql.SQLException: Incorrect string value: '\xF0\x9F\x98\x88' for column 'latin_name' at row 1
        at com.mysql.jdbc.SQLError.createSQLException(SQLError.java:998)
        at com.mysql.jdbc.MysqlIO.checkErrorPacket(MysqlIO.java:3835)
        at com.mysql.jdbc.MysqlIO.checkErrorPacket(MysqlIO.java:3771)
        at com.mysql.jdbc.MysqlIO.sendCommand(MysqlIO.java:2435)
        at com.mysql.jdbc.MysqlIO.sqlQueryDirect(MysqlIO.java:2582)
        at com.mysql.jdbc.ConnectionImpl.execSQL(ConnectionImpl.java:2535)
        at com.mysql.jdbc.PreparedStatement.executeInternal(PreparedStatement.java:1911)
        at com.mysql.jdbc.PreparedStatement.executeUpdate(PreparedStatement.java:2145)
        at com.mysql.jdbc.PreparedStatement.executeUpdate(PreparedStatement.java:2081)
        at com.mysql.jdbc.PreparedStatement.executeUpdate(PreparedStatement.java:2066)
        at org.apache.commons.dbcp.DelegatingPreparedStatement.executeUpdate(DelegatingPreparedStatement.java:105)
        at org.apache.commons.dbcp.DelegatingPreparedStatement.executeUpdate(DelegatingPreparedStatement.java:105)
        at org.springframework.jdbc.core.JdbcTemplate$2.doInPreparedStatement(JdbcTemplate.java:818)
        at org.springframework.jdbc.core.JdbcTemplate$2.doInPreparedStatement(JdbcTemplate.java:1)
        at org.springframework.jdbc.core.JdbcTemplate.execute(JdbcTemplate.java:587)


# Read bin logs
pid:1 nid:1 exception:canal:华北2区主库canal:java.io.IOException: Received error packet: errno = 1236, sqlstate = HY000 errmsg = Could not find first log file name in binary log index file
	at com.alibaba.otter.canal.parse.inbound.mysql.dbsync.DirectLogFetcher.fetch(DirectLogFetcher.java:94)
	at com.alibaba.otter.canal.parse.inbound.mysql.MysqlConnection.dump(MysqlConnection.java:137)
	at com.alibaba.otter.canal.parse.inbound.AbstractEventParser$3.run(AbstractEventParser.java:220)
	at java.lang.Thread.run(Thread.java:745)

# alter table /data/software/node/logs/1/row_load.log
****************************************************
* status : successed  , time : 2018-01-30 16:28:04:552 *
* Identity : Identity[channelId=1,pipelineId=1,processId=2004926] *
* total Data : [1] , success Data : [0] , failed Data : [1] , Interrupt : [false]
****************************************************
* process Data  *
-----------------
* failed Data *
-----------------
- PairId: 19 , TableId: 35 , EventType : CI , Time : 1517298688000
- Consistency :  , Mode :  
-----------------
---Pks
---oldPks
---Columns
---Sql
        alter table body_index add index server_time (server_time)
****************************************************


# Alarm
2018-02-16 19:24:52.047 [communication-async-0] INFO  c.a.otter.shared.arbitrate.impl.alarm.AlarmClientService - ##callManager successed! event:[NodeAlarmEvent[nid=5,pipel
ineId=3,title=EXCEPTION,message=canal:法兰克福主库canal:com.alibaba.otter.canal.parse.exception.CanalParseException: com.alibaba.otter.canal.parse.exception.CanalParseExce
ption: parse row data failed.
Caused by: com.alibaba.otter.canal.parse.exception.CanalParseException: parse row data failed.
Caused by: com.alibaba.otter.canal.parse.exception.CanalParseException: com.google.common.util.concurrent.UncheckedExecutionException: java.io.IOException: should execute
connector.connect() first
Caused by: com.google.common.util.concurrent.UncheckedExecutionException: java.io.IOException: should execute connector.connect() first
        at com.google.common.cache.LocalCache$LocalLoadingCache.getUnchecked(LocalCache.java:4832)
        at com.alibaba.otter.canal.parse.inbound.mysql.dbsync.TableMetaCache.getTableMeta(TableMetaCache.java:160)
        at com.alibaba.otter.canal.parse.inbound.mysql.dbsync.LogEventConvert.getTableMeta(LogEventConvert.java:759)
        at com.alibaba.otter.canal.parse.inbound.mysql.dbsync.LogEventConvert.parseRowsEvent(LogEventConvert.java:428)
        at com.alibaba.otter.canal.parse.inbound.mysql.dbsync.LogEventConvert.parse(LogEventConvert.java:114)
        at com.alibaba.otter.canal.parse.inbound.mysql.dbsync.LogEventConvert.parse(LogEventConvert.java:66)
        at com.alibaba.otter.canal.parse.inbound.AbstractEventParser.parseAndProfilingIfNecessary(AbstractEventParser.java:337)
        at com.alibaba.otter.canal.parse.inbound.AbstractEventParser$3$1.sink(AbstractEventParser.java:184)
        at com.alibaba.otter.canal.parse.inbound.mysql.MysqlConnection.dump(MysqlConnection.java:145)
        at com.alibaba.otter.canal.parse.inbound.AbstractEventParser$3.run(AbstractEventParser.java:220)
        at java.lang.Thread.run(Thread.java:748)
Caused by: java.io.IOException: should execute connector.connect() first
        at com.alibaba.otter.canal.parse.driver.mysql.MysqlQueryExecutor.<init>(MysqlQueryExecutor.java:30)
        at com.alibaba.otter.canal.parse.inbound.mysql.MysqlConnection.query(MysqlConnection.java:87)
        at com.alibaba.otter.canal.parse.inbound.mysql.dbsync.TableMetaCache.getTableMetaByDB(TableMetaCache.java:80)
        at com.alibaba.otter.canal.parse.inbound.mysql.dbsync.TableMetaCache.access$000(TableMetaCache.java:30)
        at com.alibaba.otter.canal.parse.inbound.mysql.dbsync.TableMetaCache$1.load(TableMetaCache.java:55)
        at com.alibaba.otter.canal.parse.inbound.mysql.dbsync.TableMetaCache$1.load(TableMetaCache.java:50)
        at com.google.common.cache.LocalCache$LoadingValueReference.loadFuture(LocalCache.java:3527)
        at com.google.common.cache.LocalCache$Segment.loadSync(LocalCache.java:2319)
        at com.google.common.cache.LocalCache$Segment.lockedGetOrLoad(LocalCache.java:2282)
        at com.google.common.cache.LocalCache$Segment.get(LocalCache.java:2197)
        at com.google.common.cache.LocalCache.get(LocalCache.java:3937)
        at com.google.common.cache.LocalCache.getOrLoad(LocalCache.java:3941)
        at com.google.common.cache.LocalCache$LocalLoadingCache.get(LocalCache.java:4824)
        at com.google.common.cache.LocalCache$LocalLoadingCache.getUnchecked(LocalCache.java:4830)
        ... 10 more
,type=nodeAlarm]]


# 华北2区主库canal ClosedByInterruptException  node/logs/1/1.log
2018-03-26 07:30:18.649 [pipelineId = 1,taskName = ProcessTermin] INFO  com.alibaba.otter.node.etl.select.SelectTask - start process termin : BatchTermin [batchId=14175, needWait=true, processId=5783680]
2018-03-26 07:30:18.687 [destination = 华北2区主库canal , address = host/ip:3306 , EventParser] INFO  c.a.o.canal.parse.inbound.mysql.dbsync.DirectLogFetcher - I/O interrupted while reading from client socket java.nio.channels.ClosedByInterruptException: null
        at com.alibaba.otter.canal.parse.driver.mysql.socket.SocketChannel.read(SocketChannel.java:49) ~[canal.parse.driver-1.0.25.jar:na]
        at com.alibaba.otter.canal.parse.inbound.mysql.dbsync.DirectLogFetcher.fetch0(DirectLogFetcher.java:151) ~[canal.parse-1.0.25.jar:na]
        at com.alibaba.otter.canal.parse.inbound.mysql.dbsync.DirectLogFetcher.fetch(DirectLogFetcher.java:69) ~[canal.parse-1.0.25.jar:na]
        at com.alibaba.otter.canal.parse.inbound.mysql.MysqlConnection.dump(MysqlConnection.java:137) [canal.parse-1.0.25.jar:na]
        at com.alibaba.otter.canal.parse.inbound.AbstractEventParser$3.run(AbstractEventParser.java:220) [canal.parse-1.0.25.jar:na]
        at java.lang.Thread.run(Thread.java:745) [na:1.8.0_111]
2018-03-26 07:30:18.687 [destination = 华北2区主库canal , address = host/ip:3306 , EventParser] ERROR c.a.otter.canal.parse.inbound.mysql.MysqlEventParser - dump address host/ip:3306 has an error, retrying. caused by java.nio.channels.ClosedByInterruptException: null

https://github.com/alibaba/otter/issues/434  ClosedByInterruptException应该是哪里发送过canal处理异常，导致binlog dump链接被关闭  
https://github.com/alibaba/canal/issues/613  
https://github.com/alibaba/canal/issues/509  canal 1.0.25和1.0.26很慢，我换到老版本1.0.24就没问题了  
```
