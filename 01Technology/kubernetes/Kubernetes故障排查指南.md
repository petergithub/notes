# Kubernetes 故障排查指南

2023.3.19 [Kubernetes](/categories/kubernetes/) 3345 7分钟 1391

## 目录

- [Kubernetes 故障排查指南](#kubernetes-故障排查指南)
  - [目录](#目录)
  - [基础流程和方法](#基础流程和方法)
    - [如何访问容器](#如何访问容器)
    - [如何访问节点](#如何访问节点)
  - [常见问题及排查方法](#常见问题及排查方法)
    - [kubectl 执行结果异常](#kubectl-执行结果异常)
    - [DNS 解析异常](#dns-解析异常)
    - [TLS 证书异常](#tls-证书异常)
    - [路由和内核参数配置错误](#路由和内核参数配置错误)
    - [防火墙](#防火墙)
    - [配置错误和程序 BUG](#配置错误和程序-bug)
  - [Further reading](#further-reading)
  - [相关文章：](#相关文章)

## [](#基础流程和方法)[基础流程和方法](#contents:基础流程和方法)

1. 查询 pod 的状态，适用于 pod Pending 的场景：

    ```sh
    kubectl describe <pod-name> -n <namespace>
    ```

2. 获取集群中的异常事件，作为排查 pod Pending 原因的补充：

    ```sh
    kubectl get events -n <namespace> --sort-by .lastTimestamp [-w]
    ```

3. 获取 pod 的日志，适用于 pod Error 或者 CrashLoopBack 的场景：

    ```sh
    kubectl logs <pod-name> -n <namespace> [name-of-container, if multiple] [-f]
    ```

4. 如果 pod 已经处于 Running 状态，并且现有的日志未能直接指出问题，则需要进入 pod 容器进一步测试，例如验证一个正在运行的进程的状态、配置，或者检查容器的网络连接。

### 如何访问容器

1. 通过 exec 命令：`kubectl exec -it <podName> sh`。
2. 通过 ephemeral container（需要 Kubernetes v1.23 以上版本）。
3. 在镜像中缺乏程序二进制的前提下，执行常用排查工具和命令：
    1. 获取容器在宿主机对应的 PID：`docker ps | grep k8s_<containerName>_<podName> | awk '{print $1}' | xargs docker inspect --format '{{ .State.Pid }}'`
    2. 在容器的网络命名空间中执行安装于宿主机的工具：`nsenter -t <PID> -n bash`
    3. 退出容器的命名空间（即退出运行于该命名空间中的 shell）：`exit`

### 如何访问节点

1. ssh 到节点。
2. journalctl -xeu kubelet 查看 kubelet 日志，适用于节点 NotReady 的场景。

## 常见问题及排查方法

### [](#kubectl-执行结果异常)[kubectl 执行结果异常](#contents:kubectl-执行结果异常)

表现：

执行任意 kubectl 命令输出以下结果：

- Error from server (InternalError): an error on the server (“”) has prevented the request from succeeding
- etcdserver: leader changed

原因：

* kubectl 和 apiserver 认证失败
* apiserver 异常
    * 通常由于 etcd 导致 apiserver 异常
* etcd 异常
    * 选举节点拓扑不满足奇数导致频繁切主
    * 磁盘性能太差导致延迟太高甚至频繁切主

排查方法：

1. 检查 kubectl 当前所使用的配置文件是否正确：`kubectl config view`

    1. 当前所使用的配置文件 `~/.kube/config` 是否由该集群生成。
    2. 检查配置文件中的 `server` 地址和访问协议是否正确。
2. apiserver 和 etcd 均属于静态 pod，如果无法使用 kubectl 命令，可直接用容器运行时如 docker 检查容器的日志：

    ```sh
    # 获取 apiserver 和 etcd 对应的 container_id
    docker ps -a | grep -e k8s_kube-apiserver -e k8s_etcd
    # 获取日志
    docker logs <container_id> [-f]
    ```

3. 测试 etcd 所使用的文件系统性能：

    ```sh
    fio --rw=write --ioengine=sync --fdatasync=1 --filename=<etcd-data-dir>/iotest --size=22m --bs=2300 --name=etcdio-bench
    ```

    该测试重点关注 etcd 所使用文件系统的 fsync 性能：

    ```sh
    fsync/fdatasync/sync_file_range:
      sync (usec): min=534, max=15766, avg=1273.08, stdev=1084.70
      sync percentiles (usec):
       | 1.00th=[ 553], 5.00th=[ 578], 10.00th=[ 594], 20.00th=[ 627],
       | 30.00th=[ 709], 40.00th=[ 750], 50.00th=[ 783], 60.00th=[ 1549],
       | 70.00th=[ 1729], 80.00th=[ 1991], 90.00th=[ 2180], 95.00th=[ 2278],
       | 99.00th=[ 2376], 99.50th=[ 9634], 99.90th=[15795], 99.95th=[15795],
       | 99.99th=[15795]

    ```

    测试结果中，如上述 fsync 99.00th 的值大于 10000 usec（即 P99 > 10ms），通常认为不满足使用条件，建议更换磁盘硬件。

### [](#dns-解析异常)[DNS 解析异常](#contents:dns-解析异常)

表现：

应用无法连接到 kubernetes apiserver 或其他 DB、proxy 等依赖服务，错误信息里通常包含 53 端口访问超时、can’t resolve host 等。

原因与排查方法：

* 无法访问 kube-dns service 对应的后端 pod

    * 应用容器内 dns 配置（`/etc/resolv.conf`）出错导致无法发出正常的解析请求（部分旧版本发行版和 libc 库存在该问题）

        检查容器内的 `/etc/resolv.conf` 文件是否包含正确的 nameserver 和 search path，如：

        ```sh
        $ cat /etc/resolv.conf
        nameserver 11.96.0.10
        search qfusion-admin.svc.cluster.local svc.cluster.local cluster.local
        options ndots:5
        ```

    * service 的负载均衡功能异常，出站请求无法 DNAT 到实际的 coreDNS 后端 pod

        1. 检查 kube-proxy pod 的运行状态。

        2. 检查应用容器所在节点是否能正常匹配 service 并完成 DNAT。

            1. 检查节点路由表是否有默认路由或 service 的路由规则，否则数据包不会被 DNAT。

            2. 检查是否存在 service 对应的 DNAT 规则，以 iptables 为例：

                ```sh
                iptables-save | grep <serviceName>
                ```

                对于每个 service 的每个端口，在 `KUBE-SERVICES` 中应该有1条规则和一个 `KUBE-SVC-<hash>` 链。

                对于每个 Pod 端点，在该 `KUBE-SVC-<hash>` 中应该有少量的规则，以及一个`KUBE-SEP-<hash>` 链，其中有少量的规则。确切的规则将根据你的具体配置（包括节点端口和负载平衡器）而变化。

            3. 查询当前 NAT 记录：

            ```sh
            conntrack -L | grep <dns-ip>
            # destination
            conntrack -L -d 10.32.0.1
            ```

        详见 [https://kubernetes.io/docs/tasks/debug/debug-application/debug-service/](https://kubernetes.io/docs/tasks/debug/debug-application/debug-service/)

    * 跨节点容器网络异常，请求无法到达 DNS pod 所在节点

        1. 检查 CNI 插件相关组件的运行状态，执行 CNI 插件自带的健康检查或状态检查命令，以 cilium 为例：

            ```sh
            cilium status [--verbose]
            kubectl -n kube-system exec -it cilium-xrd4d -- cilium-health status
            ```

        2. 检查应用容器和 coredns 之间节点和 pod 的连通性

            * 使用 nc 测试两个节点及 pod 之间的四层连通性：

                ```sh
                # host1
                nc -l 9999
                # host2
                nc -vz <host1> 9999
                ```

            * 如果容器网络（大部分情况下）采用的是 vxlan 方案，测试 vxlan 默认使用的宿主机 8472 端口是否被阻断。

                * 使用 `netstat -lnup | grep 8472` 或者 `nc -lu 8472` 检查 8472 UDP 端口是否已被其他程序占用。

                * 使用 `tcpdump` 对 8472 端口进行抓包，判断数据包能否经由网络到达。例如：

                    ```sh
                    tcpdump -i p4p1 dst port 8472 -c 1 -Xvv -nn
                    ```

                * 测试 8472 UDP 是否可使用：

                    ```sh
                    #  on the server side
                    iperf -s -p 8472 -u
                    # on the client side
                    iperf -c 172.28.128.103 -u -p 8472 -b 1K
                    ```

    * MTU 问题，网络拓扑中的某一中间设备设置了比发送端网卡更小的 MTU，导致部分大小超过的包被 drop。具体表现为能 ping 通，同一协议和端口有些请求能通，有些请求不通。

        1. 获取发送端网卡的 MTU：

            ```sh
            ifconfig
            # or
            ip -4 -s address
            ```

        2. 使用 ping 命令对目标主机的 MTU 进行测试：

            ```sh
            ping -M do -s 1472 [dest IP]
            ```

            ICMP头部使用 8 个字节，以太网头部使用 20 个字节，ping 命令再额外发送了 1472 个字节，测试 MTU 1500 字节能否到达目标主机。

        3. 修改发送端网卡的 MTU

            ```sh
            echo MTU=1450 >> /etc/sysconfig/network-scripts/ifcfg-eth0 # 文件名修改为网卡名称
            systemctl restart network
            ```

* kube-dns 对应的后端 pod 异常导致无法响应解析请求或者未包含 dns 记录

    * kube-dns service 不存在

        检查 kube-system 命名空间下 service 以及 endpoint 的状态：

        ```sh
        kubectl -n kube-system get svc | grep dns
        kubectl -n kube-system get ep | grep dns
        ```

    * coreDNS pod 状态异常

        使用上文介绍的 `kubectl describe` 和 `kubectl logs` 命令获取 coreDNS 的 pod 状态及日志。

    * coreDNS 无法响应解析或未包含指定的 dns 记录

        进入应用容器以及另一任意容器，测试 coreDNS 能否完成其他容器、节点及域名的解析

        * 请求 DNS server 的 53 端口，判断能够访问 DNS server 及其是否正在监听：`nc -vz <ip-of-dns> 53`
        * 测试域名解析：`dig example.com @<ip-of-dns> +trace` (+trace 输出追踪信息以区分是否使用缓存)
        * 其他域名解析工具：`nslookup`, `host`

更多排查 dns 解析有关的资料详见 [https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/](https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/)

### [](#tls-证书异常)[TLS 证书异常](#contents:tls-证书异常)

tls 证书的关键概念是多个证书形成一个有效的信任链，从主机上的服务器/叶子证书到多个中间证书，最后到根/CA证书。正是通过形成的信任链，客户端和服务器之间才能开始加密通信会话。

表现：因为 ssl/tls 原因无法完成预期的请求，错误信息通常包含 ssl/tls handshake error

原因：

* 未将根/CA 证书添加到可信任证书中
* 服务端/CA 证书已过期或未到开始生效时间（通常是因为系统时间不一致导致生成了还未到生效时间的证书）

排查方法：

* 使用 `openssl` 获取指定服务的证书信息：

    ```sh
    openssl s_client -connect <fqdn/ip>:<port>
    ```

* 使用 `openssl` 获取指定服务（以 `[localhost:6443](http://localhost:6443)` 为例）的服务端证书并打印成可读格式：

    ```sh
    openssl s_client -showcerts -connect localhost:6443 </dev/null 2>/dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' | openssl x509 -text
    ```

    通常可检查输出中的 Issuer（签发者）、Validity（生效时间）和 Subject（CN）。

* 如果遇到 `x509: certificate signed by unknown authority`（如 docker CLI 在访问内部的 https 镜像仓库时会抛出以上错误），说明目标服务器使用了不受信任的签发证书（如自签发证书），需要按照应用程序文档安装 CA 证书或变更与信任证书有关的配置。


### [](#路由和内核参数配置错误)[路由和内核参数配置错误](#contents:路由和内核参数配置错误)

表现：

无法完成对集群内部或外部某些状态正常服务的访问，报错信息中通常包含 Unreachable 或者 Connection timeout。

原因：

* 应用所在的 pod 或主机的路由表中无访问地址对应的路由项，且没有配置默认路由。
* 与路由有关的内核参数未正确配置或在安装 kubernetes 时开启之后被其他服务重置。

排查方法：

* 使用 `netcat` 或者 `curl` 测试服务端是否可通过四层网络访问：

    ```sh
    nc -vz <ip/fqdn> <port>
    curl -kL telnet://<ip/fqdn>:<port> -vvv
    ```

* 使用 `curl` 简单测试网络延迟：

    ```sh
    curl -s -w 'Total time: %{time_total}s\n' http://example.com
    ```

* 打印系统路由表，注意检查是否存在默认路由：

    ```sh
    route -n
    # or
    ip route show
    ```

* 查询指定 IP 的路由规则：

    ```sh
    ip route get 10.101.203.141
    ```

* 跟踪请求的路由路径：

    ```sh
    traceroute 10.101.203.141
    ```

    traceroute 默认使用 ICMP 协议的 ECHO 包，部分设备可能不会响应。

* `net.ipv4.ip_forward`：允许 Linux 在不同网络接口间转发流量的核心参数，绝大部分 CNI 要求启用此参数才能实现 pod 间访问。

    ```sh
    sysctl net.ipv4.ip_forward
    # this will turn things back on a live server
    sysctl -w net.ipv4.ip_forward=1
    # on Centos this will make the setting apply after reboot
    echo net.ipv4.ip_forward=1 >> /etc/sysconf.d/10-ipv4-forwarding-on.conf
    ```

* `net.bridge.bridge-nf-call-iptables`：允许对 Linux Bridge 设备使用 iptables 规则，部分基于 Linux Bridge 的 CNI 需要启用此参数实现容器请求外部网络的 NAT。

    ```sh
    sysctl net.bridge.bridge-nf-call-iptables
    modprobe br_netfilter
    # turn the iptables setting on
    sysctl -w net.bridge.bridge-nf-call-iptables=1
    echo net.bridge.bridge-nf-call-iptables=1 >> /etc/sysconf.d/10-bridge-nf-call-iptables.conf
    ```

* `net.ipv4.conf.all.rp_filter`：部分 CNI （如 Cilium）要求启用此参数实现 pod 间访问，但一些发行版版本的 systemd 可能会覆盖此参数。

    ```sh
    cat <<EOF > /etc/sysctl.d/99-override_cilium_rp_filter.conf
    net.ipv4.conf.all.rp_filter = 0
    net.ipv4.conf.default.rp_filter = 0
    net.ipv4.conf.lxc*.rp_filter = 0
    EOF
    systemctl restart systemd-sysctl
    ```

### [](#防火墙)[防火墙](#contents:防火墙)

表现：

请求被某些 4 层或者 7 层防火墙规则拦截，通常表现为可以访问节点但无法访问部分端口；部分请求无法完成，报错信息中通常包含 Connection Reset。

原因：

* 4 层防火墙禁止访问某些端口或者特定协议。
* 7 层防火墙审计请求的目标路径和请求体内容。

排查方法：

1. `nc -vz` 可测试四层连通性，`curl -kL` 可测试七层连通性，如果一个服务四层通但是七层不通，表明可能有七层防火墙。

2. 使用 `tcpdump` 进行抓包分析，重点关注 ACK 为 RST 或者 Reject 的 TCP 包。

3. 检查 iptables 是否有 reject 规则，`-reject-with icmp-host-unreachable` 也可能表现为有路由规则但是请求返回 `no route to host`。

    ```sh
    iptables -nvL | grep -i reject
    ```

### [](#配置错误和程序-bug)[配置错误和程序 BUG](#contents:配置错误和程序-bug)

表现：

部分应用无法正常启动或按照预定配置运行，错误信息通常包含 syntax error

原因：

空格或者 tab 导致配置文件格式出现错误

如果以上排查步骤均未发现问题，且在应用容器的日志中发现了可疑的信息，可直接向开发者报告或讨论该问题，但注意不要急于给出结论。

[](#further-reading)[Further reading](#contents:further-reading)
----------------------------------------------------------------

* [https://tanzu.vmware.com/developer/learningpaths/effective-efficient-kubernetes-debugging/](https://tanzu.vmware.com/developer/learningpaths/effective-efficient-kubernetes-debugging/) 通用的 kubernetes 问题排查流程和方法
* [https://kubernetes.io/docs/tasks/debug/debug-application/](https://kubernetes.io/docs/tasks/debug/debug-application/) Debugging Pod、Service、StatefulSet
* [https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/](https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/) Debugging DNS Resolution
* [https://goteleport.com/blog/troubleshooting-kubernetes-networking/](https://goteleport.com/blog/troubleshooting-kubernetes-networking/)

* 作者：[Waynerv](https://waynerv.com)
* 链接：[https://waynerv.com/posts/how-to-debugging-kubernetes/](/posts/how-to-debugging-kubernetes/)
* 许可：[CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/deed.zh)

updated 2023-06-06

相关文章：
-----

* [为 Kubernetes 集群启用 Pod 安全策略](/posts/enable-pod-security-policy-for-cluster/)
* [浅析 Linux 如何接收网络帧](/posts/how-linux-process-input-frames/)
* [深入理解 netfilter 和 iptables](/posts/understanding-netfilter-and-iptables/)
* [如何使用 docker buildx 构建跨平台 Go 镜像](/posts/building-multi-architecture-images-with-docker-buildx/)

[云原生](/tags/%E4%BA%91%E5%8E%9F%E7%94%9F/) [Networking](/tags/networking/)

* [Unix 终端系统（TTY）是如何工作的 >](/posts/how-tty-system-works/)

©2020–2023Waynerv

Powered by [Hugo](https://github.com/gohugoio/hugo) | Theme is [MemE](https://github.com/reuixiy/hugo-theme-meme)

[CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/deed.zh)
