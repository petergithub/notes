# Redis Notes

[TOC]

## Question

Redisson是架设在Redis基础上的一个Java驻内存数据网格（In-Memory Data Grid）。充分的利用了Redis键值数据库提供的一系列优势，基于Java实用工具包中常用接口，为使用者提供了一系列具有分布式特性的常用工具类。使得原本作为协调单机多线程并发程序的工具包获得了协调分布式多机多线程并发系统的能力，大大降低了设计和研发大规模分布式系统的难度。同时结合各富特色的分布式服务，更进一步简化了分布式环境中程序相互之间的协作。
https://github.com/redisson/redisson/wiki/Redisson%E9%A1%B9%E7%9B%AE%E4%BB%8B%E7%BB%8D

### List

1、Redis单线程为什么还高性能？NIO多路复用知道吗
2、Redis底层ZSet跳表是如何设计与实现的
3、Redis底层ZSet实现压缩列表和跳表如何选择
4、Redis高并发场景热点缓存如何重建
5、高并发场景缓存穿透&失效&雪崩如何解决
6、Redis集群架构如何抗住双十一的洪峰流量
7、Redis缓存与数据库双写不一致如何解决
8、Redis分布式锁主从架构锁失效问题如何解决
9、从CAP角度解释下Redis&Zookeeper锁架构异同
10、超大并发的分布式锁架构该如何设计
11、双十一亿级用户日活统计如何用Redis快速计算
12、双十一电商推荐系统如何用Redis实现
13、双十一电商购物车系统如何用Redis实现
14、类似微信的社交App朋友圈关注模型如何设计实现
15、美团单车如何基于Redis快速找到附近的车
16、Redis 6.0 多线程模型比单线程优化在哪里了

Redis高并发架构设计与源码剖析课程内容：
一
双十一秒杀系统后端Redis高并发架构实战
1、高并发场景秒杀下单超卖Bug实战重现
2、秒杀场景下实战JVM级别锁与分布式锁
3、大厂分布式锁Redisson框架实战
4、从Redisson源码剖析lua解决锁的原子性问题
5、Redis主从架构锁失效问题及Redlock详解
6、双十一大促如何将分布式锁性能提升100倍
7、利用Redis缓存集群架构抗住双十一大流量洪峰
8、从CAP角度剖析Redis&Zookeeper锁架构异同
9、Redis缓存与数据库双写不一致终极解决

二
亿级流量新浪微博与微信Redis架构实战
1、Redis核心数据存储结构精讲
2、Redis底层string编码int&embstr&raw详解
3、Redis底层压缩列表&跳表&哈希表详解
4、Redis底层ZSet实现压缩列表和跳表如何选择
5、微博与微信消息流Redis实现
6、微信点赞、收藏与标签基于Redis实现
7、微博与微信朋友关注模型基于Redis实现
8、微博附近的人基于Redis实现
9、电商购物车如何用Redis实现
10、电商推荐系统如何用Redis实现

三
深入底层C源码讲透Redis高性能数据结构
1、Redis核心数据结构精讲
2、亿级用户日活统计BitMap实战
3、Redis阻塞队列底层实现原理剖析
4、如何实现一个高性能的延迟队列
5、基于Geohash实现查找附近的人
6、深入C源码剖析剖析ZSet底层跳表实现
7、深入C源码剖析Redis核心数据结构设计
8、Redis 6.0 多线程相比单线程优化了啥

## Recent

通过系统当前时间-lru时间，得到键多久没有被访问的秒数: `object idletime <key>`. object idletime命令访问键时，不会改变键的lru属性，即不会影响键的访问时间
通过`info stats`的`expired_keys`指标记录累计删除的过期键数量

`info keyspace` 的 `expires` 表名设置了过期时间的 key 的数量
`db3:keys=52,expires=52,avg_ttl=1735032446`
EvictedKeys 因内存满而淘汰的key总数

