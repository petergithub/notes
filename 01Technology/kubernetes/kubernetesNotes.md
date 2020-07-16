# kubernetesNotes

## Concept

`minikube start` Starting a Minikube virtual machine
`kubectl explain pod` kubectl explain to discover possible API object fields
`kubectl explain pod.spec` drill deeper to find out more about each attribute
`kubectl api-resources` Print the supported API resources on the server

`kubectl cluster-info` Displaying cluster information
`kubectl help get`
`kubectl get pods`
    `-o wide`
    `-o yaml`
    `-o json`
    `--show-labels`
    `-L, --label-columns=[]` switch and have each displayed in its own column `-L creation_method,env`
    `-l, --selector=''`
`kubectl get nodes/services/secrets`
`kubectl get pods kubia-zxzij -o yaml` get a YAML descriptor of an existing pod
`kubectl get pods --selector=labelName=labelValue`
`kubectl get pods -l creation_method=manual`
    `'!env'`
    `'env'`
    `env in (prod,devel)`
    `env notin (prod,devel)`

`kubectl describe node NODE_NAME`

Deploying your Node.js app: create ReplicationController
`kubectl run kubia --image=luksa/kubia --port=8080 --generator=run/v1`
Accessing your web application:  creating a service object
`kubectl expose rc kubia --type=LoadBalancer --name kubia-http`
Listing services again to see if an external IP has been assigned
`kubectl get svc`
accessing your service through its external ip `curl 104.155.74.57:8080`

`kubectl scale rc kubia --replicas=3` increasing the desired replica count

`kubectl create -f FILE_NAME.yaml` command is used for creating any resource (not only pods) from a YAML or JSON file.
`kubectl apply -f FILE_NAME.yaml` 更新
`kubectl edit deploy piggy-mongo` open the YAML definition in your default text editor 修改
`kubectl patch svc nodeport -p '{"spec":{"externalTrafficPolicy":"Local"}}'` 添加

`docker logs <container id>`
`kubectl logs kubia-manual` retrieving a pod’s log with kubectl logs
`kubectl logs kubia-manual -c <container name>` specifying the container name when getting logs of a multi-container pod

`kubectl exec -it <pod name> -- /bin/sh`  进入pod内部

`kubectl port-forward kubia-manual 8888:8080` forwarding a local network port 8888 to a port 8080 in the pod

`k top pod` 资源使用情况

### Label

`kubectl label pod kubia-manual creation_method=manual` Modifying labels of existing pods
    `--overwrite`
`kubectl get pod -l creation_method=manual` Listing pods using a label selector
`kubectl get pod -l env`

### namespaces

`kubectl get ns`
`kubectl get pod --namespace kube-system`

`kubectl config set-context --current --namespace=piggy` change namespace
`alias kcd='kubectl config set-context $(kubectl config current- context) --namespace '`

kubectl create -f development.json

```json
{
  "apiVersion": "v1",
  "kind": "Namespace",
  "metadata": {
    "name": "development",
    "labels": {
      "name": "development"
    }
  }
}
```

### System

`kubectl get eventskubectl get events` 查看相关事件
