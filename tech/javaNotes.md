[TOC]

# Java Notes

## Recent
对象的内置锁?
每个对象都有一个内置锁?
`java.util.concurrent.CopyOnWriteArrayList`
`AtomicInteger`底层实现机制

concurrent: 主内存.寄存器是是运行时?

## JVM
深入理解Java虚拟机-JVM高级特性与最佳实践 周志明

### 内存区域分析
运行时数据区分两部分
所有线程共享: 方法区(Method Area), 堆(Heap)
线程隔离:		虚拟机栈(JVM Stack), 本地方法栈(Native Method Stack), 程序计数器(Program Counter Register)

Java堆:		存放对象实例
方法区:		存储被虚拟机加载的类信息,常量,静态变量等.
程序计数器: 	当前线程所执行的字节码行号指示器,线程切换时可以快速切换位置
			当前执行的如果是 1.Java方法,则保存虚拟机字节码指令地址; 2,Native方法,为空(Undefined)
虚拟机栈: 	创建栈桢用于存储局部变量表,操作数栈,动态链接,方法出口等信息. 局部变量表
本地方法栈:	同虚拟机栈

### 垃圾收集器
#### 判断对象是否在使用
##### 引用计数算法 Reference Counting
##### 可达性分析算法 Reachability Analysis

#### 垃圾收集算法
##### 标记-清除算法 Mark-Sweep
##### 复制算法 Copying
##### 标记整理算法 Mark-Compact
##### 分代收集 Generational Collection

### 第七章 虚拟机类加载机制
7个阶段: 
加载 Loading,  
验证 Verification,准备 Preparation,解析 Resolution,  
初始化 Initialization,使用 Using,卸载 Unloading

其中,验证,准备,解析三个部分称为连接Linking

## Concurrency

synchronization:
1. Mutual Exclusion or Atomic or Critical Section临界区
2. Memory Visibility
同步: 原子性Atomic,内存可见性
重排序Reordering, Happens-Before	排序

易错情形:
竞态条件Race Condition
读取-修改-写入read-modify-write
先检查后执行操作Check-Then-Act

### ThreadLocal
是local variable（线程局部变量）。
就是为每一个使用该变量的线程都提供一个变量值的副本，是每一个线程都可以独立地改变自己的副本，而不会和其它线程的副本冲突。从线程的角度看，就好像每一个线程都完全拥有该变量。

使用场景：
To keep state with a thread (user-id, transaction-id, logging-id)
To cache objects which you need frequently

主要由四个方法组成initialValue()，get()，set(T)，remove()，其中值得注意的是initialValue()，该方法是一个protected的方法，显然是为了子类重写而特意实现的。该方法返回当前线程在该线程局部变量的初始值，这个方法是一个延迟调用方法，在一个线程第1次调用get()或者set(Object)时才执行，并且仅执行1次。ThreadLocal中的实现直接返回一个null。

### java.util.concurrent.locks类结构
基于AQS(AbstractQueuedSynchronizer) 构建的Synchronizer包括ReentrantLock,Semaphore,CountDownLatch, ReetrantRead WriteLock,FutureTask等，这些Synchronizer实际上最基本的东西就是原子状态的获取和释放，只是条件不一样而已。

**ReentrantLock**：需要记录当前线程获取原子状态的次数，如果次数为零，那么就说明这个线程放弃了锁（也有可能其他线程占据着锁从而需要等待），如果次数大于1，也就是获得了重进入的效果，而其他线程只能被park住，直到这个线程重进入锁次数变成0而释放原子状态

**Semaphore**：则是要记录当前还有多少次许可可以使用，到0，就需要等待，也就实现并发量的控制，Semaphore一开始设置许可数为1，实际上就是一把互斥锁

**CountDownLatch**：闭锁则要保持其状态，在这个状态到达终止态之前，所有线程都会被park住，闭锁可以设定初始值，这个值的含义就是这个闭锁需要被countDown()几次，因为每次CountDown是sync.releaseShared(1),而一开始初始值为10的话，那么这个闭锁需要被countDown()十次，才能够将这个初始值减到0，从而释放原子状态，让等待的所有线程通过。

