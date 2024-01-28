# LLaMA

[Running LLaMA 7B and 13B on a 64GB M2 MacBook Pro with llama.cpp | Simon Willison’s TILs](https://til.simonwillison.net/llms/llama-7b-m2)
[ggerganov/llama.cpp: Port of Facebook's LLaMA model in C/C++](https://github.com/ggerganov/llama.cpp)

[用笔记本运行650亿参数大模型 InfoQ精选文章](https://www.infoq.cn/article/qucNy1wcUq87HCSTjddQ)
[人人都能懂的ChatGPT解读_AI_张杰_InfoQ精选文章](https://www.infoq.cn/article/VWrPIRvRg6E3O74q7PtL)

## My process

```sh
conda create python=3.10 --name p3.10

conda activate p3.10

python convert_old-ggml_to_ggmlv1.py models/7B models/tokenizer.model

./main -m ./models/7B/ggml-model-q4_0.bin \
  -t 8 \
  -n 128 \
  -p 'The first man on the moon was '

./talk.sh "Enabling the Zsh Completion"


(p3.10) (⎈|dev-test:picooc-tools)➜  llama.cpp git:(master) python convert-pth-to-ggml.py models/7B 1
{'dim': 4096, 'multiple_of': 256, 'n_heads': 32, 'n_layers': 32, 'norm_eps': 1e-06, 'vocab_size': -1}
n_parts = 1

Processing part 0

Traceback (most recent call last):
  File "/Users/pu/Documents/workspace/bi.workspace/llama.cpp/convert-pth-to-ggml.py", line 157, in <module>
    main()
  File "/Users/pu/Documents/workspace/bi.workspace/llama.cpp/convert-pth-to-ggml.py", line 146, in main
    model = torch.load(fname_model, map_location="cpu")
  File "/Users/pu/opt/anaconda3/envs/p3.10/lib/python3.10/site-packages/torch/serialization.py", line 809, in load
    return _load(opened_zipfile, map_location, pickle_module, **pickle_load_args)
  File "/Users/pu/opt/anaconda3/envs/p3.10/lib/python3.10/site-packages/torch/serialization.py", line 1172, in _load
    result = unpickler.load()
  File "/Users/pu/opt/anaconda3/envs/p3.10/lib/python3.10/site-packages/torch/serialization.py", line 1142, in persistent_load
    typed_storage = load_tensor(dtype, nbytes, key, _maybe_decode_ascii(location))
  File "/Users/pu/opt/anaconda3/envs/p3.10/lib/python3.10/site-packages/torch/serialization.py", line 1112, in load_tensor
    storage = zip_file.get_storage_from_record(name, numel, torch.UntypedStorage)._typed_storage()._untyped_storage
RuntimeError: PytorchStreamReader failed reading file data/2: invalid header or archive is corrupted

```

## Reference

[Running LLaMA 7B and 13B on a 64GB M2 MacBook Pro with llama.cpp | Simon Willison’s TILs](https://til.simonwillison.net/llms/llama-7b-m2)

https://til.simonwillison.net/llms/llama-7b-m2

(⎈|dev-test:picooc-tools)➜  bi.workspace git:(work) ✗ cd llama.cpp
(⎈|dev-test:picooc-tools)➜  llama.cpp git:(master) make
I llama.cpp build info:
I UNAME_S:  Darwin
I UNAME_P:  arm
I UNAME_M:  arm64
I CFLAGS:   -I.              -O3 -DNDEBUG -std=c11   -fPIC -pthread -DGGML_USE_ACCELERATE
I CXXFLAGS: -I. -I./examples -O3 -DNDEBUG -std=c++17 -fPIC -pthread
I LDFLAGS:   -framework Accelerate
I CC:       Apple clang version 14.0.0 (clang-1400.0.29.202)
I CXX:      Apple clang version 14.0.0 (clang-1400.0.29.202)

cc  -I.              -O3 -DNDEBUG -std=c11   -fPIC -pthread -DGGML_USE_ACCELERATE   -c ggml.c -o ggml.o
c++ -I. -I./examples -O3 -DNDEBUG -std=c++17 -fPIC -pthread -c utils.cpp -o utils.o
c++ -I. -I./examples -O3 -DNDEBUG -std=c++17 -fPIC -pthread main.cpp ggml.o utils.o -o main  -framework Accelerate
./main -h
usage: ./main [options]

options:
  -h, --help            show this help message and exit
  -i, --interactive     run in interactive mode
  -ins, --instruct      run in instruction mode (use with Alpaca models)
  -r PROMPT, --reverse-prompt PROMPT
                        in interactive mode, poll user input upon seeing PROMPT (can be
                        specified more than once for multiple prompts).
  --color               colorise output to distinguish prompt and user input from generations
  -s SEED, --seed SEED  RNG seed (default: -1)
  -t N, --threads N     number of threads to use during computation (default: 4)
  -p PROMPT, --prompt PROMPT
                        prompt to start generation with (default: empty)
  --random-prompt       start with a randomized prompt.
  -f FNAME, --file FNAME
                        prompt file to start generation.
  -n N, --n_predict N   number of tokens to predict (default: 128)
  --top_k N             top-k sampling (default: 40)
  --top_p N             top-p sampling (default: 0.9)
  --repeat_last_n N     last n tokens to consider for penalize (default: 64)
  --repeat_penalty N    penalize repeat sequence of tokens (default: 1.3)
  -c N, --ctx_size N    size of the prompt context (default: 512)
  --ignore-eos          ignore end of stream token and continue generating
  --memory_f16          use f16 instead of f32 for memory key+value
  --temp N              temperature (default: 0.8)
  -b N, --batch_size N  batch size for prompt processing (default: 8)
  -m FNAME, --model FNAME
                        model path (default: models/llama-7B/ggml-model.bin)

c++ -I. -I./examples -O3 -DNDEBUG -std=c++17 -fPIC -pthread quantize.cpp ggml.o utils.o -o quantize  -framework Accelerate

### github torrent merge request

[Save bandwidth by using a torrent to distribute more efficiently by ChristopherKing42 · Pull Request #73 · facebookresearch/llama](https://github.com/facebookresearch/llama/pull/73#issuecomment-1468084739)

### aria download


For the 7B model...

aria2c --select-file 21-23,25,26 'magnet:?xt=urn:btih:b8287ebfa04f879b048d4d4404108cf3e8014352&dn=LLaMA'
For the 13B model...

aria2c --select-file 1-4,25,26 'magnet:?xt=urn:btih:b8287ebfa04f879b048d4d4404108cf3e8014352&dn=LLaMA'
For the 30B model...

aria2c --select-file 5-10,25,26 'magnet:?xt=urn:btih:b8287ebfa04f879b048d4d4404108cf3e8014352&dn=LLaMA'
For the 65B model...

aria2c --select-file 11-20,25,26 'magnet:?xt=urn:btih:b8287ebfa04f879b048d4d4404108cf3e8014352&dn=LLaMA'
And for everything...

aria2c 'magnet:?xt=urn:btih:b8287ebfa04f879b048d4d4404108cf3e8014352&dn=LLaMA'

### sharepoint

[7B - OneDrive](https://zl86n-my.sharepoint.com/personal/ticrawler_tmzn_top/_layouts/15/onedrive.aspx?ga=1&id=%2Fpersonal%2Fticrawler%5Ftmzn%5Ftop%2FDocuments%2FLLAMA%2F7B)

### ipfs

[ipfs download](https://github.com/facebookresearch/llama/pull/73#issuecomment-1468084739)

Full backup: ipfs://Qmb9y5GCkTG7ZzbBWMu2BXwMkzyCKcUjtEKPpgdZ7GEFKm

7B: ipfs://QmbvdJ7KgvZiyaqHw5QtQxRtUd7pCAdkWWbzuvyKusLGTw
13B: ipfs://QmPCfCEERStStjg4kfj3cmCUu1TP7pVQbxdFMwnhpuJtxk
30B: ipfs://QmSD8cxm4zvvnD35KKFu8D9VjXAavNoGWemPW1pQ3AF9ZZ
65B: ipfs://QmdWH379NQu8XoesA8AFw9nKV2MpGR4KohK7WyugadAKTh

[7B /ipfs/QmbvdJ7KgvZiyaqHw5QtQxRtUd7pCAdkWWbzuvyKusLGTw/](https://ipfs.io/ipfs/QmbvdJ7KgvZiyaqHw5QtQxRtUd7pCAdkWWbzuvyKusLGTw/)
ipfs get QmbvdJ7KgvZiyaqHw5QtQxRtUd7pCAdkWWbzuvyKusLGTw --output ./7B

[full /ipfs/Qmb9y5GCkTG7ZzbBWMu2BXwMkzyCKcUjtEKPpgdZ7GEFKm/](https://ipfs.io/ipfs/Qmb9y5GCkTG7ZzbBWMu2BXwMkzyCKcUjtEKPpgdZ7GEFKm/)

ipfs get Qmb9y5GCkTG7ZzbBWMu2BXwMkzyCKcUjtEKPpgdZ7GEFKm/tokenizer.model --output .
ipfs get Qmb9y5GCkTG7ZzbBWMu2BXwMkzyCKcUjtEKPpgdZ7GEFKm/tokenizer_checklist.chk --output .

#### ipfs software

[Initialize a Kubo node and interact with the IPFS Network | IPFS Docs](https://docs.ipfs.tech/how-to/command-line-quick-start/#take-your-node-online)

API server listening on /ip4/127.0.0.1/tcp/5001
WebUI: http://127.0.0.1:5001/webui

```sh
# Take your node online
ipfs dameon

# download
ipfs get QmbvdJ7KgvZiyaqHw5QtQxRtUd7pCAdkWWbzuvyKusLGTw --output ./7B
ipfs get QmbvdJ7KgvZiyaqHw5QtQxRtUd7pCAdkWWbzuvyKusLGTw --output ./7B


https://cloudflare-ipfs.com/ipfs/bafykbzaceclprycjpogrb7yckldpkxcayxb7ylzl2mzgem5ydpnxxfi2isap4
