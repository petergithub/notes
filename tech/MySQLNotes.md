[TOC]

# MySQL Notes

## Recent
mysqlreport --user root --password 
/etc/mysql/my.cnf ~/.my.cnf

show full processlist;
explain sql query;

## Basic command

### MySQL调优
1.mysql嵌套子查询效率确实比较低
2.可以将其优化成连接查询
3.连接表时，可以先用where条件对表进行过滤，然后做表连接 (虽然mysql会对连表语句做优化)
4.建立合适的索引
5.学会分析sql执行计划，mysql会对sql进行优化，所以分析执行计划很重要
制定适当的存储引擎和字符编码
例如:MySQL中强事务业务使用InnoDB，弱事务业务使用MyISAM，字符编码使用utf8_bin，ORACLE中无需制定存储引擎，只需要制定字符编码UTF-8
mysql线上将采用一master多slave的方式来进行部署


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
删除数据表： DROP TABLE 表名；
将表中记录清空： DELETE FROM 表名;
往表中插入记录： INSERT INTO 表名 VALUES (”hyq”,”M”);
更新表中数据： UPDATE 表名 SET 字段名1='a',字段名2='b' WHERE 字段名3='c';
用文本方式将数据装入数据表中： LOAD DATA LOCAL INFILE “D:/mysql.txt” INTO TABLE 表名;
导入.sql文件命令： SOURCE d:/mysql.sql;

显示当前的user： SELECT USER();
来查看数据库版本 SELECT VERSION();
显示use的数据库名： SELECT DATABASE();

#### 修改密码。
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
导出整个数据库(–hex-blob 为有blob数据做的,防止乱码和导入失败用)
备份文件中的“--”字符开头的行为注释语句；以“/*!”开头、以“*/”结尾的语句为可执行的mysql注释，这些语句可以被mysql执行
``` sql
mysqldump -u USERNAME -p database_name > outfile_name.sql
mysqldump -uroot --default-character-set=utf8 --hex-blob dbName > dbName.sql
-d 没有数据 
--hex-blob 为有blob数据做的,防止乱码和导入失败用
--add-drop-table 在每个create语句之前增加一个drop table
--no-create-info, -t Do not write CREATE TABLE statements that re-create each dumped table.
--default-character-set=utf8 带语言参数导出
```

#### Import/Restore
mysql> USE 数据库名;
mysql> SOURCE d:/mysql.sql;
or
mysql -uroot -p dbName < dbName.sql
// or
mysql -uroot -p dbName -e "source /path/to/dbName.sql"


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
