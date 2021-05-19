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

## Performance

### Redis常用的删除策略有以下三种：

* 被动删除（惰性删除）：当读/写一个已经过期的Key时，会触发惰性删除策略，直接删除掉这个Key;
* 主动删除（定期删除）：Redis会定期巡检，来清理过期Key；
* 当内存达到maxmemory配置时候，会触发Key的删除操作；

Redis 提供 6 种数据淘汰策略：
    volatile-lru：从已设置过期时间的数据集（server.db[i].expires）中挑选最近最少使用 的数据淘汰
    volatile-ttl：从已设置过期时间的数据集（server.db[i].expires）中挑选将要过期的数 据淘汰
    volatile-random：从已设置过期时间的数据集（server.db[i].expires）中任意选择数据 淘汰
    allkeys-lru：从数据集（server.db[i].dict）中挑选最近最少使用的数据淘汰
    allkeys-random：从数据集（server.db[i].dict）中任意选择数据淘汰
    no-enviction（驱逐）：禁止驱逐数据

另外，还有一种基于触发器的删除策略，因为对Redis压力太大，一般没人使用。

> [Redis 数据淘汰机制](http://wiki.jikexueyuan.com/project/redis/data-elimination-mechanism.html)

#### 主动删除

Redis 将 serverCron 作为时间事件来运行，从而确保它每隔一段时间就会自动运行一次， 又因为 serverCron 需要在 Redis 服务器运行期间一直定期运行， 所以它是一个循环时间事件：serverCron 会一直定期执行，直到服务器关闭为止。

从 Redis 2.8 开始， 用户可以通过修改 hz选项来调整 serverCron 的每秒执行次数， 具体信息请参考 redis.conf 文件中关于 hz 选项的说明。

### Redis Memory Analyze

> 数据分布[Redis-rdb-tools](https://github.com/sripathikrishnan/redis-rdb-tools)
`sudo pip install rdbtools`

``` sql
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

`SCAN cursor [MATCH pattern] [COUNT count]`
eg: `SCAN 0 MATCH "*:foo:bar:*" COUNT 10`
`redis-cli --scan --pattern "*:foo:bar:*" | xargs -L 100 redis-cli DEL` 批量删除

`client list`
`--bigkeys`
`--latency`, 用来测试 Redis 服务端的响应延迟
`--latency-history`
`redis-cli -h <host> -p <port> -a <pwd> -n <db> info memory`
`redis-cli --scan | head -10`
`redis-cli --scan --pattern '*-11*' | xargs -L 100 redis-cli DEL`

`info memory`
`info keyspace`
`info commandstats` 输出中包含处理过的每一种命令的调用次数、消耗的总 CPU 时间(单位 ms)以及平均 CPU 耗时，这对了解自己的程序所使用的 Redis 操作情况非常有用。

### Setup redis server

1. vi redis.conf

daemonize yes
dbfilename dump_6379.rdb
logfile "/data/log/redis_6379.log"
dir "/data/software/redis-account"

2. start

`redis-server redis.master6379.conf --daemonize yes`  redis-server in background as a daemon thread 
`redis-server sentinel.26379.conf --sentinel --daemonize yes` or `redis-sentinel sentinel.26379.conf --daemonize yes`

shutdown redis server: `redis-cli shutdown` or `redis-server stop`  
restart redis server: `redis-server restart`  
shutdown redis sentinel: `redis-cli -h localhost -p 26379 shutdown`

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
	ttl key 				  // 返回剩余的过期时间 returns -2 if the key does not exist. returns -1 if the key exists but has no associated expire.
09  expire key seconds     //为key指定过期时间，单位是秒。返回1成功，0表示key已经设置过过期时间或者不存在  
10  ttl key                //返回设置过过期时间的key的剩余过期秒数 -1表示key不存在或者没有设置过过期时间  
11  select db-index        //通过索引选择数据库，默认连接的数据库所有是0,默认数据库数是16个。返回1表示成功，0失败  
12  move key db-index      //将key从当前数据库移动到指定数据库。返回1成功。0 如果key不存在，或者已经在指定数据库中  
13  flushdb                //删除当前数据库中所有key,此方法不会失败。慎用  
14  flushall               //删除所有数据库中的所有key，此方法不会失败。更加慎用  
   
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