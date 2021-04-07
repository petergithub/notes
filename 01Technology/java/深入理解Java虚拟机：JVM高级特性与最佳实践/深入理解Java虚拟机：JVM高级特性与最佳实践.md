# 深入理解Java虚拟机：JVM高级特性与最佳实践

周志明

## 问题

1. 内核态和用户态切换的成本是多少，衡量方式
2. 轻量级锁解锁时，通过 CAS 判断 Mark Word 中的栈指针，什么时候会失败？其他锁竞争？

## 第1章　走近Java

### 1.4　Java虚拟机发展史

Dalvik VM并不是一个Java虚拟机，它没有遵循Java虚拟机规范，不能直接执行Java的Class文件，使用的是寄存器架构而不是JVM中常见的栈架构。

> 8.5.2 基于栈的指令集与基于寄存器的指令集
> 基于栈的指令集（Instruction Set Architecture，ISA）：字节码指令流里面的指令大部分都是零地址指令，它们依赖操作数栈进行工作。
> 基于寄存器的指令集：最典型的就是x86的二地址指令集，二地址指令是x86指令集中的主流，每个指令都包含两个单独的输入参数，依赖于寄存器来访问和存储数据。
如果说得更通俗一些就是现在我们主流PC机中物理硬件直接支持的指令集架构，这些指令依赖寄存器进行工作。

## 自动内存管理

### 内存区域分析

运行时数据区分两部分  

1. 线程共享: 方法区(Method Area)，堆(Heap)  
2. 线程隔离: 虚拟机栈(JVM Stack)，本地方法栈(Native Method Stack)，程序计数器(Program Counter Register)

线程    |     名字         | 作用
--- |    ---         | ---
共享    |    Java堆        |    存放对象实例
共享    |    方法区        |    存储被虚拟机加载的类信息，常量，静态变量，运行时常量池（Runtime Constant Pool）等。
隔离    |    程序计数器    |    当前线程所执行的字节码行号指示器，线程切换时可以快速切换位置
隔离    |    虚拟机栈        |    创建栈桢用于存储局部变量表，操作数栈，动态链接，方法出口等信息。局部变量表
隔离    |    本地方法栈    |    同虚拟机栈
隔离    |    直接内存    |    Native函数库直接分配的堆外内存

程序计数器存储两种: 1. Java方法，则保存虚拟机字节码指令地址； 2. Native方法，为空(Undefined)
直接内存（Direct M emory）：Native函数库直接分配的堆外内存，然后通过一个存储在Java堆里面的DirectByteBuffer对象作为这块内存的引用进行操作

随着即时编译技术的进步，尤其是逃逸分析技术的日渐强大，栈上分配、标量替换优化手段，**Java对象实例都分配在堆上也渐渐变得不是那么绝对了**。

#### 分区

##### 2.5.5 方法区 Method Area，永生代

与Java堆一样，是各线程共享的内存区域，虽然Java虚拟机堆规范把方法区描述为堆的一个逻辑部分，但是它别名叫做Non-Heap(非堆)，目的应该是与Java堆区分开。在使用HotSpot时，很多人把方法区称为"永生代"，本质上两者并不等价，仅仅是因为HotSpot虚拟机的设计团队把GC分代收集扩展至方法区，或者说使用永久代来实现方法区

在JDK8之前的HotSpot虚拟机中，类的"永久的"数据存放在永久代，通过`‑XX:MaxPermSize` 设置永久代的大小。它的垃圾回收和老年代的垃圾回收是绑定的，一旦其中一个被占满，则两个都要进行回收。但一旦元数据(类的层级信息，方法数据，方法信息如字节码，栈和变量大小，运行时常量池，已确定的符号引用和虚方法表)超过了永久代的大小，程序就会出现内存溢出OOM。

**JDK8移除了永生代**，类的元数据保存到了一个与堆不相连的本地内存区域--**元空间**，它的最大可分配空间就是系统可用的内存空间。 
元空间的内存管理: 每一个类加载器的存储区域都称作一个元空间，所有的元空间合在一起。当一个类加载器不再存活，其对应的元空间就会被回收。

