# prometheus Note

## 初识 PromQL

[PromQL教程（一）初识 PromQL - 快猫星云Flashcat](https://flashcat.cloud/blog/promql-tutorial-01/)

[Query examples | Prometheus](https://prometheus.io/docs/prometheus/latest/querying/examples/)

在监控领域，我们经常会听到指标（Metric）这个词，指标是对系统或服务的某个特定方面进行量化的测量值。比如，服务器的 CPU 使用率、内存使用率、数据库的连接数、某个 API 的 99 分位延迟等都是常见的指标。指标可以反应系统的运行状态，帮助我们了解系统的性能、稳定性、可用性等。

指标数据一般是周期性采集，每次采集到的数据称为一个数据点，举例如下：

```json
{
    "metric": "cpu_usage_idle",
    "labels": {
        "host": "10.1.2.3",
        "region": "us-west"
    },
    "value": 82.3,
    "timestamp": 1632892800
}
```
上例是用 JSON 格式表示的一个数据点，包含了以下几个字段：

- metric：指标名称，比如 cpu_usage_idle 表示 CPU 空闲率
- labels：标签，用于标识数据点的维度，比如 host 表示主机名，region 表示地区
- value：数据点的值，比如 82.3 表示 CPU 空闲率为 82.3%
- timestamp：数据点的时间戳，比如 1632892800 表示 Unix 时间戳

metric、labels、value、timestamp 四个字段组成了数据点的唯一标识，metric、labels 两个字段组成了指标的唯一标识。

就上例而言，假设 10.1.2.3 这个机器每 15 秒采集一个数据点，一分钟就会有 4 个数据点，一小时就会有 240 个数据点，一天就会有 5760 个数据点。如果我们有 10000 台机器，一天就会有 57600000 个数据点。而这，仅仅是机器的一个指标，实际上，我们还会采集很多其他指标，另外除了机器，还要采集数据库、中间件、应用程序等的指标，数据量是非常庞大的。很多大公司每秒甚至会采集数千万、上亿的数据点。

### label operators

The following label matching operators exist:

=: Select labels that are exactly equal to the provided string.
!=: Select labels that are not equal to the provided string.
=~: Select labels that regex-match the provided string.
!~: Select labels that do not regex-match the provided string.
Regex matches are fully anchored. A match of env=~"foo" is treated as env=~"^foo$".

```sh
# PromQL
cpu_usage_idle{host="10.1.2.3"} > 10
cpu_usage_active{env="plus", region="center"}
```

### 查询示例

```sh
# PromQL
cpu_usage_idle{host="10.1.2.3"} > 10
cpu_usage_active{env="plus", region="center"}


cpu_usage_active{ident="QJ-IOT-ip"} > 10
{app=~"opcua(8052|8051)",__name__=~"jvm_.*",__name__!="jvm_buffer_total_capacity_bytes",__name__!="jvm_gc_memory_allocated_bytes_total"}
{app=~"opcua(8052|8051)",__name__=~"jvm_memory_(max|committed|used)_bytes", area="heap"}
{app=~"opcua(8052|8051)", __name__=~"(jvm_memory_usage_after_gc_percent|jvm_gc_memory_promoted_bytes_total|jvm_gc_live_data_size_bytes)"}
```

## JVM Metrics

这些指标涵盖了 JVM 运行时的方方面面。为了方便你理解，我将它们分为 直接缓冲区、类加载、垃圾回收 (GC)、内存状态 和 线程 五大板块。

### 1. 缓冲区指标 (Direct Buffer)

这些指标反映了 JVM 堆外内存（直接内存）的使用情况，常用于 NIO 操作（如 Netty）。

- `jvm_buffer_count_buffers`: 当前建立的缓冲区数量。
- `jvm_buffer_memory_used_bytes`: 已经实际使用的缓冲区内存大小。
- `jvm_buffer_total_capacity_bytes`: 当前缓冲区的总容量。通常 `capacity` 会大于等于 `used`。

### 2. 类加载指标 (Class Loading)

- `jvm_classes_loaded_classes`: 当前加载到 JVM 中的类的数量（实时数值）。
- `jvm_classes_unloaded_classes_total`: 自启动以来累计卸载的类数量。
> 提示： 如果卸载数量一直在增加，说明可能存在频繁的动态类生成（如 CGLIB 代理）。

### 3. 垃圾回收指标 (Garbage Collection)

这是监控中最核心的部分，用于观察内存流动和 GC 压力。

- `jvm_gc_live_data_size_bytes`: Full GC 后老年代（Old Gen）中存活的数据大小。这通常被视为应用程序的“基准内存占用”。
- `jvm_gc_max_data_size_bytes`: 老年代的最大容量上限。
- `jvm_gc_memory_allocated_bytes_total`: 自启动以来，年轻代中累计分配的内存总量（见上一个回答）。
- `jvm_gc_memory_promoted_bytes_total`: 自启动以来，从年轻代晋升到老年代的内存总量。
> 分析： 如果这个值增长过快，说明对象过早进入老年代，可能需要调优年轻代大小。

- `jvm_gc_overhead_percent`: GC 耗时占总时间的百分比。反映了 CPU 有多少精力花在清理垃圾而不是运行业务上。
- `jvm_gc_pause_seconds_count`: 累计 GC 暂停次数。
- `jvm_gc_pause_seconds_max`: 单次 GC 停顿的最长时间（STW 时间）。
- `jvm_gc_pause_seconds_sum`: 累计总 GC 停顿时间。

### 4. 内存状态指标 (Memory Status)

- `jvm_memory_max_bytes`: JVM 允许申请的最大内存（对应 `-Xmx`）。
- `jvm_memory_committed_bytes`: JVM 当前已向操作系统申请并保证可用的内存（对应 `-Xms` 或动态伸缩后的值）。
- `jvm_memory_used_bytes`: 当前实际使用的内存。
- `jvm_memory_usage_after_gc_percent`: 在最近一次 GC 后，存活对象占该内存区域最大容量的百分比。

### 5. 线程指标 (Threads)

- `jvm_threads_live_threads`: 当前活跃的线程数（包括守护线程和非守护线程）。
- `jvm_threads_daemon_threads`: 当前活跃的守护线程（Daemon）数量。
- `jvm_threads_peak_threads`: 自启动以来，峰值线程数。
- `jvm_threads_states_threads`: 按线程状态分组的数量（如 `RUNNABLE`, `BLOCKED`, `WAITING` 等）。
> 调优： 如果 `BLOCKED` 状态线程较多，说明代码中存在严重的锁竞争。

### 常用指标

| 关注点   | 关键指标                          | 异常信号                                    |
| -------- | --------------------------------- | ------------------------------------------- |
| 内存泄漏 | `live_data_size_bytes`            | 每次 Full GC 后该值持续上升                 |
| GC 压力  | `gc_overhead_percent`             | 超过 5%-10% 说明 GC 频繁，影响性能          |
| 线程安全 | `states_threads{state="blocked"}` | 大于 0 需警惕死锁或死循环                   |
| 内存扩容 | `committed_bytes` vs `max_bytes`  | `committed` 接近 `max` 说明物理内存即将吃紧 |

快速排查建议表格

| 场景                   | 优先看这个指标                      | 配合这个指标一起看                   |
| ---------------------- | ----------------------------------- | ------------------------------------ |
| 如果你想观察系统变慢了  | `jvm_gc_pause_seconds_sum`          | `jvm_threads_states_threads`         |
| 内存快爆了             | `jvm_memory_usage_after_gc_percent` | `jvm_gc_memory_promoted_bytes_total` |
| CPU 突然飙高           | `jvm_gc_overhead_percent`           | `jvm_classes_loaded_classes`         |

```sh
# 线程阻塞率 (Blocked Thread Ratio) 如果这个值持续走高，通常意味着程序中存在严重的锁竞争。
# 阻塞线程占比
sum(jvm_threads_states_threads{state="blocked"}) / sum(jvm_threads_live_threads) * 100

# 堆内存使用率 (Heap Usage %) 当前已用内存占最大可用内存的百分比
(jvm_memory_used_bytes{area="heap"} / jvm_memory_max_bytes{area="heap"}) * 100

# 内存泄漏诊断 (Leak Detection) 这是最有参考价值的一个查询. 观察 Full GC 后的基准存活内存
# 如果此曲线在长周期（如 24h）内呈阶梯状或稳步上升，基本可以确定存在内存泄漏。
jvm_gc_live_data_size_bytes
```
