[TOC]

# MySQL Notes

## Recent
mysqlreport --user root --password  
/etc/mysql/my.cnf ~/.my.cnf  

updates automatically the date field `ALTER TABLE tableName ADD COLUMN modifyDate DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;`  
SELECT UNIX_TIMESTAMP(NOW());  
SELECT FROM_UNIXTIME(1467542031);  
select SUBSTRING(1456958130210,1,10);  

show full processlist;  
`explain SQL` query;  then `show warings` to get the raw SQL clause

MySQL压力测试  
1. mysqlslap的介绍及使用  
2. sysbench  
3. tpcc-mysql  

MySQL 5.5.3+ UTF8mb4支持emoji  
HA: percona xtradb cluster, galera cluster   

append a string to an existing field: `UPDATE categories SET code = CONCAT(code, '_standard') WHERE id = 1;`  

To see the index for a specific table use SHOW INDEX: `SHOW INDEX FROM yourtable;`  
To see indexes for all tables within a specific schema: `SELECT DISTINCT TABLE_NAME,INDEX_NAME FROM INFORMATION_SCHEMA.STATISTICS where table_schema = 'account';`  
mysql query escape %前面加两个反斜杠，比如  
`select count(1) from tableName where column like '%关键字\\%前面的是一个百分号%'`  

查看支持的字符集和排序方式: `show character set`, `show collation`  
查看数据库字符集`select * from SCHEMATA where SCHEMA_NAME='ttlsa';`  
查看表字符集 `select TABLE_SCHEMA,TABLE_NAME,TABLE_COLLATION from information_schema.TABLES;`  
查看列字符集 `select TABLE_SCHEMA,TABLE_NAME,COLUMN_NAME,COLLATION_NAME from information_schema.COLUMNS;`  


创建表的时候指定CHARSET为utf8mb4  
```
	
	CREATE TABLE IF NOT EXISTS table_name (
	...
	) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_general_ci;
```
update database character: `ALTER DATABASE database_name CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;`  

update table character:   
`ALTER TABLE table_name CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;`  
`ALTER TABLE table_name modify column_name text charset utf8mb4;`  

update column character: `ALTER TABLE table_name CHANGE column_name column_name VARCHAR(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;`  

### datetime query
	
``` mysql	
	
	mysql> SELECT UNIX_TIMESTAMP('2005-03-27 02:00:00');
	+---------------------------------------+
	| UNIX_TIMESTAMP('2005-03-27 02:00:00') |
	+---------------------------------------+
	|                            1111885200 |
	+---------------------------------------+
	mysql> SELECT FROM_UNIXTIME(1111885200);
	+---------------------------+
	| FROM_UNIXTIME(1111885200) |
	+---------------------------+
	| 2005-03-27 03:00:00       |
	+---------------------------+
```

### case-sensitive
make a case-sensitive query  
`SELECT *  FROM table WHERE BINARY column = 'value'`  
`select * from t1 where name = binary 'YOU'`  

设置表或行的collation，使其为binary或case sensitive。在MySQL中，对于Column Collate其约定的命名方法如下:  
*_bin: 表示的是binary case sensitive collation，也就是说是区分大小写的   
*_cs: case sensitive collation，区分大小写   
*_ci: case insensitive collation，不区分大小写   

### MySQL help
`help` to get List of all MySQL commands
http://linuxcommand.org/man_pages/mysql1.html  
```
clear     (\c) Clear the current input statement.
edit      (\e) Edit command with $EDITOR.
ego       (\G) Send command to mysql server, display result vertically.
nopager   (\n) Disable pager, print to stdout.
pager     (\P) Set PAGER [to_pager]. Print the query results via PAGER.
tee       (\T) Set outfile [to_outfile]. Append everything into given outfile.
system    (\!) Execute a system shell command.
```
`pager less`, `pager less -n -i -S`   
From `man less`:  
`-i` Causes searches to ignore case  
`-n` Suppresses line numbers
`-S` Causes lines longer than the screen width to be chopped rather than folded.  

`edit`	 it will open your default text editor with the text of the last query. The default text editor is vi, Or type `\e` to edit the statement in the buffer, like CTRL+X,E in bash  