#### 2.3 HotSpot虚拟机

##### 2.3.1　对象的创建

1. **指针碰撞 Bump the Pointer**:已使用的内存放一边，空闲的放另一边，建立新对象分配内存仅仅是把指针向空闲空间那边挪动一段与对象大小相等的距离
2. **空闲列表 Free List**: 已使用和空闲的内存相互交错，虚拟机必须维护一个列表，记录可用内存块，建立新对象分配内存时要从列表中找到一块足够大的空间划分给对象实例，并更新列表上的记录。

**分配空间的并发问题**:并发情况下，可能出现正在给对象A分配内存，指针还没来得及修改，对象B又同时使用了原来的指针来分配内存的情况。解决这个问题有两种方案:  
一种是对分配内存空间的动作进行同步处理--实际上虚拟机采用CAS配上失败重试的方式保证更新操作的原子性；  
另一种是把内存分配的动作按线程划分在不同的空间中进行，即每个线程在Java堆中预先分配一小块内存，称为本地线程分配缓冲(Thread Local Allocation Buffer，TLAB)。

##### 2.3.2　对象内存布局

在HotSpot虚拟机中，对象在内存中存储的布局分３块区域:对象头(Header)，实例数据(Instance Data)和对齐填充(Padding)  
对象头包括两部分

1. 存储对象自身的运行时数据，如HashCode，GC分代年龄，锁状态标志，线程持有的锁，偏向线程ID，偏向时间戳等。官方称为 Mark Word  
2. 类型指针，即对象指向它的类元数据的指针，虚拟机通过它来确定这个对象是哪个类的实例。

##### 2.3.3　对象访问定位

1. 使用句柄: Java堆中会划分出一块内存作为句柄池  
栈中的reference存储对象句柄地址，句柄包含对象实例数据与类型数据地址信息  
优点:在对象移动(垃圾回收)时，只会改变句柄中实例数据指针，而reference本身不需修改  
2. 使用直接指针访问:　reference存储的就是对象地址。HotSpot使用此种方式  
优点:访问速度快，节省一次指针定位的时间开销  

## 第3章 垃圾收集器与内存分配策略

* 哪些内存需要回收?
* 什么时候回收?
* 如何回收?

### 3.2 判断对象是否在使用

#### 3.2.1 引用计数算法 Reference Counting

优点:简单  
缺点:难以解决循环引用

#### 3.2.2 可达性分析算法 Reachability Analysis

可作为GC Roots的对象包括:

* 虚拟机栈(栈桢中的本地变量表)中引用的对象
* 方法区中类静态属性引用的对象
* 方法区中常量引用的对象
* 本地方法中JNI(即一般说的Native方法)引用的对象

### 3.3 垃圾收集算法

#### 3.3.1 标记-清除算法 Mark-Sweep

首先标记出需要回收的对象，标记完成后统一回收所有被标记的对象。它是最基础的收集算法。

缺点:  

1. 效率问题:标记和清除两个过程效率都不高；
2. 空间问题:会产生大量不连续的内存碎片，导致最后无法找到足够的连续内存而不得不提前触发另一次垃圾收集动作。

#### 3.3.2 复制算法 Copying

将内存分为大小相等两块，每次只使用一块。当一块用完了，就将活着的对象复制到另外一块上，然后把已使用过的内存空间一次清理掉。 
现代商业虚拟机都采用这种算法:将内存分为一块较大的Eden空间，两块较小的Survivor空间，每次使用Eden和其中一块Survivor

优点:实现简单，运行高效  
缺点:内存缩小了一半

#### 3.3.3 标记整理算法 Mark-Compact

根据老年代特点，提出此算法，标记过程与"标记-清除"算法一样，但后续步骤不是直接清理，而是让所有存活对象都向一端移动，然后直接清理掉边界以外的内存

#### 3.3.4 分代收集 Generational Collection

