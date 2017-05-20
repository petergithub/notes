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


