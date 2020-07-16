# Python

## Introduction

### TODO

IDE: PyCharm
Editor: vim + vim-flake8
Python的集成开发环境(IDE)有很多，其中Spyder和Python Notebook最受欢迎

文件编码 `# encoding:utf-8`

`sudo python -m pip install package`

`brew switch python 3.6.5_1`  `brew switch python 3.7.0`  

`$ brew unlink python`
`$ brew install https://raw.githubusercontent.com/Homebrew/homebrew-core/f2a764ef944b1080be64bd88dca9a1d80130c558/Formula/python.rb`

## Install

### [pip](https://pip.pypa.io/en/stable/user_guide/)

use proxy `pip install -i http://pypi.douban.com/simple  --proxy http://localhost:1087 numpy`
推荐清华大学一个镜像网址站点：`http://e.pypi.python.org`

[configuration](https://pip.pypa.io/en/stable/user_guide/#configuration)

``` shell
vi ~/.config/pip/pip.conf //linux or MacOS
[global]
timeout = 6000
index-url = http://mirrors.aliyun.com/pypi/simple/
[install]
trusted-host=mirrors.aliyun.com
```

### [Conda](https://conda.io/projects/conda/en/latest/user-guide/getting-started.html)

[Command reference](https://conda.io/projects/conda/en/latest/commands.html)

`conda init <SHELL_NAME>` `conda init zsh`
`conda --version` Conda displays the number of the version
`conda update conda` update
`conda create --name environmentName` Create a new environment
`conda create --name environmentName python=3.6` Create a new environment with package
`conda activate environmentName` To use, or "activate" the new environment
`conda info --envs` list of all your environments
`conda activate` Change your current environment back to the default (base)
`conda deactivate` deactive conda

#### Manage packages

`conda search packageName`
`conda install packageName` install location `~/anaconda3/envs/environmentName/lib/python-VERSION/site-packages`
`conda install python=3.6` package with version
`conda search -c CHANNEL PACKAGE --info` `conda search -c conda-forge pyomo --info`

### Virtual environment

#### Basic Usage

[Pipenv & Virtual Environments](https://docs.python-guide.org/dev/virtualenvs/)

`virtualenv venv ~/workspace/project_folder/venv` Create a virtual environment
`virtualenv -p /usr/bin/python3 venv` use the Python interpreter of your choice

Create a new virtual environment by choosing a Python interpreter and making a ./venv directory to hold it:
`virtualenv --system-site-packages -p python3 ~/venv`
`source ~/venv/bin/activate  # sh, bash, ksh, or zsh` Activate the virtual environment

`python -V` to check version

Install packages within a virtual environment without affecting the host system setup. Start by upgrading pip:
`pip -V` check version
`pip install --upgrade pip`
`pip list  # show packages installed within the virtual environment`

`pip freeze > requirements.txt` generate a requirements.txt file
`pip install -r requirements.txt` # Install from our fancy new file

``` shell
# https://github.com/Damnever/pigar
pip install pigar
# Generate requirements.txt for current directory.
$ pigar

# Generating requirements.txt for given directory in given file.
$ pigar -p ../dev-requirements.txt -P ../

```

And to exit virtualenv later:
`deactivate  # don't exit until you're done using python`

### permission issue

`Could not install packages due to an EnvironmentError: [Errno 13] Permission denied`
[Permission denied How i solve this problem](https://github.com/googlesamples/assistant-sdk-python/issues/236)

if get permission issue with `pip install gevent==1.1.1`, try `python -m pip install -U "gevent==1.1.1" --user`
You have three options(use only one of them):

1. setup a virtual env to install the package (recommended): `python3 -m venv env && source ./env/bin/activate && python -m pip install package`

2. Install the package to the user folder: `python -m pip install --user package`

3. use sudo to install to the system folder (not recommended)

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
