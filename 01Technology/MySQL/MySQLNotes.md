# MySQL Notes

## TODO

[15.22 InnoDB Limits](https://dev.mysql.com/doc/refman/8.0/en/innodb-limits.html)
767 bytes is the stated prefix limitation for InnoDB tables - its 1,000 bytes long for MyISAM tables.
[4.9 Environment Variables](https://dev.mysql.com/doc/refman/8.0/en/environment-variables.html)
[MYSQL, OOM KILLER, AND EVERYTHING RELATED](https://www.psce.com/en/blog/2012/05/31/mysql-oom-killer-and-everything-related/)

[Binary Search Tree Visualization](https://www.cs.usfca.edu/~galles/visualization/BST.html)

`SHOW ENGINE INNODB STATUS`

[How to shrink/purge ibdata1 file in MySQL?](https://stackoverflow.com/questions/3456159/how-to-shrink-purge-ibdata1-file-in-mysql)

That ibdata1 isn't shrinking is a particularly annoying feature of MySQL. The ibdata1 file can't actually be shrunk unless you delete all databases, remove the files and reload a dump.

[Why is the ibdata1 file continuously growing in MySQL?](https://www.percona.com/blog/2013/08/20/why-is-the-ibdata1-file-continuously-growing-in-mysql/)

[14.6.1.2 Moving or Copying InnoDB Tables](https://dev.mysql.com/doc/refman/5.6/en/innodb-migration.html)
库拆分, 分库, 热备, 散表
慢日志 pt_query_digest
pt-duplicate-key-checker tool included with Percona Toolkit,
validate your planned changes carefully with a tool such as pt-upgrade

`show variables like 'innodb_page_size';`

## Recent

`SHOW FULL COLUMNS FROM tbl`

## Documents

[MySQL 8.0 Release Notes](https://dev.mysql.com/doc/relnotes/mysql/8.0/en/)
[MySQL 8.0 Reference Manual](https://dev.mysql.com/doc/refman/8.0/en/)
[MySQL Internals Manual](https://dev.mysql.com/doc/internals/en/)

[MySQL Worklog Tasks](https://dev.mysql.com/worklog/) are design specifications for changes that may define past work, or be considered for future development.

[3.1 MySQL Shell Commands](https://dev.mysql.com/doc/mysql-shell/8.0/en/mysql-shell-commands.html)

[MySQL Documentation Home](https://dev.mysql.com/doc/)

[如果有人问你数据库的原理，叫他看这篇文章](https://www.cnblogs.com/jiujuan/p/10676119.html)

## Statement

### Connection

连接MYSQL mysql -h主机地址 -Pport -u用户名 -p用户密码 -S /data/mysql/mysql.sock
`mysql -h110.110.110.110 -u root -p123;`（注:p与密码之间可以不用加空格，其它必须加）

### Database/Schema

显示当前数据库服务器中的数据库列表：`SHOW DATABASES;`
打开库: `USE 库名;`
建立数据库: `CREATE DATABASE 库名;`
删除数据库: `DROP DATABASE 库名 IF EXISTS 库名;`

### Table

显示数据库中的数据表: `SHOW TABLES;`
显示数据表的结构: `DESCRIBE 表名;`
建立数据表: `CREATE TABLE 表名 (字段名 VARCHAR(20), 字段名 CHAR(1));`
`SHOW CREATE TABLE`
删除数据表: `DROP TABLE 表名；`
将表中记录清空: `DELETE FROM 表名;`
duplicate table structure and data: `CREATE TABLE partnership_0803 AS SELECT * FROM partnership;`

### User management

`CREATE USER 'hadoop'@'localhost' IDENTIFIED BY 'password';`
`ALTER USER 'dev'@'localhost' IDENTIFIED WITH mysql_native_password BY 'dev';`
`DROP USER 'demo'@'localhost';`
`DROP USER admin@'%';`

`GRANT SELECT,INSERT,UPDATE,DELETE ON databaseName.tableName TO 'user'@'%';`
`GRANT ALL PRIVILEGES ON *.* TO 'hadoop'@'localhost';`
`REVOKE [type of permission] ON [database name].[table name] FROM '[username]'@'localhost';`
`REVOKE SELECT ON *.* FROM 'admin'@'%';`

`select user,host from mysql.user where user='cactiuser' \G` 查看MYSQL数据库中所有用户
`show grants for USERNAME@IP;` 查看用户权限

`FLUSH PRIVILEGES;`

### Insert

往表中插入记录: `INSERT INTO 表名 VALUES ("hyq","M");`
用文本方式将数据装入数据表中: `LOAD DATA LOCAL INFILE "D:/mysql.txt" INTO TABLE 表名`

`INSERT INTO table (id, name, age) VALUES(1, "A", 19) ON DUPLICATE KEY UPDATE name="A", age=19`
`INSERT INTO tbl_temp2 (fld_id) SELECT tbl_temp1.fld_order_id FROM tbl_temp1 WHERE tbl_temp1.fld_order_id > 100;`
`INSERT INTO tbl_temp2 SELECT * FROM tbl_temp1;`

### Update

更新表中数据: `UPDATE 表名 SET 字段名1='a',字段名2='b' WHERE 字段名3='c';`
append a string to an existing field: `UPDATE categories SET code = CONCAT(code, '_standard') WHERE id = 1;`

``` SQL
-- update multiple fields
UPDATE tbl SET refund_transactions = 0, trade_transactions = 83

-- Update MySQL table with another table's data
UPDATE tableB
INNER JOIN tableA ON tableA.name = tableB.name
SET tableB.value = IF(tableA.value > 0, tableA.value, tableB.value)
WHERE tableA.name = 'Joe'
```

### Alter

`ALTER TABLE tableName ADD INDEX idx_name (column1, column2) USING BTREE;`
`ALTER TABLE tableName DROP INDEX idx_name;`
`ALTER TABLE table_name add UNIQUE KEY (model,ip);`
`ALTER TABLE tableName modify column columnName varchar(512) NOT NULL COMMENT 'comments';`
`ALTER TABLE table_name RENAME COLUMN old_col_name TO new_col_name;`

`ALTER TABLE wifi_data add column type tinyint default 0 comment '0, 没有用户成功; 1,有用户成功' after ANOTHER_COLUMN_NAME;`
`ALTER TABLE bpg_info add column remark varchar(256) DEFAULT '' COMMENT '备注'`
`ALTER TABLE old_name RENAME new_name;`
`ALTER TABLE old_db.fooTable RENAME new_db.fooTable` move table from one schema to another schema
`ALTER TABLE table_name ENGINE=InnoDB;`
`ALTER TABLE tbl AUTO_INCREMENT = 100;` set AUTO_INCREMENT value

### Select

`select LAST_INSERT_ID();` returns the first AUTO_INCREMENT value that was set by the most recent INSERT or UPDATE statement that affected an AUTO_INCREMENT column.
按年按月分组 `GROUP BY YEAR(record_date), MONTH(record_date)`
按天分组 `select DATE_FORMAT(start_time,'%Y-%m-%d') days,count(*) count from test group by days;`

时间函数 时间格式化 `FROM_UNIXTIME(timestamp,'%Y-%m-%d')`
计算生日 `SELECT  TIMESTAMPDIFF(YEAR, birthday, CURDATE())`

字符个数(in character): `SELECT CHARACTER_LENGTH("SQL字符长度") AS LengthOfString;`
字符长度(in byte): `SELECT LENGTH("SQL字符长度") AS LengthOfString;`
`SELECT case a.platformid when 1 then "admob" when 2 then "facebook" else platformid end as platform FROM table;`
显示当前的user: `SELECT USER();`
来查看数据库版本 `SELECT VERSION();`
显示use的数据库名 query the current database name: `SELECT DATABASE();`

`show variables like 'char%'`
`show variables where variable_name like '%myisam%'`
`show status where variable_name in ('Threads_cached','Aborted_clients');`

#### [MySQL 中的 `<=>` 操作符](http://blog.jobbole.com/62478/)

[<=> NULL-safe equal](https://dev.mysql.com/doc/refman/8.0/en/comparison-operators.html#operator_equal-to)

1. 和`=`号的相同点
 像常规的=运算符一样，两个值进行比较，结果是0（不等于）或1（相等）; 换句话说：'A'<=>'B'得0 和'a'<=>'a'得1。

2. 和`=`号的不同点
 使用`=`号运算符时，NULL 没有任何意义，不把NULL作为有效的结果：`'a'=NULL` 结果是NULL，`NULL = NULL` 结果也是NULL。
 使用`<=>`时, `'a' <=> NULL` 得 0  `NULL<=> NULL` 得 1

3. 相关操作符
 除了 `<=>` ，还有两个其他的操作符用来处理某个值和NULL做比较，也就是IS NULL and IS NOT NULL。
 他们是ANSI标准中的一部分，因此也可以用在其他数据库中。而`<=>`只能在mysql中使用。你可以把`<=>`当作mysql中的方言

#### 窗口函数

[MySQL 8.0 Reference Manual :: 12.21.1 Window Function Descriptions](https://dev.mysql.com/doc/refman/8.0/en/window-function-descriptions.html)

[通俗易懂的学会：SQL窗口函数 - 知乎](https://zhuanlan.zhihu.com/p/92654574)

用途：

1. 排名问题：每个部门按业绩来排名
2. topN问题：找出每个部门排名前N的员工进行奖励

基本语法如下：
<窗口函数> over (partition by <用于分组的列名>
                order by <用于排序的列名>)

partition by用来对表分组。在这个例子中，所以我们指定了按“班级”分组（partition by 班级）
order by子句的功能是对分组后的结果进行排序

<窗口函数>的位置，可以放以下两种函数：

1. 专用窗口函数，包括后面要讲到的rank, dense_rank, row_number等专用窗口函数。
2. 聚合函数，如sum. avg, count, max, min等

```sql
-- 按国家分组后，按profit排名（数据见 Load local file）
select id, year, country, product, profit,
  rank() over(partition by country order by country,profit)
  from sales;
```

### JOIN

[SQL 连接(JOIN) | 菜鸟教程](https://www.runoob.com/sql/sql-join.html)
[A Visual Explanation of SQL Joins](https://blog.codinghorror.com/a-visual-explanation-of-sql-joins/)
INNER JOIN: match in both Table A and Table B.
FULL OUTER JOIN: all records in Table A and Table B
LEFT OUTER JOIN: produces a complete set of records from Table A, with the matching records (where available) in Table B. If there is no match, the right side will contain null.

TableA - TableB: `SELECT * FROM TableA LEFT OUTER JOIN TableB ON TableA.name = TableB.name WHERE TableB.id IS null`

`SELECT * FROM TableA FULL OUTER JOIN TableB ON TableA.name = TableB.name WHERE TableA.id IS null OR TableB.id IS null`
To produce the set of records unique to Table A and Table B, we perform the same full outer join, then **exclude the records we don't want from both sides via a where clause**.

`SELECT * FROM TableA CROSS JOIN TableB`  cartesian product, this joins "everything to everything"

```sql
-- 三张表关联：A (id,xxx) B(id,xxx) C(id,xxx) 要根据相同的id显示三张表，做Left Join。

SELECT XXX
FROM ((A LEFT JOIN B ON A.id = B.id)
LEFT JOIN C ON A.id = C.id)
WHERE B.id Is Not Null
```

#### 关联查询价格最高的文章

[MySQL :: MySQL 8.0 Reference Manual :: 3.6.4 The Rows Holding the Group-wise Maximum of a Certain Column](https://dev.mysql.com/doc/refman/8.0/en/example-maximum-column-group-row.html)

```sql
CREATE TABLE shop (
    article INT UNSIGNED  DEFAULT '0000' NOT NULL,
    dealer  CHAR(20)      DEFAULT ''     NOT NULL,
    price   DECIMAL(16,2) DEFAULT '0.00' NOT NULL,
    PRIMARY KEY(article, dealer));

INSERT INTO shop VALUES
    (1,'A',3.45),(1,'B',3.99),(2,'A',10.99),(3,'B',1.45),
    (3,'C',1.69),(3,'D',1.25),(4,'D',19.95);

-- The LEFT JOIN works on the basis that when s1.price is at its maximum value, there is no s2.price with a greater value and thus the corresponding s2.article value is NULL.
select s1.article, s1.dealer, s1.price FROM shop s1 left join shop s2 ON s1.article = s2.article and s1.price < s2.price where s2.price is null;
```

### exists 语句

exists 语法为：

```sql
select *
from table_a a
where exists (select 1 from table_b b where b.id = b.id);
```

exists 对外表用 loop 逐条查询，每次查询都会查看 exists 的条件语句。

当 exists 里的条件语句能够返回记录行时（无论返回多少记录行，只要能返回），条件就为真，返回当前 loop 到的这条记录。

反之如果 exists 里的条件语句不能返回记录行，则当前 loop 到的这条记录被丢弃。

exists 的条件就像一个 bool 条件，当能返回结果集则为 true，不能返回结果集则为 false。

当子查询为 select NULL 时， mysql 仍然认为它是 True。

#### in 与 exists 的区别

1. 外层查询表小于子查询表，则用 exists，外层查询表大于子查询表，则用 in ，如果外层和子查询表差不多，则爱用哪个用哪个。
2. not exists 比 not in 效率高。

in 的遍历是在内存中遍历。 而 exists 需要查询数据库。

查询数据库所消耗的性能更高，而内存比较快。

##### in 语句：只执行一次

确定给定的值是否与子查询或列表中的值相匹配。

in 在查询的时候，首先查询子查询的表，然后将内表和外表做一个笛卡尔积，然后按照条件进行筛选。

所以相对内表比较小的时候，in 的速度较快。

##### exists 语句：执行n次（外表行数）

指定一个子查询，检测行的存在。

遍历循环外表，检查外表中的记录有没有和内表的的数据一致的。

匹配得上就放入结果集。

### Case-sensitive

make a case-sensitive query
`select *  from table where BINARY column = 'value'`
`select * from t1 where name = binary 'YOU'`

设置表或行的collation，使其为binary或case sensitive。在MySQL中，对于Column Collate其约定的命名方法如下:
`*_bin`: 表示的是binary case sensitive collation，也就是说是区分大小写的
`*_cs`: case sensitive collation，区分大小写
`*_ci`: case insensitive collation，不区分大小写

### Other function

`CONV()` converts a number from one numeric base number system to another numeric base number system. After the conversion, the function returns a string representation of the number.  `CONV(num , from_base , to_base );`

```sql
-- convert `D0490012475E` to `D0:49:00:12:47:5E`
update mac_tbl set macHex = CONCAT_WS(':',SUBSTRING(macHex,1,2),SUBSTRING(macHex,3,2),SUBSTRING(macHex,5,2),SUBSTRING(macHex,7,2),SUBSTRING(macHex,9,2),SUBSTRING(macHex,11,2)) where id = 8;

-- force index
SELECT * FROM tbl force index(role_id) WHERE `role_id`=14838229 and `time` >= '2007-02-10 00:00:00' ORDER BY `time` ASC LIMIT 1;

-- 查询倒数第二位是偶数 even  或者 mod(id / 10, 2) = 0
SELECT id FROM `user` WHERE id / 10 % 2=0 limit 2;
```

* `SUBSTR(string, start, length)`
* `SUBSTRING_INDEX(string, delimiter, number)` returns a substring of a string before a specified number of delimiter occurs.
  * `SELECT SUBSTRING_INDEX("www.example.com", ".", 2);` return `www.example`
* `LOCATE(substring, string, start)` returns the position of the first occurrence of a substring in a string.
  * `SELECT LOCATE("com", "a.com", 3) AS MatchPosition`; return `3`
  * [MySQL LOCATE() Function](https://www.w3schools.com/sql/func_mysql_locate.asp)

### Complicated SQL

``` SQL

-- SET table_name as variable
SET @tableName = 'user';
SET @s = concat('select id from ', @tableName, ' where id = 770');
PREPARE stmt1 FROM @s;
EXECUTE stmt1;
DEALLOCATE PREPARE stmt1;

SELECT
    COUNT( CASE WHEN `mother` >24 THEN 1 ELSE NULL END ) AS `digong`,
    COUNT( CASE WHEN `mother` <=24 THEN 1 ELSE NULL END ) AS `tiangong`
FROM prince
```

### Check database status

+---------+-----------------+--------------------+---------+---------+---------+------------------------+------------------+
| Id      | User            | Host               | db      | Command | Time    | State                  | Info             |
+---------+-----------------+--------------------+---------+---------+---------+------------------------+------------------+

1. 先`show processlist;` 看到有疑问的SQL，去`explain`，然后`set profiling=1；`
2. 看看索引是不是对的，看看哪些SQL本身是有问题的

[Identify and Kill Queries with MySQL Command-Line Tool](https://pantheon.io/docs/kill-mysql-queries/)
[pt-kill — Percona Toolkit Documentation](https://docs.percona.com/percona-toolkit/pt-kill.html)
[Mass killing of MySQL Connections](https://www.percona.com/blog/2009/05/21/mass-killing-of-mysql-connections)

```SQL
pager grep -v Sleep | less; show full processlist;

-- id1,id2,id3
-- select GROUP_CONCAT(id) from table where id > 1000;

-- Kill multiple process:
SELECT GROUP_CONCAT(CONCAT('KILL ',id,';') SEPARATOR ' ') 'Paste the following query to kill all processes' FROM information_schema.processlist WHERE STATE = 'Sleep' AND user = 'root' and Host like '172%' and INFO LIKE 'SELECT %' \G
+----------------------------------------------------+
| Paste the following query to kill all processes    |
+----------------------------------------------------+
| KILL 16; KILL 8; KILL 9; KILL 19; KILL 5; KILL 15; |
+----------------------------------------------------+

-- output file
mysql> select concat('KILL ',id,';') from information_schema.processlist where user='root' into outfile '/tmp/a.txt';
mysql> source /tmp/a.txt;

```

``` bash
# count states of SQL
mysql -e "show full processlist \G" | grep State: | sort | uniq -c | sort -rn

# Kill all process in shell
mysql -h localhost -u root -p -D dbName -e "show full processlist;" | \
grep -i "show" | awk '{print $0}' | awk '{print "kill", $1 ";"}' \
mysql -h localhost -u root -p

# 查看连接MYSQL数据库的IP信息
select SUBSTRING_INDEX(host,':',1) as ip , count(*) from information_schema.processlist group by ip;
mysql -u root -h 127.0.0.1 -e "show processlist\G;"| egrep "Host\:" | awk -F: '{ print $2 }'| sort | uniq -c
mysql -u root -h 127.0.0.1 --skip-column-names -e "show processlist;"|awk '{print $3}'|awk -F":" '{print $1}'|sort|uniq –c
```

### SQL 的语法并不按照语法顺序执行

SQL 语句有一个让大部分人都感到困惑的特性，就是：SQL 语句的执行顺序跟其语句的语法顺序并不一致。SQL 语句的语法顺序是：

SELECT[DISTINCT]
FROM
WHERE
GROUP BY
HAVING
UNION
ORDER BY
为了方便理解，上面并没有把所有的 SQL 语法结构都列出来，但是已经足以说明 SQL 语句的语法顺序和其执行顺序完全不一样，就以上述语句为例，其执行顺序为：

FROM
WHERE
GROUP BY
HAVING
SELECT
DISTINCT
UNION
ORDER BY
关于 SQL 语句的执行顺序，有三个值得我们注意的地方：

1、 FROM 才是 SQL 语句执行的第一步，并非 SELECT 。数据库在执行 SQL 语句的第一步是将数据从硬盘加载到数据缓冲区中，以便对这些数据进行操作。（译者注：原文为“The first thing that happens is loading data from the disk into memory, in order to operate on such data.”，但是并非如此，以 Oracle 等常用数据库为例，数据是从硬盘中抽取到数据缓冲区中进行操作。）

2、 SELECT 是在大部分语句执行了之后才执行的，严格的说是在 FROM 和 GROUP BY 之后执行的。理解这一点是非常重要的，这就是你不能在 WHERE 中使用在 SELECT 中设定别名的字段作为判断条件的原因。

SELECT A.x + A.y AS z
FROM A
WHERE z = 10 -- z 在此处不可用，因为SELECT是最后执行的语句！
如果你想重用别名z，你有两个选择。要么就重新写一遍 z 所代表的表达式：

SELECT A.x + A.y AS z
FROM A
WHERE (A.x + A.y) = 10
…或者求助于衍生表、通用数据表达式或者视图，以避免别名重用。请看下文中的例子。

3、 无论在语法上还是在执行顺序上， UNION 总是排在在 ORDER BY 之前。很多人认为每个 UNION 段都能使用 ORDER BY 排序，但是根据 SQL 语言标准和各个数据库 SQL 的执行差异来看，这并不是真的。尽管某些数据库允许 SQL 语句对子查询（subqueries）或者派生表（derived tables）进行排序，但是这并不说明这个排序在 UNION 操作过后仍保持排序后的顺序。

注意：并非所有的数据库对 SQL 语句使用相同的解析方式。如 MySQL、PostgreSQL和 SQLite 中就不会按照上面第二点中所说的方式执行。

## DataType

[Data Type Storage Requirements](https://dev.mysql.com/doc/refman/8.0/en/storage-requirements.html#data-types-storage-reqs-strings)

### [数据类型宽度](http://blog.jobbole.com/87318/ )

显示宽度只用于显示，并不能限制取值范围和占用空间，例如：INT(3)会占用4个字节的存储空间，并且允许的最大值也不会是999，而是INT整型
[Numeric Type Attributes](https://dev.mysql.com/doc/refman/5.7/en/numeric-type-attributes.html )
[MySQL: Why specify display width without using zerofill](https://stackoverflow.com/questions/12592376/mysql-why-specify-display-width-without-using-zerofill )

### Integer Types

[Integer Types (Exact Value) - INTEGER, INT, SMALLINT, TINYINT, MEDIUMINT, BIGINT](https://dev.mysql.com/doc/refman/8.0/en/integer-types.html)

Type | Storage (Bytes) | Minimum Value Signed | Minimum Value Unsigned | Maximum Value Signed | Maximum Value Unsigned
---|---|---|---|---|---|---
TINYINT | 1 | -128 | 0 | 127 | 255
SMALLINT | 2 | -32768 | 0 | 32767 | 65535
MEDIUMINT | 3 | -8388608 | 0 | 8388607 | 16777215
INT | 4 | -2147483648 | 0 | 2147483647 | 4294967295
BIGINT | 8 | -2^63 | 0 | 2^63-1 | 2^64-1

### String Type Storage Requirements

In the following table, M represents the declared column length in characters for nonbinary string types and bytes for binary string types. L represents the actual length in bytes of a given string value.

Data Type | Storage Required
---|---|---|---|---|---|---
CHAR(M) | The compact family of InnoDB row formats optimize storage for variable-length character sets. See COMPACT Row Format Storage Characteristics. Otherwise, M × w bytes, <= M <= 255, where w is the number of bytes required for the maximum-length character in the character set.
BINARY(M) | M bytes, 0 <= M <= 255
VARCHAR(M), VARBINARY(M) | L + 1 bytes if column values require 0 − 255 bytes, L + 2 bytes if values may require more than 255 bytes
TINYBLOB, TINYTEXT | L + 1 bytes, where L < 28
BLOB, TEXT | L + 2 bytes, where L < 216

### Datetime

updates automatically the date field `ALTER TABLE tableName ADD COLUMN modifyDate DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;`

`SELECT UNIX_TIMESTAMP(NOW());`
`SELECT FROM_UNIXTIME(1467542031);`
`select SUBSTRING(1456958130210,1,10);`
`select DATE_ADD(now(), INTERVAL 1 day);` # - 加1天
`select DATE_SUB(now(), INTERVAL 1 day);` # - 减1天

``` SQL

SELECT UNIX_TIMESTAMP('2009-02-14 07:31:30');
  +---------------------------------------+
  | UNIX_TIMESTAMP('2009-02-14 07:31:30') |
  +---------------------------------------+
  |                            1234567890 |
  +---------------------------------------+
SELECT FROM_UNIXTIME(1234567890);
  +---------------------------+
  | FROM_UNIXTIME(1234567890) |
  +---------------------------+
  | 2009-02-14 07:31:30      |
  +---------------------------+

SELECT FROM_UNIXTIME(SUBSTRING(1234567890123, 1, 10));
SELECT FROM_UNIXTIME(LEFT(1234567890123,10));

DATE_FORMAT(NOW(),'%b %d %Y %h:%i %p'); //Dec 29 2008 11:45 PM
DATE_FORMAT(NOW(),'%m-%d-%Y') //12-29-2008
DATE_FORMAT(NOW(),'%d %b %y') //29 Dec 08
DATE_FORMAT(NOW(),'%d %b %Y %T:%f') //29 Dec 2008 16:25:46.635
```

### JSON

[JSON Function Reference](https://dev.mysql.com/doc/refman/8.0/en/json-function-reference.html)

```SQL
SELECT id,type,product FROM t where type = '["直播"]';
SELECT id,type,product FROM t where "直播" MEMBER OF (type);
SELECT id,type,product FROM t where JSON_CONTAINS(type, '["直播"]');
SELECT id,type,product FROM t where JSON_SEARCH(type, 'one', "直播");
```

### [Functions That Search JSON Values](https://dev.mysql.com/doc/refman/8.0/en/json-search-functions.html)

#### JSON_CONTAINS(target, candidate[, path])

Indicates by returning 1 or 0 whether a given candidate JSON document is contained within a target JSON document

``` SQL
mysql> SET @j = '{"a": 1, "b": 2, "c": {"d": 4}}';
mysql> SET @j2 = '1';
mysql> SELECT JSON_CONTAINS(@j, @j2, '$.a');
+-------------------------------+
| JSON_CONTAINS(@j, @j2, '$.a') |
+-------------------------------+
|                             1 |
+-------------------------------+
```

#### JSON_EXTRACT(json_doc, path[, path] ...)

Returns data from a JSON document, selected from the parts of the document matched by the path arguments

```SQL
mysql> SELECT JSON_EXTRACT('[10, 20, [30, 40]]', '$[1]', '$[0]');
+----------------------------------------------------+
| JSON_EXTRACT('[10, 20, [30, 40]]', '$[1]', '$[0]') |
+----------------------------------------------------+
| [20, 10]                                           |
+----------------------------------------------------+
```

The `->` operator serves as an alias for the `JSON_EXTRACT()`: `JSON_EXTRACT(c, "$.id")` == `c->"$.id"`
`UPDATE jemp SET n=1 WHERE c->"$.id" = "4";`
the `->>` operator in addition unquotes the extracted result `JSON_UNQUOTE(JSON_EXTRACT(column, path))`. In other words, given a JSON column value column and a path expression path. The `->>` operator can be used wherever JSON_UNQUOTE(JSON_EXTRACT()) would be allowed.
`column->>path` == `JSON_UNQUOTE(JSON_EXTRACT(column, path))`

#### JSON_SEARCH(json_doc, one_or_all, search_str[, escape_char[, path] ...])

```SQL
mysql> SET @j = '["abc", [{"k": "10"}, "def"], {"x":"abc"}, {"y":"bcd"}]';

mysql> SELECT JSON_SEARCH(@j, 'one', 'abc');
+-------------------------------+
| JSON_SEARCH(@j, 'one', 'abc') |
+-------------------------------+
| "$[0]"                        |
+-------------------------------+

mysql> SELECT JSON_SEARCH(@j, 'all', 'abc');
+-------------------------------+
| JSON_SEARCH(@j, 'all', 'abc') |
+-------------------------------+
| ["$[0]"", "$[2].x"]            |
+-------------------------------+
```

#### [JSON Utility Functions](https://dev.mysql.com/doc/refman/8.0/en/json-utility-functions.html)

```SQL
mysql> SELECT JSON_PRETTY('123'); # scalar
mysql> SELECT JSON_PRETTY("[1,3,5]"); # array
+------------------------+
| JSON_PRETTY("[1,3,5]") |
+------------------------+
| [
  1,
  3,
  5
]      |
+------------------------+

mysql> SELECT JSON_PRETTY('{"a":"10","b":"15","x":"25"}'); # object
```

#### JSON Other

`JSON_KEYS(json_doc[, path])`: Returns the keys from the top-level value of a JSON object as a JSON array
`JSON_OVERLAPS(json_doc1, json_doc2)`: Compares two JSON documents. Returns true (1) if the two document have any key-value pairs or array elements in common
`value MEMBER OF(json_array)`: Returns true (1) if value is an element of json_array, otherwise returns false (0). value must be a scalar or a JSON document; if it is a scalar, the operator attempts to treat it as an element of a JSON array.

## Setting

[Variable-Setting Hint Syntax](https://dev.mysql.com/doc/refman/8.0/en/optimizer-hints.html#optimizer-hints-set-var)
The `SET_VAR` hint sets the session value of a system variable temporarily (for the duration of a single statement).

Examples:
`SELECT /*+ SET_VAR(sort_buffer_size = 16M) */ name FROM people ORDER BY name;`
`INSERT /*+ SET_VAR(foreign_key_checks=OFF) */ INTO t2 VALUES(2);`

`SET @@auto_increment_increment=10`

## Charset 查看三种MySQL字符集

MySQL 5.5.3+ UTF8mb4支持emoji
查看支持的字符集和排序方式: `show character set`, `show collation` or `show variables like '%char%'`
查看数据库字符集`select * from SCHEMATA where SCHEMA_NAME='ttlsa';`
查看表字符集 `select TABLE_SCHEMA,TABLE_NAME,TABLE_COLLATION from information_schema.TABLES;` or `show table status from databaseName like 'tableName'`
查看列字符集 `select TABLE_SCHEMA,TABLE_NAME,COLUMN_NAME,COLLATION_NAME from information_schema.COLUMNS;` or `show full columns from tableName`

* `utf8_bin`: case-sensitive, because it compares the binary values of the characters.
* Both `utf8_general_ci` and `utf8_unicode_ci` perform case-insensitive comparison. operations performed using the `_general_ci` collation are faster than those for the `_unicode_ci` collation. For example, comparisons for the utf8_general_ci collation are faster, but slightly less correct, than comparisons for utf8_unicode_ci.

* `utf8_bin` compares the bits blindly. No case folding, no accent stripping.
* `utf8_general_ci` compares one byte with one byte. It does case folding and accent stripping, but no 2-character comparisions: ij is not equal ĳ in this collation.
* `utf8_*_ci` is a set of language-specific rules, but otherwise like unicode_ci. Some special cases: Ç, Č, ch, ll
* `utf8_unicode_ci` follows an old Unicode standard for comparisons. ij=ĳ, but ae != æ
* `utf8_unicode_520_ci` follows an newer Unicode standard. ae = æ

[utf8_collations](http://mysql.rjweb.org/utf8_collations.html)

[Better Unicode support for MySQL (including emoji)](http://tonyshowoff.com/articles/better-unicode-support-for-mysql-including-emoji/)

``` config

  [client]
  default-character-set = utf8mb4

  [mysql]
  default-character-set = utf8mb4

  [mysqld]
  character-set-client-handshake = FALSE
  character-set-server = utf8mb4
  collation-server = utf8mb4_unicode_ci
```

### 创建表的时候指定CHARSET为utf8mb4

``` sql
  CREATE TABLE IF NOT EXISTS mb4 (
  id INT(3) NOT NULL AUTO_INCREMENT,
    name varchar(32) CHARACTER SET utf8mb4 DEFAULT NULL,
  comment VARCHAR(50) DEFAULT 'test',
    PRIMARY KEY (`id`)
  ) ENGINE=MyIsam DEFAULT CHARSET=utf8 COLLATE utf8_general_ci;
```

update database character: `ALTER DATABASE database_name CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;`

update table character:
`ALTER TABLE table_name CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;`
`ALTER TABLE table_name modify column_name varchar(32) charset utf8mb4 not null comment 'comment';`

update column character: `ALTER TABLE table_name CHANGE column_name column_name VARCHAR(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;`

### 查看MySQL数据库服务器和数据库MySQL字符集

  ```sql
  mysql> show variables like '%char%';
  +--------------------------+-----------------------------------------------+
  | Variable_name            | Value                                         |
  +--------------------------+-----------------------------------------------+
  | character_set_client     | latin1                                        |
  | character_set_connection | latin1                                        |
  | character_set_database   | utf8                                          |
  | character_set_filesystem | binary                                        |
  | character_set_results    | latin1                                        |
  | character_set_server     | utf8mb4                                       |
  | character_set_system     | utf8                                          |
  | character_sets_dir       | /data/softwares/mysql-percona/share/charsets/ |
  +--------------------------+-----------------------------------------------+
  8 rows in set (0.00 sec)
  ```

### 查看MySQL数据表（table）的MySQL字符集

  ``` sql
  mysql> show table status from settlement like 'tableName' \G
  *************************** 1. row ***************************
             Name: tableName
           Engine: InnoDB
          Version: 10
       Row_format: Compact
             Rows: 33
   Avg_row_length: 496
      Data_length: 16384
  Max_data_length: 0
     Index_length: 16384
        Data_free: 0
   Auto_increment: 48
      Create_time: 2015-10-09 18:46:57
        Collation: utf8_general_ci
  1 row in set (0.00 sec)
  ```

### 查看MySQL数据列（column）的MySQL字符集

  ``` sql
  mysql> show full columns from st_card \G
       Field: merchant_id
        Type: varchar(64)
   Collation: utf8_general_ci
        Null: YES
         Key: MUL
     Default: NULL
       Extra:
  Privileges: select,insert,update,references
  ```

## Backup & restore

### Export/Backup database mysqldump

MySQL 5.7 Reference Manual [mysqldump - A Database Backup Program](https://dev.mysql.com/doc/refman/5.7/en/mysqldump.html#option_mysqldump_single-transaction)
导出整个数据库(--hex-blob 为有blob数据做的,防止乱码和导入失败用)
备份文件中的"--"字符开头的行为注释语句；以/*!"开头、以"*/"结尾的语句为可执行的mysql注释，这些语句可以被mysql执行

`mysqldump -u USERNAME -p dbName | gzip > sql.gz`  生成一个 gz 文件
`mysqldump -u USERNAME -p dbName > dbName.sql | gzip > sql.gz` 生成两个文件 sql 和 gz
`mysqldump -uroot --default-character-set=utf8 --hex-blob --single-transaction dbName table1Name table2Name > dbName.sql`

* `--no-data, -d` 没有数据
* `--hex-blob` 为有blob数据做的,防止乱码和导入失败用
* `--add-drop-table` 在每个create语句之前增加一个drop table
* `--skip-add-drop-table` without drop table
* `--no-create-info, -t` Do not write CREATE TABLE statements that re-create each dumped table.
* `--default-character-set=utf8` 带语言参数导出
* `--single-transaction`  This option sets the transaction isolation mode to REPEATABLE READ without blocking any applications. It is useful only with transactional tables such as InnoDB
* `--lock-tables=false , -l`  Lock all tables before dumping them. The tables are locked with READ LOCAL to allow concurrent inserts in the case of MyISAM tables. For transactional tables such as InnoDB and BDB, `--single-transaction` is a much better option, because it does not need to lock the tables at all.
* `--where, -w` export with condition `mysqldump -u root -p123456 schemaName tableName --where=" sensorid=11 and fieldid=0" > /home/xyx/Temp.sql`
* `--insert-ignore`  Write `INSERT IGNORE` statements rather than `INSERT` statements
* `--force, -f`  Ignore all errors; continue even if an SQL error occurs during a
* `--compress`

``` bash

date_str=`date +%Y%m%d%H%M%S`
cd /data2/backup
mysqldump -h localhost -uroot --pxxxxx -R -e --max_allowed_packet=1048576 --net_buffer_length=16384 i5a6 | gzip > /data2/backup/i5a6_$date_str.sql.gz
```

### Export and Import a MySQL Database in One Command

`mysqldump -u root -p database_name | mysql -h remote_host -u root -p remote_database_name`

### MySQL Export Table to CSV

[Select INTO](http://dev.mysql.com/doc/refman/5.7/en/select-into.html)
`mysql -uroot -proot -D account -s -e "select id,username from user_0 limit 10 INTO OUTFILE '/tmp/user.csv' FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n'"`
`mysql -uroot -p -D account < mysql.sql |  sed 's/\t/,/g' > out.csv`

``` sql
SELECT
  orderNumber, status, orderDate, requiredDate, comments
FROM
  orders
WHERE
  status = 'Cancelled'
INTO OUTFILE '/tmp/cancelled_orders.csv'
FIELDS ENCLOSED BY '"'
TERMINATED BY ','
ESCAPED BY '"'
LINES TERMINATED BY '\r\n';
```

### Import/Restore

`mysql> USE 数据库名;`
`mysql> SOURCE d:/mysql.sql;` or
`mysql -uroot -p dbName < dbName.sql` or
`mysql -uroot -p dbName -e "source /path/to/dbName.sql"`

* `--force, -f`  Ignore all errors; continue even if an SQL error occurs
* `--skip-column-names, -N`  Do not write column names in results.

#### Load local file into mysql

[MySQL 8.0 Reference Manual :: 13.2.7 LOAD DATA Statement](https://dev.mysql.com/doc/refman/8.0/en/load-data.html)

[How to import data from text file to mysql database - Stack Overflow](https://stackoverflow.com/questions/13579810/how-to-import-data-from-text-file-to-mysql-database)

```sql
-- 启用 Load 命令
-- 1. enable from server: SET GLOBAL local_infile=1;
-- 2. enable from client: Edit the connection -> Advanced' -> Others box -> add the line 'OPT_LOCAL_INFILE=1'.

-- 创建表
create table sales (
  id int AUTO_INCREMENT,
  year int,
  country VARCHAR(32),
  product varchar(32),
  profit int,
  PRIMARY KEY (id)
);

-- 导入的文件内容 /tmp/mysql.group.txt
-- | 2000 | Finland | Computer   |   1500 |
-- | 2000 | Finland | Phone      |    100 |
-- | 2001 | Finland | Phone      |     10 |
-- | 2000 | India   | Calculator |     75 |
-- | 2000 | India   | Calculator |     75 |
-- | 2000 | India   | Computer   |   1200 |
-- | 2000 | USA     | Calculator |     75 |
-- | 2000 | USA     | Computer   |   1500 |
-- | 2001 | USA     | Calculator |     50 |
-- | 2001 | USA     | Computer   |   1500 |
-- | 2001 | USA     | Computer   |   1200 |
-- | 2001 | USA     | TV         |    150 |
-- | 2001 | USA     | TV         |    100 |

-- 导入 SQL
LOAD DATA LOCAL INFILE '/tmp/mysql.group.txt' INTO TABLE sales COLUMNS TERMINATED BY '|';

-- How to specify which columns to load your text file columns into:
LOAD DATA LOCAL INFILE '/tmp/foo.txt' INTO TABLE foo
FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n'
(@col1,@col2,@col3) set myid=@col1,mydecimal=@col3;

LOAD DATA LOCAL
    INFILE '/tmp/mydata.txt' INTO TABLE PerformanceReport
    COLUMNS TERMINATED BY '\t'  ## This should be your delimiter
    OPTIONALLY ENCLOSED BY '"'; ## ...and if text is enclosed, specify here
```

## MySQL Server Administration

### Admin sql

#### Get the sizes of the tables

[How to get the sizes of the tables of a mysql datab](https://stackoverflow.com/questions/9620198/how-to-get-the-sizes-of-the-tables-of-a-mysql-database)
You can use this query to show the size of a table (although you need to substitute the variables first):

``` sql
SELECT
    table_name AS TableName,
    round(((data_length + index_length) / 1024 / 1024), 2) "Size in MB"
FROM information_schema.TABLES
WHERE table_schema = "$DB_NAME"
    AND table_name = "$TABLE_NAME";
```

or this query to list the size of every table in every database, largest first:

``` sql

SELECT
      table_schema as DatabaseName,
      table_name AS TableName,
      round(((data_length + index_length) / 1024 / 1024), 2) "Size in MB"
FROM information_schema.TABLES
ORDER BY (data_length + index_length) DESC;
```

[使用“optimize table”命令释放MySQL实例的表空间](https://help.aliyun.com/document_detail/457082.html)

使用 delete 语句删除数据时，delete语句只是将记录的位置或数据页标记为了“可复用”，但是磁盘文件的大小不会改变，即表空间不会直接回收。此时您可以通过 `optimize table` 语句释放表空间。

#### Calculate table size, row size and max row size for a table

[mysql - Calculate row size and max row size for a table - Database Administrators Stack Exchange](https://dba.stackexchange.com/questions/114471/calculate-row-size-and-max-row-size-for-a-table)

```sql
SELECT col_sizes.TABLE_SCHEMA, col_sizes.TABLE_NAME, SUM(col_sizes.col_size) AS EST_MAX_ROW_SIZE
FROM (
    SELECT
        cols.TABLE_SCHEMA,
        cols.TABLE_NAME,
        cols.COLUMN_NAME,
        CASE cols.DATA_TYPE
            WHEN 'tinyint' THEN 1
            WHEN 'smallint' THEN 2
            WHEN 'mediumint' THEN 3
            WHEN 'int' THEN 4
            WHEN 'bigint' THEN 8
            WHEN 'float' THEN IF(cols.NUMERIC_PRECISION > 24, 8, 4)
            WHEN 'double' THEN 8
            WHEN 'decimal' THEN ((cols.NUMERIC_PRECISION - cols.NUMERIC_SCALE) DIV 9)*4  + (cols.NUMERIC_SCALE DIV 9)*4 + CEIL(MOD(cols.NUMERIC_PRECISION - cols.NUMERIC_SCALE,9)/2) + CEIL(MOD(cols.NUMERIC_SCALE,9)/2)
            WHEN 'bit' THEN (cols.NUMERIC_PRECISION + 7) DIV 8
            WHEN 'year' THEN 1
            WHEN 'date' THEN 3
            WHEN 'time' THEN 3 + CEIL(cols.DATETIME_PRECISION /2)
            WHEN 'datetime' THEN 5 + CEIL(cols.DATETIME_PRECISION /2)
            WHEN 'timestamp' THEN 4 + CEIL(cols.DATETIME_PRECISION /2)
            WHEN 'char' THEN cols.CHARACTER_OCTET_LENGTH
            WHEN 'binary' THEN cols.CHARACTER_OCTET_LENGTH
            WHEN 'varchar' THEN IF(cols.CHARACTER_OCTET_LENGTH > 255, 2, 1) + cols.CHARACTER_OCTET_LENGTH
            WHEN 'varbinary' THEN IF(cols.CHARACTER_OCTET_LENGTH > 255, 2, 1) + cols.CHARACTER_OCTET_LENGTH
            WHEN 'tinyblob' THEN 9
            WHEN 'tinytext' THEN 9
            WHEN 'blob' THEN 10
            WHEN 'text' THEN 10
            WHEN 'mediumblob' THEN 11
            WHEN 'mediumtext' THEN 11
            WHEN 'longblob' THEN 12
            WHEN 'longtext' THEN 12
            WHEN 'enum' THEN 2
            WHEN 'set' THEN 8
            ELSE 0
        END AS col_size
    FROM INFORMATION_SCHEMA.COLUMNS cols
) AS col_sizes
GROUP BY col_sizes.TABLE_SCHEMA, col_sizes.TABLE_NAME
```

[measuring the table data size and index size](https://dba.stackexchange.com/a/46098/73508)

As for measuring the table, for a given table mydb.mytable, you can run this query

```sql
SELECT
    CONCAT(FORMAT(DAT/POWER(1024,pw1),2),' ',SUBSTR(units,pw1*2+1,2)) DATSIZE,
    CONCAT(FORMAT(NDX/POWER(1024,pw2),2),' ',SUBSTR(units,pw2*2+1,2)) NDXSIZE,
    CONCAT(FORMAT(TBL/POWER(1024,pw3),2),' ',SUBSTR(units,pw3*2+1,2)) TBLSIZE
FROM
(
    SELECT DAT,NDX,TBL,IF(px>4,4,px) pw1,IF(py>4,4,py) pw2,IF(pz>4,4,pz) pw3
    FROM
    (
        SELECT data_length DAT,index_length NDX,data_length+index_length TBL,
        FLOOR(LOG(IF(data_length=0,1,data_length))/LOG(1024)) px,
        FLOOR(LOG(IF(index_length=0,1,index_length))/LOG(1024)) py,
        FLOOR(LOG(data_length+index_length)/LOG(1024)) pz
        FROM information_schema.tables
        WHERE table_schema='picooc_bigdata'
        AND table_name='v2_sport_data_2'
    ) AA
) A,(SELECT 'B KBMBGBTB' units) B;
```

To measure all tables grouped by Database and Storage Engine

```sql
SELECT
    IF(ISNULL(DB)+ISNULL(ENGINE)=2,'Database Total',
    CONCAT(DB,' ',IFNULL(ENGINE,'Total'))) "Reported Statistic",
    LPAD(CONCAT(FORMAT(DAT/POWER(1024,pw1),2),' ',
    SUBSTR(units,pw1*2+1,2)),17,' ') "Data Size",
    LPAD(CONCAT(FORMAT(NDX/POWER(1024,pw2),2),' ',
    SUBSTR(units,pw2*2+1,2)),17,' ') "Index Size",
    LPAD(CONCAT(FORMAT(TBL/POWER(1024,pw3),2),' ',
    SUBSTR(units,pw3*2+1,2)),17,' ') "Total Size"
FROM
(
    SELECT DB,ENGINE,DAT,NDX,TBL,
    IF(px>4,4,px) pw1,IF(py>4,4,py) pw2,IF(pz>4,4,pz) pw3
    FROM
    (SELECT *,
        FLOOR(LOG(IF(DAT=0,1,DAT))/LOG(1024)) px,
        FLOOR(LOG(IF(NDX=0,1,NDX))/LOG(1024)) py,
        FLOOR(LOG(IF(TBL=0,1,TBL))/LOG(1024)) pz
    FROM
    (SELECT
        DB,ENGINE,
        SUM(data_length) DAT,
        SUM(index_length) NDX,
        SUM(data_length+index_length) TBL
    FROM
    (
       SELECT table_schema DB,ENGINE,data_length,index_length FROM
       information_schema.tables WHERE table_schema NOT IN
       ('information_schema','performance_schema','mysql')
       AND ENGINE IS NOT NULL
    ) AAA GROUP BY DB,ENGINE WITH ROLLUP
) AAA) AA) A,(SELECT ' BKBMBGBTB' units) B;
```


#### find the selectivity of several prefix lengths in one query

``` sql

  SELECT COUNT(DISTINCT LEFT(city, 3))/COUNT(*) AS sel3,
   COUNT(DISTINCT LEFT(city, 4))/COUNT(*) AS sel4,
   COUNT(DISTINCT LEFT(city, 5))/COUNT(*) AS sel5,
   COUNT(DISTINCT LEFT(city, 6))/COUNT(*) AS sel6,
   COUNT(DISTINCT LEFT(city, 7))/COUNT(*) AS sel7
  FROM sakila.city;
```

#### [find out the best prefix length for a given column](https://stackoverflow.com/questions/8746207/1071-specified-key-was-too-long-max-key-length-is-1000-bytes)

``` sql

  SELECT
   ROUND(SUM(LENGTH(`menu_link`)<10)*100/COUNT(*),2) AS length_10,
   ROUND(SUM(LENGTH(`menu_link`)<20)*100/COUNT(*),2) AS length_20,
   ROUND(SUM(LENGTH(`menu_link`)<50)*100/COUNT(*),2) AS length_50,
   ROUND(SUM(LENGTH(`menu_link`)<100)*100/COUNT(*),2) AS length_100
  FROM `pds_core_menu_items`;
```

#### [obtains the list of tables without primary key](https://moiseevigor.github.io/programming/2015/02/17/find-all-tables-without-primary-key-in-mysql/)

``` sql

  USE INFORMATION_SCHEMA;
  SELECT
      TABLES.table_name
  FROM TABLES
  LEFT JOIN KEY_COLUMN_USAGE AS c
  ON (
         TABLES.TABLE_NAME = c.TABLE_NAME
     AND c.CONSTRAINT_SCHEMA = TABLES.TABLE_SCHEMA
     AND c.constraint_name = 'PRIMARY'
  )
  WHERE
      TABLES.table_schema <> 'information_schema'
  AND TABLES.table_schema <> 'performance_schema'
  AND TABLES.table_schema <> 'mysql'
  AND c.constraint_name IS NULL;
```

#### [Remove duplicates using only a MySQL query](https://stackoverflow.com/questions/3383898/remove-duplicates-using-only-a-mysql-query?noredirect=1&lq=1)

```sql
-- This will leave the ones with the highest URL_ID for a particular URL_ADDR
-- (The derived table 'X' is to avoid the error "You can't specify target table 'tablename' for update in FROM clause")
DELETE FROM table
WHERE URL_ID NOT IN
    (SELECT ID FROM
       (SELECT MAX(URL_ID) AS ID
        FROM table
        WHERE URL_ID IS NOT NULL
        GROUP BY URL_ADDR ) X)   /*Sounds like you would need to GROUP BY a
                                   calculated form - e.g. using REPLACE to
                                  strip out www see Daniel's answer*/


-- Another case:
CREATE TABLE mytb (url_id int, url_addr varchar(100));

INSERT INTO mytb VALUES (1, 'www.google.com'), (2, 'www.microsoft.com'),(3, 'www.apple.com'),
  (4, 'www.google.com'), (5, 'www.cnn.com'), (6, 'www.apple.com');

-- Then we can use the multiple-table DELETE syntax as follows:

DELETE t2
FROM   mytb t1
JOIN   mytb t2 ON (t2.url_addr = t1.url_addr AND t2.url_id > t1.url_id);

-- ... which will delete duplicate entries, leaving only the first url based on url_id:

-- If the duplicate URLs will not have the same format, you may want to apply the REPLACE() function to remove www. or http:// parts. For example:

DELETE t2
FROM   mytb t1
JOIN   mytb t2 ON
  (REPLACE(t2.url_addr, 'www.', '') = REPLACE(t1.url_addr, 'www.', '') AND
                   t2.url_id > t1.url_id);

```

### Installation

#### 查找 my.cnf 位置

`/etc/init/mysql.conf`
mysql --help | grep /my.cnf | xargs ls
/etc/my.cnf /etc/mysql/my.cnf /usr/local/etc/my.cnf ~/.my.cnf
find the mysql data directory by `grep datadir /etc/my.cnf` or
`mysql -u USER -p -e 'SHOW VARIABLES WHERE Variable_Name LIKE "%dir"'`
`mysql -u USER -p -e 'SHOW VARIABLES WHERE Variable_Name = "datadir"'`

`select @@datadir;` select the data directory

#### CentOS

``` bash
  # mysql 5.6
  wget http://repo.mysql.com/mysql-community-release-el6-5.noarch.rpm
  rpm -ivh mysql-community-release-el6-5.noarch.rpm
  yum install mysql-server
  # startup
  /etc/init.d/mysqld start
  # configure
  mysql_secure_installation


  #UNINSTALL
  # stop
  /etc/init.d/mysqld stop
  # list pacages installed
  rpm -qa | grep mysql
  # uninstall
  yum remove mysql mysql-server mysql-libs compat-mysql51
  # remove configuration files
  rm -rf /var/lib/mysql /etc/my.cnf
```

#### start/stop

`sudo systemctl start/stop/status mysql`
`sudo systemctl status mysql`
`sudo systemctl start mysql`
`sudo systemctl stop mysql`

`./mysqld_safe` start MySQL server
`service mysql stop`, `service mysql start` Ubuntu start MySQL
`sudo /etc/init.d/mysql start`  start mysql server on ubuntu
`sudo /etc/init.d/mysql restart`  restart mysql server on ubuntu

#### Mac

install with `brew install mysql`
To restart mysql after an upgrade: `brew services restart mysql`
Or, if you don't want/need a background service you can just run: `/opt/homebrew/opt/mysql/bin/mysqld_safe --datadir=/opt/homebrew/var/mysql`

#### Windows

1. unzip
2. `mysqld --defaults-file=..\my.ini --initialize-insecure` to init
3. `mysqld --console` to start
4. `mysql -u root --skip-password` to connect
5. `ALTER USER 'root'@'localhost' IDENTIFIED BY 'root';` to update password
6. `mysqladmin -u root shutdown` to shutdown mysql server

7. `mysqld --install` to install as a service
8. `net start/stop  mysql` to start/stop mysql server as a service
9. `mysqld --remove` to remove mysql service

#### 修改密码

格式: `mysqladmin -u username -pPWD_OLD password PWD_NEW`

1. 给root加个密码`PWD_OLD`。首先进入目录mysql\bin，然后键入以下命令
 `mysqladmin -u root -password PWD_NEW`
注：因为开始时root没有密码，所以-p旧密码一项就可以省略了
2. 再将root的密码改为PWD_NEW
`mysqladmin -u root -pPWD_OLD password PWD_NEW`
命令行修改root密码: `UPDATE mysql.user SET password=PASSWORD('新密码') WHERE User='root'`;
3. [忘记 root 密码](https://help.aliyun.com/knowledge_detail/42520.html)

##### Linux

1. `vim /etc/my.cnf`
    `[mysqld]skip-grant-tables  #增加`
2. `/etc/init.d/mysqld restart`
3. `mysql`
4. `UPDATE user SET password = 'root' WHERE User = 'root' ;`
5. `flush privileges ;`
6. 删除`my.cnf`的 `spip-grant-tables`
7. 重启 MySQL 服务

### MySQL Shell Commands

[3.1 MySQL Shell Commands](https://dev.mysql.com/doc/mysql-shell/8.0/en/mysql-shell-commands.html)
[mysql Tips Input-Line Editing](https://dev.mysql.com/doc/refman/5.7/en/mysql-tips.html )

`help` to get List of all MySQL commands
`clear     (\c)` Clear the current input statement.
`status    (\s)` Get status information from the server.
`edit      (\e)` Edit command with $EDITOR. like CTRL+X,E in bash
`ego       (\G)` Send command to mysql server, display result vertically.
`nopager   (\n)` Disable pager, print to stdout.
`pager     (\P)` Set PAGER [to_pager]. Print the query results via PAGER.
`tee       (\T)` Set outfile [to_outfile]. Append everything into given outfile.
`system    (\!)` Execute a system shell command.

`pager less`, `pager less -n -i -S`
From `man less`:
`-i` Causes searches to ignore case
`-n` Suppresses line numbers
`-S` Causes lines longer than the screen width to be chopped rather than folded.

When code starts with something like this `/*!50100`, the code following till `*/` is executed only, when MySQL is installed in a version above 5.0.100

#### Autocompletion in the MySQL command-line client

Edit or create a file called .my.cnf in your home directory, containing:

``` config
  [mysql]
  auto-rehash
```

#### Input-Line Editing

[MySQL Tips](https://dev.mysql.com/doc/refman/5.7/en/mysql-tips.html )
echo bind "^W" ed-delete-prev-word > .editrc
echo bind "^U" vi-kill-line-prev >> .editrc

#### editline(libedit) vs. readline

try mysql command with `alt+.` to input last word in last command
MySQL 5.7.x on ubuntu 16.04 is compiled using editline library not readline
`mysql --version`
mysql  Ver 14.14 Distrib 5.7.17, for Linux (x86_64) using  EditLine wrapper, [MySQL EditLine](https://bugs.launchpad.net/percona-server/+bug/1266386)

#### MySQL Workbench update shortcut Auto-complete

D:\ProgramFiles\MySQL Workbench 6.3.3 CE (winx64)\data\main_menu.xml
/usr/share/mysql-workbench/data/main_menu.xml

### mysql_config_editor — MySQL Configuration Utility

[MySQL 8.0 Reference Manual :: 4.6.7 mysql_config_editor — MySQL Configuration Utility](https://dev.mysql.com/doc/refman/8.0/en/mysql-config-editor.html)

```sh
# -h,–host=name 添加host到登陆文件中
# -G，–login-path=name 在登录文件中为login path添加名字（默认为client）
# -p,–password 在登陆文件中添加密码（该密码会被mysql_config_editor自动加密）
# -u，–user 添加用户名到登陆文件中
# -S,–socket=name 添加sock文件路径到登陆文件中
# -P，–port=name 添加登陆端口到登陆文件中

mysql_config_editor print --all             #显示所有的login-path信息
mysql_config_editor print --login-path=test #显示执行的login-path配置
mysql_config_editor set --login-path=client --host=localhost --user=root --port=3306 --password
mysql_config_editor remove --login-path=test # 删除配置

mysql --login-path=client # defalut 是 client
```

## Transaction

[Using the Transaction Information Schema Tables](https://dev.mysql.com/doc/innodb-plugin/1.0/en/innodb-information-schema-examples.html)
`begin`, `start transaction`, `set autocommit=0`
`end`, `commit`, `rollback`

SELECT @@GLOBAL.tx_isolation, @@tx_isolation, @@session.tx_isolation;
`SELECT @@global.tx_isolation;`  查看InnoDB系统级别的事务隔离级别
`SELECT @@tx_isolation;`  查看InnoDB会话级别的事务隔离级别
`SET global transaction isolation level read committed;`  修改InnoDB系统级别的事务隔离级别
`SET session transaction isolation level read committed;`  修改InnoDB会话级别的事务隔离级别
`set innodb_lock_wait_timeout=100`
`show variables like 'innodb_lock_wait_timeout';`
`show engine innodb status`   to get a list of all the actions currently pending inside the InnoDB engine

### FORCE UNLOCK for locked tables in MySQL

`show open tables where in_use>0;`  get the list of locked tables
`show processlist;`  get the list of the current processes, one of them is locking your table(s)
`kill <put_process_id_here>;`   Kill one of these processes

### 事务隔离模式

1. `READ UNCOMMITED` SELECT的时候允许脏读，即SELECT会读取其他事务修改而还没有提交的数据。脏读
2. `READ COMMITED` SELECT的时候无法重复读，即同一个事务中两次执行同样的查询语句，若在第一次与第二次查询之间时间段，其他事务又刚好修改了其查询的数据且提交了，则两次读到的数据不一致。不可重复读
3. `REPEATABLE READ` SELECT的时候可以重复读，即同一个事务中两次执行同样的查询语句，得到的数据始终都是一致的。实现的原理是，在一个事务对数据行执行读取或写入操作时锁定了这些数据行。
    但是这种方式又引发了幻读的问题(MySQL InnoDB 通过 MVCC, Mutipleversion Concurrency Control 解决了幻读问题)。
    因为只能锁定读取或写入的行，不能阻止另一个事务插入数据，后期执行同样的查询会产生更多的结果。
4. `SERIALIZABLE` 与可重复读的唯一区别是，默认把普通的SELECT语句改成SELECT … LOCK IN SHARE MODE。即为查询语句涉及到的数据加上共享琐，阻塞其他事务修改真实数据。SERIALIZABLE模式中，事务被强制为依次执行。这是SQL标准建议的默认行为。

[14.5.2.1 Transaction Isolation Levels](https://dev.mysql.com/doc/refman/5.6/en/innodb-transaction-isolation-levels.html)
[Innodb中的事务隔离级别和锁的关系](https://tech.meituan.com/2014/08/20/innodb-lock.html)

脏读（dirty read）
不可重复读（unrepeatable read）
幻读（phantom read）：The so-called phantom problem occurs within a transaction when the same query produces different sets of rows at different times.
幻读和不可重复读区别: 幻读是指其他事务的新增(insert)数据，不可重复读是指其他事务的更改数据（update, delete）
为了避免这两种情况，采取的对策是不同的，防止读取到更改数据，只需要对操作的数据添加行级锁，阻止操作中的数据发生变化，

而防止读取到新增数据，则往往需要添加表级锁——将整个表锁定，防止新增数据（Oracle使用多版本数据的方式实现）

### MVCC

[面试必问的 MySQL，你懂了吗？ - 知乎](https://zhuanlan.zhihu.com/p/150089208)

[MySQL 8.0 MVCC 核心原理解析（核心源码） - 知乎](https://zhuanlan.zhihu.com/p/286775643)

MVCC 只作用于 RC（Read Committed）和 RR（Repeatable Read）级别，因为 RU（Read Uncommitted）总是读取最新的数据版本，而不是符合当前事务版本的数据行。而 Serializable 则会对所有读取的行都加锁。这两种级别都不需要 MVCC 的帮助。

以 RR 级别为例：每开启一个事务时，系统会给该事务会分配一个事务 Id，在该事务执行第一个 select 语句的时候，会生成一个当前时间点的事务快照 ReadView，主要包含以下几个属性：

trx_ids：生成 ReadView 时当前系统中活跃的事务 Id 列表，就是还未执行事务提交的。
up_limit_id：低水位，取 trx_ids 中最小的那个，trx_id 小于该值都能看到。
low_limit_id：高水位，生成 ReadView 时系统将要分配给下一个事务的id值，trx_id 大于等于该值都不能看到。
creator_trx_id：生成该 ReadView 的事务的事务 Id。

以上内容是对于 RR 级别来说，而对于 RC 级别，其实整个过程几乎一样，唯一不同的是生成 ReadView 的时机，

* RR 级别只在事务开始时生成一次，之后一直使用该 ReadView。
* RC 级别则在每次 select 时，都会生成一个 ReadView。

#### MVCC 解决了幻读了没有

* 快照读：生成一个事务快照（ReadView），之后都从这个快照获取数据。普通 select 语句就是快照读。
* 当前读：读取数据的最新版本。常见的 update/insert/delete、还有 select ... for update、select ... lock in share mode 都是当前读。

对于快照读，MVCC 因为因为从 ReadView 读取，所以必然不会看到新插入的行，所以天然就解决了幻读的问题。

而对于当前读的幻读，MVCC 是无法解决的。需要使用 Gap Lock 或 Next-Key Lock（Gap Lock + Record Lock）来解决。

#### 经常有人说 Repeatable Read 解决了幻读是什么情况

SQL 标准中规定的 RR 并不能消除幻读，但是 MySQL 的 RR 可以，靠的就是 Gap 锁。在 RR 级别下，Gap 锁是默认开启的，而在 RC 级别下，Gap 锁是关闭的。

### 锁机制

```sql
SHOW ENGINE INNODB STATUS\G;

-- 5.6 查询锁
SELECT*FROM information_schema.INNODB_LOCKS;
-- mysql 8 查询锁
select * FROM performance_schema.data_locks WHERE LOCK_TYPE="TABLE";
```

1. 共享锁：由读表操作加上的锁，加锁后其他用户只能获取该表或行的共享锁，不能获取排它锁，也就是说只能读不能写
2. 排它锁：由写表操作加上的锁，加锁后其他用户不能获取该表或行的任何锁，典型是mysql事务中的

锁的范围:
行锁: 对某行记录加上锁
表锁: 对整个表加上锁
共享锁(share mode), 排他锁(for update)

不想向数据表中插入相同的主键、unique索引时，可以使用replace或insert ignore，来避免重复的数据。
`replace into`  相当于delete然后insert，会有对数据进行写的过程。
`insert ignore`  会忽略已经存在主键或unique索引的数据，而不会有数据的修改
使用场景:
    如果不需要对数据进行更新值，那么推荐使用insert ignore，比如：多线程的插入相同的数据
    如果需要对数据进行更新最新的值，那么使用replace，比如：任务的结果，最后的更新时间

### [InnoDB的七种锁](https://mp.weixin.qq.com/s/f4_o-6-JEbIzPCH09mxHJg)

1. 自增锁(Auto-inc Locks)：表级锁，专门针对事务插入AUTO_INC的列，如果插入位置冲突，多个事务会阻塞，以保证数据一致性；
2. 共享/排它锁(Shared and Exclusive Locks)：行级锁，S锁与X锁，强锁；
3. 意向锁(Intention Locks)：表级锁，IS锁与IX锁，弱锁，仅仅表明意向，意向锁只会和表级的X，S发生冲突，不会与行级的共享 / 排他锁互斥；
4. 插入意向锁(Insert Intention Locks)：针对insert的，如果插入位置不冲突，多个事务不会阻塞，以提高插入并发；
5. 记录锁(Record Locks)：索引记录上加锁，对索引记录实施互斥，以保证数据一致性；
6. 间隙锁(Gap Locks)：封锁索引记录中间的间隔，在RR下有效，防止间隔中被其他事务插入，防止“不可重复读”；
7. 临键锁(Next-key Locks)：封锁索引记录，以及索引记录中间的间隔，在RR下有效，防止“幻读”；

InnoDB的锁，与索引类型，事务的隔离级别相关

#### 各种SQL到底加了什么锁

[MySQL 8.0 15.7.3 Locks Set by Different SQL Statements in InnoDB](https://dev.mysql.com/doc/refman/8.0/en/innodb-locks-set.html)

##### 普通select加什么锁

1. 在读未提交(Read Uncommitted)，读提交(Read Committed, RC)，可重复读(Repeated Read, RR)这三种事务隔离级别下，普通select使用快照读(snpashot read)，不加锁，并发非常高；
2. 在串行化(Serializable)这种事务的隔离级别下，普通select会升级为select ... in share mode;

##### 加锁select加什么锁

加锁select主要是指：

* select ... for update
* select ... in share mode

1. 如果，在唯一索引(unique index)上使用唯一的查询条件(unique search condition)，会使用记录锁(record lock)，而不会封锁记录之间的间隔，即不会使用间隙锁(gap lock)与临键锁(next-key lock)；
2. 其他的查询条件和索引条件，InnoDB会封锁被扫描的索引范围，并使用间隙锁与临键锁，避免索引范围区间插入记录；

##### update与delete加什么锁

1. 和加锁select类似，如果在唯一索引上使用唯一的查询条件来update/delete，例如： `update t set name=xxx where id=1;` 也只加记录锁
2. 否则，符合查询条件的索引记录之前，都会加排他临键锁(exclusive next-key lock)，来封锁索引记录与之前的区间；
3. 尤其需要特殊说明的是，如果update的是聚集索引(clustered index)记录，则对应的普通索引(secondary index)记录也会被隐式加锁，这是由InnoDB索引的实现机制决定的：普通索引存储PK的值，检索普通索引本质上要二次扫描聚集索引。

##### insert加什么锁？

同样是写操作，insert和update与delete不同，它会用排它锁封锁被插入的索引记录，而不会封锁记录之前的范围。

同时，会在插入区间加插入意向锁(insert intention lock)，但这个并不会真正封锁区间，也不会阻止相同区间的不同KEY插入。

insert时，当对存在的行进行锁的时候(主键)，mysql就只有行锁。当对未存在的行进行锁的时候(即使条件为主键)，mysql是会锁住一段范围（有gap锁）

`insert into t3(xx,xx) on duplicate key update xx='XX';` 这个特有的 insert 语法语句, 对于主键来说，插入的行不管有没有存在，都会只有行锁

### Example: 数据库插入数据时加锁 多线程(多job)重复insert

1. `insert into test.test_sql_type select 26,'name25',9,1,now() from dual where not exists (select * from test.test_sql_type where id = 26);`
2. `select ... for update`, then insert
 it locks the whole table, other process will pending to get the lock when select the table, so no one can insert into it.
3. `insert ignore`
 [innodb-locking-reads](http://dev.mysql.com/doc/refman/5.7/en/innodb-locking-reads.html)
`insert ignore`会忽略已经存在主键或unique索引的数据，而不会有数据的修改。
 [mysql-insert-ignore-different-replace-into](http://www.chenyudong.com/archives/mysql-insert-ignore-different-replace-into.html)
`insert ignore into table_name(email,phone,user_id) values('test9@163.com','99999','9999')`,这样当有重复记
录就会忽略,执行后返回数字0,还有个应用就是复制表,避免重复记录:
`insert ignore into table(name)  select  name from table2`
4. 额外的表记录一个标示flag表示默认为N 没有JOB执行，第一个服务器进入JOB 把这个标示给更新成Y那么会成功返回update条数1，其他的三台机器则会update条数为0所以 if判断一下就好，然后在正常执行完和异常代码块里都还原一下

#### reference [select-for-update-with-insert-into](http://stackoverflow.com/questions/21261213/select-for-update-with-insert-into)

`SELECT ... FOR UPDATE` with UPDATE

Using transactions with InnoDB (auto-commit turned off), a SELECT ... FOR UPDATE allows one session to temporarily lock down a particular record (or records) so that no other session can update it. Then, within the same transaction, the session can actually perform an UPDATE on the same record and commit or roll back the transaction. This would allow you to lock down the record so no other session could update it while perhaps you do some other business logic.

This is accomplished with locking. InnoDB utilizes indexes for locking records, so locking an existing record seems easy--simply lock the index for that record.

`SELECT ... FOR UPDATE` with INSERT

However, to use SELECT ... FOR UPDATE with INSERT, how do you lock an index for a record that doesn't exist yet? If you are using the default isolation level of REPEATABLE READ, InnoDB will also utilize gap locks. As long as you know the id (or even range of ids) to lock, then InnoDB can lock the gap so no other record can be inserted in that gap until we're done with it.

If your id column were an auto-increment column, then SELECT ... FOR UPDATE with INSERT INTO would be problematic because you wouldn''t know what the new id was until you inserted it. However, since you know the id that you wish to insert, SELECT ... FOR UPDATE with INSERT will work.

#### test case

select nonexistent orderId, which is not a index column, it will lock the whole table;
select nonexistent id, which is the PRIMARY KEY, it cannot lock any row;

``` sql
  CREATE TABLE `test_sql_type` (
    `id` bigint(32) NOT NULL AUTO_INCREMENT,
    `orderId` int(8) DEFAULT NULL COMMENT 'another int',
    PRIMARY KEY (`id`)
  ) ENGINE=InnoDB AUTO_INCREMENT=46 DEFAULT CHARSET=utf8 COMMENT='测试类型表';
```

console 1:

``` sql
  begin;
  select * from test_sql_type where orderId = 41 for update;
```

orderId 41 is not a existing row.
it gets the lock of the whole table;

console 2:

``` sql
  begin;
  select * from test_sql_type where orderId = 41 for update;
  **pending**
```

It pending to get the lock.

## 内存使用

[RDS MySQL如何查看消耗内存高的事件和线程](https://help.aliyun.com/document_detail/127477.htm)

### [MySQL 实际内存分配情况介绍](https://help.aliyun.com/document_detail/51799.htm)

共享内存

```sql
show variables where variable_name in (
'innodb_buffer_pool_size','innodb_log_buffer_size','innodb_additional_mem_pool_size','key_buffer_size','query_cache_size'
);
+-------------------------+------------+
| Variable_name           | Value      |
+-------------------------+------------+
| innodb_buffer_pool_size | 8589934592 |
| innodb_log_buffer_size  | 8388608    |
| key_buffer_size         | 16777216   |
+-------------------------+------------+
```

#### Session 私有内存

```sql
show variables where variable_name in (
'read_buffer_size','read_rnd_buffer_size','sort_buffer_size','join_buffer_size','binlog_cache_size','tmp_table_size'
);
+----------------------+---------+
| Variable_name        | Value   |
+----------------------+---------+
| binlog_cache_size    | 1048576 |
| join_buffer_size     | 1048576 |
| read_buffer_size     | 1048576 |
| read_rnd_buffer_size | 262144  |
| sort_buffer_size     | 2097152 |
| tmp_table_size       | 2097152 |
+----------------------+---------+
```

### [How to find out the memory cost of each mysql connection? - Server Fault](https://serverfault.com/questions/92056/how-to-find-out-the-memory-cost-of-each-mysql-connection)

```sql

--  see how much memory is being used in MySQL:
SHOW ENGINE INNODB STATUS;

-- Maximum memory per connection
-- If you want to know the maximum amount a connection can possibly use, it's this query:


SELECT ( @@read_buffer_size
+ @@read_rnd_buffer_size
+ @@sort_buffer_size
+ @@join_buffer_size
+ @@binlog_cache_size
+ @@thread_stack
+ @@tmp_table_size
+ 2*@@net_buffer_length
) / (1024 * 1024) AS MEMORY_PER_CON_MB;

-- query each item
SELECT @@read_buffer_size, @@read_rnd_buffer_size, @@sort_buffer_size, @@join_buffer_size, @@binlog_cache_size, @@thread_stack , @@tmp_table_size , 2*@@net_buffer_length ;

```

## I/O

1. `innodb_flush_log_at_trx_commit` 2
   1. 0 把日志缓冲写到日志文件，并且每秒钟刷新一次，但是事务提交时不做任何事。该模式速度最快，但不太安全，mysqld进程的崩溃会导致上一秒钟所有事务数据的丢失。
   2. 1 事务提交时，把事务日志从缓存区写到日志文件中，并且立刻写入到磁盘上。该模式是最安全的，但也是最慢的一种方式。在mysqld服务崩溃或者服务器主机宕机的情况下，日志缓存区只有可能丢失最多一个语句或者一个事务。
   3. 2 事务提交时，把事务日志从缓存区写到日志文件中，但不一定立刻写入到磁盘上。日志文件会每秒写入到磁盘，如果写入前系统崩溃，就会导致最后1秒的日志丢失。该模式速度较快，较取值为0情况下更安全，只有在操作系统崩溃或者系统断电的情况下，上一秒钟所有事务数据才可能丢失。
2. `sync_binlog` 1000
   1. 1 事务提交后，将二进制日志文件写入磁盘并立即刷新，相当于同步写入磁盘，不经过系统缓存。是最安全的值，但也是最慢的
   2. 1000 每写入1000次系统缓存就执行一次写入磁盘并刷新的操作，会有数据丢失的风险。

### O_DIRECT

这个设置依然使用fsync() 来刷新文件到磁盘，但是会通知操作系统不要缓存数据，也不要用预读。这个选项完全关闭了操作系统缓存，并且使所有的读和写都直接通过存储设备，避免了双重缓冲。

在大部分系统上，这个实现用fcntl() 调用来设置文件描述符的O_DIRECT 标记，所以可以阅读fcntl(2) 的手册页来了解系统上这个函数的细节。

如果使用O_DIRECT 选项，通常需要带有写缓存的RAID卡，并且设置为Write-Back策略 (16) ，因为这是典型的唯一能保持好性能的方法。

### Doublewrite Buffer

[MySQL 8.0 Reference Manual :: 15.6.4 Doublewrite Buffer](https://dev.mysql.com/doc/refman/8.0/en/innodb-doublewrite-buffer.html)

[InnoDB关键特性之double write - GeaoZhang - 博客园](https://www.cnblogs.com/geaozhang/p/7241744.html)

[double write buffer，你居然没听过？- 架构师之路 沈剑](https://mp.weixin.qq.com/s/bkoQ9g4cIcFFZBnpVh8ERQ)

#### doublewrite 解决的问题

脏页刷盘风险

关于IO的最小单位：

1. 数据库IO的最小单位是16K（MySQL默认，oracle是8K）
2. 文件系统IO的最小单位是4K（也有1K的）
3. 磁盘IO的最小单位是512字节

因此，存在IO写入导致page损坏的风险：

Doublewrite Buffer 提高innodb的可靠性，用来解决部分写失败(partial page write页断裂)。

出现问题的原因是**写磁盘不是原子操作，不能保证数据完整性**

#### Doublewrite Buffer 流程

当有页数据要刷盘时：

1. 页数据先memcopy到DWB的内存里；
2. DWB的内存里，会先刷到DWB的磁盘上；
3. DWB的内存里，再刷到数据磁盘存储上；

DWB由128个页构成，容量只有2M。

分析：

1. DWB的内存的目的是 先不修改磁盘数据，这样避免写失败损坏老数据，保留完整的老的磁盘数据；
2. 如果DWB的内存 完整写完，那新数据就保留下来了，无论磁盘数据是否已经修改，新数据是完整的；
3. 如果 DWB 的内存没有完整写完，老的磁盘数据还没有修改，老数据是完整的。

类比：新老数据各一份，只是修改指针指向，这样是一个原子操作。

#### Doublewrite Buffer 副作用

1. Doublewrite 是一个buffer, 但其实它是开在物理文件上的一个buffer, 其实也就是file, 所以它会导致系统有更多的fsync操作, 而硬盘的fsync性能是很慢的, 所以它会降低mysql的整体性能。

2. 但是，doublewrite buffer写入磁盘共享表空间这个过程是连续存储，是顺序写，性能非常高，(约占写的%10)，牺牲一点写性能来保证数据页的完整还是很有必要的。

## MySQL线上常见故障剖析

–活动进程(Process list)
–日志文件(slow log, alert log, general query log, binlog)
–Status variables（com_select, com_insert,.etc)
–InnoDB(物理读、逻辑读、innodbstatus)
–参数配置
–Stack trace(plus source code)
•SQL
–执行计划，explain
•OS
–内存, SWAP, /proc/meminfo
–CPU, load, ps
–IO（磁盘、网络)
•Iostat
•Profile
–Oprofile
–gprof

## Performance

[MySQL性能优化的最佳20+条经验](http://coolshell.cn/articles/1846.html )
[MySQL 5.6 Reference Manual 8.6.1 Optimizing MyISAM Queries](https://dev.mysql.com/doc/refman/5.6/en/optimizing-queries-myisam.html )

### MySQL调优

1. mysql嵌套子查询效率确实比较低
2. 可以将其优化成连接查询
3. 连接表时，可以先用where条件对表进行过滤，然后做表连接 (虽然mysql会对连表语句做优化)
4. 建立合适的索引
5. 学会分析sql执行计划，mysql会对sql进行优化，所以分析执行计划很重要

制定适当的存储引擎和字符编码
例如:MySQL中强事务业务使用InnoDB，弱事务业务使用MyISAM，字符编码使用utf8_bin，ORACLE中无需制定存储引擎，只需要制定字符编码UTF-8
mysql线上将采用一master多slave的方式来进行部署

### MySQL Query Cache

[8.10.3 The MySQL Query Cache](https://dev.mysql.com/doc/refman/5.6/en/query-cache.html )
The have_query_cache server system variable indicates whether the query cache is available `SHOW VARIABLES LIKE 'have_query_cache';`
The server does not use the query cache. `SELECT SQL_NO_CACHE id, name FROM customer;`

### [优化建议 -- 知乎哈哈](https://www.zhihu.com/question/19719997/answer/81930332)

第一优化你的sql和索引；
第二加缓存，memcached,redis；
第三以上都做了后，还是慢，就做主从复制或主主复制，读写分离，可以在应用层做，效率高，也可以用三方工具，第三方工具推荐360的atlas,其它的要么效率不高，要么没人维护；
第四如果以上都做了还是慢，不要想着去做切分，mysql自带分区表，先试试这个，对你的应用是透明的，无需更改代码,但是sql语句是需要针对分区表做优化的，sql条件中要带上分区条件的列，从而使查询定位到少量的分区上，否则就会扫描全部分区，另外分区表还有一些坑，在这里就不多说了；
第五如果以上都做了，那就先做垂直拆分，其实就是根据你模块的耦合度，将一个大的系统分为多个小的系统，也就是分布式系统；
第六才是水平切分，针对数据量大的表，这一步最麻烦，最能考验技术水平，要选择一个合理的sharding key,为了有好的查询效率，表结构也要改动，做一定的冗余，应用也要改，sql中尽量带sharding key，将数据定位到限定的表上去查，而不是扫描全部的表；
mysql数据库一般都是按照这个步骤去演化的，成本也是由低到高；

### Slow log

#### Slow log options

`show variables  like '%slow_query_log%'`  Query slow log status
`set global slow_query_log=1`  Start recording slow log, 开启了慢查询日志只对当前数据库生效，如果MySQL重启后则会失效
`slow_query_log = 1`  开启慢日志永久生效，必须修改配置文件`~/.my.cnf`, `/etc/my.cnf`（其它系统变量也是如此）
`slow_query_log_file = /tmp/mysql_slow.log`  slow log location, default value: host_name-slow.log
`long_query_time=2`  慢查询阈值，当查询时间多于设定的阈值时，记录日志,默认10s
`log_queries_not_using_indexes`  未使用索引的查询也被记录到慢查询日志中（可选项）

#### MySQL日志分析工具 [mysqldumpslow](https://dev.mysql.com/doc/refman/5.7/en/mysqldumpslow.html )

* --help
* -a  Do not abstract all numbers to N and strings to 'S'.
* -g pattern  Consider only queries that match the (grep-style) pattern.
* -s  sort_type
  * t, at: Sort by query time or average query time
  * l, al: Sort by lock time or average lock time
  * r, ar: Sort by rows sent or average rows sent
  * c: Sort by count
* -t N  Display only the first N queries in the output.

##### mysqldumpslow Sample

`mysqldumpslow -s t -t 10 /var/lib/mysql/mysql-slow.log`  得到返回查询时间最长的10个SQL
`mysqldumpslow -s r -t 10 /var/lib/mysql/mysql-slow.log`  得到返回记录集最多的10个SQL
`mysqldumpslow -s c -t 10 /data/softwares/mysql/mysql06_slow.log`  得到访问次数最多的10个SQL

### 查询优化

deferred join延迟关联 `select <cols> from profiles inner join (select <primary key cols> from profiles where x.sex='M' order by rating limiting 100000,10) as x using (<primary key cols>)`

### explain

[EXPLAIN Output Format](https://dev.mysql.com/doc/refman/5.5/en/explain-output.html#explain-join-types )
[EXPLAIN Output Format 8.0](https://dev.mysql.com/doc/refman/8.0/en/explain-output.html)
[详解MySQL中EXPLAIN解释命令](https://www.cnblogs.com/phpfans/p/4213096.html )

`explain SQL` query;  then `show warnings` to get the raw SQL clause

[MySQL Internals Manual :: 8.1 Tracing the Optimizer Typical Usage](https://dev.mysql.com/doc/internals/en/optimizer-tracing-typical-usage.html)

#### EXPLAIN列的解释

* id 列 编号是 select 的序列号，有几个 select 就有几个id，并且id的顺序是按 select 出现的顺序增长的。 id列越大执行优先级越高，id相同则从上往下执行，id为NULL最后执行。
* select_type 表示对应行是简单还是复杂的查询,simple、primary（复杂查询中最外层的 select）、subquery（包含在 select 中的子查询，不在 from 子句中)、derived（包含在 from 子句中的子查询，结果存放在临时表）
* table：显示这一行的数据是关于哪张表的，当 from 子句中有子查询时，table列是 derivenN 格式，表示当前查询依赖 id=N 的查询
* type：这是重要的列，显示连接使用了何种类型。从最好到最差的连接类型为const、eq_reg、ref、range、index和ALL
* possible_keys：显示可能应用在这张表中的索引。如果为空，没有可能的索引。可以为相关的域从WHERE语句中选择一个合适的语句
* key: 实际使用的索引。如果为NULL，则没有使用索引。很少的情况下，MYSQL会选择优化不足的索引。这种情况下，可以在SELECT语句中使用USE INDEX（indexname）来强制使用一个索引或者用IGNORE INDEX（indexname）来强制MYSQL忽略索引
* key_len：使用的索引的长度。在不损失精确性的情况下，长度越短越好
* ref：显示了在key列记录的索引中，表查找值所用到的列或常量，常见的有:const(常量)，字段名(例: film.id)
* rows：mysql估计要读取并检测的行数，注意这个不是结果集里的行数。
* Extra：关于MYSQL如何解析查询的额外信息

#### Type

性能从最好到最差：system、const、eq_ref、ref、range、index和ALL

* const, system：mysql能对查询的某部分进行优化并将其转化成一个常量，用于 primary key 或 unique key 的所有列与常数比较
* eq_ref：primary key 或 unique key 索引的所有部分被连接使用 ，最多只会返回一条符合条件的记录
* ref：相比 eq_ref，不使用唯一索引，而是使用普通索引或者唯一性索引的部分前缀，索引要和某个值相比较， 可能会找到多个符合条件的行。
* range：范围扫描通常出现在 in(), between ,> ,<, >= 等操作中。使用一个索引来检索给定范围的行
* index：扫描全索引就能拿到结果，一般是扫描某个二级索引
* ALL：即全表扫描，扫描你的聚簇索引的所有叶子节点

#### 需要强调rows是核心指标

绝大部分rows小的语句执行一般很快。所以优化语句基本上都是在优化rows, 一般来说

* rows<1000，是在可接受的范围内的。
* rows在1000~1w之间，在密集访问时可能导致性能问题，但如果不是太频繁的访问(频率低于1分钟一次)，又难再优化的话，可以接受，但需要注意观察
* rows大于1万时，应慎重考虑SQL的设计，优化SQL

这个没有绝对值可参考，一般来说越小越好，，如果100万数据量的数据库，rows是70万，通过这个可以判断sql的查询性能很差，如果100万条数据量的数据库，rows是1万，从我个人的角度，还是能接受的。

#### extra 列

该列包含MySQL解决查询的详细信息

* Using index:使用覆盖索引，如果select后面查询的字段都可以从索引树中获取，这种情况一般可以说是用到了覆盖索引
* Using where:使用 where 语句来处理结果，并且查询的列未被索引覆盖
* Using index condition:查询的列不完全被索引覆盖，where条件中是一个前导列的范围;
* Using filesort：当Query 中包含order by 操作，而且无法利用索引完成排序操作的时候，MySQL Query Optimizer 不得不选择相应的排序算法来实现
* Using temporary：在某些操作中必须使用临时表时，在 Extra 信息中就会出现Using temporary ,主要常见于 GROUP BY 和 ORDER BY 等操作中

当执行计划Extra 出现Using filesort 、Using temporary 时，可以考虑是否需要进行sql优化和调整索引，最后再调整my.cnf 中与排序或者临时表相关的参数，如sort_buffer_size或者tmp_table_size.

### 建立索引原则

1. 最左前缀匹配原则，非常重要的原则，mysql会一直向右匹配直到遇到范围查询(>、<、between、like)就停止匹配，比如a = 1 and b = 2 and c > 3 and d = 4 如果建立(a,b,c,d)顺序的索引，d是用不到索引的，如果建立(a,b,d,c)的索引则都可以用到，a,b,d的顺序可以任意调整(keep the range criterion at the end of the index, so the optimizer will use as much of the index as possible)
2. =和in可以乱序，比如a = 1 and b = 2 and c = 3 建立(a,b,c)索引可以任意顺序，mysql的查询优化器会帮你优化成索引可以识别的形式
3. 尽量选择区分度高的列作为索引,区分度的公式是`count(distinct col)/count(*)`，表示字段不重复的比例，比例越大我们扫描的记录数越少，唯一键的区分度是1，而一些状态、性别字段可能在大数据面前区分度就是0，那可能有人会问，这个比例有什么经验值吗？使用场景不同，这个值也很难确定，一般需要join的字段我们都要求是0.1以上，即平均1条扫描10条记录
4. 索引列不能参与计算，保持列"干净"，比如from_unixtime(create_time) = '2014-05-29'就不能使用到索引，原因很简单，b+树中存的都是数据表中的字段值，但进行检索时，需要把所有元素都应用函数才能比较，显然成本太大。所以语句应该写成create_time = unix_timestamp('2014-05-29');
5. 尽量的扩展索引，不要新建索引。比如表中已经有a的索引，现在要加(a,b)的索引，那么只需要修改原来的索引即可

### MySQL压力测试

1. mysqlslap 的介绍及使用
2. sysbench
3. tpcc-mysql

### index

To see the index for a specific table use SHOW INDEX: `SHOW INDEX FROM yourtable;`
To see indexes for all tables within a specific schema: `SELECT DISTINCT TABLE_NAME,INDEX_NAME FROM INFORMATION_SCHEMA.STATISTICS where table_schema = 'account';`
mysql query escape %前面加两个反斜杠，比如
`select count(1) from tableName where column like '%关键字\\%前面的是一个百分号%'`

### 索引下推（index condition pushdown ）

联合索引 第一个条件 用了范围查询

1. 没有ICP的情况下 range+using where
2. ICP的情况下 range+using index condition

### Tracing the Optimizer

```sql
# Turn tracing on (it's off by default):
SET optimizer_trace="enabled=on";
SELECT ...; # your query here
SELECT * FROM INFORMATION_SCHEMA.OPTIMIZER_TRACE;
# possibly more queries...
# When done with tracing, disable it:
SET optimizer_trace="enabled=off";
```

### 优化 Order by

[MySQL 8.0 Reference Manual :: 8.2.1.16 ORDER BY Optimization](https://dev.mysql.com/doc/refman/8.0/en/order-by-optimization.html)

[MySQL排序内部原理探秘 - 云+社区 - 腾讯云](https://cloud.tencent.com/developer/article/1072184)

1. 排序和查询的字段尽量少。只查询你用到的字段，不要使用select * ；使用limit查询必要的行数据；
2. 优先添加合适的索引
   1. 使用索引得到排序的结果
   2. 使用索引筛选出数据
3. 使用 filesort
   1. 根据 system variable `sort_buffer_size`来判断是否能使用内存排序
      1. as of MySQL 8.0.12, the optimizer allocates memory buffers incrementally as needed, up to the size indicated by the `sort_buffer_size`
   2. A filesort operation **uses temporary disk files** as necessary if the result set is too large to fit in memory
   3. As of 8.0.20, `max_length_for_sort_data` is deprecated, 用来决定`sort_mode`，默认值是 1024，比较大时会走全字段排序，导致内存占用比较多，可能会使用临时文件辅助排序，导致性能降低。
   4. `max_sort_length` 控制放到 sort_buffer 的一行的数据大小。当MySQL必须排序BLOB 或TEXT 字段时，它只会把`max_sort_length`大小的前缀放到缓存，然后忽略剩下部分的值。（比如用户要查询的数据包含了 SUBSTRING_INDEX(col1, '.',2)）
   5. Increase the `read_rnd_buffer_size` variable value so that more rows are read at a time.
   6. Change the `tmpdir` system variable to point to a dedicated file system with large amounts of free space.
4. 使用 `optimizer trace` 查看判断过程 [MySQL Internals: Tracing the Optimizer](https://dev.mysql.com/doc/internals/en/optimizer-tracing.html).
   1. `optimizer trace` output includes a filesort_summary block
   2. `peak_memory_used` indicates the maximum memory used at any one time during the sort.
   3. The `sort_mode` value provides information about the contents of tuples in the sort buffer:
      1. `<sort_key, rowid>`: This indicates that sort buffer tuples are pairs that contain the sort key value and row ID
      2. `<sort_key, additional_fields>`: This indicates that sort buffer tuples contain the sort key value and columns referenced by the query
      3. `<sort_key, packed_additional_fields>`: Like the previous variant, but the additional columns are packed tightly together instead of using a fixed-length encoding.

Previously (MySQL 5.7 and lower), `GROUP BY` sorted implicitly under certain conditions. In MySQL 8.0, that no longer occurs, so specifying `ORDER BY NULL` at the end to suppress implicit sorting (as was done previously) is no longer necessary.

### 优化 Group by

[group by 怎么优化？](https://mp.weixin.qq.com/s/igGKepCsf-SUKChco4P6Lw)

[MySQL 8.0 Reference Manual :: 8.2.1.17 GROUP BY Optimization](https://dev.mysql.com/doc/refman/8.0/en/group-by-optimization.html)

Loose index scan的原理是只使用组合索引的前缀部分，而不是索引的全部键值

[MySQL :: What is the "(scanning)" variant of a loose index scan?](https://dev.mysql.com/blog-archive/what-is-the-scanning-variant-of-a-loose-index-scan/)

如果不能使用索引，Extra 里一般有 Using temporary 和 Using filesort

1. 分组字段加索引
2. order by null 不排序 （8.0 以前group by 会进行排序，之后就不会内部默认排序了）
3. 尽量使用内存临时表
4. 使用 `SQL_BIG_RESULT` 提示 MySQL 优化器直接用磁盘临时表。如果数据量实在过大，大到内存临时表都不够用了，这时就转向使用磁盘临时表。而发现不够用再转向这个过程也是很耗时的。

### B+树层数计算

在计算机中磁盘存储数据最小单元是扇区，一个扇区的大小是 512 字节，而文件系统（例如XFS/EXT4）他的最小单元是块，一个块的大小是 4k
而 InnoDB 存储引擎的最小储存单元一页（Page）的默认大小是 16K，page可以储存指针，也可以储存行记录，其中指针指向下一个page的地址

我们先假设有两层，第一层为非叶子节点，保存指针，第二层为叶子节点，保存具体行记录
那么两层高度的b+树能存储的数量 = 根节点指针数*每个指针对应第二层的行记录数

根节点指针数：B+树的非叶子节点仅保存索引字段和指针，假设主键为bigint类型，InnoDB 的bigint占用8个字节，指针占用6个字节，8+6=14，所以我们可以得出，一个page能存放的指针个数为16k/(8+6)约等于1170

每个指针对应第二层的行记录数：再来说说一个page能存储多少条行记录，常规的互联网项目单条行记录大小约为1k，那么一个page能存储的行记录数为16k/1k=16
所以一个2层高的b+树能存储的行记录数大约为`1170*16=18720`，3层为`1170*1170*16`约等于2190w

## 存储引擎 innodb 特点

[MySQL 8.0 Reference Manual :: 17 The InnoDB Storage Engine](https://dev.mysql.com/doc/refman/8.0/en/innodb-storage-engine.html)

1. Buffer Pool
2. Change Buffer
3. Double Write
4. Adaptive Hash Index
5. 异步 IO

## Replication

[17.1.1.8 Setting Up Replication with Existing Data](https://dev.mysql.com/doc/refman/5.6/en/replication-howto-existingdata.html)
If `--master-info-repository=TABLE`, the replication coordinates from the master is saved in the table `master_slave_info` in the mysql database

`SHOW SLAVE STATUS`

1. (`Master_Log_file, Read_Master_Log_Pos`): Coordinates in the master binary log indicating how far the slave I/O thread has read events from that log.
2. (`Relay_Master_Log_File, Exec_Master_Log_Pos`): Coordinates in the master binary log indicating how far the slave SQL thread has executed events received from that log.
3. (`Relay_Log_File, Relay_Log_Pos`): Coordinates in the slave relay log indicating how far the slave SQL thread has executed the relay log. These correspond to the preceding coordinates, but are expressed in slave relay log coordinates rather than master binary log coordinates.

### mysqlbinlog

[mysqlbinlog — Utility for Processing Binary Log Files](https://dev.mysql.com/doc/refman/5.7/en/mysqlbinlog.html)
[mysqlbinlog Row Event Display](https://dev.mysql.com/doc/refman/5.7/en/mysqlbinlog-row-events.html)
从MySQL binlog解析出你要的SQL [binlog2sql](https://github.com/danfengcao/binlog2sql)
A tool for parsing a MySQL binlog file to JSON. [binlog-parser](https://github.com/zalora/binlog-parser)
`GRANT SELECT, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'admin'@'IP' identified by 'pwd';`

bin log location default: /var/lib/mysql/binlog*
`ps -ef | grep mysql` to `--datadir=/data/local/mysql`
`show variables like 'datadir';`
`show variables like '%binlog%';`
`show variables like 'expire_logs_days';` binlog日志自动删除/过期的天数，默认值为0，表示不自动删除

`show master status` 查看当前正在写入的binlog文件
`show binary logs` Lists the binary log files on the server
`show variables like 'expire_logs_days';` 设置binlog的过期时间
`flush logs` 刷新log日志，自此刻开始产生一个新编号的binlog日志文件
`reset master` 重置(清空)所有binlog日志

`SHOW BINLOG EVENTS [IN 'log_name'] [FROM pos] [LIMIT [offset,] row_count];`
`show binlog events in 'mysql-bin.000021'\G`

`mysqlbinlog /path/to/binlog > tmpfile.sql`

* `--start-position=4`                   起始pos点
* `--stop-position=1024`                   结束pos点
* `--start-datetime="2013-11-29 13:18:54"` 起始时间点
* `--stop-datetime="2013-11-29 13:21:53"`  结束时间点
* `--database=dbname`                     指定只恢复dbname数据库(一台主机上往往有多个数据库，只限本地log日志)
* `--base64-output=decode-rows` 当bin-log的模式设置为row时（binlog_format=row）指定解码
* `--verbose, -v` The output will contain lines beginning with ###,
 Specify --verbose or -v twice to also display data types and some metadata for each column

* `--read-from-remote-server, -R` connect to a server and request its binary log
* `--user=name, -u`              Connect to the remote server as username.连接到远程主机的用户名
* `--password[=name], -p`        Password to connect to remote server.连接到远程主机的密码
* `--host=name, -h`              Get the binlog from server.从远程主机上获取binlog日志
* `--database=db_name, -d db_name`              Get the binlog from server.从远程主机上获取binlog日志

The original column names are lost and replaced by `@N`, where `N` is a column number. you can get column name from `INFORMATION_SCHEMA.COLUMNS`
`SELECT ORDINAL_POSITION,COLUMN_NAME, COLLATION_NAME, CHARACTER_SET_NAME, COLUMN_COMMENT, COLUMN_TYPE, COLUMN_KEY FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'db_name' AND TABLE_NAME = 'tbl_name';`

```sh
#  --include-gtids    截取指定的gtid
#  --exclude-gtids    排除指定的gtid
#  --skip-gtids       跳过gtid的幂等性机制的检查，即截取日志的时候不带有gtid的信息
mysqlbinlog --start-datetime="2018-02-16 19:25:10" --base64-output=decode-rows -v -v mysql-bin.000802 | less

# 包含 gtid 可以和 show slave status 返回的 Executed_Gtid_Set 对比看当前执行的 SQL
mysqlbinlog --no-defaults -v -v --base64-output=DECODE-ROWS mysql-bin.000802 > mysql-bin.000802.with.gtid.log

# 按执行次数统计 SQL
mysqlbinlog --no-defaults -v -v --base64-output=DECODE-ROWS --skip-gtids --start-datetime="2021-08-09 07:15:10" --stop-datetime="2021-08-09 07:25:10" mysql-bin.004157 | grep -Ew '### INSERT|### UPDATE|### DELETE' | awk '/###/ {if($0~/INSERT|UPDATE|DELETE/)count[$2" "$NF]++}END{for(i in count) print i,"\t",count[i]}' | column -t | sort -k3 -nr | head -n 20

# To execute events from the binary log, process mysqlbinlog output using the mysql client
mysqlbinlog binlog_files | mysql -u root -p

mysqlbinlog --read-from-remote-server -h localhost -uroot -p --base64-output=decode-rows -v -v binlog.000062
```

[Point-in-Time (Incremental) Recovery Using the Binary Log](https://dev.mysql.com/doc/refman/5.7/en/point-in-time-recovery.html)

### relay log

[MySQL 5.7 Reference Manual - The Slave Relay Log](https://dev.mysql.com/doc/refman/5.7/en/slave-logs-relaylog.html)
当slave不再使用时，通过`reset slave`来取消relaylog

### InnoDB的崩溃恢复过程

[InnoDB的崩溃恢复过程主要分为四个步骤](https://mp.weixin.qq.com/s/9lmuRJY1z87t1c9mAdYqdA)

[MySQL 8.0 Reference Manual :: 15.18.2 InnoDB Recovery](https://dev.mysql.com/doc/refman/8.0/en/innodb-recovery.html#innodb-crash-recovery)

1. redo log操作：保证已提交事务影响的最新数据刷到数据页里。从redo log中读取checkpoint LSN
2. undo log操作：保证未提交事务影响的数据页回滚。
3. 写缓冲(change buffer)合并。[写缓冲(change buffer)](https://mp.weixin.qq.com/s/PF21mUtpM8-pcEhDN4dOIw)
4. purge操作。InnoDB的一种垃圾收集机制，使用单独的后台线程周期性处理索引中标记删除的数据。

### 数据库主从同步延迟

[RDS MySQL只读实例同步延迟原因与处理](https://help.aliyun.com/document_detail/41767.html)
[记一次MySQL主从同步延迟优化](https://cloud.tencent.com/developer/news/228794)
[How to identify and cure MySQL replication slave lag](https://www.percona.com/blog/2014/05/02/how-to-identify-and-cure-mysql-replication-slave-lag/)
[What to Look for if Your MySQL Replication is Lagging](https://severalnines.com/database-blog/what-look-if-your-mysql-replication-lagging)
[美团面试被问到主从延迟的解决办法 - 掘金](https://juejin.cn/post/7038459484838199326)

当只读实例出现延迟的时候，排查方向如下：

1. 检查只读实例是否存在无主键表的删除或者更新操作，可以通过在只读实例执行show engine innodb status\G命令查看，或者执行show open tables后查看输出结果的in_use列里值为1的表。
2. 控制台查看SQL慢日志，是否有alter，repair，create等DDL操作。
3. 检查只读实例的Binlog增长量，确定是否存在大事务。
4. 主库与从库配置不一致：检查只读实例的IOPS，确认只读实例是否存在资源瓶颈。
5. 在控制台查看监控，检查只读实例的MySQL_COMDML，确认主实例是否TPS过高。
6. 只读实例执行 show slave status \G 命令，确定是否存在元数据锁。

在控制台监控里面核对下 MySQL_COMDML 是否较大，如是，您是否可以通过拆分的方式进行操作的
延迟是需要有现场的时候进行判断操作的，如复现可通过 show slave status \G命令（执行多次），可以看到 Seconds_Behind_Master 不断变化，而 Exec_Master_Log_Pos 却保持不变，这样可以判断只读实例的SQL线程在执行一个大的事务或者DDL操作

```sql
nopager ;select now();pager grep -E "Retrieved_Gtid_Set|Executed_Gtid_Set|Relay_Master_Log_File|Master_Log_File|Exec_Master_Log_Pos|Seconds_Behind_Master|Slave_SQL_Running_State|Slave_IO_State"; show slave status \G
show open tables where in_use>0;
        Slave_IO_State: Waiting for master to send event
          Master_Host: 10.111.2.230
          Master_User: replicator
          Master_Port: 3002
        Connect_Retry: 60
      Master_Log_File: mysql-bin.008385
  Read_Master_Log_Pos: 151587119
        Relay_Log_File: slave-relay.008161
        Relay_Log_Pos: 278809576
Relay_Master_Log_File: mysql-bin.008384
      Slave_IO_Running: Yes
    Slave_SQL_Running: Yes
```

#### 未提交的事务

[MySQL找出未提交事务的信息 - 云+社区 - 腾讯云](https://cloud.tencent.com/developer/article/1607249)

```sql
select * from information_schema.innodb_trx\G;

select * from information_schema.processlist where COMMAND != 'Sleep';

-- 查询这个超过10秒未提交事务的详细信息
SELECT t.trx_mysql_thread_id ,t.trx_state ,t.trx_tables_in_use ,t.trx_tables_locked ,t.trx_query ,t.trx_rows_locked ,
    t.trx_rows_modified ,t.trx_lock_structs ,t.trx_started ,t.trx_isolation_level ,p.time ,p.user ,p.host ,p.db ,p.command
FROM   information_schema.innodb_trx t INNER JOIN information_schema.processlist p
ON t.trx_mysql_thread_id = p.id
WHERE  t.trx_state = 'RUNNING' AND p.time > 10 AND p.command = 'Sleep'\G

-- performance_schema.events_statements_current中的未提交事务
-- 通过查看performance_schema.events_statements_current表可看到每一个session正在执行的sql，哪怕它依旧执行完成了，只是没有提交：
select * from performance_schema.events_statements_current where sql_text not like 'select * from performance_schema.events_statements_current%'\G
```

#### 问题发生在master上

去看 processlist ，看slow sql，看操作系统负载，看系统参数配置；

#### 问题发生在slave上

1. SQL thread 慢，表现是
   1. Seconds_Behind_Master 越来越大
   2. Slave_SQL_Running_State: Reading event from the relay log
2. IO thread慢，表现是
   1. Seconds_Behind_Master 为0
   2. Slave_SQL_Running_State: 显示正常值
   3. Slave_IO_State:显示忙碌状态

#### Waiting for dependent transaction to commit

[MySQL Slave SQL Running State - “Waiting for dependent transaction to commit” meaning](https://dba.stackexchange.com/questions/269539/mysql-slave-sql-running-state-waiting-for-dependent-transaction-to-commit-me)
[记一次Mysql主从复制延迟，Waiting for dependent transaction to commit](http://www.voycn.com/article/jiyicimysqlzhucongfuzhiyanchiwaiting-dependent-transaction-commit)

`select @@slave_parallel_type, @@slave_parallel_workers, @@slave_preserve_commit_order;`
开启多线程复制的情况：`slave_parallel_type=LOGICAL_CLOCK, slave_parallel_workers>0`

开启多线程回放后，回放控制线程会根据既定的规则，进行并发回放。因此，后续事务如果不可以跟正在回放的事务并发的话，就必须要进行等待。
如果开启了[`slave_preserve_commit_order`](https://dev.mysql.com/doc/refman/8.0/en/replication-options-replica.html#sysvar_slave_preserve_commit_order)，进行并发回放的多个事务之间，也要按照和主库上提交的顺序一样，进行提交。

`Waiting for dependent transaction to commit` 是当前事务无法和正在回放的事务并发回放，出现的等待。

`Waiting for preceding transaction to commit` 是当前并发回放的事务在进入commit时的flush队列前，必须等到先前事务已经进入flush队列而引起的等待。

`Waiting for slave workers to process their queues` 由于没有空闲的工作线程，协调线程会等待。这种情况说明理论上的并行度是理想的，但是可能是参数 slave_parallel_workers 设置不够。当然设置工作线程的个数应该和服务器的配置和负载相结合考虑。[MySQL里Wating for Slave workers to free pending events到底在等什么 - 云+社区 - 腾讯云](https://cloud.tencent.com/developer/article/1739742)

#### 分区过多导致延迟

排除掉常见因素后（无主键更新，从库配置低，从库压力大），通过 `perf top -p $(pidof mysqld)` 发现 bitmap_get_next_set 和 build_template_field 函数调用非常高。
这两个函数跟启用表分区有关系。

```sql
-- 检查下表分区数量
SELECT TABLE_NAME, COUNT(*) AS CNT
    FROM information_schema.PARTITIONS WHERE PARTITION_NAME IS NOT NULL
    GROUP BY TABLE_NAME ORDER BY CNT DESC LIMIT 50;
-- 合并分区

-- 合并分区后需要执行
ANALYZE TABLE ;
```

## 构建高性能的 MySQL 集群系统

### 通过KeepAlived搭建 Mysql双主模式的高可用集群系统

### 通过MMM构建Mysql高可用集群系统

### MySQL读写分离解决方案

* 通过amoeba 实现MySQL读写分离
* 通过keepalived构建高可用的amoeba服务
* MySQL-Proxy（官方）
* Amoeba for MySQL
* MaxScale
* Atlas（360）, based on MySQL-Proxy 0.8.2
* Cobar（Alibaba）

HA: percona xtradb cluster, galera cluster

## Inception 一个集审核、执行、备份及生成回滚语句于一身的MySQL自动化运维工具

[Inception](https://github.com/hanchuanchuan/inception)
[goInception](https://hanchuanchuan.github.io/goInception/)是一个集审核、执行、备份及生成回滚语句于一身的MySQL运维工具， 通过对执行SQL的语法解析，返回基于自定义规则的审核结果，并提供执行和备份及生成回滚语句的功能

## NDB: Network Database

[InnoDB和NDB，MySQL群集和InnoDB群集之间有什么区别？](https://www.cnblogs.com/margiex/p/12706567.html)
[23.1.6.1 Differences Between the NDB and InnoDB Storage Engines](https://dev.mysql.com/doc/refman/8.0/en/mysql-cluster-ndb-innodb-engines.html)

也称为NDB CLUSTER, 是另一种存储引擎，但是它主要存储数据在内存中，并且独立于MySQL Server实例。它是MySQL Cluster使用的存储引擎。 NDB代表“网络数据库”。

### MySQL NDB Cluster (或 MySQL Cluster)

MySQL NDB Cluster (或 MySQL Cluster) 与MySQL Server（人们普遍认知的MySQL）是完全不同的产品，它使用非共享架构，通过多台服务器构建成集群，实现多点读写的关系型数据库。它具有在线维护功能，并且排除单一故障，具有非常高的可用性。此外，它的主要数据保存在内存中，可以高速处理大量的事务，是面向实时性应用程序的一款数据库产品。

### InnoDB Cluster

几乎与MySQL Cluster完全无关，并且是从MySQL 5.7 开始作为一组插件实现的。其中之一是“组复制”插件，该插件使组中的MySQL服务器能够在它们之间复制数据。

## Question

### MYSQL=黑盒?

1. 为什么在写SQL语句时遵守最左前缀原则才能用到索引？不遵守就用不到索引？其底层工作机制是怎样的？
2. Mysql中写缓冲区为什么能优化写入的速度？如何做到的？
3. Mysql在执行一个SQL语句时会经过哪些步骤？这每个步骤可以如何优化？
4. 写了一个很长的SQL，这个SQL最终的执行顺序是怎样的？如何优化复杂SQL?

### 大表=分库分表?

1. 到底多大数量的表才是大表？500万条？2000万条？5000万条？
2. 如果一个表中数据量很大，这个时候如何建立索引，如何优化索引？
3. 高并发场景下，使用Mysql事务时应该要注意哪些方面，如何进行优化？

### 高并发场景下如何使Mysql高效运行

#### 亿级流量下如何高效的使用Mysql索引

1. Innodb存储基本单位页结构详解
2. 索引底层原理与执行流程精讲
3. Mysql是如何选择最优索引的
4. 覆盖索引底层原理与执行流程精讲
5. 索引下推底层原理与执行流程精讲
6. Mysql为什么会出现索引失效
7. 亿级流量下Mysql索引最优使用和优化策略

#### 超高并发下如何对Mysql事务进行优化

1. Buffer Pool内存结构详解与优化策略分析
2. Mysql事务底层实现原理及源码详解
3. Innodb本身针对写语句做了哪些优化
4. MVCC机制是如何保证事务的隔离性的
5. 超高并发下使用事务时避免死锁策略分析
6. 分布式事务与Mysql事务之间的关系是什么
7. 超高并发下如何正确的使用Mysql事务及优化策略

#### 通过学习你能收获

1. 彻底掌握Mysql事务、索引的底层工作原理
2. 彻底掌握增删查改SQL语句的底层执行机制
3. 学习到如何针对大数据量表进行索引和事务的优化
4. 收获并理解更多更强大的Mysql性能优化技巧
