# MySQL Lock test

需要关闭自动提交，通过set @@autocommit=0; 设置为手动提交。0代表手动提交，1代表自动提交。

CREATE TABLE y(a varchar(4),b varchar(4),PRIMARY KEY(a),KEY(b));
select * from y;
INSERT INTO y SELECT "a","a";
INSERT INTO y SELECT "c","a";
INSERT INTO y SELECT "e","c";
INSERT INTO y SELECT "g","f";

mysql> select * from y;
+---+------+
| a | b    |
+---+------+
| a | a    |
| c | a    |
| e | c    |
| g | f    |
+---+------+
BEGIN;
SELECT*FROM y WHERE b="c" FOR UPDATE;

  INSERT INTO y select "d","b";
  INSERT INTO y select "d","a";
  INSERT INTO y select "b","a";


ERROR 1317 (70100): Query execution was interrupted
mysql>   INSERT INTO y select "d","c";
^C^C -- query aborted
mysql> SELECT * FROM information_schema.INNODB_LOCKS;
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
| lock_id        | lock_trx_id | lock_mode | lock_type | lock_table | lock_index | lock_space | lock_page | lock_rec | lock_data |
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
| 963953:257:4:4 | 963953      | X,GAP     | RECORD    | `live`.`y` | b          |        257 |         4 |        4 | 'c', 'e'  |
| 963947:257:4:4 | 963947      | X         | RECORD    | `live`.`y` | b          |        257 |         4 |        4 | 'c', 'e'  |
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
2 rows in set (0.02 sec)


ERROR 1317 (70100): Query execution was interrupted
mysql>   INSERT INTO y select "f","c";
mysql> SELECT * FROM information_schema.INNODB_LOCKS;
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
| lock_id        | lock_trx_id | lock_mode | lock_type | lock_table | lock_index | lock_space | lock_page | lock_rec | lock_data |
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
| 963953:257:4:5 | 963953      | X,GAP     | RECORD    | `live`.`y` | b          |        257 |         4 |        5 | 'f', 'g'  |
| 963947:257:4:5 | 963947      | X,GAP     | RECORD    | `live`.`y` | b          |        257 |         4 |        5 | 'f', 'g'  |
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+

mysql> select version();
+-----------+
| version() |
+-----------+
| 5.6.49    |
+-----------+

CREATE TABLE z(a INT,b INT,PRIMARY KEY(a),KEY(b));
select * from z;
INSERT INTO z SELECT 1,1;
INSERT INTO z SELECT 3,1;
INSERT INTO z SELECT 5,3;
INSERT INTO z SELECT 7,6;

mysql> select * from z;
+----+------+
| a  | b    |
+----+------+
|  1 |    1 |
|  3 |    1 |
|  5 |    3 |
|  7 |    6 |
+----+------+
BEGIN;
SELECT*FROM z WHERE b=3 FOR UPDATE;

  BEGIN;
  INSERT INTO z select 6,1;


GAP 锁

mysql> INSERT INTO z select 2,0;
Query OK, 1 row affected (0.02 sec)
Records: 1  Duplicates: 0  Warnings: 0
mysql> INSERT INTO z select 2,1;
Query OK, 1 row affected (0.02 sec)
Records: 1  Duplicates: 0  Warnings: 0

