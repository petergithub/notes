# SSH Notes

`ssh -p port user@host`    在端口 port 以 user 用户身份连接到 host

* `-C`    压缩传送的数据
* `-f`    ssh将在后台运行
* `-g`    Allows remote hosts to connect to local forwarded ports.
* `-i`    使用指定的密钥登录
* `-L 3307:remoteHost:3306` - Creates a local port forwarding. The local port (3307), the destination IP (remoteHost) and the remote port (3306) are separated with a colon (:).
* `-N`    不执行命令, 仅转发端口
* `-T`    表示不为这个连接分配TTY
  * It is required that your private key files are NOT accessible by others
  * Keys need to be only readable(400 or 600 is fine)  chmod 600 ~/.ssh/id_rsa
* `-t` Force pseudo-tty allocation for bash to use as an interactive shell
* `-o PreferredAuthentications=password` login with password,  默认会依次尝试 GSSAPI-based认证, host-based认证, public key认证, challenge response认证, password认证 这几种认证方式. PreferredAuthentications 可以修改顺序
* `-o PublicAuthentication=no`表示关闭公钥认证方式. 这样就能保证当服务端不支持密码认证时,也不会使用公钥认证.
* `-oStrictHostKeyChecking=no` you will not be prompted to accept a host key but with some waring sometimes.
* `-oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null` you will not be prompted to accept a host key and makes warnings disappear
* `--login` set up the login environment `ssh user@host "bash --login -c 'command arg1 ...'"` will make the remote shell set up the login environment

`sshpass` make ssh with password in command line

ssh login log `/var/log/secure` is configured in /etc/ssh/sshd_config

## ssh help

`reset` 恢复出现问题的屏幕
escape_char (default: '~').  The escape character is only recognized at the beginning of a line.
`~`符号是ssh命令中的转义字符. 通过在ssh连接中输入`~?,` 你可以看到完整的命令帮助.
`~.`    terminate session。 ssh连接变得无响应了, 让连接立即终断 阻塞的终端上输入`Enter~.`三个字符,表示终结当前SSH会话.
`~^Z`   suspends the connection
`fg`    reconnect

## ssh a new host

### ssh-keygen

* `ssh-keygen -t rsa -b 4096 -C "your_email@example.com"`    #Creates a new ssh key, using the provided email as a label #Generating public/private rsa key pair.
* `ssh-keygen -p` change the passphrase for an existing private key without regenerating the keypair
* `ssh-keygen -y -f ~/.ssh/id_rsa > ~/.ssh/id_rsa.pub` outputs the public key

### 添加公钥到远程服务器

* `ssh-copy-id user@host`    将公钥添加到 host 以实现无密码登录
* `ssh-copy-id -i ~/.ssh/id_rsa.pub username@host`
* `cat ~/.ssh/id_rsa.pub | ssh user@host "mkdir ~/.ssh; cat >> ~/.ssh/authorized_keys"`    从一台没有SSH-COPY-ID命令的主机将你的SSH公钥复制到服务器
* `ssh user@host 'mkdir -p .ssh && cat >> .ssh/authorized_keys < ~/.ssh/id_rsa.pub'`

## ssh 远程操作

### 远程执行命令

* `ssh -t user@server "mail && bash"`    Single command to login to SSH and run program
* `ssh user@host -l user "cat cmd.txt"`    通过SSH运行复杂的远程shell命令
* `ssh user@host 'bash -s' < local_script.sh` execute the local script on the remote server

### 远程 copy 文件

* `cd && tar czv src | ssh user@host 'tar xz'`    将`$HOME/src/`目录下面的所有文件, 复制到远程主机的`$HOME/src/`目录
* `ssh user@host 'tar cz src' | tar xzv`    将远程主机`$HOME/src/`目录下面的所有文件, 复制到用户的当前目录
* `vim scp://user@remoteserver//etc/hosts` Edit text files with VIM over ssh/scp
* `mysqldump --add-drop-table --extended-insert --force --log-error=error.log -uUSER -pPASS OLD_DB_NAME | ssh -C user@newhost "mysql -uUSER -pPASS NEW_DB_NAME"`    通过SSH将MySQL数据库复制到新服务器
* `sshfs name@server:/path/to/folder /path/to/mount/point` 通过 SSH 来 mount 文件系统