**FutureTask**：需要记录任务的执行状态，当调用其实例的get方法时,内部类Sync会去调用AQS的acquireSharedInterruptibly()方法，而这个方法会反向调用Sync实现的tryAcquireShared()方法，即让具体实现类决定是否让当前线程继续还是park,而FutureTask的tryAcquireShared方法所做的唯一事情就是检查状态，如果是RUNNING状态那么让当前线程park。而跑任务的线程会在任务结束时调用FutureTask 实例的set方法（与等待线程持相同的实例），设定执行结果，并且通过unpark唤醒正在等待的线程，返回结果。

### Java高级-多线程机制详解
#### 二、线程的运行机制
4. 阻塞状态

(1) JVM将CPU资源从当前线程切换给其他线程，使本线程让出CPU的使用权，并处于挂起状态。
(2) 线程使用CPU资源期间，执行了sleep(int millsecond)方法，使当前线程进入休眠状态。sleep(int millsecond)方法是Thread类中的一个类方法，线程执行该方法就立刻让出CPU使用权，进入挂起状态。经过参数millsecond指定的毫秒数之后，该线程就重新进到线程队列中排队等待CPU资源，然后从中断处继续运行。
(3) 线程使用CPU资源期间，执行了wait()方法，使得当前线程进入等待状态。等待状态的线程不会主动进入线程队列等待CPU资源，必须由其他线程调用notify()方法通知它，才能让该线程从新进入到线程队列中排队等待CPU资源，以便从中断处继续运行。
(4) 线程使用CPU资源期间，执行某个操作进入阻塞状态，如执行读/写操作引起阻塞。进入阻塞状态时线程不能进入线程队列，只有引起阻塞的原因消除时，线程才能进入到线程队列排队等待CPU资源，以便从中断处继续运行。

#### 三、线程调度模型与优先级

JVM的线程调度器负责管理线程，调度器把线程的优先级分为10个级别，分别用Thread类中的类常量表示。每个Java线程的优先级都在常数1-10之间。Thread类优先级常量有三个：

``` java

    static int MIN_PRIORITY  //1
    static int NORM_PRIORITY //5
    static int MAX_PRIORITY  //10
```

如果没有明确设置，默认线程优先级为常数5即Thread.NORM_PRIORITY。

#### 五、Java线程同步

1. 要处理线程同步，可以把修改数据的方法用关键字synchronized修饰。一个方法使用synchronized修饰，当一个线程A使用这个方法时，其他线程想使用该方法时就必须等待，直到线程A使用完该方法。所谓同步就是多个线程都需要使用一个synchronized修饰的方法。

 * 当两个并发线程访问同一个对象object中的这个synchronized(this)同步代码块时，一个时间内只能有一个线程得到执行。另一个线程必须等待当前线程执行完这个代码块以后才能执行该代码块。
 * 当一个线程访问object的一个synchronized(this)同步代码块时，另一个线程仍然可以访问该object中的非synchronized(this)同步代码块。
 * 当一个线程访问object的一个synchronized(this)同步代码块时，其他线程对object中所有其它synchronized(this)同步代码块的访问将被阻塞。
 * 当一个线程访问object的一个synchronized(this)同步代码块时，它就获得了这个object的对象锁。结果，其它线程对该object对象所有同步代码部分的访问都被暂时阻塞。

