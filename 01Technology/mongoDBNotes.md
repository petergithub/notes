# Mongo

## Recent

MongoDB单文档大小限制是16M
MongoDB limits the data size of individual BSON objects/documents. At the time of this writing the limit is 16MB.并不是技术上的限制，只是一个规定而已

## Commands

### Start Server & Connection

`mongod` To start MongoDB using all defaults  
`mongod --dbpath /path/to/mongodb/data/ --auth` To start MongoDB  

`mongo <host>:<port>/<dbName>`  Connect to mongo
`--quiet` Suppress MongoDB shell version  
`--eval` execute command
`--nodb` start mongo client without using a database

`mongo mongodb://user:pwd@localhost:27017/DATABASE_NAME?authSource=admin`
`mongo -u <user> -p <password>  127.0.0.1:27017/DATABASE_NAME --authenticationDatabase=admin`
`mongo -u <user> -p <password>  127.0.0.1:27017/DATABASE_NAME --quiet script.js`  
`mongo -u <user> -p <password>  127.0.0.1:27017/DATABASE_NAME --quiet --eval 'printjson(db.currentOp())' | less`  
`mongo -u <user> -p <password>  127.0.0.1:27017/DATABASE_NAME --quiet --eval 'db.users.find({a:'b'}).pretty().shellPrint()' | less`  
`mongo -u <user> -p <password>  127.0.0.1:27017/DATABASE_NAME --authenticationDatabase=admin --quiet --eval 'printjson(db.adminCommand('listDatabases'))' | less`  

### Basic Commands

runCommand syntax: `db.runCommand()`  
dropping a collection(drop database) `db.DATABASE_NAME.drop()` or `db.runCommand({"drop" : "DATABASE_NAME"})`
`> help`  
`load("/path/to/script.js")`  
Getting timestamp from mongodb id `ObjectId("507c7f79bcf86cd7994f6c0e").getTimestamp()`

#### format

To format the printed result, you can add the .pretty() to the operation: `db.myCollection.find().pretty()`  

``` js
// print a result collection  

function printResult (r) {
  print(tojson(r))
}

db.foo.find().forEach(printResult)
```

``` js
// print begin and end time of the command
var date1 = new Date()
print ("begin " + tojson(date1.toLocaleString()))

var result = db.getCollectionNames()
print (tojson(result))

var date1 = Date()
print ("end " + tojson(date1.toLocaleString()))
```

#### db

查看数据库 `show dbs` == `db.getMongo().getDBs()`
查看当前正在使用的数据库 `db`  
切换数据库 `use DATABASE_NAME` == `db.getSisterDB("DATABASE_NAME")`
删除数据库 删除数据库首先使用`use`命令切换到要删除的数据库，然后使用`db.dropDatabase()`  
`db.stats()`

`db.copyDatabase(fromdb, todb, fromhost, username, password, mechanism)` Copies a database either from one mongod instance to the current mongod instance or within the current mongod.

#### collection

`show collections` == `show tables` == `db.getCollectionNames()`
查看单个集合，可以使用 `db.getCollection("COLLECTION_NAME")`
`db.collectionName.findOne()`  
`db.getCollection('COLLECTION_NAME').count()`  
`db.collection_name.distinct(field,query,options)`
创建集合 `db.createCollection(COLLECTION_NAME, options)`
重命名 `db.COLLECTION_NAME.renameCollection("NEW_NAME")`
集合的删除 `db.COLLECTION_NAME.drop()`  
duplicate collection in the same database
    fastest: `mongodump -d db -c source_collection`, `mongorestore -d db -c targetcollection --dir=dump/<db>/<target_collection.bson>`
    fast: `db.source_collection.aggregate([{ $match: {} }, { $out: "target_collection" }])`
    slow: `db.getCollection('source_collection').find().forEach(function(docs){ db.getCollection('target_collection').insert(docs); })`
    slow, MongoDB 4.0 or earlier versions: `db.collection.copyTo(newCollection)`
copy a collection from one database to new_database `db.collection_name.find().forEach(function(d){ db.getSiblingDB('new_database')['collection_name'].insert(d); });`

#### query

