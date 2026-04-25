# NodeJS note

[Node.js — Download Node.js®](https://nodejs.org/en/download)

## setup

```sh
# Download and install nvm:
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash

# in lieu of restarting the shell
\. "$HOME/.nvm/nvm.sh"

# Download and install Node.js, installation path: $HOME/.nvm/versions/node
nvm install 22
# nvm install 24

# Verify the Node.js version:
node -v # Should print "v22.22.2".
# Verify npm version:
npm -v # Should print "10.9.7".

# list installed version
nvm ls
# list current version
nvm current
# change to specific version
nvm use v24.14.1
```

installation tips

```sh
=> nvm source string already in $HOME/.zshrc
=> bash_completion source string already in $HOME/.zshrc
=> You currently have modules installed globally with `npm`. These will no
=> longer be linked to the active version of Node when you install a new node
=> with `nvm`; and they may (depending on how you construct your `$PATH`)
=> override the binaries of modules installed with `nvm`:

/data/software/node-v22.14.0-linux-x64/lib
├── @anthropic-ai/claude-code@2.1.81
├── @anthropic-ai/sandbox-runtime@0.0.42
├── apifox-cli@1.5.23
├── corepack@0.31.0
├── happy-coder@0.13.0
├── next@16.2.1
├── opencode-ai@1.3.2
└── pnpm@10.26.0
=> If you wish to uninstall them at a later point (or re-install them under your
=> `nvm` node installs), you can remove them from the system Node as follows:

     $ nvm use system
     $ npm uninstall -g a_module

=> Close and reopen your terminal to start using nvm or run the following to use it now:

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
```

## Configuration

### npm registry mirror 镜像

```sh
npm config set registry https://registry.npmmirror.com

# 安装时指定镜像
npm i -g apifox-cli@latest --registry=https://registry.npmmirror.com/
```

## Nexus Repository Manager

```sh
# 本地login
npm login --registry=http://<nexus-ip>:<port>/repository/npm-hosted/
# 离线上传
npm publish <文件名>.tgz --registry=http://<nexus-ip>:<port>/repository/npm-hosted/
# 随后输入 Nexus 的用户名、密码和邮箱
# 跑通步骤后设置到 Jenkins上环境变量

# --- 配置区 ---
NEXUS_USER="your_username"
NEXUS_PASS="your_password"
# 注意：仓库地址不需要协议头(http://)，用于 .npmrc 中的字段匹配
NEXUS_URL="//nexus.example.com/repository/team-npm-group/"
REGISTRY_FULL_URL="https://nexus.example.com/repository/team-npm-group/"

# 在 CI 脚本中直接运行
echo "${NEXUS_URL}:_auth=$(echo -n ${CI_USER}:${CI_PASS} | openssl base64)" > .npmrc
npm publish

命令行测试： npm view <包名> versions --registry=https://nexus.example.com/repository/team-npm-group/
```