第一点：synchronized用来标识一个普通方法时，表示一个线程要执行该方法，必须取得该方法所在的对象的锁。
第二点：synchronized用来标识一个静态方法时，表示一个线程要执行该方法，必须获得该方法所在的类的类锁。
第三点：synchronized修饰一个代码块。类似这样：synchronized(obj) { //code.... }。表示一个线程要执行该代码块，必须获得obj的锁。这样做的目的是减小锁的粒度，保证当不同块所需的锁不冲突时不用对整个对象加锁。利用零长度的byte数组对象做obj非常经济。

2. volatile比同步简单，只适合于控制对基本变量(整数、布尔变量等)的单个实例的访问。java中的volatile关键字与C++中一样，用volatile修饰的变量在读写操作时不会进行优化(取cache里的值以提高io速度)，而是直接对主存进行操作，这表示所有线程在任何时候看到的volatile变量值都相同。

3. 在同步方法中使用wait()、notify()、notifyAll()方法：
当一个线程使用的同步方法中用到某个变量，而此变量又需要其他线程修改后才能符合本线程需要，那么可以在同步方法中使用wait()方法。中断方法的执行，使本线程等待，暂时让出CPU资源，并允许其他线程使用这个同步方法。其他线程如果在使用这个同步方法时不需要等待，那么它使用完这个同步方法时应当用notifyAll()方法通知所有由于使用这个同步方法而处于等待的线程结束等待。曾中断的线程就会从中断处继续执行，并遵循"先中断先继续"的原则。如果用的notify()方法，那么只是通知等待中的线程中某一个结束等待。

### Java Concurrency in Practice
Chapter 2 and 3 are useful

#### 1.3.2 活跃性问题
死锁,饥饿,活锁

The most common type of race condition is check-then-act, where a potentially stale observation is used to make a decision on what to do next.

`AtomicLong`, `AtomicReference`

`synchronized`, *intrinsic locks* in Java act as mutexes (or mutual exclusion locks(互斥锁)), which means that at most one thread may own the lock.

intrinsic locks are *reentrant*

#### Chapter 2. Thread Safety

##### 2.3.2. Reentrancy
重入意味着获取锁操作的粒度是"线程",而不是"调用"
Reentrancy means that locks are acquired on a per-thread rather than per-invocation basis.

##### 2.4 Guarding State with Locks
if synchronization is used to coordinate access to a variable, it is **needed everywhere that variable is accessed**. Further, when using locks to coordinate access to a variable, the same lock must be used wherever that variable is accessed.  
It is a common mistake to assume that synchronization needs to be used only when writing to
shared variables; this is simply not true. (The reasons for this will become clearer in Section 3.1.)

#### Chapter 3. Sharing Objects
##### synchronized
1. it is about atomicity or demarcating "critical sections" (实现原子性和确定临界区)
2. another significant, and subtle aspect: memory visibility. (内存可见性)
We want not only to prevent one thread from modifying the state of an object when another is using it, but also to ensure that when a thread modifies the state of an object, other threads can actually see the changes that were made.

Locking is not just about **mutual exclusion**; it is also about memory visibility. To ensure that **all threads see the most up-to-date values of shared mutable variables**, the reading and writing threads must synchronize on a common lock.

##### volatile P32
use volatile variables only when all the following criteria are met:
• Writes to the variable do not depend on its current value, or you can ensure that only a single thread ever updates the value;
• The variable does not participate in invariants with other state variables; and
• Locking is not required for any other reason while the variable is being accessed.

3.3 发布和逸出?

### Java™ Tutorials 

#### Pausing Execution with `sleep`
`Thread.sleep` causes the current thread to suspend execution for a specified period

#### Interrupts
An interrupt is an indication to a thread that it should stop what it is doing and do something else

#### Joins
The join method allows one thread to wait for the completion of another. If `t` is a `Thread` object whose thread is currently executing, `t.join();` causes the current thread to pause execution until t's thread terminates.

#### `wait`
Always invoke wait inside a loop that tests for the condition being waited for. Don't assume that the interrupt was for the particular condition you were waiting for, or that the condition is still true. 

Item 50 "Never invoke wait outside a loop" in Joshua Bloch's "Effective Java Programming Language Guide" (Addison-Wesley, 2001).

该方法属于Object的方法，wait方法的作用是**使当前调用wait方法所在部分（代码块）的线程**停止执行，并释放当前获得的调用wait所在的代码块的锁，并在其他线程调用notify或者notifyAll方法时恢复到竞争锁状态（一旦获得锁就恢复执行）。 

#### Concurrent Collections
`BlockingQueue`, `ConcurrentMap`, `ConcurrentHashMap`, `ConcurrentNavigableMap`, `ConcurrentSkipListMap`

#### Atomic Variables
`AtomicInteger`