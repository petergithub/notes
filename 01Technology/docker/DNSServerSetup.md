# DNS Server in Docker 搭建步骤

[linux搭建简单DNS服务器，实现域名解析到任意ip](http://blog.51cto.com/lookingdream/1853525 )
[Dockerfile for systemd](https://unix.stackexchange.com/questions/276340/linux-command-systemctl-status-is-not-working-inside-a-docker-container)
[Failed to get D-Bus connection: No connection to service manager - CentOS 7](https://github.com/moby/moby/issues/7459 )

## Prepare files

### /etc/named.conf

将listen-on port 和 allow-query后面都改为any
`listen-on port 53 { any; }; // 监听在主机的53端口上。any代表监听所有的主机`
`allow-query     { any; }; // 谁可以对我的DNS服务器提出查询请求。any代表任何人`  

log file: `/var/named/data/named.run`  

### /etc/named.rfc1912.zones

要添加`example.com`这个域的解析可以添加下面这一段

``` shell

    zone "example.com" IN {    // 定义要解析主域名
            type master;
            file "example.com.zone";  // 具体相关解析的配置文件保存在 /var/named/example.com.zone 文件中
    };
```

### 自定义 example.com.zone 文件

``` shell

    $TTL 86400
    @       IN SOA          ns.example.com. root (
                                            1       ; serial
                                            1D      ; refresh
                                            1H      ; retry
                                            1W      ; expire
                                            0 )     ; minimum  

    @       IN      NS      ns.example.com.
    ns      IN      A       172.18.0.2
    www     IN      A       172.18.0.1
    bbs     IN      A       172.18.0.1
    ttt     IN      A       172.18.0.1


// 其中   ns.example.com 代表当前dns服务器名称。所以  ns.example.com 一定要解析到自己本身
`www     IN      A       172.18.0.1`  // 代表 `www.example.com` 解析到`172.18.0.1` 服务器上。其他的类似


## Setup docker container
`docker image build -t dns-demo /path/to/DockerfileFolder`  
# --cap-add=NET_ADMIN: add privileges for network
`docker run -it --name=dns-demo --cap-add SYS_ADMIN --security-opt seccomp=unconfined --cap-add=NET_ADMIN -v /run -v /sys/fs/cgroup:/sys/fs/cgroup:ro dns-demo`  
`docker exec -it dns-demo bash`  
`ip a` get <dns_docker_ip>  

``` Dockerfile
    FROM centos:7

    ENV container docker

    RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
    systemd-tmpfiles-setup.service ] || rm -f $i; done); \
    rm -f /lib/systemd/system/multi-user.target.wants/*;\
    rm -f /etc/systemd/system/*.wants/*;\
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*;\
    rm -f /lib/systemd/system/anaconda.target.wants/*;

    # Install anything. The service you want to start must be a SystemD service.

    RUN yum install -y bind bind-utils iproute
    COPY named.conf /etc/named.conf
    COPY named.rfc1912.zones /etc/named.rfc1912.zones
    COPY example.com.zone /var/named/example.com.zone

    RUN chown root:named /etc/named* /var/named/example.com.zone

    VOLUME [ "/sys/fs/cgroup" ]
    CMD ["/usr/sbin/init"]
```

## Start DNS Service

`systemctl start named`

## Config filewall

开放 UDP 端口 53
`firewall-cmd --zone=public --add-port=53/udp --permanent && firewall-cmd --reload`

## Client

set DNS IP: add `nameserver  <dns_docker_ip>` at the top of /etc/resolv.conf

## Verfication

`host www.example.com <dns_docker_ip>`

## 新增域名解析

新增一个 比如`example2.com`

### `/etc/named.rfc1912.zones`

添加下面这段

``` shell
    zone "example2.com" IN {
            type master;
            file "example2.com.zone";
    };
```

### /var/named/example2.com.zone

`cp -a /var/named/example.com.zone /var/named/example2.com.zone` 并修改其中域名内容

### 配置完成之后重启服务

## Deploying a DNS Server using Docker

[Deploying a DNS Server using Docker](http://www.damagehead.com/blog/2015/04/28/deploying-a-dns-server-using-docker/ )
[docker-bind](https://github.com/sameersbn/docker-bind )

``` shell

docker run -d --name=bind --dns=127.0.0.1 \
    --publish=172.18.0.1:53:53/udp --publish=172.18.0.1:10000:10000 \
    --volume=/srv/docker/bind:/data \
    --env='ROOT_PASSWORD=root' \
    sameersbn/bind:latest
```
