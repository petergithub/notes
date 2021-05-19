# Java Concurrency in Practice

[Brian Goetz](http://jcip.net/)
[Code](https://jcip.net/listings.html)

Chapter 2 and 3 are useful

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

A synchronized block has two parts: a reference to an object that will serve as the lock, and a block of code to be guarded by that lock. A synchronized method is a shorthand for a synchronized block that spans an entire method body, and whose lock is the object on which the method is being invoked. (Static synchronized methods use the Class object for the lock.)

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

#### synchronized

1. it is about atomicity or demarcating "critical sections" (实现原子性和确定临界区)
2. another significant, and subtle aspect: memory visibility. (内存可见性)  
 We want not only to prevent one thread from modifying the state of an object when another is using it, but also to ensure that when a thread modifies the state of an object, other threads can actually see the changes that were made.

Locking is not just about **mutual exclusion**; it is also about memory visibility. To ensure that **all threads see the most up-to-date values of shared mutable variables**, the reading and writing threads must synchronize on a common lock.

#### volatile P32

use volatile variables only when all the following criteria are met:  
• Writes to the variable do not depend on its current value, or you can ensure that only a single thread ever updates the value;
• The variable does not participate in invariants with other state variables; and
• Locking is not required for any other reason while the variable is being accessed.

3.3 发布和逸出?

## Chapter 4.  Composing Objects

## Chapter 5.  Building Blocks

### Chapter 8 线程池的使用

newFixedThreadPool
newSingleThreadExecutor
newCachedThreadPool
newScheduledThreadPool

newWorkStealingPool