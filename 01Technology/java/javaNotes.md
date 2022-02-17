# Java Notes

## Recent

Jakarta (/dʒəˈkɑːrtə/

锁降级
JEP draft: Concurrent Monitor Deflation http://openjdk.java.net/jeps/8183909
不可不说的Java“锁”事 https://tech.meituan.com/2018/11/15/java-lock.html
Java偏向锁是如何撤销的？ https://www.zhihu.com/question/57774162
Java Language Specification Chapter 17. Threads and Locks https://docs.oracle.com/javase/specs/jls/se7/html/jls-17.html
Synchronization and Object Locking https://wiki.openjdk.java.net/display/HotSpot/Synchronization

`java.util.concurrent.CopyOnWriteArrayList`
`AtomicInteger`底层实现机制
SpringBoot和Swagger结合提高API开发效率  [URL](http://localhost:8080/swagger-ui.html)

[OpenJDK](https://openjdk.java.net/)

concurrent: 主内存.寄存器是是运行时?

### Concurrent vs. Parallel

并发 Concurrent 并发指能够让多个任务在逻辑上交织执行的程序设计

```shell
          --  --  --
        /              \
>---- --    --  --  -- ---->>
```

并行 Parallel 并行指物理上同时执行

```shell
     ------
    /      \
>-------------->>
```

### 常用参数

`-verbose:gc -Xloggc:/path/to/gc.pid%p.log -XX:+PrintGCDetails -XX:+PrintGCDateStamps`
`-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/path/to/hprof -XX:ErrorFile=/path/to/hs_err_pid%p.log`
-XX:+Pringflagsfinal 打印平台默认值
[HotSpot VM Command-Line Options](https://docs.oracle.com/javase/7/docs/webnotes/tsg/TSG-VM/html/clopts.html)

## Java 17

[JDK 17 Documentation](https://docs.oracle.com/en/java/javase/17/)
[JDK 17 readme](https://www.oracle.com/java/technologies/javase/jdk17-readme-downloads.html)
[JDK 17 Tool Specifications](https://docs.oracle.com/en/java/javase/17/docs/specs/man/index.html)
[JDK 17 New Feature](https://www.oracle.com/java/technologies/javase/17-relnote-issues.html#NewFeature)
[JDK 17 Books](https://docs.oracle.com/en/java/javase/17/books.html)

### Flight Recorder

[Flight Recorder API Programmer’s Guide](https://docs.oracle.com/en/java/javase/17/jfapi/creating-and-recording-your-first-event.html)
[The jfr Command](https://docs.oracle.com/en/java/javase/17/docs/specs/man/jfr.html)

## Java 8

method reference :: syntax (meaning “use this method as a value”
`File[] hiddenFiles = new File(".").listFiles(File::isHidden);`

## Java问题排查工具箱

### [Arthas](https://github.com/alibaba/arthas)

[Quick Start](https://alibaba.github.io/arthas/en/quick-start.html)
download: `wget https://alibaba.github.io/arthas/arthas-boot.jar`
startup: `java -jar arthas-boot.jar`

[watch](https://arthas.aliyun.com/doc/en/watch.html) to view the return object and parameters
`watch Demo$Counter method {params,returnObj}`
`watch com.company.EnvironmentEnum isAbroad {params,returnObj} -x 3`  more detail `-x`
`watch com.company.Service method {params,returnObj} "params[0]==1 && params[1]==new java.sql.Timestamp(1572424327000L)" -x 3`
`watch com.company.Service method "{params[0],throwExp}" -e -x 2` Check exceptions

[trace](https://alibaba.github.io/arthas/trace.html) 方法内部调用路径，并输出方法路径上的每个节点上耗时
trace Demo$Counter getFactoryInfo #cost>10 -n 1
`#cost > 10` 只会展示耗时大于10ms的调用路径
`-n` 参数指定捕捉结果的次数

`trace -E com.test.ClassA|org.test.ClassB method1|method2|method3` 用正则表匹配路径上的多个类和函数，一定程度上达到多层trace的效果

sc Demo$Counter

[Arthas的一些特殊用法文档说明 #71](https://github.com/alibaba/arthas/issues/71)

#### Demo

[阿里巴巴问题排查神器Arthas使用实践](https://mp.weixin.qq.com/s?__biz=MzI3NzE0NjcwMg==&mid=2650122813&idx=1&sn=3e419623e06cfc7900929bb6e88bcd24&chksm=f36bb71cc41c3e0a4fb7420498839af553db3073a4e02c5c67eca8d6e0f5d1f916673cb41d37&mpshare=1&scene=23&srcid=1216OroF3DROBapRZwxoMpkF#rd)

#### 原理

attach：jdk1.6新增功能，通过attach机制，可以在jvm运行中，通过pid关联应用

instrument：jdk1.5新增功能，通过instrument俗称javaagent技术，可以修改jvm加载的字节码

然后 arthas 和其他诊断工具一样，都是先通过attach链接上目标应用，通过instrument动态修改应用程序的字节码达到不重启应用而监控应用的目的

### java.net.SocketException 异常

[understanding_some_common_socketexceptions_in_java3](https://www.ibm.com/developerworks/community/blogs/738b7897-cd38-4f24-9f05-48dd69116837/entry/understanding_some_common_socketexceptions_in_java3?lang=en)
[java.net.SocketException 异常](http://developer.51cto.com/art/201003/189724.htm)

1. java.net.SocketException: Broken pipe (UNIX)
 A broken pipe error is seen when the remote end of the connection is closed gracefully.
Solution: This exception usually arises when the socket operations performed on either ends are not sync'ed.
2. java.net.SocketException: reset by peer.  This error happens on server side
3. java.net.SocketException: Connection reset. This error happens on client side
 This exception appears when the remote connection is unexpectedly and forcefully closed due to various reasons like application crash, system reboot, hard close of remote host. Kernel from the remote system sends out a packets with RST bit to the local system. The local socket on performing any SEND (could be a Keep-alive packet) or RECEIVE operations subsequently fail with this error. Certain combinations of linger settings can also result in packets with RST bit set.

### [高CPU占用分析](http://www.blogjava.net/hankchen/archive/2012/05/09/377735.html)

一个应用占用CPU很高，除了确实是计算密集型应用之外，通常原因都是出现了死循环

1. `top -H`
2. 找到具体是CPU高占用的线程 `ps -mp <PID> -o THREAD,tid,time,rss,size,%mem`
3. 将需要的线程ID转换为16进制格式 `printf "%x\n" tid`
4. 打印线程的堆栈信息 `jstack PID | grep tid -A 30`

#### checklist from linux to application process

1. `top` 看出pid为 12666 的java进程占用了较多的cpu资源
2. `top -Hp 12666` 查看该进程下各线程的CPU资源, 可以找到占资源较多的线程pid 为 12666 (12666 用 16 进制表示为 0x321e)
3. `jstack 12666 | grep nid=0x321e` 查看当前java进程的堆栈状态

### 内存检查步骤

查看java线程在内存增长时线程数 `jstack PID | grep 'java.lang.Thread.State' | wc -l` 或者 `cat /proc/pid/status | grep Thread`

用pmap查看进程内的内存 `RSS` 情况，观察java的heap和stack大小 `pmap -x pid |less`

使用gdb观察内存块里的内容，发现里面有一些接口的返回值、mc的返回值、还有一些类名等等 `gdb: dump memory /tmp/memory.bin 0x7f6b38000000 0x7f6b38000000+65535000`
`hexdump -C /tmp/memory.bin` 或 `strings /tmp/memory.bin |less`

用strace和ltrace查找malloc调用

#### Native Memory Tracking (NMT)

* java8 给HotSpot VM引入了 NMT 特性，可以用于追踪JVM的内部内存使用
* Enable NMT `-XX:NativeMemoryTracking=[off | summary | detail]`
* Use jcmd to Access NMT Data `jcmd <pid> VM.native_memory [summary | detail | baseline | summary.diff | detail.diff | shutdown] [scale= KB | MB | GB]`
* [Oracle Technology Network - Native Memory Tracking](https://docs.oracle.com/javase/8/docs/technotes/guides/vm/nmt-8.html)
* [Java Platform, Standard Edition Troubleshooting Guide - 2.7 Native Memory Tracking](https://docs.oracle.com/javase/8/docs/technotes/guides/troubleshoot/tooldescr007.html)

* 使用`-XX:NativeMemoryTracking=summary`可以用于开启NMT，其中该值默认为off，可以设置summary、detail来开启；开启的话，大概会增加5%-10%的性能消耗；使用-XX:+UnlockDiagnosticVMOptions -XX:+PrintNMTStatistics可以在jvm shutdown的时候输出整体的native memory统计；其他的可以使用`jcmd pid VM.native_memory`相关命令进行查看、diff、shutdown等
* 整个memory主要包含了Java Heap、Class、Thread、Code、GC、Compiler、Internal、Other、Symbol、Native Memory Tracking、Arena Chunk这几部分；其中reserved表示应用可用的内存大小，committed表示应用正在使用的内存大小
* [聊聊HotSpot VM的Native Memory Tracking](https://cloud.tencent.com/developer/article/1406522)

#### jemalloc 查看堆外内存 anon

[native-jvm-leaks](https://github.com/jeffgriffith/native-jvm-leaks )
[Use Case: Leak Checking](https://github.com/jemalloc/jemalloc/wiki/Use-Case:-Leak-Checking )
[Debugging Java Native Memory Leaks](http://www.evanjones.ca/java-native-leak-bug.html )
[Using jemalloc to get to the bottom of a memory leak](https://gdstechnology.blog.gov.uk/2015/12/11/using-jemalloc-to-get-to-the-bottom-of-a-memory-leak/ )

1. Starting your JVM with jemalloc `export LD_PRELOAD=/usr/local/lib/libjemalloc.so`
2. Configuring the profiler `export MALLOC_CONF=prof:true,lg_prof_interval:30,lg_prof_sample:17,prof_prefix:/path/to/jeprof/output/jeprof`
3. Run your program
4. Finding the needle `jeprof --show_bytes --gif /usr/bin/java /path/to/jeprof/output/jeprof.*.heap > out.gif`

#### gperf 查看堆外内存

[Work with Google performance tools](http://alexott.net/en/writings/prog-checking/GooglePT.html )
[perftools查看堆外内存并解决hbase内存溢出](http://koven2049.iteye.com/blog/1142768 )
[Gperftools Heap Leak Checker](https://gperftools.github.io/gperftools/heap_checker.html )

1. `export GPERF_HOME=/path/to/gperftools-2.7`
2. `export LD_PRELOAD=$GPERF_HOME/lib/libtcmalloc.so HEAPCHECK=normal`
3. `export HEAPPROFILE=/path/to/gperf/output.heap`
4. Run program `$GPERF_HOME/bin/pprof --text /usr/bin/java $HEAPPROFILE.*.heap > gperf.output.text`

#### Valgrind

[The Valgrind Quick Start Guide](http://valgrind.org/docs/manual/quick-start.html )
`valgrind ls -l >& valgrind.log`
`valgrind --leak-check=yes myprog arg1 arg2`

#### perf

[perf Examples](http://www.brendangregg.com/perf.html )
[brendangregg/perf-tools](https://github.com/brendangregg/perf-tools )

1. `perf mem record sh jni.sh 1000000 10 leak`  or attach a running process with `sudo perf record -g -p <PID>`
2. `perf mem report`

### CPU相关工具 bluedavy

[Java问题排查工具箱](https://mp.weixin.qq.com/s?__biz=MjM5MzYzMzkyMQ==&mid=2649826312&idx=1&sn=d28b3c91ef25a281256c6ccd2fafe0d3&mpshare=1&scene=23&srcid=1031nCrOjtP6QtlUYAL6QWso#rd )

碰到一些CPU相关的问题时，通常需要用到的工具：

`top (-H)` top可以实时的观察cpu的指标状况，尤其是每个core的指标状况，可以更有效的来帮助解决问题，-H则有助于看是什么线程造成的CPU消耗，这对解决一些简单的耗CPU的问题会有很大帮助。

`sar` sar有助于查看历史指标数据，除了CPU外，其他内存，磁盘，网络等等各种指标都可以查看，毕竟大部分时候问题都发生在过去，所以翻历史记录非常重要。

`jstack` jstack可以用来查看Java进程里的线程都在干什么，这通常对于应用没反应，非常慢等等场景都有不小的帮助，jstack默认只能看到Java栈，而jstack -m则可以看到线程的Java栈和native栈，但如果Java方法被编译过，则看不到（然而大部分经常访问的Java方法其实都被编译过）。

`pstack` pstack可以用来看Java进程的native栈。

`perf` 一些简单的CPU消耗的问题靠着 `top -H` + `jstack` 通常能解决，复杂的话就需要借助perf这种超级利器了。

`cat /proc/interrupts` 之所以提这个是因为对于分布式应用而言，频繁的网络访问造成的网络中断处理消耗也是一个关键，而这个时候网卡的多队列以及均衡就非常重要了，所以如果观察到cpu的si指标不低，那么看看interrupts就有必要了。

### 内存相关工具 bluedavy

碰到一些内存相关的问题时，通常需要用到的工具：

`jstat` `jstat -gcutil`或`-gc`等等有助于实时看gc的状况，不过我还是比较习惯看gc log。

`jmap` 在需要dump内存看看内存里都是什么的时候，`jmap -dump`可以帮助你；在需要强制执行fgc的时候（在CMS GC这种一定会产生碎片化的GC中，总是会找到这样的理由的），`jmap -histo:live`可以帮助你（显然，不要随便执行）。

`gcore` 相比`jmap -dump`，其实我更喜欢gcore，因为感觉就是更快，不过由于某些jdk版本貌似和gcore配合的不是那么好，所以那种时候还是要用jmap -dump的。

`mat` 有了内存dump后，没有分析工具的话然并卵

`btrace` 少数的问题可以mat后直接看出，而多数会需要再用btrace去动态跟踪，btrace绝对是Java中的超级神器，举个简单例子，如果要你去查下一个运行的Java应用，哪里在创建一个数组大小>1000的ArrayList，你要怎么办呢，在有btrace的情况下，那就是秒秒钟搞定的事，:)

`gperf` Java堆内的内存消耗用上面的一些工具基本能搞定，但堆外就悲催了，目前看起来还是只有gperf还算是比较好用的一个，或者从经验上来说Direct ByteBuffer、Deflater/Inflater这些是常见问题。

除了上面的工具外，同样内存信息的记录也非常重要，就如日志一样，所以像GC日志是一定要打开的，确保在出问题后可以翻查GC日志来对照是否GC有问题，所以像 `-XX:+PrintGCDetails -XX:+PrintGCDateStamps -Xloggc:<gc log file>` 这样的参数必须是启动参数的标配。

#### Eclipse Memory Analyzer Tool (mat)

**Dominate**: An object x dominates an object y if every path in the object graph from the start (or the root) node to y must go through x.

**Dominator Tree** : A dominator tree is built out of the object graph. In the dominator tree each object is the immediate dominator of its children, so dependencies between the objects are easily identified.

**Shallow heap** is the memory consumed by one object.

**Retained set** of X is the set of objects which would be removed by GC when X is garbage collected.

**Retained heap** of X is the sum of shallow sizes of all objects in the retained set of X, i.e. memory kept alive by X.

### jvm log 时间格式

打印绝对时间 `-XX:+PrintGCDetails -XX:+PrintGCDateStamps`
打印相对时间 `-XX:+PrintGCDetails -XX:+PrintGCTimeStamps`
`-Xloggc` 需要使用绝对路径
`-verbose:gc -Xloggc:/path/to/gc.pid%p.log -XX:+PrintGCDetails -XX:+PrintGCDateStamps`
`-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/path/to/hprof -XX:ErrorFile=/path/to/hs_err_pid%p.log`
[Fatal Error Log](http://www.oracle.com/technetwork/java/javase/felog-138657.html#gbwcy)

### ClassLoader相关工具

作为Java程序员，不碰到ClassLoader问题那基本是不可能的，在排查此类问题时，最好办的还是`-XX:+TraceClassLoading`，或者如果知道是什么类的话，我的建议就是把所有会装载的lib目录里的jar用`jar -tvf *.jar`这样的方式来直接查看冲突的class，再不行的话就要呼唤btrace神器去跟踪Classloader.defineClass之类的了。

### 其他工具

`jinfo` Java有N多的启动参数，N多的默认值，而任何文档都不一定准确，只有用jinfo -flags看到的才靠谱，甚至你还可以看看jinfo -flag，你会发现更好玩的。

`dmesg` 你的java进程突然不见了？ 也许可以试试dmesg先看看。

`systemtap` 有些问题排查到java层面是不够的，当需要trace更底层的os层面的函数调用的时候，systemtap神器就可以派上用场了。

`gdb` 更高级的玩家们，拿着core dump可以用gdb来排查更诡异的一些问题。

## Java Mermory check

### 虚拟机监控工具

[Troubleshooting Guide for Java SE 6 with HotSpot VM](http://www.oracle.com/technetwork/java/javase/memleaks-137499.html#gdysp)

* jps: 虚拟机进程状况工具  (Java Virtual Machine Process Status Tool)
* jstat: 虚拟机统计信息工具  (Java Virtual Machine Statistics Monitoring Tool)
* jinfo: Java配置信息工具
* jmap: Java内存映像工具  (Memory Map)
* jhat: 虚拟机堆转储快照分析工具  (Java Heap Analysis Tool)
* jstack: Java堆栈跟踪工具  (Stack Trace)
* HSDIS: JIT生成代码反汇编
* [jcmd](https://docs.oracle.com/en/java/javase/11/tools/jcmd.html) send diagnostic command requests to a running Java Virtual Machine (JVM)
* [jhsdb](https://docs.oracle.com/en/java/javase/11/tools/jhsdb.html): You use the jhsdb tool to attach to a Java process or to a core dump from a crashed Java Virtual Machine (JVM).

HSDB: `java -cp sa-jdi.jar sun.jvm.hotspot.HSDB`

[Serviceability in HotSpot](http://openjdk.java.net/groups/hotspot/docs/Serviceability.html)

#### jmap

排查GC问题必然会用到的工具，jmap可以告诉你当前JVM内存堆中的对象分布及其关系，当你dump堆之后可以用内存分析工具, 例如：Eclipse Memory Analyzer Tool（MAT）、VisualVM、jhat、jprofile等工具查看分析，看看有哪些大对象，或者哪些类的实例特别多。

常用用法：
强制FGC：-histo:live
dump堆：-dump:[live],format=b,file=dump.bin
`$(ps -ef | grep applicationName | grep -v grep | awk '{print $2}')` 获取pid

查看各代内存占用情况：

* `jmap -heap [pid]`
* `jmap [pid]`
* `jmap -dump:format=b,file=/tmp/java_pid.hprof [pid]` 可以将当前Java进程的内存占用情况导出来
* `jmap -dump:live,format=b,file=/tmp/java_pid.hprof [pid]` 可以将当前Java进程存活对象在内存中占用情况导出来, `:live` 会触发一次Full GC
* `jmap -histo:live [pid] >a.log` 查看当前Java进程创建的活跃对象数目和占用内存大小
* `jmap -histo $(ps -ef | grep applicationName | grep -v grep | awk '{print $2}') | head -20` top 20 内存占用

浅堆（Shallow Heap）: 对象的浅堆指它在内存中的大小
保留堆（Retained Heap）: 指当特定对象被垃圾回收后即将释放的内存大小, 因为 保留堆=内存中的大小 + 持有对象的引用大小

#### jcmd

在JDK 1.7之后，新增了一个命令行工具jcmd。它是一个多功能工具，可以用来导出堆，查看java进程，导出线程信息，执行GC等。
jcmd拥有jmap的大部分功能，Oracle官方建议使用jcmd代替jmap

[The jcmd Command](https://docs.oracle.com/en/java/javase/13/docs/specs/man/jcmd.html)

```sh
# jcmd pid help 列出该虚拟机支持的所有命令

jcmd 8799 help
8799:
The following commands are available:
JFR.stop
JFR.start
JFR.dump
JFR.check
VM.native_memory
VM.check_commercial_features
VM.unlock_commercial_features
ManagementAgent.stop
ManagementAgent.start_local
ManagementAgent.start
GC.rotate_log
Thread.print
GC.class_stats
GC.class_histogram
GC.heap_dump
GC.run_finalization
GC.run
VM.uptime
VM.flags
VM.system_properties
VM.command_line
VM.version
help

For more information about a specific command use 'help <command>'.
```

#### jhsdb

[jhsdb](https://docs.oracle.com/en/java/javase/11/tools/jhsdb.html)

JCMD、JHSDB和基础工具的对比

| 基础工具               |   JCMD                            |   JHSDB   |
|     ---               | ---                               | ---       |
| `jps -lm`               | jcmd                                | N/A |
| `jmap -dump <pid>`      | `jcmd <pid> GC.heap_dump`          | jhsdb jmap --binaryheap |
| `jmap-histo <pid>`      | `jcmd <pid> GC.class_histogram`    | jhsdb jmap --histo |
| `jstack <pid>`          | `jcmd <pid> Thread.print`           | jhsdb jstack --locks |
| `jinfo -sysprops <pid>` | `jcmd <pid> VM.system_properties`  | jhsdb info --sysprops |
| `jinfo -flags <pid>`    | `jcmd <pid> VM.flags`               | jhsdb info --flags |

#### jstack

jstack 可以告诉你当前所有JVM线程正在做什么，包括用户线程和虚拟机线程，你可以用它来查看线程栈，并且结合Lock信息来检测是否发生了死锁和死锁的线程。
另外在用top -H看到占用CPU非常高的pid时，可以转换成16进制后在jstack dump出来的文件中搜索，看看到底是什么线程占用了CPU。

#### jhat

`jhat -port 8080 /tmp/java_11211.hprof` 服务启动后，访问 [localhost](http://localhost:8080/)

#### jstat

可以告诉你当前的GC情况，包括GC次数、时间，具体的GC还可以结合gc.log文件去分析。
`jstat -gc pid 250 10`
`jstat -gcutil`
根据JVM的内存布局

* 堆内存 = 年轻代 + 年老代 + 永久代
* 年轻代 = Eden区 + 两个Survivor区（From和To）

以上统计数据各列的含义为
    S0C、S1C、S0U、S1U：Survivor 0/1区容量（Capacity）和使用量（Used）
    EC、EU：Eden区容量和使用量
    OC、OU：年老代容量和使用量
    PC、PU：永久代容量和使用量
    YGC、YGT：年轻代GC次数和GC耗时
    FGC、FGCT：Full GC次数和Full GC耗时
    GCT：GC总耗时

#### jVisualVM

[VisualVM CPU Sampling](http://greyfocus.com/2016/05/visualvm-sampling/)

##### Sampling

Sampling on the other side works by periodically retrieving thread dumps from the JVM. In this case, the performance impact is minor (and constant since the thread dumps are retrieved using a fixed frequency) and there’s no risk of introducing side effects. This process is a lot less intrusive and can also be performed quite reliably on remote applications (i.e. it could even be applied to production instances).

##### Profiling

Profiling involves instrumenting the entire application code or only some classes in order to provide runtime performance metrics to the profiler application. Since this involves changes to the application code, which are applied automatically by the profiler, it also means that there is a certain performance impact and risk of affecting the existing functionality.

##### Difference between “Self Time” and “Self Time (CPU)”

VisualVM reports two metrics related to the duration, but there is a significant difference between them:

* self time - counts the total time spent in that method, including the amount of time spent on locks or other blocking behaviour
* self time (cpu) - counts the total time spent in that method, excluding the amount of time the thread was blocked

#### [Interpretation of FieldType characters](http://docs.oracle.com/javase/specs/jvms/se7/html/jvms-4.html#jvms-4.3)

[Z = boolean
[B = byte
[S = short
[I = int
[J = long
[F = float
[D = double
[C = char
[L = any non-primitives(Object)

### JVM内存分配

在Java虚拟机中，内存分为三个代：新生代（New）、老生代（Old）、永久代（Perm）。
（1）新生代New：新建的对象都存放这里
（2）老生代Old：存放从新生代New中迁移过来的生命周期较久的对象。新生代New和老生代Old共同组成了堆内存。
（3）永久代Perm：是非堆内存的组成部分。主要存放加载的Class类级对象如class本身，method，field等等。

* 堆内存 = 年轻代 + 年老代 + 永久代
* 年轻代 = Eden区 + 两个Survivor区（From和To）

如果出现java.lang.OutOfMemoryError: Java heap space异常，说明Java虚拟机的堆内存不够。原因有二：
（1）Java虚拟机的堆内存设置不够，可以通过参数-Xms1g、-Xmx2g来调整。
（2）代码中创建了大量大对象，并且长时间不能被垃圾收集器收集（存在被引用）。

如果出现java.lang.OutOfMemoryError: PermGen space，说明是Java虚拟机对永久代Perm内存设置不够。
一般出现这种情况，都是程序启动需要加载大量的第三方jar包。例如：在一个Tomcat下部署了太多的应用。

从代码的角度，软件开发人员主要关注java.lang.OutOfMemoryError: Java heap space异常，减少不必要的对象创建，同时避免内存泄漏。

#### Guidelines for Calculating Java Heap Sizing

Refer to Java Performance

##### Table 7-3 Guidelines for Calculating Java Heap Sizing

Space                     | Command Line Option             | Occupancy Factor
----                      |---                              |---
Java heap                 | -Xms and -Xmx                   | 3x to 4x old generation space occupancy after full garbage collection
Permanent Generation      | -XX:PermSize -XX:MaxPermSize    | 1.2x to 1.5x permanent generation space occupancy after full garbage collection
Young Generation          | -Xmn 1x to 1.5x                 | old generation space occupancy after full garbage collection
Old Generation            | Implied from overall Java heap size minus the young generation size | 2x to 3x old generation space occupancy after full garbage collection

##### Refine Young Generation Size

* The old generation space size should be not be much smaller than 1.5x the live data size
* Young generation space size should be at least 10% of the Java heap size, the value specified as -Xmx and -Xms.
* When increasing the Java heap size, be careful not to exceed the amount of physical memory available to the JVM

### Other tools

#### [GCViewer](https://github.com/chewiebug/GCViewer)

GCViewer is a little tool that visualizes verbose GC output generated by Sun / Oracle, IBM, HP and BEA Java Virtual Machines.

#### [greys-anatomy](https://github.com/oldmanpushcart/greys-anatomy/wiki)

Greys是一个JVM进程执行过程中的异常诊断工具，可以在不中断程序执行的情况下轻松完成问题排查工作。

#### HouseMD

一个类似于BTrace的工具，用于对JVM运行时的状态进行追踪和诊断，作者是中间件团队的聚石。

通常我们排查问题很多时候都在代码中加个日志，看看方法的参数、返回值是不是我们期望的，然后编译打包部署重启应用，十几分钟就过去了。HouseMD可以直接让你可以追踪到方法的返回值和参数，以及调用次数、调用平均rt、调用栈。甚至是类的成员变量的值、Class加载的路径、对应的ClassLoader，都可以用一行命令给你展现出来，堪称神器。

更多的用法可以参考详细的[WiKi](https://github.com/CSUG/HouseMD)

再偷偷告诉你，因为HouseMD是基于字节码分析来做的，所以理论上运行在JVM的语言都可以用它，包括Groovy，Clojure都可以。

## JVM

### ZGC - JDK 11

[Z Garbage Collector](https://wiki.openjdk.java.net/display/zgc/Main)

[新一代垃圾回收器ZGC的探索与实践 - 美团技术团队](https://tech.meituan.com/2020/08/06/new-zgc-practice-in-meituan.html)

goals

* Pause times do not exceed 10ms
* Pause times do not increase with the heap or live-set size
* Handle heaps ranging from a few hundred megabytes to multi terabytes in size

At a glance, ZGC is:

* Concurrent
* Region-based
* Compacting
* NUMA-aware
* Using colored pointers
* Using load barriers

江南白衣本衣 春天的旁边 [Java程序员的荣光，听R大论JDK11的ZGC](https://mp.weixin.qq.com/s/KUCs_BJUNfMMCO1T3_WAjw)
> R大: 与标记对象的传统算法相比，ZGC在指针上做标记，在访问指针时加入Load Barrier（读屏障），比如当对象正被GC移动，指针上的颜色就会不对，这个屏障就会先把指针更新为有效地址再返回，也就是，永远只有单个对象读取时有概率被减速，而不存在为了保持应用与GC一致而粗暴整体的Stop The World。

ZGC的八大特征

1. 所有阶段几乎都是并发执行的
 这里的并发(Concurrent)，说的是应用线程与GC线程齐头并进，互不添堵。
说几乎，就是还有三个非常短暂的STW的阶段，所以ZGC并不是Zero Pause GC啦
2. 并发执行的保证机制，就是Colored Pointer 和 Load Barrier
 Colored Pointer 从64位的指针中，借了几位出来表示Finalizable、Remapped、Marked1、Marked0。 所以它不支持32位指针也不支持压缩指针， 且堆的上限是4TB
3. 像G1一样划分Region，但更加灵活
4. 和G1一样会做Compacting－压缩
 粗略了几十倍地过一波回收流程，小阶段都被略过了哈:
 4.1. Pause Mark Start －初始停顿标记
 4.2. Concurrent Mark －并发标记
 4.3. Relocate － 移动对象
 4.4. Remap － 修正指针
 上一个阶段的Remap，和下一个阶段的Mark是混搭在一起完成的，这样非常高效，省却了重复遍历对象图的开销。
5. 没有G1占内存的Remember Set，没有Write Barrier的开销
6. 支持Numa架构
 现在多CPU插槽的服务器都是Numa架构
7. 并行
8. 单代
 没分代，应该是ZGC唯一的弱点了. 所以R大说ZGC的水平，处于AZul早期的PauselessGC  与 分代的C4算法之间 － C4在代码里就叫GPGC，Generational Pauseless GC。
 分代原本是因为most object die young的假设，而让新生代和老生代使用不同的GC算法。但C4已经是全程并发算法了，为什么还要分代呢？
 R大说：因为分代的C4能承受的对象分配速度(Allocation Rate)， 大概是原始PGC的10倍。

## Java™ Tutorials

[Java Documentation](http://docs.oracle.com/javase/tutorial/essential/concurrency/index.html)

### Pausing Execution with `sleep`

`Thread.sleep` causes the current thread to suspend execution for a specified period

### Interrupts

An interrupt is an indication to a thread that it should stop what it is doing and do something else

线程的thread.interrupt()方法是中断线程，将会设置该线程的中断状态位，即设置为true，中断的结果线程是死亡、还是等待新的任务或是继续运行至下一步，就取决于这个程序本身。

线程会不时地检测这个中断标示位，以判断线程是否应该被中断（中断标示值是否为true）。

#### 判断线程是否被中断

使用`Thread.currentThread().isInterrupted()`方法：因为它将线程中断标示位设置为true后，不会立刻清除中断标示位，即不会将中断标设置为false），

不要使用`thread.interrupted()`：该方法调用后会将中断标示位清除，即重新设置为false

#### 底层中断异常处理方式

不要在你的底层代码里捕获`InterruptedException`异常后不处理，会处理不当。如果你不知道抛`InterruptedException`异常后如何处理，那么你有如下好的建议处理方式：

1、在catch子句中，调用`Thread.currentThread.interrupt()`来设置中断状态（因为抛出异常后中断标示会被清除），让外界通过判断`Thread.currentThread().isInterrupted()`标示来决定是否终止线程还是继续下去，应该这样做：

```java
try {
        sleep(delay);
} catch (InterruptedException e) {
    Thread.currentThread().isInterrupted();
}
```

2、或者，更好的做法就是，不使用try来捕获这样的异常

### Joins

The join method allows one thread to wait for the completion of another. If `t` is a `Thread` object whose thread is currently executing, `t.join();` causes the current thread to pause execution until t's thread terminates.

### `wait`

Always invoke wait inside a loop that tests for the condition being waited for. Don't assume that the interrupt was for the particular condition you were waiting for, or that the condition is still true.

Item 50 "Never invoke wait outside a loop" in Joshua Bloch's "Effective Java Programming Language Guide" (Addison-Wesley, 2001).

该方法属于Object的方法，wait方法的作用是**使当前调用wait方法所在部分(代码块)的线程**停止执行，并释放当前获得的调用wait所在的代码块的锁，并在其他线程调用notify或者notifyAll方法时恢复到竞争锁状态(一旦获得锁就恢复执行).

### Concurrent Collections

`BlockingQueue`, `ConcurrentMap`, `ConcurrentHashMap`, `ConcurrentNavigableMap`, `ConcurrentSkipListMap`

### Atomic Variables

`AtomicInteger`

## [理解Java中的四种引用](http://www.importnew.com/17019.html)

Java中实际上有四种强度不同的引用，从强到弱它们分别是，强引用，软引用，弱引用和虚引用

### 强引用(Strong Reference)

就是我们经常使用的引用，其写法如下 `StringBuffer buffer = new StringBuffer();`

### 软引用（Soft Reference）

当内存不足时垃圾回收器才会回收这些软引用可到达的对象。

### 弱引用(Weak Reference)

弱引用简单来说就是将对象留在内存的能力不是那么强的引用。使用WeakReference，垃圾回收器会帮你来决定引用的对象何时回收并且将对象从内存移除。创建弱引用如下
`WeakReference<Widget> weakWidget = new WeakReference<Widget>(widget)`

### 虚引用 （Phantom Reference）

我们不可以通过get方法来得到其指向的对象。它的唯一作用就是当其指向的对象被回收之后，自己被加入到引用队列，用作记录该引用指向的对象已被销毁。

虚引用使用场景主要由两个。它允许你知道具体何时其引用的对象从内存中移除。而实际上这是Java中唯一的方式。这一点尤其表现在处理类似图片的大文件的情况。当你确定一个图片数据对象应该被回收，你可以利用虚引用来判断这个对象回收之后在继续加载下一张图片。这样可以尽可能地避免可怕的内存溢出错误。

第二点，虚引用可以避免很多析构时的问题。finalize方法可以通过创建强引用指向快被销毁的对象来让这些对象重新复活。

## JVM 致命错误日志（hs_err_pid.log）解读

[JVM 致命错误日志（hs_err_pid.log）解读](https://www.raychase.net/1459) Posted on 06/27/2013 by 四火

致命错误出现的时候，JVM 生成了 `hs_err_pid<pid>.log` 这样的文件，其中往往包含了虚拟机崩溃原因的重要信息。

默认情况下文件是创建在工作目录下的（如果没权限创建的话 JVM 会尝试把文件写到/tmp 这样的临时目录下面去），当然，文件格式和路径也可以通过参数指定，比如：`java -XX:ErrorFile=/var/log/java/java_error%p.log`

这个文件将包括：

* 触发致命错误的操作异常或者信号；
* 版本和配置信息；
* 触发致命异常的线程详细信息和线程栈；
* 当前运行的线程列表和它们的状态；
* 堆的总括信息；
* 加载的本地库；
* 命令行参数；
* 环境变量；
* 操作系统 CPU 的详细信息。

首先，看到的是对问题的概要介绍：

```shell
#  SIGSEGV (0xb) at pc=0x03568cf4, pid=16819, tid=3073346448
```

一个非预期的错误被 JRE 检测到，其中：

* SIGSEGV 是信号名称
* 0xb 是信号码
* pc=0x03568cf4 指的是程序计数器的值
* pid=16819 是进程号
* tid=3073346448 是线程号

如果你对 JVM 有了解，应该不会对这些东西陌生。

接下来是 JRE 和 JVM 的版本信息：

```shell
# JRE version: 6.0_32-b05

# Java VM: Java HotSpot(TM) Server VM (20.7-b02 mixed mode linux-x86 )
```

运行在 mixed 模式下。

然后是问题帧的信息：

```shell
# Problematic frame:

# C  [libgtk-x11-2.0.so.0+0x19fcf4]  __float128+0x19fcf4
```

* C：帧类型为本地帧，帧的类型包括：
* C：本地 C 帧
* j：解释的 Java 帧
* V：虚拟机帧
* v：虚拟机生成的存根栈帧
* J：其他帧类型，包括编译后的 Java 帧

`libgtk-x11-2.0.so.0+0x19fcf4`：和程序计数器（pc）表达的含义一样，但是用的是本地 so 库+偏移量的方式。
