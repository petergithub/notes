# Python

## Introduction

### Recent

`python setup.py install` Installing without pip after `cd %path_to_pandapower%\pandapower-x.x.x\`

requests.exceptions.SSLError: HTTPSConnectionPool(host='pypi.org', port=443): Max retries exceeded with url: /pypi/loguru/json (Caused by SSLError("Can't connect to HTTPS URL because the SSL module is not available.",))
`pip install pyopenssl`

文件编码 `# encoding:utf-8`

`sudo python -m pip install package`

`brew switch python 3.6.5_1`  `brew switch python 3.7.0`

`$ brew unlink python`
`$ brew install https://raw.githubusercontent.com/Homebrew/homebrew-core/f2a764ef944b1080be64bd88dca9a1d80130c558/Formula/python.rb`

## Install

### Install Python from source

```bash
yum  install zlib-devel bzip2-devel openssl-devel ncurses-devel libffi-devel -y

# download source file
wget https://www.python.org/ftp/python/3.6.13/Python-3.6.13.tgz
tar xzf Python-3.6.13.tgz

cd Python-3.6.13
./configure --enable-optimizations
# prevent replacing the default python binary file /usr/bin/python
make altinstall
# make && make install

# check version
python3.6 -V
```

### [pip](https://pip.pypa.io/en/stable/user_guide/)

Python 3.6 以后安装 Python 会同时安装 pip
use proxy `pip install -i http://pypi.douban.com/simple  --proxy http://localhost:1087 numpy`
推荐清华大学一个镜像网址站点：`http://e.pypi.python.org`

pip install flask docx -i http://mirrors.aliyun.com/pypi/simple/

