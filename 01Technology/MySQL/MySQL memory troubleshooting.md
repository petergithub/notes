# MySQL memory troubleshooting

- [MySQL memory troubleshooting](#mysql-memory-troubleshooting)
  - [Other](#other)

[What To Do When MySQL Runs Out of Memory: Troubleshooting Guide](https://dzone.com/articles/what-to-do-when-mysql-runs-out-of-memory-troublesh)

[What To Do When MySQL Runs Out of Memory](https://www.percona.com/blog/2018/06/28/what-to-do-when-mysql-runs-out-of-memory-troubleshooting-guide/)

[How to debug a db memory-leak causing mysql to go before it's own limits?](https://dba.stackexchange.com/questions/43324/how-to-debug-a-db-memory-leak-causing-mysql-to-go-before-its-own-limits)

[Getting information about a process' memory usage from /proc/pid/smaps](https://unix.stackexchange.com/questions/33381/getting-information-about-a-process-memory-usage-from-proc-pid-smaps?noredirect=1&lq=1)

[MySQL not releasing memory](https://dba.stackexchange.com/questions/62021/mysql-not-releasing-memory?rq=1)

Part 2: Checks Inside MySQL
Now we can check things inside MySQL to look for potential MySQL memory leaks.

MySQL allocates memory in tons of places, especially:

- Table cache
- Performance_schema (run: `show engine performance_schema status` and look at the last line). That may be the cause for the systems with a small amount of RAM, i.e. 1G or less
- InnoDB (run  `show engine innodb status` and check the `buffer pool` section, memory allocated for buffer_pool and related caches)
- Temporary tables in RAM (find all in-memory tables by running: `select * from information_schema.tables where engine='MEMORY'`)
- Prepared statements, when it is not deallocated (check the number of prepared commands via deallocate command by running show global status like  'Com_prepare_sql';`show global status like 'Com_dealloc_sql'`)

The good news is, starting with MySQL 5.7, we have memory allocation in performance_schema. Here is how we can use it:

First, we need to enable collecting memory metrics. Run:

1. `UPDATE performance_schema.setup_instruments SET ENABLED = 'YES' WHERE NAME LIKE 'memory/%';`
2. Run the report from sys schema:
   `select event_name, current_alloc, high_alloc from sys.memory_global_by_current_bytes where current_count > 0;`
3. Usually, this will give you the place in code when memory is allocated. It is usually self-explanatory. In some cases, we can search for bugs or we might need to check the MySQL source code.

For example, for the bug where memory was over-allocated in triggers ( https://bugs.mysql.com/bug.php?id=86821) the select shows:

```bash
mysql> select event_name, current_alloc, high_alloc from sys.memory_global_by_current_bytes where current_count > 0;
+--------------------------------------------------------------------------------+---------------+-------------+
| event_name                                                                     | current_alloc | high_alloc  |
+--------------------------------------------------------------------------------+---------------+-------------+
| memory/innodb/buf_buf_pool                                                     | 7.29 GiB      | 7.29 GiB    |
| memory/sql/sp_head::main_mem_root                                              | 3.21 GiB      | 3.62 GiB    |
...
```

The largest chunk of RAM is usually the buffer pool but ~3G in stored procedures seems to be too high.

According to the MySQL source code documentation, sp_head represents one instance of a stored program, which might be of any type (stored procedure, function, trigger, event). In the above case, we have a potential memory leak.

In addition, we can get a total report for each higher level event if we want to see from the bird's eye what is eating memory:

```shell
mysql> select substring_index( substring_index(event_name, '/', 2), '/', -1 ) as event_type, round(sum(CURRENT_NUMBER_OF_BYTES_USED)/1024/1024, 2) as MB_CURRENTLY_USED from performance_schema.memory_summary_global_by_event_name group by event_type having MB_CURRENTLY_USED>0 order by MB_CURRENTLY_USED desc;
+--------------------+-------------------+
| event_type         | MB_CURRENTLY_USED |
+--------------------+-------------------+
| performance_schema |            106.26 |
| sql                |              0.79 |
| innodb             |              0.61 |
| memory             |              0.21 |
+--------------------+-------------------+
4 rows in set (0.00 sec)
```

I hope these simple steps can help troubleshoot MySQL crashes due to running out of memory.

## Other

```sql
mysql> select page_type as Page_Type, sum(data_size)/1024/1024 as Size_in_MB from information_schema.innodb_buffer_page group by page_type order by Size_in_MB desc;
+-------------------+-------------+
| Page_Type         | Size_in_MB  |
+-------------------+-------------+
| INDEX             | 79.86912918 |
| UNKNOWN           |  0.00000000 |
| SYSTEM            |  0.00000000 |
| UNDO_LOG          |  0.00000000 |
| IBUF_BITMAP       |  0.00000000 |
| INODE             |  0.00000000 |
| FILE_SPACE_HEADER |  0.00000000 |
| TRX_SYSTEM        |  0.00000000 |
+-------------------+-------------+

-- INDEX: B-Tree index
-- IBUF_INDEX: Insert buffer index
-- UNKNOWN: not allocated / unknown state
-- TRX_SYSTEM: transaction system data

-- Buffer pool usage per index
mysql> select
table_name as Table_Name, index_name as Index_Name,
count(*) as Page_Count, sum(data_size)/1024/1024 as Size_in_MB
from information_schema.innodb_buffer_page
group by table_name, index_name
order by Size_in_MB desc;
+--------------------------------------------+-----------------+------------+-------------+
| Table_Name                                 | Index_Name      | Page_Count | Size_in_MB  |
+--------------------------------------------+-----------------+------------+-------------+
| `magento`.`core_url_rewrite`               | PRIMARY         |       2829 | 40.64266014 |
| `magento`.`core_url_rewrite`               | FK_CORE_URL_... |        680 |  6.67517281 |
| `magento`.`catalog_product_entity_varchar` | PRIMARY         |        449 |  6.41064930 |
| `magento`.`catalog_product_index_price`    | PRIMARY         |        440 |  6.29357910 |
| `magento`.`catalog_product_entity`         | PRIMARY         |        435 |  6.23898315 |
+--------------------------------------------+-----------------+------------+-------------+
```
