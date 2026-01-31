# sqlite notes

```sh
sqlite3 /tmp/meta.db "CREATE TABLE dynamic_sources (code TEXT, type TEXT, host TEXT, port INTEGER, database TEXT, username TEXT, password_encrypted TEXT, status TEXT);"
sqlite3 /tmp/meta.db "SELECT * FROM sources;"
sqlite3 /tmp/meta.db "INSERT INTO sources VALUES ('dynamic1', 'sqlite', 'localhost', 0, '/tmp/dynamic1.db', 'user', 'password', 'active');"
sqlite3 /tmp/meta.db "INSERT INTO sources VALUES ('dynamic2', 'sqlite', '', 0, '/tmp/dynamic2.db', 'user2', 'pass2', 'active');"
sqlite3 /tmp/meta.db "UPDATE sources SET host='localhost', port=1 WHERE code='dynamic1';"
sqlite3 /tmp/meta.db "DELETE FROM sources;"

sqlite3 /tmp/dynamic1.db "VACUUM;"
```

sql

```sql
.database
.tables
.headers on
.mode csv
.output /tmp/test.csv
SELECT * FROM test;
```
