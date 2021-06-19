# 阿里云 K8S 集群内部无法访问 SLB 的问题

## 现象

集群节点 ECS 访问 Ingress 暴露的公网 SLB，可以 ping 通，但 `telnet SLB 80` 会提示 `telnet: can't connect to remote host (SLB): Connection refused`

1. 有 Ingress Pod 运行的 ECS 可以访问通
2. 没有 Ingress Pod 运行的 ECS 访问不通

## 原因

k8s的kube-proxy会做两件事情：

local模式的Service为了保留源IP，不做二次转发NAT，在没有运行Pod的机器上是不会挂载后端的k8s的kube-proxy会将LoadBalancer Service的IP同步到本地的ipvs/iptables规则中拦截调用
这两个事情的结果就是：

对于Local类型的LoadBalancer Service，在没有运行其对应的Pod的节点上，访问这个LoadBalancer的IP是不通的。

## 解决办法

1. 不访问 SLB，集群内部调用就通过ClusterIP访问，还可以使用service名自动解析域名做到多环境统一

2. 访问 SLB，将LoadBalancer的Service中的 `externalTrafficPolicy` 从 `Local` 修改为 `Cluster`，但是在应用中会丢失源IP（客户端访问的源 IP），Ingress的服务修改命令如下:

    `kubectl edit svc nginx-ingress-lb -n kube-system`

    [Kubernetes集群中访问LoadBalancer暴露出去的SLB地址不通](https://help.aliyun.com/document_detail/171437.html)

3. 访问 SLB，把 Ingress Controller从 `Deployment` 改成 `DaemonSet`，让每个节点上都跑一个 Ingress Controller Pod
`kgd nginx-ingress-controller -o yaml`

## 排查流程待完善

```shell
# 在 K8S 节点上执行
ip route get SLB
ip rule show
ip route show table local | grep SLB

# ip route show 显示的是 main 路由表，于是 ip addr show | less

# ip rule show
0:      from all lookup local
32766:  from all lookup main
32767:  from all lookup default

# ip route get SLB
local SLB dev lo src SLB
    cache <local>
# ip rule show
0:      from all lookup local
32766:  from all lookup main
32767:  from all lookup default

# ip route show table local | grep SLB
local SLB dev kube-ipvs0 proto kernel scope host src SLB

# baidu
# ip route get 220.181.38.148
220.181.38.148 via 192.168.10.253 dev eth0 src 192.168.10.136
    cache

# ip a | grep -B 2 192.168
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 00:16:3e:2c:7e:b8 brd ff:ff:ff:ff:ff:ff
    inet 192.168.10.136/24 brd 192.168.10.255 scope global dynamic eth0



# another check process
kubectl run netshoot --image=nicolaka/netshoot -it --rm

# tcpdump -nn host git2.picooc.cn
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), snapshot length 262144 bytes
01:47:41.074778 IP 172.20.0.88.50986 > 123.57.34.112.80: Flags [S], seq 3342660578, win 29200, options [mss 1460,sackOK,TS val 3588739559 ecr 0,nop,wscale 9], length 0
01:47:41.075982 IP 123.57.34.112 > 172.20.0.88: ICMP 123.57.34.112 tcp port 80 unreachable, length 68


# nmap -p 80 123.57.34.112

Starting Nmap 6.40 ( http://nmap.org ) at 2021-06-19 10:24 CST
sendto in send_ip_packet_sd: sendto(4, packet, 44, 0, 123.57.34.112, 16) => Operation not permitted
Offending packet: TCP 123.57.34.112:43042 > 123.57.34.112:80 S ttl=50 id=20572 iplen=44  seq=3959538016 win=1024 <mss 1460>
Nmap scan report for 123.57.34.112
Host is up (0.0011s latency).
PORT   STATE    SERVICE
80/tcp filtered http

Nmap done: 1 IP address (1 host up) scanned in 0.07 seconds
```

## 参考

[阿里云托管 K8S 集群内部无法访问 SLB 的问题](https://zhuanlan.zhihu.com/p/107703112)
[启用IPVS的K8S集群无法从Pod经外部访问自己的排障](https://segmentfault.com/a/1190000020751999)
[Kubernetes集群中访问LoadBalancer暴露出去的SLB地址不通](https://help.aliyun.com/document_detail/171437.html)
