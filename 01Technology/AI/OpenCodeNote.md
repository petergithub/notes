# OpenCode Note

[Intro | OpenCode](https://opencode.ai/docs/)

## Quick Start

```sh
/connect # 连接到指定的大模型服务供应商，之后可以使用接入的模型。
/init # 读取项目中的代码和文档，将项目概况生成或更新 AGENTS.md 文件。默认英文，用“/init 请使用中文”可以令其生成中文文档。
/review # review当前项目中的变化，可以通过 [commit|branch|pr] 等参数指定要review的范围。
/timeline # 显示当前会话的时间线，可以回到之前的任何一个状态，或者从指定的状态开始新会话。
/models # 切换可选的大模型。
/new # 创建一个新的会话。当上下文过长时会影响大模型的效果，所以该命令会被经常使用。
/sessions # 显示当前所有会话，并可进行切换。OpenCode支持多会话并行运行，用该命令时可能会看到若干后台对话正在运行中。
/share # 分享当前会话的链接，链接会自动复制到剪贴板以便发送，其他用户可以通过链接查看该会话。/unshare 取消分享。
```

## Setup

```sh
npm i -g opencode-ai

# add plugin
# npx oh-my-opencode install
npm install oh-my-opencode-linux-x64
```
