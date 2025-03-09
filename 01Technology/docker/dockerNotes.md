# Docker Notes

## Command

### Recent

`docker ps -a --format "table {{.Size}}\t{{.Names}}"` disk utilization
`docker ps --size`

### Common

`docker run` 只在第一次运行时使用，将镜像放到容器中，以后再次启动这个容器时，使用 `docker start imageName`

`docker start docker-mysql-5.6`
`docker exec -it docker-mysql-5.6 bash` 进入一个正在运行的 docker 容器 `[Ctrl-p] + [Ctrl-q]` Exit without shutting down a container

[Networking features in Docker Desktop for Mac](https://docs.docker.com/docker-for-mac/networking/)
connect from a container to a service on the host: connect to the special DNS name `host.docker.internal`, which resolves to the internal IP address used by the host. This is for development purpose and will not work in a production environment outside of Docker for Mac.

### Basic

`docker run -it --name=containerName <image_id || repository:tag> bash` Run a command in a new container
`docker run = docker create + docker start`

- `--add-host="localhostA:127.0.0.1" --add-host="localhostB:127.0.0.1"` append to /etc/hosts
- `-t` 分配一个伪终端（pseudo-tty）并绑定到容器的标准输入上
- `-i` 让容器的标准输入保持打开
- `-p` [host:]port:dockerPort
- `-d, --detach` 后台运行
- `-e` 设置环境变量，与在dockerfile env设置相同效果 `-e TZ=Asia/Shanghai`, `-e MYSQL_ROOT_PASSWORD=root`
- `--rm` 在容器终止运行后自动删除容器文件
- `-v, --volume "/path/to/host/machine:/path/to/container`
- `--restart always` [Start containers automatically](https://docs.docker.com/config/containers/start-containers-automatically/)
- `--user $(id -u):$(id -g)` use the current user's UID and GID.

`docker logs -f containerID`

`docker start -i <image_id>` Start a existed container
`docker attach <containerID>` Attach a running container
`docker exec -it containerID /bin/bash` 进入正在运行的容器  `[Ctrl-p] + [Ctrl-q]` Exit without shutting down a container
`docker inspect containerID` 查看信息
`docker update --restart=no $(docker ps -a -q)` updates the restart-policy

`exit` 退出
`docker stop <hash>` Gracefully stop the specified container
`docker kill [containID]` 手动终止容器

`docker ps` Show running containers

- `-a, --all` Show all containers (default shows just running)
- `-n, --last int` Show n last created containers (includes all states) (default -1)
- `-l, --latest` Show the latest created container (includes all states)

设置容器时间，需要挂载/usr/share/zoneinfo 因为/etc/localtime 一般是软连接

```sh
# 设置 TZ=Asia/Shanghai 和 挂载 /etc/localtime
  --env TZ=Asia/Shanghai \
  --volume /etc/localtime:/usr/share/zoneinfo/Asia/Shanghai:ro \

# 或者
  --env TZ=Asia/Shanghai \
  --volume /usr/share/zoneinfo:/usr/share/zoneinfo:ro \
  --volume /etc/localtime:/etc/localtime:ro \
```

#### Docker management

`docker system df` 磁盘占用

`docker stats`  a live look at your containers resource utilization

- Memory is listed under the MEM USAGE / LIMIT column. This provides a snapshot of how much memory the container is utilizing and what it’s memory limit is.
- CPU utilization is listed under the CPU % column.
- Network traffic is represented under the NET I/O column. It displays the outgoing and incoming traffic consumption of a container.
- Storage utilization is shown under the BLOCK I/O column. This show you the amount of reads and writes a container is peforming to disk.

`docker stats --no-stream` the first stats pull results

#### Restart containers automatically

[Start containers automatically | Docker Documentation](https://docs.docker.com/config/containers/start-containers-automatically/)

[How do I make a Docker container start automatically on system boot? - Stack Overflow](https://stackoverflow.com/questions/30449313/how-do-i-make-a-docker-container-start-automatically-on-system-boot)

```sh
# check a docker container restart policy
docker inspect <containerID> | grep Restart

# The default restart policy is no. For the created containers use docker update to update restart policy.
docker update --restart unless-stopped <containerID>
```

- `no`              Do not automatically restart the container. (the default)
- `on-failure`      Restart the container if it exits due to an error, which manifests as a non-zero exit code.
- `always`          Always restart the container if it stops. If it is manually stopped, it is restarted only when Docker daemon restarts or the container itself is manually restarted. (See the second bullet listed in restart policy details)
- `unless-stopped`  Similar to always, except that when the container is stopped (manually or otherwise), it is not restarted even after Docker daemon restarts.

### 使用GPU

从Docker 19.03开始，安装好docker之后，只需要使用 --gpus 即可指定容器使用显卡。如果不指定 --gpus ，运行nvidia-smi 会提示Command not found

```sh
docker run --gpus all --name 容器名 -d -t 镜像id
```

### image

```sh
docker images # Show all images in your local repository
docker image inspect imageName --format '{{json .RepoDigests}}'
# ["nginx@sha256:644a70516a26004c97d0d85c7fe1d0c3a67ea8ab7ddf4aff193d9f301670cf36","localhost:5000/library/nginx@sha256:644a70516a26004c97d0d85c7fe1d0c3a67ea8ab7ddf4aff193d9f301670cf36"]
docker images --digests

docker commit [OPTIONS] CONTAINER [REPOSITORY[:TAG]]
docker tag server:latest myname/server:latest # Rename image
docker tag IMAGE[:TAG] [REGISTRY_HOST[:REGISTRY_PORT]/]REPOSITORY[:TAG]

# remove container
docker rm <container_id/contaner_name>
docker rm $(docker ps -a -q | grep -v $(docker ps -q)) # Remove all containers from this machine except the running one
docker rm $(docker ps -a -q) # Remove all containers from this machine

# remove image
docker rmi <image_id/image_name ...>
# 清理无用的镜像
docker image rm $(docker image ls | awk '{print $1 ":" $2}' | grep -v nginx | grep -v pandora)

# clean up unused images. By default, docker image prune only cleans up dangling images. A dangling image is one that is not tagged and is not referenced by any container. [Prune unused Docker objects](https://docs.docker.com/config/pruning/)
docker image prune

docker save <image-id> -o filename # 创建一个镜像的压缩文件，这个文件能够在另外一个主机的Docker上使用. 和export命令不同，这个命令为每一个层都保存了它们的元数据。这个命令只能对镜像生效。
docker load -i filename # Load an image from a tar archive or STDIN

docker export <container-id> # 将 container 创建一个`tar`文件，并且移除了元数据和不必要的层，将多个层整合成了一个层，只保存了当前统一视角看到的内容（译者注：expoxt后的容器再import到Docker中，通过`docker images –tree`命令只能看到一个镜像；而save后的镜像则不同，它能够看到这个镜像的历史镜像）
docker import

```

### docker network 命令

Docker容器访问宿主机网络 `http://host.docker.internal`

```sh
docker network ls  # 列出所有网络
docker network inspect  # 查看网络详细信息
docker network create --driver bridge --subnet 192.168.1.0/24 my_network  # 创建一个新网络
docker network rm  # 删除一个或多个网络
docker network connect my_network my_container # 将一个容器连接到一个网络
docker network disconnect  my_network my_container # 将一个容器从一个网络断开
docker network rm $(docker network ls --quiet)  # 清理网络
```

### 和系统交互

拷贝文件: `docker cp scala-2.10.6.tgz ubuntu-hadoop:/home/hadoop/`

## build image with Dockerfile

[Building best practices | Docker Docs](https://docs.docker.com/build/building/best-practices/)
[docker buildx build | Docker Docs](https://docs.docker.com/reference/cli/docker/buildx/build/#push)

`docker build -t imageName /path/to/DockerfileFolder -f /path/to/Dockerfile`
`docker push ${image}:${imageTag}`

[Dockerfile 最佳实践](https://zhuanlan.zhihu.com/p/75013836)
将标准日志与错误日志分别输出到stdout与stderr

日志输出到标准输出与错误输出，方便查看与采集日志。参考 Nginx 的 dockerfile ：

``` shell
#forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log
```

## Troubleshooting

### Troubleshooting Network

[Troubleshooting Container Networking](https://success.docker.com/article/troubleshooting-container-networking)
`docker run -it --rm --network container:issue-container-name nicolaka/netshoot`

### 已知宿主机的 PID，如何找出对应的容器 global PID -> namespace PID 映射

常见的场景就是使用 top/htop 定位到占用内存/CPU过高的进程，此时需要定位到它所在的容器

```sh
# 宿主机进程 22932
# 通过 docker inspect 查找到对应容器
$ docker ps -q | xargs docker inspect --format '{{.State.Pid}}, {{.ID}}' | grep 22932

# 通过 cgroupfs 找到对应容器
$ cat /etc/22932/cgroup
```

### 如何找出 docker 容器中的 pid 在宿主机对应的 pid 容器中 namespace PID -> global PID 映射

```sh
# 容器环境

# 已知容器中该进程 PID 为 122
# 在容器中找到对应 PID 的信息，在 /proc/$pid/sched 中包含宿主机的信息
$ cat /proc/122/sched
node (7477, #threads: 7)
...
# 宿主机环境

# 7477 就是对应的 global PID，在宿主机中可以找到
# -p 代表指定 PID
# -f 代表打印更多信息
$ ps -fp 7477
UID        PID  PPID  C STIME TTY          TIME CMD
root      7477  7161  0 Jul10 ?        00:00:38 node index.js
```

## Disk clean

[Prune unused Docker objects | Docker Documentation](https://docs.docker.com/config/pruning/)

`docker system prune` is a shortcut that prunes images, containers, and networks. Volumes are not pruned by default, and you must specify the --volumes flag for docker system prune to prune volumes.

## Image is useful

start a ubuntu container and running bash `docker run -itd ubuntu:14.04 /bin/bash`
start a nginx server with `docker run -d -p 80:80 --name webserver nginx`
start a tensorflow container `docker run -d --name tensorflow tensorflow/tensorflow`
`docker run --rm --name redis -p 6379:6379 -d redis`
`docker run --rm --name mongo -d mongo:4.2.7`

Jenkins with blue ocean: `docker run -d -p 8081:8080 -p 50000:50000 -v /data/docker/jenkins/jenkins_home:/var/jenkins_home -v /usr/share/apache-maven:/usr/local/maven -v /etc/localtime:/etc/localtime --name jenkins jenkinsci/blueocean:1.25.5`

```sh
# windows image
# [dockur/windows: Windows inside a Docker container.](https://github.com/dockur/windows)
docker run -it --rm -p 8006:8006 -e VERSION="11" --device=/dev/kvm --device=/dev/net/tun --cap-add NET_ADMIN --stop-timeout 120 dockurr/windows
```

### gitlab

```sh
#!/bin/bash

docker run --detach \
    --hostname 127.0.0.1 \
    --publish 8443:443 --publish 8080:80 --publish 22:22 \
    --name gitlab \
    --restart always \
    -e TZ=Asia/Shanghai \
    --volume /data/gitlab/config:/etc/gitlab \
    --volume /data/gitlab/logs:/var/log/gitlab \
    --volume /data/gitlab/data:/var/opt/gitlab \
    gitlab/gitlab-ce:8.16.4-ce.0
```

### CentOS

#### Common package

`yum install -y less initscripts rsyslog`

#### Dockerfile

``` bash
FROM centos:7
COPY . /data
WORKDIR /data
RUN yum install -y iproute
EXPOSE 8080

CMD ["/usr/sbin/init"]
```

- FROM centos:7：该 image 文件继承的 centos image
- COPY . /data：将当前目录下的所有文件（除了.dockerignore排除的路径），都拷贝进入 image 文件的/data目录。
- WORKDIR /data：指定接下来的工作路径为/data。
- RUN yum install -y iproute：在`/data`目录下，运行`yum`命令安装依赖。注意，安装后所有的依赖，都将打包进入 image 文件, 可以包含多个RUN命令
- EXPOSE 8080：将容器 `8080` 端口暴露出来， 允许外部连接这个端口。
- CMD 命令在容器启动后执行, 只能有一个 有两种格式
  - shell 格式：`CMD <命令>`。实际的命令会被包装为 `sh -c` 的参数的形式进行执行，先运行一个 shell 进程。
  - exec 格式：`CMD ["可执行文件", "参数1", "参数2"...]`。推荐使用 exec 格式，这类格式在解析时会被解析为 JSON 数组，因此一定要使用双引号 "，而不要使用单引号。
- 当指定了 ENTRYPOINT 后，CMD 的含义就发生了改变，不再是直接的运行其命令，而是将 CMD 的内容作为参数传给 ENTRYPOINT 指令，换句话说实际执行时，将变为：
`<ENTRYPOINT> "<CMD>"`

创建 image 文件 `docker image build -t imageName /path/to/DockerfileFolder`
`docker run -p 8080:8080 -it imageName /bin/bash`

##### Copy docker images from one host to another

[How to copy docker images from one host to another without via repository?](https://stackoverflow.com/questions/23935141/how-to-copy-docker-images-from-one-host-to-another-without-via-repository )

1. save the docker image as a tar file: `docker save -o <path for generated tar file> <image name>`
2. copy your image to a new system with regular file transfer tools such as cp or scp.
3. load the image into docker: `docker load -i <path to image tar file>`
4. list the images: `docker images`

or
Transferring a Docker image via SSH, bzipping the content on the fly, put pv in the middle of the pipe to see how the transfer is going
`docker save <image> | bzip2 | pv | ssh user@host 'bunzip2 | docker load'`

#### Docker commit the changes you make to the container and then run it

1. `sudo docker pull ubuntu`
2. `sudo docker run ubuntu apt-get install -y ping`
3. Then get the container id using this command: `sudo docker ps -l`
4. Commit changes to the container: `sudo docker commit <container_id> iman/ping`
5. Then run the container: `sudo docker run iman/ping ping www.google.com`

#### 端口映射

因为docker容器中运行的软件所使用的端口,在本机和本机的局域网内是无法访问到的,所以我们要给docker容器中端口映射到当前主机的端口上,
这样才能在本机和本机所在的局域网内访问到.(Windows环境下的docker要做两次端口映射)
docker的端口映射是通过-p参数来实现的.
例如下面 , 将端口6379映射到6378
`docker run -d -p [host:]6378:6379 --name port-redis redis`
`docker run -d -p 8083:8080 7c34bafd1150` (使用imagesid启动tomcat)

## Docker Compose

[Install](https://docs.docker.com/compose/install/)
[Get started with Docker Compose](https://docs.docker.com/compose/gettingstarted/)
[Command-line completion](https://docs.docker.com/compose/completion/)

Create a file called docker-compose.yml
`docker-compose up` start up your application
`docker-compose down` Stop the application
`docker-compose up -d` run your services in the background
`docker-compose --help` see other available commands
`docker-compose down --volumes` bring everything down, removing the containers entirely

## Install

[Docker CentOS](https://docs.docker.com/install/linux/docker-ce/centos/)
[how-to-install-and-use-docker-on-centos-7](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-centos-7)

``` shell
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

sudo yum install -y docker-ce docker-ce-cli containerd.io
sudo systemctl enable docker
sudo usermod -aG docker $(whoami)
sudo systemctl start docker
sudo docker run hello-world
```

### Windows 11 install

[WSL 上的 Docker 容器入门 | Microsoft Learn](https://learn.microsoft.com/zh-cn/windows/wsl/tutorials/wsl-containers)
[Windows | Docker Docs](https://docs.docker.com/desktop/setup/install/windows-install/)

[WSL | Docker Docs](https://docs.docker.com/desktop/features/wsl/)
By default, Docker Desktop stores the data for the WSL 2 engine at C:\Users\[USERNAME]\AppData\Local\Docker\wsl. If you want to change the location, for example, to another drive you can do so via the Settings -> Resources -> Advanced page from the Docker Dashboard. Read more about this and other Windows settings at Changing settings

[Windows11 Docker镜像存储路径更改（非C盘路径）-阿里云开发者社区](https://developer.aliyun.com/article/980658)

```bat
# 查看WSL应用
wsl --list -v

# 导出docker镜像文件
wsl --export docker-desktop-data "D:\docker\docker-desktop-data.tar"
wsl --export docker-desktop "D:\docker\docker-desktop.tar"

# 注销docker-desktop-data、docker-desktop
wsl --unregister docker-desktop-data
wsl --unregister docker-desktop

# 指定文件夹重新导入
wsl --import docker-desktop-data D:\docker\data "D:\docker\docker-desktop-data.tar" --version 2
wsl --import docker-desktop D:\docker\desktop "D:\docker\docker-desktop.tar" --version 2
```

[Configure Docker in Windows | Microsoft Learn](https://learn.microsoft.com/en-us/virtualization/windowscontainers/manage-docker/configure-docker-daemon#configure-docker-with-a-configuration-file)

location: 几个可能的位置
%USERPROFILE%/.docker/daemon.json
%USERPROFILE%/.docker/machine/default/config.json

或者在桌面版设置里配置 daemon.json

```json
{
  "builder": {
    "gc": {
      "defaultKeepStorage": "20GB",
      "enabled": true
    }
  },
  "experimental": false
}
```


### daemon.json configuration

`docker info` 查看信息

使用DockerHub Proxy，以下以 registry.docker-cn.com 为例：可以根据列表自行替换
`docker pull registry.docker-cn.com/library/mysql:5.7`
说明：library是一个特殊的命名空间，它代表的是官方镜像。如果是某个用户的镜像就把library替换为镜像的用户名
命令行下拉取仓库临时使用其他仓库
`docker pull registry.docker-cn.com/myname/myrepo:mytag`

`/etc/docker/daemon.json` 的配置项 available configuration options in the [dockerd reference docs](https://docs.docker.com/reference/cli/dockerd/#daemon-configuration-file)

- `log-driver，log-opts`：配置日志 [Configure logging drivers | Docker Docs](https://docs.docker.com/engine/logging/configure/)
- `registry-mirrors`：使用镜像仓库
- `insecure-registries`: 设置允许使用 HTTP 协议的镜像仓库
- `data-root`：修改docker镜像默认数据位置，default `/var/lib/docker` on Linux.
- `bip`：The default Bridge IP defines the IP range that network interface docker0 can use 默认docker网络 172.17.0.0/16
- `default-address-pools` User generated bridge networks, defines the IP range of network interface docker_gwbridge.

```sh
# data-root default is /var/lib/docker
sudo mkdir -p /etc/docker

sudo tee /etc/docker/daemon.json <<EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "500m",
    "max-file": "10",
    "compress": "true"
  },
  "registry-mirrors": [
      "https://hub.uuuadc.top",
      "https://docker.anyhub.us.kg",
      "https://dockerhub.jobcher.com",
      "https://dockerhub.icu",
      "https://docker.ckyl.me",
      "https://docker.awsl9527.cn",
      "https://ud6340vz.mirror.aliyuncs.com",
      "https://ot2k4d59.mirror.aliyuncs.com/"
  ],
  "insecure-registries": [
      "IP:PORT"
  ],
  "data-root":"/data/lib/docker",
  "bip":"192.168.0.1/24",
  "default-address-pools":[
    {"base":"192.169.0.0/16","size":24},
    {"base":"192.170.0.0/16","size":24}
  ]
}
EOF

# 重启服务
# sudo systemctl daemon-reload
sudo systemctl restart docker
```

`docker info | grep -A 2 Mirrors` 检查加速器是否生效

### Configure logging drivers

全局配置控制 docker 运行时产生的日志文件大小
[JSON File logging driver](https://docs.docker.com/config/containers/logging/json-file/)
[Configure logging drivers](https://docs.docker.com/config/containers/logging/configure/)

/etc/docker/daemon.json

``` json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "500m",
    "max-file": "10",
    "compress": "true",
    "labels": "production_status",
    "env": "os,customer"
  }
}
```

[How to setup log rotation for a Docker container](https://www.freecodecamp.org/news/how-to-setup-log-rotation-for-a-docker-container-a508093912b2/)
如果不配置
By default, the stdout and stderr of the container are written in a JSON file located in /var/lib/docker/containers/[container-id]/[container-id]-json.log

### 迁移数据目录 /var/lib/docker

systemctl stop docker.service
systemctl stop docker.socket

rsync -avzP /var/lib/docker  /data/lib/

### Habor 镜像仓库

docker login http://IP:PORT -u username -p "password"
docker push ${image}:${imageTag}

### 镜像加速

[Docker 镜像加速](https://www.runoob.com/docker/docker-mirror-acceleration.html)
[Docker被封禁的离线镜像临时方案 tar 包上传- 掘金](https://juejin.cn/post/7381478389469839397)
[DockerHub国内镜像源列表（2024年6月18日 亲测可用） - 软件分享 - LINUX DO](https://linux.do/t/topic/114516)
[国内的 Docker Hub 镜像加速器，由国内教育机构与各大云服务商提供的镜像加速服务 | Dockerized 实践 https://github.com/y0ngb1n/dockerized · GitHub](https://gist.github.com/y0ngb1n/7e8f16af3242c7815e7ca2f0833d3ea6)

[公开镜像加速 - DaoCloud Enterprise](https://docs.daocloud.io/community/mirror.html)
很多镜像都在国外，比如 gcr。国内下载很慢，需要加速。 DaoCloud 为此提供了国内镜像加速，便于从国内拉取这些镜像。

使用方法 增加前缀（推荐）：k8s.gcr.io/coredns/coredns => m.daocloud.io/k8s.gcr.io/coredns/coredns

## containerd 命令

ctr 是 containerd 的一个客户端工具。
crictl 是 CRI 兼容的容器运行时命令行接口，可以使用它来检查和调试 k8s 节点上的容器运行时和应用程序。
`ctr -v` 输出的是 containerd 的版本，`crictl -v` 输出的是当前 k8s 的版本，从结果显而易见你可以认为 crictl 是用于 k8s 的。

```sh
# Save the Image as a Tar File
ctr image export dashboard.tar dashboard
ctr -n=k8s.io image export dashboard.tar dashboard

# 使用ctr导入镜像
ctr image import dashboard.tar

# ctr是containerd自带的工具，有命名空间的概念，若是k8s相关的镜像，都默认在k8s.io这个命名空间，所以导入镜像时需要指定命令空间为 k8s.io
# 使用ctr命令指定命名空间导入镜像
ctr -n=k8s.io image import dashboard.tar

#查询镜像
ctr -n=k8s.io images ls
crictl images

# pull image
# kubeadm config images list --kubernetes-version=v1.15.2
ctr image pull k8s.gcr.io/prometheus-adapter/prometheus-adapter:v0.9.1
crictl pull k8s.gcr.io/prometheus-adapter/prometheus-adapter:v0.9.1

# 创建 k8s.io 命名空间
ctr ns create k8s.io

# 查看命名空间
ctr ns ls
```
