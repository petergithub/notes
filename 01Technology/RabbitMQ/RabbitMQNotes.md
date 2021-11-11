# RabbitMQ

[RabbitMQ Server](https://github.com/rabbitmq/rabbitmq-server/)

## [Troubleshooting Guidance](https://www.rabbitmq.com/troubleshooting.html)

crash file /usr/local/rabbitmq/var/lib/rabbitmq/erl_crash.dump

## Basic command

[Command Line Tools](https://www.rabbitmq.com/cli.html)

`rabbitmqctl` for service management and general operator tasks
`rabbitmq-diagnostics` for diagnostics and health checking
`rabbitmq-plugins` for plugin management
`rabbitmq-queues` for maintenance tasks on queues, in particular quorum queues
`rabbitmq-upgrade` for maintenance tasks related to upgrades

``` bash
service rabbitmq-server start
service rabbitmq-server stop
service rabbitmq-server status
rabbitmqctl status
rabbitmqctl environment # 环境信息
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

By default, RabbitMQ have a user named guest with password guest. We will create own administrator account on RabbitMQ server, change password :

``` bash
rabbitmqctl add_user admin password
rabbitmqctl set_user_tags admin administrator
rabbitmqctl set_permissions -p / admin ".*" ".*" ".*"

rabbitmqctl add_vhost vhost_name
rabbitmqctl set_permissions -p vhost_name admin ".*" ".*" ".*"
```

RabbitMQ has a web management console. To enable web management console run : `rabbitmq-plugins enable rabbitmq_management`
`http://localhost:15672/   guest / guest`

`curl -i -u guest:guest "http://localhost:15672/api/overview"`
`curl -i -u guest:guest "http://localhost:15672/api/queues/push-center/push.schedule.push.queue.name.publish"`

The OS limits are controlled via a configuration file at `/etc/systemd/system/rabbitmq-server.service.d/limits.conf`

rabbitmq-diagnostics status
rabbitmqctl --help
rabbitmq-diagnostics status --help

`rabbitmq-diagnostics observer` is a command-line tool similar to top, htop, vmstat. [Command-line Based Observer Tool](https://www.rabbitmq.com/monitoring.html#diagnostics-observer)

## Installation

[Downloading and Installing RabbitMQ](https://www.rabbitmq.com/download.html)

### Installing RabbitMQ in a Kubernetes cluster

[Installing RabbitMQ Cluster Operator in a Kubernetes cluster](https://www.rabbitmq.com/kubernetes/operator/install-operator.html)
[Using RabbitMQ Cluster Kubernetes Operator](https://www.rabbitmq.com/kubernetes/operator/using-operator.html)
[Deploying RabbitMQ to Kubernetes: What’s Involved?](https://www.rabbitmq.com/blog/2020/08/10/deploying-rabbitmq-to-kubernetes-whats-involved/)

### Ubuntu

install erlang

``` bash
wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb
dpkg -i erlang-solutions_1.0_all.deb
apt update
apt install erlang erlang-nox
```

install rabbitmq `apt-get install rabbitmq-server`

### [Production Checklist](https://www.rabbitmq.com/production-checklist.html)

#### Virtual Hosts

In multi-tenant environments, use a separate vhost for each tenant/environment, e.g. project1_development, project1_production, project2_development, project2_production, and so on.
