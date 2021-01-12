# [jq Manual](https://stedolan.github.io/jq/manual/)

[A playground for jq 1.6](https://jqplay.org/jq)

``

```bash
# example
> echo '"Hello, world"' |jq .
"Hello, world"

> echo '{"foo": 42, "bar": "less interesting data"}' | jq .
42

> echo '{"code":200,"data": {"list":[{"updated":1},{"updated":3},{"updated":5},{"updated":7}]}}' | jq '.data.list | .[].updated' | head -n 2
1
3

> echo '{"code":200,"data": {"list":[{"updated":1},{"updated":3},{"updated":5},{"updated":7}]}}' | jq .data.list | jq '.[].updated' | head -n 2
1
3

```

## Basic filters

1. Generic Object Index: `.[<string>]`: .["foo"] (.foo is a shorthand version of this, but only for identifier-like strings).
2. Array Index: `.[2]`: -1 referring to the last element
3. Array/String Slice: `.[10:15]`
4. Array/Object Value Iterator: `.[]`
5. Comma: `,`: the same input will be fed into both and the two filters' output value streams will be concatenated in order
6. Pipe: `|`: The | operator combines two filters by feeding the output(s) of the one on the left into the input of the one on the right. It's pretty much the same as the Unix shell's pipe
