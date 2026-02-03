# Claude Code

## Document

- [CC官方文档](https://docs.anthropic.com/en/docs/claude-code)
- [CC最佳实践](https://www.anthropic.com/engineering/claude-code-best-practices)
- [Claude Code in Action](https://anthropic.skilljar.com/claude-code-in-action)
- [CC常用工作流](https://docs.anthropic.com/en/docs/claude-code/common-workflows#understand-new-codebases)
- [awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code)
- [Claude Code 最佳实践](https://mp.weixin.qq.com/s/M3xA7zTBCv8HXVL9XjOBNA)
- [How I Use Claude Code | Philipp Spiess](https://spiess.dev/blog/how-i-use-claude-code)
- [Claude Code通过Anthropic API兼容接口调用通义千问-大模型服务平台百炼-阿里云](https://help.aliyun.com/zh/model-studio/claude-code)

Tips

- [My Claude Code Context Window Strategy (200k Is Not the Problem) : r/ClaudeAI](https://www.reddit.com/r/ClaudeAI/comments/1p05r7p/my_claude_code_context_window_strategy_200k_is/)
- [官方：anthropics/skills](https://github.com/anthropics/skills)
- [江湖：obra/superpowers skills](https://github.com/obra/superpowers/tree/main/skills)
- [everything-claude-code: Complete Claude Code configuration collection - agents, skills, hooks, commands, rules, MCPs. Battle-tested configs from an Anthropic hackathon winner.](https://github.com/affaan-m/everything-claude-code/)

## Common Workflows

cli [CLI reference - Claude Code Docs](https://code.claude.com/docs/en/cli-reference)

```sh
# start with plan mode
# "defaultMode": "default", plan, acceptEdits
claude --permission-mode plan

# Show conversation picker
claude --resume
claude -r
# Continue the most recent conversation
claude --continue
claude -c
claude -p "query"


# Configure Model Context Protocol (MCP) servers
claude mcp
# Update manually, upgrade to latest
claude update

# connect to IDE
/ide

# 两次shift+tab进入计划模式（一次是auto accept edits）

--sandbox # Use sandboxing
--dangerously-skip-permissions # Skip permission prompts (use with caution)
--print, -p # Print response without interactive mode
--add-dir
```

slash command [Slash commands - Claude Code Docs](https://code.claude.com/docs/en/slash-commands)

```sh
/add-dir  # Add additional working directories
/export [filename] # Export the current conversation to a file or clipboard
/context # Visualizes current context usage to see if it's actually filling up.
/hooks # Check if any PreCompact hooks might be interfering:
```

### Features to test

```sh
/feature-dev:feature-dev  Optional feature description

```

### Coding practices

[How I'm using coding agents in September, 2025](https://blog.fsck.com/2025/10/05/how-im-using-coding-agents-in-september-2025/)

refer to [CLAUDE.md](https://github.com/obra/dotfiles/blob/main/.claude/CLAUDE.md)

"architect" session with brainstorming prompt

```sh
I've got an idea I want to talk through with you. I'd like you to help me turn it into a fully formed design and spec (and eventually an implementation plan)
Check out the current state of the project in our working directory to understand where we're starting off, then ask me questions, one at a time, to help refine the idea.
Ideally, the questions would be multiple choice, but open-ended questions are OK, too. Don't forget: only one question per message.
Once you believe you understand what we're doing, stop and describe the design to me, in sections of maybe 200-300 words at a time, asking after each section whether it looks right so far.
```

planning prompt

```sh
I need your help to write out a comprehensive implementation plan.

Assume that the engineer has zero context for our codebase and questionable taste. document everything they need to know. which files to touch for each task, code, testing, docs they might need to check. how to test it.give them the whole plan as bite-sized tasks. DRY. YAGNI. TDD. frequent commits.

Assume they are a skilled developer, but know almost nothing about our toolset or problem domain. assume they don't know good test design very well.

please write out this plan, in full detail, into docs/plans/
```

open another copy of claude as "implementer"

```sh
Please read docs/plans/this-task-plan.md and <whatever we named the design doc>. Let me know if you have questions.
```

Once we've sorted out issues with the plan, I'll tell the "implementer" Claude to

```sh
Please execute the first 3-4 tasks. If you have questions, please stop and ask me. DO NOT DEVIATE FROM THE PLAN.
```

The implementer will chug along. When it's done, I'll flip back to the "architect" session and tell it `The implementer says it's done tasks 1-3. Please check the work carefully.`

When it's done with the next chunk of work, I flip back to the architect. I typically double-ESC to reset the architect to a previous checkpoint and tell it to review up to the now-current checkpoint.

### How the Creator of Claude Code Actually Uses It: 13 Practical Moves

[How the Creator of Claude Code Actually Uses It: 13 Practical Moves | by JP | Jan, 2026 | Dev Genius](https://blog.devgenius.io/how-the-creator-of-claude-code-actually-uses-it-13-practical-moves-2bf02eec032a)

[Boris Cherny on X: "I'm Boris and I created Claude Code. Lots of people have asked how I use Claude Code, so I wanted to show off my setup a bit. My setup might be surprisingly vanilla! Claude Code works great out of the box, so I personally don't customize it much. There is no one correct way to" / X](https://x.com/bcherny/status/2007179832300581177)

1) Run multiple Claudes in parallel with Git worktrees.
2) Mix local and web sessions on purpose
3) Pick a model, then stick with it for coding - the slowest, smartest model
4) Treat CLAUDE.md as living team memory - turns every AI mistake into a permanent lesson
5) Start in Plan mode, then switch to auto‑accept edits mode
6) Turn inner‑loop workflow into slash commands
7) Promote recurring roles into subagents - subagents as automating the most common workflows that I do for most PRs.
8) Use hooks to make the last 10% deterministic
9) Pre‑allow safe tools, don’t default to YOLO
10) Plug Claude into real systems via MCP - connects Claude to tools like Slack, BigQuery, and Sentry using MCP, then shares the config in .mcp.json.This turns Claude from a code editor into a workflow hub.
11) For long‑running work, add a background verification step
12) Give Claude a verification loop (this is the multiplier)
13) Share team skills and conventions intentionally

### Run parallel Claude Code sessions with Git worktrees

```sh
# Create a new worktree with a new branch
git worktree add ../project-feature-a -b feature-a
# Or create a worktree based on branch master
git worktree add ../project-feature-a -b feature-a master
# Or create a worktree with an existing branch
git worktree add ../project-bugfix bugfix-123

# Run Claude Code in each worktree
cd ../project-feature-a
claude

# Run Claude in another worktree
cd ../project-bugfix
claude

# Manage your worktrees
git worktree list
# Remove a worktree when done
git worktree remove ../project-feature-a
```

## Setup

[Quickstart - Claude Code Docs](https://code.claude.com/docs/en/quickstart)

[UfoMiao/zcf: Zero-Config Code Flow for Claude code & Codex](https://github.com/UfoMiao/zcf) 能一键完成 Claude Code 的环境设置

[Claude Code-大模型服务平台百炼(Model Studio)-阿里云帮助中心](https://help.aliyun.com/zh/model-studio/claude-code)

[官方：anthropics/skills](https://github.com/anthropics/skills)

[江湖：obra/superpowers skills](https://github.com/obra/superpowers/tree/main/skills)

[everything-claude-code: Complete Claude Code configuration collection - agents, skills, hooks, commands, rules, MCPs. Battle-tested configs from an Anthropic hackathon winner.](https://github.com/affaan-m/everything-claude-code/)

```sh
# Install globally
npm install -g @anthropic-ai/claude-code
# Revert to specific version (e.g., v1.0.88)
npm install @anthropic-ai/claude-code@1.0.88
# Revert to latest patch in 1.0.x series
npm install @anthropic-ai/claude-code@^1.0.85

# Update manually
claude update

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

# ali
# qwen3-max qwen3-coder-plus
export ANTHROPIC_BASE_URL=https://dashscope.aliyuncs.com/apps/anthropic
export ANTHROPIC_AUTH_TOKEN=sk-xxx

claude --settings $HOME/.claude/settings-xxxxx.json
alias claude_ds='claude --settings $HOME/.claude/settings-deepseek.json'
```

### config

file location

```sh
# config file location
~/.claude/settings.json

# Plans for Claude Code location
~/.claude/plans

# Skills for Claude Code
~/.claude/skills
```

customize config

1. /config Output style 中启用"Explanatory"或"Learning"输出风格，让 Claude 解释改动背后的原因
2. /statusline 定制状态栏，始终显示 context usage 和当前 git branch


Settings precedence: When multiple settings sources exist, they are applied in the following order (highest to lowest precedence):
[Identity and Access Management - Claude Code Docs](https://code.claude.com/docs/en/iam)

1. Managed settings (via Claude.ai admin console)
2. File-based managed settings (managed-settings.json)
3. Command line arguments
4. Local project settings (.claude/settings.local.json)
5. Shared project settings (.claude/settings.json)
6. User settings (~/.claude/settings.json)

使用独立配置文件来管理 Claude Code 使用豆包的设置

[国产大模型接入 Claude Code 教程：以 Doubao-Seed-Code 为例 - 阮一峰的网络日志](https://www.ruanyifeng.com/blog/2025/11/doubao-seed-code.html)

```sh
# 1. 新建一个项目目录claude-model，在里面安装一个单独的 Claude Code
mkdir ~/claude-model
cd ~/claude-model
npm init -y
npm install @anthropic-ai/claude-code

# 新建一个子目录 .claude-doubao，用来存放豆包的配置文件和缓存。
mkdir .claude-doubao

# 2. 新建一个子目录 bin，用来存放可执行脚本。 然后，要把这个 bin 目录放入 PATH 变量，让系统可以找到里面的命令。 改完后，别忘了重启终端。
mkdir ~/claude-model/bin
export PATH="$HOME/claude-model/bin:$PATH"

# 3. 在上一步创建的 bin 目录里面，新建一个名为claude-doubao 的脚本，用来调用豆包模型。
touch ~/claude-model/bin/claude-doubao

# 在这个 claude-doubao 脚本里面，输入下面的内容。

``` ```sh
#!/usr/bin/env bash
# Wrapper for Claude Code CLI using Doubao API

CLAUDE_BIN="$HOME/claude-model/node_modules/.bin/claude"

# Inject API credentials
export ANTHROPIC_AUTH_TOKEN="YOUR_DOUBAO_API_KEY"
export ANTHROPIC_BASE_URL="https://ark.cn-beijing.volces.com/api/compatible"
export ANTHROPIC_MODEL="doubao-seed-code-preview-latest"
export API_TIMEOUT_MS=3000000

# Keep a separate config dir (optional)
export CLAUDE_CONFIG_DIR="$HOME/claude-model/.claude-doubao"

exec "$CLAUDE_BIN" "$@"
``` ```

# 变成可执行
chmod +x ~/claude-model/bin/claude-doubao
# 测一下，Claude Code 是否正常运行
claude-doubao --version
```

settings.json

### hooks

[Another useful hook](https://anthropic.skilljar.com/claude-code-in-action/312427)

a helper hook: write the input to this hook to the post-log.json file, which allows you to inspect exactly what would have been fed into your command! This makes it a lot easier for you to understand what data your command should inspect.

```json
"PostToolUse": [ // Or "PreToolUse" or "Stop", etc
  {
    "matcher": "*",
    "hooks": [
      {
        "type": "command",
        "command": "jq . > post-log.json"
      }
    ]
  },
]
```

stop hooks

```json
// windows stop hooks
{
  "alwaysThinkingEnabled": true,
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "command": "powershell -NoProfile -Command \"[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null; $t=[Windows.UI.Notifications.ToastTemplateType]::ToastText02; $x=[Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent($t); $x.GetElementsByTagName('text')[0].AppendChild($x.CreateTextNode('Claude'))|Out-Null; $x.GetElementsByTagName('text')[1].AppendChild($x.CreateTextNode('Stop'))|Out-Null; $toast=[Windows.UI.Notifications.ToastNotification]::new($x); [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier('Claude code').Show($toast)\"",
            "type": "command"
          },
          {
            "type": "command",
            "command": "powershell.exe -Command \"Import-Module BurntToast; New-BurntToastNotification -Text 'Claude Code', 'DONE'\""
          },
          {
            "command": "powershell -NoProfile -Command \"[console]::Beep(1000,200)\"",
            "type": "command"
          }
        ]
      }
    ]
  }
}

// mac os stop hooks
"hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "command": "osascript -e 'display notification \"DONE\" with title \"Claude Code\"'",
            "type": "command"
          }
        ]
      }
    ]
  }
```

### plugins

[claude-plugins-official/README.md at main · anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official/blob/main/README.md)

superpowers

```sh
# [obra/superpowers: Claude Code superpowers: core skills library](https://github.com/obra/superpowers)

# In Claude Code
/plugin marketplace add obra/superpowers-marketplace
/plugin install superpowers@superpowers-marketplace

# Check that commands appear
/help

# Verify Installation
# Should see:
# /superpowers:brainstorm - Interactive design refinement
# /superpowers:write-plan - Create implementation plan
# /superpowers:execute-plan - Execute plan in batches
```

### skills

[官方：anthropics/skills](https://github.com/anthropics/skills)

[江湖：obra/superpowers skills](https://github.com/obra/superpowers/tree/main/skills)

location:
1. ~/.claude/skills
2. .claude/skills

[Apifox CLI + Claude Skills：将接口自动化测试融入研发工作流](https://mp.weixin.qq.com/s/hTIGlKLqoT9CiHLYXLJASA)

## MCP servers

[Introducing the Model Context Protocol \ Anthropic](https://www.anthropic.com/news/model-context-protocol)
[Connect Claude Code to tools via MCP - Claude Docs](https://docs.claude.com/en/docs/claude-code/mcp#user-scope)
[Specification - Model Context Protocol](https://modelcontextprotocol.io/specification/2025-06-18)

```sh
#  --scope project
#  --scope user
claude mcp add --transport http mcpSeverName http://server.example.com
```

dbhub [dbhub: Universal database MCP server connecting to MySQL, PostgreSQL, SQL Server, MariaDB.](https://github.com/bytebase/dbhub)

```sh
claude mcp add --transport http dbhub http://dbhub.example.com/message
```

context7

CONTEXT7_API_KEY obtained from context7.com/dashboard. [Context7 - Up-to-date documentation for LLMs and AI code editors](https://context7.com/dashboard)

```sh
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

### MCP Architecture overview - tools/call request

[Architecture overview - Model Context Protocol](https://modelcontextprotocol.io/docs/learn/architecture#understanding-the-tool-execution-request)

tools/call request

```json
{
  "jsonrpc": "2.0",
  "id": 3,
  "method": "tools/call",
  "params": {
    "name": "weather_current",
    "arguments": {
      "location": "San Francisco",
      "units": "imperial"
    }
  }
}
```

tools/call response

```json
{
  "jsonrpc": "2.0",
  "id": 3,
  "result": {
    "content": [
      {
        "type": "text",
        "text": "Current weather in San Francisco: 68°F, partly cloudy with light winds from the west at 8 mph. Humidity: 65%"
      }
    ]
  }
}
```

### inspector: Visual testing tool for MCP servers

[inspector: Visual testing tool for MCP servers](https://github.com/modelcontextprotocol/inspector)

```sh
# Basic usage
npx @modelcontextprotocol/inspector --cli node build/index.js

# Connect to a remote MCP server (with Streamable HTTP transport)
npx @modelcontextprotocol/inspector --cli https://my-mcp-server.example.com --transport http --method tools/list

docker run --rm --network host -p 6274:6274 -p 6277:6277 ghcr.io/modelcontextprotocol/inspector:latest
```

### Playwright MCP server

[microsoft/playwright-mcp: Playwright MCP server](https://github.com/microsoft/playwright-mcp)

```sh
claude mcp add playwright npx @playwright/mcp@latest
```

### serena

[oraios/serena: A powerful coding agent toolkit providing semantic retrieval and editing capabilities (MCP server & other integrations)](https://github.com/oraios/serena)

```sh
claude mcp add serena -- uvx --from git+https://github.com/oraios/serena serena start-mcp-server --context claude-code
claude mcp add serena -- uvx --from git+https://github.com/oraios/serena serena start-mcp-server --context claude-code --project "$(pwd)"

# Usage: serena [OPTIONS] COMMAND [ARGS]...

#   Serena CLI commands. You can run `<command> --help` for more info on each command.
# Options:
#   --help  Show this message and exit.

# Commands:
#   config               Manage Serena configuration.
#   context              Manage Serena contexts.
#   mode                 Manage Serena modes.
#   print-system-prompt  Print the system prompt for a project.
#   project              Manage Serena projects.
#   prompts              Commands related to Serena's prompts that are...
#   start-mcp-server     Starts the Serena MCP server.
#   tools                Commands related to Serena's tools.
```

### Chrome DevTools (MCP)

[Chrome DevTools (MCP) for your AI agent  |  Blog  |  Chrome for Developers](https://developer.chrome.com/blog/chrome-devtools-mcp)
[ChromeDevTools/chrome-devtools-mcp: Chrome DevTools for coding agents](https://github.com/ChromeDevTools/chrome-devtools-mcp/?tab=readme-ov-file#chrome-devtools-mcp)

```sh
claude mcp add --scope project chrome-devtools npx chrome-devtools-mcp@latest
```

```json
{
  "mcpServers": {
    "chrome-devtools": {
      "command": "npx",
      "args": ["-y", "chrome-devtools-mcp@latest"]
    }
  }
}
```

```sh
# To check if it works, run the following prompt in your coding agent:
Please check the LCP of web.dev.
Check the performance of https://developers.chrome.com

# prompt
# Diagnose network and console errors
A few images on localhost:8080 are not loading. What is happening?

# Debug live styling and layout issues
The page on localhost:8080 looks strange and off. Check what is happening there.

# Automate performance audits
Localhost:8080 is loading slowly. Make it load faster.

```

## Happy Coder

[slopus/happy: Mobile and Web client for Codex and Claude Code, with realtime voice, encryption and fully featured](https://github.com/slopus/happy)
[Quick Start Guide](https://happy.engineering/docs/quick-start/)

```sh
npm install -g happy-coder

happy
```

## Prompt

### Claude.md

在项目中创建一个CLAUDE.md文件，让Claude详细说明以下内容，通过这种方式，工程师将AI从执行者转变为「老师」。

1. 它刚刚做了什么
2. 为什么这样做
3. 遇到了哪些问题
4. 如何修复

### PPT

```md
你是一个PPT编写专家，你会根据用户的需求做一个漂亮美观的PPT

技术要求：
- 使用reveal.js这个库
- 统一使用league这个theme
- PPT大小为1280*900
- 统一的风格和色调

你需要这么做：
- 根据PPT的内容，思考整个PPT的风格和色调，挑选一个合适的色调
- 思考每一页的内容，然后根据每一页内容思考他的布局
- 逐页生成每一页的内容
- 在所有页面生成完成之后，生成一个首页，和最后一页感谢页

用户的输入：
PPT的内容在ppt.md文件，你需要去加载这个ppt.md文件

你的输出：
一个可以直接打开的html文件
```

```md
你是一个PPT编写专家，你会根据用户的需求做一个漂亮美观的PPT

你需要这么做：
- 思考每一页的内容，然后根据每一页内容思考他的布局
- 逐页生成每一页的内容
- 按模板风格生成每一页

用户的输入：
PPT的内容在ppt.md文件，你需要去加载这个ppt.md文件
PPT模板是 2025年度工作述职报告模板.pptx

你的输出：
一个 PPT 述职文件 2025年度工作述职报告.pptx
```
