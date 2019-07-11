# Request id 分布式系统追踪请求

## nginx + spring

### nginx access log

在1.11.x之后，nginx就提供了内置的$request_id参数，此参数用于标记每个请求，全局唯一，为16字节的字符串（随机，16进制）

``` nginx
## http
log_format  trace_main_post  main_post '$remote_addr - $remote_user [$time_local] "$request" "$request_body" '
                '$status $body_bytes_sent "$http_referer" '
                '"$http_user_agent" $http_x_forwarded_for $request_time' $request_id;  
proxy_set_header X-Request-ID $request_id;  

```

在1.11.x的以前版本需要通过使用nginx现有的内置变量互相拼接才行，主要目的就是尽可能避免$request_trace_id值的重复性。
`set      $request_trace_id trace-id-$pid-$connection-$bytes_sent-$msec;`

1. $pid：nginx worker进程号
2. $connection：与upstream server链接id数。
3. $bytes_sent：发送字节数。
4. $msec：当前时间，即此变量获取的时间，包含秒、毫秒数（中间以.分割）

### tomcat access log

在tomcat conf目录下的server.xml文件中增加（调整）如下配置, pattern属性为access log 的格式

``` xml
<Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs"  
                   prefix="localhost_access_log" suffix=".txt"  
                   pattern="%h %m %t %D %F %r %s %S %b %{X-Request-ID}i %{Referer}i %{User-Agent} %{begin:msec}t %{end:msec}t" /> 
```

### 业务日志

日志组件为logback + sl4j

#### java

1. Filter 实现

``` java
    public static final String REQUEST_ID_KEY = "X-Request-ID";
    public static ThreadLocal<String> requestIdThreadLocal = new ThreadLocal<String>();
    private static final Logger logger = LoggerFactory.getLogger(RequestIdUtil.class);

    public static String getRequestId(HttpServletRequest request) {
        String requestId = null;
        String parameterRequestId = request.getParameter(REQUEST_ID_KEY);
        String headerRequestId = request.getHeader(REQUEST_ID_KEY);
        if ( parameterRequestId == null & amp;&amp;
        headerRequestId == null){
            logger.info("request parameter 和header 都没有requestId入参");
            requestId = UUID.randomUUID().toString();
        } else{
            requestId = parameterRequestId != null ? parameterRequestId : headerRequestId;
        }
        requestIdThreadLocal.set(requestId);
        return requestId;
    }


    //requestId结合日志打印，这里使用slf4j标准里的MDC实现
    MDC.put("requestId", requestId);

    //使用HTTP Client 把 requestId 放在请求 header，上面的切面一开始会判断requestId是否在请求里面，这样子在被调用的系统也能追踪到属于同一个调用链的日志了

```

#### logback

``` xml
    <encoder class="ch.qos.logback.classic.encoder.PatternLayoutEncoder">  
        <pattern>%d{yyyy-MM-dd/HH:mm:ss.SSS} %X{localIp} %X{requestId} [%t] %-5level %logger{50} %line - %m%n</pattern>  
    </encoder>  
```

### 参考

[使用requestId在分布式系统追踪请求](https://www.jianshu.com/p/705b8bbcfc32)
[nginx + tomcat实现请求链跟踪](http://shift-alt-ctrl.iteye.com/blog/2331455)
[nginx/tomcat日志格式规范](http://shift-alt-ctrl.iteye.com/blog/2352715)
[Nginx Unique Tracing ID](https://www.jianshu.com/p/5e103e1eb017)