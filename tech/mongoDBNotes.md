[TOC]

## Recent
MongoDB单文档大小限制是16M
MongoDB limits the data size of individual BSON objects/documents. At the time of this writing the limit is 16MB.并不是技术上的限制，只是一个规定而已

## Commands
### Basic Commands
show dbs
use test
show collections
db.collectionName.findOne()
db.getCollection('collectionName').count()
db.col.find({key1:value1, key2:value2}).pretty()

#### 查询条件
"$lt","$lte","$gt","$gte"分别对应<,<=,>,>=
查询birthday日期是1990-1-1之前的人 db.users.find({"birthday":{"$lt":new Date("1990/01/01")}})
查询age >=18  <=30: db.users.find({"age":{"$gte":18,"$lte":30}}) 
db.users.find({"name":{"$ne":"refactor1"}})
db.account_check_collections.findOne({"gateWayPayInfo.gateWayPayorderInfo.outOrderId" : "20150809173033000000000000005503"});

#### 使用"$in","$or", "$not"查询 
- 使用"$in"
 查询出pageViews为10000,20000的数据: db.users.find({pageViews:{"$in":[10000,20000]}})

- 使用"$or"
查询出pageViews是10000,20000或url是http://www.cnblogs.com/refactor的文档:
db.users.find(
　　{
　　　　"$or":
　　　　[
　　　　　　{"pageViews":{"$in":[10000,20000]}},
　　　　　　{"url":"http://www.cnblogs.com/refactor"}
　　　　]
　　}
)

- 使用"$not" "$not"可以用在任何条件之上
查询出id_num取模后值为1的文档.
db.users.find(
　　{"id_num":{"$not":{"mod":[1,5]}}}
)

#### 条件句的规则
在查询中,"$lt"在内层文档,在更新中"$inc" 是外层文档的键.
条件句是内层文档的键,修改器是外层文档的键.
可对一个键应用多个条件,但一个键不能对应多个更新修改器.
null可以匹配自身,而且可以匹配"不存在的"

#### 使用$all 如果需要多个元素来匹配数组,就要用"$all"

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
