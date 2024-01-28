# Elasticsearch Notes

[Elasticsearch: 权威指南](https://www.elastic.co/guide/cn/elasticsearch/guide/current/index.html)
[Elasticsearch Reference](https://www.elastic.co/guide/en/elasticsearch/reference/current/getting-started.html)

入门| Elasticsearch权威指南
Relational DB -> Databases -> Tables -> Rows -> Columns
Elasticsearch -> Indices   -> Types  -> Documents -> Fields

请尽可能多的使用过滤式查询。
start elasticsearch:
`cd elasticsearch-<version>`
`./bin/elasticsearch` or
`./bin/elasticsearch -d` run it in the background as a daemon

[全文搜索引擎 Elasticsearch 入门教程 - 阮一峰](http://www.ruanyifeng.com/blog/2017/08/elasticsearch.html)
查看当前节点的所有 Index `curl -X GET 'http://localhost:9200/_cat/indices?v'`
get alias `curl -X GET 'http://localhost:9200/p_channel_v1/_alias/?pretty=true'`
列出每个 Index 所包含的 Type `curl 'localhost:9200/_mapping?pretty=true'`
列出某个 Index 下的 Type `curl 'localhost:9200/user-center/_mapping?pretty=true'`
查看映射: `GET /index/_mapping/Type`
新建一个名叫 weather 的 Index `curl -X PUT 'localhost:9200/weather'`
删除这个 Index `curl -X DELETE 'localhost:9200/weather'`
返回所有记录`curl -X GET http://localhost:9200/Index/Type/_search`
Count by type: `curl "10.0.0.29:9200/p_channel_v1/_search?search_type=count&pretty=true" -d '{"aggs":{"count_by_type":{"terms":{"field":"_type"}}}}'`

查看文本是如何被分析的:
`GET /_analyze?analyzer=standard
Text to analyze`

```json
curl -X GET "localhost:9200/_search?explain" -H 'Content-Type: application/json' -d'
{
   "query"   : { "match" : { "tweet" : "honeymoon" }}
}
'
```

设置局域网 IP 访问 ES: `vi config/elasticsearch.yml` -> `network.host: 0.0.0.0`
[kibana URL](http://localhost:5601/app/kibana#/dev_tools/console)

[head 插件](https://github.com/mobz/elasticsearch-head):

```sh
git clone git://github.com/mobz/elasticsearch-head.git
cd elasticsearch-head
npm install
npm run start

open http://localhost:9100/
```

查看head `http://localhost:9200/_plugin/head/`

`curl http://localhost:9200/_cluster/health?pretty`

``` json
PUT /megacorp/employee/1
{
    "first_name" : "John",
    "last_name" :  "Smith",
    "age" :        25,
    "about" :      "I love to go rock climbing",
    "interests": [ "sports", "music" ]
}
```

搜索所有雇员 `GET /megacorp/employee/_search`
查询字符串 （`_query-string_`） 搜索 `GET /megacorp/employee/_search?q=last_name:Smith`
`curl -XGET 'localhost:9200/megacorp/employee/_search?q=last_name:Smith&pretty'`

``` json
GET /megacorp/employee/_search
{
    "query" : {
        "match" : {
            "last_name" : "Smith"
        }
    }
}

#短语搜索
GET /user-center/role/_search
{
    "query": {
        "match_phrase" : {
            "name" : "月下南山"
        }
    }
}
```

模糊搜索

``` json
GET /_search
{
    "query": {
        "wildcard" : { "user" : "ki*y" }
    }
}
```

#### 使用过滤器 filter

[更复杂的搜索](https://www.elastic.co/guide/cn/elasticsearch/guide/cn/_more_complicated_searches.html)
`range` 过滤器 ， 它能找到年龄大于 30 的文档，其中 gt 表示_大于(`_great than`)

```sh
GET /megacorp/employee/_search
{
    "query" : {
        "bool": {
            "must": {
                "match" : {
                    "last_name" : "smith"
                }
            },
            "filter": {
                "range" : {
                    "age" : { "gt" : 30 }
                }
            }
        }
    }
}
```

#### Combining Filters

##### Bool Filter

```sh
{
   "bool" : {
      "must" :     [],
      "should" :   [],
      "must_not" : [],
      "filter":    []
   }
}

* `must`  All of these clauses must match. The equivalent of `AND`.
* `must_not`  All of these clauses must not match. The equivalent of `NOT`.
* `should`  At least one of these clauses must match. The equivalent of `OR`.
* `filter`  Clauses that must match, but are run in non-scoring, filtering mode.

GET /my_store/products/_search
{
   "query" : {
      "constant_score" : {
         "filter" : {
            "bool" : {
              "should" : [
                 { "term" : {"price" : 20}},
                 { "term" : {"productID" : "XHDK-A-1293-#fJ3"}}
              ],
              "must_not" : {
                 "term" : {"price" : 30}
              }
           }
         }
      }
   }
}
```

##### Nesting Boolean Queries

```sh
SELECT document
FROM   products
WHERE  productID      = "KDKE-B-9947-#kL5"
  OR (     productID = "JODL-X-1937-#pV7"
       AND price     = 30 )

We can translate it into a pair of nested bool filters:
GET /my_store/products/_search
{
   "query" : {
      "constant_score" : {
         "filter" : {
            "bool" : {
              "should" : [
                { "term" : {"productID" : "KDKE-B-9947-#kL5"}},
                { "bool" : {
                  "must" : [
                    { "term" : {"productID" : "JODL-X-1937-#pV7"}},
                    { "term" : {"price" : 30}}
                  ]
                }}
              ]
           }
         }
      }
   }
}

```

##### Finding Multiple Exact Values

```sh
{
        "terms" : {
        "price" : [20, 30]
    }
}
```

##### [Ranges](https://www.elastic.co/guide/en/elasticsearch/guide/current/_ranges.html)

* `gt`: > greater than
* `lt`: < less than
* `gte`: >= greater than or equal to
* `lte`: <= less than or equal to

```sh
SELECT document
FROM   products
WHERE  price BETWEEN 20 AND 40

GET /my_store/products/_search
{
    "query" : {
        "constant_score" : {
            "filter" : {
                "range" : {
                    "price" : {
                        "gt" : 20,
                        "lt"  : 40
                    }
                }
            }
        }
    }
}
```

Ranges on Dates:

```sh
"range" : {
    "timestamp" : {
        "gt" : "2014-01-01 00:00:00",
        "lt" : "2014-01-07 00:00:00"
    }
}
```

##### [Dealing with Null Values](https://www.elastic.co/guide/en/elasticsearch/guide/current/_dealing_with_null_values.html)

`exists`: is
`missing`: is not

```sh
SELECT tags
FROM   posts
WHERE  tags IS NOT NULL

GET /my_index/posts/_search
{
    "query" : {
        "constant_score" : {
            "filter" : {
                "exists" : { "field" : "tags" }
            }
        }
    }
}


SELECT tags
FROM   posts
WHERE  tags IS NULL

GET /my_index/posts/_search
{
    "query" : {
        "constant_score" : {
            "filter": {
                "missing" : { "field" : "tags" }
            }
        }
    }
}
```

#### [Multifield Search](https://www.elastic.co/guide/en/elasticsearch/guide/current/multi-query-strings.html)

```sh
GET /_search
{
  "query": {
    "bool": {
      "should": [
        { "match": { "title":  "War and Peace" }},
        { "match": { "author": "Leo Tolstoy"   }}
      ]
    }
  }
}
```

#### [Best Fields](https://www.elastic.co/guide/en/elasticsearch/guide/current/_best_fields.html#dis-max-query)

`dis_max` Query
Instead of the bool query, we can use the `dis_max` or Disjunction Max Query. Disjunction means or (while conjunction means and) so the Disjunction Max Query simply means return documents that match any of these queries, and return the score of the best matching query

### [分析](https://www.elastic.co/guide/cn/elasticsearch/guide/cn/_analytics.html)

[ElasticSearch 的 聚合（Aggregations）](https://www.cnblogs.com/ghj1976/p/5311183.html)
Elasticsearch 有一个功能叫聚合（aggregations）, 与 SQL 中的 GROUP BY 类似但更强大。

Metrics
`sum`, `avg`, `min`, `mean`, `max`

```sh
SQL: group by interests
GET /megacorp/employee/_search
{
  "aggs": {
    "all_interests": {
      "terms": { "field": "interests" }
    }
  }
}


GET /megacorp/employee/_search
{
    "aggs" : {
        "all_interests" : {
            "terms" : { "field" : "interests" },
            "aggs" : {
                "avg_age" : {
                    "avg" : { "field" : "age" }
                }
            }
        }
    }
}

不关心搜索结果时，使用search_type=count，它的速度更快
GET /cars/transactions/_search?search_type=count
{
    "aggs" : {
        "colors" : {
            "terms" : {
              "field" : "interests"
            }
        }
    }
}
```

`term` 查询会查找我们指定的精确值
最为常用的 `term` 查询， 可以用它处理数字（numbers）、布尔值（Booleans）、日期（dates）以及文本（text）

`curl -X POST 'http://example.com/p_channel_v2/device_roi_statistics/_search?pretty'  -d '{"query":{"bool":{"must":{"term":{"app_key":"UnmYb2"}},"should":[{"term":{"android_id":"5dbeb56a02d3033c"}},{"term":{"android_id":"195a35544d1fd132"}}],"minimum_should_match":"1"}},"aggregations":{"revenue_1a":{"sum":{"field":"revenue_1"}}}}'`

```sh
{
  "query": {
    "bool": {
      "must": {
        "term": {
          "app_key": "UnmYb2"
        }
      },
      "should": [
        {
          "term": {
            "android_id": "5dbeb56a02d3033c"
          }
        },
        {
          "term": {
            "android_id": "195a35544d1fd132"
          }
        }
      ],
      "minimum_should_match": "1"
    }
  },
  "aggregations": {
    "revenue_1a": {
      "sum": {
        "field": "revenue_1"
      }
    }
  }
}

```

`constant_score` 查询以非评分模式来执行
