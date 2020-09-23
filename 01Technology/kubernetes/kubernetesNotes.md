# kubernetesNotes

## Concept

### [Requests and limits](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#meaning-of-memory)

Meaning of memory，Mi表示（1Mi=1024x1024）,M表示（1M=1000x1000）（其它单位类推， 如Ki/K Gi/G）
For example, the following represent roughly the same value: `128974848, 129e6, 129M, 123Mi`

Meaning of CPU:
The expression 0.1 is equivalent to the expression 100m, which can be read as "one hundred millicpu". Some people say "one hundred millicores", and this is understood to mean the same thing. A request with a decimal point, like 0.1, is converted to 100m by the API, and precision finer than 1m is not allowed. For this reason, the form 100m might be preferred.
`0.1 = 100m`

### Common

`k logs -f --tail=10 pod-name`
  `-o custom-columns` option an
  `--sort-by=<jsonpath_exp>` sort the resource list, `--sort-by=.metadata.name`
[Resource types](https://kubernetes.io/docs/reference/kubectl/overview/#resource-types)

[JSONPath Support](https://kubernetes.io/docs/reference/kubectl/jsonpath/)
`kubectl get pods -A -o=jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[].resources.requests.cpu}{"\n"}{end}'`

### Debug

排查问题
`k get events`
`kubectl -n namespace top pods`
kubectl get events -o custom-columns=Created:.metadata.creationTimestamp,FirstSeen:.firstTimestamp,LastSeen:.lastTimestamp,Count:.count,From:.source.component,Type:.type,Reason:.reason,Message:.message --field-selector involvedObject.kind=Pod,involvedObject.name=mysql-test-78b7567ccc-b96kb
kubectl get events --sort-by=.metadata.creationTimestamp
k get events -o yaml|less

`kubectl cluster-info dump`

### Command

`kubectl help get`

`minikube start` Starting a Minikube virtual machine
`kubectl explain pod` kubectl explain to discover possible API object fields
`kubectl explain pod.spec` drill deeper to find out more about each attribute
`kubectl api-resources` Print the supported API resources on the server

`kubectl cluster-info` Displaying cluster information
`kubectl get pods/services/deployment`
    `-o wide` request additional columns to display
    `-o yaml`
    `-o json`
    `--show-labels`
    `-L, --label-columns=[]` switch and have each displayed in its own column `-L creation_method,env`
    `-l, --selector=''`
    `-A, --all-namespaces=false` If present, list the requested object(s) across all namespaces
    `-w, --watch` watch for changes

`kubectl get nodes/services/secrets`
`kubectl get pods kubia-zxzij -o yaml` get a YAML descriptor of an existing pod
`kubectl get pods --selector=labelName=labelValue`
`kubectl get pods -l creation_method=manual`
    `'!env'`
    `'env'`
    `env in (prod,devel)`
    `env notin (prod,devel)`

`kubectl delete pods pod_name`
  `--force` force to delete

`kubectl describe node NODE_NAME`

`kubectl cp /path/to/file /target/path`

Deploying your Node.js app: create ReplicationController `kubectl run kubia --image=luksa/kubia --port=8080 --generator=run/v1`
Accessing your web application:  creating a service object `kubectl expose rc kubia --type=LoadBalancer --name kubia-http`
accessing your service through its external ip `curl 104.155.74.57:8080`

`kubectl scale rc kubia --replicas=3` increasing the desired replica count

`kubectl create -f FILE_NAME.yaml` command is used for creating any resource (not only pods) from a YAML or JSON file.
`kubectl apply -f FILE_NAME.yaml` 更新
`kubectl edit deploy piggy-mongo` open the YAML definition in your default text editor 修改
`kubectl patch svc nodeport -p '{"spec":{"externalTrafficPolicy":"Local"}}'` 添加

`docker logs <container id>`
`kubectl logs kubia-manual` retrieving a pod’s log with kubectl logs
`kubectl logs kubia-manual -c <container name>` specifying the container name when getting logs of a multi-container pod
    `--previous` figure out why the previous container

`kubectl exec -it <pod name> -- /bin/sh`  进入pod内部
`kubectl port-forward pod-name 8888:8080` forwarding a local network port 8888 to a port 8080 in the pod

`k top node` node 资源使用情况
`k top pod` pod 资源使用情况
`k top pod --containers` container 资源使用情况

COMMUNICATING WITH PODS THROUGH THE API SERVER
`kubectl proxy`
use localhost:8001 rather than the actual API server host and port. You’ll send a request to the kubia-0 pod like this:
`curl localhost:8001/api/v1/namespaces/default/pods/kubia-0/proxy/`

`kubectl autoscale deployment kubia --cpu-percent=30 --min=1 --max=5` creates the HPA object for you and sets the Deployment called kubia as the scaling target
`kubectl get hpa`
a container’s CPU utilization is the container’s actual CPU usage divided by its requested CPU
`kubectl cordon <node>` marks the node as unschedulable (but doesn’t do anything with pods running on that node).
`kubectl drain <node>` marks the node as unschedulable and then evicts all the pods from the node.

### pod

`k port-forward pod-name 8001:5000` 本地端口 8001 转发到 pod 的端口 5000

### service

访问URI: `SERVICE_NAME.NAMESPACE.svc.cluster.local`
 `svc.cluster.local` is a configurable cluster domain suffix used in all cluster local service names.

[Debug Services](https://kubernetes.io/docs/tasks/debug-application-cluster/debug-service/)

### deployment

`k rollout history deployment  deployment-name` deployment 历史记录

### Label

`kubectl label pod kubia-manual creation_method=manual` Modifying labels of existing pods
    `--overwrite`
`kubectl get pod -l creation_method=manual` Listing pods using a label selector
`kubectl get pod -l env` To list all pods that include the env label
`kubectl get po -l '!env'` To list all pods that don’t have the env label

### namespaces

`kubectl get ns`
`kubectl get pod --namespace kube-system`

`kubectl config set-context --current --namespace=piggy` change namespace
`alias kcn='kubectl config set-context $(kubectl config current-context) --namespace '`

`kubectl create -f dev.json`

```json
{
  "apiVersion": "v1",
  "kind": "Namespace",
  "metadata": {
    "name": "dev",
    "labels": {
      "name": "dev"
    }
  }
}
```

`kubectl delete ns custom-namespace` delete the whole namespace (the pods will be deleted along with the namespace automatically)
`kubectl delete po --all` Deleting all pods in a namespace, while keeping the namespace
`kubectl delete all --all` Deleting (almost) all resources in a namespace

### ConfigMap

`kubectl create configmap fortune-config --from-literal=sleep-interval=2 --from-literal=foo=bar --from-literal=bar=baz`
`kubectl create -f fortune-config.yaml`
`kubectl create configmap my-config --from-file=config-file.conf`
`kubectl create configmap my-config --from-file=/path/to/dir`

CREATING A TLS CERTIFICATE FOR THE INGRESS
`kubectl create secret tls tls-secret --cert=tls.cert --key=tls.key`

`exec` form—For example, `ENTRYPOINT ["node", "app.js"]`: runs the node process directly (not inside a shell)
`shell` form—For example, `ENTRYPOINT node app.js`: used the shell form

### System

`kubectl get events` 查看相关事件

### [Managing Resources for Containers](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)

**request**: the scheduler uses this information to decide which node to place the Pod on. The kubelet also reserves at least the request amount of that system resource specifically for that container to use.  It is default to the limits if requests is not set explicitly.
**limit**: the kubelet enforces those limits so that the running container is not allowed to use more of that resource than the limit you set

#### Exceeding the limits

CPU: when a CPU limit is set for a container, the process isn’t given more CPU time than the config- ured limit.
Memory: When a process tries to allocate memory over its limit, the process is killed (it’s said the container is OOMKilled, where OOM stands for Out Of Memory)

#### pod QoS classes

* BestEffort (the lowest priority)
  1. It’s assigned to pods that don’t have any requests or limits set at all (in any of their containers)
  2. They will be the first ones killed when memory needs to be freed for other pods.
* Burstable
  In between BestEffort and Guaranteed is the Burstable QoS class. All other pods fall into this class
  When two single-container pods exist, both in the Burstable class, the system will kill the one using more of its requested memory than the other, percentage-wise
* Guaranteed (the highest)
  1. Requests and limits need to be set for both CPU and memory.
  2. They need to be set for each container.
  3. They need to be equal (the limit needs to match the request for each resource in each container).

##### which process gets killed when memory is low

First in line to get killed are pods in the BestEffort class, followed by Burstable pods, and finally Guaranteed pods, which only get killed if system processes need memory.

### Advanced Scheduling

`kubectl taint node node1.k8s node-type=production:NoSchedule` adds a taint with key node-type, value production and the NoSchedule

Three possible effects exist:

* `NoSchedule`, which means pods won’t be scheduled to the node if they don’t tol- erate the taint.
* `PreferNoSchedule` is a soft version of NoSchedule, meaning the scheduler will try to avoid scheduling the pod to the node, but will schedule it to the node if it can’t schedule it somewhere else.
* `NoExecute`, unlike NoSchedule and PreferNoSchedule that only affect schedul- ing, also affects pods already running on the node. If you add a NoExecute taint to a node, pods that are already running on that node and don’t tolerate the NoExecute taint will be evicted from the node.

### Deploy process

1. build image `docker build -t registry.cn-beijing.aliyuncs.com/namespace/image-name:image-version . -f deploy/Dockerfile`
2. 将镜像推送到Registry `docker push`
3. 启动 pod `kubectl run pod-name -n namespace --image=registry.cn-beijing.aliyuncs.com/namespace/image-name:image-version -it --rm --restart=Never -- bash`

### Managing pods’ computational resources

* BestEffort (the lowest priority)
* Burstable
* Guaranteed (the highest)

#### Jenkins

[Kubernetes CLI](https://plugins.jenkins.io/kubernetes-cli/) 部署多个集群

```groovy
withKubeConfig([credentialsId: 'k8s_config_prd'
                    ]) {
                  sh "kubectl config view"
                  sh "kubectl get pods"
                }
```

### useful image

`kubectl run mysql-client --image=mysql:5.6 -it --rm --restart=Never -- mysql`
`kubectl run dnsutils --image=tutum/dnsutils -it --rm`
`kubectl run -it srvlookup --image=tutum/dnsutils --rm --restart=Never -- dig SRV kubia.default.svc.cluster.local`
`kubectl run nginx --image=nginx -it --rm`
`kubectl run busybox --image=busybox -it --rm`  busybox: BusyBox combines tiny versions of many common UNIX utilities
`kubectl run alpine --image=alpine -it --rm`  alpine: A minimal Docker image based on Alpine Linux
  `apk add curl` install curl

## helm

`helm repo add ali-incubator https://aliacs-app-catalog.oss-cn-hangzhou.aliyuncs.com/charts-incubator/`
`helm repo add ali-stable https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts`
helm search repo gitlab-ce
helm fetch ali-stable/gitlab-ce
helm uninstall gitlab

## Setup

[Supercharge your Kubernetes setup with OhMyZSH 🚀🚀🚀 + awesome command line tools](https://agrimprasad.com/post/supercharge-kubernetes-setup/)
[kube-ps1](https://github.com/jonmosco/kube-ps1)
`brew install kube-ps1`
kube-shell `pip install kube-shell --user -U`
`brew install kubectx`
切换集群用的命令 [kubectx + kubens: Power tools for kubectl](https://github.com/ahmetb/kubectx)

终极工具k9s

## Best Practice

### 声明每个Pod的resource

[高可靠推荐配置](https://help.aliyun.com/document_detail/128157.html)
Kubernetes采用静态资源调度方式，对于每个节点上的剩余资源，它是这样计算的：节点剩余资源=节点总资源-已经分配出去的资源，并不是实际使用的资源。如果您自己手动运行一个很耗资源的程序，Kubernetes并不能感知到。

另外所有Pod上都要声明resources。对于没有声明resources的Pod，它被调度到某个节点后，Kubernetes也不会在对应节点上扣掉这个Pod使用的资源。可能会导致节点上调度过去太多的Pod。

## Example

### 暴露 TCP 服务

#### service type = CluserIP 通过Ingress

阿里云 kubernetes 配置

1. 配置 service: 容器服务 -> 路由与负载均衡 -> 服务 -> nginx-ingress-lb -> 更新 增加端口
   port 是暴露的公网端口(控制台叫做 服务端口), targetPort 是 service 端口(控制台叫做 容器端口)
2. 配置 configmap: 容器服务 -> 应用配置-> 配置项 -> tcp-services -> 添加 22:kube-ops/gitlab:22
"service port: 'namespace/serviceName:service port'"
通过 ingress 动态读取tcp-services 暴露端口
tcp-services-configmap=$(POD_NAMESPACE)/tcp-services

reference:
[玩转Kubernetes TCP Ingress](https://developer.aliyun.com/article/603225)
[Exposing TCP and UDP services](https://kubernetes.github.io/ingress-nginx/user-guide/exposing-tcp-udp-services)

#### service type = NodePort

1. 在负载均衡设置端口映射, 监听虚拟服务器组的端口设置为 NodePort 30022
2. 安全组放开 nodePort 30022
