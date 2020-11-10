# Go Notes

## Basic

`go env` 打印出go 相关的所有环境变量
`go env GOROOT`
`set GOPROXY=https://goproxy.cn,direct` 国内配置代理

`GOROOT` 在GO语言中表示的是 Go语言编译、工具、标准库等的安装路径
`GOPATH` go项目的存放路径（工作目录），这个目录指定了需要从哪个地方寻找GO的包、可执行程序等，这个目录可以是多个目录表示

`go get github.com/jmoiron/sqlx` 下载包

`go mod init hello` Create a new module for hello package.
`go build`
    `-o` output
编译: 在hello目录下执行 `go build` 或者在其他目录执行 `go build hello`

`go install`
`go run hello.go`

### Go项目结构

在进行Go语言开发的时候，我们的代码总是会保存在$GOPATH/src目录下。在工程经过go build、go install或go get等指令后，会将下载的第三方包源代码文件放在$GOPATH/src目录下， 产生的二进制可执行文件放在 $GOPATH/bin目录下，生成的中间缓存文件会被保存在 $GOPATH/pkg 下。

如果我们使用版本管理工具（Version Control System，VCS。常用如Git）来管理我们的项目代码时，我们只需要添加$GOPATH/src目录的源代码即可。bin 和 pkg 目录的内容无需版本控制。

## VS Code

Use the VSCode-Go plugin, with the following configuration: [VSCode-Go plugin](https://github.com/golang/tools/blob/master/gopls/doc/vscode.md)

### [Go to definition is too slow](https://github.com/microsoft/vscode-go/issues/2511)

[x/tools/gopls: fails on standard library outside of $GOROOT](https://github.com/golang/go/issues/32173)
It seems that you are using modules, but you are **in a directory outside of your $GOPATH without a go.mod file**. gopls will not work correctly with non-standard library imports in such a state. You will need to add a go.mod file to your project.

## Crawlab

启动入口 `backend/main.go.main()`
`main.go -> route -> service -> model`