`tee queries.log`	Logging to file 'queries.log'  
log to a file the statements you typed and their output, pretty much like the Unix `tee` command:  

### Transaction
Using the Transaction Information Schema Tables
https://dev.mysql.com/doc/innodb-plugin/1.0/en/innodb-information-schema-examples.html  
`begin`, `start transaction`, `set autocommit=0`  
`end`, `commit`, `rollback`   

SELECT @@GLOBAL.tx_isolation, @@tx_isolation, @@session.tx_isolation;  
`SELECT @@global.tx_isolation;`	查看InnoDB系统级别的事务隔离级别   
`SELECT @@tx_isolation;`	查看InnoDB会话级别的事务隔离级别  
`SET global transaction isolation level read committed;`	修改InnoDB系统级别的事务隔离级别  
`SET session transaction isolation level read committed;`	修改InnoDB会话级别的事务隔离级别  
`set innodb_lock_wait_timeout=100`  
`show variables like 'innodb_lock_wait_timeout';`  
`show engine innodb status`	 to get a list of all the actions currently pending inside the InnoDB engine  

#### FORCE UNLOCK for locked tables in MySQL
`show open tables where in_use>0;`	get the list of locked tables
`show processlist;`	get the list of the current processes, one of them is locking your table(s)  
`kill <put_process_id_here>;`	 Kill one of these processes

#### 事务隔离模式
1. READ UNCOMMITED SELECT的时候允许脏读，即SELECT会读取其他事务修改而还没有提交的数据。  
2. READ COMMITED SELECT的时候无法重复读，即同一个事务中两次执行同样的查询语句，若在第一次与第二次查询之间时间段，其他事务又刚好修改了其查询的数据且提交了，则两次读到的数据不一致。  
3. REPEATABLE READ SELECT的时候可以重复读，即同一个事务中两次执行同样的查询语句，得到的数据始终都是一致的。实现的原理是，在一个事务对数据行执行读取或写入操作时锁定了这些数据行。  
    但是这种方式又引发了幻想读的问题。因为只能锁定读取或写入的行，不能阻止另一个事务插入数据，后期执行同样的查询会产生更多的结果。  
4. SERIALIZABLE 与可重复读的唯一区别是，默认把普通的SELECT语句改成SELECT … LOCK IN SHARE MODE。即为查询语句涉及到的数据加上共享琐，阻塞其他事务修改真实数据。SERIALIZABLE模式中，事务被强制为依次执行。这是SQL标准建议的默认行为。  

脏读（dirty read）    
不可重复读（unrepeatable read）   
幻象读（phantom read）   
幻象读和不可重复读是两个容易混淆的概念，前者是指读到了其他已经提交事务的新增数据，而后者是指读到了已经提交事务的更改数据（更改或删除），为了避免这两种情况，采取的对策是不同的，防止读取到更改数据，只需要对操作的数据添加行级锁，阻止操作中的数据发生变化，而防止读取到新增数据，则往往需要添加表级锁——将整个表锁定，防止新增数据（Oracle使用多版本数据的方式实现）   

#### 锁机制
1. 共享锁：由读表操作加上的锁，加锁后其他用户只能获取该表或行的共享锁，不能获取排它锁，也就是说只能读不能写  
2. 排它锁：由写表操作加上的锁，加锁后其他用户不能获取该表或行的任何锁，典型是mysql事务中的  
锁的范围:  
行锁: 对某行记录加上锁  
表锁: 对整个表加上锁  
共享锁(share mode), 排他锁(for update)   

不想向数据表中插入相同的主键、unique索引时，可以使用replace或insert ignore，来避免重复的数据。  
`replace into`	相当于delete然后insert，会有对数据进行写的过程。  
`insert ignore`	会忽略已经存在主键或unique索引的数据，而不会有数据的修改    
使用场景：  
    如果不需要对数据进行更新值，那么推荐使用insert ignore，比如：多线程的插入相同的数据    
    如果需要对数据进行更新最新的值，那么使用replace，比如：任务的结果，最后的更新时间    


### MySQL调优

