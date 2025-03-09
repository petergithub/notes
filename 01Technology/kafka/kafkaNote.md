# Kafka Note

version kafka_2.13-3.8.0

[Apache Kafka quickstart](https://kafka.apache.org/quickstart)
[Apache Kafka documentation](https://kafka.apache.org/documentation/)
[Apache Kafka downloads](https://kafka.apache.org/downloads)

[使用kafka kraft模式安装kafka集群，不再依赖 zookeeper 集群 - 哈喽哈喽111111 - 博客园](https://www.cnblogs.com/hahaha111122222/p/17611504.html)
[基于KRaft协议搭建高可用Kafka集群 | 浅时光博客](https://www.dqzboy.com/10332.html)
[基于kraft搭建kafka集群 · sqlfans](https://wiki.sqlfans.cn/linux/kafka-cluster-setup.html)
[Setup Kafka cluster with Kraft. We provided a set of instructions for… | by 𝐒𝐚𝐤𝐞𝐭 𝐉𝐚𝐢𝐧 | Medium](https://jainsaket-1994.medium.com/setup-kafka-cluster-with-kraft-561f281b8e2a)

Shift from ZooKeeper to Kraft

[Kafka’s Shift from ZooKeeper to Kraft | Baeldung](https://www.baeldung.com/kafka-shift-from-zookeeper-to-kraft)
[KIP-500: Replace ZooKeeper with a Self-Managed Metadata Quorum - Apache Kafka - Apache Software Foundation](https://cwiki.apache.org/confluence/display/KAFKA/KIP-500%3A+Replace+ZooKeeper+with+a+Self-Managed+Metadata+Quorum)

## kafka cli

[Kafka Command Line Interface (CLI) Tools | Confluent Documentation](https://docs.confluent.io/kafka/operations-tools/kafka-tools.html)

### 查看集群信息

```sh
# shows information about the cluster and its members
kafka-metadata-quorum.sh --bootstrap-controller localhost:9093 describe --status
# ClusterId:              focE_KxyTBOdXB7
# LeaderId:               1
# LeaderEpoch:            49
# HighWatermark:          17912
# MaxFollowerLag:         0
# MaxFollowerLagTimeMs:   0
# CurrentVoters:          [1,2,3]
# CurrentObservers:       []

kafka-broker-api-versions.sh  --bootstrap-server kafka01:9092,kafka02:9092,kafka03:9092  | awk '/id/{print $1}'
kafka-broker-api-versions.sh  --bootstrap-server localhost:9092  | awk '/id/{print $1}'
kafka01:9092
kafka02:9092

# Show the version of the Kafka broker
kafka-broker-api-versions.sh --bootstrap-server localhost:9092 --version
```

### kafka-topic

```sh
# list all the available topics
kafka-topics.sh --bootstrap-server localhost:9092 --list

# Created topic quickstart-events
# before you can write your first events, you must create a topic
kafka-topics.sh --bootstrap-server localhost:9092 --topic quickstart-events --create

# 创建topic：任一节点，指定broker及3个partition及2个副本
# by default, a topic is created with just one partition, which may not be sufficient for most use cases. Therefore, we need to add a partitions keyword to our second test topic to specify the number of partitions required.
kafka-topics.sh --bootstrap-server localhost:9092 --topic quickstart-events --create --partitions 3 --replication-factor 2

# display usage information
kafka-topics.sh --bootstrap-server localhost:9092 --topic quickstart-events --describe

# delete topic
kafka-topics.sh --bootstrap-server localhost:9092 --topic quickstart-events --delete
```

### kafka producer

[Kafka Producer | Confluent Documentation](https://docs.confluent.io/platform/current/clients/producer.html)

```sh
# Write some events into the topic
kafka-console-producer.sh --bootstrap-server localhost:9092 --topic quickstart-events
>This is my first event
>This is my second event
# You can stop the producer client with Ctrl-C at any time.

# Read the events
kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic quickstart-events --from-beginning
This is my first event
This is my second event
# You can stop the consumer client with Ctrl-C at any time.

# specify extra properties by using the producer-property option
kafka-console-producer.sh --bootstrap-server localhost:9092 --topic first_topic --producer-property acks=all
kafka-console-producer.sh --bootstrap-server localhost:9092 --topic first_topic --property parse.key=true --property key.separator=:
>name:keyName
>second key:second value
```

### Kafka Consumer

[Kafka Consumer | Confluent Documentation](https://docs.confluent.io/platform/current/clients/consumer.html)

```sh
kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic second_topic --formatter kafka.tools.DefaultMessageFormatter --property print.timestamp=true --property print.key=true --property print.value=true --property print.partition=true --from-beginning
```

### delete messages from Kafka

```sh
# specified that for the partition 0 of the topic “my_topic” we want to delete all the records from the beginning until offset 3. (exlusive 开区间)
# offset -1 删除所有
tee delete-records.json <<EOF
{
    "partitions": [
        {
            "topic": "my_topic",
            "partition": 0,
            "offset": 3
        },
        {
            "topic": "my_topic",
            "partition": 1,
            "offset": 3
        }
    ],
    "version": 1
}
EOF
kafka-delete-records.sh --bootstrap-server localhost:9092 --offset-json-file delete-records.json

# 获取指定时间戳的 offset
# 获取到最接近指定时间戳的Offset。这个工具会返回每个Partition最接近指定时间戳的Offset。
# time -1  To check the end offset set parameter time to value -1
# time -2  To check the start offset, use –time -2
# time 1730908800000
kafka-run-class org.apache.kafka.tools.GetOffsetShell \
--bootstrap-server localhost:9092 \
--topic my_topic \
--time 1730908800000

# Change the retention period

# Use the kafka-configs command line tool to alter the retention policy for the topic to a very short period of time. Once the retention period has expired, the messages will be deleted automatically.
kafka-configs.sh \
  --alter \
  --entity-type topics \
  --entity-name my_topic \
  --add-config retention.ms=1000
```

### Checking consumer position

[Apache Kafka Managing Consumer Groups](https://kafka.apache.org/documentation/#basic_ops_consumer_group)
[kafka-consumer-groups.sh - Kafka Command Line Interface (CLI) Tools | Confluent Documentation](https://docs.confluent.io/kafka/operations-tools/kafka-tools.html#kafka-consumer-groups-sh)

```sh
kafka-consumer-groups.sh --help

# list all consumer groups across all topics
kafka-consumer-groups.sh --bootstrap-server localhost:9092 --list

# view offsets
kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --group my_group

# To manually delete one or multiple consumer groups, the "--delete" option can be used:
kafka-consumer-groups.sh --bootstrap-server localhost:9092 --delete --group my_group --group my_other_group

# To reset offsets of a consumer group：to display
kafka-consumer-groups.sh --bootstrap-server localhost:9092 --reset-offsets --group consumergroup1 --topic topic1 --to-latest
# To reset the offsets back by 20 positions, use the following command: to execute
kafka-consumer-groups.sh --bootstrap-server localhost:9092 --reset-offsets --group consumergroup1 --topic test-metrics --shift-by -20 -execute


# --reset-offsets has 3 execution options:

# * (default) to display which offsets to reset.
# * --execute : to execute --reset-offsets process.
# * --export : to export the results to a CSV format.

# --reset-offsets also has the following scenarios to choose from (at least one scenario must be selected):

# Reset offsets to offsets from datetime. Format: 'YYYY-MM-DDTHH:mm:SS.sss'
--to-datetime <String: datetime>
# Reset offsets to earliest offset. to the beginning
--to-earliest
# Reset offsets to latest offset.
--to-latest
# Reset offsets shifting current offset by 'n', where 'n' can be positive or negative.
--shift-by <Long: number-of-offsets>
# Reset offsets to values defined in CSV file.
--from-file
# Resets offsets to current offset.
--to-current
# Reset offsets to offset by duration from current timestamp. Format: 'PnDTnHnMnS'
--by-duration <String: duration>
# Reset offsets to a specific offset.
--to-offset
```

--reset-offsets also has the following scenarios to choose from (at least one scenario must be selected):

* --to-datetime <String: datetime> : Reset offsets to offsets from datetime. Format: 'YYYY-MM-DDTHH:mm:SS.sss'
* --to-earliest : Reset offsets to earliest offset.
* --to-latest : Reset offsets to latest offset.
* --shift-by <Long: number-of-offsets> : Reset offsets shifting current offset by 'n', where 'n' can be positive or negative.
* --from-file : Reset offsets to values defined in CSV file.
* --to-current : Resets offsets to current offset.
* --by-duration <String: duration> : Reset offsets to offset by duration from current timestamp. Format: 'PnDTnHnMnS'
* --to-offset : Reset offsets to a specific offset.

## kafka Java client

[Chapter 6. Developing a Kafka client | Red Hat Product Documentation](https://docs.redhat.com/en/documentation/red_hat_streams_for_apache_kafka/2.5/html/developing_kafka_client_applications/proc-generic-java-client-str#proc-generic-java-client-str)

## kafka 3.8.0 installation

version kafka_2.13-3.8.0

数据目录：/data/kafka-data/kraft-combined-logs
日志目录：/data/log/data
启动命令：sudo systemctl start kafka.service
停止命令：sudo systemctl stop kafka.service

```sh
# install kafka
tar xf /data/package/kafka_2.13-3.8.0.tgz -C /data/software
ls /data/software/kafka_2.13-3.8.0
mkdir -p /data/kafka-data/

# 复制nfs 共享的文件后修改
cp /data/package/kafka/server.properties config/kraft/server.properties

# 打印出修改的值 确认
cat /data/software/kafka_2.13-3.8.0/config/kraft/server.properties | grep -Ev '^$|#' | egrep "(controller.quorum.voters|process.|node.id|controller.|listeners|log.dir|num.partitions|sadvertised.|offsets.topic.replication.factor|transaction.state.log.)"

# get Cluster id
KAFKA_CLUSTER_ID="$(bin/kafka-storage.sh random-uuid)"

# 在三台sever 上使用相同的 Cluster id 执行 format
cd /data/software/kafka_2.13-3.8.0
bin/kafka-storage.sh format -t $KAFKA_CLUSTER_ID -c config/kraft/server.properties

cat > /data/software/kafka_2.13-3.8.0/kafka.service << EOF
# cat > /etc/systemd/system/kafka.service << EOF
# cat > /usr/lib/systemd/system/kafka.service << EOF
[Unit]
Description=Apache Kafka server (broker)
After=network.target

[Service]
Type=forking
User=root
Group=root
Environment="PATH=/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/data/software/openjdk-21.0.2/bin"

ExecStart=/data/software/kafka_2.13-3.8.0/bin/kafka-server-start.sh -daemon /data/software/kafka_2.13-3.8.0/config/kraft/server.properties
ExecStop=/data/software/kafka_2.13-3.8.0/bin/kafka-server-stop.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl status kafka.service
sudo systemctl enable kafka.service
sudo systemctl restart kafka.service

# 在三台 启动
nohup /data/software/kafka_2.13-3.8.0/bin/kafka-server-start.sh /data/software/kafka_2.13-3.8.0/config/kraft/server.properties > /data/log/kafka/kafka_startup.log 2>&1 &
# 检查端口 socket server listens on 9092  controller port 9093
sudo netstat -lnpt | egrep "(9092|9093)"

```

文件内容 /data/software/kafka_2.13-3.8.0/config/kraft/server.properties

```sh
# 文件内容 /data/software/kafka_2.13-3.8.0/config/kraft/server.properties

# Configuring the First Node
controller.quorum.voters=1@kafka01:9093,2@kafka02:9093,3@kafka03:9093

# The address the socket server listens on.
# Combined nodes (i.e. those with `process.roles=broker,controller`) must list the controller listener here at a minimum.
# If the broker listener is not defined, the default listener will use a host name that is equal to the value of java.net.InetAddress.getCanonicalHostName(),
listeners=PLAINTEXT://:9092,CONTROLLER://:9093
#listeners=PLAINTEXT://kafka01:9092,CONTROLLER://kafka01:9093

# Listener name, hostname and port the broker will advertise to clients.
# If not set, it uses the value for "listeners".
advertised.listeners=PLAINTEXT://kafka01:9092


# A comma separated list of directories under which to store log files
# log.dirs=/tmp/kraft-combined-logs
log.dirs=/data/kafka-data/kraft-combined-logs-0,/data/kafka-data/kraft-combined-logs-1,/data/kafka-data/kraft-combined-logs-2

# The default number of log partitions per topic. More partitions allow greater
# parallelism for consumption, but this will also result in more files across
# the brokers.
# num.partitions=1
num.partitions=3

############################# Internal Topic Settings  #############################
# The replication factor for the group metadata internal topics "__consumer_offsets" and "__transaction_state"
# For anything other than development testing, a value greater than 1 is recommended to ensure availability such as 3.
# offsets.topic.replication.factor=1
# transaction.state.log.replication.factor=1
# transaction.state.log.min.isr=1
offsets.topic.replication.factor=3
transaction.state.log.replication.factor=3
transaction.state.log.min.isr=2
```

### 安装后验证

```sh
# shows information about the cluster and its members
bin/kafka-metadata-quorum.sh --bootstrap-controller localhost:9093 describe --status
# ClusterId:              focE_KxyTBOdXB7
# LeaderId:               1
# LeaderEpoch:            49
# HighWatermark:          17912
# MaxFollowerLag:         0
# MaxFollowerLagTimeMs:   0
# CurrentVoters:          [1,2,3]
# CurrentObservers:       []

kafka-broker-api-versions.sh  --bootstrap-server kafka01:9092,kafka02:9092,kafka03:9092  | awk '/id/{print $1}'
kafka-broker-api-versions.sh  --bootstrap-server localhost:9092  | awk '/id/{print $1}'
kafka01:9092
kafka02:9092

# Create a topic to store your events
# before you can write your first events, you must create a topic.
bin/kafka-topics.sh --create --topic quickstart-events --bootstrap-server localhost:9092

# display usage information
bin/kafka-topics.sh --describe --topic quickstart-events --bootstrap-server localhost:9092

# Write some events into the topic
bin/kafka-console-producer.sh --topic quickstart-events --bootstrap-server localhost:9092
>This is my first event
>This is my second event
# You can stop the producer client with Ctrl-C at any time.

# Read the events
bin/kafka-console-consumer.sh --topic quickstart-events --from-beginning --bootstrap-server localhost:9092
This is my first event
This is my second event
# You can stop the consumer client with Ctrl-C at any time.

# 创建topic：任一节点，指定broker及1个partition及3个副本
bin/kafka-topics.sh --create --bootstrap-server localhost:9092 --replication-factor 3 --partitions 1 --topic test1

kafka-topics.sh --list --bootstrap-server localhost:9092
```

### kafka ui安装部署

[kafka-ui](https://github.com/provectus/kafka-ui)
[Configuration wizard | UI for Apache Kafka](https://docs.kafka-ui.provectus.io/configuration/configuration-wizard)
[kafka-ui/documentation/compose/kafka-ui-auth-context.yaml](https://github.com/provectus/kafka-ui/blob/master/documentation/compose/kafka-ui-auth-context.yaml)

```sh
# kafka ui安装部署
# docker run --name kafka-ui -d -p 8080:8080 -e DYNAMIC_CONFIG_ENABLED=true -e KAFKA_CLUSTERS_0_NAME="local" -e KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS="localhost:9092" --restart always provectuslabs/kafka-ui:master

# 1. Get the application URL by running these commands:
#   export POD_NAME=$(kubectl get pods --namespace ems-test -l "app.kubernetes.io/name=kafka-ui,app.kubernetes.io/instance=kafka-ui" -o jsonpath="{.items[0].metadata.name}")
#   echo "Visit http://127.0.0.1:8080 to use your application"
#   kubectl --namespace ems-test port-forward $POD_NAME 8080:8080
# https://registry-1.docker.io/v2/provectuslabs/kafka-ui/manifests/v0.7.2
# docker.io/provectuslabs/kafka-ui:v0.7.2
helm install kafka-ui kafka-ui-0.7.6.tgz -f values.yaml --set existingConfigMap="kafka-ui-helm-values" --namespace software
# helm delete kafka-ui --namespace software

```

## kafka monitor

```sh
# JMXTool工具
bin/kafka-run-class.sh org.apache.kafka.tools.JmxTool

bin/kafka-run-class.sh org.apache.kafka.tools.JmxTool --object-name kafka.server:type=BrokerTopicMetrics,name=BytesInPerSec --jmx-url service:jmx:rmi:///jndi/rmi://:9997/jmxrmi --date-format "YYYY-MM-dd HH:mm:ss" --attributes OneMinuteRate --reporting-interval 1000

$KAFKA_HEAP_OPTS
$KAFKA_JVM_PERFORMANCE_OPTS
$KAFKA_GC_LOG_OPTS
$KAFKA_JMX_OPTS
$KAFKA_LOG4J_OPTS
```

JMXTrans + InfluxDB + Grafana

## Kafka tuning

### Linux /etc/security/limits.conf

```sh
# /etc/security/limits.conf
# The value of the hard nofile parameter cannot be greater than the value of the /proc/sys/fs/nr_open parameter. Otherwise, you may fail to connect to the ECS instance

sudo tee -a /etc/security/limits.d/kafka.conf <<EOF

* soft nofile 131072
* hard nofile 131072
* soft nproc 131072
* hard nproc 131072
* soft core unlimited
* hard core unlimited
* soft memlock 50000000
* hard memlock 50000000
EOF

```

### Linux /etc/sysctl.conf

https://www.alibabacloud.com/help/en/ecs/support/common-kernel-network-parameters-of-ecs-linux-instances-and-faq

```sh
# /etc/sysctl.conf
net.ipv6.conf.all.disable_ipv6 = 0
net.ipv6.conf.default.disable_ipv6 = 0
net.ipv6.conf.default.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_source_route = 0
net.ipv6.conf.all.accept_ra = 0
net.ipv6.conf.default.accept_ra = 0
net.ipv6.conf.all.accept_source_route = 0
net.ipv6.conf.all.forwarding = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.conf.default.accept_redirects = 0
kernel.randomize_va_space=2
net.ipv4.tcp_syncookies=1
net.ipv4.conf.all.rp_filter=1
net.ipv4.conf.default.rp_filter=1
net.ipv4.conf.default.accept_source_route=0
net.ipv4.icmp_echo_ignore_broadcasts=1
net.ipv4.ip_forward=0
net.ipv4.conf.all.send_redirects=0
net.ipv4.conf.default.send_redirects=0
net.ipv4.tcp_max_orphans=256
net.ipv4.conf.all.log_martians=1
net.ipv4.tcp_keepalive_intvl=25
net.ipv4.tcp_keepalive_probes=5
net.ipv4.tcp_fin_timeout=20
net.ipv4.tcp_max_syn_backlog=8192
net.core.somaxconn=8192
net.core.netdev_max_backlog=8192
net.ipv4.ip_local_port_range=10000 65000
fs.file-max=1000000
net.core.wmem_max=12582912
net.core.rmem_max=12582912
net.ipv4.tcp_rmem=10240 87380 12582912
net.ipv4.tcp_wmem=10240 87380 12582912
net.ipv4.tcp_mem=578522 704696 957044
net.ipv4.tcp_tw_reuse=1
net.ipv4.tcp_max_tw_buckets=0
fs.suid_dumpable=0
vm.swappiness=1
```

### Linux Disable Transparent Huge Pages

```sh
echo never > /sys/kernel/mm/transparent_hugepage/defrag
echo never > /sys/kernel/mm/transparent_hugepage/enabled
```

### Linux 参数

swap 关闭

```sh
# stop swap
cat /etc/fstab
sudo swapoff -a
# sed -ri 's/.swap./#&/' /etc/fstab
# swap 在一行的中间 注释该行
sudo sed -ri 's/^[^#]*swap/#&/' /etc/fstab
```

### Kafka Broker Parameter

Broker端参数

```sh
# 这是非常重要的参数，指定了Broker需要使用的若干个文件目录路径。用逗号分隔的多个路径，比如/home/kafka1,/home/kafka2,/home/kafka3这样。如果有条件的话你最好保证这些目录挂载到不同的物理磁盘上
log.dirs=/data/kafka1,/data/kafka2,/data/kafka3

# 关于Topic管理的
# 是否允许自动创建Topic, 不允许自动创建Topic
auto.create.topics.enable = false
# 是否允许Unclean Leader选举, 不允许落后进度太多的副本竞选
unclean.leader.election.enable = false
# 是否允许定期进行Leader选举
auto.leader.rebalance.enable = false

# 数据留存方面的
# 控制一条消息数据被保存多长时间。从优先级上来说ms设置最高、minutes次之、hours最低。
# log.retention.{hours|minutes|ms}
# The minimum age of a log file to be eligible for deletion due to age
log.retention.hours=168

# 指定Broker为消息保存的总磁盘容量大小，默认值-1 表明不设置上限
log.retention.bytes = -1
# 控制Broker能够接收的最大消息大小 Default: 1048588
# The largest record batch size allowed by Kafka (after compression if compression is enabled)
message.max.bytes = 1048588
```

### Kafka JVM 参数

KAFKA_HEAP_OPTS：指定堆大小。
KAFKA_JVM_PERFORMANCE_OPTS：指定GC参数。
