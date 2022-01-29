# 深入理解Java虚拟机：JVM高级特性与最佳实践

周志明

## 问题

1. 内核态和用户态切换的成本是多少，衡量方式
2. 轻量级锁获取过程 bytecodeInterpreter.cpp#1816 。第二个线程获取锁时 升级为重量级锁的过程确认 对象存储的线程对象地址是否会被替换？
3. 元空间的存储 JDK 源码查看
4. 同一个类内多个属性 synchronize，几个锁？

## 第1章 走近Java

### 1.4 Java虚拟机发展史

Dalvik VM并不是一个Java虚拟机，它没有遵循Java虚拟机规范，不能直接执行Java的Class文件，使用的是寄存器架构而不是JVM中常见的栈架构。

> 8.5.2 基于栈的指令集与基于寄存器的指令集
> 基于栈的指令集（Instruction Set Architecture，ISA）：字节码指令流里面的指令大部分都是零地址指令，它们依赖操作数栈进行工作。
> 基于寄存器的指令集：最典型的就是x86的二地址指令集，二地址指令是x86指令集中的主流，每个指令都包含两个单独的输入参数，依赖于寄存器来访问和存储数据。
如果说得更通俗一些就是现在我们主流PC机中物理硬件直接支持的指令集架构，这些指令依赖寄存器进行工作。

## 自动内存管理

## 第2章 内存区域

运行时数据区分两部分

1. 线程共享：方法区（Method Area），堆（Heap）
2. 线程隔离：虚拟机栈（JVM Stack），本地方法栈（Native Method Stack），程序计数器（Program Counter Register）

线程    |     名字         | 作用
--- |    ---         | ---
共享    |    Java堆        |    存放对象实例
共享    |    方法区        |    存储被虚拟机加载的类信息，常量，静态变量，运行时常量池（Runtime Constant Pool）等。
隔离    |    程序计数器    |    当前线程所执行的字节码行号指示器，线程切换时可以快速切换位置
隔离    |    虚拟机栈        |    创建栈桢用于存储局部变量表，操作数栈，动态链接，方法出口等信息。局部变量表
隔离    |    本地方法栈    |    同虚拟机栈
隔离    |    直接内存    |    Native函数库直接分配的堆外内存

程序计数器存储两种：1. Java方法，则保存虚拟机字节码指令地址； 2. Native方法，为空（Undefined）
直接内存（Direct M emory）：Native函数库直接分配的堆外内存，然后通过一个存储在Java堆里面的DirectByteBuffer对象作为这块内存的引用进行操作

随着即时编译技术的进步，尤其是逃逸分析技术的日渐强大，栈上分配、标量替换优化手段，**Java对象实例都分配在堆上也渐渐变得不是那么绝对了**。

### 2.2 运行时数据区域

#### 2.2.5 方法区 Method Area 永生代

与Java堆一样，是各线程共享的内存区域，虽然Java虚拟机堆规范把方法区描述为堆的一个逻辑部分，但是它别名叫做Non-Heap（非堆），目的应该是与Java堆区分开。在使用HotSpot时，很多人把方法区称为"永生代"，本质上两者并不等价，仅仅是因为HotSpot虚拟机的设计团队把GC分代收集扩展至方法区，或者说使用永久代来实现方法区

在JDK8之前的HotSpot虚拟机中，类的"永久的"数据存放在永久代，通过`‑XX:MaxPermSize` 设置永久代的大小。它的垃圾回收和老年代的垃圾回收是绑定的，一旦其中一个被占满，则两个都要进行回收。但一旦元数据（类的层级信息，方法数据，方法信息如字节码，栈和变量大小，运行时常量池，已确定的符号引用和虚方法表）超过了永久代的大小，程序就会出现内存溢出OOM。

