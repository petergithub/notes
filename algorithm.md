# Algorithm Notes

[TOC]

## 一致性哈希算法 Consistent hashing

[每天进步一点点——五分钟理解一致性哈希算法(consistent hashing)](http://blog.csdn.net/cywosp/article/details/23397179)

### Properties

* 分散性 spread
* 负载 load
* smoothness
* 平衡性 balance
* 单调性 monotonicity

### Step

1. 环形Hash空间
	按照常用的hash算法来将对应的key哈希到一个具有2^32次方个桶的空间中，即0~(2^32)-1的数字空间中。现在我们可以将这些数字头尾相连，想象成一个闭合的环形
2. 把数据通过一定的hash算法处理后映射到环上
	将object1、object2、object3、object4四个对象通过特定的Hash函数计算出对应的key值，然后散列到Hash环上
3. 将机器通过hash算法映射到环上
	在采用一致性哈希算法的分布式集群中将新的机器加入，其原理是通过使用与对象存储一样的Hash算法将机器也映射到环中(一般情况下对机器的hash计算是采用机器的IP或者机器唯一的别名作为输入值)，然后以顺时针的方向计算，将所有对象存储到离自己最近的机器中。
4. 机器的删除与添加  按照顺时针迁移的方法移动数据
 4.1 节点(机器)的删除
 4.2 节点(机器)的添加
5. 平衡性
	引入虚拟节点(virtual node)是实际节点(机器)在 hash 空间的复制品(replica)，一实际个节点(机器)对应了若干个“虚拟节点”，这个对应个数也成为“复制个数”，“虚拟节点”在 hash 空间中以hash值排列。