`db.COLLECTION_NAME.find({key1:value1, key2:value2}, { field1: <value>, field2: <value> ... })`  [db.collection.find()](https://docs.mongodb.com/manual/reference/method/db.collection.find/)
projection `db.getCollection('users').find({"id" : "5a153558e8ac2b5c7a8052da"}, {"id":0,"custom_weight":1})` `1: display; 0: hide`

Return documents where the tags field matches the specified array exactly, including the order: `db.inventory.find( { tags: [ "red", "blank" ] } )`
To specify fields to return: `db.COLLECTION_NAME.findOne({key1:value1}, {key2:0, key3:1})` 0, exclude key2; 1, display key3  
limit()指定查询结果数量  `db.COLLECTION_NAME.find().limit(NUMBER)`  
skip()指定查询偏移量 `db.COLLECTION_NAME.find().limit(NUMBER).skip(NUMBER)`  
sort()实现查询结果排序 `db.COLLECTION_NAME.find().sort({KEY:1})` 排序方式为可选值为：1和-1，1表示使用升序排列，-1表示降序排序  

db.collection.remove({query})

### Query Criteria 查询条件

`"$lt","$lte","$gt","$gte", "$ne"`分别对应`<,<=,>,>=,<>`  
查询birthday日期是`1990-1-1`之前的人 `db.users.find({"birthday":{"$lt":new Date("1990/01/01")}})`  
查询`age >=18  <=30`: `db.users.find({"age":{"$gte":18,"$lte":30}})`
`db.users.find({"name":{"$ne":"refactor1"}})`  
`db.collections.findOne({"gateWayPayInfo.gateWayPayorderInfo.outOrderId" : "20150809173033000000000000005503"});`
`db.inventory.find( { qty: { $ne: 20 } } )`
`db.notes.find({"title": {'$regex': "夏天来啦", "$options": 'i'})`

search with `special_||vertial_bar`:
        `db.notes.find({"title" : {"$regex":"special_\\|\\|vertial_bar"}})` or
        `db.notes.find({"title" : {"$regex":"special_||vertial_bar".replace(/[-[\]{}()*+?.,\\/^$|#\s]/g, "\\$&")}})`

`db.getCollection('notes_records').distinct("updated", {"id" : "5ed4d78c0000000001001be8"})`

`db.monthlyBudget.find( { $expr: { $gt: [ "$spent" , "$budget" ] } } )`

#### 使用"$in","$nin","$or", "$not", $and 查询

- 使用`"$in"`, `"$nin"`
 查询出pageViews为10000,20000的数据: `db.users.find({pageViews:{"$in":[10000,20000]}})`  

- 使用`"$or"`
查询出pageViews是10000,20000或url是`http://www.cnblogs.com/refactor`的文档:

``` js
db.users.find(
　　{
　　　　"$or":
　　　　[
　　　　　　{"pageViews":{"$in":[10000,20000]}},
　　　　　　{"url":"http://www.cnblogs.com/refactor"}
　　　　]
　　}
)
```

- 使用`"$not"` "$not"可以用在任何条件之上
查询出`id`取模后值不为1和5的文档: `db.users.find({"id":{"$not":{"mod":[1,5]}}})`  
`db.inventory.find( { price: { $not: { $eq: null } } } )`

#### 条件句的规则

在查询中,"$lt"在内层文档,在更新中"$inc" 是外层文档的键.
条件句是内层文档的键,修改器是外层文档的键.
可对一个键应用多个条件,但一个键不能对应多个更新修改器.

#### $inc

The $inc operator increments a field by a specified value and has the following form:
`{ $inc: { <field1>: <amount1>, <field2>: <amount2>, ... } }`

### Type-Specific Queries

#### null

`null`匹配自身,同时匹配"不存在的" not only matches itself but also matches “does not exist.”

``` js
> db.c.find({"y" : null})
{ "_id" : ObjectId("4ba0f0dfd22aa494fd523621"), "y" : null }
> db.c.find({"z" : null})
{ "_id" : ObjectId("4ba0f0dfd22aa494fd523621"), "y" : null }
{ "_id" : ObjectId("4ba0f0dfd22aa494fd523622"), "y" : 1 }
{ "_id" : ObjectId("4ba0f148d22aa494fd523623"), "y" : 2 }
```

If we only want to find keys whose value is null  
`db.c.find({"z" : {"$in" : [null], "$exists" : false}})` or `db.inventory.find( { price: { $eq: null } } )`
find documents whose value is not null
`db.c.find({"z" : {"$in" : [null], "$exists" : true}})` or `db.inventory.find( { price: { $not: { $eq: null } } } )`

#### Regular Expressions

模糊查询
`select * from student where  name like '%joe%'` 对应 `db.student.find( {name: {$regex:/joe/}})`
`select * from student where  name regexp 'joe'` 对应 `db.student.find( {name:/joe/})`

MongoDB uses the Perl Compatible Regular Expression (PCRE) library to match regular
expressions  
use a regular expression to do case insensitive matching, Joe or joe  
`> db.users.find({"name" : /joe/i})`

If we want to match not only various capitalizations of joe, but also joey  
`> db.users.find({"name" : /joey?/i})`

`db.test.find({$or: [{platform_user_id: {'$regex': "123031", "$options": 'i'}}, {nickname: {'$regex': "123031", "$options": 'i'}}]})`

##### options

包括 i, m, x以及S四个选项，其含义如下

- `i` 忽略大小写，`{<field>{$regex/pattern/i}}`，设置i选项后，模式中的字母会进行大小写不敏感匹配。
- `m` 多行匹配模式，`{<field>{$regex/pattern/,$options:'m'}`，m选项会更改^和$元字符的默认行为，分别使用与行的开头和结尾匹配，而不是与输入字符串的开头和结尾匹配。
- `x` 忽略非转义的空白字符，`{<field>:{$regex:/pattern/,$options:'m'}`，设置x选项后，正则表达式中的非转义的空白字符将被忽略，同时井号(#)被解释为注释的开头注，只能显式位于option选项中。
- `s` 单行匹配模式`{<field>:{$regex:/pattern/,$options:'s'}`，设置s选项后，会改变模式中的点号(.)元字符的默认行为，它会匹配所有字符，包括换行符(\n)，只能显式位于option选项中。

#### Querying Arrays

Arrays are always 0-indexed  
`> db.food.insert({"fruit" : ["apple", "banana", "peach"]})`  
query `db.food.find({"fruit" : "banana"})`  

##### $all 如果需要多个元素来匹配数组,就要用"$all"

db.users.insert({"userName":"refactor",emails:["295240648@qq.com","295240648@163.com","295240648@126.com"]})
db.users.insert({"userName":"refactor",emails:["295240648@qq.com","295240648@126.com","295240648@111.com"]})
db.users.insert({"userName":"refactor",emails:["295240648@126.com","295240648@163.com","295240648@111.com"]})

要找到邮箱有"295240648@163.com"又有"295240648@126.com",顺序无关紧要的文档
db.users.find(
　　{
　　　　"emails":
　　　　{
　　　　　　"$all":
　　　　　　[
　　　　　　　　"295240648@163.com",
　　　　　　　　"295240648@126.com"
　　　　　　]
　　　　}
　　}
)

要是只对一个元素的数组使用"$all"就和不用"$all"是一样的,如
db.users.find({"emails":{"$all":["295240648@126.com"]}})
db.users.find({"emails":"295240648@126.com"})
效果是一样的.

##### $size

query for arrays of a given size: `db.food.find({"fruit" : {"$size" : 3}})`  

##### $slice operator

return the first 10 comments: `db.blog.posts.findOne(criteria, {"comments" : {"$slice" : 10}})`
Alternatively, if we wanted the last 10 comments, we could use -10: `db.blog.posts.findOne(criteria, {"comments" : {"$slice" : -10}})`  
return pages in the middle of the results by taking an offset and the number of elements to return:
`db.blog.posts.findOne(criteria, {"comments" : {"$slice" : [23, 10]}})`  

##### $elemMatch

use "$elemMatch" to force MongoDB to compare both clauses with a single array element:  
`db.test.find({"x" : {"$elemMatch" : {"$gt" : 10, "$lt" : 20}})`  

###### [$elemMatch projection](https://docs.mongodb.com/manual/reference/operator/projection/elemMatch/)

The `$elemMatch` operator limits the contents of an `<array>` field from the query results to contain only the first element matching the `$elemMatch` condition.

`db.getCollection('keyword_search_result').find({ "keyword" : "身材",notes:{$elemMatch:{"id" : "5efdbd6000000000010031d0"}}},{"notes.index":1, "notes": {$elemMatch: {id: "5e92b2630000000001000b0b"}}, "notes.id":1})`

#### Querying on Embedded Documents

have a document that looks like this:

``` js
{
        "name" : {
                "first" : "Joe",
                "last" : "Schmoe"
        },
        "age" : 45
}
```

Query: `db.people.find({"name.first" : "Joe", "name.last" : "Schmoe"})`  

##### Query an Array of Embedded Documents

[Query for a Document Nested in an Array](https://docs.mongodb.com/manual/tutorial/query-array-of-documents/)

`db.test.find({"products.product_id": {$exists: true}}, {products:1}).count()`
`db.test.find({"products.product_id": 20}, {products:1}).count()`
`db.test.find({"products.0.product_id": 20})` 查找数组内第一个元素的 product_id =20
`db.test.find({"products.1.product_id": 20})` 查找数组内第二个元素的 product_id =20

### $where Queries

### aggregate

[Aggregation](https://docs.mongodb.com/manual/core/aggregation-pipeline/)

``` js
// group by 数据, 多于一个的数据
db.coll.aggregate([
        {$match:{}},
        { $group: {_id: "$uid",
            count: { $sum: NumberInt(1)}}},
        {$sort: {"count": -1}}
    ])

db.coll.aggregate([
    {$match:
        {$or: [
            {'note_id': '5ea269ec00000000010082a5'},
            {'crawled_at': {'$gte': new ISODate("2020-06-18 00:00:00+08:00"), '$lt': new ISODate("2020-06-18 00:00:00+08:00")}}
            ]
        }
    },
    {$group:
        {'_id': '$note_id', 'liked_count': {$sum: '$liked_count'},
            'collected_count': {$sum: '$collected_count'}, 'liked_and_collected': {$sum: '$liked_and_collected'},
            'comments_count': {$sum: '$comments_count'}, 'shared_count': {$sum: '$shared_count'}, 'fans_count': {$sum: '$fans_count'}
        }
    }
    ])

# group by mutiple fileds
db.coll.aggregate([
        {$match: {"status": {$in: [0,1,2]}
                 }
        },
        { $group: {_id: {
            medium_id: "$medium_id",
            status: "$status"
            },
            count: { $sum: NumberInt(1)}}},
        {$sort: {"_id.status": 1, "count": 1}}
    ])

# 平均值
db.getCollection('notes').aggregate(
[
    {$match:
        {"id" :
            {$in:[
                "5f0059080000000001002fd5",
                "5efc62a000000000010026b1",
                "5ef9faf9000000000100218b",
                "5eeb42d00000000001001759",
                "5ee49e510000000001000940",
                "5ee0a98400000000010048a0"
            ]}
        }
    },
        {$group:
            {   _id: "$user_id",
                liked_count_avg: { $avg: "$liked_count" },
                collected_countavg: { $avg: "$collected_count" }
            }
        }

    ])

// # 中位数 mid median 奇数个元素时:
count = db.coll.count();
db.coll.find().sort( {"a":1} ).skip(count / 2 - 1).limit(1);

// # 中位数 mid median 偶数个元素时:
count = db.coll.count();
db.coll.find().sort( {"a":1} ).skip(count / 2 - 1).limit(2);

// # join 操作  
// https://docs.mongodb.com/manual/reference/operator/aggregation/lookup/
SELECT *, <output array field>
FROM collection
WHERE <output array field> IN (SELECT *
                               FROM <collection to join>
                               WHERE <foreignField>= <collection.localField>);

{
   $lookup:
     {
       from: <collection to join>,
       localField: <field from the input documents>,
       foreignField: <field from the documents of the "from" collection>,
       as: <output array field>
     }
}

# select operator_id, user_id, follow_users.fans
    from users_operator_follow, users
    where operator_id= 1253 and follow_status = 1 and user_id = users.id
db.users_operator_follow.aggregate([{$match: {"operator_id" : 1253, "follow_status" : 1}},
   {
     $lookup:
       {
         from: "users",
         localField: "user_id",
         foreignField: "id",
         as: "follow_users"
       }
  },
  {$project: {"operator_id" : 1, "user_id" : 1, "follow_status" : 1, "follow_users":{"id" : 1,"fans" : 1,"follows" : 1}}}
])



SELECT *, <output array field>
FROM collection
WHERE <output array field> IN (SELECT <documents as determined from the pipeline>
                               FROM <collection to join>
                               WHERE <pipeline> );
{
   $lookup:
     {
       from: <collection to join>,
       let: { <var_1>: <expression>, …, <var_n>: <expression> },
       pipeline: [ <pipeline to execute on the collection to join> ],
       as: <output array field>
     }
}

// 根据表达式排序
db.notes.aggregate([
    {$match:{ kind:1,
        "time_put_in_format": {'$gte': ISODate("2020-06-27T20:00:00.000+08:00"), '$lte': ISODate("2020-07-27T00:00:00.000+08:00")},
         $expr: {$and:[
                    {$gt: [{$subtract: ["$liked_and_collected", "$custom_put_in_liked_and_collected"]}, 100]} ,
                    {$lte: [{$subtract: ["$liked_and_collected", "$custom_put_in_liked_and_collected"]}, 1000]} ,
               ]
           }
    }},
    {$project:{
        'id':1,'time_put_in_format':1,'liked_and_collected':1, 'custom_put_in_liked_and_collected':1,
        'subtract_liked_and_collected': {$subtract: ["$liked_and_collected", "$custom_put_in_liked_and_collected"]}
        }
    },
    {$sort:{"liked_and_collected":1, "substract":-1}
    }
])


```

### Index

Find all indexes: `db.system.indexes.find()`  
Setup index(Key 值为要创建的索引字段，1为指定按升序创建索引，如果你想按降序来创建索引指定为-1即可): `db.COLLECTION_NAME.createIndex({KEY:1}, {name:INDEX_NAME})`  
createIndex() 方法中你也可以设置使用多个字段创建索引（关系型数据库中称作复合索引）: `db.COLLECTION_NAME.createIndex({"title":1,"description":-1})`  
创建索引时加background:true 的选项，让创建工作在后台执行 `db.COLLECTION_NAME.createIndex({open: 1, close: 1}, {background: true})`  
重建索引 `db.COLLECTION_NAME.reIndex()`  
创建唯一索引 `db.COLLECTION_NAME.createIndex( { "user_id": 1 }, { unique: true } )`

查看集合中的索引: `db.COLLECTION_NAME.getIndexes()`  
查看集合中的索引大小`db.COLLECTION_NAME.totalIndexSize()`  

To list all indexes on all collections in a database, you can use the following operation in the mongo shell:

``` shell
db.getCollectionNames().forEach(function(collection) {
   indexes = db[collection].getIndexes();
   print("Indexes for " + collection + ":");
   printjson(indexes);
});
```

删除集合中的某一个索引: `db.COLLECTION_NAME.dropIndex("INDEX-NAME")` or `db.COLLECTION_NAME.dropIndex({x: 1, y: -1})`  
删除所有索引 `db.COLLECTION_NAME.dropIndexes();`

### Update

```json
//https://docs.mongodb.com/manual/reference/method/db.collection.update
db.collection.update(
   <query>,
   <update>,
   {
     upsert: <boolean>,
     multi: <boolean>,
     writeConcern: <document>,
     collation: <document>,
     arrayFilters: [ <filterdocument1>, ... ],
     hint:  <document|string>        // Available starting in MongoDB 4.2
   }
)
```

post = {title:title}
db.blog.insert(post)
db.blog.find()
post.comment=[]
db.blog.update({"title":"title"},post)

`db.getCollection('operator').insert({created: Date(), updated:ISODate()})`  created 是字符串, updated 是 `ISODate("2020-09-11T14:09:38.639+08:00")`

joe={"name","joe"}
joe.relationships={"friends":2,"enemies":3}
db.users.insert(joe)
joe = db.users.findOne();
joe.username=joe.name;
delete joe.name
db.users.update({"name":"joe"},joe)
db.users.update({"name":"joe"},{"$set":{"age":20}})

更新多个文档: `db.tasks.update({}, {$set:{"mode":"0"}},{multi:true})`
Rename a Field `db.students.updateMany( {}, { $rename: { <field1>: <newName1>, <field2>: <newName2> } } )`

```js
//replace substring in mongodb document
db.coll.find({"platform_user_id": {'$regex': "oldString", "$options": 'i'}}).forEach(function(e,i) {
    e.platform_user_id=e.platform_user_id.replace("oldString","newString");
    db.coll.save(e);
});

// 更新自一个字段
db.target_coll.find({}).forEach(
   function(item){
       db.target_coll.update({"_id":item._id},{$set:{"data_create_time":item.data_createtime}})
   }
)

// update a collection based on another collection
db.target_coll.find().forEach(function (doc1) {
    var doc2 = db.source_coll.findOne({ id: doc1.id }, { name: 1 });
    if (doc2 != null) {
        doc1.name = doc2.name;
        db.target_coll.save(doc1);
    }
});

db.source_coll.find().forEach(
  doc=>
      db.target_coll.update(
        {"_id": doc._id},
        {$set: {"field_to_update": doc.field}}
      )
)
```

#### Drop column delete field $unset

update single: `db.coll.update({filter}, {$unset: {column_name: ""}})`
update all: `db.coll.updateMany({filter}, {$unset: {column_name: ""}})`

#### Convert type of a field

[$type](https://docs.mongodb.com/manual/reference/operator/query/type/#available-types)

``` shell
db.users_operator_follow.find( {operator_id:{$type: "string"}} ).forEach( function (x) { //$type:2 string
  x.operator_id = new NumberInt(x.operator_id); // convert field to NumberInt
  db.users_operator_follow.save(x);
});
```

#### Array update

[`$[<identifier>]`](https://docs.mongodb.com/manual/reference/operator/update/positional-filtered/)

```JavaScript
db.collection.updateMany(
   { <query conditions> },
   { <update operator>: { "<array>.$[<identifier>]" : value } },
   { arrayFilters: [ { <identifier>: <condition> } ] }
)

//documents
{
    "_id" : ObjectId("5f5a01be085a11b1c155f671"),
    "products" : [
        {
            "product_commission_rate" : 20,
            "product_id" : 20,
            "product_name" : "minic充电款体脂秤",
            "product_price" : 80,
            "product_tb_id" : "521066652216"
        }
    ]
}

//sql
db.test.update(
   { },
   { $set: { "products.$[elem].product_tb_id" : "111111" } },
   {
     multi: true,
     arrayFilters: [ { "elem.product_id": 20 } ]
   }
)

db.test.update({"products.product_id": 20}, {$set: {"products.0.product_tb_id" : "111111"}}, {multi:true})
```

### Dump & Restore

mongodump -p 31000 mongodump will create a dump
mongodump -h dbhost -d dbname -o dbdirectory
mongodump -h dbhost -u user -p pwd --authenticationDatabase=admin -d dbname -o dbname_bak

mongorestore
mongorestore -h 127.0.0.1:27017 -d dbName /path/to/dbName
mongorestore -h 127.0.0.1:27017 -u user -p pwd --authenticationDatabase=admin -d dbname dbname_bak

export and import data collection
[mongoexport](https://docs.mongodb.com/v3.6/reference/program/mongoexport/#cmdoption-mongoexport-uri)
`mongoexport --uri 'mongodb://username:pwd@localhost:27017/db?authsource=admin' --type=csv --collection coll --fields _id,name,url --query='{}' --out rec.csv`
`mongoimport --file <filename>.json`

```bash
# export with all keys
keys=`mongo mongodb://username:pwd@localhost:27017/live?authSource=admin --eval "var keys = ''; for(var key in db.coll.findOne()) { keys += key + ','; }; keys;" --quiet`
mongoexport --uri 'mongodb://username:pwd@localhost:27017/live?authSource=admin' --type=csv --collection coll --fields "$keys" --query='{}' --out coll.csv
```

options:
  -h [ --host ] arg         mongo host to connect
  -u [ --username ] arg     username
  -p [ --password ] arg     password
  -d [ --db ] arg           database to use
  -c [ --collection ] arg   collection to use (some commands)
  -q [ --query ] arg        query filter, as a JSON string
  -o [ --out ] arg          output file; if not specified, stdout is used

### Advanced commands

getLastError
查看最大连接数
`db.serverStatus().connections`

### replication replSet

mongod --replSet replSetName -f mongod.conf --fork

#### Enable Auth

##### Create the user administrator

``` js
use admin
db.createUser(
  {
    user: "myUserAdmin",
    pwd: "abc123",
    roles: [ { role: "userAdminAnyDatabase", db: "admin" } ]
  }
)
```

`db.createUser({user: "admin",pwd: "password",roles: [ { role: "root", db: "admin" } ]});`
`db.auth("admin","password");`

##### Re-start the MongoDB instance with access control

`mongod --auth`

##### Connect and authenticate as the user administrator

`mongo --port 27017 -u "myUserAdmin" -p "abc123" --authenticationDatabase "admin"`

##### Create additional users as needed for your deployment

``` js
use test
db.createUser(
        {
        user: "myTester",
        pwd: "xyz123",
        roles: [ { role: "readWrite", db: "test" },
                { role: "read", db: "reporting" } ]
        }
)
```

##### Connect and authenticate as myTester

`mongo --port 27017 -u "myTester" -p "xyz123" --authenticationDatabase "test"`  
`db.auth("myTester","xyz123")`  

## Profile 优化

[MongoDB Performance](https://docs.mongodb.com/manual/administration/analyzing-mongodb-performance)

### Command

`mongotop -u <user> -p <password> -h 127.0.0.1:27017 --authenticationDatabase admin`  
`mongostat -u <user> -p <password> -h 127.0.0.1:27017 --authenticationDatabase admin`  
[mongottop](https://docs.mongodb.com/manual/reference/program/mongotop/ )  
[mongostat](https://docs.mongodb.com/manual/reference/program/mongostat/#fields )  

`db.currentOp()` Seeing the Current Operations 寻找有问题的操作
`db.runCommand( { serverStatus: 1 } )`  
`db.COLLECTION_NAME.stats()`  
`db.killOp(<opid>)` get opid from `db.currentOp()`  
`db.runCommand( { serverStatus: 1, workingSet: 1 } )` collect the statistics about your server and analyze your server stats.
In output of the serverStatus command you should pay attention to:
    mem contains info about the current memory usage (virtual and phyisical i.e. resident)
    workingSet section contains values useful for estimating the size of the working set, which is the amount of data that MongoDB uses actively.
    extra_info - especially the page_faults counter

#### [Database Profiling](https://docs.mongodb.com/manual/administration/analyzing-mongodb-performance/#database-profiling )

`db.getProfilingStatus()` 查看当前的分析级别和慢查询阈值
`db.setProfilingLevel(1, 1000)`  设置分析级别为 1, 并且记录 1000 毫秒以上的慢查询
`db.setProfilingLevel(2)` Level 2 means “profile everything.”  
`db.system.profile.find( {millis: {$gt: 5}})`  获取5ms以上的慢查询记录
`db.system.profile.find().pretty()`  
`db.system.profile.find({millis: {$gt: 500}, ts: {$gt: ISODate("2020-09-25T15:14:29.352+08:00")}, {op:1,ns:1,command:1,millis:1,planSummary:1,ts:1}).sort({millis:-1})`

#### [currentOp](https://docs.mongodb.com/manual/reference/command/currentOp )  

`db.currentOp()` Seeing the Current Operations 寻找有问题的操作
重点关注以下几个字段:
    `opid` 操作的唯一标识符。如果有需要，可以通过db.killOp(opid)直接终止该操作。 
    `secs_running` 表示该操作已经执行的时间，单位为秒。如果该字段返回的值特别大，需要查看请求是否合理。
    `ns` 该操作目标集合。
    `op` 表示操作的类型。通常是查询、插入、更新、删除中的一种。
    `locks` 跟锁相关的信息

`db.currentOp({"active" : true, "secs_running":{$gt: 3}})`

#### 分析MongoDB数据库的慢请求

全表扫描（关键字： COLLSCAN、 docsExamined ）docsExamined的值，可以查看到一个查询扫描了多少文档。该值越大，请求所占用的CPU开销越大。
不合理的索引（关键字： IXSCAN、keysExamined ）keysExamined字段，可以查看到一个使用了索引的查询，扫描了多少条索引。该值越大，CPU开销越大。

#### [explain](https://docs.mongodb.com/manual/reference/explain-results/ )

`db.collection.find().explain()`
`db.collection.explain().aggregate([])`
[Return Information on Aggregation Pipeline Operation](https://docs.mongodb.com/manual/reference/method/db.collection.aggregate/#example-aggregate-method-explain-option)
方法的参数如下：  
    verbose：{String}，可选参数。指定冗长模式的解释输出，方式指定后会影响explain()的行为及输出信息。  
    可选值有："queryPlanner"、"executionStats"、"allPlansExecution"，默认为"queryPlanner"
[执行计划函数explain](https://itbilu.com/database/mongo/V1WFKy-Cl.html )

``` js
> db.COLLECTION_NAME.find({"appkey" : "fnimbzyp1d" , "event" : "active","cdate": 20170614}).explain()
{
"cursor" : "BtreeCursor appkey_1_event_1_cdate_1",
"isMultiKey" : false,
"n" : 6632,
"nscannedObjects" : 6632,
"nscanned" : 6632,
"nscannedObjectsAllPlans" : 6632,
"nscannedAllPlans" : 6632,
"scanAndOrder" : false,
"indexOnly" : false,
"nYields" : 52,
"nChunkSkips" : 0,
"millis" : 414,
"indexBounds" : {
        "appkey" : [
                [
                        "fnimbzyp1d",
                        "fnimbzyp1d"
                ]
        ],
        "event" : [
                [
                        "active",
                        "active"
                ]
        ],
        "cdate" : [
                [
                        20170614,
                        20170614
                ]
        ]
},
"server" : "kickseed:27017",
"filterSet" : false
}
```

`"cursor" : "BtreeCursor appkey_1_event_1_cdate_1"` BtreeCursor means that an index was used
`"n" : 6632` This is the number of documents returned by the query  
`"nscannedObjects" : 6632` This is a count of the number of times MongoDB had to follow an index pointer to the actual document on disk. If the query contains criteria that is not part of the index or requests fields back that aren’t contained in the index, MongoDB must look up the document each index entry points to.  
`"nscanned" : 6632` The number of index entries looked at if an index was used. If this was a table scan, it is the number of documents examined.  

Refer to P100, Using explain() and hint(), MongoDB权威指南第2版 MongoDB The Definitive Guide  

### [Troubleshooting MongoDB 100% CPU load and slow queries](https://medium.com/@igorkhomenko/troubleshooting-mongodb-100-cpu-load-and-slow-queries-da622c6e1339)

#### 1: db.currentOp()

`db.currentOp({secs_running: {$gte: 3}})` return a list of operations in progress that take more than 3 seconds to perform

#### #2: Profiler

The database profiler collects fine grained data to the system.profile collection so you can analyze them later.
`db.setProfilingLevel(1, 1000)` sets the profiling level for the current database to 1 and the slow operation threshold is 1000 milliseconds
`db.getProfilingStatus()`

#### Interpret the results and fix an issue

The most common issue observed in the field is Inefficient execution plan. identify an inefficient plan by looking in the plan summary or by using the [explain(‘executionStats’)](https://docs.mongodb.com/manual/tutorial/analyze-query-plan/)

Each of the above 2 ways provide information about the query plan. The db.currentOp() method provides the planSummary field — a string that contains the query plan to help debug slow queries. The Database Profiler method provides even more data: keysExamined, docsExamined, nreturned, execStats. All these fields provide very useful information that contains the execution statistics of the query operation.)

repeat the query and add ‘explain’ in the end `db.custom_data.find({"application_id" : 36530,"class_name" : "Logs","UniqueId" : "a6f338db7ea728e0"}).explain('executionStats')`

### [MongoDB 性能优化五个简单步骤](http://blog.oneapm.com/apm-tech/183.html )

第一步：找出慢语句

一般来说查询语句太慢和性能问题瓶颈有着直接的关系，所以可以用 MongoDB 的性能分析工具来找出这些慢语句：

db.setProfilingLevel(1, 100);

第二步：使用 explain 分析

通过使用 explain 来对这些慢语句进行诊断。此外还可以 mtools 来分析日志。

第三步：创建索引

分析完之后需要创建新的索引 (index) 来提升查询的性能。别忘了在 MondoDB 中可以在后台创建索引以避免 collections 锁和系统崩溃。

第四步：使用稀疏索引来减少空间占用

如果使用 sparse documents，并重度使用关键字 $exists，可以使用 sparse indexes 来减少空间占用提升查询的性能。

第五步：读写分离

如果读写都在主节点的话，从节点就一直处在空置状态，这是一种浪费。对于报表或者搜索这种读操作来说完全可以在从节点实现，因此要做的是在 connection string 中设置成 secondarypreferred。

小结

这些方法虽然能够起一定的作用，但最主要的目的还是为架构上的提升争取点时间罢了。