mysql> INSERT INTO z select 2,2;
mysql> SELECT * FROM information_schema.INNODB_LOCKS;
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
| lock_id        | lock_trx_id | lock_mode | lock_type | lock_table | lock_index | lock_space | lock_page | lock_rec | lock_data |
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
| 963986:251:4:4 | 963986      | X,GAP     | RECORD    | `live`.`z` | b          |        251 |         4 |        4 | 3, 5      |
| 963980:251:4:4 | 963980      | X,GAP     | RECORD    | `live`.`z` | b          |        251 |         4 |        4 | 3, 5      |
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
mysql> INSERT INTO z select 2,3;
mysql> SELECT * FROM information_schema.INNODB_LOCKS;
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
| lock_id        | lock_trx_id | lock_mode | lock_type | lock_table | lock_index | lock_space | lock_page | lock_rec | lock_data |
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
| 963981:251:4:4 | 963981      | X,GAP     | RECORD    | `live`.`z` | b          |        251 |         4 |        4 | 3, 5      |
| 963980:251:4:4 | 963980      | X,GAP     | RECORD    | `live`.`z` | b          |        251 |         4 |        4 | 3, 5      |
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
mysql> INSERT INTO z select 2,4;
mysql> SELECT * FROM information_schema.INNODB_LOCKS;
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
| lock_id        | lock_trx_id | lock_mode | lock_type | lock_table | lock_index | lock_space | lock_page | lock_rec | lock_data |
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
| 963986:251:4:5 | 963986      | X,GAP     | RECORD    | `live`.`z` | b          |        251 |         4 |        5 | 6, 7      |
| 963980:251:4:5 | 963980      | X,GAP     | RECORD    | `live`.`z` | b          |        251 |         4 |        5 | 6, 7      |
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
mysql> INSERT INTO z select 2,5;
mysql> SELECT * FROM information_schema.INNODB_LOCKS;
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
| lock_id        | lock_trx_id | lock_mode | lock_type | lock_table | lock_index | lock_space | lock_page | lock_rec | lock_data |
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
| 963986:251:4:5 | 963986      | X,GAP     | RECORD    | `live`.`z` | b          |        251 |         4 |        5 | 6, 7      |
| 963980:251:4:5 | 963980      | X,GAP     | RECORD    | `live`.`z` | b          |        251 |         4 |        5 | 6, 7      |
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
mysql> INSERT INTO z select 2,6;
mysql> SELECT * FROM information_schema.INNODB_LOCKS;
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
| lock_id        | lock_trx_id | lock_mode | lock_type | lock_table | lock_index | lock_space | lock_page | lock_rec | lock_data |
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
| 963986:251:4:5 | 963986      | X,GAP     | RECORD    | `live`.`z` | b          |        251 |         4 |        5 | 6, 7      |
| 963980:251:4:5 | 963980      | X,GAP     | RECORD    | `live`.`z` | b          |        251 |         4 |        5 | 6, 7      |
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
mysql> INSERT INTO z select 2,7;
Query OK, 1 row affected (0.01 sec)
Records: 1  Duplicates: 0  Warnings: 0




mysql> INSERT INTO z select 4,0;
Query OK, 1 row affected (0.01 sec)
Records: 1  Duplicates: 0  Warnings: 0
mysql> INSERT INTO z select 4,1;
mysql> SELECT * FROM information_schema.INNODB_LOCKS;
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
| lock_id        | lock_trx_id | lock_mode | lock_type | lock_table | lock_index | lock_space | lock_page | lock_rec | lock_data |
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
| 963972:251:4:4 | 963972      | X,GAP     | RECORD    | `live`.`z` | b          |        251 |         4 |        4 | 3, 5      |
| 963955:251:4:4 | 963955      | X         | RECORD    | `live`.`z` | b          |        251 |         4 |        4 | 3, 5      |
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
mysql> INSERT INTO z select 4,2;
mysql> SELECT * FROM information_schema.INNODB_LOCKS;
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
| lock_id        | lock_trx_id | lock_mode | lock_type | lock_table | lock_index | lock_space | lock_page | lock_rec | lock_data |
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
| 963972:251:4:4 | 963972      | X,GAP     | RECORD    | `live`.`z` | b          |        251 |         4 |        4 | 3, 5      |
| 963955:251:4:4 | 963955      | X         | RECORD    | `live`.`z` | b          |        251 |         4 |        4 | 3, 5      |
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
mysql> INSERT INTO z select 4,3;
mysql> SELECT * FROM information_schema.INNODB_LOCKS;
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
| lock_id        | lock_trx_id | lock_mode | lock_type | lock_table | lock_index | lock_space | lock_page | lock_rec | lock_data |
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
| 963972:251:4:4 | 963972      | X,GAP     | RECORD    | `live`.`z` | b          |        251 |         4 |        4 | 3, 5      |
| 963955:251:4:4 | 963955      | X         | RECORD    | `live`.`z` | b          |        251 |         4 |        4 | 3, 5      |
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
mysql> INSERT INTO z select 4,4;
mysql> SELECT * FROM information_schema.INNODB_LOCKS;
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
| lock_id        | lock_trx_id | lock_mode | lock_type | lock_table | lock_index | lock_space | lock_page | lock_rec | lock_data |
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
| 963972:251:4:5 | 963972      | X,GAP     | RECORD    | `live`.`z` | b          |        251 |         4 |        5 | 6, 7      |
| 963955:251:4:5 | 963955      | X,GAP     | RECORD    | `live`.`z` | b          |        251 |         4 |        5 | 6, 7      |
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
mysql> INSERT INTO z select 4,5;
mysql> SELECT * FROM information_schema.INNODB_LOCKS;
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
| lock_id        | lock_trx_id | lock_mode | lock_type | lock_table | lock_index | lock_space | lock_page | lock_rec | lock_data |
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
| 963972:251:4:5 | 963972      | X,GAP     | RECORD    | `live`.`z` | b          |        251 |         4 |        5 | 6, 7      |
| 963955:251:4:5 | 963955      | X,GAP     | RECORD    | `live`.`z` | b          |        251 |         4 |        5 | 6, 7      |
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
mysql> INSERT INTO z select 4,6;
mysql> SELECT * FROM information_schema.INNODB_LOCKS;
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
| lock_id        | lock_trx_id | lock_mode | lock_type | lock_table | lock_index | lock_space | lock_page | lock_rec | lock_data |
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
| 963972:251:4:5 | 963972      | X,GAP     | RECORD    | `live`.`z` | b          |        251 |         4 |        5 | 6, 7      |
| 963955:251:4:5 | 963955      | X,GAP     | RECORD    | `live`.`z` | b          |        251 |         4 |        5 | 6, 7      |
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
mysql> INSERT INTO z select 4,7;
Query OK, 1 row affected (0.03 sec)
Records: 1  Duplicates: 0  Warnings: 0