`redis-cli -h host -p 6379 -n 2 --raw` 展示中文

## Performance

Redis单机qps（每秒的并发）可以达到110000次/s，写的速度是81000次/s。

### Redis 变慢问题的 Checklist

[Redis 变慢问题的 Checklist](https://time.geekbang.org/column/article/dbfab3b1b37b27e980756e0b2042186a/share?code=B4DpWbLTTWwh2J-qoenyDrjUMJmEMYzFjIA5fd%2FVh4c%3D&source=app_share&oss_token=33f0026d90c6e4c7)

摘自 [Redis 核心技术与实战 - 蒋德钧](https://time.geekbang.org/column/intro/100056701)

遇到 Redis 性能变慢时，按照这些步骤逐一检查，高效地解决问题。

1. 获取 Redis 实例在当前环境下的基线性能。
2. 是否用了慢查询命令？如果是的话，就使用其他命令替代慢查询命令，或者把聚合计算命令放在客户端做。
3. 是否对过期 key 设置了相同的过期时间？对于批量删除的 key，可以在每个 key 的过期时间上加一个随机数，避免同时删除。
4. 是否存在 bigkey？ 对于 bigkey 的删除操作，如果你的 Redis 是 4.0 及以上的版本，可以直接利用异步线程机制减少主线程阻塞；如果是 Redis 4.0 以前的版本，可以使用 SCAN 命令迭代删除；对于 bigkey 的集合查询和聚合操作，可以使用 SCAN 命令在客户端完成。
5. Redis AOF 配置级别是什么？业务层面是否的确需要这一可靠性级别？如果我们需要高性能，同时也允许数据丢失，可以将配置项 no-appendfsync-on-rewrite 设置为 yes，避免 AOF 重写和 fsync 竞争磁盘 IO 资源，导致 Redis 延迟增加。当然， 如果既需要高性能又需要高可靠性，最好使用高速固态盘作为 AOF 日志的写入盘。
6. 当 Redis 实例的数据量大时，无论是生成 RDB，还是 AOF 重写，都会导致 fork 耗时严重
7. Redis 实例的内存使用是否过大？发生 swap 了吗？如果是的话，就增加机器内存，或者是使用 Redis 集群，分摊单机 Redis 的键值对数量和内存压力。同时，要避免出现 Redis 和其他内存需求大的应用共享机器的情况。
8. 在 Redis 实例的运行环境中，是否启用了透明大页机制？如果是的话，直接关闭内存大页机制就行了。
9. 是否运行了 Redis 主从集群？如果是的话，把主库实例的数据量大小控制在 2~4GB，以免主从复制时，从库因加载大的 RDB 文件而阻塞。
10. 是否使用了多核 CPU 或 NUMA 架构的机器运行 Redis 实例？使用多核 CPU 时，可以给 Redis 实例绑定物理核；使用 NUMA 架构时，注意把 Redis 实例和网络中断处理程序运行在同一个 CPU Socket 上。
11. 网卡压力过大。分析：a) TCP/IP层延迟变大，丢包重传变多 b) 是否存在流量过大的实例占满带宽。解决：a) 机器网络资源监控，负载过高及时报警 b) 提前规划部署策略，访问量大的实例隔离部署

### Redis常用的删除策略有以下三种

