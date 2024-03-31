# RabbitMQ

[RabbitMQ Server](https://github.com/rabbitmq/rabbitmq-server/)

/usr/local/rabbitmq/sbin/rabbitmq-server  -detached &     加上启动参数 detached

## [Troubleshooting Guidance](https://www.rabbitmq.com/troubleshooting.html)

crash file /usr/local/rabbitmq/var/lib/rabbitmq/erl_crash.dump

## Basic command

[Command Line Tools](https://www.rabbitmq.com/cli.html)

* `rabbitmqctl` for service management and general operator tasks
* `rabbitmq-diagnostics` for diagnostics and health checking
* `rabbitmq-plugins` for plugin management
* `rabbitmq-queues` for maintenance tasks on queues, in particular quorum queues
* `rabbitmq-upgrade` for maintenance tasks related to upgrades

``` bash
# start stop
service rabbitmq-server start
service rabbitmq-server stop
service rabbitmq-server restart
service rabbitmq-server status
rabbitmqctl status
# 环境信息
rabbitmqctl environment
# log path: /usr/local/rabbitmq/var/log/
# /var/log/rabbitmq/

rabbitmqctl list_vhosts
rabbitmqctl list_queues -p <vhost>
rabbitmqctl list_consumers -p <vhost>
rabbitmqctl list_exchanges -p push-center
rabbitmqctl list_users # 查看用户
rabbitmqctl list_user_permissions username
rabbitmqctl purge_queue -p <vhost> queue.name.development
curl -X DELETE -i -u guest:guest "http://localhost:15672/api/queues/local/gongzhonghao.refreshAccessToken.queue.name.development"
```

### Management

By default, RabbitMQ have a user named guest with password guest. We will create own administrator account on RabbitMQ server, change password :

``` bash
rabbitmqctl add_user admin password
rabbitmqctl set_user_tags admin administrator
rabbitmqctl set_permissions -p / admin ".*" ".*" ".*"

rabbitmqctl add_vhost vhost_name
rabbitmqctl set_permissions -p vhost_name admin ".*" ".*" ".*"
rabbitmqctl list_user_permissions admin
```

RabbitMQ has a web management console. To enable web management console run : `rabbitmq-plugins enable rabbitmq_management`
`http://localhost:15672/   guest / guest`

`curl -i -u guest:guest "http://localhost:15672/api/overview"`
`curl -i -u guest:guest "http://localhost:15672/api/queues/push-center/push.schedule.push.queue.name.publish"`

The OS limits are controlled via a configuration file at `/etc/systemd/system/rabbitmq-server.service.d/limits.conf`

* rabbitmq-diagnostics status
* rabbitmqctl --help
* rabbitmq-diagnostics status --help

`rabbitmq-diagnostics observer` is a command-line tool similar to top, htop, vmstat. [Command-line Based Observer Tool](https://www.rabbitmq.com/monitoring.html#diagnostics-observer)

## 概念介绍

[消息队列之 RabbitMQ - 简书](https://www.jianshu.com/p/79ca08116d57)

### 消息模型

所有 MQ 产品从模型抽象上来说都是一样的过程：

消费者（consumer）订阅某个队列。生产者（producer）创建消息，然后发布到队列（queue）中，最后将消息发送到监听的消费者。

RabbitMQ 是 AMQP 协议的一个开源实现，所以其内部实际上也是 AMQP 中的基本概念

![RabbitMQ 内部结构](image/rabbitmq.amqp.png)

1. Message: 消息，消息是不具名的，它由消息头和消息体组成。消息体是不透明的，而消息头则由一系列的可选属性组成，这些属性包括routing-key（路由键）、priority（相对于其他消息的优先权）、delivery-mode（指出该消息可能需要持久性存储）等。
2. Publisher 消息的生产者，也是一个向交换器发布消息的客户端应用程序。
3. Exchange 交换器 接收，分配消息，用来接收生产者发送的消息并将这些消息路由给服务器中的队列。
4. Binding 绑定，用于消息队列和交换器之间的关联。一个绑定就是基于路由键将交换器和消息队列连接起来的路由规则，所以可以将交换器理解成一个由绑定构成的路由表。
5. Queue 消息队列，用来保存消息直到发送给消费者。它是消息的容器，也是消息的终点。一个消息可投入一个或多个队列。消息一直在队列里面，等待消费者连接到这个队列将其取走。
6. Connection 网络连接，比如一个TCP连接。
7. Channel 信道，多路复用连接中的一条独立的双向数据流通道。信道是建立在真实的TCP连接内地虚拟连接，AMQP 命令都是通过信道发出去的，不管是发布消息、订阅队列还是接收消息，这些动作都是通过信道完成。因为对于操作系统来说建立和销毁 TCP 都是非常昂贵的开销，所以引入了信道的概念，以复用一条 TCP 连接。
8. Consumer 消息的消费者，表示一个从消息队列中取得消息的客户端应用程序。
9. Virtual Host 虚拟主机，表示一批交换器、消息队列和相关对象。虚拟主机是共享相同的身份认证和加密环境的独立服务器域。每个 vhost 本质上就是一个 mini 版的 RabbitMQ 服务器，拥有自己的队列、交换器、绑定和权限机制。vhost 是 AMQP 概念的基础，必须在连接时指定，RabbitMQ 默认的 vhost 是 / 。
10. Broker 表示消息队列服务器实体。

### AMQP 中的消息路由

AMQP 中消息的路由过程和 Java 开发者熟悉的 JMS 存在一些差别，AMQP 中增加了 Exchange 和 Binding 的角色。生产者把消息发布到 Exchange 上，消息最终到达队列并被消费者接收，而 Binding 决定交换器的消息应该发送到那个队列。

![AMQP 的消息路由过程](image/AMQP.message.routing.png)

### Exchange 类型

Exchange分发消息时根据类型的不同分发策略有区别，目前共四种类型：direct、fanout、topic、headers 。headers 匹配 AMQP 消息的 header 而不是路由键，此外 headers 交换器和 direct 交换器完全一致，但性能差很多，目前几乎用不到了。

#### direct

消息中的路由键（routing key）如果和 Binding 中的 binding key 一致， 交换器就将消息发到对应的队列中。路由键与队列名完全匹配，如果一个队列绑定到交换机要求路由键为“dog”，则只转发 routing key 标记为“dog”的消息，不会转发“dog.puppy”，也不会转发“dog.guard”等等。它是完全匹配、单播的模式。

![direct 交换器](image/exchange.direct.png)

#### fanout

每个发到 fanout 类型交换器的消息都会分到所有绑定的队列上去。fanout 交换器不处理路由键，只是简单的将队列绑定到交换器上，每个发送到交换器的消息都会被转发到与该交换器绑定的所有队列上。很像子网广播，每台子网内的主机都获得了一份复制的消息。fanout 类型转发消息是最快的。

![fanout 交换器](image/exchange.fanout.png)

#### topic

topic 交换器通过模式匹配分配消息的路由键属性，将路由键和某个模式进行匹配，此时队列需要绑定到一个模式上。它将路由键和绑定键的字符串切分成单词，这些单词之间用点隔开。它同样也会识别两个通配符：符号`#`和符号`*`。`#`匹配0个或多个单词，`*`匹配不多不少一个单词。

![topic 交换器](image/exchange.topic.png)

### 消息如何保证100％投递

什么是生产端的可靠性投递？

1. 保证消息的成功发出
2. 保证MQ节点节点的成功接收
3. 发送端MQ节点（broker）收到消息确认应答
4. 完善消息进行补偿机制

### 保证高可用的?RabbitMQ 的集群

单机模式
普通集群模式：多台机器上启动多个 RabbitMQ 实例，每个实例都同步 queue 的元数据，但消息是单机存储
镜像集群模式：才是所谓的 RabbitMQ 的高可用模式，无论元数据还是 queue 里的消息都会存 在于多个实例上

### RabbitMQ vs. Kafka vs. ActiveMQ vs. RocketMQ

[入门RabbitMQ消息队列，看这篇文章就够了 - 掘金](https://juejin.cn/post/6844904113788944397)

[RabbitMQ vs Kafka：正面交锋！](https://mp.weixin.qq.com/s/uOkEXw-jMpuZOp6JteArPw)

RabbitMQ 是一个消息代理中间件，而 Apache Kafka 是一个分布式流处理平台。这种差异可能看起来只是语义上的，但它会带来严重的影响，影响我们方便地实现各种系统功能。

例如 Kafka 最适合处理流数据，在同一主题同一分区内保证消息顺序，而 RabbitMQ 对流中消息的顺序只提供基本的保证。

不过 RabbitMQ 内置了对重试逻辑和死信交换的支持，而 Kafka 将此类逻辑实现留给了用户。

1. 消息顺序
   1. RabbitMQ 对发送到队列或交换器的消息的顺序性提供了很少的保证：可以通过将消费者并发数限制为 1 来重新保证 RabbitMQ 中的消息顺序
   2. Kafka 为消费者在消息处理时提供了可靠的排序保证。Kafka 保证发送到同一主题分区的所有消息都按顺序处理。
2. 消息路由
   1. RabbitMQ 可以根据订阅者定义的路由规则将消息路由到消息交换机的订阅者。
   2. Kafka 不允许消费者在轮询主题之前过滤主题中的消息。订阅的消费者无一例外地接收分区中的所有消息。
3. 消息计时
   1. RabbitMQ 提供了延时消息发送到队列
      1. 消息生存时间 (TTL)，如果消费者没有及时处理它，那么它会自动从队列中删除，并转移到死信交换
      2. RabbitMQ 通过使用插件支持延迟/预定消息
   2. Kafka 不支持此类功能。当消息到达时，它将消息写入分区，消费者可以立即使用它们。需要在应用程序级别实现。
      1. Kafka 分区是一个仅追加的事务日志。因此它无法操纵消息时间（或分区内的位置）。
4. 消息保留
   1. 一旦消费者成功消费消息，RabbitMQ 就会从存储中删除消息。
   2. Kafka 根据设计将所有消息保留至每个主题配置的超时时间。在消息保留方面，Kafka 不关心消费者的消费状态，因为它充当消息日志。
5. 故障处理
   1. RabbitMQ 提供了传递重试和死信交换 (DLX) 等工具来处理消息处理失败。
   2. Kafka 不提供任何开箱即用的此类工具。需要在应用程序中提供和实现消息重试机制。
6. 扩展性
   1. Kafka 通常被认为比 RabbitMQ 具有更好的性能。Kafka 使用顺序磁盘 I/O 来提高性能。它使用分区的架构意味着它的水平扩展（横向扩展）比 RabbitMQ 更好，而 RabbitMQ 的垂直扩展（纵向扩展）更好。
7. 消费者复杂性
   1. RabbitMQ 消费者能有效地扩展和缩小。RabbitMQ 使用智能代理人（smart-broker）和愚蠢消费者（dumb-consumer）的方法。消费者注册到消费队列上，RabbitMQ 会在消息进入时向它们推送消息以进行处理。RabbitMQ 消费者还具有主动拉取的功能。不过它使用的比较少。
   2. Kafka 使用愚蠢代理人（dumb-broker）和聪明消费者（smart-consumer）的方法。消费者组中的消费者需要协调它们之间主题分区的约定（以便消费者组中只有一个消费者监听特定分区）。

#### 何时使用哪个？

一般情况下，RabbitMQ 是更好的选择：

1. 先进灵活的路由规则。
2. 消息计时控制（控制消息过期或消息延迟）。
3. 高级故障处理功能，以防消费者无法处理消息（暂时或永久）。
4. 更简单的消费者实现。

当我们需要以下条件时，Kafka 是更好的选择：

1. 严格的消息排序。
2. 消息保留较长时间，包括重放过去消息的可能性。
3. 当传统解决方案无法满足我们对扩展性的需求时，Kafka 能够达到较高的规模。

我们可以使用这两个平台来用于大多数软件系统。然而作为架构师，我们有责任选择最适合这个系统的工具。在做出这种选择时，我们应该考虑如上所述的功能差异和非功能限制。

这些非功能限制包括：

1. 当前平台的现有开发人员掌握知识。
2. 托管云解决方案的可用性（如果适用）。
3. RabbitMQ 和 Kafka 的运营成本。
4. 我们的目标技术栈中 SDK 的可用性。

## Erlang 垃圾回收

[Erlang垃圾回收](https://www.ttalk.im/2021/11/erlang-garbage-collector.html)

## Installation

[Downloading and Installing RabbitMQ](https://www.rabbitmq.com/download.html)

### Installing RabbitMQ in a Kubernetes cluster

[Installing RabbitMQ Cluster Operator in a Kubernetes cluster](https://www.rabbitmq.com/kubernetes/operator/install-operator.html)
[Using RabbitMQ Cluster Kubernetes Operator](https://www.rabbitmq.com/kubernetes/operator/using-operator.html)
[Deploying RabbitMQ to Kubernetes: What’s Involved?](https://www.rabbitmq.com/blog/2020/08/10/deploying-rabbitmq-to-kubernetes-whats-involved/)

### Ubuntu

install erlang

```bash
wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb
dpkg -i erlang-solutions_1.0_all.deb
apt update
apt install erlang erlang-nox
```

install rabbitmq `apt-get install rabbitmq-server`

### [Production Checklist](https://www.rabbitmq.com/production-checklist.html)

#### Virtual Hosts

In multi-tenant environments, use a separate vhost for each tenant/environment, e.g. project1_development, project1_production, project2_development, project2_production, and so on.

### Monitor

### monitor rabbitMQ by shell

```bash
#!/bin/env bash
# Desc:Monitor RabbitMQ processs
# config crontab
# * * * * * /data/apps/shell/rabbitmq-monitor.sh >> /data/logs/scripts/rabbitmq-monitor.log 2>&1

DATE=`date -d now "+%Y-%m-%d %H:%M:%S"`
TARGET="vhost_name"
RESULT=$(/usr/sbin/rabbitmqctl list_vhosts | grep $TARGET)
if [ "$RESULT" == "$TARGET" ];then
 echo ${DATE} "Service RabbitMQ is running. result $RESULT"
else
 echo ${DATE} "Restart RabbitMQ"
 /sbin/service rabbitmq-server start
fi
```
