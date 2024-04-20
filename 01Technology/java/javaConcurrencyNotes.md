# Java Concurrency

## Recent

StampedLock 在提供类似读写锁的同时，还支持优化读模式。优化读基于假设，大多数情况下读操作并不会和写操作冲突，其逻辑是先试着读，然后通过validate方法确认是否进入了写模式，如果没有进入，就成功避免了开销；如果进入，则尝试获取读锁。
CopyOnWriteArrayList 原来的一系列类 对应的新类型整理

[Joins](https://docs.oracle.com/javase/tutorial/essential/concurrency/join.html)
The join method allows one thread to wait for the completion of another. If t is a Thread object whose thread is currently executing, `t.join();` causes the current thread to pause execution until t's thread terminates.

[Interrupts](https://docs.oracle.com/javase/tutorial/essential/concurrency/interrupt.html)
An interrupt is an indication to a thread that it should stop what it is doing and do something else

synchronization:

1. Mutual Exclusion or Atomic or Critical Section临界区
2. Memory Visibility

同步: 原子性Atomic,内存可见性
重排序Reordering, Happens-Before 排序

[不可不说的Java“锁”事-美团](https://tech.meituan.com/2018/11/15/java-lock.html)

易出现并发问题情形:
竞态条件Race Condition
读取-修改-写入read-modify-write
先检查后执行操作Check-Then-Act

## 可见性、原子性和有序性问题

1. CPU 缓存导致的可见性问题
2. 线程切换带来的原子性问题
3. 优化带来的有序性问题：编译优化，CPU 缓存等

## CAS 以及带来的三大问题

CAS全称为Compare And Swap（比较与交换），常用来实现乐观锁，通俗理解就是在更新数据前，先比较一下原数据与期待值是否一致，若一致说明过程中没有其他线程更新过，则进行新值替换，否则更新失败。

实现是通过 Unsafe类的compareAndSwapInt()方法

CAS 存在的问题：

* ABA问题：使用 AtomicStampedReference 类解决
* 长时间自旋：通过让JVM 能支持处理器提供的 pause 指令，这样对效率会有一定的提升
* 多个共享变量的原子操作：使用AtomicReference类或者锁

## ThreadLocal

是线程局部变量(local variable).
就是为每一个使用该变量的线程都提供一个变量值的副本，是每一个线程都可以独立地改变自己的副本，而不会和其它线程的副本冲突.从线程的角度看，就好像每一个线程都完全拥有该变量.

使用场景

* To keep state with a thread (user-id, transaction-id, logging-id)
* To cache objects which you need frequently

主要由四个方法组成initialValue()，get()，set(T)，remove()，其中值得注意的是initialValue()，该方法是一个protected的方法，显然是为了子类重写而特意实现的.该方法返回当前线程在该线程局部变量的初始值，这个方法是一个延迟调用方法，在一个线程第1次调用get()或者set(Object)时才执行，并且仅执行1次.ThreadLocal中的实现直接返回一个null.

## java.util.concurrent.locks类结构

### 概念

基于AQS(AbstractQueuedSynchronizer) 构建的Synchronizer包括ReentrantLock,Semaphore,CountDownLatch, ReetrantRead WriteLock,FutureTask等，这些Synchronizer实际上最基本的东西就是原子状态的获取和释放，只是条件不一样而已.

**ReentrantLock**：需要记录当前线程获取原子状态的次数，如果次数为零，那么就说明这个线程放弃了锁(也有可能其他线程占据着锁从而需要等待)，如果次数大于1，也就是获得了重进入的效果，而其他线程只能被park住，直到这个线程重进入锁次数变成0而释放原子状态

**Semaphore**：则是要记录当前还有多少次许可可以使用，到0，就需要等待，也就实现并发量的控制，`Semaphore` 一开始设置许可数为1，实际上就是一把互斥锁

**CountDownLatch**：闭锁则要保持其状态，在这个状态到达终止态之前，所有线程都会被park住，闭锁可以设定初始值，这个值的含义就是这个闭锁需要被countDown()几次，因为每次CountDown是sync.releaseShared(1),而一开始初始值为10的话，那么这个闭锁需要被countDown()十次，才能够将这个初始值减到0，从而释放原子状态，让等待的所有线程通过.

**FutureTask**：需要记录任务的执行状态，当调用其实例的get方法时,内部类Sync会去调用AQS的acquireSharedInterruptibly()方法，而这个方法会反向调用Sync实现的tryAcquireShared()方法，即让具体实现类决定是否让当前线程继续还是park,而FutureTask的tryAcquireShared方法所做的唯一事情就是检查状态，如果是RUNNING状态那么让当前线程park.而跑任务的线程会在任务结束时调用FutureTask 实例的set方法(与等待线程持相同的实例)，设定执行结果，并且通过unpark唤醒正在等待的线程，返回结果.

#### 有时候需要多个线程都获得同一把锁，去做一件事情

信号量 `Semaphore` ，创建信号量的时候得指定一个整数(例如10)， 表明同一时刻最多有10个线程可以获得锁： `Semaphore lock= new Semaphore(10);` 当然每个线程都需要调用`lock.aquire()`, `lock.release()`去申请/释放锁

#### 一个线程要写共享变量， 可是还有几个线程要同时读

只好来一个读写锁了`ReadWriteLock`， 为了保证可重入性， 元老院体贴的实现了 `ReentrantReadWriteLock`

#### 一个线程需要等待其他多个线程完工以后才能干活

计数器`CountDownLatch`，某个线程干完了就把计数器减去1， 如果计数器为0了，那个一直耐心等待的线程就可以开始了。

#### 几个线程必须互相等待， 就像100米赛跑那样， 所有人都准备好了才能起跑 `CyclicBarrier`

### Synchronized和ReentrantLock的区别

#### [JDK 5.0 中更灵活、更具可伸缩性的锁定机制](https://www.ibm.com/developerworks/cn/java/j-jtp10264/index.html)

java.util.concurrent.lock 中的 Lock 框架是锁定的一个抽象，它允许把锁定的实现作为 Java 类，而不是作为语言的特性来实现。这就为 Lock 的多种实现留下了空间，各种实现可能有不同的调度算法、性能特性或者锁定语义。 ReentrantLock 类实现了 Lock ，它拥有与 synchronized 相同的并发性和内存语义，但是添加了类似轮询锁、定时锁等候和可中断锁等候的一些特性。此外，它还提供了在激烈争用情况下更佳的性能

#### [synchronized的字节码表示](https://www.cnblogs.com/javaminer/p/3889023.html)

在java语言中存在两种内建的synchronized语法

1. synchronized语句
 对于synchronized语句当Java源代码被javac编译成bytecode的时候，会在同步块的入口位置和退出位置分别插入monitorenter和monitorexit字节码指令。
2. synchronized方法
 synchronized方法则会被翻译成普通的方法调用和返回指令如:invokevirtual、areturn指令，在VM字节码层面并没有任何特别的指令来实现被synchronized修饰的方法，而是在Class文件的方法表中将该方法的access_flags字段中的synchronized标志位置1，表示该方法是同步方法并使用调用该方法的对象或该方法所属的Class在JVM的内部对象表示Klass做为锁对象

#### 异同[我是皮皮甜大王](https://www.jianshu.com/p/650498242d67)

两者的共同点：
1）协调多线程对共享对象、变量的访问
2）可重入，同一线程可以多次获得同一个锁
3）都保证了可见性和互斥性
两者的不同点：
1）ReentrantLock显示获得、释放锁，synchronized隐式获得释放锁
2）ReentrantLock可响应中断、可轮回，synchronized是不可以响应中断的，为处理锁的不可用性提供了更高的灵活性
3）ReentrantLock是API级别的，synchronized是JVM级别的
4）ReentrantLock可以实现公平锁
5）ReentrantLock通过Condition可以绑定多个条件
6）底层实现不一样， synchronized是同步阻塞，使用的是悲观并发策略，lock是同步非阻塞，采用的是乐观并发策略

#### [ReentrantLock vs synchronized on CPU level](https://stackoverflow.com/questions/36371149/reentrantlock-vs-synchronized-on-cpu-level)

`synchronized` uses a locking mechanism that is built into the JVM and `MONITORENTER` / `MONITOREXIT` bytecode instructions. So the underlying implementation is JVM-specific (that is why it is called intrinsic lock) and AFAIK usually (subject to change) uses a pretty conservative strategy: once lock is "inflated" after threads collision on lock acquiring, `synchronized` begin to use OS-based locking ("fat locking") instead of fast CAS ("thin locking") and do not "like" to use CAS again soon (even if contention is gone).

`ReentrantLock` implementation is based on `AbstractQueuedSynchronizer` and coded in pure Java (uses CAS instructions and thread descheduling which was introduced it Java 5), so it is more stable across platforms, offers more flexibility and tries to use fast CAS appoach for acquiring a lock every time (and OS-level locking if failed).

## Java高级-多线程机制详解

### 二、线程的运行机制

阻塞状态

1. JVM将CPU资源从当前线程切换给其他线程，使本线程让出CPU的使用权，并处于挂起状态.
2. 线程使用CPU资源期间，执行了sleep(int millsecond)方法，使当前线程进入休眠状态.sleep(int millsecond)方法是Thread类中的一个类方法，线程执行该方法就立刻让出CPU使用权，进入挂起状态.经过参数millsecond指定的毫秒数之后，该线程就重新进到线程队列中排队等待CPU资源，然后从中断处继续运行.
3. 线程使用CPU资源期间，执行了wait()方法，使得当前线程进入等待状态.等待状态的线程不会主动进入线程队列等待CPU资源，必须由其他线程调用notify()方法通知它，才能让该线程从新进入到线程队列中排队等待CPU资源，以便从中断处继续运行.
4. 线程使用CPU资源期间，执行某个操作进入阻塞状态，如执行读/写操作引起阻塞.进入阻塞状态时线程不能进入线程队列，只有引起阻塞的原因消除时，线程才能进入到线程队列排队等待CPU资源，以便从中断处继续运行.

### 三、线程调度模型与优先级

JVM的线程调度器负责管理线程，调度器把线程的优先级分为10个级别，分别用Thread类中的类常量表示.每个Java线程的优先级都在常数1-10之间.

Thread类优先级常量有三个：

``` java

static int MIN_PRIORITY  //1
static int NORM_PRIORITY //5
static int MAX_PRIORITY  //10
```

如果没有明确设置，默认线程优先级为常数5, 即Thread.NORM_PRIORITY.

### 五、Java线程同步

1. 要处理线程同步，可以把修改数据的方法用关键字synchronized修饰.一个方法使用synchronized修饰，当一个线程A使用这个方法时，其他线程想使用该方法时就必须等待，直到线程A使用完该方法.所谓同步就是多个线程都需要使用一个synchronized修饰的方法.

    * 当两个并发线程访问同一个对象object中的这个synchronized(this)同步代码块时，一个时间内只能有一个线程得到执行.另一个线程必须等待当前线程执行完这个代码块以后才能执行该代码块.
    * 当一个线程访问object的一个synchronized(this)同步代码块时，另一个线程仍然可以访问该object中的非synchronized(this)同步代码块.
    * 当一个线程访问object的一个synchronized(this)同步代码块时，其他线程对object中所有其它synchronized(this)同步代码块的访问将被阻塞.
    * 当一个线程访问object的一个synchronized(this)同步代码块时，它就获得了这个object的对象锁.结果，其它线程对该object对象所有同步代码部分的访问都被暂时阻塞.

    第一点：synchronized用来标识一个普通方法时，表示一个线程要执行该方法，必须取得该方法所在的对象的锁.
    第二点：synchronized用来标识一个静态方法时，表示一个线程要执行该方法，必须获得该方法所在的类的类锁.
    第三点：synchronized修饰一个代码块.类似这样：synchronized(obj) { //code.... }.表示一个线程要执行该代码块，必须获得obj的锁.这样做的目的是减小锁的粒度，保证当不同块所需的锁不冲突时不用对整个对象加锁.利用零长度的byte数组对象做obj非常经济.

2. volatile比同步简单，只适合于控制对基本变量(整数、布尔变量等)的单个实例的访问.java中的volatile关键字与C++中一样，用volatile修饰的变量在读写操作时不会进行优化(取cache里的值以提高io速度)，而是直接对主存进行操作，这表示所有线程在任何时候看到的volatile变量值都相同.
3. 在同步方法中使用wait()、notify()、notifyAll()方法：
 当一个线程使用的同步方法中用到某个变量，而此变量又需要其他线程修改后才能符合本线程需要，那么可以在同步方法中使用wait()方法.中断方法的执行，使本线程等待，暂时让出CPU资源，并允许其他线程使用这个同步方法.其他线程如果在使用这个同步方法时不需要等待，那么它使用完这个同步方法时应当用notifyAll()方法通知所有由于使用这个同步方法而处于等待的线程结束等待.曾中断的线程就会从中断处继续执行，并遵循"先中断先继续"的原则.如果用的notify()方法，那么只是通知等待中的线程中某一个结束等待.

### [聊聊并发（三）——JAVA线程池的分析和使用](http://www.infoq.com/cn/articles/java-threadPool)
作者 方腾飞 发布于 2012年11月15日

通过`ThreadPoolExecutor`来创建一个线程池。
`new  ThreadPoolExecutor(corePoolSize, maximumPoolSize, keepAliveTime, milliseconds,runnableTaskQueue, handler)`
创建一个线程池需要输入几个参数：
    `corePoolSize` （线程池的基本大小）：当提交一个任务到线程池时，线程池会创建一个线程来执行任务，即使其他空闲的基本线程能够执行新任务也会创建线程，等到需要执行的任务数大于线程池基本大小时就不再创建。如果调用了线程池的prestartAllCoreThreads方法，线程池会提前创建并启动所有基本线程。
    `runnableTaskQueue` （任务队列）：用于保存等待执行的任务的阻塞队列。 可以选择以下几个阻塞队列。
        ArrayBlockingQueue：是一个基于数组结构的有界阻塞队列，此队列按 FIFO（先进先出）原则对元素进行排序。
        LinkedBlockingQueue：一个基于链表结构的阻塞队列，此队列按FIFO （先进先出） 排序元素，吞吐量通常要高于ArrayBlockingQueue。静态工厂方法Executors.newFixedThreadPool()使用了这个队列。
        SynchronousQueue：一个不存储元素的阻塞队列。每个插入操作必须等到另一个线程调用移除操作，否则插入操作一直处于阻塞状态，吞吐量通常要高于LinkedBlockingQueue，静态工厂方法Executors.newCachedThreadPool使用了这个队列。
        PriorityBlockingQueue：一个具有优先级的无限阻塞队列。
    `maximumPoolSize` （线程池最大大小）：线程池允许创建的最大线程数。如果队列满了，并且已创建的线程数小于最大线程数，则线程池会再创建新的线程执行任务。值得注意的是如果使用了无界的任务队列这个参数就没什么效果。
    `ThreadFactory`: 用于设置创建线程的工厂，可以通过线程工厂给每个创建出来的线程设置更有意义的名字。
    `RejectedExecutionHandler`（饱和策略）：当队列和线程池都满了，说明线程池处于饱和状态，那么必须采取一种策略处理提交的新任务。这个策略默认情况下是AbortPolicy，表示无法处理新任务时抛出异常。以下是JDK1.5提供的四种策略。
        `AbortPolicy`：直接抛出异常。
        `CallerRunsPolicy`：只用调用者所在线程来运行任务。
        `DiscardOldestPolicy`：丢弃队列里最近的一个任务，并执行当前任务。
        `DiscardPolicy`：不处理，丢弃掉。
        当然也可以根据应用场景需要来实现`RejectedExecutionHandler`接口自定义策略。如记录日志或持久化不能处理的任务
    `keepAliveTime` （线程活动保持时间）：线程池的工作线程空闲后，保持存活的时间。所以如果任务很多，并且每个任务执行的时间比较短，可以调大这个时间，提高线程的利用率。
    `TimeUnit` （线程活动保持时间的单位）：可选的单位有天（DAYS），小时（HOURS），分钟（MINUTES），毫秒(MILLISECONDS)，微秒(MICROSECONDS, 千分之一毫秒)和毫微秒(NANOSECONDS, 千分之一微秒)。

#### 线程池的主要工作流程

Java Doc: `java.util.concurrent.ThreadPoolExecutor.execute(Runnable)`

1. 首先线程池判断基本线程池是否已满？没满，创建一个工作线程来执行任务。满了，则进入下个流程
2. 其次线程池判断工作队列是否已满？没满，则将新提交的任务存储在工作队列里。满了，则进入下个流程
3. 最后线程池判断整个线程池是否已满？没满，则创建一个新的工作线程来执行这个新提交的任务，满了，则交给饱和策略来处理这个任务

#### 合理的配置线程池

[Java并发：线程池如何设置线程数_线程池中的线程数量-CSDN博客](https://blog.csdn.net/chuixue24/article/details/122828355)

要想合理的配置线程池，就必须首先分析任务特性，可以从以下几个角度来进行分析：
    任务的性质：CPU密集型任务，IO密集型任务和混合型任务。
    任务的优先级：高，中和低。
    任务的执行时间：长，中和短。
    任务的依赖性：是否依赖其他系统资源，如数据库连接。

任务性质不同的任务可以用不同规模的线程池分开处理。

* CPU密集型任务配置尽可能小的线程，如配置Ncpu+1个线程的线程池
* IO密集型任务则由于线程并不是一直在执行任务，则配置尽可能多的线程，如2*Ncpu
* 混合型的任务，如果可以拆分，则将其拆分成一个CPU密集型任务和一个IO密集型任务，只要这两个任务执行的时间相差不是太大，那么分解后执行的吞吐率要高于串行执行的吞吐率，如果这两个任务执行时间相差太大，则没必要进行分解。
 我们可以通过Runtime.getRuntime().availableProcessors()方法获得当前设备的CPU个数。

优先级不同的任务可以使用优先级队列PriorityBlockingQueue来处理。它可以让优先级高的任务先得到执行，需要注意的是如果一直有优先级高的任务提交到队列里，那么优先级低的任务可能永远不能执行。

执行时间不同的任务可以交给不同规模的线程池来处理，或者也可以使用优先级队列，让执行时间短的任务先执行。

依赖数据库连接池的任务，因为线程提交SQL后需要等待数据库返回结果，如果等待的时间越长CPU空闲时间就越长，那么线程数应该设置越大，这样才能更好的利用CPU。

建议使用有界队列，有界队列能增加系统的稳定性和预警能力，可以根据需要设大一点，比如几千。有一次我们组使用的后台任务线程池的队列和线程池全满了，不断的抛出抛弃任务的异常，通过排查发现是数据库出现了问题，导致执行SQL变得非常缓慢，因为后台任务线程池里的任务全是需要向数据库查询和插入数据的，所以导致线程池里的工作线程全部阻塞住，任务积压在线程池里。如果当时我们设置成无界队列，线程池的队列就会越来越多，有可能会撑满内存，导致整个系统不可用，而不只是后台任务出现问题。当然我们的系统所有的任务是用的单独的服务器部署的，而我们使用不同规模的线程池跑不同类型的任务，但是出现这样问题时也会影响到其他任务。

#### 线程池的监控

通过线程池提供的参数进行监控。线程池里有一些属性在监控线程池的时候可以使用
    `taskCount`: 线程池需要执行的任务数量
    `completedTaskCount`: 线程池在运行过程中已完成的任务数量。小于或等于taskCount
    `largestPoolSize`: 线程池曾经创建过的最大线程数量。通过这个数据可以知道线程池是否满过。如等于线程池的最大大小，则表示线程池曾经满了
    `getPoolSize`: 线程池的线程数量。如果线程池不销毁的话，池里的线程不会自动销毁，所以这个大小只增不+ getActiveCount: 获取活动的线程数

通过扩展线程池进行监控。通过继承线程池并重写线程池的 `beforeExecute`, `afterExecute和terminated` 方法，我们可以在任务执行前，执行后和线程池关闭前干一些事情。如监控任务的平均执行时间，最大执行时间和最小执行时间等。这几个方法在线程池里是空方法。如: `protected void beforeExecute(Thread t, Runnable r) { }`

## Java并发机制的底层实现原理

### 2.1　volatile

volatile的两条实现原则。进行写操作的时候会多出行 lock 汇编代码

1. Lock前缀指令会引起处理器缓存回写到内存。
2. 一个处理器的缓存回写到内存会导致其他处理器的缓存无效。
   1. 处理器使用MESI（修改、独占、共享、无效）控制协议去维护内部缓存和其他处理器缓存的一致性。

DCL单例（Double Check Lock）到底需不需要volatile?
如果不加 volatile，可能因为指令重排导致 使用到半初始化状态的对象

if(t != null) xxx -> 使用了半初始化状态的对象

### 2.3　原子操作的实现原理

处理器如何实现原子操作

1. 使用总线锁保证原子性
2. 使用缓存锁保证原子性，有两种情况下处理器不会使用缓存锁定。
   1. 当操作的数据不能被缓存在处理器内部，或操作的数据跨多个缓存行（cache line）时，则处理器会调用总线锁定。
   2. 有些处理器不支持缓存锁定

## Java内存模型(JMM)

站在程序员的视角，Java内存模型规范了JVM如何提供按需禁用缓存和编译优化的方法。具体来说，包括 volatile、synchronized 和 final 三个关键字，以及六项 Happens-Before 规则。

JMM 定义了线程和主内存之间的抽象关系：线程之间的共享变量存储在主内存（Main Memory）中，每个线程都有一个私有的本地内存（Local Memory），本地内存中存储了该线程以读/写共享变量的副本。本地内存是JMM的一个抽象概念，并不真实存在。它涵盖了缓存、写缓冲区、寄存器以及其他的硬件和编译器优化。

### 3.1　Java内存模型的基础

在并发编程中，需要处理两个关键问题：线程之间如何通信及线程之间如何同步。在命令式编程中，线程之间的通信机制有两种：共享内存和消息传递。

1. 在共享内存的并发模型里，线程之间共享程序的公共状态，通过写-读内存中的公共状态进行隐式通信。
2. 在消息传递的并发模型里，线程之间没有公共状态，线程之间必须通过发送消息来显式进行通信。

Java的并发采用的是共享内存模型，Java线程之间的通信总是隐式进行，整个通信过程对程序员完全透明。

重排序分三种类型，这些重排序可能会导致多线程程序出现内存可见性问题。：

1. 编译器优化的重排序。编译器在不改变单线程程序语义的前提下，可以重新安排语句的执行顺序。
2. 指令级并行的重排序。如果不存在数据依赖性，处理器可以改变语句对应机器指令的执行顺序。
3. 内存系统的重排序。由于处理器使用缓存和读/写缓冲区，这使得加载和存储操作看上去可能是在乱序执行。

对于编译器，JMM的编译器重排序规则会禁止特定类型的编译器重排序（不是所有的编译器重排序都要禁止）。对于处理器重排序，JMM的处理器重排序规则会要求Java编译器在生成指令序列时，插入特定类型的内存屏障（Memory Barriers，Intel称之为Memory Fence）指令，通过内存屏障指令来禁止特定类型的处理器重排序。

常见的处理器都允许Store-Load重排序；

### 3.4　volatile的内存语义

基于保守策略的JMM内存屏障插入策略：

* 在每个volatile写操作的前面插入一个StoreStore屏障。
* 在每个volatile写操作的后面插入一个StoreLoad屏障。
* 在每个volatile读操作的后面插入一个LoadLoad屏障。
* 在每个volatile读操作的后面插入一个LoadStore屏障。

### 3.5　锁的内存语义

锁释放和锁获取的内存语义

* 线程A释放一个锁，实质上是线程A向接下来将要获取这个锁的某个线程发出了（线程A对共享变量所做修改的）消息。
* 线程B获取一个锁，实质上是线程B接收了之前某个线程发出的（在释放这个锁之前对共享变量所做修改的）消息。
* 线程A释放锁，随后线程B获取这个锁，这个过程实质上是线程A通过主内存向线程B发送消息。
