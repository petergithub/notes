# LangGraph

[LangGraph](https://langchain-ai.github.io/langgraph/)

[LangSmith](https://smith.langchain.com/)

[SQL agent](https://langchain-ai.github.io/langgraph/tutorials/sql/sql-agent/)

[langchain-deepseek: 0.1.3 — 🦜🔗 LangChain documentation](https://python.langchain.com/api_reference/deepseek/)

## Quickstarts

### Run a local server

[Run a local server](https://langchain-ai.github.io/langgraph/tutorials/langgraph-platform/local-server/)

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
>
>    - API: [http://localhost:2024](http://localhost:2024/)
>
>    - Docs: http://localhost:2024/docs
>
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

# Starts a lightweight development server that requires no Docker installation. This server is ideal for rapid development and testing. This is available in version 0.1.55 and up.
langgraph dev

# Generates a Dockerfile that can be used to build images for and deploy instances of the LangGraph API server. This is useful if you want to further customize the dockerfile or deploy in a more custom way.
langgraph dockerfile [OPTIONS] SAVE_PATH
langgraph dockerfile -c langgraph.json Dockerfile

# Starts an instance of the LangGraph API server locally in a docker container. This requires the docker server to be running locally. It also requires a LangSmith API key for local development or a license key for production use.
langgraph up
```
