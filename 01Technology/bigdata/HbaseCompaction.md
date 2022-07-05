# 理解 HBase Compaction 机制

[深入理解 HBase Compaction 机制 - 腾讯云开发者社区-腾讯云](https://cloud.tencent.com/developer/article/1488439)

## 为什么要执行 Compaction

熟悉HBase的同学应该知道，HBase是基于一种`LSM-Tree（Log-structured Merge Tree）`存储模型设计的，写入路径上是先写入`WAL（Write-Ahead-Log）`即预写日志，再写入memstore缓存，满足一定条件后执行flush操作将缓存数据刷写到磁盘，生成一个HFile数据文件。

随着数据不断写入，磁盘HFile文件就会越来越多，文件太多会影响HBase查询性能，主要体现在查询数据的io次数增加。为了优化查询性能，HBase会合并小的HFile以减少文件数量，这种合并HFile的操作称为Compaction，这也是为什么要进行Compaction的主要原因。

## Compaction 作用

其实Compaction操作属于资源密集型操作特别是IO密集型，这点后面也会提及到，Compaction其实就是以短时间内的IO消耗，以换取相对稳定的读取性能。

## Compaction 分类

HBase Compaction分为两种：`Minor Compaction` 与 `Major Compaction`，通常我们简称为小合并、大合并。

`Minor Compaction`：指选取一些小的、相邻的HFile将他们合并成一个更大的HFile。默认情况下，minor compaction会删除选取HFile中的TTL过期数据。

`Major Compaction`：指将一个Store中所有的HFile合并成一个HFile，这个过程会清理三类没有意义的数据：被删除的数据（打了Delete标记的数据）、TTL过期数据、版本号超过设定版本号的数据。另外，一般情况下，Major Compaction时间会持续比较长，整个过程会消耗大量系统资源，对上层业务有比较大的影响。因此，生产环境下通常关闭自动触发Major Compaction功能，改为手动在业务低峰期触发。

这里值得关注，默认情况下Minor Compaction也会删除数据，但只是删除合并HFile中的TTL过期数据。Major Compaction是完全删除无效数据，包括被删除的数据、TTL过期数据以及版本号过大的数据。

## Compaction 触发条件

HBase触发Compaction的条件有三种：

1. memstore Flush
2. 后台线程周期性检查
3. 手动触发

memstore flush：可以说compaction的根源就在于flush，memstore 达到一定阈值或其他条件时就会触发flush刷写到磁盘生成HFile文件，正是因为HFile文件越来越多才需要compact。HBase每次flush之后，都会判断是否要进行compaction，一旦满足minor compaction或major compaction的条件便会触发执行。

后台线程周期性检查： 后台线程 CompactionChecker 会定期检查是否需要执行compaction，检查周期为`hbase.server.thread.wakefrequency * hbase.server.compactchecker.Interval.multiplier`，这里主要考虑的是一段时间内没有写入请求仍然需要做compact检查。

* 参数 `hbase.server.thread.wakefrequency` 默认值 10000 即 10s，是HBase服务端线程唤醒时间间隔，用于log roller、memstore flusher等操作周期性检查；
* 参数 `hbase.server.compactchecker.interval.multiplier` 默认值1000，是compaction操作周期性检查乘数因子。10 * 1000 s 时间上约等于2hrs, 46mins, 40sec。

手动触发：是指通过HBase Shell、Master UI界面或者HBase API等任一种方式 执行 compact、major_compact等命令。

## Compaction 参数解析

### Major Compaction 参数

Major Compaction涉及的参数比较少，主要有大合并时间间隔与一个抖动参数因子，如下：

1. `hbase.hregion.majorcompaction`
    Major compaction周期性时间间隔，默认值 604800000，单位ms。表示major compaction默认7天调度一次，HBase 0.96.x及之前默认为1天调度一次。设置为 0 时表示禁用自动触发major compaction。需要强调的是一般major compaction持续时间较长、系统资源消耗较大，对上层业务也有比较大的影响，一般生产环境下为了避免影响读写请求，会禁用自动触发major compaction。

2. `hbase.hregion.majorcompaction.jitter`
    Major compaction抖动参数，默认值0.5。这个参数是为了避免major compaction同时在各个regionserver上同时发生，避免此操作给集群带来很大压力。 这样节点major compaction就会在 + 或 - 两者乘积的时间范围内随机发生。

### Minor Compaction 参数

Minor compaction涉及的参数比major compaction要多，各个参数的目标是为了选择合适的HFile，具体参数如下：

1. `hbase.hstore.compaction.min`
    一次minor compaction最少合并的HFile数量，默认值 3。表示至少有3个符合条件的HFile，minor compaction才会启动。一般情况下不建议调整该参数。
    如果要调整，不建议调小该参数，这样会带来更频繁的压缩，调大该参数的同时其他相关参数也应该做调整。早期参数名称为 hbase.hstore.compactionthreshold。

2. `hbase.hstore.compaction.max`
    一次minor compaction最多合并的HFile数量，默认值 10。这个参数也是控制着一次压缩的时间。一般情况下不建议调整该参数。调大该值意味着一次compaction将会合并更多的HFile，压缩时间将会延长。

3. `hbase.hstore.compaction.min.size`
    文件大小 < 该参数值的HFile一定是适合进行minor compaction文件，默认值 128M（memstore flush size）。意味着小于该大小的HFile将会自动加入（automatic include）压缩队列。一般情况下不建议调整该参数。
    但是，在write-heavy就是写压力非常大的场景，可能需要微调该参数、减小参数值，假如每次memstore大小达到1~2M时就会flush生成HFile，此时生成的每个HFile都会加入压缩队列，而且压缩生成的HFile仍然可能小于该配置值会再次加入压缩队列，这样将会导致压缩队列持续很长。

4. `hbase.hstore.compaction.max.size`
    文件大小 > 该参数值的HFile将会被排除，不会加入minor compaction，默认值Long.MAX_VALUE，表示没有什么限制。一般情况下也不建议调整该参数。

5. `hbase.hstore.compaction.ratio`
    这个ratio参数的作用是判断文件大小 > hbase.hstore.compaction.min.size的HFile是否也是适合进行minor compaction的，默认值1.2。更大的值将压缩产生更大的HFile，建议取值范围在1.0~1.4之间。大多数场景下也不建议调整该参数。

6. `hbase.hstore.compaction.ratio.offpeak`
    此参数与compaction ratio参数含义相同，是在原有文件选择策略基础上增加了一个非高峰期的ratio控制，默认值5.0。这个参数受另外两个参数 hbase.offpeak.start.hour 与 hbase.offpeak.end.hour 控制，这两个参数值为[0, 23]的整数，用于定义非高峰期时间段，默认值均为-1表示禁用非高峰期ratio设置。

## Compaction 线程池选择

HBase RegionServer内部专门有一个 CompactSplitThead 用于维护执行minor compaction、major compaction、split、merge操作的线程池。

其中与compaction操作有关的线程池称为 largeCompactions（又称longCompactions） 与 smallCompactions（又称shortCompactions），前者用来处理大规模compaction，后者处理小规模compaction，线程池大小都默认为 1 即只分别提供了一个线程用于相应的compaction。

这里并不是major compaction就一定会交给largeCompactions线程池处理。关于HBase compaction分配给largeCompactions还是smallCompactions线程池受参数`hbase.regionserver.thread.compaction.throttle`控制，该参数默认值为`2 * hbase.hstore.compaction.max * hbase.hregion.memstore.flush.size`，如果flush size 大小是128M，该参数默认值就是2684354560 即2.5G。一次compaction的文件总大小如果超过该配置，就会分配给largeCompactions处理，否则分配给smallCompactions处理。

largeCompactions与smallCompactions的线程池大小可通过参数 hbase.regionserver.thread.compaction.large、hbase.regionserver.thread.compaction.small进行配置。对于compaction压力比较大的场景，如果要调大两种线程池的大小，建议调整范围在2~5之间，不建议设置过大否则可能会消费过多的服务端资源造成不良影响。

## 操作

```sh
# major_compact 'regionName'
major_compact 'test_table,,1479298301063.de0cf9a0a157dd40e0777532dcd0b57e.'
```

### 如何判断HBase Major Compact是否执行完毕？

通过命令 status 'simple' 可查看 HBase RS 级别的一些指标，其中 compactionProgressPct=1.0 即表明RS Compact完成。

通过命令 status 'detailed' 可查看 HBase RS Region 级别的一些指标，其中 compactionProgressPct=1.0 即表明RS Compact完成。