## 开启认证代理连接转发功能

[What is SSH Agent Forwarding and How Do You Use It?](https://www.cloudsavvyit.com/25/what-is-ssh-agent-forwarding-and-how-do-you-use-it/)

[ssh转发代理：ssh-agent用法详解](https://www.cnblogs.com/f-ck-need-u/p/10484531.html)

在 server 上使用本地的私钥来进行认证，不需要拷贝本地私钥到 server

```bash
# 开启代理
ssh-agent
# 添加密钥到ssh-agent的高速缓存中
ssh-add ~/.ssh/id_rsa
# 查看是否添加成功
ssh-add -l

# 注意 ssh 到第一台 server1 的时候，使用 -A 选项 开启认证代理连接转发功能
ssh -A server1
# 登录需要本地私钥的服务器，登陆其他 server2 的时候，只支持 ip 地址访问，可以在 server1 的 /etc/hosts 里面配置host，就可以通过主机名访问
ssh -p port root@server2
```

ssh-agent的工作是依赖于环境变量 `SSH_AUTH_SOCK` 和 `SSH_AGENT_PID`

## Troubleshooting sshd

[OpenSSH Configuring](https://help.ubuntu.com/community/SSH/OpenSSH/Configuring)

1. `ps -ef | grep ssh`, `sudo ss -lnp | grep sshd` or `sudo netstat -anp | grep sshd`
`root      3865     1  0 11:53 ?        00:00:00 /usr/sbin/sshd -D`
2. `sudo service ssh restart`
3. `less /var/log/syslog`
4. `$(which sshd) -Ddp 10222`

### Troubleshooting ssh

[networking_2ndEd ssh](https://docstore.mik.ua/orelly/networking_2ndEd/ssh/ch12_01.htm)

### Bad owner or permissions on .ssh/config

`chmod 600 .ssh/config`

### Too many authentication failures

> This is usually caused by inadvertently offering multiple ssh keys to the server. The server will reject any key after too many keys have been offered.
> To prevent irrelevant keys from being offered, you have to explicitly specify this in every host entry in the ~/.ssh/config (on the client machine) file by adding IdentitiesOnly like so

```bash
# -o 'IdentitiesOnly yes'

Host www.somehost.com
  IdentityFile ~/.ssh/key_for_somehost_rsa
  IdentitiesOnly yes
  Port 22
```

## Keep SSH Sessions Alive 保持SSH连接不断线

1. client: ssh -o ServerAliveInterval=60 username@host
2. update .ssh/config
源头发力的办法就是, 让ssh一直尝试与服务器通信, 不让其空闲下来, 间隔时间与服务器发keepalive的心跳包, 通过简单的ssh设置就能做到这一点
vim .ssh/config 打开SSH的配置文件,添加下面两行到其中
`ServerAliveInterval <X>`
`ServerAliveCountMax <Y>`
上面的X表示, 两次心跳指令的发送间隔秒数, Y则代表发送指令的最大数量, 你可以根据你要离开的时间, 灵活的做出调整. 或者你也可以不对最大发送指令数量, 做限制, 只给出一个间隔时间, 保持心跳包接受顺畅就好

> ServerAliveInterval: number of seconds that the client will wait before sending a null packet to the server (to keep the connection alive).
> ClientAliveInterval: number of seconds that the server will wait before sending a null packet to the client (to keep the connection alive).
> Setting a value of 0 (the default) will disable these features so your connection could drop if it is idle for too long.

## SSH隧道 端口转发(Port Forwarding)

这是一种隧道(tunneling)技术

* [远程操作与端口转发](http://www.ruanyifeng.com/blog/2011/12/ssh_port_forwarding.html )
* [Linux下ssh动态端口转发](https://www.chenyudong.com/archives/linux-ssh-port-dynamic-forward.html )
* [实战 SSH 端口转发](https://www.ibm.com/developerworks/cn/linux/l-cn-sshforward )
* [SSH隧道：端口转发功能详解](https://www.cnblogs.com/f-ck-need-u/p/10482832.html)

* 正向代理（-L）：相当于 iptable 的 port forwarding
* 反向代理（-R）：相当于 frp 或者 ngrok
* socks5 代理（-D）：相当于 ss/ssr

### 动态转发

* `ssh -D <local port> <SSH Server>`    动态转发 如果SSH Server是境外服务器, 则该SOCKS代理实际上具备了翻墙功能
* `ssh -D 7070 remoteServer -gfNT` Dynamic forward all the connection by SOCKS
* `ssh -D 7070 -l username proxy.remotehost.com -gfNT -o ProxyCommand="connect -H web-proxy.oa.com:8080 %h %p "` 给ssh连接增加http代理, 如果你的PC无法直接访问到ssh服务器上，但是有http代理可以访问，那么可以为建立这个socks5的动态端口转发加上一个代理. 其中ProxyCommand指定了使用`connect`程序(`sudo apt-get install connect-proxy`)来进行代理。通常还可以使用corkscrew来达到相同的效果。

### 本地端口转发

localhost 连不上remoteSecret, remoteHost可以连通localhost和remoteSecret, 通过remoteHost连上remoteSecret

* `ssh -gL localPort:remoteSecret:remoteSecretPort remoteHost`    #在localhost执行本地端口转发Local forwarding:connect remoteSecret through remoteHost
* `ssh -gL <localhost>:<local port>:<remote host>:<remote port> <SSH hostname>`  # localhost 可以是 0.0.0.0 运行本地网络的其他机器连接

其工作方式为：在本地指定一个由ssh监听的转发端口(localPort)，将远程主机的端口(remoteSecret:remoteSecretPort)映射为本地端口(localPort)，当有主机连接本地映射端口(localPort)时，本地ssh就将此端口的数据包转发给中间主机(remoteHost)，然后 remoteHost 再与远程主机的端口(remoteSecret:remoteSecretPort)通信。

example 1: 通过 host3 的端口转发, ssh通过连接 localhost 登录 host2

1. `ssh -gfNTL 9001:host2:22 host3` 在本机执行(建议使用参数 `ssh -gfNTL`)
2. `ssh -p 9001 localhost` ssh登录本机的9001端口, 相当于连接host2的22端口

example 2: 通过 host3 的端口转发, local 通过连接 localhost:9001 访问 host2:80

1. `ssh -gfNTL 9001:host2:80 host3` 在本机执行(建议使用参数 `ssh -gfNTL`)
2. `curl localhost:9001` ssh登录本机的9001端口, 相当于连接host2的22端口

### 远程端口转发

localhost与remoteSecret之间无法连通, 必须借助remoteHost转发, 不过remoteHost是一台内网机器, 它可以连接外网的localhost, 但是反过来就不行, 外网的localhost连不上内网的remoteHost.

解决办法:从remoteHost上建立与localhost的SSH连接, 然后在localhost上使用这条连接

1. `ssh -R localPort:remoteSecret:remoteSecretPort localhost`    #在remoteHost执行
2. `ssh -p localPort localhost`    #在localhost上SSH本机localPort, 即连接上了remoteSecret

`ssh -R <localhost>:<local port>:<remote host>:<remote port> <SSH hostname>`    #远程端口转发remote forwarding

## Jumphost

Bastion host 堡垒机 跳板机

[How To Use A Jumphost in your SSH Client Configurations](https://ma.ttias.be/use-jumphost-ssh-client-configurations/ )

Jumphosts are used as intermediate hops between your actual SSH target and yourself. Instead of using something like "unsecure" SSH agent forwarding, you can use ProxyCommand to proxy all your commands through your jumphost.
You want to connect to HOST B and have to go through HOST A, because of firewalling, routing, access privileges

```text
+---+       +---+       +---+
|You|   ->  | A |   ->  | B |
+---+       +---+       +---+
```

Classic SSH Jumphost configuration

### ProxyCommand

A configuration like this will allow you to proxy through HOST A.

```config
# $ cat .ssh/config
Host host-a
    Hostname 10.0.0.5
    User your_username

Host host_b
    Hostname 192.168.0.1
    User your_username
    Port 22
    ProxyCommand ssh -q -W %h:%p host-a
```

Now if you want to connect to your HOST B, all you have to type is `ssh host_b`, which will first connect to `host-a` in the background (that is the `ProxyCommand` being executed) and start the SSH session to your actual target.

SSH Jumphost configuration with netcat (nc)
Alternatively, if you can't/don't want to use ssh to tunnel your connections, you can also use nc (netcat).
configure it in ./ssh/config with `ProxyCommand`
`ProxyCommand ssh host-a nc -w 120 %h %p`

If netcat is not available to you as a regular user, because permissions are limited, you can prefix it with sudo
`ProxyCommand ssh host-a sudo nc -w 120 %h %p`

### ProxyJump

Starting from OpenSSH 7.3, released August 2016, ssh support ProxyJump

`ssh -J host1,host2,host3 user@host4.internal` A key thing to understand here is that this is not the same as ssh host1 then user@host1:~$ ssh host2, the -J jump parameter uses forwarding trickery so that the localhost is establishing the session with the next host in the chain.

``` bash
Host host2
    HostName 172.17.1.172
    Port 22
    IdentityFile ~/.ssh/id_rsa
    #ProxyCommand ssh -q -W %h:%p jump
    ProxyJump jump
```

## 创建Kerberos的keytab文件

```bash
cd /data/
ktutil
addent -password -p username@GMAIL.COM -k 1 -e aes256-cts
wkt username.keytab
quit
```

alias ssh35="kinit username@GMAIL.COM -k -t ~/username.keytab;ssh work@host1 -t 'ssh host2;bash -l'"
ssh root@MachineB 'bash -s' < local_script.sh    #run local shell script on a remote machine
trace kinit with `KRB5_TRACE=/dev/stdout kinit username`

## test

* `yes | pv | ssh $host "cat > /dev/null"`    实时SSH网络吞吐量测试 通过SSH连接到主机, 显示实时的传输速度, 将所有传输数据指向/dev/null, 需要先安装pv.Debian(apt-get install pv) Fedora(yum install pv)
* `yes | pv | cat > /dev/null`

## pssh

pssh  is  a  program  for executing ssh in parallel on a number of hosts.

* `pssh -ih /path/to/host.txt date` Pass list of hosts using a file
* `pssh -iH "host1 host2" date` Pass list of hosts manually
* `pssh -i -o /tmp/out/ -H "10.43.138.2 10.43.138.3 10.43.138.9" -l root date` Storing the STDOUT

### pssh options

* Using `-o` or `--outdir` you can save standard output to files
* Using `-e` or `--errdir` you can save standard error to files

## scp

* `scp client_file user@host:filepath`    上传文件到服务器端
* `scp user@host:server_files client_file_path`    下载文件
* `scp -3 -P port1 ruser1@rhost1:/rpath/1 scp://ruser2@rhost2:port2/rpath/2` scp from rhost1 to rhost2
* `scp -3 host1:source_file host2:target_file`

client_file 待上传的文件, 可以有多个, 多个文件之间用空格隔开. 也可以用*.filetype上传某个类型的全部文件
user 服务端登录用户名, host 服务器名（IP或域名）, filepath 上传到服务器的目标路径（这里注意此用户一定要有这个路径的读写权限）

### scp 断点续传

* `rsync --partial --progress --rsh="ssh -p 222" user@host:remote_file local_file` resume an scp transfer for different port than default 22
* [linux - Is there a way to resume an interrupted scp of a file? - Super User](https://superuser.com/questions/421672/is-there-a-way-to-resume-an-interrupted-scp-of-a-file)

  You can try the following approch: instead of `scp` use `dd` to skip over the downloaded part and append the remainder to the file.

  sofar=`ls -l ./destfile | awk '{print $5}'`
  ssh user@host "dd if=./srcfile bs=1024 skip=$sofar" >> ./destfile

### Windows putty plink pscp

* pscp.exe -pw pwd filename username@host:directory/subdirectory
* plink -pw pwd username@host ls;ls
* plink -pw pwd username@host -m local_script.sh
* plink -i %putty%/privateKey.ppk

Windows的控制台会把两个双引号之间的字符串作为一个参数传递给被执行的程序, 而不会把双引号也传递给程序
所以错误命令`C:\>plink 192.168.6.200 ls "-l"`
Windows控制台不认得单引号, 所以上面那个命令的正确用法应该是:
`c:\>plink 192.168.6.200 ls '-l'`