1.mysql嵌套子查询效率确实比较低
2.可以将其优化成连接查询
3.连接表时，可以先用where条件对表进行过滤，然后做表连接 (虽然mysql会对连表语句做优化)
4.建立合适的索引
5.学会分析sql执行计划，mysql会对sql进行优化，所以分析执行计划很重要
制定适当的存储引擎和字符编码  
例如:MySQL中强事务业务使用InnoDB，弱事务业务使用MyISAM，字符编码使用utf8_bin，ORACLE中无需制定存储引擎，只需要制定字符编码UTF-8  
mysql线上将采用一master多slave的方式来进行部署  

## Basic command

### Common command
连接MYSQL mysql -h主机地址 -Pport -u用户名 －p用户密码 -S /data/mysql/mysql.sock  
mysql -h110.110.110.110 -u root -p 123;（注:u与root之间可以不用加空格，其它也一样）  
显示当前数据库服务器中的数据库列表：SHOW DATABASES;  
USE 库名；  
建立数据库： CREATE DATABASE 库名;  
删除数据库： DROP DATABASE 库名;  
显示数据库中的数据表： SHOW TABLES;  
显示数据表的结构： DESCRIBE 表名;  
建立数据表： CREATE TABLE 表名 (字段名 VARCHAR(20), 字段名 CHAR(1));  
SHOW CREATE TABLE  
删除数据表： DROP TABLE 表名；  
将表中记录清空： DELETE FROM 表名;  
往表中插入记录： INSERT INTO 表名 VALUES (”hyq”,”M”);  
更新表中数据： UPDATE 表名 SET 字段名1='a',字段名2='b' WHERE 字段名3='c';  
用文本方式将数据装入数据表中： LOAD DATA LOCAL INFILE “D:/mysql.txt” INTO TABLE 表名;  
导入.sql文件命令： SOURCE d:/mysql.sql;  

`./mysqld_safe` start MySQL server  
`sudo /etc/init.d/mysql start`	start mysql server on ubuntu
`sudo /etc/init.d/mysql restart`	restart mysql server on ubuntu
`/etc/init/mysql.conf` 
显示当前的user： `SELECT USER();`  
来查看数据库版本 `SELECT VERSION();`  
显示use的数据库名： `SELECT DATABASE();`  
find the mysql data directory by `grep datadir /etc/my.cnf` or    
`mysql -uUSER -p -e 'SHOW VARIABLES WHERE Variable_Name LIKE "%dir"'`  
`mysql -uUSER -p -e 'SHOW VARIABLES WHERE Variable_Name = "datadir"'`  

#### 修改密码
格式：mysqladmin -u用户名 -p旧密码 password 新密码  
1、给root加个密码ab12。首先在DOS下进入目录mysql\bin，然后键入以下命令  
mysqladmin -u root -password ab12  
注：因为开始时root没有密码，所以-p旧密码一项就可以省略了。  
2、再将root的密码改为djg345。  
mysqladmin -u root -p ab12 password djg345  
命令行修改root密码： UPDATE mysql.user SET password=PASSWORD('新密码') WHERE User='root';  