[configuration](https://pip.pypa.io/en/stable/user_guide/#configuration)

`vi ~/.config/pip/pip.conf //linux or MacOS`

```sh
[global]
timeout = 6000
index-url = http://mirrors.aliyun.com/pypi/simple/
[install]
trusted-host=mirrors.aliyun.com
```

windows系统下：

在 %userprofile% 用户目录下，新建pip文件夹，然后在该文件夹下新建pip.ini文件。填写如下内容：

```ini
[global]
index-url = http://mirrors.aliyun.com/pypi/simple/
; proxy     = http://XXXX.com:port
[install]
trusted-host=mirrors.aliyun.com
```

[config-file](https://pip.pypa.io/en/stable/user_guide/#config-file)
If multiple configuration files are found by pip then they are combined in the following order:

1. The global file is read
2. The per-user file is read
3. The virtualenv-specific file is read

### [pip Quickstart](https://pip.pypa.io/en/stable/quickstart/)

Install packages within a virtual environment without affecting the host system setup. Start by upgrading pip:
`pip -V` check version
`pip install --upgrade pip`
`pip list  # show packages installed within the virtual environment`

`pip freeze > requirements.txt` generate a requirements.txt file
`pip install -r requirements.txt` # Install from our fancy new file
`pip uninstall somepackage`

[Install packages in a virtual environment using pip and venv - Python Packaging User Guide](https://packaging.python.org/en/latest/guides/installing-using-pip-and-virtual-environments/)

```sh
# Create an environment
$ mkdir myproject
$ cd myproject
$ python3 -m venv .venv

# Activate the environment
$ . venv/bin/activate
```

windows

```powershell
# Create a new virtual environment
py -m venv .venv
# Activate a virtual environment
.venv\Scripts\activate

where python

# Install a package
py -m pip install requests
```

#### pip install

`-e, --editable <path/url>`
Install a project in editable mode (i.e. setuptools “develop mode”) from a local project path or a VCS url.

`pip install -e /path/to/locations/repo` This will overwrite the directory in site-packages with a symbolic link to the locations repository, meaning any changes to code in there will automatically be reflected - just reload the page (so long as you're using the development server).
[What is the use case for `pip install -e`?](https://stackoverflow.com/questions/42609943/what-is-the-use-case-for-pip-install-e)

### Virtual environment

[Pipenv & Virtual Environments](https://docs.python-guide.org/dev/virtualenvs/)

`virtualenv venv ~/workspace/project_folder/venv` Create a virtual environment
`virtualenv -p /usr/bin/python3 venv` use the Python interpreter of your choice

Create a new virtual environment by choosing a Python interpreter and making a ./venv directory to hold it:
`virtualenv --system-site-packages -p python3 ~/venv`
`source ~/venv/bin/activate  # sh, bash, ksh, or zsh` Activate the virtual environment

`python -V` to check version

And to exit virtualenv later:
`deactivate  # don't exit until you're done using python`

### requirement.txt

``` bash
# [Pipenv & Virtual Environments — The Hitchhiker's Guide to Python](https://docs.python-guide.org/dev/virtualenvs/#other-notes)
pip freeze > requirements.txt

# https://github.com/Damnever/pigar
pip install pigar
# Generate requirements.txt for current directory.
$ pigar

# Generating requirements.txt for given directory in given file.
$ pigar -p ../dev-requirements.txt -P ../
```

#### [Version specifiers](https://www.python.org/dev/peps/pep-0440/#version-specifiers)

The comparison operator determines the kind of version clause:
~=: Compatible release clause
==: Version matching clause
!=: Version exclusion clause
<=, >=: Inclusive ordered comparison clause
<, >: Exclusive ordered comparison clause
===: Arbitrary equality clause.
[Compatible release](https://www.python.org/dev/peps/pep-0440/#compatible-release)

example:
-r base.txt # base.txt下面的所有包
pypinyin==0.12.0 # 指定版本（最日常的写法）
django-querycount>=0.5.0 # 大于某个版本
django-debug-toolbar>=1.3.1,<=1.3.3 # 版本范围
ipython # 默认（存在不替换，不存在安装最新版）
SomeProject~=1.4.2  # To install a version that’s compatible with a certain version

#### 第三方工具生成

pip freeze 会附带上一些不需要的包，以及某些包依赖的包~
pipreqs 自动分析项目中引用的包。对Django项目自动构建的时候忽略了Mysql包，版本也很奇怪；而且联网搜索的时候遇到404就报错跳出了?
pigar 功能同上，会显示包被项目文件引用的地方（搜索下就能解决的问题啊= =感觉是伪需求），404的问题也存在
pip-tools 通过第三方文件生成requirements.txt，讲道理为什么不直接写呢，要通过第三方包来做一层转换

#### 推荐用法

一般项目会分为开发环境，测试环境，生产环境等……依赖的包会不同。推荐在文件夹下为每个环境建立一个requirements.txt文件。公有的包存在base.txt供引用

➜ meeting git:(sync) ✗ tree requirements -h
requirements
├── [ 286] base.txt
├── [ 80] local.txt
└── [ 28] production.txt

### permission issue

`Could not install packages due to an EnvironmentError: [Errno 13] Permission denied`
[Permission denied How i solve this problem](https://github.com/googlesamples/assistant-sdk-python/issues/236)

if get permission issue with `pip install gevent==1.1.1`, try `python -m pip install -U "gevent==1.1.1" --user`
You have three options(use only one of them):

1. setup a virtual env to install the package (recommended): `python3 -m venv env && source ./env/bin/activate && python -m pip install package`
2. Install the package to the user folder: `python -m pip install --user package`
3. use sudo to install to the system folder (not recommended)

### [Conda](https://conda.io/projects/conda/en/latest/user-guide/getting-started.html)

[Command reference](https://conda.io/projects/conda/en/latest/commands.html)

`conda init <SHELL_NAME>` `conda init zsh`
`conda --version` Conda displays the number of the version
`conda update conda` update
`conda create --name environmentName` Create a new environment
`conda create python=3.10 --name environmentName` Create a new environment with package
`conda activate environmentName` To use, or "activate" the new environment
`conda info --envs` list of all your environments
`conda activate` Change your current environment back to the default (base)
`conda deactivate` deactive conda
`conda remove --name ENVNAME --all` Delete an entire environment

#### Manage packages

`conda search packageName`
`conda install packageName` install location `~/anaconda3/envs/environmentName/lib/python-VERSION/site-packages`
`conda install python=3.6` package with version
`conda search -c CHANNEL PACKAGE --info` `conda search -c conda-forge pyomo --info`

### Tabs to Space

 对于已保存的文件，可以使用下面的方法进行空格和TAB的替换：
TAB替换为空格：
:set ts=4
:set expandtab
:%retab!

空格替换为TAB：
:set ts=4
:set noexpandtab
:%retab!

加!是用于处理非空白字符之后的TAB，即所有的TAB，若不加!，则只处理行首的TAB。

## [The Python Tutorial](https://docs.python.org/3.5/tutorial/ )

1. When the script name is given as '-' (meaning standard input), sys.argv[0] is set to '-'. When -c command is used, sys.argv[0] is set to '-c'. When -m module is used, sys.argv[0] is set to the full name of the located module. Options found after -c command or -m module are not consumed by the Python interpreter’s option processing but left in sys.argv for the command or module to handle.
2. In interactive mode, the last printed expression is assigned to the variable `_`
3. use raw strings by adding an `r` before the first quote  `>>> print(r'C:\some\name')  # note the r before the quote C:\some\name`
4. String literals can span multiple lines. One way is using triple-quotes: `"""..."""` or `'''...'''`
5. start is always included, and the end always excluded. This makes sure that `s[:i] + s[i:]` is always equal to `s`
6. In Python, like in C, any non-zero integer value is true; zero is false. anything with a non-zero length is true, empty sequences are false.
7. When a compound statement is entered interactively, it must be followed by a blank line to indicate completion. Note that each line within a basic block must be indented by the same amount.
8. The keyword argument end can be used to avoid the newline after the output, or end the output with a different string:

``` python

>>> a, b = 0, 1
>>> while b < 1000:
...     print(b, end=',')
...     a, b = b, a+b
...
1,1,2,3,5,8,13,21,34,55,89,144,233,377,610,987,
```

9. Use 4-space indentation, and no tabs.
10. Name your classes and functions consistently; the convention is to use CamelCase for classes and lower_case_with_underscores for functions and methods. Always use self as the name for the first method argument (see A First Look at Classes for more on classes and methods).
11. `dir()` is used to find out which names a module defines.

### List

`list = ['orange', 'apple', 'pear', 'banana', 'kiwi', 'apple', 'banana']`

### Set

`set = {'apple', 'orange', 'apple', 'pear', 'orange', 'banana'}`

### Dictionary

`tel = {}`
`tel = {'jack': 4098, 'sape': 4139}`
`tel['sam'] = 1234`
`del tel['sape']`

## Performance

### [The Python Profilers](https://docs.python.org/3/library/profile.html)

`python -m cProfile test.py`

### Timer

```python
import time

time0 = time.perf_counter()

//code

print(time.perf_counter() - time0)

```

## Execute

`export PYTHONPATH=. && python /path/to/script.py`

## Web

### Deploy

[python web 部署：nginx + gunicorn + supervisor + flask 部署笔记](https://www.jianshu.com/p/be9dd421fb8d)
[Flask + Docker 无脑部署新手教程](https://zhuanlan.zhihu.com/p/78432719)

### Flask

`gunicron -w4 -b0.0.0.0:8000 myapp:app`

```shell
pkill -f gunicorn
gunicorn --worker-class gevent --timeout 30 --graceful-timeout 20 --max-requests-jitter 2000 --max-requests 1500 -w 6 --log-level DEBUG --access-logfile gunicorn_access.log --error-logfile gunicorn_error.log -D --bind 127.0.0.1:5000 manager:app
echo "gunicorn start!!!"
```
