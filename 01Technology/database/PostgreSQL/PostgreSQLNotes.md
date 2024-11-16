# PostgreSQL Notes

[PostgreSQL 16.3 Documentation](https://www.postgresql.org/docs/16/index.html)
[PostgreSQL 15.7 手册](http://www.postgres.cn/docs/current/index.html)
[PostgreSQL 中文社区 15.7 手册](http://www.postgres.cn/docs/15/index.html)
[PostgreSQL 教程 | 菜鸟教程](https://www.runoob.com/postgresql/postgresql-tutorial.html)

## Research

[PostgreSQL 与 MySQL 相比，优势何在？ - 知乎](https://www.zhihu.com/question/20010554)
[PGXN: PostgreSQL Extension Network](https://pgxn.org/)

## Book

[PostgreSQL好书推荐 - 墨天轮](https://www.modb.pro/db/475440)
[interdb.jp/pg/index.html](https://www.interdb.jp/pg/index.html)

## 控制台命令

[PostgreSQL 16: psql](https://www.postgresql.org/docs/16/app-psql.html)

```sh
psql --help

# 连接数据库 -U 指定用户，-d 指定数据库，-h 指定服务器，-p 指定端口
psql -h localhost -p 5432 -U postgres --password

# 直接输入密码
PGPASSWORD=<password> psql -h localhost -p 5432 -U <username>

Connection options:
  -h, --host=HOSTNAME      database server host or socket directory (default: "local socket")
  -p, --port=PORT          database server port (default: "5432")
  -U, --username=USERNAME  database user name (default: "root")
  -d, dbname --dbname=dbname
  -e, --echo-queries Copy all SQL commands sent to the server to standard output as well. This is equivalent to setting the variable ECHO to queries.


  -w, --no-password        never prompt for password
  -W, --password           force password prompt (should happen automatically)
General options:
  -f /path/to/sql
  -c, --command=COMMAND    run only single command (SQL or internal) and exit
Input and output options:
  -a all echo
  -L, --log-file=FILENAME  send session log to file
  -q quiet

Output format options:
  -A, --no-align           unaligned table output mode
  -t, --tuples-only        print rows only
  -x, --expanded
           Turn on the expanded table formatting mode. This is equivalent to \x or \pset expanded.

```

* \password dbuser 命令（设置密码）和\q命令（退出）
* \h 查看SQL命令的解释，比如\h select。
* \? 查看psql命令列表。
* \l 列出所有数据库。
* \x Expanded display 类似 MySQL \G
* \c [database_name] 连接其他数据库。
* \d 列出当前数据库的所有表格。
* \dt 列出数据库中所有表
* \d [table_name] 列出表结构
* \di 列出数据库中所有 index
* \dv 列出数据库中所有 view \dv *.*
* \d+ pg_roles 查看 view 定义
* \dp [PATTERN] list table, view, and sequence access privileges
* \sv pg_roles 查看 view 定义, \sv+ 展示行号
* \du 列出所有用户。
* \encoding 显示字符集
* \i path/to/sql 执行sql文件
* \x 扩展展示结果信息，相当于MySQL的 \G
* \e 打开文本编辑器。
* \conninfo 列出当前数据库和连接的信息。
* \o filename.txt 查询结果输出到文件
* \t 查询结果不返回表头
* \pset format unaligned 不对齐
* \set ECHO_HIDDEN on|off 显示某个命令实际执行的SQL语句
* \timing 开启显示执行时间 或者 `time psql -P pager=off -c 'SELECT ...' >outfile`

```sh
pg_ctl restart # restart db

psql -c "show hba_file;"
         hba_file
--------------------------
 /data/pgdata/pg_hba.conf

# Reload the configuration:
psql -c "select pg_reload_conf();"

SHOW data_directory;

# 赋值给变量
IS_STANDBY=$(sudo -u postgres psql -U postgres -tAc "SELECT pg_is_in_recovery()")

# 建库
createdb -T template0 newdb

```

## SQL 命令

```sql
select version(); #显示版本信息

-- lists databases
-- \l
SELECT datname FROM pg_database WHERE datistemplate = false;

-- 使用数据库
-- \c database_name

-- lists tables in the current database
-- \d
SELECT table_schema,table_name FROM information_schema.tables ORDER BY table_schema,table_name;

-- 创建新表
CREATE TABLE user_tbl(name VARCHAR(20), signup_date DATE);
-- AUTO INCREMENT（自动增长）serial
CREATE TABLE runoob (
    id serial NOT NULL,
    alttext text,
    imgurl text
)

-- 自定义创建模式（schema）
create schema 模式名称;
-- 查看数据库下的所有（schema）
select * from information_schema.schemata;
-- 查询schema中所有表
select * from pg_tables;
select table_name from information_schema.tables where table_schema = 'myuser';
-- 查询数据库中的所有表及其描述
select relname as TABLE_NAME ,col_description(c.oid, 0) as COMMENTS from pg_class c where relkind = 'r' and relname not like 'pg_%' and relname not like 'sql_%'

-- 查看数据库中所有的 view
-- \dv *.*
select schemaname, viewname from pg_catalog.pg_views
where schemaname NOT IN ('pg_catalog', 'information_schema')
order by schemaname, viewname;

-- 插入数据
INSERT INTO user_tbl(name, signup_date) VALUES('张三', '2013-12-22');

-- 选择记录
SELECT * FROM user_tbl;

-- 更新数据
UPDATE user_tbl set name = '李四' WHERE name = '张三';

-- 删除记录
DELETE FROM user_tbl WHERE name = '李四' ;

-- 添加列
ALTER TABLE user_tbl ADD email VARCHAR(40);

-- 更新结构
ALTER TABLE user_tbl ALTER COLUMN signup_date SET NOT NULL;

-- 更名栏位
ALTER TABLE user_tbl RENAME COLUMN signup_date TO signup;

-- 删除栏位
ALTER TABLE user_tbl DROP COLUMN email;

-- 表格更名
ALTER TABLE user_tbl RENAME TO backup_tbl;

-- 删除表格
DROP TABLE IF EXISTS backup_tbl;

-- 创建数据库
create database 数据库名 owner 所属用户 encoding UTF8;
-- 注意：删库前需要关闭所有会话，不然会提示：
-- ERROR:  database "mydb" is being accessed by other users
-- DETAIL:  There are 8 other sessions using the database.
drop database 数据库名;

-- 关闭数据库所有会话
SELECT pg_terminate_backend(pg_stat_activity.pid)
FROM pg_stat_activity
WHERE datname='mydb' AND pid<>pg_backend_pid();

-- 查看view 定义
\d+ pg_roles;
select pg_get_viewdef('pg_roles', true);

-- 查询注释
SELECT
a.attname as "字段名",
col_description(a.attrelid,a.attnum) as "注释",
concat_ws('',t.typname,SUBSTRING(format_type(a.atttypid,a.atttypmod) from '(.*)')) as "字段类型"
FROM
pg_class as c,
pg_attribute as a,
pg_type as t
WHERE
c.relname = 't_batch_task'
and a.atttypid = t.oid
and a.attrelid = c.oid
and a.attnum>0;

-- 索引
-- 查看索引
\di t_user
select * from pg_indexes where tablename = 'table_name';
CREATE INDEX index_name ON table_name (column1_name, column2_name);
CREATE UNIQUE INDEX index_name on table_name (column_name);
DROP INDEX index_name;
DROP INDEX  if exists index_name;

-- PostgreSQL does not define round(double precision, integer)
-- it is required to convert to numeric type
-- float8 is just a shorthand alias for double precision
SELECT round( CAST(float8 '3.1415927' as numeric), 2);
SELECT round( CAST(double precision '3.1415927' as numeric), 2);
```

### 建表语句

```sql
create table "t_user" (
 "id" bigserial not null,
 "username" varchar (64) not null,
 "password" varchar (64) not null,
 "create_time" timestamp not null default current_timestamp,
 "update_time" timestamp not null default current_timestamp,
 constraint t_user_pk primary key (id)
);
comment on column "t_user"."id" is '主键';
comment on column "t_user"."username" is '用户名';
comment on column "t_user"."password" is '密码';
comment on column "t_user"."create_time" is '创建时间';
comment on column "t_user"."update_time" is '更新时间';

insert into t_user (username,password) values ('u1','p1');

-- 序号类型SERIAL和BIGSERIAL并不是真正的类型， 只是为在表中设置唯一标识做的概念上的便利。在目前的实现中，下面一句话：
CREATE TABLE tablename (colname SERIAL);
-- 等价于
CREATE SEQUENCE tablename_colname_seq;
CREATE TABLE tablename(
    colname integer DEFAULT nextval('tablename_colname_seq') NOT NULL
);
-- 设置sequence 自增 id 值
SELECT pg_catalog.setval('tablename_colname_seq', 1, true);

-- 根据已有表结构创建表
create table if not exists 新表 (like 旧表 including indexes including comments including defaults);

-- 显示表结构
\d+ tablename

-- 命令行导出建表语句
pg_dump -t 'schema-name.table-name' --schema-only database-name
TABLE=basetest; pg_dump -U postgres dbname -t $TABLE --schema-only > $TABLE.sql
```

### 创建用户和授权

```sql
CREATE USER dbuser WITH PASSWORD 'password';
-- 创建用户数据库，这里为exampledb，并指定所有者为dbuser。
CREATE DATABASE exampledb OWNER dbuser;
--创建管理员 pgadmin
create role pgadmin with superuser login password 'pgadminAa123456';
--创建开发用户
create role dbuser with login password 'pwd' connection limit 10 valid until '2023-01-16 00:00:00';

-- 将exampledb数据库的所有权限都赋予dbuser，否则dbuser只能登录控制台，没有任何数据库操作权限。
GRANT ALL PRIVILEGES ON DATABASE exampledb to dbuser;
-- [42501]: ERROR: permission denied for schema public
-- Login to psql using a user with superuser priv.
-- Change to the target database
-- Grant CREATE on 'public' schema to the target user
GRANT CREATE ON SCHEMA public TO dbuser;
grant all privileges on all tables in schema public to dbuser;
grant all privileges on all sequences in schema public to dbuser;
grant all privileges on all functions in schema public to dbuser;
grant select on all tables in schema public to dbuser;
--将pgadmin模式的所有权限授权给pgadmin
grant create,usage on schema pgadmin to pgadmin;

revoke create on schema public from dbuser;
revoke all privileges on all tables in schema public from dbuser;
revoke all privileges on all functions in schema public from dbuser;
revoke all privileges on all sequences in schema public from dbuser;

-- [PostgreSQL: Documentation: 8.0: ALTER USER](https://www.postgresql.org/docs/8.0/sql-alteruser.html)
-- 设置超级用户
ALTER ROLE dbuser SUPERUSER CREATEDB CREATEROLE INHERIT LOGIN NOREPLICATION NOBYPASSRLS;
-- remove the SUPERUSER privilege from a role
ALTER ROLE dbuser WITH NOSUPERUSER;
-- 设置只读权限
alter user dbuser set default_transaction_read_only = on;
-- 密码有效期 仅针对客户端有效，服务器端不受限制
alter role dbuser valid until '2022-12-31 23:59:59';
alter role dbuser PASSWORD 'password';

-- 将 owner 转移给其他角色
ALTER TABLE table_name OWNER TO new_owner;
ALTER SEQUENCE sequence_name OWNER TO new_owner;
ALTER FUNCTION function_name OWNER TO new_owner;

-- 用户加入到指定的用户组
--将pgadmin加入到admin组
alter group admin add user pgadmin;
--将 dbuser 加入到developer组
alter group developer add user dbuser;

-- 撤回在public模式下的权限
revoke select on all tables in schema public from dbuser;

-- 撤回在information_schema模式下的权限
revoke select on all tables in schema information_schema from dbuser;

-- 撤回在pg_catalog模式下的权限
revoke select on all tables in schema pg_catalog from dbuser;
--任何用户都拥有public模式的所有权限
-- 回收 dbuser在public的create权限
revoke create on schema public from dbuser;
--出于安全，回收任何用户在public的create权限
revoke create on schema public from public;
-- 撤回对数据库的操作权限
revoke all on database 数据库名 from dbuser;

-- 删除用户 删除前需要回收用户的权限，然后才能删除
drop user dbuser;

SELECT * FROM pg_roles;

-- Check Database-Level Privileges
SELECT datname, has_database_privilege('dbuser', datname, 'CONNECT') AS connect,
       has_database_privilege('dbuser', datname, 'CREATE') AS create,
       has_database_privilege('dbuser', datname, 'TEMP') AS temp
FROM pg_database;

-- Check Schema-Level Privileges
SELECT nspname, has_schema_privilege('dbuser', nspname, 'CREATE') AS create,
       has_schema_privilege('dbuser', nspname, 'USAGE') AS usage
FROM pg_namespace;

-- Check Table-Level Privileges
SELECT table_schema, table_name,
       has_table_privilege('dbuser', table_schema || '.' || table_name, 'SELECT') AS select,
       has_table_privilege('dbuser', table_schema || '.' || table_name, 'INSERT') AS insert,
       has_table_privilege('dbuser', table_schema || '.' || table_name, 'UPDATE') AS update,
       has_table_privilege('dbuser', table_schema || '.' || table_name, 'DELETE') AS delete
FROM information_schema.tables
WHERE table_type = 'BASE TABLE' AND table_schema NOT IN ('pg_catalog', 'information_schema');

-- Check Sequence-Level Privileges
SELECT sequence_schema, sequence_name,
       has_sequence_privilege('dbuser', sequence_schema || '.' || sequence_name, 'USAGE') AS usage,
       has_sequence_privilege('dbuser', sequence_schema || '.' || sequence_name, 'SELECT') AS select,
       has_sequence_privilege('dbuser', sequence_schema || '.' || sequence_name, 'UPDATE') AS update
FROM information_schema.sequences
WHERE sequence_schema NOT IN ('pg_catalog', 'information_schema');

-- Check Function-Level Privileges
-- 执行时遇到错误，需要判断 function 的参数
-- SELECT routine_schema, routine_name,
--        has_function_privilege('dbuser', routine_schema || '.' || routine_name, 'EXECUTE') AS execute
-- FROM information_schema.routines
-- WHERE routine_schema NOT IN ('pg_catalog', 'information_schema');

-- list all privileges of a role (grantee)
SELECT table_catalog, table_schema, table_name, privilege_type
   FROM   information_schema.table_privileges
   WHERE  grantee = 'dbuser';

-- list all privileges of all roles (grantee) except someone (pg_monitor, PUBLIC)
SELECT grantee,table_catalog, table_schema, table_name, privilege_type
   FROM   information_schema.table_privileges
   WHERE  grantee not in ('pg_monitor','PUBLIC');

-- Table permissions:
SELECT *
   FROM information_schema.role_table_grants
   WHERE grantee = 'dbuser';
-- Ownership
SELECT *
   FROM pg_tables
   WHERE tableowner = 'dbuser';

-- Schema permissions
SELECT r.usename AS grantor,
             e.usename AS grantee,
             nspname,
             privilege_type,
             is_grantable
        FROM pg_namespace
   JOIN LATERAL (SELECT *
                FROM aclexplode(nspacl) AS x) a
          ON true
        JOIN pg_user e
          ON a.grantee = e.usesysid
        JOIN pg_user r
          ON a.grantor = r.usesysid
       WHERE e.usename = 'dbuser';

-- list all grantee of a table
SELECT grantee, privilege_type
   FROM information_schema.role_table_grants
   WHERE table_name='mytable'
-- output
mail=# select grantee, privilege_type from information_schema.role_table_grants where table_name='aliases';
   grantee    |  privilege_type
--------------+-----------------
 mailreader   |  INSERT
 mailreader   |  SELECT
 mailreader   |  UPDATE
 mailreader   |  DELETE
 mailreader   |  TRUNCATE
 mailreader   |  REFERENCES
 mailreader   |  TRIGGER
(7 rows)
```

### 字符串操作

substring字符串截取

```sql
--从第一个位置开始截取，截取4个字符,返回结果:Post
SELECT SUBSTRING ('PostgreSQL', 1, 4);
-- 从第8个位置开始截取，截取到最后一个字符，返回结果:SQL
SELECT SUBSTRING ('PostgreSQL', 8);
--正则表达式截取，截取'gre'字符串
SELECT SUBSTRING ('PostgreSQL', 'gre');
```

### 数据库重命名

```sql
-- 1. 断开连接（重命名数据库时，不能有任何连接至改数据库）
SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE datname='name' AND pid<>pg_backend_pid();

-- 2. 重命名
ALTER DATABASE name RENAME TO newname;

-- 列出所有数据库
select datname from pg_catalog.pg_database where datname not in ('postgres','template0','template1') order by 1;
```

### 时间操作

```sql
-- to_timestamp() 字符串转时间
select * from t_user
where create_time >= to_timestamp('2023-01-01 00:00:00', 'yyyy-mm-dd hh24:MI:SS');

-- to_char 时间转字符串
select to_char(create_time, 'yyyy-mm-dd hh24:MI:SS') from t_user;

-- 当前时间加一天
SELECT NOW()::TIMESTAMP + '1 day';
SELECT NOW() + INTERVAL '1 DAY';
SELECT now()::timestamp + ('1' || ' day')::interval
-- 当前时间减一天
SELECT NOW()::TIMESTAMP + '-1 day';
SELECT NOW() - INTERVAL '1 DAY';
SELECT now()::timestamp - ('1' || ' day')::interval
-- 加1年1月1天1时1分1秒
select NOW()::timestamp + '1 year 1 month 1 day 1 hour 1 min 1 sec';
```

### 查看当前连接和登录用户

```sql
SELECT * from pg_stat_activity;
SELECT * from pg_stat_activity where datname = 'dbname' and client_addr not in ( '172.28.7.53', '172.28.7.54') order by client_addr, application_name;
```

### 获取数据库表大小

```sql
-- 查看数据库表大小
select pg_database_size('playboy');
-- 1、查询执行数据库大小
select pg_size_pretty (pg_database_size('dbname'));
-- 2、查询数据库实例当中各个数据库大小
select datname, pg_size_pretty (pg_database_size(datname)) AS size from pg_database;
-- 3、查询单表数据大小
select pg_size_pretty(pg_relation_size('product')) as size;
-- 4、查询数据库表包括索引的大小
select pg_size_pretty(pg_total_relation_size('table_name')) as size;
-- 5、查看表中索引大小
select pg_size_pretty(pg_indexes_size('product'));
-- 6、获取各个表中的数据记录数
select relname as TABLE_NAME, reltuples as rowCounts from pg_class where relkind = 'r' and relname not like 'pg%' order by rowCounts desc;
-- 7、查看数据库表对应的数据文件
select pg_relation_filepath('product');
```

### 一些特殊需求的 SQL

对比两张表的结构和数据是否完全相同

```sql
SELECT *
FROM table1
WHERE table1 NOT IN (SELECT * FROM table2)
UNION ALL
SELECT *
FROM table2
WHERE table2 NOT IN (SELECT * FROM table1);
```

### timing

`\timing` is specific to the client psql, not to the database server. You need to put that into the configuration file for psql which is `~/.psqlrc`

To enable timing for all your psql sessions, run this in your shell (note the double backslash): `echo '\\timing on' >> ~/.psqlrc`

See the manual for details: [psql](https://www.postgresql.org/docs/current/app-psql.html#AEN100589)

psql attempts to read and execute commands from the system-wide startup file (psqlrc) and then the user's personal startup file (~/.psqlrc), after connecting to the database but before accepting normal commands

### PostgreSQL 大小写敏感(区分大小写)

[PostgreSQL 16: 4.1. Lexical Structure](https://www.postgresql.org/docs/current/sql-syntax-lexical.html#SQL-SYNTAX-IDENTIFIERS)

key words：比如 SELECT, UPDATE, or VALUES
identifiers：标识符

Quoted identifiers：case-sensitive
unquoted names：always folded to lower case。（与 SQL 标准不兼容，标准规定未带引号的名称应折叠为大写）

1. PostgreSQL 对建立的对象（存储过程、函数、表、字段、序列等）名称的大小写敏感；
2. PostgreSQL 中，执行 SQL 语句时，会把所有标识符（库名，表名，列名等）字符串转换成小写。所以又说 PostgreSQL 不区分大小写，如`select * from NODE`和`select * from node`是完全一致的；
3. 如要查询或调用大写的 PostgreSQL 对象，需在对应的名称上加双引号，如 "NODE", `select * from "NODE"`；
4. 查询数据中的大小写敏感

建议就是PostgreSQL中能用小写的就小写，毕竟"NODE"这种加双引号的写法总感觉怪怪的。

例子：

```sql
-- [PostgreSQL大小写的坑 - GoodGF - 博客园](https://www.cnblogs.com/gaofan/p/11398753.html)

-- 建立了大写的表NODE，查询不论是用NODE还是node都不行，需用"NODE"才可识别。
SELECT * from  "NODE" ;
-- 建立了小写的表edge，查询不论是用EDGE还是edge都可以，"edge"也可识别。
SELECT * from edge ; -- 或 EDGE 或"edge"

-- 存储过程测试结论与表名一样。
-- 大写的存储过程TP_INSERT需用加双引号来调用。
call "TP_INSERT"();
-- 小写的存储过程tp_select, 可用下面几种格式
call tp_select();
call TP_SELECT();
call "tp_select"();

-- 字段名
-- 在NODE表中建立字符型name,Name,NAME三个字段(居然能建成功)，对应插入值'lili','Lili','LILI'。
INSERT INTO public."NODE"(name, "Name", "NAME")  VALUES ('lili','Lili', 'LILI');   //插入成功
SELECT  name,"Name","NAME" from "NODE"; //查询正确返回值
-- 小写表的测试结果与上述结果相同。
```

## Performance

[PostgreSQL 16: Chapter 14. Performance Tips](https://www.postgresql.org/docs/16/performance-tips.html)
[Introduction to PostgreSQL Performance Tuning | EDB](https://www.enterprisedb.com/postgres-tutorials/introduction-postgresql-performance-tuning-and-optimization)

### 索引

[PostgreSQL 索引技术详解](https://cloud.tencent.com/developer/article/2315287)
[PostgreSQL 16: 73.6. Database Page Layout](https://www.postgresql.org/docs/current/storage-page-layout.html)
[导致慢SQL的原因和解决方案_云数据库 RDS(RDS)-阿里云帮助中心](https://help.aliyun.com/zh/rds/apsaradb-rds-for-postgresql/slow-sql-queries)

```sql
\di t_user
select * from pg_indexes where tablename = 'table_name';
CREATE INDEX index_name ON table_name (column1_name, column2_name);
CREATE UNIQUE INDEX index_name on table_name (column_name);
DROP INDEX index_name;
```

### explain 查询计划

[PostgreSQL 执行计划](https://cloud.tencent.com/developer/article/2315274)

### 检查慢 SQL

检查慢 SQL top 5

```sql
-- 检查慢 SQL top 5
select
     to_char(now(),'yyyy-mm-dd hh24:mi:ss') "巡检时间"
    ,a.datname "datname(数据库名)"
    ,a.pid "pid(进程id)"
    ,b.rolname "username(dbuser)"
    --,a.application_name "app_name(应用名称)"
    ,a.client_addr "client_ip(客户端ip)"
    --,a.query_start "query_start(当前查询开始时间)"
    ,to_char(a.state_change,'yyyy-mm-dd hh24:mi:ss') "state_change(状态变化时间)"
    --,a.wait_event_type "wait_event_type(等待类型)"
    --,a.wait_event "wait_event(等待事件)"
    --,a.state "state(状态)"
    --,a.query "sql(执行的sql)"
    --,a.backend_type "backend_type(后端类型)"
from pg_stat_activity a
left join pg_roles b
on (a.usesysid = b.oid)
where a.state = 'active'
    and state_change < current_timestamp - interval '1 hour'
    and a.datname is not null
order by current_timestamp-state_change desc
limit 5;
```

pg_stat_statements

1. 执行时间单位 毫秒
2. dbid 可以到 pg_database 查询 `select oid, datname,datdba from pg_database where oid = $dbid;`

```sql
-- [PostgreSQL 16: F.32. pg_stat_statements — track statistics of SQL planning and execution](https://www.postgresql.org/docs/16/pgstatstatements.html)
-- 查询最耗时的5个sql  需要开启 pg_stat_statements
select * from pg_stat_statements order by total_exec_time desc limit 5;

-- 获取执行时间最慢的3条SQL，并给出CPU占用比例
SELECT substring(query, 1, 1000) AS short_query,
   round(total_exec_time::numeric, 2) AS total_exec_time, calls,
   round((100 * total_exec_time / sum(total_exec_time::numeric) OVER ())::numeric, 2) AS percentage_cpu
FROM pg_stat_statements
ORDER BY total_exec_time DESC LIMIT 3;

-- 重置 If no parameter is specified or all the specified parameters are 0(invalid), it will discard all statistics. By default, this function can only be executed by superusers. Access may be granted to others using GRANT.
SELECT pg_stat_statements_reset();

-- 6、分析评估SQL执行情况
EXPLAIN ANALYZE SELECT * FROM product

-- 7、查看当前长时间执行却不结束的SQL
select datname, usename, client_addr, application_name, state, backend_start, xact_start, xact_stay, query_start, query_stay, replace(query, chr(10), ' ') as query from (select pgsa.datname as datname, pgsa.usename as usename, pgsa.client_addr client_addr, pgsa.application_name as application_name, pgsa.state as state, pgsa.backend_start as backend_start, pgsa.xact_start as xact_start, extract(epoch from (now() - pgsa.xact_start)) as xact_stay, pgsa.query_start as query_start, extract(epoch from (now() - pgsa.query_start)) as query_stay , pgsa.query as query from pg_stat_activity as pgsa where pgsa.state != 'idle' and pgsa.state != 'idle in transaction' and pgsa.state != 'idle in transaction (aborted)') idleconnections order by query_stay desc limit 5;

-- 查询当前执行时间超过60s的sql
select datname, pid, query, client_addr, clock_timestamp() - query_start
from pg_stat_activity
where
 (state = any (array['active'::text, 'idle in transaction'::text]))
 and (clock_timestamp() - query_start) > '00:00:60'::interval
order by
 (clock_timestamp() - query_start) desc;

-- 查询当前执行时间超过 5 分钟的sql
SELECT pid, user, pg_stat_activity.query_start,
  now() - pg_stat_activity.query_start AS query_time,
  query, state, wait_event_type, wait_event
FROM pg_stat_activity
WHERE (now() - pg_stat_activity.query_start) > interval '5 minutes';

-- 8、查出使用表扫描最多的表
select * from pg_stat_user_tables where n_live_tup > 100000 and seq_scan > 0 order by seq_tup_read desc limit 10;
-- 9、查询读取buffer最多的5个SQL
select * from pg_stat_statements order by shared_blks_hit+shared_blks_read desc limit 5;

-- 查询访问指定表的慢查询
select * from pg_stat_activity where query ilike '%<table_name>%' and query_start - now() > interval '10 seconds';

-- 查看当前wal的buffer中有多少字节未写入磁盘
select pg_xlog_location_diff(pg_current_xlog_insert_location(),pg_current_xlog_location());
```

### 查看阻塞的 SQL

[进阶数据库系列（八）：PostgreSQL 锁机制-腾讯云开发者社区-腾讯云](https://cloud.tencent.com/developer/article/2315270)
[PostgreSQL: 13.3. Explicit Locking](https://www.postgresql.org/docs/current/explicit-locking.html)

`SELECT pg_cancel_backend(pid);` – session还在，事务回退;
`SELECT pg_terminate_backend(pid);` --session消失，事务回退

* `pg_stat_activity`: A table with one entry per server process, showing details of the running query for each. 只返回 session 的最后一条查询，而不一定是导致阻塞的查询
* `pg_locks`: Information on current locks held within the database by open transactions, with one row per lockable object.
* `pg_blocking_pids()`: A function that can find the process IDs (PIDs) of sessions that are blocking the PostgreSQL server process of a supplied PID. [pg_blocking_pids() - pgPedia](https://pgpedia.info/p/pg_blocking_pids.html)
* `pg_cancel_backend()`: Function that cancels the currently running query by sending a SIGINT to a process ID.
* `pg_terminate_backend()`: Terminate a backend process completely (the query and usually the connection) on the database (uses SIGTERM instead of SIGINT).

select * from pg_catalog.pg_locks;

```sql
-- 查看 view 结构
\d+ pg_stat_activity
-- check the active queries
SELECT * FROM pg_stat_activity WHERE state != 'idle';
-- check the blocked queries
SELECT * FROM pg_stat_activity WHERE state = 'blocked';

-- 返回全部信息
SELECT * FROM pg_stat_activity where cardinality(pg_blocking_pids(pid)) > 0;

-- list details about blocked sessions:
-- Since 9.6 this is a lot easier as it introduced the function pg_blocking_pids() to find the sessions that are blocking another session.
select pid, usename, client_addr, pg_blocking_pids(pid) as blocked_by, query as blocked_query
   from pg_stat_activity
   where cardinality(pg_blocking_pids(pid)) > 0;

-- 同时返回 query, blocking_id 和 blocking_query, 只返回 session 的最后一条查询，而不一定是导致阻塞的查询
SELECT activity.pid, activity.usename, activity.query, client_addr
      blocking.pid AS blocking_id, blocking.query AS blocking_query, blocking.client_addr AS blocking_client_addr
   FROM pg_stat_activity AS activity
   JOIN pg_stat_activity AS blocking ON blocking.pid = ANY(pg_blocking_pids(activity.pid));

-- kill a blocked query by using the below command.
SELECT pg_cancel_backend(pid), pg_terminate_backend(pid);

-- terminate all blocked queries 直接 kill 掉
SELECT pg_cancel_backend(a.pid), pg_terminate_backend(a.pid)
   FROM (select pid, usename, pg_blocking_pids(pid) as blocked_by, query as blocked_query
         from pg_stat_activity where cardinality(pg_blocking_pids(pid)) > 0) a
```

find the locked objects/tables from PG_LOCKS view
The view pg_locks provides access to information about the locks held by open transactions within the database server.

```sql
-- relation: OID of the relation targeted by lock.
-- pid: Process ID of the server process holding or awaiting this lock.
-- locktype: Type of the lockable object: relation, extend, page, tuple, transactionid, virtualxid, object, userlock, or advisory
-- mode: Name of the lock mode held or desired by this process
-- granted: True if lock is held, false if lock is awaited
select pid, locktype , relation , mode, granted from pg_catalog.pg_locks pl where pl.pid in (<pid>);
select * from pg_catalog.pg_locks pl where pl.pid in (<pid>);

-- get the other processes that acquired lock on the same table
select pid, locktype , relation , mode, granted from pg_catalog.pg_locks pl where pl.relation = <relation-from-sql-above>;
select * from pg_catalog.pg_locks pl where pl.relation = <relation-from-sql-above>;
```

#### 查找阻塞的 SQL

##### 使用监控锁的视图

```sql
-- 创建 active_locks 视图
-- View with readable locks info and filtered out locks on system tables
CREATE VIEW active_locks AS
SELECT clock_timestamp(), pg_class.relname, pg_locks.locktype, pg_locks.database,
       pg_locks.relation, pg_locks.page, pg_locks.tuple, pg_locks.virtualtransaction,
       pg_locks.pid, pg_locks.mode, pg_locks.granted
FROM pg_locks JOIN pg_class ON pg_locks.relation = pg_class.oid
WHERE relname !~ '^pg_' and relname <> 'active_locks';

-- 创建 active_locks 视图的另一个写法 https://stackoverflow.com/a/23060492/1086907
CREATE OR REPLACE VIEW public.active_locks_join_stat_all AS
 SELECT t.schemaname,
    t.relname,
    l.locktype,
    l.page,
    l.virtualtransaction,
    l.pid,
    l.mode,
    l.granted
   FROM pg_locks l
   JOIN pg_stat_all_tables t ON l.relation = t.relid
  WHERE t.schemaname <> 'pg_toast'::name AND t.schemaname <> 'pg_catalog'::name
  ORDER BY t.schemaname, t.relname;

-- Now when we want to see locks just type
SELECT * FROM postgres.public.active_locks;
SELECT * FROM active_locks;
SELECT * FROM active_locks_join_stat_all;
```

##### 查询 pg_locks 的语句

```sql
--查看会话session
select pg_backend_pid();

--查看会话持有的锁
select * from pg_locks where pid=3797;

--2. 查询存在锁的数据表
select a.locktype,a.database,a.pid,a.mode,a.relation,b.relname -- ,sa.*
from pg_locks a
join pg_class b on a.relation = b.oid
inner join  pg_stat_activity sa on a.pid=sa.procpid

--3.查询某个表内,状态为lock的锁及关联的查询语句
select a.locktype,a.database,a.pid,a.mode,a.relation,b.relname -- ,sa.*
from pg_locks a
join pg_class b on a.relation = b.oid
inner join  pg_stat_activity sa on a.pid=sa.procpid
where a.database=382790774  and sa.waiting_reason='lock'
order by sa.query_start
```

##### One PID to Lock Them All: Finding the Source of the Lock in Postgres

[One PID to Lock Them All: Finding the Source of the Lock in Postgres | Crunchy Data Blog](https://www.crunchydata.com/blog/one-pid-to-lock-them-all-finding-the-source-of-the-lock-in-postgres)

```sql
WITH sos AS (
   SELECT array_cat(array_agg(pid),
           array_agg((pg_blocking_pids(pid))[array_length(pg_blocking_pids(pid),1)])) pids
   FROM pg_locks
   WHERE NOT granted
)
SELECT a.pid, a.usename, a.datname, a.state,
      a.wait_event_type || ': ' || a.wait_event AS wait_event,
       current_timestamp-a.state_change time_in_state,
       current_timestamp-a.xact_start time_in_xact,
       l.relation::regclass relname,
       l.locktype, l.mode, l.page, l.tuple,
       pg_blocking_pids(l.pid) blocking_pids,
       (pg_blocking_pids(l.pid))[array_length(pg_blocking_pids(l.pid),1)] last_session,
       coalesce((pg_blocking_pids(l.pid))[1]||'.'||coalesce(case when locktype='transactionid' then 1 else array_length(pg_blocking_pids(l.pid),1)+1 end,0),a.pid||'.0') lock_depth,
       a.query
FROM pg_stat_activity a
     JOIN sos s on (a.pid = any(s.pids))
     LEFT OUTER JOIN pg_locks l on (a.pid = l.pid and not l.granted)
ORDER BY lock_depth;

-- Example output from that statement:
pid   |   usename   | datname  |        state        |     wait_event      |  time_in_state  |  time_in_xact   |  relname   |   locktype    |        mode         | page | tuple |     blocking_pids      | last_session | lock_depth |                       query
--------+-------------+----------+---------------------+---------------------+-----------------+-----------------+------------+---------------+---------------------+------+-------+------------------------+--------------+------------+----------------------------------------------------
 879401 | application | postgres | idle in transaction | Client: ClientRead  | 00:29:53.512147 | 00:30:01.31748  |            |               |                     |      |       |                        |              | 879401.0   | select * from sampledata where id=101 for update;
 880275 | application | postgres | active              | Lock: transactionid | 00:01:00.342763 | 00:01:00.459375 |            | transactionid | ShareLock           |      |       | {879401}               |       879401 | 879401.1   | update sampledata set data = 'abc' where id = 101;
 880204 | application | postgres | active              | Lock: relation      | 00:00:29.722705 | 00:00:29.722707 | sampledata | relation      | AccessExclusiveLock |      |       | {879401,880275,879488} |       879488 | 879401.4   | alter table sampledata add column data03 integer;
 880187 | application | postgres | active              | Lock: relation      | 00:00:03.580716 | 00:00:03.580718 | sampledata | relation      | RowExclusiveLock    |      |       | {880204}               |       880204 | 880204.2   | update sampledata set data = 'abc' where id = 103;
 879527 | application | postgres | active              | Lock: relation      | 00:00:14.974433 | 00:28:32.80346  | sampledata | relation      | RowExclusiveLock    |      |       | {880204}               |       880204 | 880204.2   | update sampledata set data = 'abc' where id = 102;
 879488 | application | postgres | active              | Lock: tuple         | 00:00:41.35361  | 00:00:41.47118  | sampledata | tuple         | ExclusiveLock       |    2 |    21 | {880275}               |       880275 | 880275.2   | update sampledata set data = 'def' where id = 101;
(6 rows)
```

##### 查看锁等待情况SQL

[进阶数据库系列（八）：PostgreSQL 锁机制-附录一：查看锁等待情况SQL](https://cloud.tencent.com/developer/article/2315270)

```sql
with
 t_wait as
 (
 select a.mode,a.locktype,a.database,a.relation,a.page,a.tuple,a.classid,a.granted,
  a.objid,a.objsubid,a.pid,a.virtualtransaction,a.virtualxid,a.transactionid,a.fastpath,
  b.state,b.query,b.xact_start,b.query_start,b.usename,b.datname,b.client_addr,b.client_port,b.application_name
 from pg_locks a,pg_stat_activity b where a.pid=b.pid and not a.granted
 ),
 t_run as
 (
 select a.mode,a.locktype,a.database,a.relation,a.page,a.tuple,a.classid,a.granted,
  a.objid,a.objsubid,a.pid,a.virtualtransaction,a.virtualxid,a.transactionid,a.fastpath,
  b.state,b.query,b.xact_start,b.query_start,b.usename,b.datname,b.client_addr,b.client_port,b.application_name
 from pg_locks a,pg_stat_activity b where a.pid=b.pid and a.granted
 ),
 t_overlap as
 (
 select r.* from t_wait w join t_run r on
  (
  r.locktype is not distinct from w.locktype and
  r.database is not distinct from w.database and
  r.relation is not distinct from w.relation and
  r.page is not distinct from w.page and
  r.tuple is not distinct from w.tuple and
  r.virtualxid is not distinct from w.virtualxid and
  r.transactionid is not distinct from w.transactionid and
  r.classid is not distinct from w.classid and
  r.objid is not distinct from w.objid and
  r.objsubid is not distinct from w.objsubid and
  r.pid <> w.pid
  )
 ),
 t_unionall as
 (
 select r.* from t_overlap r
 union all
 select w.* from t_wait w
 )
 select locktype,datname,relation::regclass,page,tuple,virtualxid,transactionid::text,classid::regclass,objid,objsubid,
  string_agg(
   'Pid: '||case when pid is null then 'NULL' else pid::text end||chr(10)||
   'Lock_Granted: '||case when granted is null then 'NULL' else granted::text end||' , Mode: '||case when mode is null then 'NULL' else mode::text end||' , FastPath: '||case when fastpath is null then 'NULL' else fastpath::text end||' , VirtualTransaction: '||case when virtualtransaction is null then 'NULL' else virtualtransaction::text end||' , Session_State: '||case when state is null then 'NULL' else state::text end||chr(10)||
   'Username: '||case when usename is null then 'NULL' else usename::text end||' , Database: '||case when datname is null then 'NULL' else datname::text end||' , Client_Addr: '||case when client_addr is null then 'NULL' else client_addr::text end||' , Client_Port: '||case when client_port is null then 'NULL' else client_port::text end||' , Application_Name: '||case when application_name is null then 'NULL' else application_name::text end||chr(10)||
   'Xact_Start: '||case when xact_start is null then 'NULL' else xact_start::text end||' , Query_Start: '||case when query_start is null then 'NULL' else query_start::text end||' , Xact_Elapse: '||case when (now()-xact_start) is null then 'NULL' else (now()-xact_start)::text end||' , Query_Elapse: '||case when (now()-query_start) is null then 'NULL' else (now()-query_start)::text end||chr(10)||
   'SQL (Current SQL in Transaction): '||chr(10)||
   case when query is null then 'NULL' else query::text end,
   chr(10)||'--------'||chr(10)
  order by
   ( case mode
   when 'INVALID' then 0
   when 'AccessShareLock' then 1
   when 'RowShareLock' then 2
   when 'RowExclusiveLock' then 3
   when 'ShareUpdateExclusiveLock' then 4
   when 'ShareLock' then 5
   when 'ShareRowExclusiveLock' then 6
   when 'ExclusiveLock' then 7
   when 'AccessExclusiveLock' then 8
   else 0
   end  ) desc,
   (case when granted then 0 else 1 end)
  ) as lock_conflict
 from t_unionall
 group by
  locktype,datname,relation,page,tuple,virtualxid,transactionid::text,classid,objid,objsubid ;

-- 返回结果
   locktype    | datname | relation | page | tuple | virtualxid | transactionid | classid | objid | objsubid |                                                                               lock_conflict
---------------+---------+----------+------+-------+------------+---------------+---------+-------+----------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 transactionid | dbname |          |      |       |            | 13015         |         |       |          | Pid: 5093                                                                                                                                                                 +
               |         |          |      |       |            |               |         |       |          | Lock_Granted: true , Mode: ExclusiveLock , FastPath: false , VirtualTransaction: 98/168 , Session_State: idle in transaction                                              +
               |         |          |      |       |            |               |         |       |          | Username: user , Database: dbname , Client_Addr: 172.28.36.196/32 , Client_Port: 54107 , Application_Name: DBeaver 24.1.5 - Main <dbname>                                +
               |         |          |      |       |            |               |         |       |          | Xact_Start: 2024-10-14 08:07:08.144585+00 , Query_Start: 2024-10-14 08:10:55.0805+00 , Xact_Elapse: 01:34:44.600878 , Query_Elapse: 01:30:57.664963                       +
               |         |          |      |       |            |               |         |       |          | SQL (Current SQL in Transaction):                                                                                                                                         +
               |         |          |      |       |            |               |         |       |          | SELECT x.* FROM public.fact_consumption_data_point_hourly x                                                                                                               +
               |         |          |      |       |            |               |         |       |          | WHERE id = 4                                                                                                                                                              +
               |         |          |      |       |            |               |         |       |          | --------                                                                                                                                                                  +
               |         |          |      |       |            |               |         |       |          | Pid: 5311                                                                                                                                                                 +
               |         |          |      |       |            |               |         |       |          | Lock_Granted: false , Mode: ShareLock , FastPath: false , VirtualTransaction: 16/13636 , Session_State: active                                                            +
               |         |          |      |       |            |               |         |       |          | Username: user , Database: dbname , Client_Addr: 172.28.36.196/32 , Client_Port: 56616 , Application_Name: DBeaver 24.1.5 - Main <dbname>                                +
               |         |          |      |       |            |               |         |       |          | Xact_Start: 2024-10-14 09:13:43.544583+00 , Query_Start: 2024-10-14 09:13:43.545181+00 , Xact_Elapse: 00:28:09.20088 , Query_Elapse: 00:28:09.200282                      +
               |         |          |      |       |            |               |         |       |          | SQL (Current SQL in Transaction):                                                                                                                                         +
               |         |          |      |       |            |               |         |       |          | UPDATE public.fact_consumption_data_point_hourly                                                                                                                          +
               |         |          |      |       |            |               |         |       |          |         SET consumption_time_id=$1                                                                                                                                        +
               |         |          |      |       |            |               |         |       |          |         WHERE id=$2
 tuple         | dbname | 26319    |    0 |    26 |            |               |         |       |          | Pid: 5311                                                                                                                                                                 +
               |         |          |      |       |            |               |         |       |          | Lock_Granted: true , Mode: ExclusiveLock , FastPath: false , VirtualTransaction: 16/13636 , Session_State: active                                                         +
               |         |          |      |       |            |               |         |       |          | Username: user , Database: dbname , Client_Addr: 172.28.36.196/32 , Client_Port: 56616 , Application_Name: DBeaver 24.1.5 - Main <dbname>                                +
               |         |          |      |       |            |               |         |       |          | Xact_Start: 2024-10-14 09:13:43.544583+00 , Query_Start: 2024-10-14 09:13:43.545181+00 , Xact_Elapse: 00:28:09.20088 , Query_Elapse: 00:28:09.200282                      +
               |         |          |      |       |            |               |         |       |          | SQL (Current SQL in Transaction):                                                                                                                                         +
               |         |          |      |       |            |               |         |       |          | UPDATE public.fact_consumption_data_point_hourly                                                                                                                          +
               |         |          |      |       |            |               |         |       |          |         SET consumption_time_id=$1                                                                                                                                        +
               |         |          |      |       |            |               |         |       |          |         WHERE id=$2                                                                                                                                                       +
               |         |          |      |       |            |               |         |       |          | --------                                                                                                                                                                  +
               |         |          |      |       |            |               |         |       |          | Pid: 5311                                                                                                                                                                 +
               |         |          |      |       |            |               |         |       |          | Lock_Granted: true , Mode: ExclusiveLock , FastPath: false , VirtualTransaction: 16/13636 , Session_State: active                                                         +
               |         |          |      |       |            |               |         |       |          | Username: user , Database: dbname , Client_Addr: 172.28.36.196/32 , Client_Port: 56616 , Application_Name: DBeaver 24.1.5 - Main <dbname>                                +
               |         |          |      |       |            |               |         |       |          | Xact_Start: 2024-10-14 09:13:43.544583+00 , Query_Start: 2024-10-14 09:13:43.545181+00 , Xact_Elapse: 00:28:09.20088 , Query_Elapse: 00:28:09.200282                      +
               |         |          |      |       |            |               |         |       |          | SQL (Current SQL in Transaction):                                                                                                                                         +
               |         |          |      |       |            |               |         |       |          | UPDATE public.fact_consumption_data_point_hourly                                                                                                                          +
               |         |          |      |       |            |               |         |       |          |         SET consumption_time_id=$1                                                                                                                                        +
               |         |          |      |       |            |               |         |       |          |         WHERE id=$2                                                                                                                                                       +
               |         |          |      |       |            |               |         |       |          | --------                                                                                                                                                                  +
               |         |          |      |       |            |               |         |       |          | Pid: 5343                                                                                                                                                                 +
               |         |          |      |       |            |               |         |       |          | Lock_Granted: false , Mode: ExclusiveLock , FastPath: false , VirtualTransaction: 59/1874 , Session_State: active                                                         +
               |         |          |      |       |            |               |         |       |          | Username: user , Database: dbname , Client_Addr: 172.28.36.196/32 , Client_Port: 56880 , Application_Name: DBeaver 24.1.5 - SQLEditor <ETL\xe9\x87\x8d\xe7\x82\xb9\xe8\xae+
               |         |          |      |       |            |               |         |       |          | Xact_Start: 2024-10-14 09:19:36.976799+00 , Query_Start: 2024-10-14 09:19:36.977812+00 , Xact_Elapse: 00:22:15.768664 , Query_Elapse: 00:22:15.767651                     +
               |         |          |      |       |            |               |         |       |          | SQL (Current SQL in Transaction):                                                                                                                                         +
               |         |          |      |       |            |               |         |       |          | update \r                                                                                                                                                                 +
               |         |          |      |       |            |               |         |       |          | fact_consumption_data_point_hourly\r                                                                                                                                      +
               |         |          |      |       |            |               |         |       |          | set consumption_time_id= 62024101417                                                                                                                                      +
               |         |          |      |       |            |               |         |       |          | --------                                                                                                                                                                  +
               |         |          |      |       |            |               |         |       |          | Pid: 5400                                                                                                                                                                 +
               |         |          |      |       |            |               |         |       |          | Lock_Granted: false , Mode: ExclusiveLock , FastPath: false , VirtualTransaction: 55/12002 , Session_State: active                                                        +
               |         |          |      |       |            |               |         |       |          | Username: user , Database: dbname , Client_Addr: 172.28.36.196/32 , Client_Port: 57379 , Application_Name: DBeaver 24.1.5 - SQLEditor <ETL\xe9\x87\x8d\xe7\x82\xb9\xe8\xae+
               |         |          |      |       |            |               |         |       |          | Xact_Start: 2024-10-14 09:30:54.633174+00 , Query_Start: 2024-10-14 09:30:54.635058+00 , Xact_Elapse: 00:10:58.112289 , Query_Elapse: 00:10:58.110405                     +
               |         |          |      |       |            |               |         |       |          | SQL (Current SQL in Transaction):                                                                                                                                         +
               |         |          |      |       |            |               |         |       |          | update \r                                                                                                                                                                 +
               |         |          |      |       |            |               |         |       |          | fact_consumption_data_point_hourly\r                                                                                                                                      +
               |         |          |      |       |            |               |         |       |          | set consumption_time_id= 62024101417
(2 rows)

```

##### 查看阻塞会话，类似MySQL的 show processlist，并生成 kill sql

```sql
with recursive
tmp_lock as (
 select distinct
  --w.mode w_mode,w.page w_page,
  --w.tuple w_tuple,w.xact_start w_xact_start,w.query_start w_query_start,
  --now()-w.query_start w_locktime,w.query w_query
  w.pid as id,--w_pid,
  r.pid as parentid--r_pid,
  --r.locktype,r.mode r_mode,r.usename r_user,r.datname r_db,
  --r.relation::regclass,
  --r.page r_page,r.tuple r_tuple,r.xact_start r_xact_start,
  --r.query_start r_query_start,
  --now()-r.query_start r_locktime,r.query r_query,
 from (
  select a.mode,a.locktype,a.database,
  a.relation,a.page,a.tuple,a.classid,
  a.objid,a.objsubid,a.pid,a.virtualtransaction,a.virtualxid,
  a.transactionid,
  b.query as query,
  b.xact_start,b.query_start,b.usename,b.datname
  from pg_locks a,
  pg_stat_activity b
  where a.pid=b.pid
  and not a.granted
 ) w,
 (
  select a.mode,a.locktype,a.database,
  a.relation,a.page,a.tuple,a.classid,
  a.objid,a.objsubid,a.pid,a.virtualtransaction,a.virtualxid,
  a.transactionid,
  b.query as query,
  b.xact_start,b.query_start,b.usename,b.datname
  from pg_locks a,
  pg_stat_activity b -- select pg_typeof(pid) from pg_stat_activity
  where a.pid=b.pid
  and a.granted
 ) r
 where 1=1
  and r.locktype is not distinct from w.locktype
  and r.database is not distinct from w.database
  and r.relation is not distinct from w.relation
  and r.page is not distinct from w.page
  and r.tuple is not distinct from w.tuple
  and r.classid is not distinct from w.classid
  and r.objid is not distinct from w.objid
  and r.objsubid is not distinct from w.objsubid
  and r.transactionid is not distinct from w.transactionid
  and r.pid <> w.pid
 ),
tmp0 as (
 select *
 from tmp_lock tl
 union all
 select t1.parentid,0::int4
 from tmp_lock t1
 where 1=1
 and t1.parentid not in (select id from tmp_lock)
 ),
tmp3 (pathid,depth,id,parentid) as (
 SELECT array[id]::text[] as pathid,1 as depth,id,parentid
 FROM tmp0
 where 1=1 and parentid=0
 union
 SELECT t0.pathid||array[t1.id]::text[] as pathid,t0.depth+1 as depth,t1.id,t1.parentid
 FROM tmp0 t1, tmp3 t0
 where 1=1 and t1.parentid=t0.id
)
select distinct
 '/'||array_to_string(a0.pathid,'/') as pathid,
 a0.depth,
 a0.id,a0.parentid,lpad(a0.id::text, 2*a0.depth-1+length(a0.id::text),' ') as tree_id,
 --'select pg_cancel_backend('||a0.id|| ');' as cancel_pid,
 --'select pg_terminate_backend('||a0.id|| ');' as term_pid,
 case when a0.depth =1 then 'select pg_terminate_backend('|| a0.id || ');' else null end  as term_pid,
 case when a0.depth =1 then 'select pg_cancel_backend('|| a0.id || ');' else null end  as cancel_pid
 ,a2.datname,a2.usename,a2.application_name,a2.client_addr,a2.wait_event_type,a2.wait_event,a2.state
 --,a2.backend_start,a2.xact_start,a2.query_start
from tmp3 a0
left outer join (select distinct '/'||id||'/' as prefix_id,id
 from tmp0
 where 1=1 ) a1
on position( a1.prefix_id in '/'||array_to_string(a0.pathid,'/')||'/' ) >0
left outer join pg_stat_activity a2 -- select * from pg_stat_activity
on a0.id = a2.pid
order by '/'||array_to_string(a0.pathid,'/'),a0.depth;

-- 返回结果
     pathid      | depth |  id  | parentid |  tree_id  |              term_pid              |          cancel_pid          | datname | usename |                        application_name                         |  client_addr  | wait_event_type |  wait_event   |        state
-----------------+-------+------+----------+-----------+------------------------------------+------------------------------+---------+---------+-----------------------------------------------------------------+---------------+-----------------+---------------+---------------------
 /5093           |     1 | 5093 |        0 |  5093     | select pg_terminate_backend(5093); | select pg_cancel_backend(5093); | dbname | user     | DBeaver 24.1.5 - Main <dbname>                                 | 172.28.36.196 | Client          | ClientRead    | idle in transaction
 /5093/5311      |     2 | 5311 |     5093 |    5311   |                                    |                              | dbname | user     | DBeaver 24.1.5 - Main <dbname>                                 | 172.28.36.196 | Lock            | transactionid | active
 /5093/5311/5343 |     3 | 5343 |     5311 |      5343 |                                    |                              | dbname | user     | DBeaver 24.1.5 - SQLEditor <ETL\xe9\x87\x8d\xe7\x82\xb9\xe8\xae | 172.28.36.196 | Lock            | tuple         | active
 /5093/5311/5400 |     3 | 5400 |     5311 |      5400 |                                    |                              | dbname | user     | DBeaver 24.1.5 - SQLEditor <ETL\xe9\x87\x8d\xe7\x82\xb9\xe8\xae | 172.28.36.196 | Lock            | tuple         | active
(4 rows)
```

##### find out the blocking pids and blocked pids

[find out the blocking pids and blocked pids](https://medium.com/@kdeep40784/how-to-track-the-processes-competing-with-your-process-for-the-table-locks-in-postgresql-and-kill-e6e4ca776ec8)

无数据返回

```sql
SELECT blocked_locks.pid AS blocked_pid, blocked_activity.usename AS blocked_user,
   blocking_locks.pid AS blocking_pid, blocking_activity.usename AS blocking_user,
   blocked_activity.query AS blocked_statement, blocking_activity.query AS current_statement_in_blocking_process
FROM pg_catalog.pg_locks blocked_locks
JOIN pg_catalog.pg_stat_activity blocked_activity ON blocked_activity.pid = blocked_locks.pid
JOIN pg_catalog.pg_locks blocking_locks
   ON blocking_locks.locktype = blocked_locks.locktype
   AND blocking_locks.database IS NOT DISTINCT FROM blocked_locks.database
   AND blocking_locks.relation IS NOT DISTINCT FROM blocked_locks.relation
   AND blocking_locks.page IS NOT DISTINCT FROM blocked_locks.page
   AND blocking_locks.tuple IS NOT DISTINCT FROM blocked_locks.tuple
   AND blocking_locks.virtualxid IS NOT DISTINCT FROM blocked_locks.virtualxid
   AND blocking_locks.transactionid IS NOT DISTINCT FROM blocked_locks.transactionid
   AND blocking_locks.classid IS NOT DISTINCT FROM blocked_locks.classid
   AND blocking_locks.objid IS NOT DISTINCT FROM blocked_locks.objid
   AND blocking_locks.objsubid IS NOT DISTINCT FROM blocked_locks.objsubid
   AND blocking_locks.pid != blocked_locks.pid
JOIN pg_catalog.pg_stat_activity blocking_activity ON blocking_activity.pid = blocking_locks.pid
WHERE NOT blocked_locks.granted
order by blocking_pid
```

##### How to check which queries are active or blocked in PostgreSQL?

[How to check which queries are active or blocked in PostgreSQL?](https://minervadb.xyz/how-to-check-which-queries-are-active-or-blocked-in-postgresql/)

返回100条

```sql
SELECT blocked_locks.pid     AS blocked_pid,
       blocked_activity.usename  AS blocked_user,
       blocking_locks.pid     AS blocking_pid,
       blocking_activity.usename AS blocking_user,
       blocked_activity.query    AS blocked_statement,
       blocking_activity.query   AS current_statement_in_blocking_process
FROM  pg_catalog.pg_locks         blocked_locks
JOIN  pg_catalog.pg_stat_activity blocked_activity  ON blocked_activity.pid = blocked_locks.pid
JOIN  pg_catalog.pg_locks         blocking_locks
        ON blocking_locks.locktype = blocked_locks.locktype
        AND blocking_locks.DATABASE IS NOT DISTINCT FROM blocked_locks.DATABASE
        AND blocking_locks.relation IS NOT DISTINCT FROM blocked_locks.relation
        AND blocking_locks.page IS NOT DISTINCT FROM blocked_locks.page
        AND blocking_locks.tuple IS NOT DISTINCT FROM blocked_locks.tuple
        AND blocking_locks.virtualxid IS NOT DISTINCT FROM blocked_locks.virtualxid
        AND blocking_locks.transactionid IS NOT DISTINCT FROM blocked_locks.transactionid
        AND blocking_locks.classid IS NOT DISTINCT FROM blocked_locks.classid
        AND blocking_locks.objid IS NOT DISTINCT FROM blocked_locks.objid
        AND blocking_locks.objsubid IS NOT DISTINCT FROM blocked_locks.objsubid
        AND blocking_locks.pid != blocked_locks.pid
JOIN  pg_catalog.pg_stat_activity blocking_activity ON blocking_activity.pid = blocking_locks.pid;
```

#### pg_stat_activity structure

```sql
dbname=> \d+ pg_stat_activity
                                  View "pg_catalog.pg_stat_activity"
      Column      |           Type           | Collation | Nullable | Default | Storage  | Description
------------------+--------------------------+-----------+----------+---------+----------+-------------
 datid            | oid                      |           |          |         | plain    |
 datname          | name                     |           |          |         | plain    |
 pid              | integer                  |           |          |         | plain    |
 leader_pid       | integer                  |           |          |         | plain    |
 usesysid         | oid                      |           |          |         | plain    |
 usename          | name                     |           |          |         | plain    |
 application_name | text                     |           |          |         | extended |
 client_addr      | inet                     |           |          |         | main     |
 client_hostname  | text                     |           |          |         | extended |
 client_port      | integer                  |           |          |         | plain    |
 backend_start    | timestamp with time zone |           |          |         | plain    |
 xact_start       | timestamp with time zone |           |          |         | plain    |
 query_start      | timestamp with time zone |           |          |         | plain    |
 state_change     | timestamp with time zone |           |          |         | plain    |
 wait_event_type  | text                     |           |          |         | extended |
 wait_event       | text                     |           |          |         | extended |
 state            | text                     |           |          |         | extended |
 backend_xid      | xid                      |           |          |         | plain    |
 backend_xmin     | xid                      |           |          |         | plain    |
 query_id         | bigint                   |           |          |         | plain    |
 query            | text                     |           |          |         | extended |
 backend_type     | text                     |           |          |         | extended |
View definition:
 SELECT s.datid,
    d.datname,
    s.pid,
    s.leader_pid,
    s.usesysid,
    u.rolname AS usename,
    s.application_name,
    s.client_addr,
    s.client_hostname,
    s.client_port,
    s.backend_start,
    s.xact_start,
    s.query_start,
    s.state_change,
    s.wait_event_type,
    s.wait_event,
    s.state,
    s.backend_xid,
    s.backend_xmin,
    s.query_id,
    s.query,
    s.backend_type
   FROM pg_stat_get_activity(NULL::integer) s(datid, pid, usesysid, application_name, state, query, wait_event_type, wait_event, xact_start, query_start, backend_start, state_change, client_addr, client_hostname, client_port, backend_xid, backend_xmin, backend_type, ssl, sslversion, sslcipher, sslbits, ssl_client_dn, ssl_client_serial, ssl_issuer_dn, gss_auth, gss_princ, gss_enc, gss_delegation, leader_pid, query_id)
     LEFT JOIN pg_database d ON s.datid = d.oid
     LEFT JOIN pg_authid u ON s.usesysid = u.oid;
```

### 4 个执行语句 timeout 参数

`lock_timeout`：获取一个表，索引，行上的锁超过这个时间，直接报错，不等待，0为禁用。
`statement_timeout`：当SQL语句的执行时间超过这个设置时间，终止执行SQL，0为禁用
`idle_in_transaction_session_timeout`：在一个空闲的事务中，空闲时间超过这个值，将视为超时，0为禁用。
`dealdlock_timeout`：死锁时间超过这个值将直接报错，不会等待，默认设置为1s。

## PostgreSQL 事务与并发控制

[进阶数据库系列（十四）：PostgreSQL 事务与并发控制-腾讯云开发者社区-腾讯云](https://cloud.tencent.com/developer/article/2315295)
[进阶数据库系列（八）：PostgreSQL 锁机制-腾讯云开发者社区-腾讯云](https://cloud.tencent.com/developer/article/2315270)

PostgreSQL 只实现了 3 种 隔离级别。在 PostgreSQL 中, Read Uncommitted 和 Read Committed 是一样的。

RC 是postgresql里的默认级别。

查看 PostgreSQL 全局事务隔离级别:

```sql
SELECT name, setting
FROM pg_settings
WHERE name = 'default_transaction_isolation';

-- 或者
SELECT  current_setting('transaction_isolation');
```

修改全局的事务隔离级别:

```sql
ALTER SYSTEM
SET default_transaction_isolation TO  'REPEATABLE READ';

-- 修改之后 reload 实例使之生效
SELECT pg_reload_conf();
```

* 开始事务：`BEGIN` or `BEGIN TRANSACTION`
* 提交事务：`COMMIT;` or `END TRANSACTION;`
* 回滚更改：`ROLLBACK`
* 设置savepoint：`savepoint bpoint;`
* 回滚更改到 save point：`rollback to savepoint bpoint;`
* 查看自动提交状态 `\echo :AUTOCOMMIT`
* 打开/关闭自动提交 `set AUTOCOMMIT on`, `set AUTOCOMMIT off`

### 基于多版本的并发控制(MVCC)

在 MVCC 中, 每一个写操作会创建一个新的版本. 当事务发起一个读操作时, 并发控制器选择一个版本读, 连同版本号一起读出, 在更新时对此版本号加一。

PostgreSQL 为每个事务分配一个递增的, int32 整型 数作为 唯一的事务ID, 即 xid. 。

PostgreSQL 内部数据结构中, 每个元组(行记录) 有 4 个与事务可见性相关的 隐藏列:

xmin, 创建该行数据的 xid;
xmax, 删除改行的xid;
cmin, 插入该元组的命令在事务中的命令序列号;
cmax, 删除该元组的命令在事务中的命令序列号.

### 死锁

[数据库内核月报 － PostgreSQL · 内核特性 · 死锁检测与解决](http://mysql.taobao.org/monthly/2021/07/03/)
[PostgreSQL 源码解读（224）- Locks(The Deadlock Detection Algorithm)_ITPUB博客](https://blog.itpub.net/6906/viewspace-2656469/).

#### 死锁检测机制

等待图（circular dependency in locks）分析，PostgreSQL构建一个等待图，表示各个事务之间的锁等待关系。 通过分析，识别出循环依赖（即死锁）。

选择被中止的事务

* 事务年龄：通常选择最新的事务中止，因为回滚的代价较小。Transaction Age: Newer transactions are more likely to be aborted.
* 锁的数量：可能会考虑事务持有的锁数量，选择影响最小的事务中止。Lock Priority: PostgreSQL tries to minimize the impact by selecting the transaction with the fewest updates or the smallest number of locks held

自动中止 检测到死锁后，数据库会自动中止选定的事务并报告错误。

#### 死锁检测的触发时机

由于 PostgreSQL 不对死锁的预防和避免做任何工作，事务如何察觉到自己可能陷入死锁？PostgreSQL 对发生死锁的预期比较乐观。执行事务的进程在获取锁时，发现锁因为正被其他事务持有，且请求锁的模式 (lock mode) 与持有锁的事务存在冲突而需要等待后：

设置一个死锁定时器，然后立刻进入睡眠，不检测死锁
如果定时器超时前，进程已经成功获得锁，那么定时器被提前取消，没有发生死锁
如果定时器超时，则进程被唤醒并执行死锁检测算法
只有定时器超时后，才执行死锁检测算法。这种设计避免对超时时间以内的每一个睡眠等待进程都执行一次死锁检测，这也是 乐观等待 策略的体现。定时器的超时时间通过 GUC 参数 deadlock_timeout 设置。

死锁检测的触发实现在 ProcSleep() 函数中。这是进程被阻塞而进入睡眠时的函数：

## 安装和配置管理

[PostgreSQL 数据库日志与日常巡检](https://cloud.tencent.com/developer/article/2315309)

```sql
-- 异常处理：杀连接；
select pg_terminate_backend(pid);
-- 查看最新加载配置的时间
select pg_conf_load_time();
```

### 参数级别

[PostgreSQL Parameters: Scope and Priority Users Should Know](https://www.percona.com/blog/postgresql-parameters-scope-and-priority-users-should-know/)

[How Can I Take a Backup of Configuration Files in PostgreSQL?](https://www.percona.com/blog/how-can-i-take-a-backup-of-configuration-files-in-postgresql/)

1. Compile time parameter settings

These compile time settings have the least priority and can be overridden in any other levels. However, some of these parameters cannot be modified by any other means.

```sql
select name,boot_val from pg_settings;
```

 If a PostgreSQL user wants to change these values, they need to recompile the PostgreSQL from the source code. Some are exposed through the configure command line option. Some such configuration options are:  `--with-blocksize=<BLOCKSIZE>`    This sets table block size in kB. The default is 8kb.  `--with-segsize=<SEGSIZE>`  This sets table segment size in GB. The default is 1GB. This means PostgreSQL creates a new file in the data directory as the table size exceeds 1GB.   `--with-wal-blocksize=<BLOCKSIZE>`   sets WAL block size in kB, and the default is 8kB.

2. Data directory/initialization-specific parameter settings

Parameters can also be specified at the data directory initialization time.  Some of these parameters cannot be changed by other means or are difficult to change.

```sql
select name,setting from pg_settings where source='override';
```

For example, the wal_segment_size, which determines the WAL segment file, is such a parameter. PostgreSQL generates WAL segment files of 16MB by default, and it can be specified at the time of initialization only.

3. PostgreSQL parameters set by environment variables

PostgreSQL executables, including the postmaster, are honoring many environment variables. But they are generally used by client tools. The most common parameter used by the PostgreSQL server (postmaster) will be PGDATA, which sets the parameter data_directory.  These parameters can be specified by the service managers like systemd.

```sh
$ export PGDATA=/home/postgres/data
$ export PGPORT=5434
$ pg_ctl start
waiting for server to start....2023-08-04 06:53:09.637 UTC [5787] LOG:  starting PostgreSQL 15.3 on x86_64-pc-linux-gnu, compiled by gcc (GCC) 4.8.5 20150623 (Red Hat 4.8.5-44), 64-bit
2023-08-04 06:53:09.637 UTC [5787] LOG:  listening on IPv6 address "::1", port 5434
2023-08-04 06:53:09.637 UTC [5787] LOG:  listening on IPv4 address "127.0.0.1", port 5434
2023-08-04 06:53:09.639 UTC [5787] LOG:  listening on Unix socket "/tmp/.s.PGSQL.5434"
```

4. Configuration files

This is probably the method every novice user will be aware of. The fundamental PostgreSQL configuration file is postgresql.conf, and it is the most common place to have global settings. PostgreSQL looks for a configuration file in the PGDATA by default, but an alternate location can be specified using the command line parameter config_file  of postmaster.  The parameter specifications can be split into multiple files and directories because Postgresql supports include and  include_dir directives in the configuration files. So, there can be nested/cascaded configurations.

PostgreSQL rereads all its configuration files if it receives a SIGHUP signal. If the same parameter is set in multiple locations, the last to read will be will be considered. Among all configuration files, postgresql.auto.conf gets the highest priority because that is the file to read the last. That is where all "ALTER SYSTEM SET/RESET" commands keep the information.

5. Command line argument to postmaster

```sql
select name,setting from pg_settings where source='command line';
```

6. Database level setting

```sql
ALTER DATABASE newdb SET max_parallel_workers_per_gather = 4;
```

7. User-level settings

```sql
select name,setting,source,context from pg_settings where  source='user';
```

8. Database – user combination

PostgreSQL allows us to have parameter settings that will be applicable when a particular user/role connects to a particular database.

For example:

```sql
ALTER USER admin IN DATABASE db1 SET max_parallel_workers_per_gather=6;
```

Setting at this level has even higher priority than everything mentioned before.

```sql
select name,setting,source,context from pg_settings where  name='max_parallel_workers_per_gather';
           name           | setting | source | context
---------------------------------+---------+---------------+---------
 max_parallel_workers_per_gather | 6   | database user | user
(1 row)
```

9. Parameters by the client connection request

There is an option to specify parameters while making a new connection. It can be passed to PostgreSQL as part of the connection string.

For example, I want to connect to the database to perform some bulk data loading and manipulation (ETL), and I don't want to wait for any WAL writing. If, at all, there is any crash in between, I am OK to perform the ETL again. So, I am going to request a connection with synchronous_commit  off.

```sql
$ psql "host=localhost user=postgres options='-c synchronous_commit=off'"
psql (14.8)
Type "help" for help.

postgres=# select name,setting,source,context from pg_settings where  name='synchronous_commit';
     name        | setting   | source | context
--------------------+-----------+--------+---------
 synchronous_commit | off | client | user
(1 row)
```

10.  Session-level setting

Each session can decide on the settings for that session at that point in time or execution. The sessions are allowed to modify this session-level setting as and when required.

```sql
postgres=# set jit=off;
SET
postgres=# select name,setting,source,context from pg_settings where  name='jit';
 name | setting | source  | context
------+---------+---------+---------
 jit  | off | session | user
(1 row)
```

A good use case is that, suppose we are going to rebuild a big index. We know that it is going to use considerable maintenance_work_mem.  Setting this at the session level simplifies our life without affecting other sessions.

```sql
set maintenance_work_mem = '4GB';
```

11. Transaction-level settings

PostgreSQL allows us to specify parameters at a very small scope, like transaction level.

```sql
postgres=# BEGIN;
BEGIN
postgres=*# SET LOCAL enable_seqscan=off;
SET
```

12. Object-level settings

PostgreSQL allows us to specify the parameter specific to a program block, like a PL/pgSQL function. So, the setting goes as part of the function definition.

Here is an example of the function definition to test the function-level settings.

```sql
CREATE OR REPLACE FUNCTION checkParams()
 RETURNS BOOLEAN
as $$
DECLARE
  nm TEXT;
  setng TEXT;
  cntxt TEXT;
  src TEXT;
BEGIN
SELECT name,setting,context,source INTO nm,setng,cntxt,src from pg_settings where  name='enable_partitionwise_join';
RAISE NOTICE 'Parameter Name: % value:%  Context:%  Source:%',nm,setng,cntxt,src;
RETURN true;
END;
$$ LANGUAGE plpgsql
SET enable_partitionwise_join = 'on'
SET enable_seqscan = 'off';
```

### 数据库备份与恢复

[PostgreSQL 数据库备份与恢复](https://cloud.tencent.com/developer/article/2315304)
[PostgreSQL: Documentation: 16: 26.1. SQL Dump](https://www.postgresql.org/docs/16/backup-dump.html)

[The Current State of Open Source Backup Management for PostgreSQL | Severalnines](https://severalnines.com/blog/current-state-open-source-backup-management-postgresql/)
[A Complete Guide to PostgreSQL Backup & Recovery](https://www.enterprisedb.com/postgresql-database-backup-recovery-what-works-wal-pitr)
[PostgreSQL备份与恢复 pg_dump pgBackRest](https://vip.kingdee.com/article/355319090380443904?productLineId=29&isKnowledge=2&lang=zh-CN)
[Barman](https://pgbarman.org/)
[pgBackRest - Reliable PostgreSQL Backup & Restore](https://pgbackrest.org/)

[如何使用 PostgreSQL 14 的持续归档备份和基于时间点恢复 | Shall We Code?](https://waynerv.com/posts/postgresql-14-continuous-archiving-and-pitr/)

#### pg_dump 导出数据

[PostgreSQL: Documentation: 16: pg_dump](https://www.postgresql.org/docs/16/app-pgdump.html)

```sh
pg_dump -h localhost -p 5432 -U postgres --clean --if-exists --create --column-inserts -d database_name -t table_name -f save_sql.sql
-- 备份postgres库并tar打包
pg_dump -h 127.0.0.1 -p 5432 -U postgres -d database_name -Ft -f postgres.sql.tar

# pg_dumpall backs up each database in a given cluster, and also preserves cluster-wide data such as role and tablespace definitions
pg_dumpall > dumpfile
pg_dumpall -h localhost -p 5432 -U postgres -f /tmp/pg_dumpall.sql

# 并行备份
pg_dump -U username -F t -j 4 -f backup.tar database_name
# 压缩备份
pg_dump -U username database_name | gzip > /tmp/backup.gz
```

1. `--column-inserts` 以带有列名的 `INSERT` 命令形式转储数据。This will **make restoration very slow**; it is mainly useful for making dumps that can be loaded into non-PostgreSQL databases
2. `-t` --只转储指定名称的表
3. `-f` --指定输出文件或目录名
4. `-F` format, --format=format Selects the format of the output. format can be one of the following:
    1. `p`, plain: Output a plain-text SQL script file (the default).
    2. `c`, custom Output a custom-format archive suitable for input into `pg_restore`.
    3. `t`, tar Output a tar-format archive suitable for input into `pg_restore`.
5. `-c, --clean` Output commands to DROP all the dumped database objects prior to outputting the commands for creating them.
6. `--if-exists` Use `DROP ... IF EXISTS` commands to drop objects in `--clean` mode
7. `-C, --create` create the database itself and reconnect to the created database
8. `-t pattern, --table=pattern` Dump only tables with names matching pattern. 可以使用多个-t选项匹配多个表。
9. `-T pattern, --exclude-table=pattern` Do not dump any tables matching pattern.
10. `-O, --no-owner` Do not output commands to set ownership of objects to match the original database.
11. `--data-only`: Backs up only the data, excluding the database schema.
12. `-s, --schema-only` Dump only the object definitions (schema), not data.

psql 通过执行 SQL 文件恢复 `psql -d dbname -f sqlfile`
[PostgreSQL 16: psql](https://www.postgresql.org/docs/16/app-psql.html)

1. `--set ON_ERROR_STOP=on` exit with an exit status of 3 if an SQL error occurs
2. `-1` or `--single-transaction` restored as a single transaction

```sh
# 执行 SQL 恢复
psql -h localhost -p 5432 -U postgres --set ON_ERROR_STOP=on --single-transaction -f globals.backup.sql
psql -h localhost -p 5432 -U postgres --set ON_ERROR_STOP=on --single-transaction -d dbname -f dumpfile

# 从压缩的备份文件中恢复
gunzip -c backup.gz | psql -U username target_database
```

导出参数实验

```sh
# 没有 --inserts 和 --column-inserts
COPY public.test_table (id, value) FROM stdin;
1       Record 1
2       Record 2
\.

#  --inserts
INSERT INTO public.test_table VALUES (1, 'Record 1');
INSERT INTO public.test_table VALUES (2, 'Record 2');

#  --column-inserts
INSERT INTO public.test_table (id, value) VALUES (1, 'Record 1');
INSERT INTO public.test_table (id, value) VALUES (2, 'Record 2');

# --clean 有 DROP 但是没有 IF EXISTS
ALTER TABLE ONLY public.test_table DROP CONSTRAINT test_table_pkey;
ALTER TABLE public.test_table ALTER COLUMN id DROP DEFAULT;
DROP SEQUENCE public.test_table_id_seq;
DROP TABLE public.test_table;
DROP EXTENSION pg_stat_statements;

#  --clean --if-exists: DROP TABLE IF EXISTS
# TABLE, SEQUENCE, EXTENSION
ALTER TABLE IF EXISTS ONLY public.test_table DROP CONSTRAINT IF EXISTS test_table_pkey;
ALTER TABLE IF EXISTS public.test_table ALTER COLUMN id DROP DEFAULT;
DROP SEQUENCE IF EXISTS public.test_table_id_seq;
DROP TABLE IF EXISTS public.test_table;
DROP EXTENSION IF EXISTS pg_stat_statements;

#  --clean --if-exists --create: DROP DATABASE IF EXISTS
# 数据库
DROP DATABASE IF EXISTS test_replication;
--
-- Name: test_replication; Type: DATABASE; Schema: -; Owner: postgres
--
CREATE DATABASE test_replication WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.UTF-8';
ALTER DATABASE test_replication OWNER TO postgres;
```

#### pg_restore

[PostgreSQL: Documentation: 16: pg_restore](https://www.postgresql.org/docs/16/app-pgrestore.html)

```sh
# 列出备份文件内容而不恢复，输出到 /tmp/list1
pg_restore -v -l -f /tmp/list1 /tmp/test_replication.dump
# 恢复 日志输出到 /tmp/restore.log
pg_restore -h localhost -p 5432 -U postgres -d dbname --clean --if-exists -v pg.dump > /tmp/restore.log 2>&1

# 管道恢复
pg_dump -h localhost -p 5432 -U postgres -Fc -d test_replication | pg_restore -h localhost -p 5432 -U postgres --clean --if-exists -v -d test_replication_restore

# 使用并行作业恢复
pg_restore -U username -j 4 -d target_database backup_file
```

* `-c, --clean` Before restoring database objects, issue commands to DROP all the objects that will be restored. This option is useful for overwriting an existing database. If any of the objects do not exist in the destination database, ignorable error messages will be reported, unless --if-exists is also specified
* `--if-exists` Use DROP ... IF EXISTS commands to drop objects in --clean mode.
* `-C, --create` Create the database before restoring into it. If --clean is also specified, drop and recreate the target database before connecting to it.
* `-d dbname, --dbname=dbname` Connect to database dbname and restore directly into the database.
* `-e, --exit-on-error` Exit if an error is encountered while sending SQL commands to the database.
* `-f, filename, --file=filename` Specify output file for generated script, or for the listing when used with -l. Use - for stdout.
* `-l, --list` List the table of contents of the archive. The output of this operation can be used as input to the -L option.
* `-s, --schema-only` Restore only the schema (data definitions), not data, to the extent that schema entries are present in the archive. This option is the inverse of --data-only.
* `-t table, --table=table`, Restore definition and/or data of only the named table.
* `-1, --single-transaction` Execute the restore as a single transaction. This option implies --exit-on-error.
* `-O, --no-owner` Do not output commands to set ownership of objects to match the original database. With -O, any user name can be used for the initial connection, and this user will own all the created objects.

#### 逻辑备份与恢复

```sh
su - postgres
# 先备份全局对象
pg_dumpall -h localhost -p 5432 -U postgres --globals-only -f globals.backup.sql
# 再备份数据库
# -F c is custom format (compressed, and able to do in parallel with -j N) -b is including blobs, -v is verbose, -f is the backup file name.
pg_dump -h localhost -p 5432 -U postgres -Fc --clean --if-exists --create --large-objects -v -d old_db -f /path/to/old_db.dump
# 纯 SQL 格式导出 恢复慢
pg_dump -h localhost -p 5432 -U postgres --column-inserts -f save_sql.sql -d old_db -t table_name
pg_dump -d old_db -t table_name | gzip > /tmp/backup.gz

# 逻辑恢复 先恢复全局对象
psql -c globals.backup.sql
# pg_restore 恢复数据库
pg_restore -h localhost -p 5432 -U postgres -d old_db -v /path/to/old_db.dump

# To reload an archive file into the same database it was dumped from, discarding the current contents of that database
pg_restore -d newDb --clean --create old_db.dump
```

#### 物理备份与恢复

[如何使用 PostgreSQL 14 的持续归档备份和基于时间点恢复 | Shall We Code?](https://waynerv.com/posts/postgresql-14-continuous-archiving-and-pitr/)

物理备份

```sh
# 开启归档日志
vi $PGDATA/postgresql.conf
wal_level = replica  # 或者更高级别
archive_mode = on
# backup_in_progress文件用来辅助wal日志备份，通过删除配合test指令控制wal日志备份
archive_command = 'test ! -f /usr/local/pgsql/backup_in_progress || (test ! -f /usr/local/pgsql/data/pg_archive/%f && cp %p /usr/local/pgsql/data/pg_archive/%f)'

# 重启数据库
pg_ctl restart -mf

touch /usr/local/pgsql/backup_in_progress
# 开始基础备份,可以在代码里连接数据库执行
psql -c "select pg_start_backup('hot_backup');"
# 将数据库文件进行备份
BACKUPDATE=`date '+%Y%m%d%H%m%S'`
tar -cf /data/pg_backup/pgbackup_${BACKUPDATE}.tar $PGDATA
# 结束备份,可以在代码里连接数据库执行
psql -c "select pg_stop_backup();"
# 停止wal日志备份
rm /usr/local/pgsql/backup_in_progress
# 将wal日志和基础备份打包在一起
tar -rf /data/pg_backup/pgbackup_${BACKUPDATE}.tar /usr/local/pgsql/data/pg_archive
```

物理恢复

```sh
pg_ctl stop -mf
mv $PGDATA ${PGDATA}.old
tar -xf /data/pg_backup/pgbackup_${BACKUPDATE}.tar -C $PGDATA
vi $PGDATA/recovery.conf
restore_command = 'cp /usr/local/pgsql/data/pg_archive/%f %p'
# 指定要恢复的时间点，也可以不指定，直接恢复所有数据
recovery_target_time = '2022-09-01 10:00:00'
pg_ctl start
```

#### 复制数据库

[Creating a copy of a database in PostgreSQL - Stack Overflow](https://stackoverflow.com/questions/876522/creating-a-copy-of-a-database-in-postgresql)

```sql
/* KILL ALL EXISTING CONNECTION FROM ORIGINAL DB (sourcedb) to avoid the error ERROR:  source database "SOURCE_DB" is being accessed by other users*/
SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity
 WHERE pg_stat_activity.datname = 'SOURCE_DB' AND pid <> pg_backend_pid();

/* CLONE DATABASE TO NEW ONE(TARGET_DB) */
CREATE DATABASE TARGET_DB WITH TEMPLATE SOURCE_DB OWNER USER_DB;
```

或者

```sql
-- One issue I've found with this method is that pg_dump will hold open its transaction until the restore into the new database is complete, even if pg_dump has actually finished its dump. This can cause locking issues in some cases (for example, if a DDL statement is run on the source DB).
pg_dump SOURCE_DB | psql TARGET_DB
```

### RPM 安装

[PostgreSQL: Linux downloads (Red Hat family)](https://www.postgresql.org/download/linux/redhat/)

For RHEL / Rocky Linux / AlmaLinux / CentOS / SL / OL 7, 8, 9 or Fedora 39 and later derived distributions:
  postgresql-setup --initdb
  systemctl enable postgresql.service
  systemctl start postgresql.service

### 源码安装

[CentOS 7 安装PostgreSQL 16 | 淡月清云的数据世界](https://data.imgwho.com/posts/centos-7-install-postgresql-16)
[Centos7停止维护后如何安装Postgres16_centos7 postgres16源码安装-CSDN博客](https://blog.csdn.net/Bingo_155/article/details/141161312)

`postgresql-server` The programs needed to create and run a PostgreSQL server
`postgresql` PostgreSQL client programs

https://mirrors.aliyun.com/postgresql/repos/yum/testing/debug/16/redhat/rhel-9-x86_64/
https://download.postgresql.org/pub/repos/yum/16/redhat/

```sh
# [PostgreSQL: Documentation: 16: 17.3. Building and Installation with Autoconf and Make](https://www.postgresql.org/docs/16/install-make.html)
sudo yum install -y perl-ExtUtils-Embed readline-devel zlib-devel pam-devel libxml2-devel libxslt-devel openldap-devel python-devel gcc-c++ openssl-devel cmake systemd-devel

tar xf postgresql-16.3.tar.gz
cd postgresql-16.3
./configure --prefix=/data/software/pgsql-16.3 --with-systemd --without-icu
# make world: build everything that can be built, including the documentation (HTML and man pages), and the additional modules (contrib)
make world && make install

export PGDATA=/data/pgdata
mkdir -p $PGDATA

# 创建组
sudo groupadd postgres
# 创建用户
sudo useradd -g postgres postgres
# 修改目录属主、属组
# 注意：不修改执行文件目录，只修改数据目标，
sudo chown -R postgres:postgres $PGDATA
sudo su - postgres

tee -a ~/.bashrc <<EOF
export PGHOME=/data/software/pgsql-16.3
export PGDATA=/data/pgdata
export PATH=\$PGHOME/bin:$PATH
EOF
source ~/.bashrc

# 切换到postgres用户初始化数据目录
# [PostgreSQL 16: initdb](https://www.postgresql.org/docs/16/app-initdb.html)
$PGHOME/bin/initdb -D $PGDATA
#  -E UTF8 --locale=en_US.utf8 -U postgres --data-checksums
# [PostgreSQL: pg_ctl](https://www.postgresql.org/docs/current/app-pg-ctl.html)
$PGHOME/bin/pg_ctl start -D $PGDATA --log=$PGDATA/startup.log
$PGHOME/bin/createdb test
$PGHOME/bin/psql test

pg_ctl start
pg_ctl status
pg_ctl stop

# [PostgreSQL 16: 17.5. Post-Installation Setup](https://www.postgresql.org/docs/16/install-post.html)
# To enable your system to find the man documentation, you need to add lines like the following to a shell start-up file unless you installed into a location that is searched by default:
MANPATH=$PGHOME/share/man:$MANPATH
export MANPATH
```

修改密码

```sql
ALTER USER postgres WITH PASSWORD 'YourPassWord';
```

配置PostgreSQL 服务，可以开机自启

```sh
sudo tee /etc/systemd/system/postgresql.service <<EOF

[Unit]
Description=PostgreSQL 16.3 database server
Documentation=man:postgres(1)
After=network-online.target
Wants=network-online.target

[Service]

Type=forking
User=postgres
Group=postgres
OOMScoreAdjust=-1000

Environment="PGHOME=/data/software/pgsql-16.3"
Environment=PGDATA=/data/pgdata

ExecStart=/data/software/pgsql-16.3/bin/pg_ctl start -D $PGDATA --log=$PGDATA/startup.log
ExecStop=/data/software/pgsql-16.3/bin/pg_ctl stop -D $PGDATA
ExecReload=/data/software/pgsql-16.3/bin/pg_ctl reload -D $PGDATA
TimeoutSec=0

[Install]
WantedBy=multi-user.target

EOF

sudo tee -a /etc/sudoers.d/postgres <<EOF
postgres ALL=(ALL) NOPASSWD: /bin/systemctl start postgresql.service
postgres ALL=(ALL) NOPASSWD: /bin/systemctl stop postgresql.service
postgres ALL=(ALL) NOPASSWD: /bin/systemctl restart postgresql.service
postgres ALL=(ALL) NOPASSWD: /bin/systemctl reload postgresql.service
EOF

sudo systemctl daemon-reload
sudo systemctl enable postgresql
sudo systemctl restart postgresql
sudo systemctl status postgresql

```

#### 安装 pg_stat_statements 模块开启慢查询统计

[PostgreSQL 16: F.32. pg_stat_statements — track statistics of SQL planning and execution](https://www.postgresql.org/docs/16/pgstatstatements.html#PGSTATSTATEMENTS-CONFIG-PARAMS)
[PostgreSQL安装pg_stat_statements模块开启慢查询统计 | BoobooWei](https://www.toberoot.com/news/2020/04/23/tec-pg-md/index.html)

```sh
# 需要安装相同版本的contrib包
yum install -y postgresql-contrib.x86_64

# 修改配置文件
vim /var/lib/pgsql/data/postgresql.conf
# 当需要跟踪SQL语句或者慢语句，得需要设置以下参数：
log_statement = all     #需设置跟踪所有语句，否则只能跟踪出错信息
log_min_duration_statement = 5000    #milliseconds,记录执行5秒及以上的语句

shared_preload_libraries = 'pg_stat_statements'         # (change requires restart)
#以下配置pg_stat_statements采样参数
pg_stat_statements.max = 10000
## 在pg_stat_statements中最多保留多少条统计信息，通过LRU算法，覆盖老的记录。
pg_stat_statements.track = all
## all - (所有SQL包括函数内嵌套的SQL), top - 直接执行的SQL(函数内的sql不被跟踪), none - (不跟踪)
pg_stat_statements.track_utility = off
## 是否跟踪非DML语句 (例如DDL，DCL)，on表示跟踪, off表示不跟踪
pg_stat_statements.save = on


# 重启服务
su - postgres
pg_ctl -D $PGDATA reload


# 创建 extension
# 由于pg_stat_statements针对的是数据库级别，所以需要首先进入指定数据库
psql
\l
\c test01
create extension pg_stat_statements;

psql -c -d dbName "create extension pg_stat_statements;"

\df
```

```sql
-- 查询慢SQL
SELECT query, calls, total_exec_time, rows, 100.0 * shared_blks_hit /
               nullif(shared_blks_hit + shared_blks_read, 0) AS hit_percent
          FROM pg_stat_statements ORDER BY calls,total_exec_time DESC LIMIT 5;

SELECT query, calls, total_exec_time, rows, 100.0 * shared_blks_hit / nullif(shared_blks_hit + shared_blks_read, 0) AS hit_percent FROM pg_stat_statements ORDER BY calls,total_exec_time DESC LIMIT 5;

-- 重置统计信息
-- 统计结果一直都在，重启也不会清零，那么统计结果如何清零重新统计呢？
-- 执行下面SQL即可：
select pg_stat_statements_reset() ;
SELECT pg_stat_statements_reset(0,0,s.queryid) FROM pg_stat_statements AS s
            WHERE s.query = 'UPDATE pgbench_branches SET bbalance = bbalance + $1 WHERE bid = $2';
```

#### 修改配置文件

```sh
# 修改监听地址，否则无法远程连接
listen_addresses = '*'
port = 5432
# 修改最大连接数
max_connections = 20000
# 设置socket目录
# unix_socket_directories = '/tmp'
# 开启日志获取
logging_collector = on
# 设置日志目录
log_directory = 'pg_log'
# 设置日志文件名称格式
log_filename = 'postgresql-%Y-%m-%d.log'
# 开启日志轮转
log_truncate_on_rotation = on

# 可以设置为物理内存大小的四分之一
shared_buffers = 2GB
# 默认 4MB
work_mem = 4MB

# full_page_writes 为了避免部分写（8k被内核拆分为4k，被磁盘拆分为512字节） https://www.2ndquadrant.com/en/blog/on-the-impact-of-full-page-writes/，所以只要恢复一部分数据块即可，还不用先读取data file。这样的话checkpoint的频率以及shared buffer的大小（增量检查点很重要）就非常重要了。
full_page_writes = on  # recover from partial page writes，Default on
# wal_log_hints会导致checkpoint后，页如果发生了即使不重要的数据改动,也遵循全页写机制。如果wal_checksum启用了，这个参数会自动强制启用。
#wal_log_hints = off       # also do full page writes of non-critical updates (change requires restart)
#wal_compression = off     # enables compression of full-page writes; off, pglz, lz4, zstd, or on
```

内核参数优化

[PostgreSQL 19.4. Managing Kernel Resources](https://www.postgresql.org/docs/16/kernel-resources.html)

```sh
# 参考，内核参数优化
cat >> /etc/sysctl.conf << EOF
#for postgres db 13.7
kernel.shmall = 966327       # expr `free |grep Mem|awk '{print $2 *1024}'` / `getconf PAGE_SIZE`
kernel.shmmax = 3958075392   # free |grep Mem|awk '{print $2 *1024}'
kernel.shmmni = 4096
kernel.sem = 50100 64128000 50100 1280

fs.file-max = 76724200
net.ipv4.ip_local_port_range = 9000 65000
net.core.rmem_default = 1048576
net.core.rmem_max = 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 1048576
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_max_syn_backlog = 4096
net.core.netdev_max_backlog = 10000
fs.aio-max-nr = 40960000
net.ipv4.tcp_timestamps = 0

vm.overcommit_memory = 2
vm.overcommit_ratio = 85
# vm.swappiness=0 设置为 0 不使用交换分区
vm.swappiness=0
# vm.dirty_ratio is the percentage of system memory which when dirty, causes the process doing writes to block and write out dirty pages to the disk.
# 前台刷脏页的百分比，默认值是“20%”，也太大，建议设置成“1%”。
vm.dirty_ratio=2
# vm.dirty_background_ratio is the percentage of system memory which when dirty, causes the system to start writing data to the disk.
# 默认值是“10%”，当文件系统的缓存中保存的脏页数超过总内存的这个百分比时，开始后台刷脏数据。当内存中有大量的脏数据时，会产生很大的性能抖动。为了保证系统的稳定性，建议把该值设置成一个较小的值。
vm.dirty_background_ratio=1
vm.dirty_writeback_centisecs=100
vm.dirty_expire_centisecs=500
vm.min_free_kbytes=524288
EOF

# 参考，修改资源限制
cat >> /etc/security/limits.conf << EOF
* soft    nofile  1048576
* hard    nofile  1048576
* soft    stack   unlimited
* hard    stack   unlimited
* soft    nproc   unlimited
* hard    nproc   unlimited
* soft    core    unlimited
* hard    core    unlimited
* soft    memlock unlimited
* hard    memlock unlimited
EOF

```

log

```sh
[postgres@k8s-master ~]$ $PGHOME/bin/initdb -D $PGDATA
The files belonging to this database system will be owned by user "postgres".
This user must also own the server process.

The database cluster will be initialized with locale "en_US.UTF-8".
The default database encoding has accordingly been set to "UTF8".
The default text search configuration will be set to "english".

Data page checksums are disabled.

fixing permissions on existing directory /data/software/pgsql-16.3/PGDATA ... ok
creating subdirectories ... ok
selecting dynamic shared memory implementation ... posix
selecting default max_connections ... 100
selecting default shared_buffers ... 128MB
selecting default time zone ... Asia/Shanghai
creating configuration files ... ok
running bootstrap script ... ok
performing post-bootstrap initialization ... ok
syncing data to disk ... ok

initdb: warning: enabling "trust" authentication for local connections
initdb: hint: You can change this by editing pg_hba.conf or using the option -A, or --auth-local and --auth-host, the next time you run initdb.

Success. You can now start the database server using:

    /data/software/pgsql-16.3/bin/pg_ctl -D /data/software/pgsql-16.3/PGDATA -l logfile start
```

### 生产环境 PostgreSQL 参数配置

[Exploring PostgreSQL Performance Tuning Parameters](https://www.percona.com/blog/tuning-postgresql-database-parameters-to-optimize-performance/)
[PostgreSQL 性能优化](https://cloud.tencent.com/developer/article/2315307)

注意：并非所有参数都适用于所有应用程序类型。某些应用程序通过调整参数可以提高性能，有些则不会。必须针对应用程序及操作系统的特定需求来调整数据库参数。

`show all;` 列出所有参数

$PGDATA/postgresql.conf
$PGDATA/pg_hba.conf

#### shared_buffers

PostgreSQL既使用自身的缓冲区，也使用内核缓冲IO。这意味着数据会在内存中存储两次，首先是存入PostgreSQL缓冲区，然后是内核缓冲区。这被称为双重缓冲区处理。对大多数操作系统来说，这个参数是最有效的用于调优的参数。此参数的作用是设置PostgreSQL中用于缓存的专用内存量。

`show shared_buffers;` 默认值128M

建议的设置值为机器总内存大小的25％，但是也可以根据实际情况尝试设置更低和更高的值。实际值取决于机器的具体配置和工作的数据量大小。举个例子，如果工作数据集可以很容易地放入内存中，那么可以增加shared_buffers的值来包含整个数据库，以便整个工作数据集可以保留在缓存中。

#### wal_buffers

PostgreSQL将其WAL（预写日志）记录写入缓冲区，然后将这些缓冲区刷新到磁盘。由wal_buffers定义的缓冲区的默认大小为16MB，但如果有大量并发连接的话，则设置为一个较高的值可以提供更好的性能。默认 4MB

`show wal_buffers;`

#### effective_cache_size

effective_cache_size提供可用于磁盘高速缓存的内存量的估计值。它只是一个建议值，而不是确切分配的内存或缓存大小。它不会实际分配内存，而是会告知优化器内核中可用的缓存量。在一个索引的代价估计中，更高的数值会使得索引扫描更可能被使用，更低的数值会使得顺序扫描更可能被使用。在设置这个参数时，还应该考虑PostgreSQL的共享缓冲区以及将被用于PostgreSQL数据文件的内核磁盘缓冲区。默认值是4GB。

`show effective_cache_size;`

#### work_mem

此配置用于复合排序。内存中的排序比溢出到磁盘的排序快得多，设置非常高的值可能会导致部署环境出现内存瓶颈，因为此参数是按用户排序操作。如果有多个用户尝试执行排序操作，则系统将为所有用户分配大小为`work_mem *`总排序操作数的空间。全局设置此参数可能会导致内存使用率过高，因此强烈建议在会话级别修改此参数值。默认值为4MB。

`show work_mem;`

#### maintenance_work_mem

`maintenance_work_mem`是用于维护任务的内存设置。默认值为64MB。设置较大的值对于`VACUUM，RESTORE，CREATE INDEX，ADD FOREIGN KEY`和`ALTER TABLE`等操作的性能提升效果显著。

`show maintenance_work_mem;`

#### synchronous_commit

此参数的作用为在向客户端返回成功状态之前，强制提交等待WAL被写入磁盘。这是性能和可靠性之间的权衡。如果应用程序被设计为性能比可靠性更重要，那么关闭synchronous_commit。这意味着成功状态与保证写入磁盘之间会存在时间差。在服务器崩溃的情况下，即使客户端在提交时收到成功消息，数据也可能丢失。

[synchronous_commit 配置对性能的影响](https://www.cnblogs.com/lightdb/p/15483919.html)

`show synchronous_commit;`

#### checkpoint_timeout 和 checkpoint_completion_target

PostgreSQL将更改写入WAL。检查点进程将数据刷新到数据文件中。发生CHECKPOINT时完成此操作。这是一项开销很大的操作，整个过程涉及大量的磁盘读/写操作。用户可以在需要时随时发出CHECKPOINT指令，或者通过PostgreSQL的参数`checkpoint_timeout`和`checkpoint_completion_target`来自动完成。

checkpoint_timeout参数用于设置WAL检查点之间的时间。将此设置得太低会减少崩溃恢复时间，因为更多数据会写入磁盘，但由于每个检查点都会占用系统资源，因此也会损害性能。此参数只能在postgresql.conf文件中或在服务器命令行上设置。

`checkpoint_completion_target`指定检查点完成的目标，作为检查点之间总时间的一部分。默认值是 0.9。这个参数只能在postgresql.conf文件中或在服务器命令行上设置。高频率的检查点可能会影响性能。

`show checkpoint_timeout;`  `show checkpoint_completion_target;`

#### checkpoint_segments

增加这个参数可以提升大量数据导入时候的速度。

#### max_connections

允许客户端连接的最大数目，默认值 100

#### fsync

强制把数据同步更新到磁盘,如果系统的IO压力很大，把改参数改为off。默认 on

在fsync打开的情况下，优化后性能能够提升30%左右。因为有部分优化选项在默认的SQL测试语句中没有体现出它的优势，如果到实际测试中，提升应该不止30%。**这里的优化内容待明确？**

测试的过程中，主要的瓶颈就在系统的IO，如果需要减少IO的负荷，最直接的方法就是把fsync关闭，但是这样就会在掉电的情况下，可能会丢失部分数据。

#### commit_delay 和 commit_siblings

事务提交后，日志写到wal log上到wal_buffer写入到磁盘的时间间隔。需要配合commit_sibling。能够一次写入多个事务，减少IO，提高性能

设置触发commit_delay的并发事务数，根据并发事务多少来配置。减少IO，提高性能

#### archive_mode

设置 archive_mode 无效,这个参数设置为无效的时候，能够提升以下的操作的速度

* CREATE TABLE AS SELECT
* CREATE INDEX
* ALTER TABLE SET TABLESPACE
* CLUSTER等。

#### autovacuum

[PostgreSQL 16: 25.1. Routine Vacuuming](https://www.postgresql.org/docs/16/routine-vacuuming.html)
[PostgreSQL 16: 20.10. Automatic Vacuuming](https://www.postgresql.org/docs/16/runtime-config-autovacuum.html)

PostgreSQL's VACUUM command has to process each table on a regular basis for several reasons:

* To recover or reuse disk space occupied by updated or deleted rows.
* To update data statistics used by the PostgreSQL query planner.
* To update the visibility map, which speeds up index-only scans.
* To protect against loss of very old data due to transaction ID wraparound or multixact ID wraparound.

#### 一份参数文件1

来源：PostgreSQL修炼之道：从小工到专家（第2版）

```sh
listen_addresses = '*'            # what IP address(es) to listen on;
port = 5432                             # (change requires restart)
max_connections = 3000                   # (change requires restart)
superuser_reserved_connections = 10     # (change requires restart)
# 配置了TCP的keepalive选项，tcp_keepalives_idle、tcp_keepalives_interval、tcp_keepalives_count，让一些已出问题的网络连接能尽快结束。
tcp_keepalives_idle = 5                # TCP_KEEPIDLE, in seconds;
tcp_keepalives_interval = 5           # TCP_KEEPINTVL, in seconds;
tcp_keepalives_count = 3               # TCP_KEEPCNT;
shared_buffers = 32GB
# huge_pages 从默认值“try”改为“on”，这样会强制保证数据使用大页内存，如果操作系统配置的大页有问题，则数据库无法启动，这样可以快速发现问题。
huge_pages = on
# you actively intend to use prepared transactions.
work_mem = 4MB
maintenance_work_mem = 128MB
autovacuum_work_mem = 256MB
wal_writer_delay = 10ms
# 指定WAL日志的空间上限。保证WAL不会占用太多的空间。
max_wal_size = 50GB
# 该值通常不要设置得太小，容易导致Standby失效。
min_wal_size = 40GB
# 保证能及时发生Checkponit。
checkpoint_timeout = 15min
max_locks_per_transaction =256
checkpoint_completion_target = 0.9      # checkpoint target duration, 0.0 - 1.0

effective_cache_size = 256GB
log_destination = 'csvlog'              # Valid values are combinations of
logging_collector = on          # Enable capturing of stderr and csvlog
log_directory = 'pg_log'                # directory where log files are written,
log_truncate_on_rotation = on           # If on, an existing log file with the
log_rotation_age=3d
log_rotation_size=100MB

autovacuum = on                 # Enable autovacuum subprocess?  'on'
log_autovacuum_min_duration = 0
# worker设置得多一些，可以保证AutoVacuum能尽快地完成。
autovacuum_max_workers = 10             # max number of autovacuum subprocesses
autovacuum_naptime = 1min               # time between autovacuum runs
autovacuum_vacuum_threshold = 500       # min number of row updates before vacuum
autovacuum_analyze_threshold = 500      # min number of row updates before analyze
autovacuum_vacuum_scale_factor = 0.2    # fraction of table size before vacuum
autovacuum_analyze_scale_factor = 0.1   # fraction of table size before analyze
# 为防止AutoVacuum对系统产生太大冲击，AutoVacuum每完成一定的工作量，就休眠2ms再重新开始工作。
autovacuum_vacuum_cost_delay = 2ms      # autovacuum_vacuum_cost_delay
# 因为是SSD，所以建议把该值设置得高一些。
autovacuum_vacuum_cost_limit = 5000     # default vacuum_cost_limit
vacuum_cost_limit = 5000  #sas 盘2000,SSD为10000
# 为防止Vacuum对系统产生冲击，Vacuum每完成一定的工作量后，休眠2ms再开始工作。
vacuum_cost_delay = 2ms

wal_compression = on

# 当锁超过600秒时，则放弃锁，防止长时间持有锁。如果你有长时间的DDL或DML语句操作，请根据实际情况把该参数值改大。
lock_timeout=600000
# 允许SQL最多运行1小时，请根据实际情况调整此参数。
statement_timeout=3600000
# 清理长时间（10分钟）的idle的事务连接，请根据实际情况调整此参数。
idle_in_transaction_session_timeout = 600000  # 自动清理 idle session

log_min_error_statement=error
log_min_duration_statement=5s
temp_file_limit=20G  #控制临时表空间size
# 因为是SSD，将该值调小，以便于执行计划尽量走索引，而不走全表扫描。
random_page_cost = 1.1
log_checkpoints =on
log_statement = 'ddl'
track_io_timing = on # 打开后非常耗费性能，如非必要 不要打开
track_functions = all
# 为每个活动会话保留的内存量，以存储当前执行命令的文本。这些文本被用于 pg_stat_activity 视图的 query 字段
# 默认情况下，这个参数的值是 1024 字节（即 1KB），如果查询文本超过 1024 字节，它将被截断。
track_activity_query_size = 2048

# pg_stat_statements 插件可以监控SQL的执行时间等性能统计数据，最好装上。
# [PostgreSQL 16: F.32. pg_stat_statements — track statistics of SQL planning and execution](https://www.postgresql.org/docs/16/pgstatstatements.html)
shared_preload_libraries = 'pg_stat_statements'
# 在pg_stat_statements中最多保留多少条统计信息，通过LRU算法，覆盖老的记录。
pg_stat_statements.max = 10000
# all - (所有SQL包括函数内嵌套的SQL), top - 直接执行的SQL(函数内的sql不被跟踪), none - (不跟踪)
pg_stat_statements.track = all
pg_stat_statements.track_utility = off # 是否跟踪非DML语句 (例如DDL，DCL)，on表示跟踪, off表示不跟踪
pg_stat_statements.save = on # 重启后是否保留统计信息

archive_mode = 'on'
# 设置了一个无用的命令，主要是因为修改archive_mode需要重启数据库服务器，而修改archive_command不需要重启数据库服务器。所以先配置一个无用的命令“/usr/bin/true”，等真正需要归档时，再把archive_command设置成实际的归档命令，这样就不需要重启机器了。
archive_command = '/usr/bin/true'
```

#### 一份参数文件2

[PostgreSQL 性能优化](https://cloud.tencent.com/developer/article/2315307)

```sh
max_connections = 300       #(change requires restart)
# unix_socket_directories = '.'   #comma-separated list of directories

shared_buffers = 194GB    #尽量用数据库管理内存，减少双重缓存，提高使用效率
huge_pages = on    #on, off, or try，使用大页
work_mem = 256MB # min 64kB ，减少外部文件排序的可能，提高效率

maintenance_work_mem = 2GB  #min 1MB，加速建立索引
autovacuum_work_mem = 2GB   #min 1MB, or -1 to use maintenance_work_mem  ，加速垃圾回收。
dynamic_shared_memory_type = mmap   #the default is the first option
vacuum_cost_delay = 0      #0-100 milliseconds，垃圾回收不妥协，极限压力下，减少膨胀可能性。
bgwriter_delay = 10ms      #10-10000ms between rounds，刷shared buffer脏页的进程调度间隔，尽量高频调度，减少用户进程申请不到内存而需要主动刷脏页的可能（导致RT升高）。
bgwriter_lru_maxpages = 1000   #0-1000 max buffers written/round ,  一次最多刷多少脏页。
bgwriter_lru_multiplier = 10.0    #0-10.0 multipler on buffers scanned/round 一次扫描多少个块，上次刷出脏页数量的倍数。
effective_io_concurrency = 2       #1-1000; 0 disables prefetching ， 执行节点为bitmap heap scan时，预读的块数。

wal_level = minimal     #minimal, archive, hot_standby, or logical ， 如果现实环境，建议开启归档。
synchronous_commit = off    #synchronization level; ，异步提交。
wal_sync_method = open_sync    # the default is the first option ，因为没有standby，所以写xlog选择一个支持O_DIRECT的fsync方法。
full_page_writes = off      # recover from partial page writes ，生产中，如果有增量备份和归档，可以关闭，提高性能。
wal_buffers = 1GB           # min 32kB, -1 sets based on shared_buffers  ，wal buffer大小，如果大量写wal buffer等待，则可以加大。
wal_writer_delay = 10ms     #1-10000 milliseconds wal buffer调度间隔，和bg writer delay类似。
commit_delay = 20      #range 0-100000, in microseconds ，分组提交的等待时间。
commit_siblings = 9    #range 1-1000 , 有多少个事务同时进入提交阶段时，就触发分组提交。
checkpoint_timeout = 55min  #range 30s-1h 时间控制的检查点间隔。
max_wal_size = 320GB    #2个检查点之间最多允许产生多少个XLOG文件。
checkpoint_completion_target = 0.99     #checkpoint target duration, 0.0 - 1.0 ，平滑调度间隔，假设上一个检查点到现在这个检查点之间产生了100个XLOG，则这次检查点需要在产生100*checkpoint_completion_target个XLOG文件的过程中完成。PG会根据这些值来调度平滑检查点。
random_page_cost = 1.0     #same scale as above , 离散扫描的成本因子，本例使用的SSD IO能力足够好。
effective_cache_size = 240GB  #可用的OS CACHE

log_destination = 'csvlog'  #Valid values are combinations of
logging_collector = on          #Enable capturing of stderr and csvlog
log_truncate_on_rotation = on   #If on, an existing log file with the
update_process_title = off
track_activities = off
autovacuum = on    #Enable autovacuum subprocess?  'on'
autovacuum_max_workers = 4 #max number of autovacuum subprocesses ，允许同时有多少个垃圾回收工作进程。
autovacuum_naptime = 6s  #time between autovacuum runs，自动垃圾回收探测进程的唤醒间隔。
autovacuum_vacuum_cost_delay = 0    #default vacuum cost delay for，垃圾回收不妥协。
# cause a log event to be issued in the Postgres logs every time a lock is being waited on for more than 1 second. This is controlled by the deadlock timeout in Postgres
log_lock_waits = on
lock_timeout = 120s
```

## PostgreSQL 主从同步

[PostgreSQL 27.1. Comparison of Different Solutions](https://www.postgresql.org/docs/16/different-replication-solutions.html)
[PostgreSQL 27.2. Log-Shipping Standby Servers](https://www.postgresql.org/docs/16/warm-standby.html)

[进阶数据库系列（十五）：PostgreSQL 主从同步原理与实践-腾讯云开发者社区-腾讯云](https://cloud.tencent.com/developer/article/2315296)

[浅谈 PostgreSQL 高可用方案-腾讯云开发者社区-腾讯云](https://cloud.tencent.com/developer/article/2425953)

[Can someone share experience configuring Highly Available PgSQL? : r/PostgreSQL](https://www.reddit.com/r/PostgreSQL/comments/122p5am/can_someone_share_experience_configuring_highly/)

[Postgresql集群高可用架构学习-天翼云开发者社区 - 天翼云](https://www.ctyun.cn/developer/article/564584580702277)

[Postgres 史上最垃圾的高可用软件之 - CLup_vip postgres-CSDN博客](https://blog.csdn.net/qq_42226855/article/details/128004884)

[PostgreSQL: Documentation: 16: Chapter 20. Server Configuration](https://www.postgresql.org/docs/16/runtime-config.html)

当异步主从发生角色切换后，主库的wal目录中可能还有没完全同步到从库的内容，因此老的主库无法直接切换为新主库的从库。使用 pg_rewind 可以修复老的主库，使之成为新主库的只读从库。而不需要重建整个从库。

pg_rewind（PostgreSQL 9.5官方包含，用于主从故障切换），一般推荐使用repmgr rejoin机制。

```sh

# checksum 在每次写到OS以及读的时候计算，不是每次修改都计算，所以那负载就好多了（offload cpu checksum），所以OLTP开启吧https://postgreshelp.com/postgresql-checksum/，DSS和批处理不要开启。

# 开启 data_checksums
initdb -k
```

### PostgreSQL 预写日志机制（Write-Ahead Logging，WAL）

WAL 保证了事务持久性和数据完整性，又尽量地避免了频繁IO对性能的影响。

写数据的步骤：先写到缓冲区Buffer，再刷新到磁盘Disk。

WAL机制实际是在这个写数据的过程中加入了对应的写wal log的过程，步骤一样是先到Buffer，再刷新到Disk。

1. Change发生时
   1. 先将变更后内容记入WAL Buffer
   2. 再将更新后的数据写入Data Buffer
2. Commit发生时
   1. WAL Buffer刷新到Disk
   2. Data Buffer写磁盘推迟
3. Checkpoint发生时：将所有Data Buffer刷新到磁盘

WAL的好处

当宕机发生时，

Data Buffer的内容还没有全部写入到永久存储中，数据丢失；
但是WAL Buffer的内容已写入磁盘，根据WAL日志的内容，可以恢复库丢失的内容。

在提交时，仅把WAL刷新到了磁盘，而不是Data刷新：

从IO次数来说，WAL刷新是少量IO，Data刷新是大量IO，WAL刷新次数少得多；
从IO花销来说，WAL刷新是连续IO，Data刷新是随机IO，WAL刷新花销小得多。

因此WAL机制在保证事务持久性和数据完整性的同时，成功地提升了系统性能。

### 主从复制

1. 基于文件的日志传送：直接从一个数据库服务器移动 WAL 记录到另一台服务器
   1. PostgreSQL 通过一次一文件（WAL段）的WAL记录传输实现了基于文件的日志传送。
   2. 日志传送所需的带宽取根据主服务器的事务率而变化；
   3. 日志传送是异步的，即WAL记录是在事务提交后才被传送
   4. 数据丢失窗口可以通过使用参数archive_timeout进行限制，可以低至数秒，但同时会增加文件传送所需的带宽。
2. 流复制，PostgreSQL 在9.x之后引入，就是备服务器通过tcp流从主服务器中同步相应的数据，主服务器在WAL记录产生时即将它们以流式传送给备服务器，而不必等到WAL文件被填充。
   1. 默认情况下流复制是异步的，这种情况下主服务器上提交一个事务与该变化在备服务器上变得可见之间客观上存在短暂的延迟，但这种延迟相比基于文件的日志传送方式依然要小得多，在备服务器的能力满足负载的前提下延迟通常低于一秒；
   2. 在流复制中，备服务器比使用基于文件的日志传送具有更小的数据丢失窗口，不需要采用archive_timeout来缩减数据丢失窗口；
   3. 将一个备服务器从基于文件日志传送转变成基于流复制的步骤是：把recovery.conf文件中的primary_conninfo设置指向主服务器；设置主服务器配置文件的listen_addresses参数与认证文件即可。

### 主从复制使用到的工具

#### pg_basebackup 基础备份工具

使用 pg_basebackup 基础备份工具从主库创建从库的基础备份。

Perform an initial data synchronization from the primary server to the standby server.

[PostgreSQL 16: pg_basebackup](https://www.postgresql.org/docs/16/app-pgbasebackup.html)

```sh
pg_basebackup -h db01 -p 5432 -U replica -D $PGDATA -X stream -R
```

* `-h` specifies a non-local host. Here, you need to enter the IP address of your server with the primary cluster.
* `-p` specifies the port number it connects to on the primary server. By default, PostgreSQL uses port :5432.
* `-U` allows you to specify the user you connect to the primary cluster as. This is the role you created in the previous step.
* `-D` flag is the output directory of the backup. This is your replica's data directory that you emptied just before.
* `-Fp` specifies the data to be outputted in the plain format instead of as a tar file. This is the default format.
* `-Xs` streams the contents of the WAL log as the backup of the primary is performed. This value is the default.
* `-R, --write-recovery-conf` creates an empty file, named `standby.signal`, in the replica's data directory. This file lets your replica cluster know that it should operate as a standby server. The `-R` option also adds the connection information about the primary server to the postgresql.auto.conf file. This is a special configuration file that is read whenever the regular postgresql.conf file is read, but the values in the .auto file override the values in the regular configuration file.
* `-C, --create-slot` Specifies that the replication slot named by the --slot option should be created before starting the backup. An error is raised if the slot already exists.
* `-S slotname, --slot=slotname` This option can only be used together with -X stream. It causes WAL streaming to use the specified replication slot. If the base backup is intended to be used as a streaming-replication standby using a replication slot, the standby should then use the same replication slot name as primary_slot_name. This ensures that the primary server does not remove any necessary WAL data in the time between the end of the base backup and the start of streaming replication on the new standby.

The specified replication slot has to exist unless the option -C is also used.

If this option is not specified and the server supports temporary replication slots (version 10 and later), then a temporary replication slot is automatically used for WAL streaming.

### PostgreSQL高可用架构方案 的优势和区别

这个表格提供了一个基本的概览，但请注意，每种方案的实际适用性和优势可能会根据具体的应用场景、团队经验和业务需求有所不同。因此，在选择适合自己项目的高可用架构方案时，建议深入研究每个方案的具体细节，并考虑进行一定的测试或咨询经验丰富的专家。

| 特征/方案   | 流复制+Keepalived | repmgr          | pgpool-II   | Patroni       | PAF          | Pacemaker+Corosync  |   |
|---------|----------------|-----------------|-------------|---------------|--------------|---------------------|---|
| 主要优势    | 简单易配置          | 简单易用            | 负载均衡        | 自动故障转移        | 与Pacemaker集成 | 高级集群管理              |   |
| 架构类型    | 主备切换           | 主备切换            | 连接池/负载均衡    | 主备切换          | 主备切换         | 主备切换或多主             |   |
| 复杂度     | 低              | 低到中             | 高           | 中             | 中到高          | 高                   |   |
| 自动故障转移  | 有（较为基本）        | 有               | 有           | 有             | 有            | 有                   |   |
| 管理工具    | Keepalived     | repmgr          | pgpool-II   | Patroni       | Pacemaker    | Pacemaker+Corosync  |   |
| 特色功能    | 虚拟IP切换         | 复制管理            | 查询分割和复制     | 分布式系统管理       | 高级监控与管理      | 灵活的资源管理             |   |
| 适用场景    | 小型至中型企业        | PostgreSQL专用高可用 | 复杂查询环境或读写分离 | 需要自动化和易于扩展的场景 | 需要与其他服务集成的场景 | 复杂的企业级应用            |   |
| 维护和社区支持 | 低到中            | 高               | 中           | 高             | 中            | 中到高                 |   |

[synchronous_commit 配置对性能的影响](https://www.cnblogs.com/lightdb/p/15483919.html)

### 主备切换 流复制+keepalived

[PostgreSQL从小白到高手教程 - 第48讲：PG高可用实现 keepalived -腾讯云开发者社区-腾讯云](https://cloud.tencent.com/developer/article/2400069)
[Create a highly available PostgreSQL cluster in linux using repmgr and keepalived | by Fekete József | Medium](https://medium.com/@fekete.jozsef.joe/create-a-highly-available-postgresql-cluster-in-linux-using-repmgr-and-keepalived-9d72aa9ef42f)
[PostgreSQL HA with Repmgr and Keepalived | by ilosaurus | Medium](https://medium.com/@muhilhamsyarifuddin/postgresql-ha-with-repmgr-and-keepalived-f466bb6aa437)

切换脚本failover.sh，主库宕机后，keepalived调用执行切换脚本。

优点：复杂度较低，配置简单

缺点：

* 需要自己编写监控和切换脚本，自己维护切换后的系统状态。
* 存在着脑裂的问题。

#### 一些参考的脚本

```sh
#!/bin/bash
# /etc/keepalived/check_pg.sh
# 监控脚本check_pg.sh，对主从PG 进行状态监控。

export PGDATABASE=postgres
export PGPORT=1922
export PGUSER=postgres
export PGHOME=/usr/local/pg12.2
export PATH=$PGHOME/bin:$PATH:$HOME/bin
PGMIP=127.0.0.1
LOGFILE=/etc/keepalived/log/pg_status.log
SQL1='SELECT pg_is_in_recovery from pg_is_in_recovery();'
SQL2='update sr_delay set sr_date = now() where id =1;'
SQL3='SELECT 1;'

db_role=`echo $SQL1 | $PGHOME/bin/psql -d $PGDATABASE -U $PGUSER -At -w`
if [ $db_role == 't' ]; then
   echo -e `date +"%F %T"` "Attention1:the current database is standby DB!" >> $LOGFILE
   exit 0
fi

# 备库不检查存活,主库更新状态
echo $SQL3 | psql -p $PGPORT -d $PGDATABASE -U $PGUSER -At -w
if [ $? -eq 0 ] ; then
   echo $SQL2 | psql -p $PGPORT -d $PGDATABASE -U $PGUSER -At -w
   echo -e `date +"%F %T"` "Success: update the master sr_delay successed!" >> $LOGFILE
   exit 0
else
   echo -e `date +"%F %T"` "Error:Is the server is running?" >> $LOGFILE
   exit 1
fi
```

```sh
#!/bin/bash
# /etc/keepalived/failover.sh
# 切换脚本failover.sh，主库宕机后，keepalived调用执行切换脚本。

export PGPORT=1922
export PGUSER=postgres
export PG_OS_USER=postgres
export PGDATA=/usr/local/pg12.2/data
export PGDBNAME=postgres
export LANG=zh_CN.UTF-8
export PGPATH=/usr/local/pg12.2/bin
export PATH=$PATH:$PGPATH
PGMIP=127.0.0.1
LOGFILE=/etc/keepalived/log/failover.log

# master-to-slave delay
sr_allowed_delay_time=10
SQL1='select pg_is_in_recovery from pg_is_in_recovery();'
SQL2="select sr_date as delay_time from sr_delay where now()-sr_date < interval '60';"
db_role=`echo $SQL1 | psql -At -p $PGPORT -U $PGUSER -d $PGDBNAME -w`
db_sr_delaytime=`echo $SQL2 | psql -p $PGPORT -d $PGDBNAME -U $PGUSER -At -w`
SWITCH_COMMAND='pg_ctl promote -D $PGDATA'

# slave switchover to master if delay large than specical second
if [ $db_role == f ];then
   echo -e `date +"%F %T"` "Attention:The current postgreSQL DB is master database,cannot switched!" >> $LOGFILE
   exit 0
fi

if [ $db_sr_delaytime -gt 0 ];then
   echo -e `date +"%F %T"` "Attention:The current master database is health,the standby DB cannot switched!" >> $LOGFILE
   exit 0
fi

echo $db_sr_delaytime

if [ -z $db_sr_delaytime ];then
   echo -e `date +"%F %T"` "Attention:The current database is statndby,ready to switch master database!" >> $LOGFILE
   pg_ctl promote -D $PGDATA
   sed -i 's/primary_conninfo/#primary_conninfo/' $PGDATA/postgresql.auto.conf
   pg_ctl restart -D $PGDATA
elif [ $? eq 0 ];then
   echo -e `date +"%F %T"` "success:The current standby database successed to switched the primary PG database !" >> $LOGFILE
   exit 0
else
   echo -e `date +"%F %T"` "Error: the standby database failed to switch the primary PG database !,pelease checked it!" >> $LOGFILE
   exit 1
fi
```

```sh
#!/bin/bash
# /etc/keepalived/fault.sh
# 脚本fault.sh，keepalived 进入错误状态时执行的脚本。

LOGGFILE=/etc/keepalived/log/pg_db_fault.log
PGPORT=1922
PGMIP=10.10.10.111
echo -e `date +"%F %T"` "Error:Because of the priamry DB happend some unknown problem,So turn off the PostgreSQL Database!" >> $LOGFILE
PGPID="`netstat -anp|grep $PGPORT |awk '{printf $7}'|cut -d/ -f1`"

service keepalived stop
kill -9 $PGPID

if [ $? eq 0 ];then
   echo -e `date +"%F %T"` "Error:Because of the priamry DB happend some unknown problem,So turn off the PostgreSQL Database!" >> $LOGFILE
   service keepalived stop
   exit 1
fi
```

#### PostgreSQL 主库配置

[Setting Up PostgreSQL Replication: A Step-by-Step Guide | by Umair Hassan | Medium](https://medium.com/@umairhassan27/setting-up-postgresql-replication-on-slave-server-a-step-by-step-guide-1ff36bb9a47f)

```sql
-- 创建数据库账号replica，并将密码设置为replica
CREATE ROLE replica login replication encrypted password 'password';

-- 查询账号是否创建成功
SELECT usename from pg_user where usename = 'replica';
-- 查询权限是否创建成功
SELECT rolname from pg_roles where rolname = 'replica';
```

配置 pg_hba.conf 文件

```sh
# 配置 pg_hba.conf 文件
tee -a $PGDATA/pg_hba.conf << EOF

host    all             all             db02IP/32            md5
host    replication     replica         db02IP/32            md5
EOF
```

配置 postgresql.conf 文件 并将参数修改为以下内容：

```sh
# vi $PGDATA/postgresql.conf
listen_addresses = '*'   #监听的IP地址
max_connections = 10000    #最大连接数，从库的max_connections必须要大于主库的

# [wal_level synchronous_commit: 20.5. Write Ahead Log](https://www.postgresql.org/docs/16/runtime-config-wal.html#RUNTIME-CONFIG-WAL-SETTINGS)
wal_level = replica      #记录足够的信息以支持常见的备库用途，包括流复制和热备 minimal, replica, or logical
synchronous_commit = on  #开启同步复制 Valid values are remote_apply, on (the default), remote_write, local, and off.
# [max_wal_senders wal_sender_timeout: 20.6. Replication](https://www.postgresql.org/docs/16/runtime-config-replication.html#GUC-MAX-WAL-SENDERS)
max_wal_senders = 10     #同步最大的进程数量
wal_sender_timeout = 60s #流复制主机发送数据的超时时间
#max_replication_slots = 10     # max number of replication slots (change requires restart)
primary_slot_name = 'node_a_slot'     # replication slot on sending server, 主库设置是为了主从切换后，变为从库的预先准备

# archive_timeout = 0 # force a WAL file switch after this number of seconds; 0 disables

# create a replication slot
psql -U postgres -c "SELECT * FROM pg_create_physical_replication_slot('node_a_slot');"
# Querying Replication Slots
psql -U postgres -c "SELECT slot_name, slot_type, active FROM pg_replication_slots;"

# 启动服务
systemctl restart postgresql
```

```sql
-- 测试数据
CREATE DATABASE test_replication;
\c test_replication
CREATE TABLE test_table (id serial primary key, value text);
INSERT INTO test_table (value) VALUES ('Record 1');
INSERT INTO test_table (value) VALUES ('Record 2');
SELECT * FROM test_table;
```

#### PostgreSQL 从库配置

```sh
# 安装但是不启动，也不初始化数据目录
mkdir -p $PGDATA
chown -R postgres:postgres $PGDATA
chmod 0700 /data/pgdata

# Perform an initial data synchronization from the primary server to the standby server.
# [PostgreSQL 16: pg_basebackup](https://www.postgresql.org/docs/16/app-pgbasebackup.html)
pg_basebackup -h db01 -p 5432 -U replica -D $PGDATA -X stream -R
# R if you are using this to create a standby, this will automatically add a recovery.conf to the backup folder
# X will include the wall files generated while the backup was being taken, this will ensure that your backup is up-to-date
```

修改 $PGDATA/postgresql.conf

```sh
# vi $PGDATA/postgresql.conf
# primary_conninfo = 'host=<主节点IP> port=5432 user=replica password=replica' #对应主库的连接信息
# primary_conninfo = 'host=db01 port=5432 user=replica password=password' #对应主库的连接信息
recovery_target_timeline = 'latest' #流复制同步到最新的数据 default latest
max_connections = 1000             # 最大连接数，从节点需设置比主节点大
# hot_standby = on     # 开启热备 "off" disallows queries during recovery (change requires restart). default on

# max_standby_streaming_delay = 30s  # 数据流备份的最大延迟时间 default 30s, 超时则杀掉从库正在执行的冲突 SQL
# wal_receiver_status_interval = 1s  # 从节点向主节点报告自身状态的最长间隔时间 default 10s
# hot_standby_feedback = on          # 如果有错误的数据复制向主进行反馈 default off
primary_slot_name = 'node_a_slot'                       # replication slot on sending server

# create a replication slot
# 从库也创建好，是为了主从切换
psql -U postgres -c "SELECT * FROM pg_create_physical_replication_slot('node_a_slot');"
# Querying Replication Slots
psql -U postgres -c "SELECT slot_name, slot_type, active FROM pg_replication_slots;"

# 启动服务
systemctl restart postgresql
```

#### PostgreSQL 主从配置验证

```sh
pg_basebackup -D $PGDATA -h db01 -p 5432 -U replica -X stream -P
# pg_basebackup: error: directory "/data/pgdata" exists but is not empty

# 在主节点中运行以下命令，查看sender进程。
ps auxww | grep ^postgres
ps aux |grep walsender

# 在从节点中运行以下命令，查看receiver进程
ps aux |grep walreceiver

pg_controldata | grep 'Database cluster state'
# 主库返回 in production
# 从库返回 in archive recovery


# 在主库中查看从库状态。
# [PostgreSQL 16: 9.27. System Administration Functions Table 9.91. Backup Control Functions](https://www.postgresql.org/docs/16/functions-admin.html#FUNCTIONS-ADMIN-BACKUP-TABLE)
psql -U postgres -c "select pg_current_wal_lsn();"

psql -U postgres -c "\x" -c "select * from pg_stat_replication;"
-[ RECORD 1 ]----+-----------------------------
pid              | 31055
usesysid         | 16388
usename          | replica
application_name | walreceiver
client_addr      | 127.0.0.1
client_hostname  |
client_port      | 41552
backend_start    | 2024-10-23 11:48:56.27194+08
backend_xmin     |
state            | streaming
sent_lsn         | 0/7000060
write_lsn        | 0/7000060
flush_lsn        | 0/7000060
replay_lsn       | 0/7000060
write_lag        |
flush_lag        |
replay_lag       |
sync_priority    | 0
sync_state       | async
reply_time       | 2024-10-23 11:51:16.34397+08


# Monitor replication status:
[PostgreSQL 16: 9.27. System Administration Functions Table 9.92. Recovery Information Functions](https://www.postgresql.org/docs/16/functions-admin.html#FUNCTIONS-RECOVERY-INFO-TABLE)
psql -U postgres -c "select pg_last_wal_receive_lsn(), pg_last_wal_replay_lsn(), pg_last_xact_replay_timestamp();"

psql -U postgres -c "\x" -c "SELECT * FROM pg_stat_wal_receiver;"
-[ RECORD 1 ]---------+---------------
pid                   | 29078
status                | streaming
receive_start_lsn     | 0/7000000
receive_start_tli     | 1
written_lsn           | 0/7000060
flushed_lsn           | 0/7000060
received_tli          | 1
last_msg_send_time    | 2024-10-23 11:50:56.321083+08
last_msg_receipt_time | 2024-10-23 11:50:56.323755+08
latest_end_lsn        | 0/7000060
latest_end_time       | 2024-10-23 11:48:56.288978+08
slot_name             |
sender_host           | db01
sender_port           | 5432
conninfo              | user=replica password=******** channel_binding=disable dbname=replication host=db01 port=5432 fallback_application_name=walreceiver sslmode=disable sslcompression=0 sslcertmode=disable sslsni=1 ssl_min_protocol_version=TLSv1.2 gssencmode=disable krbsrvname=postgres gssdelegation=0 target_session_attrs=any load_balance_hosts=disable
```

#### PostgreSQL Replication Switchover

[PostgreSQL Replication Switchover: A Step-by-Step Guide | by Umair Hassan | Medium](https://medium.com/@umairhassan27/postgresql-replication-switchover-a-step-by-step-guide-d42107d860)

```sh
# Verify Standby Synchronization
SELECT CASE
    WHEN pg_last_wal_receive_lsn() = pg_last_wal_replay_lsn() THEN 0
    ELSE EXTRACT(EPOCH FROM now() - pg_last_xact_replay_timestamp())
END AS log_delay;

# Allow Current Live IP in Current Backup 配置 pg_hba.conf 文件
tee -a $PGDATA/pg_hba.conf << EOF
host    replication     replica         db01IP/32            md5
EOF

# Shutdown the Primary
systemctl stop postgresql
# pg_ctl stop -D $PGDATA

# Promote the Standby to Read-Write
psql -U postgres -c "SELECT pg_promote();"
# pg_ctl promote -D $PGDATA
#This command promotes the standby to a read-write primary.

# Create standby.signal on Old Primary
touch $PGDATA/standby.signal

# Edit postgresql.auto.conf on Old Primary
#Update the postgres.auto.conf file with NEW MASTER SERVER DETAILS
vi $PGDATA/postgresql.auto.conf

#Modify the primary_conninfo parameter to reflect the new standby IP:
primary_conninfo = 'user=replica password=''password'' channel_binding=disable host=db02 port=5432 sslmode=disable sslcompression=0 sslcertmode=disable sslsni=1 ssl_min_protocol_version=TLSv1.2 gssencmode=disable krbsrvname=postgres gssdelegation=0 target_session_attrs=any load_balance_hosts=disable'

# Querying Replication Slots
psql -U postgres -c "SELECT slot_name, slot_type, active FROM pg_replication_slots;"
# 确认 node_a_slot 存在
psql -U postgres -c "SELECT * FROM pg_create_physical_replication_slot('node_a_slot');"

# TODO: 通过 pg_rewind 工具 配置postgresql.auto.conf添加primary_conninfo参数

# Start Old Primary as a Standby
# pg_ctl start -D $PGDATA
systemctl start postgresql

# Monitor Logs The logs will have something like “Starting as a standby”
tail -100f $PGDATA/startup.log

# Verify switchover

# Verify the switchover using the available views.
# First we will check if the server is receiving wals or not run below query on new slave:
select * from pg_stat_wal_receiver;
select pg_last_wal_receive_lsn(), pg_last_wal_replay_lsn(), pg_last_xact_replay_timestamp();

IS_STANDBY=$(sudo -u postgres psql -U postgres -tAc "SELECT pg_is_in_recovery()")

# Verify by matching the tables in both DB's
# 测试数据
CREATE DATABASE test_replication;
\c test_replication
CREATE TABLE test_table (id serial primary key, value text);
INSERT INTO test_table (value) VALUES ('Record 1');
INSERT INTO test_table (value) VALUES ('Record 2');
SELECT * FROM test_table;

# Check the new slave is Read-only or not (It should be read-only)
SELECT pg_is_in_recovery();
# This query will return a single boolean value:
# true if the server is a standby and false if it's the primary.
```

主备切换脚本

```sh
#!/bin/bash
# 需要在主从库上配置 ssh 和数据库免密登录

set -euxo pipefail

PRIMARY_OLD=db01
STANDBY_OLD=db02

# stop old primary
ssh $PRIMARY_OLD -t sudo systemctl stop postgresql

# Promote the old standby to new primary
psql -h $STANDBY_OLD -U postgres -c "SELECT pg_promote();"
ssh $STANDBY_OLD -t sudo tail -15 $PGDATA/startup.log

# Startup old primary as new standby
ssh $PRIMARY_OLD -t sudo touch $PGDATA/standby.signal
ssh $PRIMARY_OLD -t sudo systemctl start postgresql

# view log
ssh $PRIMARY_OLD -t sudo tail -20 $PGDATA/startup.log
psql -h $STANDBY_OLD -U postgres -c "SELECT pg_is_in_recovery();"
psql -h $PRIMARY_OLD -U postgres -c "SELECT pg_is_in_recovery();"

echo $STANDBY_OLD is primary, $PRIMARY_OLD is standby
```

#### PostgreSQL keepalived setup

[PostgreSQL从小白到高手教程 - 第48讲：PG高可用实现keepalived-腾讯云开发者社区-腾讯云](https://cloud.tencent.com/developer/article/2400069)

```sh
# 有内容修改
# 需要使用抢占模式配置，注释掉 nopreempt
# #nopreempt
# Don't run scripts configured to be run as root if any part of the path
# is writable by a non-root user.
#  enable_script_security
sudo cp /etc/keepalived/keepalived.conf /etc/keepalived/keepalived.conf.default
sudo cp conf/keepalived.conf /etc/keepalived/keepalived.conf
mkdir -p /data/project/keepalived/
cp conf/check_pg_primary.sh /data/project/keepalived/

sudo systemctl enable keepalived
sudo systemctl start keepalived
sudo systemctl restart keepalived

# view log
sudo journalctl -xeu keepalived
```

keepliaved configuration file: keepalived.conf

```conf
; master node
! https://github.com/kubernetes/kubeadm/blob/main/docs/ha-considerations.md#keepalived-configuration
! [Keepalived Man page for Linux](https://www.keepalived.org/manpage.html)
!
! /etc/keepalived/keepalived.conf
! /usr/local/etc/keepalived/keepalived.conf
! /container/service/keepalived/assets/keepalived.conf
! /usr/local/etc/keepalived/check_pg_primary.sh
! Configuration File for keepalived
global_defs {
    router_id LVS_DEVEL_postgres
    script_user username
    enable_script_security
}
vrrp_script check_pg_primary {
  script "/data/project/keepalived/check_pg_primary.sh"
  interval 2
  weight -2
  fall 10
  rise 2
}

vrrp_instance VI_1 {
    state MASTER        #  is MASTER for one and BACKUP for all other hosts, hence the virtual IP will initially be assigned to the MASTER.
    interface ens192
    virtual_router_id 53  #  should be the same for all keepalived cluster hosts while unique amongst all clusters in the same subnet
    priority 101        #  should be higher on the control plane node than on the backups. Hence 101 and 100 respectively will suffice.
    #nopreempt #不可抢占

    authentication {
        auth_type PASS
        auth_pass 43   #  should be the same for all keepalived cluster hosts,
    }
    virtual_ipaddress {
        10.2.8.81  #  is the virtual IP address negotiated between the keepalived cluster hosts.
    }
    track_script {
        check_pg_primary
    }

    #notify "/container/service/keepalived/assets/notify.sh"
}
```

```conf
; backup node
! https://github.com/kubernetes/kubeadm/blob/main/docs/ha-considerations.md#keepalived-configuration
! [Keepalived Man page for Linux](https://www.keepalived.org/manpage.html)
!
! /etc/keepalived/keepalived.conf
! /usr/local/etc/keepalived/keepalived.conf
! /container/service/keepalived/assets/keepalived.conf
! /usr/local/etc/keepalived/check_pg_primary.sh
! Configuration File for keepalived
global_defs {
    router_id LVS_DEVEL_postgres
    script_user username
    enable_script_security
}
vrrp_script check_pg_primary {
  script "/data/project/keepalived/check_pg_primary.sh"
  interval 2
  weight -2
  fall 10
  rise 2
}

vrrp_instance VI_1 {
    state BACKUP        #  is MASTER for one and BACKUP for all other hosts, hence the virtual IP will initially be assigned to the MASTER.
    interface ens192
    virtual_router_id 53  #  should be the same for all keepalived cluster hosts while unique amongst all clusters in the same subnet
    priority 101        #  should be higher on the control plane node than on the backups. Hence 101 and 100 respectively will suffice.
    #nopreempt #不可抢占

    authentication {
        auth_type PASS
        auth_pass 43   #  should be the same for all keepalived cluster hosts,
    }
    virtual_ipaddress {
        10.2.8.81  #  is the virtual IP address negotiated between the keepalived cluster hosts.
    }
    track_script {
        check_pg_primary
    }

    #notify "/container/service/keepalived/assets/notify.sh"
}
```




```sh

#!/bin/sh
# /data/project/keepalived/check_pg_primary.sh

export PGHOME=/data/software/pgsql-16.3
export PATH=$PGHOME/bin:$PATH

# Check if the node is in recovery mode (standby)
#IS_STANDBY=$(sudo -u postgres psql -h localhost -U postgres -d postgres -tAc "SELECT pg_is_in_recovery()")
IS_STANDBY=$(psql -h db01 -U postgres -d postgres -tAc "SELECT pg_is_in_recovery()")

if [ $? -ne 0 ]; then
    echo "error when execute sql"
    exit 1
fi

if [ "$IS_STANDBY" == "t" ]; then
    echo "Node is standby"
    exit 1
elif [ "$IS_STANDBY" == "f" ]; then
    echo "Node is primary"
    exit 0
```

#### PostgreSQL pg_rewind

[PostgreSQL pg_rewind](https://www.postgresql.org/docs/16/app-pgrewind.html)
[PgSQL · 特性分析 · 神奇的pg_rewind-阿里云开发者社区](https://developer.aliyun.com/article/608907)
[PgSQL · 特性分析 · 时间线解析 - 数据库内核月报](http://mysql.taobao.org/monthly/2015/07/03/?spm=a2c6h.12873639.article-detail.10.51497a76cSjrad)

pg_rewind requires that the target server either has the `wal_log_hints` option enabled in `postgresql.conf` or data checksums enabled when the cluster was initialized with initdb. Neither of these are currently on by default. `full_page_writes` must also be set to on, but is enabled by default.

```sh
# 主库执行
pg_rewind --target-pgdata=/data/pgdata --source-server='host=db02 port=5432 user=postgres' --progress --dry-run

# 执行完后从库需要检查以下设置
# postgresql.conf 确保从库关闭备份，主库打开备份
# 从库
archive_mode = off
archive_command = ''
archive_cleanup_command = ''
# 主库
archive_mode = on
archive_command = 'rsync -Pavz %p /data/nfsdata/postgresql16.3/archivedir/%f'
archive_cleanup_command = 'pg_archivecleanup /data/nfsdata/postgresql16.3/archivedir %r'
restore_command = 'cp /data/nfsdata/postgresql16.3/archivedir/%f %p'            # command to use to restore an archived WAL file
recovery_target_timeline = 'latest'     # 'current', 'latest', or timeline ID

# postgresql.auto.conf 确认跟踪的库为主库
host=db01
```

* `-n --dry-run` Do everything except actually modifying the target directory.
* `-P --progress` Enables progress reporting.
* `-c --restore-target-wal` Use restore_command defined in the target cluster configuration to retrieve WAL files from the WAL archive if these files are no longer available in the pg_wal directory.
* `-R --write-recovery-conf` Create standby.signal and append connection settings to postgresql.auto.conf in the output directory. --source-server is mandatory with this option.
* `--debug` Print verbose debugging output that is mostly useful for developers debugging pg_rewind.

#### PostgreSQL 同步异常

```sh
2024-11-11 17:33:44.021 CST [23888] LOG:  waiting for WAL to become available at 0/31000250
2024-11-11 17:33:49.021 CST [24157] LOG:  started streaming WAL from primary at 0/31000000 on timeline 23
2024-11-11 17:33:49.021 CST [24157] FATAL:  could not receive data from WAL stream: ERROR:  requested starting point 0/31000000 is ahead of the WAL flush position of this server 0/307D5F08
2024-11-11 17:33:49.021 CST [23888] LOG:  waiting for WAL to become available at 0/31000250



2024-11-12 10:11:33.405 CST [3738] LOG:  restored log file "000000170000000000000031" from archive
2024-11-12 10:11:33.419 CST [3738] LOG:  invalid record length at 0/310001C0: expected at least 24, got 0

```


### repmgr

[repmgr 5.4.1 Documentation](https://www.repmgr.org/docs/current/index.html)

repmgr 是 EDB 公司的一个开源工具套件（类似于 MySQL 的 MHA），用于管理 PostgreSQL 服务器集群中的复制和故障转移。它使用工具来增强 PostgreSQL 的内置热备份功能，以设置备用服务器，监控复制以及执行管理任务，例如故障转移或手动切换操作。

优点

* 配置操作简单，可一键式完成相关部署操作；
* 支持 Auto Failover 和 Manual Switchover；
* 不使用任何额外的端口进行通信;
* 对数据库侵入小，和主备流复制基本一致;
* 通过调用已注册事件的用户脚本来提供通知;
* 不使用任何额外的端口进行通信。

缺点

* 没有对VIP的管理，如果要实现VIP的管理，需要自己写脚本来实现。
* 无法从 PostgreSQL 服务关闭的节点检索另一个节点的状态
* 不会检测备用库是否在恢复配置中使用未知或不存在的节点错误配置
* 不提供分布式控制解决方案
* 不能在备机单个节点 down 掉时，自动拉起

[Create a highly available PostgreSQL cluster in linux using repmgr and keepalived | by Fekete József | Medium](https://medium.com/@fekete.jozsef.joe/create-a-highly-available-postgresql-cluster-in-linux-using-repmgr-and-keepalived-9d72aa9ef42f)
[PostgreSQL HA with Repmgr and Keepalived | by ilosaurus | Medium](https://medium.com/@muhilhamsyarifuddin/postgresql-ha-with-repmgr-and-keepalived-f466bb6aa437)

### Pgpool-II

[pgpool-II 4.5.4 Documentation](https://www.pgpool.net/docs/45/en/html/index.html)
[Pgpool-II + Watchdog Setup Example](https://www.pgpool.net/docs/45/en/html/example-cluster.html)

建议部署 3 节点 Pgpool-II，参考 [Watchdog](https://www.pgpool.net/docs/45/en/html/tutorial-watchdog-intro.html)

Pgpool-II 是在 PostgreSQL 服务器和 PostgreSQL 数据库客户端之间工作的中间件。

优点

* 连接池：提供连接池功能，提高数据库性能。
* 负载均衡：可以在多个 PostgreSQL 实例之间分发查询请求。
* 自动故障转移：支持自动故障转移和读写分离。

缺点

* 复杂性：配置和管理相对复杂。
* 性能开销：在高负载情况下，Pgpool-II 本身可能成为瓶颈。
* 一致性：需要额外处理数据一致性问题。
* 如果必要，需要额外需要一台服务器部署 Pgpool

[Configuring Pgpool-II RUNNING-MODE](https://www.pgpool.net/docs/45/en/html/configuring-pgpool.html#RUNNING-MODE)
The most popular mode ever used is "streaming replication mode".

[PG-高可用 pgpool-Ⅱ 运行模式优缺点](https://www.cnblogs.com/binliubiao/p/13181143.html)

pgpool-Ⅱ有连接池、复制、负载均衡等功能，使用这些功能需要配置在不同的工作模式下。

* 原始模式：只实现故障切换功能，当配置多个后端数据库情形，第一个后端数据库故障时切换到第二个后端数据库，依次类推。这种模式pgpool不负责后端数据库数据同步，数据库的数据同步由用户负责，对应配置文件为$prefix/etc/pgpool.conf.sample，这种模式不支持负载均衡。
* 连接池模式：实现连接池的功能和原始模式的故障切换功能。
* 内置复制模式：这种模式下pgpool负责后端数据库数据同步，pgpool节点上的写操作需等待所有后端数据库将数据写入后才向客户端返回成功，是强同步复制方式，配置文件为$prefix/etc/pgpoo1.conf.sampie-repIication，这种模式实现负载均衡的功能。
* 主备模式：使用第三方工具(如：Slony，流复制)完成pgpool的后端数据库的数据同步复制，中间件层使用pgpool-Ⅱ，pgpool提供高可用和连接池的功能。配置文件为$prefix/etc/pgpool.conf.sample-master-slave，这种模式支持负载均衡。
* 配合流复制的主备模式：使用PostgreSQL流复制方式，PostgreSQL流复制负责pgpool后端数据库数据同步，对应的配置文件为$prefix/etc/pgpool.conf.sample-stream，这种模式支持负载均衡。pgpool+pg复制实现高可用解决方案
* 配合Slony的主备模式：
* 并行模式：实现查询的并行执行。并行模式不能与主备模式同时使用。

### Patroni

[Patroni 4.0.2 documentation](https://patroni.readthedocs.io/en/latest/README.html#technical-requirements-installation)

Patroni 是一个基于 Python 的高可用解决方案，利用 etcd、Consul 或 ZooKeeper 或 Kubernetes 等分布式一致性存储实现自动故障转移。

优点

* 持续监控和自动故障转移
* 使用单个命令进行手动/计划切换
* 内置自动化功能，用于将故障节点再次带回到集群。
* 用于整个集群配置和进一步工具化的 REST API。
* 为透明的应用故障转移提供基础能力 每个操作和配置的分布式共识。
* 与 Linux 看门狗集成，以避免脑裂现象。

缺点

* 没有实现对VIP的管理，如果要实现VIP的管理，需要自己写脚本来实现
* 复杂性：需要配置和管理多个组件（如 etcd、Consul 或 ZooKeeper）。
* 资源消耗：额外的组件会增加系统资源消耗和运维复杂度。

## MySQL 与 PostgreSQL 之间的区别

[PostgreSQL 与 MySQL 相比，优势何在？ - 知乎](https://www.zhihu.com/question/20010554)
[Why Uber Engineering Switched from Postgres to MySQL | Uber Blog](https://www.uber.com/en-SG/blog/postgres-to-mysql-migration/)

### 迁移工具

[pgloader](https://github.com/dimitri/pgloader)可以根据给定的映射规则将 MySQL 数据转化为 PostgreSQL 数据。

## 数据库开发规范

[PostgreSQL 数据库开发规范-阿里云开发者社区](https://developer.aliyun.com/article/60899)

### 命名规范

1. 标识符总长度不超过63，由于oracle标识符长度不超过30，原则上，为了兼容oracle，标识符长度最好不要超过30；
2. 对象名（表名、列名、函数名、视图名、序列名、等对象名称）规范，对象名务必只使用小写字母，下划线，数字。不要以pg开头，不要以数字开头，不要使用保留字;
3. 查询中的别名不要使用 "小写字母，下划线，数字" 以外的字符，例如中文;
4. 主键索引应以 `pk_` 开头， 唯一索引要以 `uk_` 开头，普通索引要以 `idx_` 打头
5. 临时表以 `tmp_` 开头，子表以规则结尾，例如按年分区的主表如果为tbl, 则子表为tbl_2016，tbl_2017等；
6. 库名最好以部门名字开头 + 功能，如 xxx_yyy，xxx_zzz，便于辨识；
7. 禁用public schema，应该为每个应用分配对应的schema，schema_name最好与user name一致。

### 设计规范

1. 多表中的相同列，必须保证列名一致，数据类型一致；
2. btree索引字段不建议超过2000字节，如果有超过2000字节的字段需要建索引，建议使用函数索引（例如哈希值索引），或者使用分词索引；
3. 对于频繁更新的表，建议建表时指定表的fillfactor=85，每页预留15%的空间给HOT更新使用；（create table test123(id int, info text) with(fillfactor=85); CREATE TABLE）
4. 表结构中字段定义的数据类型与应用程序中的定义保持一致，表之间字段校对规则一致，避免报错或无法使用索引的情况发生；
5. 建议有定期历史数据删除需求的业务，表按时间分区，删除时不要使用DELETE操作，而是DROP或者TRUNCATE对应的表；
6. 为了全球化的需求，所有的字符存储与表示，均以UTF-8编码；
7. 对于值与堆表的存储顺序线性相关的数据，如果通常的查询为范围查询，建议使用BRIN索引。例如流式数据，时间字段或自增字段，可以使用BRIN索引，减少索引的大小，加快数据插入速度。（create index idx on tbl using brin(id); ）
8. 设计时应尽可能选择合适的数据类型，能用数字的坚决不用字符串，使用好的数据类型，可以使用数据库的索引，操作符，函数，提高数据的查询效率；
9. 应该尽量避免全表扫描(除了大数据量扫描的数据分析)，PostgreSQL支持几乎所有数据类型的索引；
10. 应该尽量避免使用数据库触发器，这会使得数据处理逻辑复杂，不便于调试；
11. 未使用的大对象，一定要同时删除数据部分，否则大对象数据会一直存在数据库中，与内存泄露类似；
12. 对于固定条件的查询，可以使用部分索引，减少索引的大小，同时提升查询效率；（create index idx on tbl (col) where id=1;）
13. 对于经常使用表达式作为查询条件的语句，可以使用表达式或函数索引加速查询；（create index idx on tbl ( exp ); ）
14. 如果需要调试较为复杂的逻辑时，不建议写成函数进行调试，可以使用plpgsql的匿名代码块；
15. 当用户有prefix或者 suffix的模糊查询需求时，可以使用索引，或反转索引达到提速的需求；（select * from tbl where reverse(col) ~ '^def'; – 后缀查询使用反转函数索引）
16. 用户应该对频繁访问的大表（通常指超过8GB的表，或者超过1000万记录的表）进行分区，从而提升查询的效率、更新的效率、备份与恢复的效率、建索引的效率等等；
17. 设计表结构时必须加上字段数据的入库时间inputed_time和数据的更新时间updated_time；

### 查询规范

1. 统计行数用count(*)或者count(1),count(列名)不会统计列为空的行；
2. count(distinct col) 计算该列的非NULL不重复数量，NULL不被计数；
3. count(distinct (col1,col2,…) ) 计算多列的唯一值时，NULL会被计数，同时NULL与NULL会被认为是想同的；
4. NULL是UNKNOWN的意思，也就是不知道是什么。 因此NULL与任意值的逻辑判断都返回NULL；
5. 除非是ETL程序，否则应该尽量避免向客户端返回大数据量，若数据量过大，应该考虑相应需求是否合理；
6. 尽量不要使用 `select * from t` ，用具体的字段列表代替`*`，不要返回用不到的任何字段，另外表结构发生变化也容易出现问题。

### 管理规范

1. 数据订正时，删除和修改记录时，要先select，避免出现误删除，确认无误才能提交执行；
2. 用户可以使用explain analyze查看实际的执行计划，但是如果需要查看的执行计划设计数据的变更，必须在事务中执行explain analyze，然后回滚；
3. 如何并行创建索引，不堵塞表的DML，创建索引时加CONCURRENTLY关键字，就可以并行创建，不会堵塞DML操作，否则会堵塞DML操作；（create index CONCURRENTLY idx on tbl(id); ）
4. 为数据库访问账号设置复杂密码；
5. 业务系统，开发测试账号，不要使用数据库超级用户，非常危险；
6. 应该为每个业务分配不同的数据库账号，禁止多个业务共用一个数据库账号；
7. 大批量数据入库的优化，如果有大批量的数据入库，建议使用copy语法，或者 insert into table values (),(),…(); 的方式，提高写入速度。

### 稳定性与性能规范

1. 游标使用后要及时关闭；
2. 两阶段提交的事务，要及时提交或回滚，否则可能导致数据库膨胀；
3. 不要使用delete 全表，性能很差，请使用truncate代替；
4. 应用程序一定要开启autocommit，同时避免应用程序自动begin事务，并且不进行任何操作的情况发生，某些框架可能会有这样的问题；
5. 在函数中，或程序中，不要使用count(*)判断是否有数据，很慢。 建议的方法是limit 1;
6. 必须选择合适的事务隔离级别，不要使用越级的隔离级别，例如READ COMMITTED可以满足时，就不要使用repeatable read和serializable隔离级别；
7. 高峰期对大表添加包含默认值的字段，会导致表的rewrite，建议只添加不包含默认值的字段，业务逻辑层面后期处理默认值；
8. 可以预估SQL执行时间的操作，建议设置语句级别的超时，可以防止雪崩，也可以防止长时间持锁；
9. PostgreSQL支持DDL事务，支持回滚DDL，建议将DDL封装在事务中执行，必要时可以回滚，但是需要注意事务的长度，避免长时间堵塞DDL对象的读操作；
10. 如果用户需要在插入数据和，删除数据前，或者修改数据后马上拿到插入或被删除或修改后的数据，建议使用insert into … returning …; delete … returning …或update … returning …; 语法。减少数据库交互次数；
11. 自增字段建议使用序列，序列分为2字节，4字节，8字节几种(serial2,serial4,serial8)。按实际情况选择。 禁止使用触发器产生序列值；
12. 使用窗口查询减少数据库和应用的交互次数；
13. 如何判断两个值是不是不一样（并且将NULL视为一样的值），使用col1 IS DISTINCT FROM col2；
14. 对于经常变更，或者新增，删除记录的表，应该尽量加快这种表的统计信息采样频率，获得较实时的采样，输出较好的执行计划。

### [说说MySQL与PostgreSQL之间的区别，该如何技术选型？](https://cloud.tencent.com/developer/article/1796238)

PostgreSQL相对于MySQL的优势

1. 在SQL的标准实现上要比MySQL完善，而且功能实现比较严谨；
2. 存储过程的功能支持要比MySQL好，具备本地缓存执行计划的能力；
3. 对表连接支持较完整，优化器的功能较完整，支持的索引类型很多，复杂查询能力较强；
4. PG主表采用堆表存放，MySQL采用索引组织表，能够支持比MySQL更大的数据量。
5. PG的主备复制属于物理复制，相对于MySQL基于binlog的逻辑复制，数据的一致性更加可靠，复制性能更高，对主机性能的影响也更小。
6. MySQL的存储引擎插件化机制，存在锁机制复杂影响并发的问题，而PG不存在。

MySQL相对于PG的优势

1. innodb的基于回滚段实现的MVCC机制，相对PG新老数据一起存放的基于XID的MVCC机制，是占优的。新老数据一起存放，需要定时触 发VACUUM，会带来多余的IO和数据库对象加锁开销，引起数据库整体的并发能力下降。而且VACUUM清理不及时，还可能会引发数据膨胀；
2. MySQL采用索引组织表，这种存储方式非常适合基于主键匹配的查询、删改操作，但是对表结构设计存在约束；
3. MySQL的优化器较简单，系统表、运算符、数据类型的实现都很精简，非常适合简单的查询操作；
4. MySQL分区表的实现要优于PG的基于继承表的分区实现，主要体现在分区个数达到上千上万后的处理性能差异较大。
5. MySQL的存储引擎插件化机制，使得它的应用场景更加广泛，比如除了innodb适合事务处理场景外，myisam适合静态数据的查询场景。

[PostgreSQL 与 MySQL — 关系数据库管理系统（RDBMS）之间的区别 — AWS](https://aws.amazon.com/cn/compare/the-difference-between-mysql-vs-postgresql/)

### 如何在 PostgreSQL 与 MySQL 之间做出选择

#### 应用范围

PostgreSQL 更适合具有频繁写入操作和复杂查询的企业级应用程序。

但是，如果想创建原型，创建用户较少的内部应用程序，或者创建具有更多读取次数和较少数据更新的信息存储引擎，则您可以启动 MySQL 项目。

#### 数据库开发经验

MySQL 更适合初学者，其学习曲线更短。从头开始构建新的数据库项目所需的时间更少。将 MySQL 设置为独立产品，或将其与其他 Web 开发技术（如 LAMP 堆栈）捆绑在一起很简单。

另一方面，PostgreSQL 对于新手来说可能更具挑战性。它通常需要复杂的基础设置设置和问题排查经验。

#### 性能要求

如果您的应用程序需要频繁更新数据，则 PostgreSQL 是更好的选择。但是，如果您需要频繁读取数据，则首选 MySQL。

写入性能：

MySQL 使用写锁定来实现真正的并发性。例如，如果一个用户正在编辑表，则另一个用户可能必须等到操作完成后才能更改该表。

但是，PostgreSQL 内置了多版本并发控制（MVCC）支持，没有读写锁定。这样，如果要进行频繁并发的写入操作，则 PostgreSQL 数据库的表现会更好。

读取性能：

PostgreSQL 会创建一个新的系统进程，为每个连接到数据库的用户分配大量内存（大约 10MB）。它需要内存密集型资源才能针对多个用户进行扩展。

另一方面，MySQL 为多个用户使用单一进程。因此，对于主要向用户读取和显示数据的应用程序，MySQL 数据库的表现优于 PostgreSQL。
