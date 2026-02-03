# AI Model Deploy

## 模型

### deepseek

vllm + ray

deepseek janus pro 多模态大模型炸裂出场，transformer架构，没有走diffusion路线

[deepseek-ai/DeepSeek-R1 · Hugging Face](https://huggingface.co/deepseek-ai/DeepSeek-R1)

[DeepSeek Token 用量计算 | DeepSeek API Docs](https://api-docs.deepseek.com/zh-cn/quick_start/token_usage)

[KTransformers 4090单卡跑671B DeepSeek-R1 - 知乎](https://zhuanlan.zhihu.com/p/23212558318)
[单卡RTX4090部署R1满血版之KTransformers篇-阿朱](https://mp.weixin.qq.com/s/g3JsrLUuMXDX-8lSSzb06A)

[4090单卡部署QWen2.5-VL视觉模型 - 阿朱](https://mp.weixin.qq.com/s/Ha-J5uUKk7XUqMfW_VEqHg)

[不到 4 万元的 DeepSeek-R1-671B-Q8 部署方案 - 腾讯玄武实验室](https://mp.weixin.qq.com/s/vIrvbVJ6Nv00Ehre1zZwMw)

[Deepseek V3 0324 modelfile : r/ollama](https://www.reddit.com/r/ollama/comments/1jpk3ty/deepseek_v3_0324_modelfile)

#### quantized DeepSeek-R1

[Deployment-ready reasoning with quantized DeepSeek-R1 models | Red Hat Developer](https://developers.redhat.com/articles/2025/03/03/deployment-ready-reasoning-quantized-deepseek-r1-models#)

INT4 models recover 97%+ accuracy for 7B and larger models, with the 1.5B model maintaining ~94%.

#### 内存使用量计算

[DeepSeek 本地化部署指南：硬件适配全解析-DeepSeek技术社区](https://deepseek.csdn.net/67c14dbab8d50678a2421282.html)

内存使用计算

fp16: (16/8)*70B = 140GB
fp16: (16/8)*671B = 1342 GB
int8: (8/8)*671B = 671 GB
int4: (4/8)*671B = 335.5 GB
int1: (1/8)*671B = 83.875 GB

对于 DeepSeek-R1-32B 模型，若以常规的 fp16 精度计算，每个参数占用 2 字节（16/8），基础参数占用为 320 亿 × 2 字节 = 640 亿字节，约 64GB。乘以安全系数 1.3 后，基础参数占用提升至 83.2GB。在实际运行中，每处理一定数量的上下文 token，会产生额外的上下文开销。假设处理 4096 tokens 的上下文会增加 2GB 的上下文开销（具体数值会因模型和运行环境略有差异），当处理 8192 个上下文 token 时，上下文扩展量为 2GB × 2 = 4GB。若再考虑系统缓存可能占用 3GB（实际会因系统配置不同而变化），则 总显存需求 = 83.2GB + 4GB + 3GB = 90.2GB。这表明在部署 DeepSeek-R1-32B 模型时，单卡显存若低于 90.2GB，可能无法稳定运行

1. 每个参数占用 2 字节，基础参数占用为 320 亿 × 2 字节 = 640 亿字节，约 64GB
2. 乘以安全系数 1.3 * 64GB = 83.2GB
3. 处理 8192 个上下文 token 时，上下文扩展量为 2GB × 2 = 4GB
4. 总显存需求 = 83.2GB + 4GB + 3GB = 90.2GB

[Run DeepSeek-R1 Dynamic 1.58-bit](https://unsloth.ai/blog/deepseekr1-dynamic)
DeepSeek R1 has 61 layers

n (offload) = VRAM(GB) / Filesize(GB) × n (layers) − 4

#### The Temperature Parameter

[The Temperature Parameter | DeepSeek API Docs](https://api-docs.deepseek.com/quick_start/parameter_settings)

The default value of temperature is 1.0. We recommend users to set the temperature according to their use case listed in below.

Coding / Math                     0.0
Data Cleaning / Data Analysis     1.0
General Conversation              1.3
Translation                       1.3
Creative Writing / Poetry         1.5

#### 模型能力对比

| 对比项 | GPT (OpenAI) | DeepSeek-R1 |
| --- | --- | --- |
| 模型架构 | Transformer解码器架构 (全参数激活) | 混合专家模型 (MoE，部分参数激活) |
| 参数规模 | GPT-4：1.76万亿参数（全参数计算）01未 公开 | 总参数6,710亿，每次仅激活370亿 |
| 训练方法 | D 监督微调（SFT）+强化学习(RLHF) | 纯强化学习(RL)，不依赖 SFT |
| 推理能力 | 强大的自然语言理解和推理能力 | 优秀的推理能力，具备自我验证和反思 |
| 计算资源 | 需要高计算成本和能耗 | MoE 机制降低计算消耗 |
| 并行训练 | 基于标准的分布式训练框架 | 采用 HAI-LLM 并行框架(16路流水线并行、64路专家并行) |
| 开源情况 | GPT为闭源 | DeepSeek-R1为开源 |
| 适用场景 | 通用对话、代码生成、复杂推理 | 适用于高效推理任务，低成本大规模部署 |


## ollama

[ollama/ollama: Get up and running with large language models.](https://github.com/ollama/ollama)
[ollama/ollama - Docker Image | Docker Hub](https://hub.docker.com/r/ollama/ollama)
[ollama Importing a model](https://github.com/ollama/ollama/blob/main/docs/import.md)
[ollama api](https://github.com/ollama/ollama/blob/main/docs/api.md)

```sh
# 设置好环境变量后，运行 ollama run 命令即可让 Ollama 使用指定的 GPU
export CUDA_VISIBLE_DEVICES=0,1
# Docker 使用所有gpu --gpus=all
# Docker 只使用第 0 和第 1 张 GPU 卡 --gpus=0,1
docker run -d --env OLLAMA_HOST=0.0.0.0:11434 -v /data/docker/ollama/ollama:/root/.ollama -p 11434:11434 --name ollama ollama/ollama
alias ollama='docker exec -it ollama ollama'

# Show model information
ollama show llama3.2
# List models on your computer
ollama list
# List which models are currently loaded
ollama ps
# Start Ollama
ollama serve

# Run a model
ollama run modelName
# Show more info: duration and eval rate
ollama run modelName --verbose
# Stop a running model
ollama stop modelName
# Remove a model
ollama rm modelName

#
# Run with parameter: num_ctx Context Window
ollama run llama3 –set parameter num_ctx 4096 --temperature 0.7 --top-p 0.9 --memory-limit 8GB --batch-size 8
# 检查系统资源
ollama run llama2 --debug
# 使用性能分析工具
ollama run llama2 --profile

# 使用curl测试API
curl -X POST http://localhost:11434/api/generate -d '{
  "model": "llama2",
  "prompt": "Hello, how are you?"
}'

curl http://localhost:11434/api/tags

# 批处理
ollama run llama2 < batch_prompts.txt > responses.txt

# [ollama Model library](https://ollama.com/library)

# deepseek
# deepseek 1.5b ~ 32b 上下文长度 32,768  最大输入 32,768
# [DeepSeek R1和DeepSeek V3 API_大模型服务平台百炼(Model Studio)-阿里云帮助中心](https://help.aliyun.com/zh/model-studio/developer-reference/deepseek#94082c580cot9)
# [deepseek-r1:1.5b](https://ollama.com/library/deepseek-r1:1.5b)
# DeepSeek-R1-Distill-Qwen-1.5B
ollama run deepseek-r1:1.5b
# DeepSeek-R1-Distill-Qwen-7B
ollama run deepseek-r1:7b
# DeepSeek-R1-Distill-Qwen-32B
ollama run deepseek-r1:32b

# DeepSeek-R1-Distill-Llama-70B
# Error: model requires more system memory (37.3 GiB) than is available (24.7 GiB)
ollama run deepseek-r1:70b

# 34b 执行太慢
ollama run codellama:34b

# 70b Error: model requires more system memory (31.2 GiB) than is available (27.3 GiB)
ollama run codellama:70b

# Cline uses complex prompts and iterative task execution that may be challenging for less capable models. For best results, it's recommended to use Claude 3.5 Sonnet for its advanced agentic coding capabilities.
ollama run qwen2.5:32b

# [DeepSeek Coder](https://deepseekcoder.github.io/)
# [DeepSeek-Coder/Evaluation/HumanEval - deepseek-ai/DeepSeek-Coder](https://github.com/deepseek-ai/DeepSeek-Coder/tree/main/Evaluation/HumanEval)
#
# DeepSeek-Coder-V2 comes in two primary types: Instruct and Base.
# Base model
# A base model is a general-purpose language model trained on a large corpus of text (e.g., code, documentation, and natural language). It has no specific fine-tuning for instruction-following or task-oriented behaviour.
#
# Instruct model
# An instruct model is a fine-tuned version of a base model, optimized to follow instructions and perform specific tasks. It is trained on datasets containing instruction-response pairs (e.g., “Write a SQL query to find duplicates” → “SELECT …”). Excels at task-oriented interactions (e.g., debugging, refactoring, answering questions).

# [second-state-DeepSeek-Coder-V2-Lite-Instruct-GGUF: Mirror of https://huggingface.co/second-state/DeepSeek-Coder-V2-Lite-Instruct-GGUF](https://gitee.com/hf-models/second-state-DeepSeek-Coder-V2-Lite-Instruct-GGUF)
# DeepSeek-Coder-V2-Lite-Instruct-Q4_K_M.gguf  Quant method: Q4_K_M
# medium, balanced quality - recommended
# DeepSeek-Coder-V2-Instruct 236B
# DeepSeek-Coder-V2-Lite-Instruct 16B
ollama run deepseek-coder-v2:16b-lite-instruct-q4_K_M

# [MFDoom/deepseek-r1-tool-calling:8b](https://ollama.com/MFDoom/deepseek-r1-tool-calling:8b)
# DeepSeek's first-generation of reasoning models with comparable performance to OpenAI-o1, including six dense models distilled from DeepSeek-R1 based on Llama and Qwen. With Tool Calling support.
ollama run MFDoom/deepseek-r1-tool-calling:8b
```

### ollama 命令

[ollama的命令注解_ollama命令行-CSDN博客](https://blog.csdn.net/sunyuhua_keyboard/article/details/141174683)

```sh
>>> /?
Available Commands:
  /set            Set session variables
  /show           Show model information
  /load <model>   Load a session or model
  /save <model>   Save your current session
  /clear          Clear session context
  /bye            Exit
  /?, /help       Help for a command
  /? shortcuts    Help for keyboard shortcuts

Use """ to begin a multi-line message.

>>> /set
Available Commands:
  /set parameter ...     Set a parameter
  /set system <string>   Set system message
  /set template <string> Set prompt template
  /set history           Enable history
  /set nohistory         Disable history
  /set wordwrap          Enable wordwrap
  /set nowordwrap        Disable wordwrap
  /set format json       Enable JSON mode
  /set noformat          Disable formatting
  /set verbose           Show LLM stats
  /set quiet             Disable LLM stats
```

主命令
/set: 用于设置会话参数和配置。例如，设置消息格式、启用或禁用历史记录等。
/show: 显示模型的相关信息，如当前加载的模型的名称、版本等。
/load : 加载一个特定的模型或会话。你可以指定一个模型的名称或路径来加载它。
/save : 保存当前的会话状态或模型。你可以将当前会话或模型的配置保存为一个文件，以便以后使用。
/clear: 清除会话上下文。这将删除当前会话中的所有历史记录或对话内容。
/bye: 退出会话。这个命令将结束当前与模型的对话，并退出程序。
/? 或 /help: 显示帮助信息。如果你需要关于某个命令的详细信息，可以使用这些命令。
/? shortcuts: 显示键盘快捷键的帮助信息。这可以帮助你更快速地进行操作。

/set 子命令
/set parameter …: 设置某个参数。这可能包括一些特定的配置项，用于控制模型的行为或输出方式。
/set system : 设置系统消息。你可以提供一个字符串作为系统消息，这通常用于在对话开始时向模型传达背景信息或特定指令。
/set template : 设置提示模板。这允许你定义一个模板，用于格式化你与模型的对话。
/set history: 启用历史记录。这意味着模型会保存你当前会话中的对话历史，以便稍后参考或使用。
/set nohistory: 禁用历史记录。使用这个命令后，模型将不会保存会话历史。
/set wordwrap: 启用自动换行。这在长文本消息的情况下非常有用，可以让文本自动换行以便于阅读。
/set nowordwrap: 禁用自动换行。如果不需要自动换行，可以使用这个命令。
/set format json: 启用JSON模式格式化输出。这会将模型的响应格式化为JSON格式，方便结构化数据的处理。
/set noformat: 禁用格式化输出。如果不需要任何特定格式的输出，可以使用这个命令。
/set verbose: 启用详细模式，这会显示与LLM相关的统计信息，如响应时间、消耗资源等。
/set quiet: 禁用详细模式。启用后，将不会显示与LLM相关的统计信息，输出会更简洁。

应用场景

- 管理会话: 你可以使用 /load 和 /save 命令来保存和加载特定的会话状态，从而在不同时间点继续先前的工作。
- 自定义消息格式: 使用 /set template 和 /set format json 可以自定义和控制模型输出的格式，适用于不同的应用场景。
- 调试和性能监控: 通过 /set verbose 和 /set quiet，你可以控制是否查看模型的统计信息，这在调试或性能监控时特别有用。

这些命令和设置可以帮助你更灵活地控制模型的行为和会话的管理，使其更好地适应你的使用需求。

### Where are models stored?

macOS: ~/.ollama/models
Linux: /usr/share/ollama/.ollama/models
Windows: %userprofile%\.ollama\models

默认的模型保存路径位于C盘，（%userprofile%\.ollama\models），可以通过设置 OLLAMA_MODELS 进行修改，然后重启终端，重启ollama服务（需要去状态栏里关掉程序）

```bat
setx OLLAMA_MODELS "D:\ollama_model"
OLLAMA_MODELS=D:\workspace\ollama\models
```

### ollama Setting environment variables on Windows

[ollama/docs/faq](https://github.com/ollama/ollama/blob/main/docs/faq.md#setting-environment-variables-on-windows)

On Windows, Ollama inherits your user and system environment variables.

1. First Quit Ollama by clicking on it in the task bar.
2. Start the Settings (Windows 11) or Control Panel (Windows 10) application and search for environment variables.
3. Click on Edit environment variables for your account.
4. Edit or create a new variable for your user account for OLLAMA_HOST, OLLAMA_MODELS, etc.
   1. OLLAMA_HOST=0.0.0.0:11434
5. Click OK/Apply to save.
6. Start the Ollama application from the Windows Start menu.

### keep a model loaded in memory or make it unload immediately?

The `keep_alive` parameter can be set to:

- a duration string (such as "10m" or "24h")
- a number in seconds (such as 3600)
- any negative number which will keep the model loaded in memory (e.g. -1 or "-1m")
- '0' which will unload the model immediately after generating a response

```sh
# to preload a model and leave it in memory use:
curl http://localhost:11434/api/generate -d '{"model": "deepseek-r1:7b", "keep_alive": -1}'

# To unload the model and free up memory use:
curl http://localhost:11434/api/generate -d '{"model": "MFDoom/deepseek-r1-tool-calling:8b", "keep_alive": 0}'
```

### config Ollama

#### context window size

[How to Increase Ollama Context Size: A Complete Step-by-Step Guide - Deep AI — Leading Generative AI-powered Solutions for Business](https://deepai.tn/glossary/ollama/how-increase-ollama-context-size/)
[GGUF specification](https://github.com/ggml-org/ggml/blob/master/docs/gguf.md)
huggingface 上或模型的 config 文件中记录的大小：sequence_len: 4096

By default, Ollama uses a context window size of 2048 tokens.

show the context size *really is* in the current model being run `ollama show (model name)`. In the ollama CLI, `/show info`

```sh
ollama show deepseek-r1:7b
# Model
#   architecture        qwen2
#   parameters          7.6B
#   context length      131072
#   embedding length    3584
#   quantization        Q4_K_M

# Parameters
#   stop    "<｜begin▁of▁sentence｜>"
#   stop    "<｜end▁of▁sentence｜>"
#   stop    "<｜User｜>"
#   stop    "<｜Assistant｜>"

# When using the API, specify the num_ctx parameter:
curl http://localhost:11434/api/generate -d '{
  "model": "llama3.2",
  "prompt": "Why is the sky blue?",
  "options": {
    "num_ctx": 4096
  }
}'

/set parameter num_ctx 131072
/save deepseek-r1:7b-ctx-128k

/set parameter num_ctx 65536
/save deepseek-r1:7b-ctx-64k
/set parameter num_ctx 32768
/save deepseek-r1:7b-ctx-32k
/set parameter num_ctx 16384
/save deepseek-r1:7b-ctx-16k
/set parameter num_ctx 8192
/save deepseek-r1:7b-ctx-8k
/set parameter num_ctx 6144
/save deepseek-r1:7b-ctx-6k
/set parameter num_ctx 4096
/save deepseek-r1:7b-ctx-4k
/set parameter num_ctx 3072
/save deepseek-r1:7b-ctx-3k
/set parameter num_ctx 2048
/save deepseek-r1:7b-ctx-2k


ollama ps
# NAME              ID              SIZE      PROCESSOR    UNTIL
# deepseek-r1:7b-ctx-128k    946b57ccb619    12 GB    100% CPU     4 minutes from now
# deepseek-r1:7b-ctx-64k    af0516d55326    13 GB    58%/42% CPU/GPU    4 minutes from now
# deepseek-r1:7b-ctx-64k    af0516d55326    8.4 GB    100% CPU     4 minutes from now  2025年3月3日
# deepseek-r1:7b-ctx-32k    1b1debea5066    9.5 GB    39%/61% CPU/GPU    4 minutes from now
# deepseek-r1:7b-ctx-16k    3fc83f5dea49    7.2 GB    19%/81% CPU/GPU    4 minutes from now
# deepseek-r1:7b-ctx-8k    fdb679a1bd50    6.3 GB    7%/93% CPU/GPU    4 minutes from now
# deepseek-r1:7b-ctx-6k    edd7d65f4ea1    6.1 GB    7%/93% CPU/GPU    4 minutes from now
# deepseek-r1:7b-ctx-4k    96cae7f73d2b    6.0 GB    7%/93% CPU/GPU    4 minutes from now
# deepseek-r1:7b-ctx-3k    25f4b7c66be3    5.5 GB    100% GPU     4 minutes from now
# deepseek-r1:7b-ctx-2k    9be990020b49    5.4 GB    100% GPU     4 minutes from now
# deepseek-r1:7b    0a8c26691023    5.4 GB    100% GPU     4 minutes from now
```

### cline with local deepseek

本地允许 deepseek 32b 模型，cline 调用时报错
[Cline is having trouble... · Issue #1094 · cline/cline](https://github.com/cline/cline/issues/1094)

```log
Cline uses complex prompts and iterative task execution that may be challenging for less capable models. For best results, it's recommended to use Claude 3.5 Sonnet for its advanced agentic coding capabilities.

```

## vLLM

A tool designed to run LLMs very efficiently, especially when serving many users at once.
[Ollama vs VLLM: Which Tool Handles AI Models Better? | by Naman Tripathi | Medium](https://medium.com/@naman1011/ollama-vs-vllm-which-tool-handles-ai-models-better-a93345b911e6)

[Welcome to vLLM — vLLM](https://docs.vllm.ai/en/stable/)
[aneeshjoy/vllm-windows: Docker compose to run vLLM on Windows](https://github.com/aneeshjoy/vllm-windows)
[vllm/vllm-openai Tags | Docker Hub](https://hub.docker.com/r/vllm/vllm-openai/tags)

[AutoAWQ — vLLM](https://docs.vllm.ai/en/latest/features/quantization/auto_awq.html) To create a new 4-bit quantized model, you can leverage AutoAWQ. Quantization reduces the model’s precision from BF16/FP16 to INT4 which effectively reduces the total model memory footprint. The main benefits are lower latency and memory usage.

To determine whether a given model is supported, you can check the config.json file inside the HF repository. If the "architectures" field contains a model architecture listed below, then it should be supported in theory. [Supported Models — vLLM](https://docs.vllm.ai/en/v0.6.5/models/supported_models.html)

### vllm api

```sh
# Test by accessing the /models endpoints
curl http://127.0.0.1:8003/v1/models
```

llm chat completion
[API Reference - OpenAI API](https://platform.openai.com/docs/api-reference/chat/create)

```sh
curl -X POST http://127.0.0.1:9997/v1/chat/completions \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
    "model": "qwen2.5-instruct",
    "messages": [
        {
            "role": "system",
            "content": "You are a helpful assistant."
        },
        {
            "role": "user",
            "content": "What is the largest animal?"
        }
    ]
  }'
```

embeddings [API Reference - OpenAI API](https://platform.openai.com/docs/api-reference/embeddings)

```sh
curl -X 'POST' 'http://localhost:9997/v1/embeddings' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
    "model": "bge-m3",
    "input": "Hello, world!"
  }'
```

rank

```sh
curl http://localhost:9997/v1/rerank \
  -H "Content-Type: application/json" \
  -d '{
  "model": "bge-reranker-v2-m3",
  "query": "Organic skincare products for sensitive skin",
  "documents": [
    "Eco-friendly kitchenware for modern homes",
    "Biodegradable cleaning supplies for eco-conscious consumers",
    "Organic cotton baby clothes for sensitive skin",
    "Natural organic skincare range for sensitive skin",
    "Tech gadgets for smart homes: 2024 edition",
    "Sustainable gardening tools and compost solutions",
    "Sensitive skin-friendly facial cleansers and toners",
    "Organic food wraps and storage solutions",
    "All-natural pet food for dogs with allergies",
    "Yoga mats made from recycled materials"
  ],
  "top_n": 3
}'

INFO 04-10 11:11:21 [api_server.py:1081] Starting vLLM API server on http://0.0.0.0:8000
INFO 04-10 11:11:21 [launcher.py:26] Available routes are:
INFO 04-10 11:11:21 [launcher.py:34] Route: /openapi.json, Methods: GET, HEAD
INFO 04-10 11:11:21 [launcher.py:34] Route: /docs, Methods: GET, HEAD
INFO 04-10 11:11:21 [launcher.py:34] Route: /docs/oauth2-redirect, Methods: GET, HEAD
INFO 04-10 11:11:21 [launcher.py:34] Route: /redoc, Methods: GET, HEAD
INFO 04-10 11:11:21 [launcher.py:34] Route: /health, Methods: GET
INFO 04-10 11:11:21 [launcher.py:34] Route: /load, Methods: GET
INFO 04-10 11:11:21 [launcher.py:34] Route: /ping, Methods: POST, GET
INFO 04-10 11:11:21 [launcher.py:34] Route: /tokenize, Methods: POST
INFO 04-10 11:11:21 [launcher.py:34] Route: /detokenize, Methods: POST
INFO 04-10 11:11:21 [launcher.py:34] Route: /v1/models, Methods: GET
INFO 04-10 11:11:21 [launcher.py:34] Route: /version, Methods: GET
INFO 04-10 11:11:21 [launcher.py:34] Route: /v1/chat/completions, Methods: POST
INFO 04-10 11:11:21 [launcher.py:34] Route: /v1/completions, Methods: POST
INFO 04-10 11:11:21 [launcher.py:34] Route: /v1/embeddings, Methods: POST
INFO 04-10 11:11:21 [launcher.py:34] Route: /pooling, Methods: POST
INFO 04-10 11:11:21 [launcher.py:34] Route: /score, Methods: POST
INFO 04-10 11:11:21 [launcher.py:34] Route: /v1/score, Methods: POST
INFO 04-10 11:11:21 [launcher.py:34] Route: /v1/audio/transcriptions, Methods: POST
INFO 04-10 11:11:21 [launcher.py:34] Route: /rerank, Methods: POST
INFO 04-10 11:11:21 [launcher.py:34] Route: /v1/rerank, Methods: POST
INFO 04-10 11:11:21 [launcher.py:34] Route: /v2/rerank, Methods: POST
INFO 04-10 11:11:21 [launcher.py:34] Route: /invocations, Methods: POST
INFO 04-10 11:11:21 [launcher.py:34] Route: /metrics, Methods: GET
```

### vllm run model

```sh
docker pull vllm/vllm-openai:v0.8.3

# 指定程序只能使用编号为 0 和 1 的 GPU。这对于多 GPU 系统非常有用，可以控制程序使用哪些 GPU。
export CUDA_VISIBLE_DEVICES=0,1

# Name or path of the huggingface model to use. Default: “facebook/opt-125m”
--model

# deepseek_r1 think enable
--enable-reasoning --reasoning-parser deepseek_r1

--served-model-name SERVED_MODEL_NAME [SERVED_MODEL_NAME ...]
# The model name(s) used in the API. If multiple names are provided, the server will respond to any of the provided names. The model name in the model field of a response will be the first name in this list. If not specified, the model name will be the same as the --model argument. Noted that this name(s) will also be used in model_name tag content of prometheus metrics, if multiple names provided, metrics tag will take the first one.

--gpu-memory-utilization <value>
# gpu-memory-utilization 是用于设置 GPU 内存利用率的参数，<value> 是一个介于 0 到 1 之间的浮点数，表示 GPU 内存的使用比例
```

```sh
# By default, vLLM downloads models from HuggingFace. If you would like to use models from ModelScope, set the environment variable VLLM_USE_MODELSCOPE before initializing the engine.
# [DeepSeek-R1 · modelscope](https://modelscope.cn/models/deepseek-ai/DeepSeek-R1)
# [DeepSeek-R1-Distill-Qwen-1.5B](https://modelscope.cn/models/deepseek-ai/DeepSeek-R1-Distill-Qwen-1.5B)
# default max-model-len: max_seq_len=32768
    # --env "HUGGING_FACE_HUB_TOKEN=hf_oo" \
    # --model mistralai/Mistral-7B-v0.1
docker run --runtime nvidia --gpus all \
    --detach \
    --env TZ=Asia/Shanghai \
    --name vllm \
    --restart always \
    --env VLLM_USE_MODELSCOPE=True \
    --volume //d/workspace/vllm/.cache/:/root/.cache/ \
    --volume //d/workspace/models/:/models/ \
    --publish 8000:8000 \
    --ipc=host \
    vllm/vllm-openai:v0.7.2 \
    --model /models/DeepSeek-R1-Distill-Qwen-32B \
    --served-model-name deepseek-r1:1.5b \
    --max-model-len 15520 \
    --gpu-memory-utilization 0.9

# Deploy with docker on Linux:
docker run --runtime nvidia --gpus all \
    --name my_vllm_container \
    -v ~/.cache/huggingface:/root/.cache/huggingface \
     --env "HUGGING_FACE_HUB_TOKEN=<secret>" \
    -p 8000:8000 \
    --ipc=host \
    vllm/vllm-openai:latest \
    --model deepseek-ai/DeepSeek-R1

# Load and run the model:
vllm serve "deepseek-ai/DeepSeek-R1-Distill-Qwen-1.5B"
# Load and run the model:
docker exec -it my_vllm_container bash -c "vllm serve deepseek-ai/DeepSeek-R1-Distill-Qwen-1.5B"

# Test by accessing the /models endpoints
http://127.0.0.1:8000/v1/models

# Check throughput ( I am running on a RTX 3090 )
http://127.0.0.1:8000/metrics

# Call the server using curl:
curl -X POST "http://localhost:8000/v1/chat/completions" \
    -H "Content-Type: application/json" \
    --data '{
        "model": "deepseek-r1:1.5b",
        "messages": [
            {
                "role": "user",
                "content": "What is the capital of France?"
            }
        ]
    }'

# OpenAI Completions API with vLLM
curl http://localhost:8000/v1/completions \
    -H "Content-Type: application/json" \
    -d '{
        "model": "Qwen/Qwen2.5-1.5B-Instruct",
        "prompt": "San Francisco is a",
        "max_tokens": 7,
        "temperature": 0
    }'

# OpenAI Chat Completions API with vLLM
curl http://localhost:8000/v1/chat/completions \
    -H "Content-Type: application/json" \
    -d '{
        "model": "Qwen/Qwen2.5-1.5B-Instruct",
        "messages": [
            {"role": "system", "content": "You are a helpful assistant."},
            {"role": "user", "content": "Who won the world series in 2020?"}
        ]
    }'
```

### vllm 参数

[引擎参数 — vLLM 文档](https://docs.vllm.com.cn/en/latest/serving/engine_args.html)

```sh
# 要使用的 huggingface 模型的名称或路径。 默认值：“facebook/opt-125m”
--model

--api-key API_KEY

# 可选值：auto, generate, embedding, embed, classify, score, reward, transcription
# 模型要使用的任务。即使同一个模型可以用于多个任务，每个 vLLM 实例也只支持一个任务。当模型只支持一个任务时，可以使用 "auto" 来选择它；否则，您必须明确指定要使用的任务。
# 默认值：“auto”
--task

# 限制 PyTorch 可见的 GPU 设备
CUDA_VISIBLE_DEVICES=0,1,2,3,4,5,6,7
# 将张量并行化到 8 个 GPU 上。这个设置和你的 CUDA_VISIBLE_DEVICES 参数相符，要确认模型可以支持 8-way 的张量并行
--tensor-parallel-size 8

# 用于模型执行器的 GPU 内存 fraction，范围可以从 0 到 1。例如，值为 0.5 意味着 50% 的 GPU 内存利用率。如果未指定，将使用默认值 0.9。这是一个每个实例的限制，并且仅适用于当前的 vLLM 实例。如果您在同一 GPU 上运行另一个 vLLM 实例，则无关紧要。例如，如果您在同一 GPU 上运行两个 vLLM 实例，您可以将每个实例的 GPU 内存利用率设置为 0.5。
# 默认值：0.9
# 设置每个 GPU 最大的显存使用比例为 90%。如果 GPU 上的显存容量较大（例如 24GB 或 40GB），通常设置为 0.9 是安全的，但如果显存较小，或者你有多个进程在同时使用 GPU，可能会导致 Out of Memory 错误
# 确保每个 GPU 上的显存足够，并且没有其他进程占用显存。如果遇到内存溢出，可以尝试调整该值，或者逐步减少每个 GPU 的显存使用。
--gpu-memory-utilization 0.9

# 在显存不足时会使用 CPU 扩展内存，设置每 GPU 的 CPU offloading 空间（GiB）。根据可用系统内存设置，例如 45GB。
# 要卸载到 CPU 的空间（GiB），每个 GPU。默认为 0，表示不卸载。直观地看，此参数可以被视为增加 GPU 内存大小的虚拟方式。例如，如果您有一个 24 GB 的 GPU 并将其设置为 10，实际上您可以将其视为 34 GB 的 GPU。然后您可以加载一个 13B 模型与 BF16 权重，这至少需要 26GB 的 GPU 内存。请注意，这需要快速的 CPU-GPU 互连，因为模型的一部分在每个模型前向传递中从 CPU 内存动态加载到 GPU 内存。
# 默认值：0
--cpu-offload-gb 0

# 模型上下文长度。如果未指定，将自动从模型配置中派生。  "model_max_length": 16384
# 指定模型支持的最大输入长度为 8192 tokens。这个值需要与你的模型大小、显存和并行度相匹配。
--max-model-len 8192

# 要使用的模型实现。可选值：auto, vllm, transformers 默认值：“auto”
# “auto” 将尝试使用 vLLM 实现（如果存在），如果 vLLM 实现不可用，则回退到 Transformers 实现。
# “vllm” 将使用 vLLM 模型实现。
# “transformers” 将使用 Transformers 模型实现。
--model-impl

# 用于量化权重的方法。如果为 None，我们首先检查模型配置文件中的 quantization_config 属性。如果为 None，我们假设模型权重未量化，并使用 dtype 来确定权重的数据类型。
# 可选值：aqlm, awq, deepspeedfp, tpu_int8, fp8, ptpc_fp8, fbgemm_fp8, modelopt, marlin, gguf, gptq_marlin_24, gptq_marlin, awq_marlin, gptq, compressed-tensors, bitsandbytes, qqq, hqq, experts_int8, neuron_quant, ipex, quark, moe_wna16, None
--quantization, -q


# 使用负载均衡，确保它能够在多个 GPU 之间分配工作。
--max-requests
--max-requests-per-gpu

# 检查内存管理 如果模型因为内存不足只在 GPU 0 上运行，可以尝试调整内存分配设置，如环境变量 PYTORCH_CUDA_ALLOC_CONF。有助于减少 CUDA 内存的碎片化，允许模型更有效地使用多个 GPU。
PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:256

# 启用前缀缓存。
--enable-prefix-caching
# 信任远程代码
--trust-remote-code

# 使用版本1
VLLM_USE_V1=1
```

### vllm GGUF

[GGUF — vLLM](https://docs.vllm.ai/en/stable/features/quantization/gguf.html)

[gguf-split: split and merge gguf per batch of tensors by phymbert · Pull Request #6135 · ggml-org/llama.cpp](https://github.com/ggml-org/llama.cpp/pull/6135)
[llama.cpp/docs/docker.md at master · ggml-org/llama.cpp](https://github.com/ggml-org/llama.cpp/blob/master/docs/docker.md)

```sh
# [llama.cpp gguf-split](https://github.com/ggml-org/llama.cpp/tree/b3785/examples/gguf-split)
# --merge
gguf-split --merge /tmp/ggml-out-q4_0-2-00001-of-00003.gguf /tmp/ggml-out-q4_0-2-merge.gguf

gguf_merge: /tmp/ggml-out-q4_0-2-00001-of-00003.gguf -> /tmp/ggml-out-q4_0-2-merge.gguf
gguf_merge: reading metadata /tmp/ggml-out-q4_0-2-00001-of-00003.gguf ...done
gguf_merge: reading metadata /tmp/ggml-out-q4_0-2-00002-of-00003.gguf ...done
gguf_merge: reading metadata /tmp/ggml-out-q4_0-2-00003-of-00003.gguf ...done
gguf_merge: writing tensors /tmp/ggml-out-q4_0-2-00001-of-00003.gguf ...done
gguf_merge: writing tensors /tmp/ggml-out-q4_0-2-00002-of-00003.gguf ...done
gguf_merge: writing tensors /tmp/ggml-out-q4_0-2-00003-of-00003.gguf ...done
gguf_merge: /tmp/ggml-out-q4_0-2-merge.gguf merged from 3 split with 325 tensors.
```

## llama.cpp

[ggml-org/llama.cpp: LLM inference in C/C++](https://github.com/ggml-org/llama.cpp)
[LLaMA.cpp HTTP Server README · ggml-org/llama.cpp](https://github.com/ggml-org/llama.cpp/blob/master/examples/server/README.md)

[Local AI performance variables table](https://martech.org/how-to-run-deepseek-locally-on-your-computer/)

llama-cli

```sh
# llama-cli
#
# A CLI tool for accessing and experimenting with most of llama.cpp's functionality.
# Run in conversation mode
# Models with a built-in chat template will automatically activate conversation mode. If this doesn't occur, you can manually enable it by adding -cnv and specifying a suitable chat template with --chat-template NAME
llama-cli -m model.gguf
#
# > hi, who are you?
# Hi there! I'm your helpful assistant! I'm an AI-powered chatbot designed to assist and provide information to users like you. I'm here to help answer your questions, provide guidance, and offer support on a wide range of topics. I'm a friendly and knowledgeable AI, and I'm always happy to help with anything you need. What's on your mind, and how can I assist you today?
#
# > what is 1+1?
# Easy peasy! The answer to 1+1 is... 2!
```

llama-server

```sh
# llama-server
#
# A lightweight, OpenAI API compatible, HTTP server for serving LLMs.
# Start a local HTTP server with default configuration on port 8080
llama-server -m model.gguf --port 8080
#
# Basic web UI can be accessed via browser: http://localhost:8080
# Chat completion endpoint: http://localhost:8080/v1/chat/completions
Support multiple-users and parallel decoding
# up to 4 concurrent requests, each with 4096 max context
llama-server -m model.gguf -c 16384 -np 4

# Serve an embedding model
# use the /embedding endpoint
llama-server -m model.gguf --embedding --pooling cls -ub 8192
# Serve a reranking model
# use the /reranking endpoint
llama-server -m model.gguf --reranking
```

### llama docker

```sh
# ghcr.io/ggml-org/llama.cpp:full-cuda: Same as full but compiled with CUDA support. (platforms: linux/amd64)
$ docker run --gpus all -v /dsdata/modelscope/:/models ghcr.io/ggml-org/llama.cpp:full-cuda bash
Unknown command: bash
Available commands:
  --run (-r): Run a model previously converted into ggml
              ex: -m /models/7B/ggml-model-q4_0.bin -p "Building a website can be done in 10 simple steps:" -n 512
  --bench (-b): Benchmark the performance of the inference for various parameters.
              ex: -m model.gguf
  --perplexity (-p): Measure the perplexity of a model over a given text.
              ex: -m model.gguf -f file.txt
  --convert (-c): Convert a llama model into ggml
              ex: --outtype f16 "/models/7B/"
  --quantize (-q): Optimize with quantization process ggml
              ex: "/models/7B/ggml-model-f16.bin" "/models/7B/ggml-model-q4_0.bin" 2
  --all-in-one (-a): Execute --convert & --quantize
              ex: "/models/" 7B
  --server (-s): Run a model on the server
              ex: -m /models/7B/ggml-model-q4_0.bin -c 2048 -ngl 43 -mg 1 --port 8080
```

### Unsloth

[Run DeepSeek-R1 Dynamic 1.58-bit](https://unsloth.ai/blog/deepseekr1-dynamic)
[Tutorial: How to Run DeepSeek-R1 Locally | Unsloth Documentation](https://docs.unsloth.ai/basics/tutorials-how-to-fine-tune-and-run-llms/tutorial-how-to-run-deepseek-r1-locally)

```sh
# Example with Q4_0 K quantized cache Notice -no-cnv disables auto conversation mode
./llama.cpp/llama-cli \
    --model DeepSeek-R1-GGUF/DeepSeek-R1-UD-IQ1_S/DeepSeek-R1-UD-IQ1_S-00001-of-00003.gguf \
    --cache-type-k q4_0 \
    --threads 12 -no-cnv --prio 2 \
    --temp 0.6 \
    --ctx-size 8192 \
    --seed 3407 \
    --prompt "<｜User｜>What is 1+1?<｜Assistant｜>"

docker run -v /path/to/models:/models -p 8000:8000 ghcr.io/ggml-org/llama.cpp:server -m /models/7B/ggml-model-q4_0.gguf --port 8000 --host 0.0.0.0 -n 512
docker run --gpus all -v /path/to/models:/models local/llama.cpp:server-cuda -m /models/7B/ggml-model-q4_0.gguf --port 8000 --host 0.0.0.0 -n 512 --n-gpu-layers 1

# Deploy with docker on Linux:
docker run --runtime nvidia --gpus all \
    --detach \
    --restart always \
    --name llama \
    --env TZ=Asia/Shanghai \
    --env CUDA_VISIBLE_DEVICES=3,4 \
    --volume /dsdata/modelscope/:/models/ \
    --publish 8000:8000 \
    ghcr.io/ggml-org/llama.cpp:server \
    --port 8000 --host 0.0.0.0 -n 512 \
    --model DeepSeek-R1-GGUF/DeepSeek-R1-UD-IQ1_S/DeepSeek-R1-UD-IQ1_S-00001-of-00003.gguf
```

#### Chat Template Issues?

[Tutorial: How to Run DeepSeek-R1 Locally DeepSeek Chat Template | Unsloth Documentation](https://docs.unsloth.ai/basics/tutorials-how-to-fine-tune-and-run-llms/tutorial-how-to-run-deepseek-r1-locally#deepseek-chat-template)

```sh
print_info: BOS token        = 0 '<｜begin▁of▁sentence｜>'
print_info: EOS token        = 1 '<｜end▁of▁sentence｜>'
print_info: EOT token        = 1 '<｜end▁of▁sentence｜>'
print_info: PAD token        = 128815 '<｜PAD▁TOKEN｜>'
print_info: LF token         = 201 'Ċ'
print_info: FIM PRE token    = 128801 '<｜fim▁begin｜>'
print_info: FIM SUF token    = 128800 '<｜fim▁hole｜>'
print_info: FIM MID token    = 128802 '<｜fim▁end｜>'
print_info: EOG token        = 1 '<｜end▁of▁sentence｜>'
```

All distilled versions and the main 671B R1 model use the same chat template:

```sh
<｜begin▁of▁sentence｜><｜User｜>What is 1+1?<｜Assistant｜>It's 2.<｜end▁of▁sentence｜><｜User｜>Explain more!<｜Assistant｜>
```

A BOS is forcibly added, and an EOS separates each interaction. To counteract double BOS tokens during inference, you should only call tokenizer.encode(..., add_special_tokens = False) since the chat template auto adds a BOS token as well.
For llama.cpp / GGUF inference, you should skip the BOS since it’ll auto add it.

`<｜User｜>What is 1+1?<｜Assistant｜>`

The `<think>` and `</think>` tokens get their own designated tokens. For the distilled versions for Qwen and Llama, some tokens are re-mapped, whilst Qwen for example did not have a BOS token, so <|object_ref_start|> had to be used instead.

### llama server 参数

[LLaMA.cpp HTTP Server README](https://github.com/ggml-org/llama.cpp/blob/master/examples/server/README.md)

```sh
-t, --threads N     number of threads to use during generation (default: -1) (env: LLAMA_ARG_THREADS)
--prio N            set process/thread priority : 0-normal, 1-medium, 2-high, 3-realtime (default: 0)
-c, --ctx-size N    size of the prompt context (default: 4096, 0 = loaded from model) (env: LLAMA_ARG_CTX_SIZE)
-ctk, --cache-type-k TYPE   KV cache data type for K allowed values: f32, f16, bf16, q8_0, q4_0, q4_1, iq4_nl, q5_0, q5_1 (default: f16) (env: LLAMA_ARG_CACHE_TYPE_K)
-ctv, --cache-type-v TYPE   KV cache data type for V allowed values: f32, f16, bf16, q8_0, q4_0, q4_1, iq4_nl, q5_0, q5_1 (default: f16) (env: LLAMA_ARG_CACHE_TYPE_V)
-dev, --device <dev1,dev2,..>   comma-separated list of devices to use for offloading (none = don't offload) use --list-devices to see a list of available devices (env: LLAMA_ARG_DEVICE)
--list-devices    print list of available devices and exit
-ngl, --gpu-layers, --n-gpu-layers N  number of layers to store in VRAM (env: LLAMA_ARG_N_GPU_LAYERS)
-sm, --split-mode {none,layer,row}    how to split the model across multiple GPUs, one of:
                                      - none: use one GPU only
                                      - layer (default): split layers and KV across GPUs
                                      - row: split rows across GPUs (env: LLAMA_ARG_SPLIT_MODE)
-m, --model FNAME   model path (default: models/$filename with filename from --hf-file or --model-url if set, otherwise models/7B/ggml-model-f16.gguf)
(env: LLAMA_ARG_MODEL)
```

Sampling params

```sh
--jinja    Enable experimental Jinja templating engine (required for tool use)
--reasoning-format FORMAT    Controls extraction of model thinking traces and the format / field in which they are returned (default: deepseek; allowed values: deepseek, none; requires --jinja). none will leave thinking traces inline in message.content in a model-specific format, while deepseek will return them separately under message.reasoning_content
```

Example-specific params

```sh
--host HOST   ip address to listen (default: 127.0.0.1) (env: LLAMA_ARG_HOST)
--port PORT   port to listen (default: 8080) (env: LLAMA_ARG_PORT)

--embedding, --embeddings    restrict to only support embedding use case; use only with dedicated embedding models (default: disabled) (env: LLAMA_ARG_EMBEDDINGS)
--reranking, --rerank    enable reranking endpoint on server (default: disabled) (env: LLAMA_ARG_RERANKING)
--api-key KEY    API key to use for authentication (default: none) (env: LLAMA_API_KEY)  usage: --header "Authorization: Bearer KEY"
```

## 模型部署工具

Ollama：适合个人 + 本地部署 + 轻量体验
vLLM：适合企业级 + 服务器部署 + 高性能扩展

[对接本地大模型时，选择 Ollma 还是 vLLM？ - OSCHINA - 中文开源技术交流社区](https://www.oschina.net/news/321572)
[大模型工具对比：SGLang, Ollama, VLLM, LLaMA.cpp如何选择？](https://stable-learn.com/zh/ai-model-tools-comparison/)

[Integrate Local Models Deployed by Xinference | Dify](https://docs.dify.ai/development/models-integration/xinference)
[Integrate Local Models Deployed by OpenLLM | Dify](https://docs.dify.ai/development/models-integration/openllm)
[Integrate Local Models Deployed by LocalAI | Dify](https://docs.dify.ai/development/models-integration/localai)

| 工具名称        | 性能表现                                                     | 易用性                                 | 适用场景                                 | 硬件需求                       | 模型支持                      | 部署方式                       |
|-------------|----------------------------------------------------------|-------------------------------------|--------------------------------------|----------------------------|---------------------------|----------------------------|
| SGLang v0.4 | 零开销批处理提升1.1倍吞吐量，缓存感知负载均衡提升1.9倍，结构化输出提速10倍                | 需一定技术基础，但提供完整API和示例                 | 企业级推理服务、高并发场景、需要结构化输出的应用             | 推荐A100/H100，支持多GPU部署       | 全面支持主流大模型，特别优化DeepSeek等模型 | Docker、Python包             |
| Ollama      | 继承 llama.cpp 的高效推理能力，提供便捷的模型管理和运行机制                      | 小白友好，提供图形界面安装程序一键运行和命令行，支持 REST API | 个人开发者创意验证、学生辅助学习、日常问答、创意写作等个人轻量级应用场景 | 与 llama.cpp 相同，但提供更简便的资源管理 | 模型库丰富，涵盖 1700 多款，支持一键下载安装 | 独立应用程序、Docker、REST API     |
| VLLM        | 借助 PagedAttention 和 Continuous Batching 技术，多 GPU 环境下性能优异 | 需要一定技术基础，配置相对复杂                     | 大规模在线推理服务、高并发场景                      | 要求 NVIDIA GPU，推荐 A100/H100 | 支持主流 Hugging Face 模型      | Python包、OpenAI兼容API、Docker |
| LLaMA.cpp   | 多级量化支持，跨平台优化，高效推理                                        | 命令行界面直观，提供多语言绑定                     | 边缘设备部署、移动端应用、本地服务                    | CPU/GPU 均可，针对各类硬件优化        | GGUF格式模型，广泛兼容性            | 命令行工具、API服务器、多语言绑定         |

### 模型显存使用量计算

[Can Your Computer Run This LLM?](https://www.canirunthisllm.net/)
[Ollama GPU Compatibility Calculator - React App](https://aleibovici.github.io/ollama-gpu-calculator/)

[模型显存使用量计算 — Xinference](https://inference.readthedocs.io/zh-cn/stable/models/model_memory.html)
[LLM Model VRAM Calculator - a Hugging Face Space by NyxKrage](https://huggingface.co/spaces/NyxKrage/LLM-Model-VRAM-Calculator)

[STOP asking for "the best model for my pc" : r/ollama](https://www.reddit.com/r/ollama/comments/1j8qp3g/stop_asking_for_the_best_model_for_my_pc/?share_id=xGRLbTeGKPHcJcmxcm5Je&utm_content=1&utm_medium=ios_app&utm_name=iossmf&utm_source=share&utm_term=22)

```sh
xinference cal-model-mem -s 7 -f gptq -c 8192 -n GOT-OCR2_0
xinference cal-model-mem -s 7 -q Int4 -f gptq -c 16384 -n qwen1.5-chat
# model_name: qwen1.5-chat
# kv_cache_dtype: 16
# model size: 7.0 B
# quant: Int4
# context: 16384
# gpu mem usage:
#   model mem: 4139 MB
#   kv_cache: 8192 MB
#   overhead: 650 MB
#   active: 17024 MB
#   total: 30005 MB (30 GB)

## GPU 使用情况监控
watch -n 1 nvidia-smi
```

### ollama 模型部署工具

Ollama, a popular local LLM deployment tool, supports a broad range of open-source LLMs and offers an intuitive experience, making it ideal for single-user, local environments.

### OpenLLM

[bentoml/OpenLLM: Run any open-source LLMs, such as Llama, Mistral, as OpenAI compatible API endpoint in the cloud.](https://github.com/bentoml/OpenLLM)

From Ollama to OpenLLM: Running LLMs in the Cloud
[From Ollama to OpenLLM: Running LLMs in the Cloud](https://www.bentoml.com/blog/from-ollama-to-openllm-running-llms-in-the-cloud)

```powershell
# [【解决】无法将“XXX”项识别为 cmdlet、函数、脚本文件或可运行程序的名称。请检查名称的拼写，如果包括路径，请确保路径正确，然后再试一次_无法将“labelme”项识别为 cmdlet、函数、脚本文件或可运行程序的名称。请检查名-CSDN博客](https://blog.csdn.net/weixin_41362657/article/details/110649744)
PS D:\>
Get-ExecutionPolicy -List

        Scope ExecutionPolicy
        ----- ---------------
MachinePolicy       Undefined
   UserPolicy       Undefined
      Process       Undefined
  CurrentUser       Undefined
 LocalMachine       Undefined

# Scope: Process, CurrentUser, LocalMachine, UserPolicy, MachinePolicy
# ExecutionPolicy: Unrestricted, RemoteSigned, AllSigned, Restricted, Default, Bypass, Undefined”
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
Set-ExecutionPolicy Unrestricted -Scope CurrentUser
Set-ExecutionPolicy RemoteSigned -Scope LocalMachine
```

### LocalAI

[LocalAI-examples/langchain-chroma at main · mudler/LocalAI-examples](https://github.com/mudler/LocalAI-examples/tree/main/langchain-chroma)

```sh
# 配置到dify 时 404
# 2025-02-11 11:51:10 3:51AM WRN Client error ip=172.20.0.1 latency="24.32µs" method=POST status=404 url=/rerank

curl http://localhost:8080/console/api/workspaces/current/models/model-types/rerank

curl http://localhost:8080/v1/rerank \
  -H "Content-Type: application/json" \
  -d '{
  "model": "cross-encoder",
  "query": "Organic skincare products for sensitive skin",
  "documents": [
    "Eco-friendly kitchenware for modern homes",
    "Biodegradable cleaning supplies for eco-conscious consumers",
    "Organic cotton baby clothes for sensitive skin",
    "Natural organic skincare range for sensitive skin",
    "Tech gadgets for smart homes: 2024 edition",
    "Sustainable gardening tools and compost solutions",
    "Sensitive skin-friendly facial cleansers and toners",
    "Organic food wraps and storage solutions",
    "All-natural pet food for dogs with allergies",
    "Yoga mats made from recycled materials"
  ],
  "top_n": 3
}'

```

### xinference

[在Xinference上部署自定义大模型——FreedomIntelligence/HuatuoGPT2-13B为例 - 知乎](https://zhuanlan.zhihu.com/p/685747169)

```sh
# 将模型下载源设置为 ModelScope。设置环境变量 XINFERENCE_MODEL_SRC=modelscope
docker pull registry.cn-hangzhou.aliyuncs.com/xprobe_xinference/xinference
docker image tag registry.cn-hangzhou.aliyuncs.com/xprobe_xinference/xinference:latest xprobe_xinference/xinference:latest
docker run -e XINFERENCE_MODEL_SRC=modelscope -p 9997:9997 --gpus all xprobe/xinference:v<your_version> xinference-local -H 0.0.0.0 --log-level debug

  --restart always \
docker run --detach \
  --name xinference \
  --env TZ=Asia/Shanghai \
  --publish 9997:9997 \
  --env XINFERENCE_MODEL_SRC=modelscope \
  --volume //c/workspace/xinference/.xinference:/root/.xinference \
  --volume //c/workspace/xinference/.cache/huggingface:/root/.cache/huggingface \
  --volume //c/workspace/xinference/.cache/modelscope:/root/.cache/modelscope \
  --gpus all \
  xprobe_xinference/xinference:v0.15.4 \
  sh /root/.xinference/startup.sh

# Windows下改成一行执行
docker run --detach --env TZ=Asia/Shanghai --publish 9997:9997 --name xinference --restart always -e XINFERENCE_MODEL_SRC=modelscope -v //c/workspace/xinference/.xinference:/root/.xinference -v //c/workspace/xinference/.cache/huggingface:/root/.cache/huggingface -v //c/workspace/xinference/.cache/modelscope:/root/.cache/modelscope --gpus all xprobe_xinference/xinference sh /root/.xinference/startup.sh

alias xinference='docker exec -it xinference xinference'
```

```sh
#!/bin/bash
# startup.sh 放在外部磁盘挂载进去，启动时执行
# 启动且后台运行
xinference-local -H 0.0.0.0 &
# xinference-local -H 0.0.0.0 --log-level debug &
# 检测是否启动
while true; do
  if curl -s "http://localhost:9997" > /dev/null; then
    break
  else
    sleep 1
  fi
done

#自动加载 embedding
xinference launch --model-name bge-m3 --model-type embedding &
# xinference launch --model-name jina-embeddings-v3 --model-type embedding &
#自动加载 rerank
xinference launch --model-name jina-reranker-v2 --model-type rerank &

#等待后台运行结束，实际上xinference-local是不会结束的，所以能保证此脚本进程不结束，从而不会自动重启
wait
```

调用模型接口

```sh
# llm chat
curl -X 'POST' \
  'http://127.0.0.1:9997/v1/chat/completions' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
    "model": "qwen2.5-instruct",
    "messages": [
        {
            "role": "system",
            "content": "You are a helpful assistant."
        },
        {
            "role": "user",
            "content": "What is the largest animal?"
        }
    ]
  }'

# embeddings
curl -X 'POST' 'http://localhost:9997/v1/embeddings' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
    "model": "bge-m3",
    "input": "Hello, world!"
  }'

# rank
curl http://localhost:9997/v1/rerank \
  -H "Content-Type: application/json" \
  -d '{
  "model": "bge-reranker-v2-m3",
  "query": "Organic skincare products for sensitive skin",
  "documents": [
    "Eco-friendly kitchenware for modern homes",
    "Biodegradable cleaning supplies for eco-conscious consumers",
    "Organic cotton baby clothes for sensitive skin",
    "Natural organic skincare range for sensitive skin",
    "Tech gadgets for smart homes: 2024 edition",
    "Sustainable gardening tools and compost solutions",
    "Sensitive skin-friendly facial cleansers and toners",
    "Organic food wraps and storage solutions",
    "All-natural pet food for dogs with allergies",
    "Yoga mats made from recycled materials"
  ],
  "top_n": 3
}'
```

本地安装

```sh
# 本地安装
conda create --name py312 python=3.12
conda activate py312

# 安装xinference的依赖
pip install "xinference[all]"

# 启动xinference
xinference-local # 我使用这个命令启动不了
# 设置使用modelscope下载模型
# 如果你就一块gpu还是0的话就要指定启动
CUDA_VISIBLE_DEVICES=0
# 使用这个命令可以启动
XINFERENCE_HOME=d:/xinference/ XINFERENCE_MODEL_SRC=modelscope xinference-local --host 0.0.0.0 --port 9997

# 列举本地模型
xinference list --endpoint "http://127.0.0.1:9997"

# [jina-embeddings-v2-base-zh — Xinference](https://inference.readthedocs.io/zh-cn/latest/models/builtin/embedding/jina-embeddings-v2-base-zh.html)
# Model ID: jinaai/jina-embeddings-v2-base-zh
# xinference launch --model-name jina-embeddings-v2-base-zh --model-type embedding
xinference launch --model-name jina-embeddings-v3 --model-type embedding &
xinference launch --model-name bge-m3 --model-type embedding &

# [jina-reranker-v2 — Xinference](https://inference.readthedocs.io/zh-cn/latest/models/builtin/rerank/jina-reranker-v2.html)
# Model ID: jinaai/jina-reranker-v2-base-multilingual
xinference launch --model-name jina-reranker-v2 --model-type rerank &
xinference launch --model-name bge-reranker-large --model-type rerank &
xinference launch --model-name bge-reranker-v2-minicpm-layerwise --model-type rerank &

# OCR 模型 [GOT-OCR2_0 — Xinference](https://inference.readthedocs.io/zh-cn/v0.16.3/models/builtin/image/got-ocr2_0.html)
xinference launch --model-name GOT-OCR2_0 --model-type image
# Launch model name: GOT-OCR2_0 with kwargs: {}
# Model uid: GOT-OCR2_0

# 列出所有内置支持的模型
xinference registrations -t embedding
xinference registrations -t rerank
```

### SGLang

[sgl-project/sglang: SGLang is a fast serving framework for large language models and vision language models.](https://github.com/sgl-project/sglang)

### Embedding model

[Embedding models · Ollama Blog](https://ollama.com/blog/embedding-models)

[MTEB Leaderboard - a Hugging Face Space by mteb](https://huggingface.co/spaces/mteb/leaderboard)
MTEB（Massive Text Embedding Benchmark）是一个用于评估文本嵌入（Embedding）模型的综合性基准测试平台。通过多任务和多数据集的组合，MTEB可以全面衡量不同Embedding模型在各种自然语言处理（NLP）任务中的表现，如文本分类、语义检索、文本聚类等。

```sh
ollama pull mxbai-embed-large
```

### reranking models

Ollama rerank model [linux6200/bge-reranker-v2-m3](https://ollama.com/linux6200/bge-reranker-v2-m3)

deploy local embedding/reranking models using xinference/LocalAI/OpenLLM.

[Using Xinference — Xinference](https://inference.readthedocs.io/en/latest/getting_started/using_xinference.html#using-xinference-with-docker)

```sh
docker run -e XINFERENCE_MODEL_SRC=modelscope -p 9998:9997 --gpus all xprobe/xinference:<your_version> xinference-local -H 0.0.0.0 --log-level debug

# 1024 维度  最大 token 数 8192
jina-embeddings-v3
```

## GPU 介绍

GPU 命名规则解读

[一文读懂 NVIDIA GPU 产品线-51CTO.COM](https://www.51cto.com/article/805028.html)
[英伟达GPU各型号对比 - 知乎](https://zhuanlan.zhihu.com/p/718450083)
[比较 GeForce 系列最新一代显卡和前代显卡 | NVIDIA](https://www.nvidia.cn/geforce/graphics-cards/compare/)

### 字母： 架构代号（Architecture）

新的架构通常代表着性能、能效比和新技术的显著提升。

代表 GPU 的核心架构，通常用一个或多个字母表示，代表 GPU 的微架构。例如：

K：Kepler 架构 2012
V：Volta 架构 2017
T：Turing 架构 2018, RTX 20 系列, GTX 16 系列
A：Ampere 架构 2019, RTX 30 系列
H：Hopper 架构 2022, RTX 4000 系列
L: Ada Lovelace 架构 2022, RTX 40 系列
B: Blackwell 架构, RTX 50 系列

### 数字：性能层级（Tier）

通常用数字表示，数字越大通常代表性能越强。

代表 GPU 的具体型号，通常用一个或多个数字表示。例如：

“4” 系列：入门级或低功耗级
“10” 系列：中端推理优化级
“40” 系列：高端图形和虚拟工作站级
“100” 系列：旗舰级高性能计算和人工智能级

### 常见的GPU 型号对比解析：基于 GPU 命名推断显卡特性

示例一：T4 与 L4 的比较

L4 是 T4 的直接后继者，属于同一性能层级，针对相似的应用场景设计。然而，两者在微架构和技术规格上存在显著差异：

微架构： L4 采用更新的 Ada Lovelace 架构（2023 年发布），而 T4 则采用较早的 Turing 架构（2018 年发布）。
显存容量： L4 配备了更大的显存容量，达到 24 GB，而 T4 仅有 16 GB。
核心数量和性能： L4 拥有更多且更强大的计算核心，因此在性能上优于 T4。
虽然两者的目标功耗相似，但 L4 凭借更先进的架构和更高的显存容量，在相同的功耗下能够提供更强的计算性能，更适合处理对显存容量有较高要求的任务。

示例二：A10 与 A100 的比较

A100 是基于 Ampere 架构的旗舰级产品，而 A10 则是该架构下的一个较低层级的型号。两者都基于相同的 Ampere 微架构，但在规模和性能上存在显著差异：

核心数量和性能： A100 拥有远多于 A10 的计算核心，因此在计算性能上远超 A10。
显存容量： A100 配备了更大的显存容量，以支持更大规模的模型训练和推理。
功耗： 由于规模更大、性能更强，A100 的功耗也高于 A10。
因此，A100 更适合需要处理大规模模型训练、微调和高吞吐量推理等 demanding 计算任务的场景，而 A10 则更适合对成本和功耗敏感、对性能要求相对较低的应用场景。

### 面向 AI 和机器学习的显卡

| 排名 | GPU 型号 | 架构 | CUDA 核心数 | 显存 | 主要用途 |
| --- | --- | --- | --- | --- | --- |
| 1 | NVIDIA H100 | Hopper | 16896 | 80GB HBM3 | 大规模 AI 训练 |
| 2 | NVIDIA A100 | Ampere | 6912 | 40GB HBM2 | AI 推理、机器学习 |
| 3 | NVIDIA V100 | Volta | 5120 | 32GB HBM2 | 神经网络训练、科学计算 |
| 4 | Tesla T4 | Turing | 2560 | 16GB GDDR6 | 轻量 AI 推理、云推理 |
| 5 | Tesla P100 | Pascal | 3584 | 16GB HBM2 | 数据中心加速、机器学习推理 |
| 6 | NVIDIA A40 | Ampere | ? | 48GB | AI 推理、机器学习 |

H20 96GB

### 硬件资源配置

显存需求 ≈ 模型参数 × 参数字节数 × 安全系数（1.3-1.5）

CPU GPU 配置比例：建议内存是显存的1.5倍以上

### gpu 相关命令

```sh
nvcc --version
# nvcc: NVIDIA (R) Cuda compiler driver
# Copyright (c) 2005-2021 NVIDIA Corporation
# Built on Thu_Nov_18_09:45:30_PST_2021
# Cuda compilation tools, release 11.5, V11.5.119
# Build cuda_11.5.r11.5/compiler.30672275_0

nvidia-smi
# Mon Mar 31 14:24:25 2025
# +-----------------------------------------------------------------------------------------+
# | NVIDIA-SMI 570.86.15              Driver Version: 570.86.15      CUDA Version: 12.8     |
# |-----------------------------------------+------------------------+----------------------+
# | GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
# | Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
# |                                         |                        |               MIG M. |
# |=========================================+========================+======================|
# |   0  NVIDIA A40                     Off |   00000000:67:00.0 Off |                    0 |
# |  0%   75C    P0            303W /  300W |   43985MiB /  46068MiB |     96%      Default |
# |                                         |                        |                  N/A |
# +-----------------------------------------+------------------------+----------------------+

# +-----------------------------------------------------------------------------------------+
# | Processes:                                                                              |
# |  GPU   GI   CI              PID   Type   Process name                        GPU Memory |
# |        ID   ID                                                               Usage      |
# |=========================================================================================|
# |    0   N/A  N/A           25809      C   /usr/local/bin/ollama                 43976MiB |
# +-----------------------------------------------------------------------------------------+

pip install nvitop
# 查看
nvitop
```
