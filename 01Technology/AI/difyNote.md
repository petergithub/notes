# Dify Notes

## Dify

[Dify github](https://github.com/langgenius/dify)
[在线版 Studio - Dify](https://cloud.dify.ai/apps)

[Dify 文档](https://docs.dify.ai/zh-hans)

[特性与技术规格 | Dify](https://docs.dify.ai/zh-hans/getting-started/readme/features-and-specifications)

[DifyShare - Share your flows. View the magic.](https://difyshare.com/)
[BannyLon/DifyAIA: 基于Dify自主创建的AI应用DSL工作流](https://github.com/BannyLon/DifyAIA)
[DeepSeek+dify 本地知识库：高级应用Agent+工作流](https://mp.weixin.qq.com/s/1p5KRDflsIISdOvm4QkWYw)
[Dify 架构篇| 多租户下的SSO功能 - 53AI-AI知识库|大模型知识库|大模型训练|智能体开发](https://www.53ai.com/news/dify/2025032992518.html)

Dify is an open-source LLM app development platform. Dify's intuitive interface combines AI workflow, RAG pipeline, agent capabilities, model management, observability features and more, letting you quickly go from prototype to production.

案例：

- 训练出专属于“你”的问答机器人
- 官网 AI 智能客服
- 接入微信
- 接入钉钉

[jaguarliuu/rookie\_text2data: Dify插件 - 自然语言获取数据库数据](https://github.com/jaguarliuu/rookie_text2data)
[Markdown转md文件 Markdown Exporter - Dify Marketplace](https://marketplace.dify.ai/plugins/bowenliang123/md_exporter)

### dify deploy

[Deploy Dify on Kubernetes](https://github.com/Winson-030/dify-kubernetes)

.env 文件修改

```sh
LOG_LEVEL=DEBUG

LOG_TZ=Asia/Shanghai
LOG_FILE=/app/logs/server.log

DEBUG=true
FLASK_DEBUG=true

## customize
# Add environment variables below at the end of .env file, then docker compose down && docker compose up -d
PLUGIN_PYTHON_ENV_INIT_TIMEOUT=720
PIP_MIRROR_URL=https://mirrors.aliyun.com/pypi/simple
```

### Dify 1.0.1 deploy

[Release v1.0.1 · langgenius/dify](https://github.com/langgenius/dify/releases/tag/1.0.1)

PowerShell 下启动

### Dify 1.0.0 deploy

[dify-docs/zh_CN/development/migration/migrate-to-v1.md at main · langgenius/dify-docs](https://github.com/langgenius/dify-docs/blob/main/zh_CN/development/migration/migrate-to-v1.md)

```sh
root@e81a1e9bfdc9:/app/api# poetry run flask install-plugins --workers=2
2025-03-09 06:08:52.421 INFO [MainThread] [utils.py:149] - Note: NumExpr detected 24 cores but "NUMEXPR_MAX_THREADS" not set, so enforcing safe limit of 16.
2025-03-09 06:08:52.422 INFO [MainThread] [utils.py:162] - NumExpr defaulting to 16 threads.
```

### Dify 0.15.3 deploy

[Docker Compose 部署 | Dify](https://docs.dify.ai/zh-hans/getting-started/install-self-hosted/docker-compose)

.env 修改部分

```sh
# .env

# Used to change the OpenAI base address, default is https://api.openai.com/v1.
# When OpenAI cannot be accessed in China, replace it with a domestic mirror address,
# or when a local model provides OpenAI compatible API, it can be replaced.
OPENAI_API_BASE=https://api.openai.com/v1

# Defaults to gevent. If using windows, it can be switched to sync or solo.
SERVER_WORKER_CLASS=gevent

# Upload file size limit, default 15M.
UPLOAD_FILE_SIZE_LIMIT=15
# Upload image file size limit, default 10M.
UPLOAD_IMAGE_FILE_SIZE_LIMIT=10
# Upload video file size limit, default 100M.
UPLOAD_VIDEO_FILE_SIZE_LIMIT=100
# Upload audio file size limit, default 50M.
UPLOAD_AUDIO_FILE_SIZE_LIMIT=50

MAIL_DEFAULT_SEND_FROM=自己的邮箱
# SMTP server configuration, used when MAIL_TYPE is `smtp`
SMTP_SERVER= 对应邮箱的smtp，一般都在设置里
SMTP_PORT=465
SMTP_USERNAME= 自己的邮箱
SMTP_PASSWORD=  自己的密码
SMTP_USE_TLS=true
SMTP_OPPORTUNISTIC_TLS=false
```

Docker Compose 部署

```sh
# 克隆 Dify 源代码至本地环境。
# 假设当前最新版本为 0.15.3
git clone https://github.com/langgenius/dify.git --branch 0.15.3

# 启动 Dify
# 1.  进入 Dify 源代码的 Docker 目录
cd dify/docker
# 2.  复制环境配置文件
cp .env.example .env
# 3.  启动 Docker 容器
docker-compose up -d
```

更新 Dify 进入 dify 源代码的 docker 目录，按顺序执行以下命令：

```sh
cd dify/docker
docker compose down
git pull origin main
docker compose pull
docker compose up -d
```

访问 Dify
你可以先前往管理员初始化页面设置设置管理员账户：

```sh
# 本地环境
http://localhost/install

# 服务器环境
http://your_server_ip/install

# Dify 主页面：
# 本地环境
http://localhost

# 服务器环境
http://your_server_ip
```

### 如何重置dify管理员密码

```sh
docker exec -it docker-api-1 flask reset-password
# 然后按照提示输入管理员email以及两次新密码即可。
```

### dify 钉钉

[将 Dify 应用与钉钉机器人集成 | Dify](https://docs.dify.ai/zh-hans/learn-more/use-cases/dify-on-dingtalk)

### dify database

select name,email,interface_language,last_login_at,last_login_ip,status,created_at,last_active_at from accounts;

### dify issue

```sh
# agent 调用雅虎财经
# prompt 今天有哪些新闻
[ollama] Error: API request failed with status code 400: {"error":"registry.ollama.ai/library/deepseek-r1:7b does not support tools"}
```

## firecrawl

[firecrawl/CONTRIBUTING](https://github.com/mendableai/firecrawl/blob/main/CONTRIBUTING.md)

[localhost:3002](http://localhost:3002/)
[admin/queues](http://localhost:3002/admin/queues)

```sh
docker pull node:18-slim
docker pull node:22-slim
docker pull rust:1-slim
docker pull golang:1.24


curl -X POST http://localhost:3002/v1/crawl \
    -H 'Content-Type: application/json' \
    -d '{
      "url": "https://www.baidu.com"
    }'

curl -X POST https://api.firecrawl.dev/v1/crawl \
    -H 'Content-Type: application/json' \
    -H 'Authorization: Bearer fc-YOUR_API_KEY' \
    -d '{
      "url": "https://docs.firecrawl.dev",
      "limit": 10,
      "scrapeOptions": {
        "formats": ["markdown", "html"]
      }
    }'


```
