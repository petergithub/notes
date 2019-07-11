# Docker Notes

`docker run` 只在第一次运行时使用，将镜像放到容器中，以后再次启动这个容器时，使用 `docker start imageName`

docker start docker-mysql-5.6
docker exec -it docker-mysql-5.6 bash

`docker images` Show all images in your local repository  

`docker run -it --name=containerName <image_id || repository:tag> bash` Run a command in a new container
`docker run = docker create + docker start`
start a ubuntu container and running bash `docker run -itd ubuntu:14.04 /bin/bash`
start a nginx server with `docker run -d -p 80:80 --name webserver nginx`
start a tensorflow container `docker run -d --name tensorflow tensorflow/tensorflow`

* `--add-host="localhostA:127.0.0.1" --add-host="localhostB:127.0.0.1"` append to /etc/hosts
* `-t` 分配一个伪终端（pseudo-tty）并绑定到容器的标准输入上  
* `-i` 让容器的标准输入保持打开  
* `-p` [host:]port:dockerPort
* `-d` 后台运行  
* `-e` 设置环境变量，与在dockerfile env设置相同效果 `-e MYSQL_ROOT_PASSWORD=root`  
* `--rm` 在容器终止运行后自动删除容器文件  
* `-v, --volume "/path/to/host/machine:/path/to/container`

`docker start -i <image_id>` Start a existed container  
`docker attach <container_id>` Attach a running container
`docker exec -it [containerID] /bin/bash` 进入一个正在运行的 docker 容器  
`[Ctrl-p] + [Ctrl-q]` Exit without shutting down a container  

`exit` 退出
`docker stop <hash>` Gracefully stop the specified container
`docker kill [containID]` 手动终止容器  

`docker ps` Show running containers  

* `-a, --all` Show all containers (default shows just running)  
* `-n, --last int` Show n last created containers (includes all states) (default -1)  
* `-l, --latest` Show the latest created container (includes all states)  

`docker commit [OPTIONS] CONTAINER [REPOSITORY[:TAG]]`  
`docker tag server:latest myname/server:latest` Rename image  

`docker rm <container_id/contaner_name>`  
`docker rm $(docker ps -a -q | grep -v $(docker ps -q))` Remove all containers from this machine except the running one
`docker rm $(docker ps -a -q)` Remove all containers from this machine
`docker rmi <image_id/image_name ...>`  

`docker save <image-id>` 创建一个镜像的压缩文件，这个文件能够在另外一个主机的Docker上使用. 和export命令不同，这个命令为每一个层都保存了它们的元数据。这个命令只能对镜像生效。
`docker export <container-id>` docker export命令创建一个tar文件，并且移除了元数据和不必要的层，将多个层整合成了一个层，只保存了当前统一视角看到的内容（译者注：expoxt后的容器再import到Docker中，通过docker images –tree命令只能看到一个镜像；而save后的镜像则不同，它能够看到这个镜像的历史镜像）。

拷贝文件: `docker cp scala-2.10.6.tgz ubuntu-hadoop:/home/hadoop/`  

## Usage

### centOS

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
* CMD 命令在容器启动后执行, 只能有一个

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

#### Docker commit the changes you make to the container and then run it.

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
