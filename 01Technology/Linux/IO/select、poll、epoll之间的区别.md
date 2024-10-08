# select、poll、epoll之间的区别

[epoll和select的区别](https://blog.csdn.net/jiange_zh/article/details/50811553)
[你管这破玩意叫 IO 多路复用？- 无聊的闪客](https://mp.weixin.qq.com/s/YdIdoZ_yusVWza1PU7lWaw)

Advanced Programming in the UNIX® Environment 3rd Edition, Chapter 14 Advanced I/O, 14.4 I/O Multiplexing

select，poll，epoll都是IO多路复用的机制。I/O多路复用就通过一种机制，可以监视多个描述符，一旦某个描述符就绪（一般是读就绪或者写就绪），能够通知程序进行相应的读写操作。

但select，poll，epoll本质上都是同步I/O，因为他们都需要在读写事件就绪后自己负责进行读写，也就是说这个读写过程是阻塞的，而异步I/O则无需自己负责进行读写，异步I/O的实现会负责把数据从内核拷贝到用户空间。

## select原理 时间复杂度O(n)

int select(int maxfdp1, fd_set *restrict readfds,
    fd_set *restrict writefds, fd_set *restrict exceptfds, struct timeval *restrict tvptr);
        Returns: count of ready descriptors, 0 on timeout, −1 on error

调用select时，会发生以下事情：

1. 从用户空间拷贝fd_set到内核空间；
2. 注册回调函数__pollwait；
3. 遍历所有fd，对全部指定设备做一次poll（这里的poll是一个文件操作，它有两个参数，一个是文件fd本身，一个是当设备尚未就绪时调用的回调函数__pollwait，这个函数把设备自己特有的等待队列传给内核，让内核把当前的进程挂载到其中）；
4. 当设备就绪时，设备就会唤醒在自己特有等待队列中的【所有】节点，于是当前进程就获取到了完成的信号。poll文件操作返回的是一组标准的掩码，其中的各个位指示当前的不同的就绪状态（全0为没有任何事件触发），根据mask可对fd_set赋值；
5. 如果所有设备返回的掩码都没有显示任何的事件触发，就去掉回调函数的函数指针，进入有限时的睡眠状态，再恢复和不断做poll，再作有限时的睡眠，直到其中一个设备有事件触发为止。
6. 只要有事件触发，系统调用返回，将fd_set从内核空间拷贝到用户空间，回到用户态，用户就可以对相关的fd作进一步的读或者写操作了。

[epoll和select的区别](https://blog.csdn.net/jiange_zh/article/details/50811553)

## poll实现 时间复杂度O(n)

int poll(struct pollfd fdarray[], nfds_t nfds, int timeout);
    Returns: count of ready descriptors, 0 on timeout, −1 on error

poll的实现和select非常相似，只是描述fd集合的方式不同，poll使用pollfd结构而不是select的fd_set结构，其他的都差不多。

它没有最大连接数的限制，原因是它是基于链表来存储的

[IO多路复用之poll总结 - Rabbit_Dale - 博客园](https://www.cnblogs.com/Anker/archive/2013/08/15/3261006.html)

## epoll原理 时间复杂度O(1)

epoll可以理解为event poll，不同于忙轮询和无差别轮询，epoll会把哪个流发生了怎样的I/O事件通知我们。所以我们说epoll实际上是事件驱动（每个事件关联上fd）的。

调用epoll_create时，做了以下事情：

1. 内核帮我们在epoll文件系统里建了个file结点；
2. 在内核cache里建了个红黑树用于存储以后epoll_ctl传来的socket；
3. 建立一个list链表，用于存储准备就绪的事件。

调用epoll_ctl时，做了以下事情：

1. 把socket放到epoll文件系统里file对象对应的红黑树上；
2. 给内核中断处理程序注册一个回调函数，告诉内核，如果这个句柄的中断到了，就把它放到准备就绪list链表里。

调用epoll_wait时，做了以下事情：

观察list链表里有没有数据。有数据就返回，没有数据就sleep，等到timeout时间到后即使链表没数据也返回。而且，通常情况下即使我们要监控百万计的句柄，大多一次也只返回很少量的准备就绪句柄而已，所以，epoll_wait仅需要从内核态copy少量的句柄到用户态而已。

总结如下：

一颗红黑树，一张准备就绪句柄链表，少量的内核cache，解决了大并发下的socket处理问题。

* 执行epoll_create时，创建了红黑树和就绪链表；
* 执行epoll_ctl时，如果增加socket句柄，则检查在红黑树中是否存在，存在立即返回，不存在则添加到树干上，然后向内核注册回调函数，用于当中断事件来临时向准备就绪链表中插入数据;
* 执行epoll_wait时立刻返回准备就绪链表里的数据即可。

epoll对文件描述符的操作有两种模式：LT（level trigger）和ET（edge trigger）。LT模式是默认模式。两种模式的区别：

LT模式下，只要一个句柄上的事件一次没有处理完，会在以后调用epoll_wait时重复返回这个句柄，而ET模式仅在第一次返回。

[IO多路复用之epoll总结 - Rabbit_Dale - 博客园](https://www.cnblogs.com/Anker/archive/2013/08/17/3263780.html)

## 对比

### select缺点

1. 最大并发数限制：使用32个整数的32位，即32*32=1024来标识fd，虽然可修改，但是有以下第二点的瓶颈；
2. 效率低：每次都会线性扫描整个fd_set，集合越大速度越慢；
3. 内核/用户空间内存拷贝问题。

### epoll的提升

1. 本身没有最大并发连接的限制，仅受系统中进程能打开的最大文件数目限制；
2. 效率提升：只有活跃的socket才会主动的去调用callback函数；
3. 省去不必要的内存拷贝：epoll通过内核与用户空间mmap同一块内存实现。

当然，以上的优缺点仅仅是特定场景下的情况：高并发，且任一时间只有少数socket是活跃的。

如果在并发量低，socket都比较活跃的情况下，select就不见得比epoll慢了（就像我们常常说快排比插入排序快，但是在特定情况下这并不成立）。

## 发展历史

[select、poll、epoll之间的区别总结[整理] + 知乎大神解答_qq546770908的专栏-CSDN博客](https://blog.csdn.net/qq546770908/article/details/53082870)

select, poll, epoll 都是I/O多路复用的具体的实现，之所以有这三个鬼存在，其实是他们出现是有先后顺序的。

I/O多路复用这个概念被提出来以后， select是第一个实现 (1983 左右在BSD里面实现的)。select 被实现以后，很快就暴露出了很多问题。

1997年, 实现了poll, poll 修复了select的很多问题。

2002年, 大神 Davide Libenzi 实现了epoll.