mysql> INSERT INTO z select 6,0;
Query OK, 1 row affected (0.03 sec)
Records: 1  Duplicates: 0  Warnings: 0

INSERT INTO z select 6,1;
mysql> SELECT * FROM information_schema.INNODB_LOCKS;
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
| lock_id        | lock_trx_id | lock_mode | lock_type | lock_table | lock_index | lock_space | lock_page | lock_rec | lock_data |
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
| 963603:251:4:4 | 963603      | X,GAP     | RECORD    | `live`.`z` | b          |        251 |         4 |        4 | 3, 5      |
| 963602:251:4:4 | 963602      | X         | RECORD    | `live`.`z` | b          |        251 |         4 |        4 | 3, 5      |
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
INSERT INTO z select 6,2;
mysql> SELECT * FROM information_schema.INNODB_LOCKS;
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
| lock_id        | lock_trx_id | lock_mode | lock_type | lock_table | lock_index | lock_space | lock_page | lock_rec | lock_data |
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
| 963959:251:4:4 | 963959      | X,GAP     | RECORD    | `live`.`z` | b          |        251 |         4 |        4 | 3, 5      |
| 963955:251:4:4 | 963955      | X         | RECORD    | `live`.`z` | b          |        251 |         4 |        4 | 3, 5      |
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
INSERT INTO z select 6,3;
mysql> SELECT * FROM information_schema.INNODB_LOCKS;
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
| lock_id        | lock_trx_id | lock_mode | lock_type | lock_table | lock_index | lock_space | lock_page | lock_rec | lock_data |
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
| 963957:251:4:5 | 963957      | X,GAP     | RECORD    | `live`.`z` | b          |        251 |         4 |        5 | 6, 7      |
| 963955:251:4:5 | 963955      | X,GAP     | RECORD    | `live`.`z` | b          |        251 |         4 |        5 | 6, 7      |
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
INSERT INTO z select 6,4;
mysql> SELECT * FROM information_schema.INNODB_LOCKS;
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
| lock_id        | lock_trx_id | lock_mode | lock_type | lock_table | lock_index | lock_space | lock_page | lock_rec | lock_data |
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
| 963958:251:4:5 | 963958      | X,GAP     | RECORD    | `live`.`z` | b          |        251 |         4 |        5 | 6, 7      |
| 963955:251:4:5 | 963955      | X,GAP     | RECORD    | `live`.`z` | b          |        251 |         4 |        5 | 6, 7      |
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
mysql> INSERT INTO z select 6,5;
mysql> SELECT * FROM information_schema.INNODB_LOCKS;
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
| lock_id        | lock_trx_id | lock_mode | lock_type | lock_table | lock_index | lock_space | lock_page | lock_rec | lock_data |
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
| 963960:251:4:5 | 963960      | X,GAP     | RECORD    | `live`.`z` | b          |        251 |         4 |        5 | 6, 7      |
| 963955:251:4:5 | 963955      | X,GAP     | RECORD    | `live`.`z` | b          |        251 |         4 |        5 | 6, 7      |
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
mysql> INSERT INTO z select 6,6;
mysql> SELECT * FROM information_schema.INNODB_LOCKS;
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
| lock_id        | lock_trx_id | lock_mode | lock_type | lock_table | lock_index | lock_space | lock_page | lock_rec | lock_data |
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
| 963961:251:4:5 | 963961      | X,GAP     | RECORD    | `live`.`z` | b          |        251 |         4 |        5 | 6, 7      |
| 963955:251:4:5 | 963955      | X,GAP     | RECORD    | `live`.`z` | b          |        251 |         4 |        5 | 6, 7      |
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+

