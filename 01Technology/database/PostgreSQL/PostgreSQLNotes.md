# PostgreSQL Notes

[PostgreSQL 16.3 Documentation](https://www.postgresql.org/docs/16/index.html)
[PostgreSQL 中文社区 15.7 手册](http://www.postgres.cn/docs/15/index.html)
[PostgreSQL 教程 | 菜鸟教程](https://www.runoob.com/postgresql/postgresql-tutorial.html)

## Research

[PostgreSQL 与 MySQL 相比，优势何在？ - 知乎](https://www.zhihu.com/question/20010554)
[PGXN: PostgreSQL Extension Network](https://pgxn.org/)

## 控制台命令

```sh
psql --help

-- 连接数据库 -U 指定用户，-d 指定数据库，-h 指定服务器，-p 指定端口
psql -h localhost -p 5432 -U postgres --password
PGPASSWORD=<password> psql -h localhost -p 5432 -U <username>

Connection options:
  -h, --host=HOSTNAME      database server host or socket directory (default: "local socket")
  -p, --port=PORT          database server port (default: "5432")
  -U, --username=USERNAME  database user name (default: "root")
  -w, --no-password        never prompt for password
  -W, --password           force password prompt (should happen automatically)
  -f /path/to/sql
```

* \password dbuser 命令（设置密码）和\q命令（退出）
* \h 查看SQL命令的解释，比如\h select。
* \? 查看psql命令列表。
* \l 列出所有数据库。
* \x Expanded display 类似 MySQL \G
* \c [database_name] 连接其他数据库。
* \d 列出当前数据库的所有表格。
* \dt #列出数据库中所有表
* \d [table_name] 列出表结构
* \di 列出数据库中所有 index
* \dv 列出数据库中所有 view \dv *.*
* \d+ pg_roles 查看 view 定义
* \dp     [PATTERN]      list table, view, and sequence access privileges
* \sv pg_roles 查看 view 定义, \sv+ 展示行号
* \du 列出所有用户。
* \encoding #显示字符集
* \i path/to/sql #执行sql文件
* \x #扩展展示结果信息，相当于MySQL的\G
* \e 打开文本编辑器。
* \conninfo 列出当前数据库和连接的信息。
* \timing 开启显示执行时间 或者 `time psql -P pager=off -c 'SELECT ...' >outfile`

`pg_ctl restart` restart db

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

-- 序号类型SERIAL和BIGSERIAL并不是真正的类型， 只是为在表中设置唯一标识做的概念上的便利。在目前的实现中，下面一句话：
CREATE TABLE tablename (colname SERIAL);
-- 等价于
CREATE SEQUENCE tablename_colname_seq;
CREATE TABLE tablename(
    colname integer DEFAULT nextval('tablename_colname_seq') NOT NULL
);

-- 根据已有表结构创建表
create table if not exists 新表 (like 旧表 including indexes including comments including defaults);
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

-- [PostgreSQL: Documentation: 8.0: ALTER USER](https://www.postgresql.org/docs/8.0/sql-alteruser.html)
-- 设置超级用户
ALTER ROLE dbuser SUPERUSER CREATEDB CREATEROLE INHERIT LOGIN NOREPLICATION NOBYPASSRLS;
-- 设置只读权限
alter user 用户名 set default_transaction_read_only = on;
-- 密码有效期 仅针对客户端有效，服务器端不受限制
alter role dbuser valid until '2022-12-31 23:59:59';
alter role dbuser PASSWORD 'password';

-- 用户加入到指定的用户组
--将pgadmin加入到admin组
alter group admin add user pgadmin;
--将 dbuser 加入到developer组
alter group developer add user dbuser;

-- 撤回在public模式下的权限
revoke select on all tables in schema public from 用户名;

-- 撤回在information_schema模式下的权限
revoke select on all tables in schema information_schema from 用户名;

-- 撤回在pg_catalog模式下的权限
revoke select on all tables in schema pg_catalog from 用户名;
--任何用户都拥有public模式的所有权限
--出于安全，回收任何用户在public的create权限
revoke create on schema public from public;

-- 撤回对数据库的操作权限
revoke all on database 数据库名 from 用户名;

-- 删除用户
drop user 用户名;

SELECT * FROM pg_roles;

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
   WHERE grantee = 'YOUR_USER';
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
       WHERE e.usename = 'YOUR_USER';

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

## 安装和配置管理

[PostgreSQL 数据库日志与日常巡检](https://cloud.tencent.com/developer/article/2315309)

```sql
-- 异常处理：杀连接；
select pg_terminate_backend(pid);
-- 查看最新加载配置的时间
select pg_conf_load_time();
```

### 获取数据大小

```sql
-- 查看数据库表大小
select pg_database_size('playboy');
-- 1、查询执行数据库大小
select pg_size_pretty (pg_database_size('db_product'));
-- 2、查询数据库实例当中各个数据库大小
select datname, pg_size_pretty (pg_database_size(datname)) AS size from pg_database;
-- 3、查询单表数据大小
select pg_size_pretty(pg_relation_size('product')) as size;
-- 4、查询数据库表包括索引的大小
select pg_size_pretty(pg_total_relation_size('table_name')) as size;
-- 5、查看表中索引大小
select pg_size_pretty(pg_indexes_size('product'));
-- 6、获取各个表中的数据记录数
select relname as TABLE_NAME, reltuples as rowCounts from pg_class where relkind = 'r' order by rowCounts desc
-- 7、查看数据库表对应的数据文件
select pg_relation_filepath('product');
```

### 参数级别

[PostgreSQL Parameters: Scope and Priority Users Should Know](https://www.percona.com/blog/postgresql-parameters-scope-and-priority-users-should-know/)

[How Can I Take a Backup of Configuration Files in PostgreSQL?](https://www.percona.com/blog/how-can-i-take-a-backup-of-configuration-files-in-postgresql/)

#### 1. Compile time parameter settings

These compile time settings have the least priority and can be overridden in any other levels. However, some of these parameters cannot be modified by any other means.

```sql
select name,boot_val from pg_settings;
```

 If a PostgreSQL user wants to change these values, they need to recompile the PostgreSQL from the source code. Some are exposed through the configure command line option. Some such configuration options are:  `--with-blocksize=<BLOCKSIZE>`    This sets table block size in kB. The default is 8kb.  `--with-segsize=<SEGSIZE>`  This sets table segment size in GB. The default is 1GB. This means PostgreSQL creates a new file in the data directory as the table size exceeds 1GB.   `--with-wal-blocksize=<BLOCKSIZE>`   sets WAL block size in kB, and the default is 8kB.

#### 2. Data directory/initialization-specific parameter settings

Parameters can also be specified at the data directory initialization time.  Some of these parameters cannot be changed by other means or are difficult to change.

```sql
select name,setting from pg_settings where source='override';
```

For example, the wal_segment_size, which determines the WAL segment file, is such a parameter. PostgreSQL generates WAL segment files of 16MB by default, and it can be specified at the time of initialization only.

#### 3. PostgreSQL parameters set by environment variables

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

#### 4. Configuration files

This is probably the method every novice user will be aware of. The fundamental PostgreSQL configuration file is postgresql.conf, and it is the most common place to have global settings. PostgreSQL looks for a configuration file in the PGDATA by default, but an alternate location can be specified using the command line parameter config_file  of postmaster.  The parameter specifications can be split into multiple files and directories because Postgresql supports include and  include_dir directives in the configuration files. So, there can be nested/cascaded configurations.

PostgreSQL rereads all its configuration files if it receives a SIGHUP signal. If the same parameter is set in multiple locations, the last to read will be will be considered. Among all configuration files, postgresql.auto.conf gets the highest priority because that is the file to read the last. That is where all “ALTER SYSTEM SET/RESET” commands keep the information.

#### 5. Command line argument to postmaster

```sql
select name,setting from pg_settings where source='command line';
```

#### 6. Database level setting

```sql
ALTER DATABASE newdb SET max_parallel_workers_per_gather = 4;
```

#### 7. User-level settings

```sql
select name,setting,source,context from pg_settings where  source='user';
```

#### 8. Database – user combination

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

#### 9. Parameters by the client connection request

There is an option to specify parameters while making a new connection. It can be passed to PostgreSQL as part of the connection string.

For example, I want to connect to the database to perform some bulk data loading and manipulation (ETL), and I don’t want to wait for any WAL writing. If, at all, there is any crash in between, I am OK to perform the ETL again. So, I am going to request a connection with synchronous_commit  off.

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

#### 10. Session-level setting

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

#### 11. Transaction-level settings

PostgreSQL allows us to specify parameters at a very small scope, like transaction level.

```sql
postgres=# BEGIN;
BEGIN
postgres=*# SET LOCAL enable_seqscan=off;
SET
```

#### 12. Object-level settings

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

导出数据到SQL文件

```sql
pg_dump -h localhost -p 5432 -U postgres --column-inserts -t table_name -f save_sql.sql database_name
pg_dump -h localhost -p 5432 -U postgres --column-inserts -t table_name -f save_sql.sql database_name
-- 备份postgres库并tar打包
pg_dump -h 127.0.0.1 -p 5432 -U postgres -f postgres.sql.tar -Ft
```

1. `--column-inserts` #以带有列名的 `INSERT` 命令形式转储数据。This will make restoration very slow; it is mainly useful for making dumps that can be loaded into non-PostgreSQL databases.
2. `-t` --只转储指定名称的表。
3. `-f` --指定输出文件或目录名
4. `-F` format, --format=format Selects the format of the output. format can be one of the following:
    1. `p`, plain: Output a plain-text SQL script file (the default).
    2. `c`, custom Output a custom-format archive suitable for input into pg_restore.
    3. `t`, tar Output a tar-format archive suitable for input into pg_restore.
5. `-c, --clean` Output commands to DROP all the dumped database objects prior to outputting the commands for creating them.
6. `-C, --create` create the database itself and reconnect to the created database
7. `--if-exists` Use `DROP ... IF EXISTS` commands to drop objects in `--clean` mode
8. `-t pattern, --table=pattern` Dump only tables with names matching pattern.
9. `-T pattern, --exclude-table=pattern` Do not dump any tables matching pattern.
10. `-O, --no-owner` Do not output commands to set ownership of objects to match the original database.
11. `-s, --schema-only` Dump only the object definitions (schema), not data.

#### 逻辑备份与恢复

```sql
su - postgres
-- 先备份全局对象
pg_dumpall -f backup.sql --globals-only
-- 再备份数据库
pg_dump databaseName -Fc > databaseName.dump


-- 逻辑恢复
su - postgres
-- #先恢复全局对象
psql
-- \i FILE  execute commands from file
\i backup.sql
--创建对应的数据库
create database databaseName;
\q

-- #pg_restore进行恢复
pg_restore -d databaseName databaseName.dump -v

-- To reload an archive file into the same database it was dumped from, discarding the current contents of that database:
pg_restore -d ems_test --clean --create db.dump
```

#### 物理备份与恢复

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

### PostgreSQL 主从同步

[进阶数据库系列（十五）：PostgreSQL 主从同步原理与实践-腾讯云开发者社区-腾讯云](https://cloud.tencent.com/developer/article/2315296)

#### PostgreSQL 预写日志机制（Write-Ahead Logging，WAL）

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

#### 主从复制

1. 基于文件的日志传送：直接从一个数据库服务器移动 WAL 记录到另一台服务器
   1. PostgreSQL 通过一次一文件（WAL段）的WAL记录传输实现了基于文件的日志传送。
   2. 日志传送所需的带宽取根据主服务器的事务率而变化；
   3. 日志传送是异步的，即WAL记录是在事务提交后才被传送
   4. 数据丢失窗口可以通过使用参数archive_timeout进行限制，可以低至数秒，但同时会增加文件传送所需的带宽。
2. 流复制，PostgreSQL 在9.x之后引入，就是备服务器通过tcp流从主服务器中同步相应的数据，主服务器在WAL记录产生时即将它们以流式传送给备服务器，而不必等到WAL文件被填充。
   1. 默认情况下流复制是异步的，这种情况下主服务器上提交一个事务与该变化在备服务器上变得可见之间客观上存在短暂的延迟，但这种延迟相比基于文件的日志传送方式依然要小得多，在备服务器的能力满足负载的前提下延迟通常低于一秒；
   2. 在流复制中，备服务器比使用基于文件的日志传送具有更小的数据丢失窗口，不需要采用archive_timeout来缩减数据丢失窗口；
   3. 将一个备服务器从基于文件日志传送转变成基于流复制的步骤是：把recovery.conf文件中的primary_conninfo设置指向主服务器；设置主服务器配置文件的listen_addresses参数与认证文件即可。

## Performance

[PostgreSQL 16: Chapter 14. Performance Tips](https://www.postgresql.org/docs/16/performance-tips.html)
[Introduction to PostgreSQL Performance Tuning | EDB](https://www.enterprisedb.com/postgres-tutorials/introduction-postgresql-performance-tuning-and-optimization)

### 索引

[PostgreSQL 索引技术详解](https://cloud.tencent.com/developer/article/2315287)
[PostgreSQL 16: 73.6. Database Page Layout](https://www.postgresql.org/docs/current/storage-page-layout.html)

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
    ,b.rolname "username(用户名)"
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

```sql
-- 查询最耗时的5个sql  需要开启pg_stat_statements
select * from pg_stat_statements order by total_time desc limit 5;

-- 获取执行时间最慢的3条SQL，并给出CPU占用比例SELECT substring(query, 1, 1000) AS short_query,
round(total_time::numeric, 2) AS total_time,
calls,
round((100 * total_time / sum(total_time::numeric) OVER ())::numeric, 2) AS percentage_cpu
FROM pg_stat_statements
ORDER BY total_time DESC
LIMIT 3;

-- 6、分析评估SQL执行情况
EXPLAIN ANALYZE SELECT * FROM product

-- 7、查看当前长时间执行却不结束的SQL
select datname, usename, client_addr, application_name, state, backend_start, xact_start, xact_stay, query_start, query_stay, replace(query, chr(10), ' ') as query from (select pgsa.datname as datname, pgsa.usename as usename, pgsa.client_addr client_addr, pgsa.application_name as application_name, pgsa.state as state, pgsa.backend_start as backend_start, pgsa.xact_start as xact_start, extract(epoch from (now() - pgsa.xact_start)) as xact_stay, pgsa.query_start as query_start, extract(epoch from (now() - pgsa.query_start)) as query_stay , pgsa.query as query from pg_stat_activity as pgsa where pgsa.state != 'idle' and pgsa.state != 'idle in transaction' and pgsa.state != 'idle in transaction (aborted)') idleconnections order by query_stay desc limit 5;

-- 8、查出使用表扫描最多的表
select * from pg_stat_user_tables where n_live_tup > 100000 and seq_scan > 0 order by seq_tup_read desc limit 10;
-- 9、查询读取buffer最多的5个SQL
select * from pg_stat_statements order by shared_blks_hit+shared_blks_read desc limit 5;

-- 查询访问指定表的慢查询
select * from pg_stat_activity where query ilike '%<table_name>%' and query_start - now() > interval '10 seconds';

-- 查看当前wal的buffer中有多少字节未写入磁盘
select pg_xlog_location_diff(pg_current_xlog_insert_location(),pg_current_xlog_location());
```

### PostgreSQL 系统参数

[Exploring PostgreSQL Performance Tuning Parameters](https://www.percona.com/blog/tuning-postgresql-database-parameters-to-optimize-performance/)
[PostgreSQL 性能优化](https://cloud.tencent.com/developer/article/2315307)

注意：并非所有参数都适用于所有应用程序类型。某些应用程序通过调整参数可以提高性能，有些则不会。必须针对应用程序及操作系统的特定需求来调整数据库参数。

`show all;` 列出所有参数

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

#### 一份参数文件

[PostgreSQL 性能优化](https://cloud.tencent.com/developer/article/2315307)

```sh
max_connections = 300       #(change requires restart)

unix_socket_directories = '.'   #comma-separated list of directories

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
```

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

### 查看阻塞的 SQL

[进阶数据库系列（八）：PostgreSQL 锁机制-腾讯云开发者社区-腾讯云](https://cloud.tencent.com/developer/article/2315270)

`SELECT pg_cancel_backend(pid);` – session还在，事务回退;
`SELECT pg_terminate_backend(pid);` --session消失，事务回退

查看阻塞会话，类似MySQL的 show processlist，并生成 kill sql

examine the `pg_stat_activity` view; you should see some long running transactions.

```sql
-- 查看阻塞会话，并生成kill sql
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
 case when a0.depth =1 then 'select cancel_backend('|| a0.id || ');' else null end  as cancel_pid
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
```

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
3. 查询中的别名不要使用 “小写字母，下划线，数字” 以外的字符，例如中文;
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
15. 当用户有prefix或者 suffix的模糊查询需求时，可以使用索引，或反转索引达到提速的需求；（select * from tbl where reverse(col) ~ ‘^def’; – 后缀查询使用反转函数索引）
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
