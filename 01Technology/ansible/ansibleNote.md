# Ansible

[Introduction to ad hoc commands — Ansible Community Documentation](https://docs.ansible.com/ansible/latest/command_guide/intro_adhoc.html)
[Ansible Galaxy - Welcome to Galaxy](https://galaxy.ansible.com/ui/)

[一步到位玩透Ansible | 骏马金龙](https://www.junmajinlong.com/ansible/index/)
[Ansible 学习笔记 | SRE运维进阶之路](https://clay-wangzhi.com/devops/ansible/)

`ansible [host_pattern] -m [module] -a "[module options]"`

option

- `all` ansible中，将其叫做 pattern，即匹配。我通常称它为资产选择器。就是匹配资产（-i参数指定）中的一部分。这里的all是匹配所有指定的所有资产。
- `-i` Inventory，指定主机，默认是/etc/ansible/hosts
- `-a 'MODULE_ARGS', --args 'MODULE_ARGS'` 模块的参数(比如使用command模块，那么-a参数就是要执行的命令) The action's options in space separated k=v format: -a 'opt1=val1 opt2=val2' or a json string: -a '{"opt1": "val1", "opt2": "val2"}'
- `-m 'MODULE_NAME', --module-name 'MODULE_NAME'` 指定模块的名称（不指定-m，那么默认是command模块）
- `-u 'REMOTE_USER', --user 'REMOTE_USER'` remote user，默认使用root用户登陆
- `-k` 用来提示输入远程主机的密码(基于用户密码登录)
- `-f 'FORKS', --forks 'FORKS'` 一次执行几个进程(并发数量)，默认为5个
- `-l 'SUBSET', --limit 'SUBSET'` limit selected hosts to an additional pattern `--limit='qj:!qj_2506'`
- `-o, --oneline` 以单行格式显示Ansible临时命令的输出
- `--sudo` 执行命令时使用 sudo 权限(需要用户具有sudo权限)
- `--key-file`: 建立SSH链接的私钥文件
- `--list-hosts`: 列出匹配到的服务器列表
- `-C, --check` check mode, Ansible does not make any changes to remote systems.
- `-c, --connection`connection type to use (default=ssh):  ssh, local, smart
- `-v` 显示任务结果
- `-vv` 任务结果和任务配置都会显示
- `-vvv` 包含关于与受管主机连接的信息
- `-vvvv` 增加了连接插件相关的额外详细程序选项，包括受管主机上用于执行脚本的用户以及所执行的脚本

```sh
sudo apt install ansible

# 显示 Ansible 版本以及正在使用的配置文件
ansible --version
ansible all --list-hosts
ansible ungrouped --list-hosts

# 测试与所有被管理节点的网络连通性
# -i 参数后面的是一个列表(List)。当只有一个被管理节点时，后面要加一个英文逗号
ansible all -i 192.168.40.137, -m ping
ansible all -i 192.168.40.137,192.168.40.138 -m ping

ansible bj -a date
# -o 选项以单行格式显示Ansible临时命令的输出
ansible bj -a date -o
ansible all -i ja151, -m ping
ansible myhosts -i inventory.ini -m ping

ansible bj -i inventory.yaml -a 'df -h'

# 在管理节点上，确保文件/tmp/a.conf发布到所有被管理节点
ansible all -i 192.168.40.137,192.168.40.138 -m copy -a "src=/tmp/a.conf dest=/tmp/a.conf"
# An ad hoc task can harness the power of Ansible and SCP to transfer many files to multiple machines in parallel. To transfer a file directly to all servers in the [atlanta] group:
ansible all -m ansible.builtin.copy -a "src=/etc/hosts dest=/tmp/hosts"

# Check mode
# In check mode, Ansible does not make any changes to remote systems. Ansible prints the commands only. It does not run the commands.
# --check, -C
ansible all -m copy -a "content=foo dest=/root/bar.txt" -C
# Enabling check mode (-C or --check) in the above command means Ansible does not actually create or update the /root/bar.txt file on any remote systems.

# 查看模块的帮助：
ansible-doc -l # 查看核心的模块(包含模块的大致说明,比较慢)
ansible-doc -s 'command' # 执行模块名，可以列出模块的用法
ansible-doc ping
```

## ansible config

Changes can be made and used in a configuration file which will be searched for in the following order:

1. ANSIBLE_CONFIG (environment variable if set)
2. ansible.cfg (in the current directory)
3. ~/.ansible.cfg (in the home directory)
4. /etc/ansible/ansible.cfg

```ini
# some basic default values...
inventory = /etc/ansible/hosts  ; This points to the file that lists your hosts
```

## Building an inventory

[Building an inventory — Ansible Community Documentation](https://docs.ansible.com/ansible/latest/getting_started/get_started_inventory.html)

Tips for building inventories

- Ensure that group names are meaningful and unique. Group names are also case sensitive.
- Avoid spaces, hyphens, and preceding numbers (use floor_19, not 19th_floor) in group names.
- Group hosts in your inventory logically according to their What, Where, and When.

What
  Group hosts according to the topology, for example: db, web, leaf, spine.

Where
  Group hosts by geographic location, for example: datacenter, region, floor, building.

When
  Group hosts by stage, for example: development, test, staging, production.

Use metagroups

```yaml
metagroupname:
  children:
```

```sh
# Inventories in INI format
# -a 追加
tee -a inventory.ini <<EOF
[myhosts]
192.0.2.50
192.0.2.51
192.0.2.52
EOF

# Verify your inventory.
ansible-inventory -i inventory.ini --list
# Ping the myhosts group in your inventory.
ansible myhosts -m ping -i inventory.ini

# Inventories in YAML format
tee -a inventory.yaml <<EOF
myhosts:
  hosts:
    my_host_01:
      ansible_host: 192.0.2.50
    my_host_02:
      ansible_host: 192.0.2.51
    my_host_03:
      ansible_host: 192.0.2.52
EOF
```

[How to build your inventory — Ansible Community Documentation](https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html)

```yaml
ungrouped:
  hosts:
    mail.example.com:
webservers:
  hosts:
    foo.example.com:
    bar.example.com:
    www[01:50].example.com:
dbservers:
  hosts:
    one.example.com:
    two.example.com:
    three.example.com:
    db-[a:f].example.com:
east:
  hosts:
    foo.example.com:
    one.example.com:
    two.example.com:
west:
  hosts:
    bar.example.com:
    three.example.com:
prod:
  children:
    east:
test:
  children:
    west:
```

## Ad-hoc commands

[Introduction to ad hoc commands](https://docs.ansible.com/ansible/latest/command_guide/intro_adhoc.html)

### module command

```sh
# -m command 是默认模块
# command模块允许管理员对受管主机快速执行远程命令。这些命令不是由受管主机上的shell加以处理。因此，它们无法访问shell环境变量，也不能执行重定向和管道等shell操作。
ansible all -m command -a uptime
ansible all -a uptime
# ping
ansible myhosts -m ping -i inventory.ini
# shell
ansible raleigh -m ansible.builtin.shell -a 'echo $TERM'
```

### module shell

```sh
# 与command模块不同，shell 模块是通过受管主机上的shell进行处理。因此，可以访问shell环境变量，也可以使用重定向和管道等操作。
ansible all -m shell -a 'set'
ansible sj-monitor01 -m shell -a 'reboot'
ansible sj-monitor01 -m shell -a 'grep ONBOOT=no /etc/sysconfig/network-scripts/ifcfg-ens192'
ansible sj-monitor01 -m shell -a "sed -i 's/ONBOOT=no/ONBOOT=yes/g;' /etc/sysconfig/network-scripts/ifcfg-ens192"

# raw
# command和shell模块都要求受管主机上安装正常工作的Python。模块 raw 可以绕过模块子系统，直接使用远程shell运行命令。在管理无法安装Python的系统（如网络路由器）时，可以利用这个模块。它也可以用于将Python安装到主机上
# 建议避免使用command、shell和raw这三个“运行命令”模块。
ansible 172.16.103.129 -m raw -a 'echo "hello world" > /tmp/test'
```

### module script

```sh
# script模块用于在受控机上执行主控机上的脚本
ansible 172.16.103.129 -m script -a '/etc/ansible/scripts/a.sh &>/tmp/a'
```

### module Managing files

```sh
# copy
ansible atlanta -m ansible.builtin.copy -a "src=/etc/hosts dest=/tmp/hosts"
# Fetch 将远程文件收集到本地, 会有一个目录名是远程主机名，目录里面的内容是收集过来的文件
ansible all -m fetch -a "src=/tmp/hello dest=./ "

# File
# create directories, similar to mkdir -p:
ansible webservers -m ansible.builtin.file -a "dest=/path/to/c mode=755 owner=mdehaan group=mdehaan state=directory"
# changing ownership and permissions on files
ansible webservers -m ansible.builtin.file -a "dest=/srv/foo/b.txt mode=600 owner=mdehaan group=mdehaan"
# delete directories (recursively) and delete files:
ansible webservers -m ansible.builtin.file -a "dest=/path/to/c state=absent"
```

### module find

find模块查询目标主机上的文件
fileglob 查询的是 Ansible 端文件，只能通配文件而不能通配目录，且不会递归通配。

### module Managing packages

```sh
# To ensure a package is installed without updating it:
ansible webservers -m ansible.builtin.yum -a "name=acme state=present"
# To ensure a specific version of a package is installed:
ansible webservers -m ansible.builtin.yum -a "name=acme-1.5 state=present"
# To ensure a package is at the latest version:
ansible webservers -m ansible.builtin.yum -a "name=acme state=latest"
# To ensure a package is not installed:
ansible webservers -m ansible.builtin.yum -a "name=acme state=absent"
```

### module Managing services

```sh
# Ensure a service is started on all webservers:
ansible webservers -m ansible.builtin.service -a "name=httpd state=started"
# Alternatively, restart a service on all webservers:
ansible webservers -m ansible.builtin.service -a "name=httpd state=restarted"
# Ensure a service is stopped:
ansible webservers -m ansible.builtin.service -a "name=httpd state=stopped"

# systemd
# state：管理服务状态 started restarted stopped reloaded
ansible all -m systemd -a "name=nginx state=stopped enabled=no"
```

### module Gathering facts

```sh
# Facts represent discovered variables about a system. You can use facts to implement conditional execution of tasks but also just to get ad hoc information about your systems. To see all facts:
ansible all -m ansible.builtin.setup

# Display only facts about certain interfaces.
# network name: ens192
ansible all -m ansible.builtin.setup -a 'filter=ansible_ens*'
# Only collect the default minimum amount of facts:
ansible all -m ansible.builtin.setup -a 'gather_subset=!all'
# Only collect IPv4 facts:
ansible all -m ansible.builtin.setup -a "filter=ansible_default_ipv4"
# To get all network interfaces:
ansible all -m ansible.builtin.setup -a 'filter=ansible_interfaces'
# To get specific details about a particular interface:
ansible all -m ansible.builtin.setup -a 'filter=ansible_eth0'
```

## ansible-playbook

[Creating a playbook — Ansible Community Documentation](https://docs.ansible.com/ansible/latest/getting_started/get_started_playbook.html)

```sh
# syntax-check
ansible-playbook playbook.yaml --syntax-check
# run
ansible-playbook playbook.yaml --verbose

# exclude with !
ansible-playbook -vv kubernetes/playbook_containerd.yaml --list-hosts --limit='qj:!qj_2506'

# hosts as variable {{ server_group }}
ansible-playbook disk.yaml -e server_group=192.168.56.70 -e diskname=vdc

# only run plays and tasks whose tags do not match these values. This argument may be specified multiple times.
--skip-tags

```

```yaml
# create a playbook
# append with -a
tee playbook.yaml << EOF
- name: My first play
  hosts: bj
  tasks:
   - name: Ping my hosts
     ansible.builtin.ping:

   - name: Print message
     ansible.builtin.debug:
       msg: Hello world

   - name: Print hostname
     ansible.builtin.command:
       hostname

   - name: Get date
     ansible.builtin.command: date
EOF
```

## Ansible var

```sh
# This example is generally NOT for `src` in copy, but for context.
- name: Example with remote HOME variable
  hosts: all
  vars:
    user: joe
    home: /home/joe
  vars_files:
    - vars/users.yml
  tasks:
    - name: Debug remote user's home directory
      debug:
        msg: "The control node home directory is {{ lookup('env', 'HOME') }}"
        msg: "The remote user's home directory is {{ ansible_env.HOME }}"
```

## ansible role

[4.6 巧用Roles | SRE运维进阶之路](https://clay-wangzhi.com/devops/ansible/roles.html)

```sh
# 查看更多选项帮助
ansible-galaxy init --help

$ ansible-galaxy init first_role
$ tree first_role/
first_role/            \\ 角色名称
├── defaults           \\ 为当前角色设定默认变量时使用此目录，应当包含一个main.yml文件；
│   └── main.yml
├── files              \\ 存放有copy或script等模块调用的文件
├── handlers           \\ 此目录应当包含一个main.yml文件，用于定义各角色用到的各handler
│   └── main.yml
├── meta               \\ 应当包含一个main.yml，用于定义角色的特殊设定及其依赖关系；1.3及以后版本支持
│   └── main.yml
├── README.md
├── tasks              \\ 至少包含一个名为main.yml的文件，定义了此角色的任务列表
│   └── main.yml
├── templates          \\ template模块会自动在此目录中寻找Jinja2模板文件
├── tests
│   ├── inventory
│   └── test.yml
└── vars              \\ 应当包含一个main.yml，用于定义此角色用到的变量
    └── main.yml
```

## Ansible role timesync

```sh
ansible-galaxy role install linux-system-roles.timesync
ansible-galaxy collection install -vv -r meta/collection-requirements.yml

ansible-playbook -vv -i qj-worker04, playbook/time_sync.yaml
```
