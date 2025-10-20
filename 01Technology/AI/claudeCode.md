# Claude Code

## Document

- [CC官方文档](https://docs.anthropic.com/en/docs/claude-code)
- [CC最佳实践](https://www.anthropic.com/engineering/claude-code-best-practices)
- [CC常用工作流](https://docs.anthropic.com/en/docs/claude-code/common-workflows#understand-new-codebases)
- [awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code)
- [Claude Code 最佳实践](https://mp.weixin.qq.com/s/M3xA7zTBCv8HXVL9XjOBNA)
- [How I Use Claude Code | Philipp Spiess](https://spiess.dev/blog/how-i-use-claude-code)

## Common Workflows

```sh
# Show conversation picker
claude --resume
claude -r
# Continue the most recent conversation
claude --continue
claude -c

# Configure Model Context Protocol (MCP) servers
claude mcp

# connect to IDE
/ide
```

## Setup

```sh
claude --settings $HOME/.claude/settings-deepseek.json

alias c='claude --settings $HOME/.claude/settings-deepseek.json'
```

settings-deepseek.json

```json
{
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
    "ANTHROPIC_BASE_URL": "https://api.deepseek.com/anthropic",
    "API_TIMEOUT_MS": "600000",
    "ANTHROPIC_MODEL": "deepseek-chat",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "deepseek-chat",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "deepseek-chat",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "deepseek-reasoner"
  }
}
```

settings.json

```json
{
  "env": {
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1"
  },
  "includeCoAuthoredBy": false
}
```

设置 claude 的环境变量来切换模型

```sh
export ANTHROPIC_BASE_URL=https://api.deepseek.com
export ANTHROPIC_AUTH_TOKEN=sk-xxx

# 设置 Claude API 到 Deepseek官方平台 的别名
alias set_claude_ds='export ANTHROPIC_BASE_URL="https://api.deepseek.com/anthropic"; unset ANTHROPIC_API_KEY; export ANTHROPIC_AUTH_TOKEN="sk-xxx"; export ANTHROPIC_MODEL="deepseek-chat"; export ANTHROPIC_SMALL_FAST_MODEL="deepseek-chat"; echo "Claude API 已设置为 Deepseek官方平台。"'

# 设置 Claude API 到 Kimi 的别名
alias set_claude_kimi='export ANTHROPIC_BASE_URL="https://api.moonshot.cn/anthropic"; export ANTHROPIC_AUTH_TOKEN="<Kimi API Key>"; export ANTHROPIC_MODEL="kimi-k2-0711-preview"; export ANTHROPIC_SMALL_FAST_MODEL="kimi-k2-0711-preview"; unset ANTHROPIC_API_KEY; echo "Claude API 已设置为 Kimi 配置。"'

# 清空 Claude API 变量的别名
alias unset_claude='unset ANTHROPIC_BASE_URL; unset ANTHROPIC_API_KEY; unset ANTHROPIC_MODEL; unset ANTHROPIC_AUTH_TOKEN; unset ANTHROPIC_SMALL_FAST_MODEL; echo "Claude API 变量已清空。"'

# 输出 Claude API配置信息
alias echo_claude_api_info='echo ANTHROPIC_BASE_URL=$ANTHROPIC_BASE_URL; echo ANTHROPIC_AUTH_TOKEN=$ANTHROPIC_AUTH_TOKEN; echo ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY; echo ANTHROPIC_MODEL=$ANTHROPIC_MODEL; echo ANTHROPIC_SMALL_FAST_MODEL=$ANTHROPIC_SMALL_FAST_MODEL'

export ANTHROPIC_BASE_URL=https://dashscope.aliyuncs.com/compatible-mode/v1
export ANTHROPIC_AUTH_TOKEN=sk-33a215a84d1e4b95a69bd0faff381a1f

claude --settings $HOME/.claude/settings-xxxxx.json
alias claude_ds='claude --settings $HOME/.claude/settings-deepseek.json'
```

### MCP servers

context7

```sh
#  --scope project
#  --scope user
claude mcp add --transport http --scope user context7 https://mcp.context7.com/mcp --header "CONTEXT7_API_KEY: $CONTEXT7_API_KEY"
```

```json
"mcpServers": {
  "context7": {
    "type": "http",
    "url": "https://mcp.context7.com/mcp",
    "headers": {
      "CONTEXT7_API_KEY": "api key"
    }
  }
},
```

[Sequential Thinking MCP Server](https://github.com/modelcontextprotocol/servers/tree/main/src/sequentialthinking) 是一个由 MCP 官方提供的服务器实现，旨在通过结构化的、逐步的思考过程，帮助用户或 AI 解决复杂问题。