#### 增加新用户 grant permission
grant all on dbName.* to USERNAME@host identified by 'pwd';  
grant all on aotmobile_global.* to 'USERNAME'@192.168.1.136 identified by 'PASSWORD';  
grant select,insert,update,delete on mydb.* to test2@localhost identified by “abc”;  
show grants for USERNAME@IP; 查看用户权限  
select * from mysql.user where user='cactiuser' \G    
SELECT DISTINCT CONCAT('User: ''',user,'''@''',host,''';') AS query FROM mysql.user; 查看MYSQL数据库中所有用户  
CREATE USER 'newuser'@'localhost' IDENTIFIED BY 'password';  
GRANT ALL PRIVILEGES ON * . * TO 'newuser'@'localhost';  
REVOKE [type of permission] ON [database name].[table name] FROM ‘[username]’@‘localhost’;  
DROP USER ‘demo’@‘localhost’;  

（注意：和上面不同，下面的因为是MYSQL环境中的命令，所以后面都带一个分号作为命令结束符）  
格式：grant select on 数据库.* to 用户名@登录主机 identified by “密码”  
1、增加一个用户test1密码为abc，让他可以在任何主机上登录，并对所有数据库有查询、插入、修改、删除的权限。首先用root用户连入MYSQL，然后键入以下命令：  
grant select,insert,update,delete on *.* to test1@”%” Identified by “abc”;  
但增加的用户是十分危险的，你想如某个人知道test1的密码，那么他就可以在internet上的任何一台电脑上登录你的mysql数据库并对你的数据可以为所欲为了，解决办法见2。  
2、增加一个用户test2密码为abc,让他只可以在localhost上登录，并可以对数据库mydb进行查询、插入、修改、删除的操作（localhost指本地主机，即MYSQL数据库所在的那台主机），  
这样用户即使用知道test2的密码，他也无法从internet上直接访问数据库，只能通过MYSQL主机上的web页来访问了。  
grant select,insert,update,delete on mydb.* to test2@localhost identified by “abc”;  
如果你不想test2有密码，可以再打一个命令将密码消掉。  
grant select,insert,update,delete on mydb.* to test2@localhost identified by “”;  
mysql> FLUSH PRIVILEGES;  

#### 查看三种MySQL字符集的方法
- 查看MySQL数据库服务器和数据库MySQL字符集  
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
- 查看MySQL数据表（table）的MySQL字符集  
	``` sql
	mysql> show table status from settlement like 'tableName' \G
	*************************** 1. row ***************************
	           Name: st_card
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
- 查看MySQL数据列（column）的MySQL字符集  
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


#### Example: 建库和建表以及插入数据
``` sql
DROP DATABASE IF EXISTS school; //如果存在SCHOOL则删除
CREATE DATABASE school; //建立库SCHOOL
USE school; //打开库SCHOOL
CREATE TABLE teacher //建立表TEACHER
(
id INT(3) AUTO_INCREMENT NOT NULL PRIMARY KEY,
name CHAR(10) NOT NULL,
address VARCHAR(50) DEFAULT ‘深圳',
year DATE
);

-- 以下为插入字段  
INSERT INTO teacher VALUES(”,'jack','大连二中','1975-12-23′);  
```
如果你在mysql提示符键入上面的命令也可以，但不方便调试。  
（1）你可以将以上命令原样写入一个文本文件中，假设为school.sql，然后复制到c:\\下，并在DOS状态进入目录\\mysql\\bin，然后键入以下命令：  
mysql -uroot -p密码 < c:\\school.sql  
如果成功，空出一行无任何显示；如有错误，会有提示。（以上命令已经调试，你只要将//的注释去掉即可使用）。  
（2）或者进入命令行后使用 mysql> source c:\\school.sql; 也可以将school.sql文件导入数据库中。  

#### Export/Backup database mysqldump
MySQL 5.7 Reference Manual [mysqldump - A Database Backup Program](https://dev.mysql.com/doc/refman/5.7/en/mysqldump.html#option_mysqldump_single-transaction)  
导出整个数据库(--hex-blob 为有blob数据做的,防止乱码和导入失败用)  
备份文件中的“--”字符开头的行为注释语句；以“/*!”开头、以“*/”结尾的语句为可执行的mysql注释，这些语句可以被mysql执行  

`mysqldump -u USERNAME -p database_name > outfile_name.sql`  
`mysqldump -uroot --default-character-set=utf8 --hex-blob --single-transaction dbName > dbName.sql`  
* `-d` 没有数据 
* `--hex-blob` 为有blob数据做的,防止乱码和导入失败用
* `--add-drop-table` 在每个create语句之前增加一个drop table
* `--no-create-info, -t` Do not write CREATE TABLE statements that re-create each dumped table.
* `--default-character-set=utf8` 带语言参数导出
* `--single-transaction`	This option sets the transaction isolation mode to REPEATABLE READ without blocking any applications. It is useful only with transactional tables such as InnoDB
* `--lock-tables=false , -l`	Lock all tables before dumping them. The tables are locked with READ LOCAL to allow concurrent inserts in the case of MyISAM tables. For transactional tables such as InnoDB and BDB, `--single-transaction` is a much better option, because it does not need to lock the tables at all.
* `--where/-w` export with condition `mysqldump -uroot -p123456 schemaName tableName --where=" sensorid=11 and fieldid=0" > /home/xyx/Temp.sql`

#### Import/Restore
`mysql> USE 数据库名;`  
`mysql> SOURCE d:/mysql.sql;` or  
`mysql -uroot -p dbName < dbName.sql` or   
`mysql -uroot -p dbName -e "source /path/to/dbName.sql"`  

#### MySQL Export Table to CSV 
[Select INTO](http://dev.mysql.com/doc/refman/5.7/en/select-into.html)  
`mysql -uroot -proot -D account -s -e "select id,username from user_0 limit 10 INTO OUTFILE '/tmp/user.csv' FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n'"`    
`mysql -uroot -p -D account < mysql.sql |  sed 's/\t/,/g' > out.csv`  

``` mysql
	
	SELECT 
	    orderNumber, status, orderDate, requiredDate, comments
	FROM
	    orders
	WHERE
	    status = 'Cancelled' 
	INTO OUTFILE 'C:/tmp/cancelled_orders.csv' 
	FIELDS ENCLOSED BY '"' 
	TERMINATED BY ',' 
	ESCAPED BY '"' 
	LINES TERMINATED BY '\r\n';
```

### MySQL Workbench update shortcut Auto-complete 
D:\ProgramFiles\MySQL Workbench 6.3.3 CE (winx64)\data\main_menu.xml  
/usr/share/mysql-workbench/data/main_menu.xml  


## Advanced

### Backup script 
``` bash

	date_str=`date +%Y%m%d%H%M%S`
	cd /data2/backup
	mysqldump -h localhost -uroot --pxxxxx -R -e --max_allowed_packet=1048576 --net_buffer_length=16384 i5a6 | gzip > /data2/backup/i5a6_$date_str.sql.gz
```

### MySQL忘记root密码
1、在DOS窗口下输入net stop mysql5 或 net stop mysql  
2、开一个DOS窗口，这个需要切换到mysql的bin目录输入mysqld --skip-grant-tables;  
3、再开一个DOS窗口，mysql -u root  
4、输入：  
use mysql  
update user set password=password("password") where user="root";  
flush privileges;  
exit  
5、使用任务管理器，找到mysqld-nt的进程，结束进程   

### 将文本数据转到数据库中
1、文本数据应符合的格式：字段数据之间用tab键隔开，null值用\\n来代替.例：  
3 rose 大连二中 1976-10-10  
4 mike 大连一中 1975-12-23  
假设你把这两组数据存为school.txt文件，放在c盘根目录下。  
2、数据传入命令 load data local infile “c:\\school.txt” into table 表名;  
注意：你最好将文件复制到\\mysql\\bin目录下，并且要先用use命令打表所在的库。  

### Advanced SQL

``` sql

	UPDATE st_clearing_statement SET refund_transactions = 0, trade_transactions = 83
	SELECT 
	    COUNT( CASE WHEN `mother` >24 THEN 1 ELSE NULL END ) AS `digong`, 
	    COUNT( CASE WHEN `mother` <=24 THEN 1 ELSE NULL END ) AS `tiangong`
	FROM prince
	
```

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

### slow log 
#### record slow log
`show variables  like '%slow_query_log%'`	Query slow log status
`set global slow_query_log=1`	Start recording slow log, 开启了慢查询日志只对当前数据库生效，如果MySQL重启后则会失效  
`slow_query_log = 1`	开启慢日志永久生效，必须修改配置文件`~/.my.cnf`, `/etc/my.cnf`（其它系统变量也是如此）  
`slow_query_log_file = /tmp/mysql_slow.log`	slow log location, default value: host_name-slow.log   
`long_query_time=2`	慢查询阈值，当查询时间多于设定的阈值时，记录日志,默认10s  
`log_queries_not_using_indexes`	未使用索引的查询也被记录到慢查询日志中（可选项）   
  

MySQL提供了日志分析工具mysqldumpslow   
`mysqldumpslow -s r -t 10 /data/softwares/mysql/mysql06_slow.log`	得到返回记录集最多的10个SQL
`mysqldumpslow -s c -t 10 /data/softwares/mysql/mysql06_slow.log`	得到访问次数最多的10个SQL

### Example: 数据库插入数据时加锁 多线程(多job)重复insert
1. `insert into test.test_sql_type select 26,'name25',9,1,now() from dual where not exists (select * from test.test_sql_type where id = 26);`  
2. `select ... for update`, then insert  
it locks the whole table, other process will pending to get the lock when select the table, so no one can insert into it.  
3. `insert ignore`  
http://dev.mysql.com/doc/refman/5.7/en/innodb-locking-reads.html   
`insert ignore`会忽略已经存在主键或unique索引的数据，而不会有数据的修改。  
http://www.chenyudong.com/archives/mysql-insert-ignore-different-replace-into.html 	  
`insert ignore into table_name(email,phone,user_id) values('test9@163.com','99999','9999')`,这样当有重复记  
录就会忽略,执行后返回数字0,还有个应用就是复制表,避免重复记录：  
`insert ignore into table(name)  select  name from table2`  
4. 额外的表记录一个标示flag表示默认为N 没有JOB执行，第一个服务器进入JOB 把这个标示给更新成Y那么会成功返回update条数1，其他的三台机器则会update条数为0所以 if判断一下就好，然后在正常执行完和异常代码块里都还原一下  

#### reference
http://stackoverflow.com/questions/21261213/select-for-update-with-insert-into  
`SELECT ... FOR UPDATE` with UPDATE  

Using transactions with InnoDB (auto-commit turned off), a SELECT ... FOR UPDATE allows one session to temporarily lock down a particular record (or records) so that no other session can update it. Then, within the same transaction, the session can actually perform an UPDATE on the same record and commit or roll back the transaction. This would allow you to lock down the record so no other session could update it while perhaps you do some other business logic.  

This is accomplished with locking. InnoDB utilizes indexes for locking records, so locking an existing record seems easy--simply lock the index for that record.  

`SELECT ... FOR UPDATE` with INSERT  

However, to use SELECT ... FOR UPDATE with INSERT, how do you lock an index for a record that doesn''t exist yet? If you are using the default isolation level of REPEATABLE READ, InnoDB will also utilize gap locks. As long as you know the id (or even range of ids) to lock, then InnoDB can lock the gap so no other record can be inserted in that gap until we''re done with it.  

If your id column were an auto-increment column, then SELECT ... FOR UPDATE with INSERT INTO would be problematic because you wouldn''t know what the new id was until you inserted it. However, since you know the id that you wish to insert, SELECT ... FOR UPDATE with INSERT will work.  

#### test case
select nonexistent orderId, which is not a index column, it will lock the whole table;  
select nonexistent id, which is the PRIMARY KEY, it cannot lock any row;  

```
  
	CREATE TABLE `test_sql_type` (
	  `id` bigint(32) NOT NULL AUTO_INCREMENT,
	  `orderId` int(8) DEFAULT NULL COMMENT 'another int',
	  PRIMARY KEY (`id`)
	) ENGINE=InnoDB AUTO_INCREMENT=46 DEFAULT CHARSET=utf8 COMMENT='测试类型表';
```

console 1:  
```

	begin;
	select * from test_sql_type where orderId = 41 for update;
```

orderId 41 is not a existing row.  
it gets the lock of the whole table;  

console 2:  
```

	begin;
	select * from test_sql_type where orderId = 41 for update;
	**pending**
```

It pending to get the lock.  


## 构建高性能的 MySQL 集群系统
### 通过KeepAlived搭建 Mysql双主模式的高可用集群系统
### 通过MMM构建Mysql高可用集群系统
###  MySQL读写分离解决方案
* 通过amoeba 实现MySQL读写分离  
* 通过keepalived构建高可用的amoeba服务  
* MySQL-Proxy（官方）  
* Amoeba for MySQL  
* MaxScale  
* Atlas（360）, based on MySQL-Proxy 0.8.2  
* Cobar（Alibaba）  
