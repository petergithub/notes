`sudo docker run -i -t ubuntu:14.04 /bin/bash`  #start a container base on the image. 这样在这个container中启动了一个终端并运行bash 其中， -t 选项让Docker分配一个伪终端（pseudo-tty）并绑定到容器的标准输入上， -i 则让容器的标准输入保持打开。
-d 可以让它后台运行。
exit 退出。

`docker commit [OPTIONS] CONTAINER [REPOSITORY[:TAG]]`
rename image `docker tag server:latest myname/server:latest`

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
`docker run –d –p 6378:6379 --name port-redis redis`
`docker run -d -p 8083:8080 7c34bafd1150` (使用imagesid启动tomcat)
