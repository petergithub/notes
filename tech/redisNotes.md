## 常规操作命令  
01  exits key              //测试指定key是否存在，返回1表示存在，0不存在  
02  del key1 key2 ....keyN //删除给定key,返回删除key的数目，0表示给定key都不存在  
03  type key               //返回给定key的value类型。返回 none 表示不存在key,string字符类型，list 链表类型 set 无序集合类型...  
04  keys pattern           //返回匹配指定模式的所有key,下面给个例子  
05  randomkey              //返回从当前数据库中随机选择的一个key,如果当前数据库是空的，返回空串  
06  rename oldkey newkey   //原子的重命名一个key,如果newkey存在，将会被覆盖，返回1表示成功，0失败。可能是oldkey不存在或者和newkey相同  
07  renamenx oldkey newkey //同上，但是如果newkey存在返回失败  
08  dbsize                 //返回当前数据库的key数量  
09  expire key seconds     //为key指定过期时间，单位是秒。返回1成功，0表示key已经设置过过期时间或者不存在  
10  ttl key                //返回设置过过期时间的key的剩余过期秒数 -1表示key不存在或者没有设置过过期时间  
11  select db-index        //通过索引选择数据库，默认连接的数据库所有是0,默认数据库数是16个。返回1表示成功，0失败  
12  move key db-index      //将key从当前数据库移动到指定数据库。返回1成功。0 如果key不存在，或者已经在指定数据库中  
13  flushdb                //删除当前数据库中所有key,此方法不会失败。慎用  
14  flushall               //删除所有数据库中的所有key，此方法不会失败。更加慎用  
   
## string 类型数据操作命令  
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
   
## list 类型数据操作命令  
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
   
## set 类型数据操作命令  
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
   
## sorted set 类型数据操作命令  
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
   
## hash 类型数据操作命令  
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