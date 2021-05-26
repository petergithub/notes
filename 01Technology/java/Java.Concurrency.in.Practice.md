# Java Concurrency in Practice

[Brian Goetz](http://jcip.net/)
[Code](https://jcip.net/listings.html)

Chapter 2 and 3 are useful

## TODO

同一个Executor 再次提交新任务发生死锁 确认代码 RenderPageTask

## 1 Chapter 1. Introduction

### 1.1. A (Very) Brief History of Concurrency

* Resource utilization.
* Fairness
* Convenience

### 1.2. Benefits of Threads

#### 1.2.1. Exploiting Multiple Processors

#### 1.2.2. Simplicity of Modeling

#### 1.2.3. Simplified Handling of Asynchronous Events

#### 1.2.4. More Responsive User Interfaces

### 1.3. Risks of Threads

#### 1.3.1. Safety Hazards

Figure 1.1. Unlucky Execution of UnsafeSequence.Nextvalue.

#### 1.3.2. Liveness Hazards 活跃性问题

While safety means "nothing bad ever happens", liveness concerns the complementary goal that "something good eventually happens".

死锁,饥饿,活锁

#### 1.3.3. Performance Hazards

### 1.4. Threads are Everywhere

## Part I: Fundamentals

## Chapter 2.  Thread Safety

If multiple threads access the same mutable state variable without appropriate synchronization, your program is broken. There are three ways to fix it:

* Don't share the state variable across threads;
* Make the state variable immutable; or
* Use synchronization whenever accessing the state variable.

### 2.1. What is Thread Safety?

A class is thread-safe if it behaves correctly when accessed from multiple threads, regardless of the scheduling or interleaving of the execution of those threads by the runtime environment, and with no additional synchronization or other coordination on the part of the calling code.

#### 2.1.1. Example: A Stateless Servlet

### 2.2. Atomicity

#### 2.2.1. Race Conditions

The most common type of race condition is check-then-act, where a potentially stale observation is used to make a decision on what to do next.

`AtomicLong`, `AtomicReference`

`synchronized`, *intrinsic locks* in Java act as mutexes (or mutual exclusion locks(互斥锁)), which means that at most one thread may own the lock.

intrinsic locks are *reentrant*

#### 2.2.2. Example: Race Conditions in Lazy Initialization

#### 2.2.3. Compound Actions

Listing 2.4. Servlet that Counts Requests Using AtomicLong.

### 2.3. Locking

To preserve state consistency, update related state variables in a single atomic operation.

#### 2.3.1. Intrinsic Locks

A synchronized block has two parts:

* a reference to an object that will serve as the lock, and
* a block of code to be guarded by that lock.

A synchronized method is a shorthand for a synchronized block that spans an entire method body, and whose lock is the object on which the method is being invoked. (Static synchronized methods use the Class object for the lock.)

```Java
synchronized (lock) {
    // Access or modify shared state guarded by lock
}
```

#### 2.3.2. Reentrancy

重入意味着获取锁操作的粒度是"线程",而不是"调用"
Reentrancy means that locks are acquired on a per-thread rather than per-invocation basis.

#### 2.4 Guarding State with Locks

If synchronization is used to coordinate access to a variable, it is **needed everywhere that variable is accessed**. Further, when using locks to coordinate access to a variable, the same lock must be used wherever that variable is accessed.

It is a common mistake to assume that synchronization needs to be used only when writing to shared variables; this is simply not true. (The reasons for this will become clearer in Section 3.1.)

For each mutable state variable that may be accessed by more than one thread, all accesses to that variable must be performed with the same lock held. In this case, we say that the variable is guarded by that lock.

#### 2.5. Liveness and Performance

Avoid holding locks during lengthy computations or operations at risk of not completing quickly such as network or console I/O.

## Chapter 3. Sharing Objects

Chapter 2 was about using synchronization to prevent multiple threads from accessing the same data at the same time; this chapter examines techniques for sharing and publishing objects so they can be safely accessed by multiple threads.

`synchronized`

1. it is about atomicity or demarcating "critical sections" (实现原子性和确定临界区)
2. another significant, and subtle aspect: memory visibility. (内存可见性)  
 We want not only to prevent one thread from modifying the state of an object when another is using it, but also to ensure that when a thread modifies the state of an object, other threads can actually see the changes that were made.

Locking is not just about **mutual exclusion**; it is also about memory visibility. To ensure that **all threads see the most up-to-date values of shared mutable variables**, the reading and writing threads must synchronize on a common lock.

### 3.1. Visibility

#### 3.1.1. Stale Data

#### 3.1.2. Nonatomic 64-bit Operations

#### 3.1.3. Locking and Visibility

#### 3.1.4. Volatile Variables

use volatile variables only when all the following criteria are met:  
• Writes to the variable do not depend on its current value, or you can ensure that only a single thread ever updates the value;
• The variable does not participate in invariants with other state variables; and
• Locking is not required for any other reason while the variable is being accessed.

### 3.2. Publication and Escape 发布和逸出

Listing 3.6. Allowing Internal Mutable State to Escape. Don't Do this.

Listing 3.7. Implicitly Allowing the this Reference to Escape. Don't Do this.

#### 3.2.1. Safe Construction Practices

Listing 3.8. Using a Factory Method to Prevent the this Reference from Escaping During Construction.

### 3.3. Thread Confinement

#### 3.3.1. Ad-hoc Thread Confinement

#### 3.3.2. Stack Confinement

#### 3.3.3. ThreadLocal

### 3.4. Immutability

Immutable objects are always thread-safe. An object is immutable if:

* Its state cannot be modifled after construction;
* All its flelds are final;[12] and
* It is properly constructed (the this reference does not escape during construction).

Listing 3.11. Immutable Class Built Out of Mutable Underlying Objects.

#### 3.4.1. Final Fields

#### 3.4.2. Example: Using Volatile to Publish Immutable Objects

### 3.5. Safe Publication

Listing 3.13. Caching the Last Result Using a Volatile Reference to an Immutable Holder Object.

#### 3.5.1. Improper Publication: When Good Objects Go Bad

#### 3.5.2. Immutable Objects and Initialization Safety

#### 3.5.3. Safe Publication Idioms

* To publish an object safely, both the reference to the object and the object's state must be made visible to other threads at the same time. A properly constructed object can be safely published by:
* Initializing an object reference from a static initializer;
* Storing a reference to it into a volatile field or AtomicReference;
* Storing a reference to it into a final field of a properly constructed object; or
* Storing a reference to it into a field that is properly guarded by a lock.

#### 3.5.4. Effectively Immutable Objects

Objects that are not technically immutable, but whose state will not be modified after publication, are called effectively immutable.

Safely published effectively immutable objects can be used safely by any thread without additional synchronization.

#### 3.5.5. Mutable Objects

The publication requirements for an object depend on its mutability:

* Immutable objects can be published through any mechanism;
* Effectively immutable objects must be safely published;
* Mutable objects must be safely published, and must be either threadsafe or guarded by a lock.

#### 3.5.6. Sharing Objects Safely

The most useful policies for using and sharing objects in a concurrent program are:

* Thread-confined. A thread-confined object is owned exclusively by and confined to one thread, and can be modifled by its owning thread.
* Shared read-only. A shared read-only object can be accessed concurrently by multiple threads without additional synchronization, but cannot be modified by any thread. Shared read-only objects include immutable and effectively immutable objects.
* Shared thread-safe. A thread-safe object performs synchronization internally, so multiple threads can freely access it through its public interface without further synchronization.
* Guarded. A guarded object can be accessed only with a specific lock held. Guarded objects include those that are encapsulated within other thread-safe objects and published objects that are known to be guarded by a specific lock.

## Chapter 4.  Composing Objects

### 4.1. Designing a Thread-safe Class

The design process for a thread-safe class should include these three basic elements:

* Identify the variables that form the object's state;
* Identify the invariants that constrain the state variables;
* Establish a policy for managing concurrent access to the object's state.

#### 4.1.1. Gathering Synchronization Requirements

#### 4.1.2. State-dependent Operations

#### 4.1.3. State Ownership

### 4.2. Instance Confinement

Encapsulating data within an object confines access to the data to the object's methods, making it easier to ensure that the data is always accessed with the appropriate lock held.

Confinement makes it easier to build thread-safe classes because a class that confines its state can be analyzed for thread safety without having to examine the whole program.

#### 4.2.1. The Java Monitor Pattern

An object following the Java monitor pattern encapsulates all its mutable state and guards it with the object's own intrinsic lock.

#### 4.2.2. Example: Tracking Fleet Vehicles

Listing 4.4. Monitor-based Vehicle Tracker Implementation.

### 4.3. Delegating Thread Safety

#### 4.3.1. Example: Vehicle Tracker Using Delegation

Listing 4.7. Delegating Thread Safety to a ConcurrentHashMap.

#### 4.3.2. Independent State Variables

#### 4.3.3. When Delegation Fails

#### 4.3.4. Publishing Underlying State Variables

If a state variable is thread-safe, does not participate in any invariants that constrain its value, and has no prohibited state transitions for any of its operations, then it can safely be published.

#### 4.3.5. Example: Vehicle Tracker that Publishes Its State

Listing 4.12. Vehicle Tracker that Safely Publishes Underlying State.

### 4.4. Adding Functionality to Existing Thread-safe Classes

Listing 4.13. Extending Vector to have a Put-if-absent Method.

#### 4.4.1. Client-side Locking

Listing 4.14. Non-thread-safe Attempt to Implement Put-if-absent. Don't Do this.

Listing 4.15. Implementing Put-if-absent with Client-side Locking.

#### 4.4.2. Composition

Listing 4.16. Implementing Put-if-absent Using Composition.

### 4.5. Documenting Synchronization Policies

Document a class's thread safety guarantees for its clients; document its synchonization policy for its maintainers.

#### 4.5.1. Interpreting Vague Documentation

## Chapter 5.  Building Blocks

### 5.1. Synchronized Collections

The synchronized collection classes include Vector and Hashtable, part of the original JDK, as well as their cousins added in JDK 1.2, the synchronized wrapper classes created by the Collections.synchronizedXxx factory methods

#### 5.1.1. Problems with Synchronized Collections

The synchronized collections are thread-safe, but you may sometimes need to use additional client-side locking to guard compound actions.

#### 5.1.2. Iterators and Concurrentmodificationexception

#### 5.1.3. Hidden Iterators

`toString` Listing 5.6. Iteration Hidden within String Concatenation. Don't Do this.

### 5.2. Concurrent Collections

Replacing synchronized collections with concurrent collections can offer dramatic scalability improvements with little risk.

#### 5.2.1. ConcurrentHashMap

#### 5.2.2. Additional Atomic Map Operations

#### 5.2.3. CopyOnWriteArrayList

### 5.3. Blocking Queues and the Producer-consumer Pattern

#### 5.3.1. Example: Desktop Search

#### 5.3.2. Serial Thread Confinement

#### 5.3.3. Deques and Work Stealing

Java 6 also adds another two collection types, `Deque` (pronounced "deck") and `BlockingDeque`, that extend `Queue` and `BlockingQueue`. A `Deque` is a doubleended queue that allows efficient insertion and removal from both the head and the tail. Implementations include `ArrayDeque` and `LinkedBlockingDeque`.

### 5.4. Blocking and Interruptible Methods

When a thread blocks, it is usually suspended and placed in one of the blocked thread states (`BLOCKED`, `WAITING`, or `TIMED_WAITING`)

When your code calls a method that throws InterruptedException, then your method is a blocking method too, and must have a plan for responding to interruption. For library code, there are basically two choices:

* Propagate the InterruptedException
* Restore the interrupt: `Thread.currentThread().interrupt();`

### 5.5. Synchronizers

A synchronizer is any object that coordinates the control flow of threads based on its state. Blocking queues can act as synchronizers; other types of synchronizers include semaphores, barriers, and latches.

#### 5.5.1. Latches

A latch is a synchronizer that can delay the progress of threads until it reaches its terminal state

#### 5.5.2. FutureTask

A computation represented by a FutureTask is implemented with a Callable, the result-bearing equivalent of Runnable, and can be in one of three states: waiting to run, running, or completed.

Listing 5.13. Coercing an Unchecked Throwable to a RuntimeException.

#### 5.5.3. Semaphores

Counting semaphores are used to control the number of activities that can access a certain resource or perform a given action at the same time.

#### 5.5.4. Barriers

### 5.6. Building an Efficient, Scalable Result Cache

Listing 5.16. Initial Cache Attempt Using HashMap and Synchronization.

Listing 5.17. Replacing HashMap with ConcurrentHashMap.

Listing 5.20. Factorizing Servlet that Caches Results Using Memoizer.

## Summary of Part I

We've covered a lot of material so far! The following "concurrency cheat sheet" summarizes the main concepts and rules presented in Part I.

* It's the mutable state, stupid. [1]

All concurrency issues boil down to coordinating access to mutable state. The less mutable state, the easier it is to ensure thread safety.

* Make fields final unless they need to be mutable.

* Immutable objects are automatically thread-safe.

* Encapsulation makes it practical to manage the complexity.

* Guard each mutable variable with a lock.

* Guard all variables in an invariant with the same lock.

* Hold locks for the duration of compound actions.

* A program that accesses a mutable variable from multiple threads without synchronization is a broken program.

* Don't rely on clever reasoning about why you don't need to synchronize.

* Include thread safety in the design processor explicitly document that your class is not thread-safe.

* Document your synchronization policy.

## Part II: Structuring Concurrent Applications

## Chapter 6. Task Execution

### 6.1. Executing Tasks in Threads

#### 6.1.1. Executing Tasks Sequentially

Listing 6.1. Sequential Web Server.

#### 6.1.2. Explicitly Creating Threads for Tasks

Listing 6.2. Web Server that Starts a New Thread for Each Request.

#### 6.1.3. Disadvantages of Unbounded Thread Creation

For production use, however, the thread-per-task approach has some practical drawbacks, especially when a large number of threads may be created:

* Thread lifecycle overhead.
* Resource consumption.
* Stability.

### 6.2. The Executor Framework

`Executor` is based on the producer-consumer pattern, where activities that submit tasks are the producers (producing units of work to be done) and the threads that execute tasks are the consumers (consuming those units of work).

#### 6.2.1. Example: Web Server Using Executor

Listing 6.4. Web Server Using a Thread Pool.

#### 6.2.2. Execution Policies

The value of decoupling submission from execution is that it lets you easily specify, and subsequently change without great difficulty, the execution policy for a given class of tasks. An execution policy specifies the "what, where, when, and how" of task execution, including:

* In what thread will tasks be executed?
* In what order should tasks be executed (FIFO, LIFO, priority order)?
* How many tasks may execute concurrently?
* How many tasks may be queued pending execution?
* If a task has to be rejected because the system is overloaded, which task should be selected as the victim, and how should the application be notified?
* What actions should be taken before or after executing a task?

#### 6.2.3. Thread Pools

newFixedThreadPool
newSingleThreadExecutor
newCachedThreadPool
newScheduledThreadPool

newWorkStealingPool

#### 6.2.4. Executor Lifecycle

Listing 6.7. Lifecycle Methods in `ExecutorService`.

#### 6.2.5. Delayed and Periodic Tasks

A `DelayQueue` manages a collection of Delayed objects. A Delayed has a delay time associated with it: DelayQueue lets you take an element only if its delay has expired.

### 6.3. Finding Exploitable Parallelism

#### 6.3.1. Example: Sequential Page Renderer

Listing 6.10. Rendering Page Elements Sequentially.

#### 6.3.2. Result-bearing Tasks: Callable and Future

#### 6.3.3. Example: Page Renderer with Future

Listing 6.13. Waiting for Image Download with `Future`.

#### 6.3.4. Limitations of Parallelizing Heterogeneous Tasks

#### 6.3.5. CompletionService: Executor Meets BlockingQueue

#### 6.3.6. Example: Page Renderer with CompletionService

Listing 6.15. Using `CompletionService` to Render Page Elements as they Become Available.

#### 6.3.7. Placing Time Limits on Tasks

#### 6.3.8. Example: A Travel Reservations Portal

## Chapter 7. Cancellation and Shutdown

### 7.1. Task Cancellation

#### 7.1.1. Interruption

#### 7.1.2. Interruption Policies

#### 7.1.3. Responding to Interruption

#### 7.1.4. Example: Timed Run

#### 7.1.5. Cancellation Via Future

#### 7.1.6. Dealing with Non-interruptible Blocking

* Synchronous socket I/O in java.io.
* Synchronous I/O in java.nio.
* Asynchronous I/O with Selector.
* Lock acquisition.

#### 7.1.7. Encapsulating Nonstandard Cancellation with Newtaskfor

### 7.2. Stopping a Thread-based Service

#### 7.2.1. Example: A Logging Service

#### 7.2.2. ExecutorService Shutdown

#### 7.2.3. Poison Pills

#### 7.2.4. Example: A One-shot Execution Service

#### 7.2.5. Limitations of Shutdownnow

### 7.3. Handling Abnormal Thread Termination

#### 7.3.1. Uncaught Exception Handlers

### 7.4. JVM Shutdown

#### 7.4.1. Shutdown Hooks

#### 7.4.2. Daemon Threads

#### 7.4.3. Finalizers

## Chapter 8.  Applying Thread Pools 线程池的使用

### 8.1. Implicit Couplings Between Tasks and Execution Policies

Types of tasks that require specific execution policies include:

* Dependent tasks.
* Tasks that exploit thread confinement.
* Response-time-sensitive tasks.
* Tasks that use ThreadLocal.

#### 8.1.1. Thread Starvation Deadlock

#### 8.1.2. Long-running Tasks

### 8.2. Sizing Thread Pools

### 8.3. Configuring ThreadPoolExecutor

#### 8.3.1. Thread Creation and Teardown

#### 8.3.2. Managing Queued Tasks

#### 8.3.3. Saturation Policies

Several implementations of RejectedExecutionHandler are provided, each implementing a different saturation policy: AbortPolicy, CallerRunsPolicy, DiscardPolicy, and DiscardOldestPolicy.

#### 8.3.4. Thread Factories

### 8.4. Extending ThreadPoolExecutor

ThreadPoolExecutor was designed for extension, providing several "hooks" for subclasses to override `beforeExecute`, `afterExecute`, and `terminate` that can be used to extend the behavior of `ThreadPoolExecutor`.

#### 8.4.1. Example: Adding Statistics to a Thread Pool

### 8.5. Parallelizing Recursive Algorithms

#### 8.5.1. Example: A Puzzle Framework

## Chapter 9.  GUI Applications

### 9.1. Why are GUIs Single-threaded?

### 9.2. Short-running GUI Tasks

### 9.3. Long-running GUI Tasks

### 9.4. Shared Data Models

### 9.5. Other Forms of Single-threaded Subsystems

## Part III: Liveness, Performance, and Testing

## Chapter 10.  Avoiding Liveness Hazards

### 10.1. Deadlock

#### 10.1.1. Lock-ordering Deadlocks

#### 10.1.2. Dynamic Lock Order Deadlocks

#### 10.1.3. Deadlocks Between Cooperating Objects

#### 10.1.4. Open Calls

Calling a method with no locks held is called an open call

#### 10.1.5. Resource Deadlocks

### 10.2. Avoiding and Diagnosing Deadlocks

#### 10.2.1. Timed Lock Attempts

#### 10.2.2. Deadlock Analysis with Thread Dumps

### 10.3. Other Liveness Hazards

#### 10.3.1. Starvation

Starvation occurs when a thread is perpetually denied access to resources it needs in order to make progress; the most commonly starved resource is CPU cycles. Starvation in Java applications can be caused by inappropriate use of thread priorities. It can also be caused by executing nonterminating constructs (infinite loops or resource waits that do not terminate) with a lock held, since other threads that need that lock will never be able to acquire it.

#### 10.3.2. Poor Responsiveness

#### 10.3.3. Livelock

Livelock is a form of liveness failure in which a thread, while not blocked, still cannot make progress because it keeps retrying an operation that will always fail. Livelock often occurs in transactional messaging applications, where the messaging infrastructure rolls back a transaction if a message cannot be processed successfully, and puts it back at the head of the queue.

## Chapter 11.  Performance and Scalability

First make your program right, then make it fast and then only if your performance requirements and measurements tell you it needs to be faster.

### 11.1. Thinking about Performance

Improving performance means doing more work with fewer resources. The meaning of "resources" can vary; for a given activity, some specific resource is usually in shortest supply, whether it is CPU cycles, memory, network bandwidth, I/O bandwidth, database requests, disk space, or any number of other resources.

#### 11.1.1. Performance Versus Scalability

#### 11.1.2. Evaluating Performance Tradeoffs

Most performance decisions involve multiple variables and are highly situational. Before deciding that one approach is "faster" than another, ask yourself some questions:

* What do you mean by "faster"?
* Under what conditions will this approach actually be faster? Under light or heavy load? With large or small data sets? Can you support your answer with measurements?
* How often are these conditions likely to arise in your situation? Can you support your answer with measurements?
* Is this code likely to be used in other situations where the conditions may be different?
* What hidden costs, such as increased development or maintenance risk, are you trading for this improved performance? Is this a good tradeoff?

### 11.2. Amdahl's Law

Amdahl's law describes how much a program can theoretically be sped up by additional computing resources, based on the proportion of parallelizable and serial components. If `F` is the fraction of the calculation that must be executed serially, then Amdahl's law says that on a machine with `N` processors, we can achieve a speedup of at most:

`Speedup ≤ 1 / (F + (1 - F) / N)`

As `N` approaches infinity, the maximum speedup converges to `1/F`, meaning that a program in which fifty percent of the processing must be executed serially can be sped up only by a factor of two, regardless of how many processors are available, and a program in which ten percent must be executed serially can be sped up by at most a factor of ten.

#### 11.2.1. Example: Serialization Hidden in Frameworks

#### 11.2.2. Applying Amdahl's Law Qualitatively

### 11.3. Costs Introduced by Threads

#### 11.3.1. Context Switching

Context switches are not free; thread scheduling requires manipulating shared data structures in the OS and JVM. The OS and JVMuse the same CPUs your program does; more CPU time spent in JVM and OS code means less is available for your program. But OS and JVM activity is not the only cost of context switches. When a new thread is switched in, the data it needs is unlikely to be in the local processor cache, so a context switch causes a flurry of cache misses, and thus threads run a little more slowly when they are first scheduled. This is one of the reasons that schedulers give each runnable thread a certain minimum time quantum even when many other threads are waiting: it amortizes the cost of the context switch and its consequences over more uninterrupted execution time, improving overall throughput (at some cost to responsiveness).

The `vmstat` command on Unix systems and the perfmon tool on Windows systems report the number of context switches and the percentage of time spent in the kernel. High kernel usage (over 10%) often indicates heavy scheduling activity, which may be caused by blocking due to I/O or lock contention.

#### 11.3.2. Memory Synchronization

The performance cost of synchronization comes from several sources. The visibility guarantees provided by `synchronized` and `volatile` may entail using special instructions called memory barriers that can flush or invalidate caches, flush hardware write buffers, and stall execution pipelines. Memory barriers may also have indirect performance consequences because they inhibit other compiler optimizations; most operations cannot be reordered with memory barriers.

#### 11.3.3. Blocking

Uncontended synchronization can be handled entirely within the JVM (Bacon et al., 1998); contended synchronization may require OS activity, which adds to the cost. When locking is contended, the losing thread(s) must block.

### 11.4. Reducing Lock Contention

There are three ways to reduce lock contention:

* Reduce the duration for which locks are held;
* Reduce the frequency with which locks are requested; or
* Replace exclusive locks with coordination mechanisms that permit greater concurrency.

#### 11.4.1. Narrowing Lock Scope ("Get in, Get Out")

#### 11.4.2. Reducing Lock Granularity

#### 11.4.3. Lock Striping

Splitting a heavily contended lock into two is likely to result in two heavily contended locks. While this will produce a small scalability improvement by enabling two threads to execute concurrently instead of one, it still does not dramatically improve prospects for concurrency on a system with many processors.

For example, the implementation of ConcurrentHashMap uses an array of 16 locks, each of which guards 1/16 of the hash buckets; bucket N is guarded by lock N mod 16.

#### 11.4.4. Avoiding Hot Fields

#### 11.4.5. Alternatives to Exclusive Locks

using the concurrent collections, read-write locks, immutable objects and atomic variables.

#### 11.4.6. Monitoring CPU Utilization

#### 11.4.7. Just Say No to Object Pooling

Allocating objects is usually cheaper than synchronizing.

### 11.5. Example: Comparing Map Performance

### 11.6. Reducing Context Switch Overhead

## Chapter 12.  Testing Concurrent Programs

### 12.1. Testing for Correctness

#### 12.1.1. Basic Unit Tests

#### 12.1.2. Testing Blocking Operations

#### 12.1.3. Testing Safety

#### 12.1.4. Testing Resource Management

#### 12.1.5. Using Callbacks

#### 12.1.6. Generating More Interleavings

### 12.2. Testing for Performance

#### 12.2.1. Extending PutTakeTest to Add Timing

#### 12.2.2. Comparing Multiple Algorithms

#### 12.2.3. Measuring Responsiveness

### 12.3. Avoiding Performance Testing Pitfalls

#### 12.3.1. Garbage Collection

#### 12.3.2. Dynamic Compilation

#### 12.3.3. Unrealistic Sampling of Code Paths

#### 12.3.4. Unrealistic Degrees of Contention

#### 12.3.5. Dead Code Elimination

### 12.4. Complementary Testing Approaches

#### 12.4.1. Code Review

#### 12.4.2. Static Analysis Tools

#### 12.4.3. Aspect-oriented Testing Techniques

#### 12.4.4. Profilers and Monitoring Tools

## Part IV: Advanced Topics

## Chapter 13.  Explicit Locks

### 13.1. Lock and ReentrantLock

#### 13.1.1. Polled and Timed Lock Acquisition

#### 13.1.2. Interruptible Lock Acquisition

#### 13.1.3. Non-block-structured Locking

### 13.2. Performance Considerations

Performance is a moving target; yesterday's benchmark showing that X is faster than Y may already be out of date today.

### 13.3. Fairness

The ReentrantLock constructor offers a choice of two fairness options: create a nonfair lock (the default) or a fair lock.

### 13.4. Choosing Between Synchronized and ReentrantLock

### 13.5. Read-write Locks

## Chapter 14.  Building Custom Synchronizers

### 14.1. Managing State Dependence

#### 14.1.1. Example: Propagating Precondition Failure to Callers

#### 14.1.2. Example: Crude Blocking by Polling and Sleeping

#### 14.1.3. Condition Queues to the Rescue

### 14.2. Using Condition Queues

#### 14.2.1. The Condition Predicate

#### 14.2.2. Waking Up Too Soon

#### 14.2.3. Missed Signals

#### 14.2.4. Notification

Whenever you wait on a condition, make sure that someone will perform a notification whenever the condition predicate becomes true.

There are two notification methods in the condition queue APInotify and notifyAll.

#### 14.2.5. Example: A Gate Class

#### 14.2.6. Subclass Safety Issues

#### 14.2.7. Encapsulating Condition Queues

#### 14.2.8. Entry and Exit Protocols

### 14.3. Explicit Condition Objects

Hazard warning: The equivalents of `wait`, `notify`, and `notifyAll` for Condition objects are `await`, `signal`, and `signalAll`. However, Condition extends Object, which means that it also has `wait` and `notify` methods. Be sure to use the proper versions `await` and `signal` instead!

### 14.4. Anatomy of a Synchronizer

### 14.5. AbstractQueuedSynchronizer

#### 14.5.1. A Simple Latch

### 14.6. AQS in Java.util.concurrent Synchronizer Classes

#### 14.6.1. ReentrantLock

#### 14.6.2. Semaphore and CountDownLatch

#### 14.6.3. FutureTask

#### 14.6.4. ReentrantReadWriteLock

## Chapter 15.  Atomic Variables and Nonblocking Synchronization

### 15.1. Disadvantages of Locking

### 15.2. Hardware Support for Concurrency

#### 15.2.1. Compare and Swap

#### 15.2.2. A Nonblocking Counter

#### 15.2.3. CAS Support in the JVM

### 15.3. Atomic Variable Classes

#### 15.3.1. Atomics as "Better Volatiles"

#### 15.3.2. Performance Comparison: Locks Versus Atomic Variables

### 15.4. Nonblocking Algorithms

#### 15.4.1. A Nonblocking Stack

#### 15.4.2. A Nonblocking Linked List

#### 15.4.3. Atomic Field Updaters

#### 15.4.4. The ABA Problem

## Chapter 16.  The Java Memory Model

### 16.1. What is a Memory Model, and Why would I Want One?

#### 16.1.1. Platform Memory Models

#### 16.1.2. Reordering

#### 16.1.3. The Java Memory Model in 500 Words or Less

The Java Memory Model is specified in terms of actions, which include reads and writes to variables, locks and unlocks of monitors, and starting and joining with threads. The JMM defines a partial ordering [2] called happens-before on all actions within the program.

The rules for happens-before are:

* Program order rule.
* Monitor lock rule.
* Volatile variable rule.
* Thread start rule.
* Thread termination rule.
* Interruption rule.
* Finalizer rule.
* Transitivity.

#### 16.1.4. Piggybacking on Synchronization

### 16.2. Publication

#### 16.2.1. Unsafe Publication

#### 16.2.2. Safe Publication

#### 16.2.3. Safe Initialization Idioms

#### 16.2.4. Double-checked Locking

### 16.3. Initialization Safety