[Key eviction | Redis](https://redis.io/docs/reference/eviction/#eviction-policies)

* 被动删除（惰性删除）：当读/写一个已经过期的Key时，会触发惰性删除策略，直接删除掉这个Key;
* 主动删除（定期删除）：Redis会定期巡检，来清理过期Key；
* 当内存达到maxmemory配置时候，会触发Key的删除操作；

Redis 提供 8 种数据淘汰策略：
    volatile-lru：从已设置过期时间的数据集（server.db[i].expires）中挑选最近最少使用 的数据淘汰
    volatile-lfu(since 4.0): Removes least frequently used keys with the expire field set to true.
    volatile-ttl：从已设置过期时间的数据集（server.db[i].expires）中挑选将要过期的数 据淘汰
    volatile-random：从已设置过期时间的数据集（server.db[i].expires）中任意选择数据 淘汰
    allkeys-lru：从数据集（server.db[i].dict）中挑选最近最少使用的数据淘汰
    allkeys-lfu(since 4.0): Keeps frequently used keys; removes least frequently used (LFU) keys
    allkeys-random：从数据集（server.db[i].dict）中任意选择数据淘汰
    no-enviction（驱逐）：禁止驱逐数据

另外，还有一种基于触发器的删除策略，因为对Redis压力太大，一般没人使用。

> [Redis 数据淘汰机制](http://wiki.jikexueyuan.com/project/redis/data-elimination-mechanism.html)

### Redis Big key and hot key

[一文详解Redis中BigKey、HotKey的发现与处理](https://mp.weixin.qq.com/s/FPYE1B839_8Yk1-YSiW-1Q)

1. debug object 命令对Key进行分析，调试命令，运行代价较大，并且在其运行时，进入Redis的其余请求将会被阻塞直到其执行完毕。
2. Redis自4.0起提供了MEMORY USAGE命令来帮助分析Key的内存占用，相对debug object它的执行代价更低，但由于其时间复杂度为O(N)因此在分析大Key时仍有阻塞风险。
3. redis-cli 的 bigkeys 参数 以遍历的方式分析整个Redis实例中的所有Key并汇总以报告的方式返回结果。该方案的优势在于方便及安全，而缺点也非常明显：分析结果不可定制化。该方案的优势在于方便及安全，而缺点也非常明显：分析结果不可定制化。
4. Redis4.0 通过redis-cli的hotkeys参数发现热Key 该参数能够返回所有Key的被访问次数，它的缺点同样为不可定制化输出报告，大量的信息会使你在分析结果时复杂度较大，另外，使用该方案的前提条件是将redis-server的maxmemory-policy参数设置为LFU。
5. 通过业务层定位热Key
6. 使用monitor命令在紧急情况时找出热Key。可以打印Redis中的所有请求，包括时间信息、Client信息、命令以及Key信息，并重定向至文件。monitor命令对Redis的CPU、内存、网络资源均有一定的占用。因此，对于一个已处于高压状态的Redis，monitor可能会起到雪上加霜的作用。同时，这种异步收集并分析的方案的时效性较差，并且由于分析的精确度取决于monitor的执行时间，因此在多数无法长时间执行该命令的线上场景中本方案的精确度也不够好。
7. 使用开源工具 redis-rdb-tools 离线发现大Key

#### 主动删除

Redis 将 serverCron 作为时间事件来运行，从而确保它每隔一段时间就会自动运行一次， 又因为 serverCron 需要在 Redis 服务器运行期间一直定期运行， 所以它是一个循环时间事件：serverCron 会一直定期执行，直到服务器关闭为止。

从 Redis 2.8 开始， 用户可以通过修改 hz选项来调整 serverCron 的每秒执行次数， 具体信息请参考 redis.conf 文件中关于 hz 选项的说明。

### Redis Memory Analyze

> 数据分布[Redis-rdb-tools](https://github.com/sripathikrishnan/redis-rdb-tools)
`sudo pip install rdbtools`

```sql
#使用 redis-rdb-tools 生成内存快照
rdb -c memory dump.rdb > memory.csv;

# 导入rdb到sqlite
sqlite3 memory.db
sqlite> create table memory(database int,type varchar(128),key varchar(128),size_in_bytes int,encoding varchar(128),num_elements int,len_largest_element varchar(128));
sqlite>.mode csv memory
sqlite>.import memory.csv memory
sqlite>.quit


#查询key个数
sqlite>select count(*) from memory;

#查询总的内存占用
sqlite>select sum(size_in_bytes) from memory;

#查询内存占用最高的10个 key
sqlite>select * from memory order by size_in_bytes desc limit 10;

#查询成员个数1000个以上的 list
sqlite>select * from memory where type='list' and num_elements > 1000 ;
```

## Command

startup redis server `./redis-server redis_6379.conf`
`src/redis-cli -h 127.0.0.1 -p 6379 -a <password> -n <dbNumber>`
`-r` 4: repeat 4 times
`-i` 2: 2 seconds sleep between each PING command

redis log file: `less  /etc/redis/redis.conf | grep logfile`
get all config `config get *`

用于分析 Redis 性能的一些命令
`redis-cli -h <host> -p <port> -a <pwd> -n <db> --bigkeys` 从指定的 Redis DB 中持续采样，实时输出当时得到的 value 占用空间最大的 key 值，并在最后给出各种数据结构的 biggest key 的总结报告:
用的是scan方式，不用担心会阻塞redis很长时间不能处理其他的请求。执行的结果可以用于分析redis的内存的只用状态，每种类型key的平均大小。

`client list`
`--bigkeys`
`--latency`, 用来测试 Redis 服务端的响应延迟
`--latency-history`
`redis-cli -h <host> -p <port> -a <pwd> -n <db> info memory`

`info memory`
`info keyspace`
`info commandstats` 输出中包含处理过的每一种命令的调用次数、消耗的总 CPU 时间(单位 ms)以及平均 CPU 耗时，这对了解自己的程序所使用的 Redis 操作情况非常有用。

### Setup redis server

1. config redis.conf

```txt
vi redis.conf

daemonize yes
dbfilename dump_6379.rdb
logfile "/data/log/redis_6379.log"
dir "/data/software/redis-account"
```

2. start

`redis-server redis.master6379.conf --daemonize yes`  redis-server in background as a daemon thread
`redis-server sentinel.26379.conf --sentinel --daemonize yes` or `redis-sentinel sentinel.26379.conf --daemonize yes`

shutdown redis server: `redis-cli shutdown` or `redis-server stop`
restart redis server: `redis-server restart`
shutdown redis sentinel: `redis-cli -h localhost -p 26379 shutdown`

### redis-cli

Redis的value存储中文后，get之后显示16进制的字符串”\xe4\xb8\xad\xe5\x9b\xbd”
启动`redis-cli`时，在其后面加上 `--raw` ，汉字即可显示正常。

### 常规操作命令

字符串(strings),字符串列表(lists),字符串集合(sets),有序字符串集合(sorted sets),哈希(hashes)
01  exits key              //测试指定key是否存在，返回1表示存在，0不存在
02  del key1 key2 ....keyN //删除给定key,返回删除key的数目，0表示给定key都不存在
03  type key               //返回给定key的value类型。返回 none 表示不存在key,string字符类型，list 链表类型 set 无序集合类型...
04  keys pattern           //返回匹配指定模式的所有key,下面给个例子
05  randomkey              //返回从当前数据库中随机选择的一个key,如果当前数据库是空的，返回空串
06  rename oldkey newkey   //原子的重命名一个key,如果newkey存在，将会被覆盖，返回1表示成功，0失败。可能是oldkey不存在或者和newkey相同
07  renamenx oldkey newkey //同上，但是如果newkey存在返回失败
08  dbsize                 //返回当前数据库的key数量
09  expire key seconds     //为key指定过期时间，单位是秒。返回1成功，0表示key已经设置过过期时间或者不存在
10  ttl key                //返回设置过过期时间的key的剩余过期秒数 -1表示key不存在或者没有设置过过期时间  returns -2 if the key does not exist. returns -1 if the key exists but has no associated expire.
11  select db-index        //通过索引选择数据库，默认连接的数据库所有是0,默认数据库数是16个。返回1表示成功，0失败
12  move key db-index      //将key从当前数据库移动到指定数据库。返回1成功。0 如果key不存在，或者已经在指定数据库中
13  flushdb                //删除当前数据库中所有key,此方法不会失败。慎用
14  flushall               //删除所有数据库中的所有key，此方法不会失败。更加慎用

### [SCAN](https://redis.io/commands/scan)

SCAN return value is an array of two values

1. the first value is the new cursor to use in the next call
2. the second value is an array of elements.

`SCAN cursor [MATCH pattern] [COUNT count]`
eg: `SCAN 0 MATCH "*:foo:bar:*" COUNT 10`
`redis-cli --scan | head -10`
`redis-cli -h host -p 6379 -n 2 --scan --pattern "*:foo:bar:*" | xargs -L 100 redis-cli -h host -p 6379 -n 2  DEL` 批量删除

#### SCAN命令时，不会漏key，但可能会得到重复的key

这主要和Redis的Rehash机制有关。

1. 为什么不会漏key？Redis在SCAN遍历全局哈希表时，采用*高位进位法*的方式遍历哈希桶（可网上查询图例，一看就明白），当哈希表扩容后，通过这种算法遍历，旧哈希表中的数据映射到新哈希表，依旧会保留原来的先后顺序，这样就可以保证遍历时不会遗漏也不会重复。

2. 为什么SCAN会得到重复的key？这个情况主要发生在哈希表缩容。已经遍历过的哈希桶在缩容时，会映射到新哈希表没有遍历到的位置，所以继续遍历就会对同一个key返回多次。

### string 类型数据操作命令

01  set key value         //设置key对应的值为string类型的value,返回1表示成功，0失败
02  setnx key value       //同上，如果key已经存在，返回0 。nx 是not exist的意思
03  get key               //获取key对应的string值,如果key不存在返回nil
04  getset key value      //原子的设置key的值，并返回key的旧值。如果key不存在返回nil
05  mget key1 key2 ... keyN            //一次获取多个key的值，如果对应key不存在，则对应返回nil。下面是个实验,首先清空当前数据库，然后设置k1,k2.获取时k3对应返回nil
06  mset key1 value1 ... keyN valueN   //一次设置多个key的值，成功返回1表示所有的值都设置了，失败返回0表示没有任何值被设置
07  msetnx key1 value1 ... keyN valueN //同上，但是不会覆盖已经存在的key
08  incr key              //对key的值做加加操作,并返回新的值。注意incr一个不是int的value会返回错误，incr一个不存在的key，则设置key为1
09  decr key              //同上，但是做的是减减操作，decr一个不存在key，则设置key为-1
10  incrby key integer    //同incr，加指定值 ，key不存在时候会设置key，并认为原来的value是 0
11  decrby key integer    //同decr，减指定值。decrby完全是为了可读性，我们完全可以通过incrby一个负值来实现同样效果，反之一样。
12  append key value      //给指定key的字符串值追加value,返回新字符串值的长度。下面给个例子
13  substr key start end  //返回截取过的key的字符串值,注意并不修改key的值。下标是从0开始的，接着上面例子

### list 类型数据操作命令

01  lpush key string          //在key对应list的头部添加字符串元素，返回1表示成功，0表示key存在且不是list类型
02  rpush key string          //同上，在尾部添加
03  llen key                  //返回key对应list的长度，key不存在返回0,如果key对应类型不是list返回错误
04  lrange key start end      //返回指定区间内的元素，下标从0开始，负值表示从后面计算，-1表示倒数第一个元素 ，key不存在返回空列表
05  ltrim key start end       //截取list，保留指定区间内元素，成功返回1，key不存在返回错误
06  lset key index value      //设置list中指定下标的元素值，成功返回1，key或者下标不存在返回错误
07  lrem key count value      //从key对应list中删除count个和value相同的元素。count为0时候删除全部
08  lpop key                  //从list的头部删除元素，并返回删除元素。如果key对应list不存在或者是空返回nil，如果key对应值不是list返回错误
09  rpop                      //同上，但是从尾部删除
10  blpop key1...keyN timeout //从左到右扫描返回对第一个非空list进行lpop操作并返回，比如blpop list1 list2 list3 0 ,如果list不存在list2,list3都是非空则对list2做lpop并返回从list2中删除的元素。如果所有的list都是空或不存在，则会阻塞timeout秒，timeout为0表示一直阻塞。当阻塞时，如果有client对key1...keyN中的任意key进行push操作，则第一在这个key上被阻塞的client会立即返回。如果超时发生，则返回nil。有点像unix的select或者poll
11  brpop                     //同blpop，一个是从头部删除一个是从尾部删除
12  rpoplpush srckey destkey  //从srckey对应list的尾部移除元素并添加到destkey对应list的头部,最后返回被移除的元素值，整个操作是原子的.如果srckey是空或者不存在返回nil

### set 类型数据操作命令

01  sadd key member                //添加一个string元素到,key对应的set集合中，成功返回1,如果元素以及在集合中返回0,key对应的set不存在返回错误
02  srem key member                //从key对应set中移除给定元素，成功返回1，如果member在集合中不存在或者key不存在返回0，如果key对应的不是set类型的值返回错误
03  spop key                       //删除并返回key对应set中随机的一个元素,如果set是空或者key不存在返回nil
04  srandmember key                //同spop，随机取set中的一个元素，但是不删除元素
05  smove srckey dstkey member     //从srckey对应set中移除member并添加到dstkey对应set中，整个操作是原子的。成功返回1,如果member在srckey中不存在返回0，如果key不是set类型返回错误
06  scard key                      //返回set的元素个数，如果set是空或者key不存在返回0
07  sismember key member           //判断member是否在set中，存在返回1，0表示不存在或者key不存在
08  sinter key1 key2...keyN        //返回所有给定key的交集
09  sinterstore dstkey key1...keyN //同sinter，但是会同时将交集存到dstkey下
10  sunion key1 key2...keyN        //返回所有给定key的并集
11  sunionstore dstkey key1...keyN //同sunion，并同时保存并集到dstkey下
12  sdiff key1 key2...keyN         //返回所有给定key的差集
13  sdiffstore dstkey key1...keyN  //同sdiff，并同时保存差集到dstkey下
14  smembers key                   //返回key对应set的所有元素，结果是无序的

### sorted set 类型数据操作命令

01  zadd key score member        //添加元素到集合，元素在集合中存在则更新对应score
02  zrem key member              //删除指定元素，1表示成功，如果元素不存在返回0
03  zincrby key incr member      //增加对应member的score值，然后移动元素并保持skip list保持有序。返回更新后的score值
04  zrank key member             //返回指定元素在集合中的排名（下标）,集合中元素是按score从小到大排序的
05  zrevrank key member          //同上,但是集合中元素是按score从大到小排序
06  zrange key start end         //类似lrange操作从集合中去指定区间的元素。返回的是有序结果
07  zrevrange key start end      //同上，返回结果是按score逆序的
08  zrangebyscore key min max    //返回集合中score在给定区间的元素
09  zcount key min max           //返回集合中score在给定区间的数量
10  zcard key                    //返回集合中元素个数
11  zscore key element           //返回给定元素对应的score
12  zremrangebyrank key min max  //删除集合中排名在给定区间的元素
13  zremrangebyscore key min max //删除集合中score在给定区间的元素

### hash 类型数据操作命令

01  hset key field value       //设置hash field为指定值，如果key不存在，则先创建
02  hget key field             //获取指定的hash field
03  hmget key filed1....fieldN //获取全部指定的hash filed
04  hmset key filed1 value1 ... filedN valueN //同时设置hash的多个field
05  hincrby key field integer  //将指定的hash filed 加上给定值
06  hexists key field          //测试指定field是否存在
07  hdel key field             //删除指定的hash field
08  hlen key                   //返回指定hash的field数量
09  hkeys key                  //返回hash的所有field
10  hvals key                  //返回hash的所有value
11  hgetall                    //返回hash的所有filed和value

### Redis 发布订阅

Redis 发布订阅 (pub/sub) 是一种消息通信模式：发送者 (pub) 发送消息，订阅者 (sub) 接收消息。

Redis 客户端可以订阅任意数量的频道。

* `PUBLISH channel message` 将信息发送到指定的频道。
* `SUBSCRIBE channel [channel ...]` 订阅给定的一个或多个频道的信息。
* `UNSUBSCRIBE [channel [channel ...]]` 指退订给定的频道。
* `PUBSUB subcommand [argument [argument ...]]` 查看订阅与发布系统状态。
* `PUBSUB CHANNELS [pattern]` 列出当前的活跃频道。

## Redis 6.0

### multi-threaded I/O

[Redis configuration file example | Redis](https://redis.io/docs/management/config-file/)

redis 6.x IO threads 读请求默认关闭多线程，参考 Redis 配置文件注释
原因：读时 IO 操作小，请求头很小，如果返回数据大，多线程提高效率

```sh
# Setting io-threads to 1 will just use the main thread as usual. When I/0 threads are enabled, we only use threads for writes, that is to thread the write(2) syscall and transfer the client buffers to the socket. However it is also possible to enable threading of reads and protocol parsing using the following configuration directive, by setting it to yes:
io-threads-do-reads no
```

[In what types of workloads does multi-threaded I/O in Redis 6 make a difference? - Stack Overflow](https://stackoverflow.com/questions/62618284/in-what-types-of-workloads-does-multi-threaded-i-o-in-redis-6-make-a-difference)

Before Redis 6, Redis processes a request with 4 steps in serial (in a single thread):

1. reading the request from socket
2. parsing it
3. process it
4. writing the response to socket

Before it finishes these 4 steps, Redis cannot process other requests, even if there're some requests ready for reading (step 1). And normally writing the response to socket (step 4) is slow, so if we can do the write operation in another IO thread (configuration: `io-threads`), Redis can process more requests, and be faster.

Also you can set Redis to run step 1 and 2 in another IO thread (configuration: `io-threads-do-reads`), however, the Redis team claims that normally it doesn't help much (_Usually threading reads doesn't help much. -- quoted from [redis.conf](https://raw.githubusercontent.com/redis/redis/6.0/redis.conf).

## Redis Cluster 为什么使用哈希槽而不用一致性哈希

[Redis为什么使用哈希槽而不用一致性哈希-51CTO.COM](https://www.51cto.com/article/777058.html)

一致性哈希算法很好地解决了分布式系统在扩容或者缩容时，发生过多的数据迁移的问题。

算法是对 2^32 进行取模运算的结果值虚拟成一个圆环，环上的刻度对应一个 0~2^32 - 1 之间的数值。通过虚拟节点的方式很好的处理了数据不平衡问题。

原因：

* 当发生扩容时候，Redis可配置映射表的方式让哈希槽更灵活，可更方便组织映射到新增server上面的slot数，比一致性hash的算法更灵活方便。
* 在数据迁移时，一致性hash 需要重新计算key在新增节点的数据，然后迁移这部分数据，哈希槽则直接将一个slot对应的数据全部迁移，实现更简单
* 可以灵活的分配槽位，比如性能更好的节点分配更多槽位，性能相对较差的节点可以分配较少的槽位

为什么Redis Cluster哈希槽数量是16384？

* Redis节点间通信时，心跳包会携带节点的所有槽信息，它能以幂等方式来更新配置。如果采用 16384(16k=2^14)个插槽，占空间 2KB (16384/8);如果采用 65536 个插槽，占空间 8KB (65536/8)。
* Redis Cluster 不太可能扩展到超过 1000 个主节点，太多可能导致网络拥堵。
* 16384 个插槽范围比较合适，当集群扩展到1000个节点时，也能确保每个master节点有足够的插槽
