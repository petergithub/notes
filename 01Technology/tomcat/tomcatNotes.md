# Tomcat Notes

## Tomcat 系统架构

Tomcat要实现2个核心功能：

* 处理Socket连接，负责网络字节流与Request和Response对象的转化。
* 加载和管理Servlet，以及具体处理Request请求。

因此Tomcat设计了两个核心组件连接器（Connector）和容器（Container）来分别做这两件事情。连接器负责对外交流，容器负责内部处理。

连接器用ProtocolHandler接口来封装通信协议和I/O模型的差异，ProtocolHandler内部又分为Endpoint和Processor模块，Endpoint负责底层Socket通信，Processor负责应用层协议解析。连接器通过适配器Adapter调用容器。

### 容器的层次结构

Tomcat设计了4种容器，分别是Engine、Host、Context和Wrapper。这4种容器不是平行关系，而是父子关系

Wrapper表示一个Servlet，Context表示一个Web应用程序，一个Web应用程序中可能会有多个Servlet；Host代表的是一个虚拟主机，或者说一个站点，可以给Tomcat配置多个虚拟主机地址，而一个虚拟主机下可以部署多个Web应用程序；Engine表示引擎，用来管理多个虚拟站点，一个Service最多只能有一个Engine。

可以通过Tomcat的server.xml配置文件来加深对Tomcat容器的理解，Tomcat就是用组合模式来管理这些容器的。具体实现方法是，所有容器组件都实现了Container接口，因此组合模式可以使得用户对单容器对象和组合容器对象的使用具有一致性。这里单容器对象指的是最底层的Wrapper，组合容器对象指的是上面的Context、Host或者Engine。

```xml
<Server> //顶层组件，可以包括多个Service
    <Service> //顶层组件，可包含一个Engine，多个连接器
        <Connector> //连接器组件，代表通信接口
        </Connector>

        <Engine> //容器组件，一个Engine组件处理Service中的所有请求，包含多个Host
            <Host> //容器组件，处理特定的Host下客户请求，可包含多个Context
                <Context> //容器组件，为特定的Web应用处理所有的客户请求
                </Context>
            </Host>
        </Engine>
    <Service>
</Server>
```

## Tomcat connector (Apache Tomcat 7)

https://tomcat.apache.org/tomcat-7.0-doc/config/http.html

### acceptCount

> The maximum queue length for incoming connection requests when all possible request processing threads are in use. Any requests received when the queue is full will be refused. The default value is 100.
> 如果Tomcat的线程都忙于响应，新来的连接会进入队列排队，如果超出排队大小，则拒绝连接；

### maxConnections 最大连接数

> The maximum number of connections that the server will accept and process at any given time.
> 瞬时最大连接数，超出的会排队等待
> tomcat的最大连接数参数是maxConnections，这个值表示最多可以有多少个socket连接到tomcat上。BIO模式下默认最大连接数是它的最大线程数(缺省是200)，NIO模式下默认是10000，APR模式则是8192(windows上则是低于或等于maxConnections的1024的倍数)。如果设置为-1则表示不限制。

### maxThreads 最大线程数

> The maximum number of request processing threads to be created by this Connector
> Tomcat能启动用来处理请求的最大线程数，如果请求处理量一直远远大于最大线程数则可能会僵死。
> 如果没有对connector配置额外的线程池的话，maxThreads参数用来设置默认线程池的最大线程数。tomcat默认是200，对一般访问量的应用来说足够了。

## Servlet 规范

Filter和Listener的本质区别：

* Filter是干预过程的，它是过程的一部分，是基于过程行为的。
* Listener是基于状态的，任何行为改变同一个状态，触发的事件是一致的。

## Tomcat如何打破双亲委托机制？

JDK中有3个默认的类加载器：

* BootstrapClassLoader是启动类加载器，由C语言实现，用来加载JVM启动时所需要的核心类，比如rt.jar、resources.jar等。
* ExtClassLoader是扩展类加载器，用来加载\jre\lib\ext目录下JAR包。
* AppClassLoader是系统类加载器，用来加载classpath下的类，应用程序默认用它来加载类。
* 自定义类加载器，用来加载自定义路径下的类。

这里请你注意，类加载器的父子关系不是通过继承来实现的，比如AppClassLoader并不是ExtClassLoader的子类，而是说AppClassLoader的parent成员变量指向ExtClassLoader对象。同样的道理，如果你要自定义类加载器，不去继承AppClassLoader，而是继承ClassLoader抽象类，再重写findClass和loadClass方法即可，Tomcat就是通过自定义类加载器来实现自己的类加载逻辑。不知道你发现没有，如果你要打破双亲委托机制，就需要重写loadClass方法，因为loadClass的默认实现就是双亲委托机制。

Tomcat的自定义类加载器WebAppClassLoader打破了双亲委托机制，它首先自己尝试去加载某个类，如果找不到再代理给父类加载器，其目的是优先加载Web应用自己定义的类。而为了避免本地目录下的类覆盖JRE的核心类，先尝试用JVM扩展类加载器ExtClassLoader去加载。
