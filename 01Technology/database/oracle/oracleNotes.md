# Oracle notes

[Oracle Database 2 Day DBA](https://docs.oracle.com/en/database/oracle/oracle-database/19/admqs/introduction.html)

## oracle sqlplus

[SQL\*Plus Quick Start](https://docs.oracle.com/en/database/oracle/oracle-database/19/sqpug/SQL-Plus-quick-start.html)

```sh
# An example using an Easy Connection identifier to connect to the HR schema in the MYDB database running on mymachine is
sqlplus hr@\"//mymachine.mydomain:port/MYDB\"

# An example using a Net Service Name is:
sqlplus hr@MYDB

sqlplus username@connect_identifier
```

```sql
-- Connecting to a Different Database
connect username@connect_identifier

-- Lists all users/schemas in the database. Schemas are the owners of tables and other objects.
SELECT username FROM all_users ORDER BY username;
-- Shows the name of the currently connected database (or CDB/root container).
SELECT name FROM v$database;
-- To list all tables you own
SELECT table_name FROM user_tables ORDER BY table_name;
-- To list tables owned by a specific schema/user (e.g., 'HR') that you can access:
SELECT table_name FROM all_tables WHERE owner = 'HR' ORDER BY table_name;
-- To list all tables in the database (requires special privileges like DBA role or SELECT ANY DICTIONARY):
SELECT owner, table_name FROM dba_tables ORDER BY owner, table_name;

-- view column details for the view, EMP_DETAILS_VIEW
DESCRIBE EMP_DETAILS_VIEW

-- To create the HR tables from command-line SQL*Plus
@?/DEMO/SCHEMA/HUMAN_RESOURCES/HR_MAIN.SQL
-- rename the column headings
COLUMN FIRST_NAME HEADING "First Name"


-- Any Oracle Version (Unordered) Gets the first 5 tables encountered
SELECT table_name FROM all_tables WHERE ROWNUM <= 5;

-- Top 10 Most Highly Paid Employees
-- Get the top 10 most highly paid employees
SELECT first_name, last_name, salary FROM employees ORDER BY salary DESC FETCH FIRST 10 ROWS ONLY;

-- combination of OFFSET and FETCH for pagination
SELECT columns FROM table_name ORDER BY column_to_sort
OFFSET 20 ROWS        -- Skip the first 20 rows
FETCH NEXT 10 ROWS ONLY; -- Then return the next 10 rows
```

### Create New Pluggable Database (PDB)

[CREATE PLUGGABLE DATABASE](https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/CREATE-PLUGGABLE-DATABASE.html)

```sql
-- Check Current Container: Ensure you're in the CDB root.
SHOW CON_NAME;
-- Should return CDB$ROOT

-- Create the PDB
-- FILE_NAME_CONVERT: Specifies the directory conversion for the data files (adjust paths as necessary for your system).
CREATE PLUGGABLE DATABASE MYPDB ADMIN USER mypdb_admin IDENTIFIED BY "PdbAdmPass1" FILE_NAME_CONVERT = ('/pdbseed/', '/mypdb/');
-- Open the PDB: The new PDB is created in MOUNTED mode and must be opened for use.
ALTER PLUGGABLE DATABASE MYPDB OPEN;
-- Set PDB to open automatically on CDB startup (optional but recommended):
ALTER PLUGGABLE DATABASE MYPDB SAVE STATE;
```

### Create New User (Schema): APPUSER

```sql
-- To prevent errors like ORA-65096: invalid common user or role name, enable the _ORACLE_SCRIPT parameter:
-- ALTER SESSION SET "_ORACLE_SCRIPT"=true;
-- Connect to the New PDB: Change the current container to your new PDB (MYPDB).
ALTER SESSION SET CONTAINER = MYPDB;
-- Or, connect directly via SQL*Plus/SQL Developer using the PDB's service name.
SHOW CON_NAME;
-- Should return MYPDB

-- Create the User (Schema): APPUSER
CREATE USER APPUSER IDENTIFIED BY "AppUserPass1"
DEFAULT TABLESPACE users
TEMPORARY TABLESPACE temp
QUOTA UNLIMITED ON users;

-- Grant Essential Privileges
-- Allows the user to connect (log in) to the database
GRANT CREATE SESSION TO APPUSER;
-- Allows the user to create tables, views, sequences, procedures, etc.
GRANT RESOURCE TO APPUSER;
-- Allows the user to create a view
GRANT CREATE VIEW TO APPUSER;

-- GRANT CREATE SESSION TO admin;
-- GRANT CREATE TABLE TO admin;
-- GRANT CREATE TRIGGER TO admin;
-- GRANT CREATE SEQUENCE TO admin;
-- GRANT CREATE PROCEDURE TO admin;

-- Alternatively, for a power user (less recommended for application users):
GRANT CONNECT, RESOURCE, DBA TO APPUSER;

-- Set Storage Quota for the User, Limit the storage allocation on the USERS tablespace
ALTER USER APPUSER QUOTA 100M ON USERS;

-- Test the Connection: Disconnect and try to connect using the new user/password and the PDB's service name
-- Example in SQL*Plus/SQLcl
CONNECT APPUSER/"AppUserPass1"@//localhost:1521/mypdb
```

## deploy oracle 19c

[创建Oracle 数据库版本 19c 的 Docker 镜像](https://www.oracle.com/br/technical-resources/articles/database-performance/oracle-db19c-com-docker.html)
Running Oracle Database in a container [docker-images/OracleDatabase/SingleInstance/README.md at main · oracle/docker-images](https://github.com/oracle/docker-images/blob/main/OracleDatabase/SingleInstance/README.md)
[Oracle Database 19c Download for Linux x86-64 | Oracle Nederland](https://www.oracle.com/nl/database/technologies/oracle19c-linux-downloads.html)

[Oracle Database 19c - Install and Upgrade](https://docs.oracle.com/en/database/oracle/oracle-database/19/install-and-upgrade.html)
[Operating System Checklist for Oracle Database Installation on Linux](https://docs.oracle.com/en/database/oracle/oracle-database/19/ladbi/operating-system-checklist-for-oracle-database-installation-on-linux.html#GUID-E5C0A90E-7750-45D9-A8BC-C7319ED934F0)

```sh
# 下载适用于 Linux x86-64 的 Oracle Database 19c：http://www.oracle.com/technetwork/database/enterprise-edition/downloads/index.html
# 将LINUX.X64_193000_db_home.zip 文件复制到 docker-images/OracleDatabase/SingleInstance/dockerfiles/19.3.0 目录：
cp ~/Downloads/LINUX.X64_193000_db_home.zip docker-images/OracleDatabase/SingleInstance/dockerfiles/19.3.0
cd /data/workspace.3rd/docker-images/OracleDatabase/SingleInstance/dockerfiles
# 创建一个 Docker 镜像
./buildContainerImage.sh -v 19.3.0 -e
# oracle/database:19.3.0-ee

# ORACLE_SID: The Oracle Database SID that should be used (default for 23ai Free Edition: FREE; all others, ORCLCDB).
# 1521 端口 (Oracle Net Listener) 是 客户端连接数据库 的主端口
# 5500 端口 (OEM Express / Enterprise Manager) 是 Oracle 提供的基于 Web 的数据库管理界面 https://localhost:5500/em/shell。您可以通过浏览器访问它，进行数据库的日常管理、性能监控、用户和表空间管理等操作。
# 2484 端口 (Oracle Connection Manager / CMAN) 用于支持 Secure Sockets Layer (SSL) / TLS 加密连接 的特定传输协议（如 MTS）。

mkdir -p /data/docker/oracle-19c/
sudo chown -R 54321:54321 /data/docker/oracle-19c/
docker run -d \
    --name oracle-db \
    -p 1521:1521 -p 5500:5500 \
    -e ORACLE_SID=ORCLCDB -e ORACLE_PDB=ORCLPDB1 \
    -e ORACLE_PWD=password \
    -e ORACLE_CHARACTERSET=AL32UTF8 \
    -v /data/docker/oracle-19c/oradata/:/opt/oracle/oradata \
    oracle/database:19.3.0-ee

# ORACLE PASSWORD FOR SYS, SYSTEM AND PDBADMIN: password
# sqlplus sys/<your password>@//localhost:1521/<your service name> as sysdba
# sqlplus system/<your password>@//localhost:1521/<your service name>
# sqlplus pdbadmin/<your password>@//localhost:1521/<Your PDB name>
alias sqlplus="docker exec -i oracle-db sqlplus"

sqlplus sys/password@//localhost:1521/ORCLCDB as sysdba
sqlplus system/password@//localhost:1521/ORCLCDB
sqlplus pdbadmin/password@//localhost:1521/ORCLPDB1
```
