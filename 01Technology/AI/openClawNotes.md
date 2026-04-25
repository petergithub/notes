# Open Claw Notes

[openclaw/openclaw: Your own personal AI assistant. Any OS. Any Platform. The lobster way. 🦞](https://github.com/openclaw/openclaw?tab=readme-ov-file#readme)
[OpenClaw 中 DeepSeek 配置：实用指南 | 作者：Santosh Viswanatham | 2026 年 2 月 | Medium --- Configuring DeepSeek in OpenClaw: A Practical Guide | by Santosh Viswanatham | Feb, 2026 | Medium](https://isantoshv.medium.com/configuring-deepseek-in-openclaw-a-practical-guide-23982b29ced9)
[老万 - 安全养虾概论](https://mp.weixin.qq.com/s/G5fHBZg0lfppkgrenqdrhA)

[Node.js — Download Node.js®](https://nodejs.org/en/download)

[一键创建OpenClaw机器人·即刻拥有钉钉 AI 助理 - 钉钉开放平台](https://open.dingtalk.com/document/dingstart/build-dingtalk-ai-employees)
[OpenClaw-大模型服务平台百炼(Model Studio)-阿里云帮助中心](https://help.aliyun.com/zh/model-studio/openclaw-coding-plan?spm=5176.454194655176.J_L02u6VphiK2DqbAEtTYRj.3.4620747c4aSWaO#4e8d8e1f41pdo)
[钉钉开发者后台](https://open-dev.dingtalk.com)

http://127.0.0.1:18789/

1. dingtalk-connector
2. deepseek token

```sh
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
nvm install 22
node -v # Should print "v22.22.1".
# Verify npm version:
npm -v # Should print "10.9.4".

npm install -g openclaw@latest

openclaw --version
openclaw onboard --install-daemon

# 1. Onboarding mode → Select Quickstart
# 2. Model/auth provider → Select Custom Provider
# 3. API Base URL → Enter: https://api.deepseek.com
# 5. Endpoint compatibility → Select OpenAI-compatible
# 6. Model ID Enter: deepseek-reasoner
# 7. Endpoint ID → Leave this as the default value
# 8. Model alias → Set this to deepseek (or anything you like)


openclaw dashboard

# Updated ~/.openclaw/openclaw.json
# Workspace OK: ~/.openclaw/workspace
# Sessions OK: ~/.openclaw/agents/main/sessions
# Web search
openclaw configure --section web

# 第一时间装一个保护自己的技能：
# 它的作用是在每次安装其它技能前先审查一番，评估安全风险
npx clawhub install skill-vetter

# You can manage hooks later with
openclaw hooks list
openclaw hooks enable <name>
openclaw hooks disable <name>


# 钉钉插件
openclaw plugins install @dingtalk-real-ai/dingtalk-connector
# 重启网关
openclaw gateway restart

openclaw plugins list  # 确认 dingtalk-connector 已加载
```

allow visit from win/wsl

network interface: enp0s8 192.168.56.108

```json
"gateway": {
    "port": 18789,
    "mode": "local",
    "bind": "loopback",
}
```
