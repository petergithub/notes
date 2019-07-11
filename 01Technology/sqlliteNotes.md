# SQLite

[Command Line Shell For SQLite](https://www.sqlite.org/cli.html)
[SQLite 教程](http://www.runoob.com/sqlite/sqlite-tutorial.html)

## SQLite 命令

``` shell
sqlite3 <quicken_database_file>
sqlite3 memory.db
sqlite> create table memory(database int,type varchar(128),key varchar(128),size_in_bytes int,encoding varchar(128),num_elements int,len_largest_element varchar(128));
sqlite>.mode csv memory
sqlite>.import memory.csv memory
sqlite>.quit
```

## SQLite 语法

### SQL Common

``` sql
CREATE TABLE COMPANY1(
   ID INTEGER PRIMARY KEY    AUTOINCREMENT,
   NAME           TEXT    NOT NULL,
   AGE            INT     NOT NULL,
   ADDRESS        CHAR(50),
   SALARY         REAL
);
```

### index

索引名字在 sqllite 里需要数据库内唯一, 所以建议索引名字规则为:   index_表名_索引名   并且索引名包含唯一的字段  比如  index_bodyindex_roleid_id
`CREATE UNIQUE INDEX index_name on table_name (column_name);`