根据对象存活周期不同，将内存分为几块:新生代和老年代，这样就根据各个年代特点采用最适当的收集算法。
在新生代使用复制算法，只需付出少量存活对象的复制成本就可以完成收集。
老年代中因为对象存活率高，没有额外空间对它进行分配担保，就必须使用"标记-清理"或者"标记-整理"算法

### 3.5 垃圾收集器

**Young generation**: Serial，ParNew，Parallel Scavenge，G1(Garbage First)  
**Tenured generation**: CMS(Concurrent Mark Sweep)，Serial Old(MSC)，Parallel Old，G1(Garbage First)

![HostSpot垃圾回收器](image/HostSpot垃圾回收器。png "HostSpot垃圾回收器")

algorithm combinations cheat sheet

Young               |    Tenured     |    JVM options
---                 |    ---         |        ---
Incremental         |    Incremental |    -Xincgc
Serial              |    Serial      |    -XX:+UseSerialGC
Parallel Scavenge   |    Serial      |    -XX:+UseParallelGC -XX:-UseParallelOldGC
Parallel New        |    Serial      |    N/A
Serial              |    Parallel Old|     N/A
Parallel Scavenge   |    Parallel Old|    -XX:+UseParallelGC -XX:+UseParallelOldGC
Parallel New        |    Parallel Old|     N/A
Serial              |    CMS         |    -XX:-UseParNewGC -XX:+UseConcMarkSweepGC
Parallel Scavenge   |    CMS         |    N/A
Parallel New        |    CMS         |    -XX:+UseParNewGC -XX:+UseConcMarkSweepGC
G1                  |                |    -XX:+UseG1GC