mysql> INSERT INTO z select 6,7;
Query OK, 1 row affected (0.01 sec)
Records: 1  Duplicates: 0  Warnings: 0


mysql> INSERT INTO z select 8,0;
Query OK, 1 row affected (0.01 sec)
Records: 1  Duplicates: 0  Warnings: 0

mysql> INSERT INTO z select 8,1;
mysql> SELECT * FROM information_schema.INNODB_LOCKS;
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
| lock_id        | lock_trx_id | lock_mode | lock_type | lock_table | lock_index | lock_space | lock_page | lock_rec | lock_data |
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
| 963988:251:4:4 | 963988      | X,GAP     | RECORD    | `live`.`z` | b          |        251 |         4 |        4 | 3, 5      |
| 963980:251:4:4 | 963980      | X,GAP     | RECORD    | `live`.`z` | b          |        251 |         4 |        4 | 3, 5      |
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
mysql> INSERT INTO z select 8,2;
mysql> SELECT * FROM information_schema.INNODB_LOCKS;
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
| lock_id        | lock_trx_id | lock_mode | lock_type | lock_table | lock_index | lock_space | lock_page | lock_rec | lock_data |
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
| 963989:251:4:4 | 963989      | X,GAP     | RECORD    | `live`.`z` | b          |        251 |         4 |        4 | 3, 5      |
| 963980:251:4:4 | 963980      | X,GAP     | RECORD    | `live`.`z` | b          |        251 |         4 |        4 | 3, 5      |
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
mysql> INSERT INTO z select 8,3;
mysql> SELECT * FROM information_schema.INNODB_LOCKS;
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
| lock_id        | lock_trx_id | lock_mode | lock_type | lock_table | lock_index | lock_space | lock_page | lock_rec | lock_data |
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
| 963990:251:4:5 | 963990      | X,GAP     | RECORD    | `live`.`z` | b          |        251 |         4 |        5 | 6, 7      |
| 963980:251:4:5 | 963980      | X,GAP     | RECORD    | `live`.`z` | b          |        251 |         4 |        5 | 6, 7      |
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
mysql> INSERT INTO z select 8,4;
mysql> SELECT * FROM information_schema.INNODB_LOCKS;
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
| lock_id        | lock_trx_id | lock_mode | lock_type | lock_table | lock_index | lock_space | lock_page | lock_rec | lock_data |
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
| 963991:251:4:5 | 963991      | X,GAP     | RECORD    | `live`.`z` | b          |        251 |         4 |        5 | 6, 7      |
| 963980:251:4:5 | 963980      | X,GAP     | RECORD    | `live`.`z` | b          |        251 |         4 |        5 | 6, 7      |
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
mysql> INSERT INTO z select 8,5;
mysql> SELECT * FROM information_schema.INNODB_LOCKS;
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
| lock_id        | lock_trx_id | lock_mode | lock_type | lock_table | lock_index | lock_space | lock_page | lock_rec | lock_data |
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
| 963992:251:4:5 | 963992      | X,GAP     | RECORD    | `live`.`z` | b          |        251 |         4 |        5 | 6, 7      |
| 963980:251:4:5 | 963980      | X,GAP     | RECORD    | `live`.`z` | b          |        251 |         4 |        5 | 6, 7      |
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+

mysql> INSERT INTO z select 8,6;
Query OK, 1 row affected (0.02 sec)
Records: 1  Duplicates: 0  Warnings: 0



