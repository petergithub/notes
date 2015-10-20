[TOC]

# Commands
## Basic Commands
show dbs
use test
show collections
db.collectionName.findOne()
db.getCollection('collectionName').count()

## Index
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

## Update
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

## Dump & Restore
mongodump -p 31000	mongodump will create a dump
mongorestore
./bin/mongorestore -h 127.0.0.1:27017 -d dbName /path/to/dbName

## Advanced commands
getLastError
查看最大连接数
`db.serverStatus().connections`

## replication replSet
mongod --replSet replSetName -f mongod.conf --fork
