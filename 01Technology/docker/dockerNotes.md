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

* `--add-host="localhostA:127.0.0.1" --add-host="localhostB:127.0.0.1"` append to /etc/hosts
* `-t` 分配一个伪终端（pseudo-tty）并绑定到容器的标准输入上
* `-i` 让容器的标准输入保持打开
* `-p` [host:]port:dockerPort
* `-d, --detach` 后台运行
* `-e` 设置环境变量，与在dockerfile env设置相同效果 `-e TZ=Asia/Shanghai`, `-e MYSQL_ROOT_PASSWORD=root`
* `--rm` 在容器终止运行后自动删除容器文件
* `-v, --volume "/path/to/host/machine:/path/to/container`
* `--restart always` [Start containers automatically](https://docs.docker.com/config/containers/start-containers-automatically/)

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

* `-a, --all` Show all containers (default shows just running)
* `-n, --last int` Show n last created containers (includes all states) (default -1)
* `-l, --latest` Show the latest created container (includes all states)

#### Docker management

`docker system df` 磁盘占用

`docker stats`  a live look at your containers resource utilization

* Memory is listed under the MEM USAGE / LIMIT column. This provides a snapshot of how much memory the container is utilizing and what it’s memory limit is.
* CPU utilization is listed under the CPU % column.
* Network traffic is represented under the NET I/O column. It displays the outgoing and incoming traffic consumption of a container.
* Storage utilization is shown under the BLOCK I/O column. This show you the amount of reads and writes a container is peforming to disk.

`docker stats --no-stream` the first stats pull results

#### Restart containers automatically

[Start containers automatically | Docker Documentation](https://docs.docker.com/config/containers/start-containers-automatically/)

[How do I make a Docker container start automatically on system boot? - Stack Overflow](https://stackoverflow.com/questions/30449313/how-do-i-make-a-docker-container-start-automatically-on-system-boot)

The default restart policy is no. For the created containers use docker update to update restart policy.

`docker update --restart unless-stopped <containerID>`

### image

`docker images` Show all images in your local repository

`docker commit [OPTIONS] CONTAINER [REPOSITORY[:TAG]]`
`docker tag server:latest myname/server:latest` Rename image
`docker tag IMAGE[:TAG] [REGISTRY_HOST[:REGISTRY_PORT]/]REPOSITORY[:TAG]`

`docker rm <container_id/contaner_name>`
`docker rm $(docker ps -a -q | grep -v $(docker ps -q))` Remove all containers from this machine except the running one
`docker rm $(docker ps -a -q)` Remove all containers from this machine
`docker rmi <image_id/image_name ...>`
`docker image prune` clean up unused images. By default, docker image prune only cleans up dangling images. A dangling image is one that is not tagged and is not referenced by any container. [Prune unused Docker objects](https://docs.docker.com/config/pruning/)

`docker save <image-id> -o filename` 创建一个镜像的压缩文件，这个文件能够在另外一个主机的Docker上使用. 和export命令不同，这个命令为每一个层都保存了它们的元数据。这个命令只能对镜像生效。
`docker load -i filename` Load an image from a tar archive or STDIN

`docker export <container-id>` 将 container 创建一个`tar`文件，并且移除了元数据和不必要的层，将多个层整合成了一个层，只保存了当前统一视角看到的内容（译者注：expoxt后的容器再import到Docker中，通过`docker images –tree`命令只能看到一个镜像；而save后的镜像则不同，它能够看到这个镜像的历史镜像）
`docker import`

#### build image with Dockerfile

`docker build -t imageName /path/to/DockerfileFolder -f /path/to/Dockerfile`

[Dockerfile最佳实践](https://zhuanlan.zhihu.com/p/75013836)
将标准日志与错误日志分别输出到stdout与stderr

日志输出到标准输出与错误输出，方便查看与采集日志。参考 Nginx 的 dockerfile ：

``` shell
#forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log
```

### 和系统交互

拷贝文件: `docker cp scala-2.10.6.tgz ubuntu-hadoop:/home/hadoop/`

### Docker 中国官方镜像

[Docker 镜像加速](https://www.runoob.com/docker/docker-mirror-acceleration.html)

#### `docker pull registry.docker-cn.com/myname/myrepo:mytag`

#### global setting

`vi /etc/docker/daemon.json`
{
    "registry-mirrors": ["http://hub-mirror.c.163.com"]
}

`systemctl restart docker.service`

`docker info | grep -A 2 Mirrors` 检查加速器是否生效

``` html
国内加速站点
https://registry.docker-cn.com
http://hub-mirror.c.163.com
https://mirror.ccs.tencentyun.com
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

## Sample

start a ubuntu container and running bash `docker run -itd ubuntu:14.04 /bin/bash`
start a nginx server with `docker run -d -p 80:80 --name webserver nginx`
start a tensorflow container `docker run -d --name tensorflow tensorflow/tensorflow`
`docker run --name redis -p 6379:6379 -d redis`
`docker run --name mongo -d mongo:4.2.7`

Jenkins with blue ocean: `docker run -d -p 8081:8080 -p 50000:50000 -v /data/docker/jenkins/jenkins_home:/var/jenkins_home -v /usr/share/apache-maven:/usr/local/maven    -v /etc/localtime:/etc/localtime --name jenkins jenkinsci/blueocean:1.25.5`

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

* FROM centos:7：该 image 文件继承的 centos image
* COPY . /data：将当前目录下的所有文件（除了.dockerignore排除的路径），都拷贝进入 image 文件的/data目录。
* WORKDIR /data：指定接下来的工作路径为/data。
* RUN yum install -y iproute：在`/data`目录下，运行`yum`命令安装依赖。注意，安装后所有的依赖，都将打包进入 image 文件, 可以包含多个RUN命令
* EXPOSE 8080：将容器 `8080` 端口暴露出来， 允许外部连接这个端口。
* CMD 命令在容器启动后执行, 只能有一个 有两种格式
  * shell 格式：`CMD <命令>`。实际的命令会被包装为 `sh -c` 的参数的形式进行执行，先运行一个 shell 进程。
  * exec 格式：`CMD ["可执行文件", "参数1", "参数2"...]`。推荐使用 exec 格式，这类格式在解析时会被解析为 JSON 数组，因此一定要使用双引号 "，而不要使用单引号。
* 当指定了 ENTRYPOINT 后，CMD 的含义就发生了改变，不再是直接的运行其命令，而是将 CMD 的内容作为参数传给 ENTRYPOINT 指令，换句话说实际执行时，将变为：
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
