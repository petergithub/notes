# Python

## Introduction

### TODO

IDE: PyCharm
Editor: vim + vim-flake8
Python的集成开发环境(IDE)有很多，其中Spyder和Python Notebook最受欢迎

if get permission issue with `pip install gevent==1.1.1`, try `python -m pip install -U "gevent==1.1.1" --user`

`brew switch python 3.6.5_1`  `brew switch python 3.7.0`  

`$ brew unlink python`
`$ brew install https://raw.githubusercontent.com/Homebrew/homebrew-core/f2a764ef944b1080be64bd88dca9a1d80130c558/Formula/python.rb`


#### Tabs to Space

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

### [The Python Tutorial](https://docs.python.org/3.5/tutorial/ )

1. When the script name is given as '-' (meaning standard input), sys.argv[0] is set to '-'. When -c command is used, sys.argv[0] is set to '-c'. When -m module is used, sys.argv[0] is set to the full name of the located module. Options found after -c command or -m module are not consumed by the Python interpreter’s option processing but left in sys.argv for the command or module to handle.
2. In interactive mode, the last printed expression is assigned to the variable `_`
3. use raw strings by adding an `r` before the first quote  
		`>>> print(r'C:\some\name')  # note the r before the quote`  
		`C:\some\name`
4. String literals can span multiple lines. One way is using triple-quotes: `"""..."""` or `'''...'''`
5. start is always included, and the end always excluded. This makes sure that `s[:i] + s[i:]` is always equal to `s`
6.  In Python, like in C, any non-zero integer value is true; zero is false. anything with a non-zero length is true, empty sequences are false.
7.  When a compound statement is entered interactively, it must be followed by a blank line to indicate completion. Note that each line within a basic block must be indented by the same amount.
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

#### List
`list = ['orange', 'apple', 'pear', 'banana', 'kiwi', 'apple', 'banana']`

#### Set
`set = {'apple', 'orange', 'apple', 'pear', 'orange', 'banana'}`

#### Dictionary
`dictionary = {'jack': 4098, 'sape': 4139}`
`del tel['sape']`
