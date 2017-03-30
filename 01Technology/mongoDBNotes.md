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
### Basic Commands
`mongod`	To start MongoDB using all defaults
`mongod --dbpath /path/to/mongodb/data/ --auth`	To start MongoDB

`mongo <host>:<port>/<dbName>`  Connect to mongo  
`show dbs`  
`use test`  
`show collections`  
To format the printed result, you can add the .pretty() to the operation: `db.myCollection.find().pretty()`
`db.collectionName.findOne()`  
`db.getCollection('collectionName').count()`  
`db.col.find({key1:value1, key2:value2})`  
`db.col.findOne({key1:value1},{key2:0, key3:1})`	0, exclude key2; 1, display key3

runCommand syntax: `db.runCommand()`
dropping a collection(drop database) `db.collectionName.drop()` or `db.runCommand({"drop" : "collectionName"})`  

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
### Cursors
#### Limits, Skips and Sorts
`db.c.find().limit(3)`  
`db.c.find().skip(3)`  
Sort direction can be 1 (ascending) or −1 (descending).  
`db.c.find().sort({username : 1, age : -1})`  


### Index
Find all indexes:
`db.system.indexes.find()`
Setup index(Key 值为要创建的索引字段，1为指定按升序创建索引，如果你想按降序来创建索引指定为-1即可):
`db.collectionName.ensureIndex({KEY:1})`
ensureIndex() 方法中你也可以设置使用多个字段创建索引（关系型数据库中称作复合索引）:
`db.collectionName.ensureIndex({"title":1,"description":-1})`
创建索引时加background:true 的选项，让创建工作在后台执行
`db.values.ensureIndex({open: 1, close: 1}, {background: true})`

删除索引
删除集合中的某一个索引：
`db.collection.dropIndex({x: 1, y: -1})`
db.collection.dropIndexes();
`db.collection.dropIndexes();`

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

{ "_id" : ObjectId("55b61a2634a254ddb211bf32"), "relationships" : { "friends" : 2, "enemies" : 3 }, "username" : "joe" }

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
use admin
db.createUser(
  {
    user: "myUserAdmin",
    pwd: "abc123",
    roles: [ { role: "userAdminAnyDatabase", db: "admin" } ]
  }
)

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
