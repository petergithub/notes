[TOC]

## Recent
MongoDB单文档大小限制是16M
MongoDB limits the data size of individual BSON objects/documents. At the time of this writing the limit is 16MB.并不是技术上的限制，只是一个规定而已

export and import data collection
`mongoexport --host <hostname> --port 27017 --db test  --collection <collectionName> --out <filename>.json`
`mongoimport --file <filename>.json`

options:
  -h [ --host ] arg         mongo host to connect to ( <set name>/s1,s2 for
  -u [ --username ] arg     username
  -p [ --password ] arg     password
  -d [ --db ] arg           database to use
  -c [ --collection ] arg   collection to use (some commands)
  -q [ --query ] arg        query filter, as a JSON string
  -o [ --out ] arg          output file; if not specified, stdout is used

## Commands
### Start Server & Connection

`mongod`	To start MongoDB using all defaults  
`mongod --dbpath /path/to/mongodb/data/ --auth`	To start MongoDB  

`mongo <host>:<port>/<dbName>`  Connect to mongo   
`--quiet` Suppress MongoDB shell version  
`--eval` execute command
`--nodb` start mongo client without using a database

`mongo -u <user> -p <password>  127.0.0.1:27017/DATABASE_NAME`  
`mongo -u <user> -p <password>  127.0.0.1:27017/DATABASE_NAME --quiet script.js`  
`mongo -u <user> -p <password>  127.0.0.1:27017/DATABASE_NAME --quiet --eval 'printjson(db.currentOp())' | less`  
`mongo -u <user> -p <password>  127.0.0.1:27017/DATABASE_NAME --quiet --eval 'db.users.find({a:'b'}).pretty().shellPrint()' | less`  
`mongo -u <user> -p <password>  127.0.0.1:27017/DATABASE_NAME --quiet --eval 'printjson(db.adminCommand('listDatabases'))' | less`  



### Basic Commands
runCommand syntax: `db.runCommand()`  
dropping a collection(drop database) `db.DATABASE_NAME.drop()` or `db.runCommand({"drop" : "DATABASE_NAME"})`   
`> help`  
`load("/path/to/script.js")`  

#### format
To format the printed result, you can add the .pretty() to the operation: `db.myCollection.find().pretty()`  
```
// print a result collection  

function printResult (r) {
  print(tojson(r))
}

db.foo.find().forEach(printResult)
```

```
// print begin and end time of the command
var date1 = new Date()
print ("begin " + tojson(date1.toLocaleString()))

var result = db.getCollectionNames()
print (tojson(result))

var date1 = Date()
print ("end " + tojson(date1.toLocaleString()))
~          
```

#### db
查看当前正在使用的数据库 `show dbs` == `db.getMongo().getDBs()`   
查看当前正在使用的数据库 `db`  
切换数据库 `use DATABASE_NAME` == `db.getSisterDB("DATABASE_NAME")`    
删除数据库 删除数据库首先使用use命令切换到要删除的数据库，然后使用`db.dropDatabase()`  
`db.stats()`

#### collection
`show collections` == `show tables` == `db.getCollectionNames()`
查看单个集合，可以使用 `db.getCollection("COLLECTION_NAME")`   
`db.collectionName.findOne()`  
`db.getCollection('COLLECTION_NAME').count()`  
创建集合 `db.createCollection(COLLECTION_NAME, options)`
重命名 `db.COLLECTION_NAME.renameCollection("NEW_NAME")`
集合的删除 `db.COLLECTION_NAME.drop()`  

#### query
`db.COLLECTION_NAME.find({key1:value1, key2:value2})`  
`db.COLLECTION_NAME.findOne({key1:value1},{key2:0, key3:1})`	0, exclude key2; 1, display key3  
limit()指定查询结果数量  `db.COLLECTION_NAME.find().limit(NUMBER)`  
skip()指定查询偏移量 `db.COLLECTION_NAME.find().limit(NUMBER).skip(NUMBER)`  
sort()实现查询结果排序 `db.COLLECTION_NAME.find().sort({KEY:1})` 排序方式为可选值为：1和-1，1表示使用升序排列，-1表示降序排序  

### Query Criteria 查询条件
`"$lt","$lte","$gt","$gte", "$ne"`分别对应`<,<=,>,>=,<>`  
查询birthday日期是`1990-1-1`之前的人 `db.users.find({"birthday":{"$lt":new Date("1990/01/01")}})`  
查询`age >=18  <=30`: `db.users.find({"age":{"$gte":18,"$lte":30}})`   
`db.users.find({"name":{"$ne":"refactor1"}})`  
`db.collections.findOne({"gateWayPayInfo.gateWayPayorderInfo.outOrderId" : "20150809173033000000000000005503"});`  

#### 使用"$in","$nin","$or", "$not"查询
- 使用`"$in"`, `"$nin"`
 查询出pageViews为10000,20000的数据: `db.users.find({pageViews:{"$in":[10000,20000]}})`  

- 使用`"$or"`
查询出pageViews是10000,20000或url是http://www.cnblogs.com/refactor的文档:

```

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

#### 条件句的规则
在查询中,"$lt"在内层文档,在更新中"$inc" 是外层文档的键.
条件句是内层文档的键,修改器是外层文档的键.
可对一个键应用多个条件,但一个键不能对应多个更新修改器.

### Type-Specific Queries
#### null
`null`匹配自身,同时匹配"不存在的" not only matches itself but also matches “does not exist.”

```

	> db.c.find({"y" : null})
	{ "_id" : ObjectId("4ba0f0dfd22aa494fd523621"), "y" : null }
	> db.c.find({"z" : null})
	{ "_id" : ObjectId("4ba0f0dfd22aa494fd523621"), "y" : null }
	{ "_id" : ObjectId("4ba0f0dfd22aa494fd523622"), "y" : 1 }
	{ "_id" : ObjectId("4ba0f148d22aa494fd523623"), "y" : 2 }
```

If we only want to find keys whose value is null  
`> db.c.find({"z" : {"$in" : [null], "$exists" : true}})`

#### Regular Expressions
MongoDB uses the Perl Compatible Regular Expression (PCRE) library to match regular
expressions  
use a regular expression to do case insensitive matching, Joe or joe  
`> db.users.find({"name" : /joe/i})`

If we want to match not only various capitalizations of joe, but also joey  
`> db.users.find({"name" : /joey?/i})`

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

#### Querying on Embedded Documents
have a document that looks like this:
```

	{
		"name" : {
			"first" : "Joe",
			"last" : "Schmoe"
		},
		"age" : 45
	}
```
Query: `db.people.find({"name.first" : "Joe", "name.last" : "Schmoe"})`  

### $where Queries


### Index
Find all indexes: `db.system.indexes.find()`  
Setup index(Key 值为要创建的索引字段，1为指定按升序创建索引，如果你想按降序来创建索引指定为-1即可): `db.COLLECTION_NAME.ensureIndex({KEY:1})`  
ensureIndex() 方法中你也可以设置使用多个字段创建索引（关系型数据库中称作复合索引）: `db.COLLECTION_NAME.ensureIndex({"title":1,"description":-1})`  
创建索引时加background:true 的选项，让创建工作在后台执行 `db.COLLECTION_NAME.ensureIndex({open: 1, close: 1}, {background: true})`  
重建索引 `db.COLLECTION_NAME.reIndex()`  

查看集合中的索引: `db.COLLECTION_NAME.getIndexes()`  
查看集合中的索引大小`db.COLLECTION_NAME.totalIndexSize()`  

删除集合中的某一个索引: `db.COLLECTION_NAME.dropIndex("INDEX-NAME")` or `db.COLLECTION_NAME.dropIndex({x: 1, y: -1})`  
删除所有索引 `db.COLLECTION_NAME.dropIndexes();`

### Update
post = {title:title}
db.blog.insert(post)
db.blog.find()
post.comment=[]
db.blog.update({"title":"title"},post)

joe={"name","joe"}
joe.relationships={"friends":2,"enemies":3}
db.users.insert(joe)
joe = db.users.findOne();
joe.username=joe.name;
delete joe.name
db.users.update({"name":"joe"},joe)
db.users.update({"name":"joe"},{"$set":{"age":20}})

`{ "_id" : ObjectId("55b61a2634a254ddb211bf32"), "relationships" : { "friends" : 2, "enemies" : 3 }, "username" : "joe" }`

### Dump & Restore
mongodump -p 31000	mongodump will create a dump
mongorestore
./bin/mongorestore -h 127.0.0.1:27017 -d dbName /path/to/dbName

### Advanced commands
getLastError
查看最大连接数
`db.serverStatus().connections`

### replication replSet
mongod --replSet replSetName -f mongod.conf --fork

#### Enable Auth
##### Create the user administrator
```
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
```

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

### Command
`mongotop -u <user> -p <password> -h 127.0.0.1:27017 --authenticationDatabase admin`  
`mongostat -u <user> -p <password> -h 127.0.0.1:27017 --authenticationDatabase admin`  
[mongottop](https://docs.mongodb.com/manual/reference/program/mongotop/ )  
[mongostat](https://docs.mongodb.com/manual/reference/program/mongostat/#fields )  


`db.runCommand( { serverStatus: 1 } )`  
`db.COLLECTION_NAME.stats()`  

`db.currentOp()` Seeing the Current Operations 寻找有问题的操作 [currentOp](https://docs.mongodb.com/manual/reference/command/currentOp )  
`db.killOp(<opid>)` get opid from `db.currentOp()`  

#### [explain](https://docs.mongodb.com/manual/reference/explain-results/ )
`db.collection.find().explain()`  
方法的参数如下：  
    verbose：{String}，可选参数。指定冗长模式的解释输出，方式指定后会影响explain()的行为及输出信息。  
    可选值有："queryPlanner"、"executionStats"、"allPlansExecution"，默认为"queryPlanner"
[执行计划函数explain](https://itbilu.com/database/mongo/V1WFKy-Cl.html )

```

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


#### [Database Profiling](https://docs.mongodb.com/manual/administration/analyzing-mongodb-performance/#database-profiling )
`db.getProfilingLevel()` 查看当前的分析级别  
`db.setProfilingLevel(1)`  
`db.setProfilingLevel(2)` Level 2 means “profile everything.”  
`db.system.profile.find( { millis : { $gt : 5 } } )`  
`db.system.profile.find().pretty()`  

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
