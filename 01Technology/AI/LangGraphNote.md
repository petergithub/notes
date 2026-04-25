# LangGraph

[LangGraph](https://langchain-ai.github.io/langgraph/)

[LangSmith](https://smith.langchain.com/)

[SQL agent](https://langchain-ai.github.io/langgraph/tutorials/sql/sql-agent/)

[langchain-deepseek: 0.1.3 — 🦜🔗 LangChain documentation](https://python.langchain.com/api_reference/deepseek/)

## Learn Path

1. [Foundation: Introduction to LangGraph - Python - LangChain Academy](https://academy.langchain.com/courses/take/intro-to-langgraph/texts/58238105-getting-set-up)
2. [LangChain Resources: Guides, Reports & AI Agent Insights](https://www.langchain.com/resources)
3. [Learning LLMs and AI Agents - Google Docs](https://docs.google.com/document/d/1z-qYfxtn3dtrdQlxhldIDqcRNd_9WoysUdXasKwxbW0/edit?tab=t.0)
4. [Courses - DeepLearning.AI](https://www.deeplearning.ai/courses/)

## Quickstarts

### Run a local server

[Run a local server](https://langchain-ai.github.io/langgraph/tutorials/langgraph-platform/local-server/)
[LangSmith Studio - Docs by LangChain](https://docs.langchain.com/langsmith/studio#local-development-server)

```sh
# Python >= 3.11 is required.
pip install --upgrade "langgraph-cli[inmem]"

langgraph new path/to/your/app --template new-langgraph-project-python

cd path/to/your/app
pip install -e .

# Launch LangGraph Server
# The langgraph dev command starts LangGraph Server in an in-memory mode. This mode is suitable for development and testing purposes.
langgraph dev

# Sample output:
>    Ready!
>    - API: [http://localhost:2024](http://localhost:2024/)
>    - Docs: http://localhost:2024/docs
>    - LangGraph Studio Web UI: https://smith.langchain.com/studio/?baseUrl=http://127.0.0.1:2024
# Test your application in LangGraph Studio
>    - LangGraph Studio Web UI: https://smith.langchain.com/studio/?baseUrl=http://127.0.0.1:2024
```

### Build a SQL agent

```sh
pip install -U langgraph langchain_community "langchain[deepseek]"
pip install -U "langchain[gemini]"

```

### Deploy a Standalone Container

[How to Deploy a Standalone Container](https://langchain-ai.github.io/langgraph/cloud/deployment/standalone_container/)

```sh
docker run \
    --env-file .env \
    -p 8123:8000 \
    -e REDIS_URI="foo" \
    -e DATABASE_URI="bar" \
    -e LANGSMITH_API_KEY="baz" \
    my-image
```

### Quick start reference

[Application structure](https://langchain-ai.github.io/langgraph/concepts/application_structure/)

[Use requirements.txt](https://langchain-ai.github.io/langgraph/cloud/deployment/setup/)

## LangGraph CLI

[LangGraph CLI](https://langchain-ai.github.io/langgraph/cloud/reference/cli/#dockerfile)

```sh
pip install langgraph-cli

# Builds a Docker image for the LangGraph API server that can be directly deployed.
langgraph build
    -t, --tag TEXT # Required. Tag for the Docker image. Example: langgraph build -t my-image
    -c, --config FILE langgraph.json # Path to configuration file declaring dependencies, graphs and environment variables.
# Starts a lightweight development server that requires no Docker installation. This server is ideal for rapid development and testing. This is available in version 0.1.55 and up.
langgraph dev

# Generates a Dockerfile that can be used to build images for and deploy instances of the LangGraph API server. This is useful if you want to further customize the dockerfile or deploy in a more custom way.
langgraph dockerfile [OPTIONS] SAVE_PATH
langgraph dockerfile -c langgraph.json Dockerfile

# Starts an instance of the LangGraph API server locally in a docker container. This requires the docker server to be running locally. It also requires a LangSmith API key for local development or a license key for production use.
langgraph up
```

## LangChain Academy - Introduction to LangGraph

[Foundation: Introduction to LangGraph - Python - LangChain Academy](https://academy.langchain.com/courses/take/intro-to-langgraph/texts/58238105-getting-set-up)
[Course-Transcripts.txt](https://import.cdn.thinkific.com/967498/gIM6mFYTmOKJLPQPd4SW_Course-Transcripts.txt)

[ChatDeepSeek integration - Docs by LangChain](https://docs.langchain.com/oss/python/integrations/chat/deepseek)

[petergithub/langchain-academy-fork](https://github.com/petergithub/langchain-academy-fork)

**Setup**
**Python version**

```sh
# Please make sure you're using a Python version higher than 3.11 but lower than 3.14, specifically 3.11, 3.12, or 3.13.
python3 --version

# **Clone repo**
git clone https://github.com/langchain-ai/langchain-academy.git
$ cd langchain-academy

# **Create an environment and install dependencies**

$ python3 -m venv lc-academy-env
$ source lc-academy-env/bin/activate
$ pip install -r requirements.txt

# **Running notebooks**
# If you don't have Jupyter set up, follow installation instructions [here](https://jupyter.org/install).
$ jupyter notebook

# **Sign up for LangSmith**
# Create a [LangSmith](https://docs.langchain.com/langsmith/create-account-api-key) account and API key. You can reference LangSmith docs [here](https://docs.smith.langchain.com/).
# Then, set

LANGSMITH_API_KEY="your-key"
LANGSMITH_TRACING_V2=true
LANGSMITH_PROJECT="langchain-academy"
# If you are on the EU instance:
LANGSMITH_ENDPOINT=https://eu.api.smith.langchain.com`

# in your environment.

# **Set up OpenAI API key**
# If you don’t have an OpenAI API key, you can sign up [here](https://openai.com/index/openai-api/). Note that OpenAI no longer has a free tier. You can use other models. Your results may differ from those in the course video, but that is not unusual in LLM development. Be sure to set up keys and alter invocations for any alternate models.
#
# Then, set

# OPENAI_API_KEY
DEEPSEEK_API_KEY

# and replace
llm = ChatOpenAI(model="gpt-4o")
# to
# llm = ChatOpenAI(model="gpt-4o")
from langchain_deepseek import ChatDeepSeek
llm = ChatDeepSeek(model="deepseek-reasoner", temperature=0, max_tokens=None, timeout=None, max_retries=2,)

# in your environment.

# **Tavily for web search**

# Tavily Search API is a search engine optimized for LLMs and RAG, aimed at efficient, quick, and persistent search results. You can sign up for an API key [here](https://tavily.com/). It’s easy to sign up and offers a generous free tier. Some lessons in Module 4 will use Tavily.

# Then, set

TAVILY_API_KEY

# in your environment.

# **Set up LangSmith Studio**

# **Note: LangSmith Studio was formerly LangGraph Studio**

# -   LangSmith Studio is a custom IDE for viewing and testing agents.
# -   Studio can be run locally and opened in your browser on Mac, Windows, and Linux.
# -   See documentation [here](https://langchain-ai.github.io/langgraph/concepts/langgraph_studio/#local-development-server).
# -   Graphs for LangSmith Studio are in the module-x/studio/ folders.
# -   To start the local development server, run the following command in your terminal in the /studio directory each module:

langgraph dev

# You should see the following output:

# \- 🚀 API: http://127.0.0.1:2024
# - 🎨 Studio UI: https://smith.langchain.com/studio/?baseUrl=http://127.0.0.1:2024
# - 📚 API Docs: [http://127.0.0.1:2024/docs](http://127.0.0.1:2024/docs)

# Open your browser and navigate to the Studio UI: `https://smith.langchain.com/studio/?baseUrl=http://127.0.0.1:2024`

# -   To use Studio, you will need to create a .env file with the relevant API keys
# -   Run this from the command line to create these files for module 1 to 6, as an example:


# for i in {1..5}; do
#   cp module-$i/studio/.env.example module-$i/studio/.env
#   echo "OPENAI_API_KEY=\\"$OPENAI_API_KEY\\"" > module-$i/studio/.env
# done
# echo "TAVILY_API_KEY=\\"$TAVILY_API_KEY\\"" >> module-4/studio/.env

for i in {1..5}; do
  cp module-$i/studio/.env.example module-$i/studio/.env
  echo "DEEPSEEK_API_KEY=\"$DEEPSEEK_API_KEY\"" > module-$i/studio/.env
done
echo "TAVILY_API_KEY=\"$TAVILY_API_KEY\"" >> module-4/studio/.env
```