偶尔出现主键锁
mysql> SELECT * FROM information_schema.INNODB_LOCKS;
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
| lock_id        | lock_trx_id | lock_mode | lock_type | lock_table | lock_index | lock_space | lock_page | lock_rec | lock_data |
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
| 963593:251:3:7 | 963593      | S         | RECORD    | `live`.`z` | PRIMARY    |        251 |         3 |        7 | 6         |
| 963590:251:3:7 | 963590      | X         | RECORD    | `live`.`z` | PRIMARY    |        251 |         3 |        7 | 6         |
+----------------+-------------+-----------+-----------+------------+------------+------------+-----------+----------+-----------+
2 rows in set (0.06 sec)

---TRANSACTION 963603, ACTIVE 4 sec inserting
mysql tables in use 1, locked 1
LOCK WAIT 2 lock struct(s), heap size 360, 1 row lock(s), undo log entries 1
MySQL thread id 143534564, OS thread handle 0x7feee819a700, query id 270442595 172.20.0.4 root executing
INSERT INTO z select 6,1
------- TRX HAS BEEN WAITING 4 SEC FOR THIS LOCK TO BE GRANTED:
RECORD LOCKS space id 251 page no 4 n bits 80 index `b` of table `live`.`z`
trx id 963603 lock_mode X locks gap before rec insert intention waiting
Record lock, heap no 4 PHYSICAL RECORD: n_fields 2; compact format; info bits 0
 0: len 4; hex 80000003; asc     ;;
 1: len 4; hex 80000005; asc     ;;

------------------
TABLE LOCK table `live`.`z` trx id 963603 lock mode IX
RECORD LOCKS space id 251 page no 4 n bits 80 index `b` of table `live`.`z`
trx id 963603 lock_mode X locks gap before rec insert intention waiting
Record lock, heap no 4 PHYSICAL RECORD: n_fields 2; compact format; info bits 0
 0: len 4; hex 80000003; asc     ;;
 1: len 4; hex 80000005; asc     ;;

---TRANSACTION 963602, ACTIVE 16 sec
4 lock struct(s), heap size 1184, 3 row lock(s)
MySQL thread id 143534605, OS thread handle 0x7feed2f7c700, query id 270442533 172.20.0.4 root
Trx read view will not see trx with id >= 963603, sees < 963603
TABLE LOCK table `live`.`z` trx id 963602 lock mode IX
RECORD LOCKS space id 251 page no 4 n bits 80 index `b` of table `live`.`z` trx id 963602 lock_mode X
Record lock, heap no 4 PHYSICAL RECORD: n_fields 2; compact format; info bits 0
 0: len 4; hex 80000003; asc     ;;
 1: len 4; hex 80000005; asc     ;;

RECORD LOCKS space id 251 page no 3 n bits 80 index `PRIMARY` of table `live`.`z` trx id 963602 lock_mode X locks rec but not gap
Record lock, heap no 4 PHYSICAL RECORD: n_fields 4; compact format; info bits 0
 0: len 4; hex 80000005; asc     ;;
 1: len 6; hex 0000000eb3fb; asc       ;;
 2: len 7; hex 9b0000014c0110; asc     L  ;;
 3: len 4; hex 80000003; asc     ;;

RECORD LOCKS space id 251 page no 4 n bits 80 index `b` of table `live`.`z` trx id 963602 lock_mode X locks gap before rec
Record lock, heap no 5 PHYSICAL RECORD: n_fields 2; compact format; info bits 0
 0: len 4; hex 80000006; asc     ;;
 1: len 4; hex 80000007; asc     ;;


SELECT
  r.trx_id waiting_trx_id,
  r.trx_mysql_thread_id waiting_thread,
  r.trx_query waiting_query,
  b.trx_id blocking_trx_id,
  b.trx_mysql_thread_id blocking_thread,
  b.trx_query blocking_query
FROM       information_schema.innodb_lock_waits w
INNER JOIN information_schema.innodb_trx b
  ON b.trx_id = w.blocking_trx_id
INNER JOIN information_schema.innodb_trx r
  ON r.trx_id = w.requesting_trx_id;

select * FROM       information_schema.innodb_lock_waits w
INNER JOIN information_schema.innodb_trx b
  ON b.trx_id = w.blocking_trx_id
INNER JOIN information_schema.innodb_trx r
  ON r.trx_id = w.requesting_trx_id;