> Permanent Generation Partially Removed
> [JVM_Troubleshooting](https://www.oracle.com/webfolder/technetwork/tutorials/mooc/JVM_Troubleshooting/week1/lesson1.pdf)
> • In JDK 7, some things were moved out of PermGen
> – Symbols were moved to native memory
> – Interned strings were moved to the Java Heap
> – Class statics were moved to the Java Heap

**JDK8移除了永生代**，类的元数据保存到了一个与堆不相连的本地内存区域--**元空间**，它的最大可分配空间就是系统可用的内存空间。
元空间的内存管理：每一个类加载器的存储区域都称作一个元空间，所有的元空间合在一起。当一个类加载器不再存活，其对应的元空间就会被回收。
Classes and metadata stored in the Metaspace
[Metaspace](https://wiki.openjdk.java.net/display/HotSpot/Metaspace)

元空间的JVM参数有两个：-XX:MetaspaceSize=N和 -XX:MaxMetaspaceSize=N，对于64位JVM来说，元空间的默认初始大小是20.75MB，默认的元空间的最大值是无限。MaxMetaspaceSize用于设置metaspace区域的最大值，MetaspaceSize表示metaspace首次使用不够而触发FGC的阈值，只对触发起作用，

[JVM源码分析之Metaspace解密-你假笨](JVM源码分析之Metaspace解密)

[Java 内存分区之 堆外内存 Metaspace 元空间 取永久代PermGen 而代之 请叫我大师兄__](https://blog.csdn.net/qq_27093465/article/details/106758504)
class metadata 用于记录一个 Java 类在 JVM 中的信息，包括但不限于 JVM class file format 的运行时数据： 
1、Klass 结构，这个非常重要，把它理解为一个 Java 类在虚拟机内部的表示吧；
2、method metadata，包括方法的字节码、局部变量表、异常表、参数信息等；
3、常量池；
4、注解；
5、方法计数器，记录方法被执行的次数，用来辅助 JIT 决策
6、 其他
虽然每个 Java 类都关联了一个 java.lang.Class 的实例，而且它是一个贮存在堆中的 Java 对象。但是类的 class metadata 不是一个 Java 对象，它不在堆中，而是在 Metaspace 中。

### 2.3 HotSpot虚拟机

#### 2.3.1 对象的创建

1. **指针碰撞 Bump the Pointer**：已使用的内存放一边，空闲的放另一边，建立新对象分配内存仅仅是把指针向空闲空间那边挪动一段与对象大小相等的距离
2. **空闲列表 Free List**：已使用和空闲的内存相互交错，虚拟机必须维护一个列表，记录可用内存块，建立新对象分配内存时要从列表中找到一块足够大的空间划分给对象实例，并更新列表上的记录。

**分配空间的并发问题**：并发情况下，可能出现正在给对象A分配内存，指针还没来得及修改，对象B又同时使用了原来的指针来分配内存的情况。解决这个问题有两种方案：

1. 一种是对分配内存空间的动作进行同步处理--实际上虚拟机采用CAS配上失败重试的方式保证更新操作的原子性；
2. 另一种是把内存分配的动作按线程划分在不同的空间中进行，即每个线程在Java堆中预先分配一小块内存，称为本地线程分配缓冲（Thread Local Allocation Buffer，TLAB）

#### 2.3.2 对象内存布局

在HotSpot虚拟机中，对象在内存中存储的布局分３块区域：对象头（Header），实例数据（Instance Data）和对齐填充（Padding）
对象头包括

1. 存储对象自身的运行时数据，如HashCode，GC分代年龄，锁状态标志，线程持有的锁，偏向线程ID，偏向时间戳等。官方称为 Mark Word。Mark Word的32个比特存储空间中的25个比特用于存储对象哈希码，4个比特用于存储对象分代年龄，2个比特用于存储锁标志位，1个比特固定为0
2. 类型指针，即对象指向它的类元数据的指针，虚拟机通过它来确定这个对象是哪个类的实例。
3. 此外，如果对象是一个Java数组，那在对象头中还必须有一块用于记录数组长度的数据，因为虚拟机可以通过普通Java对象的元数据信息确定Java对象的大小，但是如果数组的长度是不确定的，将无法通过元数据中的信息推断出数组的大小。

#### 2.3.3 对象访问定位

1. 使用句柄：Java堆中会划分出一块内存作为句柄池
栈中的reference存储对象句柄地址，句柄包含对象实例数据与类型数据地址信息
优点：在对象移动（垃圾回收）时，只会改变句柄中实例数据指针，而reference本身不需修改
2. 使用直接指针访问：reference存储的就是对象地址。HotSpot使用此种方式
优点：访问速度快，节省一次指针定位的时间开销

## 第3章 垃圾收集器与内存分配策略

* 哪些内存需要回收?
* 什么时候回收?
* 如何回收?

Garbage collector is responsible for
– Allocations
– Keeping the alive objects in memory
– Reclaiming the space used by unreachable objects

### 3.2 判断对象是否在使用

#### 3.2.1 引用计数算法 Reference Counting

优点：简单
缺点：难以解决循环引用

主流的Java虚拟机里面都没有选用引用计数算法

#### 3.2.2 可达性分析算法 Reachability Analysis

可作为 GC Roots 的对象包括:

* 虚拟机栈（栈桢中的本地变量表）中引用的对象
* 方法区中类静态属性引用的对象
* 方法区中常量引用的对象
* 本地方法中 JNI（即一般说的 Native 方法）引用的对象
* Java虚拟机内部的引用，如基本数据类型对应的Class对象，一些常驻的异常对象（比如 NullPointExcepiton、OutOfM emoryError）等，还有系统类加载器。
* 所有被同步锁（synchronized关键字）持有的对象。
* 反映Java虚拟机内部情况的JM XBean、JVM TI中注册的回调、本地代码缓存等。

#### 3.2.3　再谈引用

在JDK 1.2版之后，Java对引用的概念进行了扩充，将引用分为强引用（Strongly Reference）、软引用（Soft Reference）、弱引用（Weak Reference）和虚引用（Phantom Reference）4种，这4种引用强度依次逐渐减弱。

* 强引用是最传统的“引用”的定义，是指在程序代码之中普遍存在的引用赋值软引用是用来描述一些还有用，但非必须的对象。
* 软引用 SoftReference 关联着的对象，在系统将要发生内存溢出异常前，会把这些对象列进回收范围之中进行第二次回收，如果这次回收还没有足够的内存，才会抛出内存溢出异常
* 弱引用 WeakReference 也是用来描述那些非必须对象，强度比软引用更弱一些，被弱引用关联的对象只能生存到下一次垃圾收集发生为止。当垃圾收集器开始工作，无论当前内存是否足够，都会回收掉只被弱引用关联的对象。
* 虚引用 PhantomReference 也称为“幽灵引用”或者“幻影引用”，它是最弱的一种引用关系。一个对象是否有虚引用的存在，完全不会对其生存时间构成影响，也无法通过虚引用来取得一个对象实例。为一个对象设置虚引用关联的唯一目的只是为了能在这个对象被收集器回收时收到一个系统通知。

#### 3.2.5　回收方法区

《Java虚拟机规范》中提到过可以不要求虚拟机在方法区中实现垃圾收集，事实上也确实有未实现或未能完整实现方法区类型卸载的收集器存在（如JDK 11时期的ZGC收集器就不支持类卸载），方法区垃圾收集的“性价比”通常也是比较低的

方法区的垃圾收集主要回收两部分内容：废弃的常量和不再使用的类型。判定一个常量是否“废弃”还是相对简单，而要判定一个类型是否属于“不再被使用的类”的条件就比较苛刻了。需要同时满足下面三个条件：

* 该类所有的实例都已经被回收，也就是Java堆中不存在该类及其任何派生子类的实例。
* 加载该类的类加载器已经被回收，这个条件除非是经过精心设计的可替换类加载器的场景，如OSGi、JSP的重加载等，否则通常是很难达成的。
* 该类对应的java.lang.Class对象没有在任何地方被引用，无法在任何地方通过反射访问该类的方法。

### 3.3 垃圾收集算法

#### 3.3.1 分代收集 Generational Collection

根据对象存活周期不同，将内存分为几块：新生代和老年代，这样就根据各个年代特点采用最适当的收集算法。
在新生代使用复制算法，只需付出少量存活对象的复制成本就可以完成收集。
老年代中因为对象存活率高，没有额外空间对它进行分配担保，就必须使用"标记-清理"或者"标记-整理"算法

#### 3.3.2 标记-清除算法 Mark-Sweep

首先标记出需要回收的对象，标记完成后统一回收所有被标记的对象。它是最基础的收集算法。

缺点：

1. 效率问题：标记和清除两个过程效率都不高；
2. 空间问题：会产生大量不连续的内存碎片，导致最后无法找到足够的连续内存而不得不提前触发另一次垃圾收集动作。

#### 3.3.3 复制算法 Copying

将内存分为大小相等两块，每次只使用一块。当一块用完了，就将活着的对象复制到另外一块上，然后把已使用过的内存空间一次清理掉。
现代商业虚拟机都采用这种算法：将内存分为一块较大的Eden空间，两块较小的Survivor空间，每次使用Eden和其中一块Survivor

优点：实现简单，运行高效
缺点：内存缩小了一半

#### 3.3.4 标记整理算法 Mark-Compact

根据老年代特点，提出此算法，标记过程与“标记-清除”算法一样，但后续步骤不是直接清理，而是让所有存活对象都向一端移动，然后直接清理掉边界以外的内存

是否移动对象都存在弊端，移动则内存回收时会更复杂，不移动则内存分配时会更复杂。

### 3.4　HotSpot的算法细节实现

#### 3.4.1　根节点枚举

HotSpot是使用一组称为 OopMap 的数据结构，直接得到哪些地方存放着对象引用的

#### 3.4.2　安全点

HotSpot 在安全点（Safepoint）为每条指令都生成 OopMap，也就决定了用户程序执行时只有在安全带才能够停顿下来开始垃圾收集。

* 抢先式中断（Preemptive Suspension）：在垃圾收集发生时，系统首先把所有用户线程全部中断，如果发现有用户线程中断的地方不在安全点上，就恢复这条线程执行，让它一会再重新中断，直到跑到安全点上。现在几乎没有虚拟机实现采用抢先式中断来暂停线程响应GC事件
* 主动式中断（Voluntary Suspension）：当垃圾收集需要中断线程的时候，设置标志位，各个线程执行过程时会不停地主动去轮询这个标志，一旦发现中断标志为真时就自己在最近的安全点上主动中断挂起。

#### 3.4.3　安全区域

安全区域（Safe Region）是指能够确保在某一段代码片段之中，引用关系不会发生变化，因此，在这个区域中任意地方开始垃圾收集都是安全的。

用户线程处于Sleep状态或者Blocked状态，这时候线程无法响应虚拟机的中断请求，不能再走到安全的地方去中断挂起自己。

当用户线程执行到安全区域里面的代码时，首先会标识自己已经进入了安全区域，那样当这段时间里虚拟机要发起垃圾收集时就不必去管这些已声明自己在安全区域内的线程了。当线程要离开安全区域时，它要检查虚拟机是否已经完成了根节点枚举（或者垃圾收集过程中其他需要暂停用户线程的阶段），如果完成了，那线程就当作没事发生过，继续执行；否则它就必须一直等待，直到收到可以离开安全区域的信号为止。

#### 3.4.4　记忆集与卡表

为解决对象跨代引用所带来的问题，垃圾收集器在新生代中建立了名为记忆集（Remembered Set）的数据结构，用以避免把整个老年代加进GC Roots扫描范围。

卡精度：每个记录精确到一块内存区域，该区域内有对象含有跨代指针。用一种称为“卡表”（Card Table）的方式去实现记忆集，这也是目前最常用的一种记忆集实现形式

#### 3.4.5　写屏障

HotSpot虚拟机里是通过写屏障（Write Barrier）技术维护卡表状态的

#### 3.4.6　并发的可达性分析

Wilson于1994年在理论上证明了，当且仅当以下两个条件同时满足时，会产生“对象消失”的问题，即原本应该是黑色的对象被误标为白色：

* 赋值器插入了一条或多条从黑色对象到白色对象的新引用；
* 赋值器删除了全部从灰色对象到该白色对象的直接或间接引用。

因此，我们要解决并发扫描时的对象消失问题，只需破坏这两个条件的任意一个即可。由此分别产生了两种解决方案：

* 增量更新（Incremental Update）： CMS
* 原始快照（Snapshot At The Beginning，SATB）：G1、Shenandoah

### 垃圾收集器

**Young generation**: Serial，ParNew，Parallel Scavenge，G1（Garbage First）
**Tenured generation**: CMS（Concurrent Mark Sweep），Serial Old（MSC），Parallel Old，G1（Garbage First）

![HostSpot垃圾回收器]（image/HostSpot垃圾回收器。png "HostSpot垃圾回收器"）

algorithm combinations cheat sheet

Young               |    Tenured     |    JVM options
---                 |    ---         |        ---
Incremental         |    Incremental |    -Xincgc
Serial              |    Serial      |    -XX:+UseSerialGC
Parallel Scavenge   |    Serial      |    -XX:+UseParallelGC -XX:-UseParallelOldGC
Parallel New        |    Serial      |    N/A
Serial              |    Parallel Old|    N/A
Parallel Scavenge   |    Parallel Old|    -XX:+UseParallelGC -XX:+UseParallelOldGC
Parallel New        |    Parallel Old|    N/A
Serial              |    CMS         |    Before JDK 9 -XX:-UseParNewGC -XX:+UseConcMarkSweepGC
Serial              |    CMS         |    After JDK 9 N/A
Parallel Scavenge   |    CMS         |    N/A
Parallel New        |    CMS         |    -XX:+UseParNewGC -XX:+UseConcMarkSweepGC
G1                  |                |    -XX:+UseG1GC

Note that this stands true for Java 8，for older Java versions the available combinations might differ a bit.
The table is from [GC Algorithms: Implementations](https://plumbr.eu/handbook/garbage-collection-algorithms-implementations )

### 3.5　经典垃圾收集器

#### 3.5.1 Serial 收集器

最基本最悠久的单线程收集器，在它进行时，必须暂停其他所有的工作线程，直到它结束。Stop the World。
优点：简洁高效（与其他收集器的单线程比）
应用场景：运行在 Client 模式下的默认新生代收集器

#### 3.5.2 ParNew 收集器

是 Serial 收集器的多线程版本
应用场景：运行在 Server 模式下的虚拟机中首选的新生代收集器

很重要的原因是：除了 Serial 收集器外，目前只有它能与 CMS 收集器配合工作。不幸的是，CMS作为老年代的收集器，却无法与JDK 1.4.0中已经存在的新生代收集器Parallel Scavenge配合工作，所以在JDK 1.5中使用CMS来收集老年代的时候，新生代只能选择ParNew或者Serial收集器中的一个。

##### CMS 不能与 Parallel Scavenge 配合工作的原因

除了一个面向低延迟一个面向高吞吐量的目标不一致外，技术上的原因是Parallel Scavenge收集器及后面提到的G1收集器等都没有使用HotSpot中原本设计的垃圾收集器的分代框架，而选择另外独立实现。Serial、ParNew 收集器则共用了这部分的框架代码，详细可参考：[Our Collectors 2) Why doesn't "ParNew" and "Parallel Old" work together?](https://blogs.oracle.com/jonthecollector/our-collectors)

#### 3.5.3 Parallel Scavenge 收集器

是一个新生代收集器，使用复制算法的并行多线程收集器
优点：GC自适应的调节策略（GC Ergonomics） 不需要手工指定新生代的大小、Eden与Survivor区的比例、晋升老年代对象年龄等细节参数

应用场景：停顿时间越短就越适合需要与用户交互的程序，良好的响应速度能提升用户体验，而高吞吐量则可以高效率地利用CPU时间，尽快完成程序的运算任务，主要适合在后台运算而不需要太多交互的任务。

**Parallel Scavenge VS CMS收集器**
CMS收集器的关注点是尽可能缩短垃圾收集时用户线程的停顿时间；
Parallel Scavenge收集器的目标是达到一个可控制的吞吐量。  吞吐量 = 运行用户代码时间 /（运行用户代码时间+垃圾收集时间）
提供了两个参数用于精确控制吞吐量，分别是 控制最大垃圾收集停顿时间 和 直接设置吞吐量大小 的参数。

**Parallel Scavenge收集器 VS ParNew收集器**
Parallel Scavenge收集器与ParNew收集器的一个重要区别是它具有自适应调节策略。

#### 3.5.4 Serial Old 收集器

是Serial收集器的老年代版本，单线程，使用"标记-整理"算法

应用场景：

* Client模式：Serial Old收集器的主要意义也是在于给Client模式下的虚拟机使用。
* Server模式：有两大用途：一种用途是在JDK 1.5以及之前的版本中与Parallel Scavenge收集器搭配使用，另一种用途就是作为CMS收集器的后备预案，在并发收集发生Concurrent Mode Failure时使用。

#### 3.5.5 Parallel Old 收集器

是Parallel Scavenge收集器的老年代版本，使用多线程和“标记－整理”算法。

应用场景：在注重吞吐量以及CPU资源敏感的场合，都可以优先考虑Parallel Scavenge加Parallel Old收集器。

#### 3.5.6 CMS（Concurrent Mark Sweep）收集器

以获取最短回收停顿时间为目标，基于"标记-清除"算法  过程

1. 初始标记（CMS initial mark）：仅标记GC Roots能直接关联到的对象，速度很快，需要“Stop The World”
2. 并发标记（CMS concurrent mark）
3. 重新标记（CMS remark）：修正并发标记期间产生变动的对象的标记记录，停顿时间一般会比初始标记阶段稍长一些，但远比并发标记的时间短，仍然需要“Stop The World”
4. 并发清除（CMS concurrent sweep）

优点： 并发收集、低停顿
缺点

1. CMS收集器对CPU资源非常敏感
2. 无法处理浮动垃圾（可能出现“Concurrent Mode Failure”失败而导致另一次Full GC的产生）
3. 产生大量空间碎片

#### 3.5.7 G1（Garbage-First） 收集器

可以做到基本不牺牲吞吐率的前提下完成低停顿的回收工作
面向服务端。特点如下

* 并行与并发
* 分代收集
* 空间整合：从整体看是基于"标记-整理"，从局部看（两个Region之间）是基于"复制"算法，不会产生内存空间碎片
* 可预测的停顿：除了追求低停顿，还能建立可预测的停顿时间模型，能指定在垃圾收集上的时间不得超过N毫秒

G1收集器的

运作过程大致可划分为以下四个步骤：

* 初始标记（Initial Marking）：标记 GC Roots 能直接关联到的对象，并且修改 TAMS 指针的值，让下一阶段用户线程并发运行时，能正确地在可用的Region中分配新对象。这个阶段需要停顿线程，但耗时很短，而且是借用进行Minor GC的时候同步完成的，所以G1收集器在这个阶段实际并没有额外的停顿。
* 并发标记（Concurrent Marking）：从GC Root开始对堆中对象进行可达性分析，递归扫描整个堆里的对象图，找出要回收的对象，这阶段耗时较长，但可与用户程序并发执行。当对象图扫描完成以后，还要重新处理SATB记录下的在并发时有引用变动的对象。
* 最终标记（Final Marking）：对用户线程做另一个短暂的暂停，用于处理并发阶段结束后仍遗留下来的最后那少量的SATB记录。
* 筛选回收（Live Data Counting and Evacuation）：负责更新Region的统计数据，对各个Region的回收价值和成本进行排序，根据用户所期望的停顿时间来制定回收计划，可以自由选择任意多个Region构成回收集，然后把决定回收的那一部分Region的存活对象复制到空的Region中，再清理掉整个旧Region的全部空间。这里的操作涉及存活对象的移动，是必须暂停用户线程，由多条收集器线程并行完成的。

G1收集器除了并发标记外，其余阶段也是要完全暂停用户线程的。

就目前而言、CMS还是默认首选的GC策略、可能在以下场景下G1更适合：

* 服务端多核CPU、JVM内存占用较大的应用（至少大于4G）
* 应用在运行过程中会产生大量内存碎片、需要经常压缩空间
* 想要更可控、可预期的GC停顿周期；防止高并发下应用雪崩现象

### 3.6　低延迟垃圾收集器

#### 3.6.1　Shenandoah收集器

OpenJDK 12的正式特性

目标是实现一种能在任何堆内存大小下都可以把垃圾收集的停顿时间限制在十毫秒以内的垃圾收集器

工作过程大致可以划分为以下九个阶段：

* 初始标记（Initial Marking）：标记与GC Roots直接关联的对象，这个阶段仍是“Stop The World”的
* 并发标记（Concurrent Marking）
* 最终标记（Final Marking）：处理剩余的SATB扫描，并在这个阶段统计出回收价值也会有一小段短暂的停顿。
* 并发清理（Concurrent Cleanup）
* 并发回收（Concurrent Evacuation）：把回收集里面的存活对象先复制一份到其他未被使用的Region，通过读屏障和被称为“Brooks Pointers”的转发指针来实现移动对象和用户线程并行。
* 初始引用更新（Initial Update Reference）
* 并发引用更新（Concurrent Update Reference）
* 最终引用更新（Final Update Reference）：这个阶段是Shenandoah的最后一次停顿，停顿时间只与GC Roots的数量相关。
* 并发清理（Concurrent Cleanup）

其中三个最重要的并发阶段（并发标记、并发回收、并发引用更新）

#### 3.6.2　[ZGC 收集器](https://wiki.openjdk.java.net/display/zgc/Main)

JDK 11中新加入

At a glance, ZGC is:

Concurrent
Region-based
Compacting
NUMA-aware
Using colored pointers
Using load barriers

ZGC和Shenandoah的目标是高度相似的，都希望在尽可能对吞吐量影响不太大的前提下，实现在任意堆内存大小下都可以把垃圾收集的停顿时间限制在十毫秒以内的低延迟。

在x64硬件平台下，ZGC的Region 有 大、中、小三类容量：

* 小型Region（Small Region）：容量固定为2MB，用于放置小于256KB的小对象。
* 中型Region（Medium Region）：容量固定为32MB，用于放置大于等于256KB但小于4MB的对象。
* 大型Region（Large Region）：容量不固定，可以动态变化，但必须为2MB的整数倍，用于放置4MB或以上的大对象。每个大型Region中只会存放一个大对象

染色指针技术（Colored Pointer）
64位的Linux则分别支持47位（128TB）的进程虚拟地址空间和46位（64TB）的物理地址空间，64位的Windows系统甚至只支持44位（16TB）的物理地址空间。

ZGC的染色指针技术使用了46位指针的高4位来存储四个标志信息，导致ZGC能够管理的内存不可以超过4TB（2的42次幂）

通过这些标志位，虚拟机可以直接从指针中看到其引用对象的三色标记状态、是否进入了重分配集（即被移动过）、是否只能通过finalize()方法才能被访问到。

ZGC的运作过程：

* 初始标记（Mark Start）：标记与GC Roots直接关联的对象，这个阶段仍是“Stop The World”的
* 并发标记（Concurrent Mark）
* 并发预备重分配（Concurrent Prepare for Relocate）：统计得出本次收集过程要清理哪些Region，将这些Region组成重分配集（Relocation Set）
* 并发重分配（Concurrent Relocate）：重分配是ZGC执行过程中的核心阶段，这个过程要把重分配集中的存活对象复制到新的Region上，并为重分配集中的每个Region维护一个转发表（Forward Table），记录从旧对象到新对象的转向关系。
* 并发重映射（Concurrent Remap）：重分配集中旧对象的所有引用，被合并到了下一次垃圾收集循环中的并发标记阶段里去完成

#### 3.7.3 虚拟机及垃圾收集器日志

JDK 9 HotSpot所有功能的日志都收归到了“-Xlog”参数上: `-Xlog[:[selector][:[output][:[decorators][:output-options]]]]`

    33.125: [GC [DefNew: 3324K->152K（3712K），0.0025925 secs] 3324K->152K（11904K），0.0031680 secs]
    100.667: [Full GC [Tenured: 0K->210K（10240K），0.0149142 secs] 4603K->210K（19456K），[Perm : 2999K->2999K（21248K）]，0.0150007 secs] [Times: user=0.01 sys=0.00，real=0.02 secs]

最前面的数字"33.125："和"100.667："：代表了GC发生的时间，这个数字的含义是从Java虚拟机启动以来经过的秒数。

GC日志开头的"［GC"和"［Full GC"：说明了这次垃圾收集的停顿类型，而不是用来区分新生代GC还是老年代GC的。如果有"Full"，说明这次GC是发生了Stop-The-World的，例如下面这段新生代收集器ParNew的日志也会出现"［Full GC"（这一般是因为出现了分配担保失败之类的问题，所以才导致STW）。如果是调用System.gc（）方法所触发的收集，那么在这里将显示"［Full GC （System）"。

    [Full GC 283.736: [ParNew: 261599K->261599K（261952K），0.0000288 secs]

接下来的"［DefNew"、"［Tenured"、"［Perm"：表示GC发生的区域，这里显示的区域名称与使用的GC收集器是密切相关的，例如上面样例所使用的Serial收集器中的新生代名为"Default New Generation"，所以显示的是"［DefNew"。如果是ParNew收集器，新生代名称就会变为"［ParNew"，意为"Parallel New Generation"。如果采用Parallel Scavenge收集器，那它配套的新生代称为"PSYoungGen"，老年代和永久代同理，名称也是由收集器决定的。

后面方括号内部的"3324K->152K（3712K）"：含义是"GC前该内存区域已使用容量-> GC后该内存区域已使用容量 （该内存区域总容量）"。而在方括号之外的"3324K->152K（11904K）"：表示"GC前Java堆已使用容量 -> GC后Java堆已使用容量 （Java堆总容量）"。

再往后，"0.0025925 secs"表示该内存区域GC所占用的时间，单位是秒。有的收集器会给出更具体的时间数据，如"［Times： user=0.01 sys=0.00， real=0.02 secs］"，这里面的user、sys和real与Linux的time命令所输出的时间含义一致，分别代表用户态消耗的CPU时间、内核态消耗的CPU事件和操作从开始到结束所经过的墙钟时间（Wall Clock Time）。CPU时间与墙钟时间的区别是，墙钟时间包括各种非运算的等待耗时，例如等待磁盘I/O、等待线程阻塞，而CPU时间不包括这些耗时，但当系统有多CPU或者多核的话，多线程操作会叠加这些CPU时间，所以读者看到user或sys时间超过real时间是完全正常的。

#### 3.7.4　垃圾收集器参数总结

### 3.8　实战：内存分配与回收策略

* 对象优先在Eden分配
* 大对象直接进入老年代
* 长期存活的对象将进入老年代
* 动态对象年龄判定
* 空间分配担保

    Minor GC之前，虚拟机会先检查老年代最大可用连续空间是否大于新生代对象总空间
    如果大于，则Minor GC是安全的
    如果不大于，则会查看HandlePromotionFailure设置值是否允许担保失败
        如果允许，则检查老年代最大可用连续空间是否大于历次晋升到老年代对象的平均大小
            如果大于，将进行一次Minor GC，尽管这次是有风险的
            如果小于，那要改为进行Full GC
        如果不允许冒险，那要改为进行Full GC

## 第４章 虚拟机性能监控、故障处理工具

jps: 虚拟机进程状况工具
jstat: 虚拟机统计信息工具
jinfo: Java配置信息工具
jmap: Java内存映像工具
jhat: 虚拟机堆转储快照分析工具
jstack: Java堆栈跟踪工具
HSDIS: JIT生成代码反汇编
JHSDB: JDK 9

### 4.3　可视化故障处理工具

#### 4.3.1 JHSDB：基于服务性代理的调试工具

JHSDB 是一款基于服务性代理（Serviceability Agent，SA）实现的进程外调试工具。服务性代理是HotSpot虚拟机中一组用于映射Java虚拟机运行信息的、主要基于Java语言（含少量JNI代码）实现的API集合。

[jhsdb](https://docs.oracle.com/en/java/javase/11/tools/jhsdb.html)

表4-15 JCMD、JHSDB和基础工具的对比
基础工具| JCMD | HSDB
--- | --- | ---
jps -lm | jcmd | N/A
jmap -dump pid | jcmd pid GC.heap_dump | jhsdb jmap --binaryheap
jmap-histo pid | jcmd pid GC.class_histogram | jhsdb jmap --histo
jstack pid | jcmd pid Thread.print | jhsdb jstack --locks
jinfo -sysprops pid | jcmd pid VM.system_properties | jhsdb info --sysprops
jinfo -flags pid | jcmd pid VM.flags | jhsdbj info --flags

## 第三部分　虚拟机执行子系统

## 第6章　类文件结构

## 第 7 章 虚拟机类加载机制

7个阶段:
加载 Loading
连接 Linking 阶段包括：验证 Verification，准备 Preparation，解析 Resolution
初始化 Initialization，使用 Using，卸载 Unloading

其中，验证，准备，解析三个部分称为连接Linking

### 7.3　类加载的过程

#### 7.3.1　加载

在加载阶段，Java虚拟机需要完成以下三件事情：

1. 通过一个类的全限定名来获取定义此类的二进制字节流。
2. 将这个字节流所代表的静态存储结构转化为方法区的运行时数据结构。
3. 在内存中生成一个代表这个类的java.lang.Class对象，作为方法区这个类的各种数据的访问入口。

#### 7.3.2　验证

验证阶段大致上会完成下面四个阶段的检验动作：文件格式验证、元数据验证、字节码验证和符号引用验证。

### 7.4 类加载器

两个类相等：必须是由同一个类加载器加载的同一个Class文件来的

#### 7.4.2 双亲委派模型

从Java开发人员的角度来看，主要有三种系统提供的类加载器

* 启动类加载器（Bootstrap ClassLoader）：负责加载$JAVA_HOME/lib目录中的或者由-Xbootclasspath指定路径，它不能被Java程序直接引用
* 扩展类加载器（Extension ClassLoader）：由sun.misc.Lanuncher$ExtClassLoader实现，负责加载$JAVA_HOME/lib/ext目录中，或者由java.ext.dirs系统变量指定，开发者可以使用
* 应用程序类加载器（Application ClassLoader），也叫系统类加载器：由sun.misc.Lanuncher$AppClassLoader实现。负责加载用户路径（Classpath）上所指定的类库，开发者可以使用。

#### 7.4.3 破坏双亲委派模型

1. 在JDK1.2双亲委派模型引入之前
2. 自身缺陷导致，基础类需要调用用户代码。
如JNDI的代码由启动类加载器加载，但它需要调用独立实现并部署在应用程序的ClassPath下的JNDI接口提供者（SPI，Service Provider Interface）的代码，但启动类不"认识"。
为了解决这个问题，引入了线程上下文类加载器（Thread Context ClassLoader）
3. 为了追求程序的动态性：代码热替换 HotSwap，模块热部署 Hot Deployment.OSGi实现模块化热部署，它的类加载器是网状结构，可以在平级的类加载器中进行

### 7.5　Java模块化系统

扩展类加载器（Extension Class Loader）被平台类加载器（Platform Class Loader）取代。

JDK 9中虽然仍然维持着三层类加载器和双亲委派的架构，但类加载的委派关系也发生了变动。当平台及应用程序类加载器收到类加载请求，在委派给父加载器加载前，要先判断该类是否能够归属到某一个系统模块中，如果可以找到这样的归属关系，就要优先委派给负责那个模块的加载器完成加载，也许这可以算是对双亲委派的第四次破坏

## 第8章　虚拟机字节码执行引擎

### 8.2　运行时栈帧结构

### 8.3　方法调用

#### 8.3.1　解析

#### 8.3.2 分派 Dispatch

* 静态分派 Method Overload Resolution，

静态分派的最典型应用表现就是方法重载。静态类型是在编译期可知的。静态分派发生在编译阶段，因此确定静态分派的动作实际上不是由虚拟机来执行的，这点也是为何一些资料选择把它归入“解析”而不是“分派”的原因。

* 动态分派 它与Java语言多态性的另外一个重要体现——重写（Override）有着很密切的关联

这种多态性的根源在于虚方法调用指令invokevirtual的执行逻辑，那自然我们得出的结论就只会对方法有效，对字段是无效的，因为字段不使用这条指令。

* 单分派与多分派

方法的接收者与方法的参数统称为方法的宗量，这个定义最早应该来源于著名的《Java与模式》一书。根据分派基于多少种宗量，可以将分派划分为单分派和多分派两种。单分派是根据一个宗量对目标方法进行选择，多分派则是根据多于一个宗量对目标方法进行选择。

Java语言是一门静态多分派、动态单分派的语言

#### 8.4　动态类型语言支持

8.4.1　动态类型语言

8.4.2　Java与动态类型

8.4.3　java.lang.invoke包

JDK 7时新加入的java.lang.invoke包[1]是JSR 292的一个重要组成部分，这个包的主要目的是在之前单纯依靠符号引用来确定调用的目标方法这条路之外，提供一种新的动态确定目标方法的机制，称为“方法句柄”（Method Handle）

8.4.4　invokedynamic指令

某种意义上可以说invokedynamic指令与 MethodHandle机制的作用是一样的，都是为了解决原有4条“invoke*”指令方法分派规则完全固化在虚拟机之中的问题，把如何查找目标方法的决定权从虚拟机转嫁到具体用户代码之中，让用户（广义的用户，包含其他程序语言的设计者）有更高的自由度

#### 8.5　基于栈的字节码解释执行引擎

8.5.1　解释执行

Java语言经常被人们定位为“解释执行”的语言，在Java初生的JDK 1.0时代，这种定义还算是比较准确的，但当主流的虚拟机中都包含了即时编译器后，Class文件中的代码到底会被解释执行还是编译执行，就成了只有虚拟机自己才能准确判断的事。

8.5.2　基于栈的指令集与基于寄存器的指令集

Javac编译器输出的字节码指令流，基本上[1]是一种基于栈的指令集架构（Instruction Set Architecture，ISA），字节码指令流里面的指令大部分都是零地址指令，它们依赖操作数栈进行工作。

与之相对的另外一套常用的指令集架构是基于寄存器的指令集，最典型的就是x86的二地址指令集，如果说得更通俗一些就是现在我们主流PC机中物理硬件直接支持的指令集架构，这些指令依赖寄存器进行工作。

基于栈的指令集主要优点是可移植，因为寄存器由硬件直接提供[2]，程序直接依赖这些硬件寄存器则不可避免地要受到硬件的约束。

8.5.3　基于栈的解释器执行过程

## 第9章　类加载及执行子系统的案例与实战

### Tomcat

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

### OSGi

[Classloading](http://moi.vonos.net/java/osgi-classloaders/)

    bootstrap ClassLoader （includes Java standard libraries from jre/lib/rt.jar etc）
       ^
    extension ClassLoader
       ^
    system ClassLoader （i.e. stuff on $CLASSPATH，including OSGi core code）
       ^
    OSGi environment ClassLoader
       ^    （** Note: OSGi ClassLoaders forward lookups to parent ClassLoader only for some packages，e.g. java。*）
       \
        \   |-- OSGi ClassLoader for "system bundle"  -> （map of imported-package->ClassLoader）
         \--|-- OSGi ClassLoader for bundle1    -> （map of imported-package->ClassLoader）
            |-- OSGi ClassLoader for bundle2    -> （map of imported-package->ClassLoader）
            |-- OSGi ClassLoader for bundle3    -> （map of imported-package->ClassLoader）
                                         /
                                        /
          /========================================================================================\
          |  shared bundle registry，holding info about all bundles and their exported-packages  |
          \========================================================================================/

### 字节码生成技术与动态代理的实现

Javassist、CGLib、ASM 之类的字节码类库，JDK里面的Javac命令就是字节码生成技术的“老祖宗”，并且Javac也是一个由Java语言写成的程序，它的代码存放在OpenJDK的jdk.compiler\share\classes\com\sun\tools\javac目录中。

许多Java开发人员都使用过动态代理，即使没有直接使用过java.lang.reflect.Proxy或实现过java.lang.reflect.InvocationHandler接口，应该也用过Spring来做过Bean的组织管理。

### Backport工具：Java的时光机器

## 第四部分　程序编译与代码优化

## 第10章　前端编译与优化

* 前端编译器：JDK的Javac、Eclipse JDT中的增量式编译器（ECJ）。
* 即时编译器：HotSpot虚拟机的C1、C2编译器，Graal编译器。
* 提前编译器：JDK的Jaotc、GNU Compiler for the Java（GCJ）、Excelsior JET。

## 第11章　后端编译与优化

### 11.2　即时编译器

目前主流的两款商用Java虚拟机（HotSpot、OpenJ9）里，Java程序最初都是通过解释器（Interpreter）进行解释执行的，当虚拟机发现某个方法或代码块的运行特别频繁，就会把这些代码认定为“热点代码”（Hot Spot Code），为了提高热点代码的执行效率，在运行时，虚拟机将会把这些代码编译成本地机器码，并以各种手段尽可能地进行代码优化，运行时完成这个任务的后端编译器被称为即时编译器。

### 11.3　提前编译器

### 11.4　编译器优化技术

#### 11.4.1　优化技术概览

#### 11.4.2　方法内联

#### 11.4.3　逃逸分析 Escape Analysis

#### 11.4.4　公共子表达式消除

#### 11.4.5　数组边界检查消除

### 11.5　实战：深入理解Graal编译器

Graal编译器在JDK 9时以Jaotc提前编译工具的形式首次加入到官方的JDK中，从JDK 10起，Graal编译器可以替换服务端编译器，成为HotSpot分层编译中最顶层的即时编译器。

## 第五部分　高效并发

## 第12章 java内存模型与线程

### 12.3 java 内存模型

原子性，可见性，有序性
先行发生原则

#### 12.3.1 主内存与工作内存

Java内存模型的主要目标是定义虚拟机中将变量存储到内存和从内存中取出变量这样的底层细节。它规定了所有的变量都存储在主内存（Main Memory）中，每条线程有自己的工作内存（Working Memory），线程工作内存保存了使用到的变量的主内存副本拷贝，线程对变量的操作（读取，赋值等）都必须在工作内存中进行，而不能直接读写主内存中的变量。不同的线程之间也不能互相访问。线程间变量值的传递均需要通过主内存来完成。

#### 12.3.2 内存间交互操作

关于主内存与工作内存之间的交互协议，Java内存模型中定义了以下8种操作来完成，虚拟机实现必须保证每一种操作都是原子的，不可再分的（对于double和long类型的变量来说，load，store，read和write操作在某些平台上允许例外）

**注**:JSR-133文档已经放弃采用这8种操作来描述Java内存模型的访问协议。

1. lock: 作用于主内存变量，它把一个变量标识为一条线程独占状态
2. unlock: 作用于主内存变量，它把一个处于锁定状态的变量释放，释放后的变量才可以被其他线程锁定
3. read: 作用于主内存变量，它把一个变量的值从主内存传输到线程的工作内存，以全 load 使用
4. load: 作用于工作内存变量，它把read操作的值放入工作内存的变量副本中
5. use: 作用于工作内存变量，它把工作内存中一个变量的值传递给执行引擎，每当虚拟机遇到一个需要使用到变量的值的字节码指令时将会执行这个操作
6. assign: 作用于工作内存变量，它把一个从执行引擎收到的值赋给工作内存变量每当虚拟机遇到一个需要给变量赋值的字节码指令时执行这个操作
7. store: 作用于工作内存变量，它把工作内存中一个变量的值传送到主内存中，以便随后的write使用
8. write: 作用于主内存变量，它把store操作从工作内存中得到的变量的值放入主内存的变量中

如果要把一个变量从主内存复制到工作内存，那就要顺序执行read，load操作。
注意，Java内存模型只要求顺序执行，而不保证是连续执行。

Java设计团队将Java内存模型的操作**简化为read、write、lock和unlock 四种**，但这只是语言描述上的等价化简，Java内存模型的基础设计并未改变。

#### 12.3.3 volatile

1. 保证此变量对所有线程的可见性
2. 禁止指令重排序优化
volatile一般情况下不能代替sychronized，因为volatile不能保证操作的原子性，即使只是i++，实际上也是由多个原子操作组成

#### 12.3.6　先行发生原则

### 12.4 java与线程

#### 12.4.1　线程的实现

实现线程主要有三种方式：使用内核线程实现（1：1实现），使用用户线程实现（1：N实现），使用用户线程加轻量级进程混合实现（N：M 实现）

Java线程的实现，从JDK 1.3起，“主流”平台上的“主流”商用Java虚拟机的线程模型普遍都被替换为基于操作系统原生线程模型来实现，即采用1：1的线程模型。

#### 12.4.2　Java线程调度

线程调度是指系统为线程分配处理器使用权的过程，调度主要方式有两种，

* 协同式（Cooperative Threads-Scheduling）线程调度：线程的执行时间由线程本身来控制，线程把自己的工作执行完了之后，要主动通知系统切换到另外一个线程上去
* 抢占式（Preemptive Threads-Scheduling）线程调度：每个线程将由系统来分配执行时间，线程的切换不由线程本身来决定。

Java使用的线程调度方式就是抢占式调度。

Java 语言一共设置了10个级别的线程优先级（Thread.M IN_PRIORITY至Thread.M AX_PRIORITY）。在两个线程同时处于Ready状态时，优先级越高的线程越容易被系统选择执行。

不过，线程调度最终是由操作系统说了算，操作系统的线程优先级的概念并不见得能与Java线程的优先级一一对应

#### 12.4.3 状态转换 java.lang.Thread.State

1. New
2. Runnable
3. Waiting
4. Timed Waiting
5. Blocked
6. Terminated

#### 12.5　Java与协程

仍在进行中。

## 第13章　线程安全与锁优化

### 13.2　线程安全

定义：当多个线程同时访问一个对象时，如果不用考虑这些线程在运行时环境下的调度和交替执行，也不需要进行额外的同步，或者在调用方进行任何其他的协调操作，调用这个对象的行为都可以获得正确的结果，那就称这个对象是线程安全的。
-- Java并发编程实战（Java Concurrency In Practice）作者 Brian Goetz

#### 13.2.1　Java语言中的线程安全

可以将Java语言中各种操作共享的数据分为以下五类：不可变、绝对线程安全、相对线程安全、线程兼容和线程对立。

1. 不可变 final关键字修饰。比如 java.lang.String类的对象
2. 绝对线程安全
3. 相对线程安全 是我们通常意义上所讲的线程安全，比如Vector和HashTable
   它需要保证对这个对象单次的操作是线程安全的，我们在调用的时候不需要进行额外的保障措施，
   但是对于一些特定顺序的连续调用，就可能需要在调用端使用额外的同步手段来保证调用的正确性。
4. 线程兼容 指对象本身并不是线程安全的，但是可以通过在调用端正确地使用同步手段来保证对象在并发环境中可以安全地使用，
   Java类库API中大部分的类都是线程兼容的。比如集合类ArrayList和 HashMap等。
5. 线程对立 指不管调用端是否采取了同步措施，都无法在多线程环境中并发使用代码
   Thread类的suspend()和resume()方法。如果有两个线程同时持有一个线程对象，一个尝试去中断线程，一个尝试去恢复线程，在并发进行的情况下，无论调用时是否进行了同步，目标线程都存在死锁风险——假如suspend()中断的线程就是即将要执行resume()的那个线程，那就肯定要产生死锁了。也正是这个原因，suspend()和resume()方法都已经被声明废弃了。
   常见的线程对立的操作还有System.setIn()、Sytem.setOut()和System.runFinalizersOnExit()等。

#### 13.2.2　线程安全的实现方法

1.互斥同步（M utual Exclusion & Synchronization）是一种最常见也是最主要的并发正确性保障手段。

同步是指在多个线程并发访问共享数据时，保证共享数据在同一个时刻只被一条（或者是一些，当使用信号量的时候）线程使用。

而互斥是实现同步的一种手段，临界区（Critical Section）、互斥量（Mutex）和信号量（Semaphore）都是常见的互斥实现方式。

重入锁（ReentrantLock）是Lock接口最常见的一种实现，顾名思义，它与synchronized一样是可重入的。

ReentrantLock与synchronized相比增加了一些高级功能，主要有以下三项：等待可中断、可实现公平锁及锁可以绑定多个条件。

* 等待可中断：是指当持有锁的线程长期不释放锁的时候，正在等待的线程可以选择放弃等待，改为处理其他事情。可中断特性对处理执行时间非常长的同步块很有帮助。
* 公平锁：是指多个线程在等待同一个锁时，必须按照申请锁的时间顺序来依次获得锁；而非公平锁则不保证这一点，在锁被释放时，任何一个等待锁的线程都有机会获得锁。synchronized中的锁是非公平的，ReentrantLock在默认情况下也是非公平的，但可以通过带布尔值的构造函数要求使用公平锁。不过一旦使用了公平锁，将会导致ReentrantLock的性能急剧下降，会明显影响吞吐量。
* 锁绑定多个条件：是指一个ReentrantLock对象可以同时绑定多个Condition对象。

#### 13.3　锁优化

高效并发是从JDK 5升级到JDK 6后一项重要的改进项，HotSpot虚拟机开发团队在这个版本上花费了大量的资源去实现各种锁优化技术，如适应性自旋（Adaptive Spinning）、锁消除（Lock Elimination）、锁膨胀（Lock Coarsening）、轻量级锁（Lightweight Locking）、偏向锁（Biased Locking）等，这些技术都是为了在线程之间更高效地共享数据及解决竞争问题，从而提高程序的执行效率。

##### 13.3.1　自旋锁与自适应自旋

##### 13.3.2　锁消除

对被检测到不可能存在共享数据竞争的锁进行消除。

锁消除的主要判定依据来源于逃逸分析的数据支持（第11章已经讲解过逃逸分析技术），如果判断到一段代码中，在堆上的所有数据都不会逃逸出去被其他线程访问到，那就可以把它们当作栈上数据对待，认为它们是线程私有的，同步加锁自然就无须再进行。

##### 13.3.3　锁粗化

如果一系列的连续操作都对同一个对象反复加锁和解锁，甚至加锁操作是出现在循环体之中的，那即使没有线程竞争，频繁地进行互斥同步操作也会导致不必要的性能损耗。

##### 13.3.4　轻量级锁

轻量级锁并不是用来代替重量级锁的，它设计的初衷是**在没有多线程竞争的前提下**，减少传统的重量级锁使用操作系统互斥量产生的性能消耗。

HotSpot虚拟机的对象头（Object Header）分为两部分，第一部分用于存储对象自身的运行时数据，如哈希码（HashCode）、GC分代年龄（Generational GC Age）等。这部分数据的长度在32位和64位的Java虚拟机中分别会占用32个或64个比特，官方称它为“Mark Word”。这部分是实现轻量级锁和偏向锁的关键。另外一部分用于存储指向方法区对象类型数据的指针，如果是数组对象，还会有一个额外的部分用于存储数组长度。这些对象内存布局的详细内容，

轻量级锁的工作过程：

1. 在线程执行同步代码块之前，JVM会现在当前线程的栈桢中创建用于存储锁记录的空间，并将锁对象头中的 markWord 信息复制到锁记录中，这个官方称为 Displaced Mard Word。然后线程尝试使用 CAS 将对象头中的 MarkWord 替换为指向锁记录的指针。

2. 将锁对象头中的 markWord 信息复制到锁记录中，这个官方称为 Displaced Mard Word。然后线程尝试使用 CAS 将对象头中的 MarkWord 替换为指向锁记录的指针。如果替换成功，则进入步骤3，失败则进入步骤4。

3. CAS 替换成功说明当前线程已获得该锁，此时在栈桢中锁标志位信息也更新为轻量级锁状态：00。此时的栈桢与锁对象头的状态如图二所示。

4. 如果CAS 替换失败则说明当前时间锁对象已被某个线程占有，那么此时当前线程只有通过自旋的方式去获取锁。如果在自旋一定次数后仍为获得锁，那么轻量级锁将会升级成重量级锁。**升级成重量级锁带来的变化就是对象头中锁标志位将变为 10（重量级锁），MarkWord 中存储的也就是指向互斥量（重量级锁）的指针。（注意！！！此时，锁对象头的 MarkWord 已经发生了改变）。**
   这时轻量级锁解锁时，通过 CAS 判断 Mark Word 中的栈指针，替换会失败，需要唤醒等待的线程。

##### 13.3.5　偏向锁

如果说轻量级锁是在无竞争的情况下使用CAS操作去消除同步使用的互斥量，那偏向锁就是在无竞争的情况下把整个同步都消除掉，连CAS操作都不去做了。

偏向锁中的“偏”，就是偏心的“偏”、偏袒的“偏”。它的意思是这个锁会偏向于第一个获得它的线程，如果在接下来的执行过程中，该锁一直没有被其他的线程获取，则持有偏向锁的线程将永远不需要再进行同步。