Note that this stands true for Java 8，for older Java versions the available combinations might differ a bit。 
The table is from [GC Algorithms: Implementations](https://plumbr.eu/handbook/garbage-collection-algorithms-implementations )

#### 3.5.1 Serial收集器

最基本最悠久的单线程收集器，在它进行时，必须暂停其他所有的工作线程，直到它结束。Stop the World。 
优点:简洁高效(与其他收集器的单线程比)  
应用场景:运行在Client模式下的默认新生代收集器

#### 3.5.2 ParNew收集器

是Serial收集器的多线程版本  
应用场景：运行在Server模式下的虚拟机中首选的新生代收集器  

很重要的原因是：除了Serial收集器外，目前只有它能与CMS收集器配合工作。不幸的是，CMS作为老年代的收集器，却无法与JDK 1.4.0中已经存在的新生代收集器Parallel Scavenge配合工作，所以在JDK 1.5中使用CMS来收集老年代的时候，新生代只能选择ParNew或者Serial收集器中的一个。

#### 3.5.3 Parallel Scavenge 收集器

是一个新生代收集器，使用复制算法的并行多线程收集器  
优点:GC自适应的调节策略(GC Ergonomics) 不需要手工指定新生代的大小、Eden与Survivor区的比例、晋升老年代对象年龄等细节参数

应用场景：停顿时间越短就越适合需要与用户交互的程序，良好的响应速度能提升用户体验，而高吞吐量则可以高效率地利用CPU时间，尽快完成程序的运算任务，主要适合在后台运算而不需要太多交互的任务。

**Parallel Scavenge VS CMS收集器**
CMS收集器的关注点是尽可能缩短垃圾收集时用户线程的停顿时间；  
Parallel Scavenge收集器的目标是达到一个可控制的吞吐量。吞吐量=运行用户代码时间/(运行用户代码时间+垃圾收集时间)  
提供了两个参数用于精确控制吞吐量，分别是 控制最大垃圾收集停顿时间 和 直接设置吞吐量大小 的参数。

**Parallel Scavenge收集器 VS ParNew收集器**
Parallel Scavenge收集器与ParNew收集器的一个重要区别是它具有自适应调节策略。

#### 3.5.4 Serial Old 收集器

是Serial收集器的老年代版本，单线程，使用"标记-整理"算法

应用场景：

* Client模式: Serial Old收集器的主要意义也是在于给Client模式下的虚拟机使用。
* Server模式: 有两大用途：一种用途是在JDK 1.5以及之前的版本中与Parallel Scavenge收集器搭配使用，另一种用途就是作为CMS收集器的后备预案，在并发收集发生Concurrent Mode Failure时使用。

#### 3.5.5 Parallel Old 收集器

是Parallel Scavenge收集器的老年代版本，使用多线程和“标记－整理”算法。

应用场景：在注重吞吐量以及CPU资源敏感的场合，都可以优先考虑Parallel Scavenge加Parallel Old收集器。

#### 3.5.6 CMS(Concurrent Mark Sweep)收集器

以获取最短回收停顿时间为目标，基于"标记-清除"算法  过程

1. 初始标记(CMS initial mark):仅标记GC Roots能直接关联到的对象，速度很快，需要“Stop The World”  
2. 并发标记(CMS concurrent mark)  
3. 重新标记(CMS remark): 修正并发标记期间产生变动的对象的标记记录，停顿时间一般会比初始标记阶段稍长一些，但远比并发标记的时间短，仍然需要“Stop The World”  
4. 并发清除(CMS concurrent sweep)

优点： 并发收集、低停顿  
缺点

1. CMS收集器对CPU资源非常敏感  
2. 无法处理浮动垃圾(可能出现“Concurrent Mode Failure”失败而导致另一次Full GC的产生)  
3. 产生大量空间碎片  

#### 3.5.7 G1(Garbage-First) 收集器

可以做到基本不牺牲吞吐率的前提下完成低停顿的回收工作  
面向服务端。特点如下

* 并行与并发
* 分代收集
* 空间整合:从整体看是基于"标记-整理"，从局部看(两个Region之间)是基于"复制"算法，不会产生内存空间碎片
* 可预测的停顿:除了追求低停顿，还能建立可预测的停顿时间模型，能指定在垃圾收集上的时间不得超过N毫秒

就目前而言、CMS还是默认首选的GC策略、可能在以下场景下G1更适合：  

* 服务端多核CPU、JVM内存占用较大的应用（至少大于4G）
* 应用在运行过程中会产生大量内存碎片、需要经常压缩空间
* 想要更可控、可预期的GC停顿周期；防止高并发下应用雪崩现象

#### 3.5.8 理解GC日志

    33.125: [GC [DefNew: 3324K->152K(3712K)，0.0025925 secs] 3324K->152K(11904K)，0.0031680 secs]
    100.667: [Full GC [Tenured: 0K->210K(10240K)，0.0149142 secs] 4603K->210K(19456K)，[Perm : 2999K->2999K(21248K)]，0.0150007 secs] [Times: user=0.01 sys=0.00，real=0.02 secs]

最前面的数字"33.125："和"100.667："：代表了GC发生的时间，这个数字的含义是从Java虚拟机启动以来经过的秒数。

GC日志开头的"［GC"和"［Full GC"：说明了这次垃圾收集的停顿类型，而不是用来区分新生代GC还是老年代GC的。如果有"Full"，说明这次GC是发生了Stop-The-World的，例如下面这段新生代收集器ParNew的日志也会出现"［Full GC"(这一般是因为出现了分配担保失败之类的问题，所以才导致STW)。如果是调用System.gc()方法所触发的收集，那么在这里将显示"［Full GC (System)"。

    [Full GC 283.736: [ParNew: 261599K->261599K(261952K)，0.0000288 secs]

接下来的"［DefNew"、"［Tenured"、"［Perm"：表示GC发生的区域，这里显示的区域名称与使用的GC收集器是密切相关的，例如上面样例所使用的Serial收集器中的新生代名为"Default New Generation"，所以显示的是"［DefNew"。如果是ParNew收集器，新生代名称就会变为"［ParNew"，意为"Parallel New Generation"。如果采用Parallel Scavenge收集器，那它配套的新生代称为"PSYoungGen"，老年代和永久代同理，名称也是由收集器决定的。

后面方括号内部的"3324K->152K(3712K)"：含义是"GC前该内存区域已使用容量-> GC后该内存区域已使用容量 (该内存区域总容量)"。而在方括号之外的"3324K->152K(11904K)"：表示"GC前Java堆已使用容量 -> GC后Java堆已使用容量 (Java堆总容量)"。

再往后，"0.0025925 secs"表示该内存区域GC所占用的时间，单位是秒。有的收集器会给出更具体的时间数据，如"［Times： user=0.01 sys=0.00， real=0.02 secs］"，这里面的user、sys和real与Linux的time命令所输出的时间含义一致，分别代表用户态消耗的CPU时间、内核态消耗的CPU事件和操作从开始到结束所经过的墙钟时间(Wall Clock Time)。CPU时间与墙钟时间的区别是，墙钟时间包括各种非运算的等待耗时，例如等待磁盘I/O、等待线程阻塞，而CPU时间不包括这些耗时，但当系统有多CPU或者多核的话，多线程操作会叠加这些CPU时间，所以读者看到user或sys时间超过real时间是完全正常的。

### 3.6 内存分配策略与回收策略

* 对象优先在Eden分配
* 大对象直接进入老年代
* 长期存活的对象将进入老年代
* 动态对象年龄判定
* 空间分配担保

    Minor GC之前，虚拟机会先检查老年代最大可用连续空间是否大于新生代对象总空间， 
    如果大于，则Minor GC是安全的  
    如果不大于，则会查看HandlePromotionFailure设置值是否允许担保失败， 
        如果允许，则检查老年代最大可用连续空间是否大于历次晋升到老年代对象的平均大小  
            如果大于，将进行一次Minor GC，尽管这次是有风险的
            如果小于，那要改为进行Full GC。 
        如果不允许冒险，那要改为进行Full GC。 

## 第４章 虚拟机监控工具

jps: 虚拟机进程状况工具  
jstat: 虚拟机统计信息工具  
jinfo: Java配置信息工具  
jmap: Java内存映像工具  
jhat: 虚拟机堆转储快照分析工具  
jstack: Java堆栈跟踪工具  
HSDIS: JIT生成代码反汇编  

4.3.1　JHSDB：基于服务性代理的调试工具

## 第 7 章 虚拟机类加载机制

7个阶段:
加载 Loading， 
验证 Verification，准备 Preparation，解析 Resolution， 
初始化 Initialization，使用 Using，卸载 Unloading

其中，验证，准备，解析三个部分称为连接Linking

### 7.4 类加载器

两个类相等:必须是由同一个类加载器加载的同一个Class文件来的

#### 7.4.2 双亲委派模型

从Java开发人员的角度来看，主要有三种系统提供的类加载器

* 启动类加载器(Bootstrap ClassLoader):负责加载$JAVA_HOME/lib目录中的或者由-Xbootclasspath指定路径，它不能被Java程序直接引用
* 扩展类加载器(Extension ClassLoader):由sun.misc.Lanuncher$ExtClassLoader实现，负责加载$JAVA_HOME/lib/ext目录中，或者由java.ext.dirs系统变量指定，开发者可以使用
* 应用程序类加载器(Application ClassLoader)，也叫系统类加载器:由sun.misc.Lanuncher$AppClassLoader实现。负责加载用户路径(Classpath)上所指定的类库，开发者可以使用。

#### 7.4.3 破坏双亲委派模型

1. 在JDK1.2双亲委派模型引入之前
2. 自身缺陷导致，基础类需要调用用户代码。 
如JNDI的代码由启动类加载器加载，但它需要调用独立实现并部署在应用程序的ClassPath下的JNDI接口提供者(SPI，Service Provider Interface)的代码，但启动类不"认识"。
为了解决这个问题，引入了线程上下文类加载器(Thread Context ClassLoader)
3. 为了追求程序的动态性:代码热替换 HotSwap，模块热部署 Hot Deployment.OSGi实现模块化热部署，它的类加载器是网状结构，可以在平级的类加载器中进行

#### 类加载及执行子系统实例

##### Tomcat

[Tomcat 5.5](https://tomcat.apache.org/tomcat-5.5-doc/class-loader-howto.html)

            Bootstrap
              |
           Extension ClassLoader
              |
           System
              |
           Common
          /      \
     Catalina   Shared
                 /   \
            Webapp1  Webapp2 ...

[Tomcat 6.0 remove Shared ClassLoader](https://tomcat.apache.org/tomcat-6.0-doc/class-loader-howto.html)

          Bootstrap
              |
           System
              |
           Common
           /     \
      Webapp1   Webapp2 ...

##### OSGi

[Classloading](http://moi.vonos.net/java/osgi-classloaders/)

    bootstrap ClassLoader (includes Java standard libraries from jre/lib/rt.jar etc)
       ^
    extension ClassLoader
       ^
    system ClassLoader (i.e. stuff on $CLASSPATH，including OSGi core code)
       ^
    OSGi environment ClassLoader
       ^    (** Note: OSGi ClassLoaders forward lookups to parent ClassLoader only for some packages，e.g. java。*)
       \
        \   |-- OSGi ClassLoader for "system bundle"  -> (map of imported-package->ClassLoader)
         \--|-- OSGi ClassLoader for bundle1    -> (map of imported-package->ClassLoader)
            |-- OSGi ClassLoader for bundle2    -> (map of imported-package->ClassLoader)
            |-- OSGi ClassLoader for bundle3    -> (map of imported-package->ClassLoader)
                                         /
                                        /
          /========================================================================================\
          |  shared bundle registry，holding info about all bundles and their exported-packages  |
          \========================================================================================/

## 第12章 java内存模型与线程

### 12.3 java 内存模型

原子性，可见性，有序性  
先行发生原则

#### 12.3.1 主内存与工作内存

Java内存模型的主要目标是定义虚拟机中将变量存储到内存和从内存中取出变量这样的底层细节。它规定了所有的变量都存储在主内存(Main Memory)中，每条线程有自己的工作内存(Working Memory)，线程工作内存保存了使用到的变量的主内存副本拷贝，线程对变量的操作(读取，赋值等)都必须在工作内存中进行，而不能直接读写主内存中的变量。不同的线程之间也不能互相访问。线程间变量值的传递均需要通过主内存来完成。

#### 12.3.2 内存间交互操作

关于主内存与工作内存之间的交互协议，Java内存模型中定义了以下8种操作来完成，虚拟机实现必须保证每一种操作都是原子的，不可再分的(对于double和long类型的变量来说，load，store，read和write操作在某些平台上允许例外)

**注**:JSR-133文档已经放弃采用这8种操作来描述Java内存模型的访问协议。

1. lock: 作用于主内存变量，它把一个变量标识为一条线程独占状态
2. unlock: 作用于主内存变量，它把一个处于锁定状态的变量释放，释放后的变量才可以被其他线程锁定
3. read: 作用于主内存变量，它把一个变量的值从主内存传输到线程的工作内存，以全 load 使用
4. load: 作用于工作内存变量，它把read操作的值放入工作内存的变量副本中
5. use: 作用于工作内存变量，它把工作内存中一个变量的值传递给执行引擎，每当虚拟机遇到一个需要使用到变量的值的字节码指令时将会执行这个操作
6. assign: 作用于工作内存变量，它把一个从执行引擎收到的值赋给工作内存变量每当虚拟机遇到一个需要给变量赋值的字节码指令时执行这个操作
7. store:　作用于工作内存变量，它把工作内存中一个变量的值传送到主内存中，以便随后的write使用
8. write: 作用于主内存变量，它把store操作从工作内存中得到的变量的值放入主内存的变量中

如果要把一个变量从主内存复制到工作内存，那就要顺序执行read，load操作。
注意，Java内存模型只要求顺序执行，而不保证是连续执行。

##### 12.3.3 volatile

1. 保证此变量对所有线程的可见性
2. 禁止指令重排序优化
volatile一般情况下不能代替sychronized，因为volatile不能保证操作的原子性，即使只是i++，实际上也是由多个原子操作组成

#### 12.4 java与线程

##### 12.4.3 状态 java.lang.Thread.State

1. New
2. Runnable
3. Waiting
4. Timed Waiting
5. Blocked
6. Terminated
