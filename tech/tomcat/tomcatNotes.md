# Tomcat Notes

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
