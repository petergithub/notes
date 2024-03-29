# Java并发编程的艺术

方腾飞　魏鹏　程晓明　著

## 第2章　Java并发机制的底层实现原理

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

## 第3章　Java内存模型

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
