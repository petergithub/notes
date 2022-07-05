# Hadoop Notes

## Hadoop

[Reference](https://www.tutorialspoint.com/hbase/hbase_installation.htm)

1. start hadoop: $HADOOP_HOME/sbin/start-all.sh
2. stop hadoop: $HADOOP_HOME/sbin/stop-all.sh
3. start hbase: $HBASE_HOME/bin/start-hbase.sh
4. stop hbase: $HBASE_HOME/bin/stop-hbase.sh
5. [URL](http://localhost:8088)

### Hadoop Configuration

`/etc/hadoop/conf/capacity-scheduler.xml`
`yarn.scheduler.capacity.resource-calculator`
`org.apache.hadoop.yarn.util.resource.DefaultResourceCalculator` It considers only memory
`org.apache.hadoop.yarn.util.resource.DominantResourceCalculato` It uses both cpu and memory.

### Command

[Hadoop FileSystem Shell](https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/FileSystemShell.html )
`hadoop fs -help ls`
`hadoop fs -ls`
`hdfs dfs -put source target` copy files
`hdfs dfs -cat /user/hadoop/data.txt` cat path/to/file

### Change replication factor

[How to change an running HDFS cluster's replication factor?](https://www.systutorials.com/qa/1295/how-to-change-an-running-hdfs-clusters-replication-factor)
First, the replication factor is client decided.
Second, the replication factor is per-file configuration.
Hence, the configuration only changes the client and takes effect for new files.
For existing files, you need to manually re-set the replication factor: `hadoop fs -setrep -R -w 2 /path/to/file`

set `dfs.replication=2` in `$HADOOP_HOME/etc/hadoop/hdfs-site.xml`
`hdfs fsck / -blocks -locations -files`  输出中确定一下是否还有block在decommision的机器上
`hdfs fsck / -files -blocks -racks`
`hdfs dfsadmin -report`

Check replication:
list file: `hadoop fs -ls /path/to/file`
Get the replication factor using the stat hdfs command tool: `hdfs dfs -stat %r /path/to/file`

### Add DataNode

1. 启动datanode进程 `sbin/hadoop-daemon.sh start datanode`
2. 启动nodemanager进程 `sbin/yarn-daemon.sh start nodemanager`
3. 均衡block `sbin/start-balancer.sh`

### Remove DataNode

1. 将 replication factor 设置为减少后的节点数
2. `echo node_hostname >> $HADOOP_HOME/etc/hadoop/dfs.hosts.exclude.txt`

``` xml
<property>
    <name>dfs.hosts.exclude</name>
    <value>$HADOOP_HOME/etc/hadoop/dfs.hosts.exclude.txt</value>
    <description>Names a file that contains a list of hosts that are not permitted to connect to the namenode.  The full pathname of the
    file must be specified.  If the value is empty, no hosts are excluded.</description>
</property>
```

3. 重新读取配置 `hadoop dfsadmin  -refreshNodes`
4. `hdfs dfsadmin -report`
可以看到该节点会处于`Decommission Status : Decommission in progress`的状态。
等待数据迁移完成之后，该状态变为 `Decommission Status : Decommissioned`
在该节点上停止进程： `hadoop-daemon.sh stop datanode` 删除slaves文件中的对应主机名即可

### Verifying Hadoop Installation

1. Name Node Setup: `hdfs namenode -format` Formatting the HDFS file system via the NameNode
2. Verifying Hadoop dfs: `start-dfs.sh`
3. Verifying Yarn Script: `start-yarn.sh`
4. Accessing Hadoop on Browser: `http://localhost:50070`
5. Verify all Applications of Cluster: `http://localhost:8088`
6. Checking the HBase Directory in HDFS: `hadoop fs -ls /hbase`

### Configuration Files

#### `core-site.xml`

The core-site.xml file contains information such as the port number used for Hadoop instance, memory allocated for file system, memory limit for storing data, and the size of Read/Write buffers.

``` xml

    <configuration>
        <property>
            <name>fs.default.name</name>
            <value>hdfs://localhost:9000</value>
        </property>
    </configuration>
```

#### `hdfs-site.xml`

The hdfs-site.xml file contains information such as the value of replication data, namenode path, and datanode path of your local file systems, where you want to store the Hadoop infrastructure.

``` xml

    <configuration>
       <property>
          <name>dfs.replication</name >
          <value>1</value>
       </property>

       <property>
          <name>dfs.name.dir</name>
          <value>file:///data/hadoop/hadoopinfra/hdfs/namenode</value>
       </property>

       <property>
          <name>dfs.data.dir</name>
          <value>file:///data/hadoop/hadoopinfra/hdfs/datanode</value>
       </property>
    </configuration>
```

#### `mapred-site.xml`

This file is used to specify which MapReduce framework we are using. By default, Hadoop contains a template of yarn-site.xml

``` xml

    <configuration>
       <property>
          <name>mapreduce.framework.name</name>
          <value>yarn</value>
       </property>
    </configuration>
```

#### `yarn-site.xml`

This file is used to configure yarn into Hadoop.

``` xml
    <configuration>
       <property>
          <name>yarn.nodemanager.aux-services</name>
          <value>mapreduce_shuffle</value>
       </property>
    </configuration>
```

http://localhost:8088
http://localhost:50070 NameNode Web Interface (HDFS layer)
http://localhost:50090
http://localhost:50030 JobTracker Web Interface (MapReduce layer)
http://localhost:50060 TaskTracker Web Interface (MapReduce layer)

## Hive

[Apache Hive](https://hive.apache.org/ )
[GettingStarted](https://cwiki.apache.org/confluence/display/Hive/GettingStarted#GettingStarted-RunningHive )

### Hive Command Line Options

[LanguageManual Cli](https://cwiki.apache.org/confluence/display/Hive/LanguageManual+Cli )

usage: hive
 -d,--define <key=value>          Variable substitution to apply to Hive commands. e.g. -d A=B or --define A=B
 -e quoted-query-string         SQL from command line
 -f filename                    SQL from files
 -H,--help                        Print help information
 -h hostname                    Connecting to Hive Server on remote host
    --hiveconf <property=value>   Use value for given property
    --hivevar <key=value>         Variable substitution to apply to hive
                                  commands. e.g. --hivevar A=B
 -i filename                    Initialization SQL file
 -p port                        Connecting to Hive Server on port number
 -S,--silent                      Silent mode in interactive shell
 -v,--verbose                     Verbose mode (echo executed SQL to the
                                  console)
Display header: `set hive.cli.print.header=true`
`set hive.metastore.warehouse.dir=/user/myname/hive/warehouse;` 用户设定自己的数据仓库目录。不影响其他用户。也在$HOME/.hiverc中设置，则每次启动hive自动加载

Get all setting: `hive -e "set -v;" > ~/config.txt`

#### Basic commands

[LanguageManual Select](https://cwiki.apache.org/confluence/display/Hive/LanguageManual+Select )
Hive will print information to standard error such as the time taken to run a query during the course of operation.
`SELECT current_database()`
字符串s 转整型 `cast(s as int)`
`SHOW PARTITIONS table_name`
`INSERT OVERWRITE TABLE tablename1 [PARTITION (partcol1=val1, partcol2=val2 ...) [IF NOT EXISTS]] select_statement1 FROM from_statement;`
`INSERT INTO TABLE tablename1 [PARTITION (partcol1=val1, partcol2=val2 ...)] select_statement1 FROM from_statement;`

#### Config

`SET hive.execution.engine=tez;`
`SET tez.queue.name=queueName;`

##### hiveconf

[LanguageManual VariableSubstitution](https://cwiki.apache.org/confluence/display/Hive/LanguageManual+VariableSubstitution )
test.sql: `select * from foo where day >= '${hiveconf:CURRENT_DATE}'`
`hive --hiveconf CURRENT_DATE='2012-09-16' -f test.hql`
`hive --hiveconf CONF='this is conf' -e '!echo ${hiveconf:CONF};'`

`hive> set hiveconf:CONF=conf1;`
`hive> set hiveconf:CONF;`

##### hivevar

`set hivevar:tablename=mytable;`
`hive> source /path/to/setup.hql;` # setup.hql which sets a tablename variable
or `hive> select * from ${tablename}`
or `hive> select * from ${hivevar:tablename}`

`hive --hivevar TABLE_NAME=mytable -f test.hql`
`hive --hivevar VAR='this is var' -e '!echo ${VAR};'`
`hive> set hivevar:VAR=var1;`
`hive> set hivevar:VAR;`

#### Advanced

[Hive Joins](https://cwiki.apache.org/confluence/display/Hive/LanguageManual+Joins)

##### cube

cube简称数据魔方，可以实现hive多个任意维度的查询，cube(a,b,c)则首先会对(a,b,c)进行group by，然后依次是(a,b),(a,c),(a),(b,c),(b),(c),最后在对全表进行group by，他会统计所选列中值的所有组合的聚合

`select a,b,c from table group by a,b,c with cube;`

#### Privileges

`SHOW ROLES;` `SHOW CURRENT ROLES;`
`SET ROLE ADMIN;`
`CREATE ROLE role_name;`
`GRANT select ON DATABASE db_name TO ROLE role_name;`
`GRANT select ON TABLE db_name.table_name TO ROLE role_name;`
`REVOKE select ON TABLE db_name.table_name FROM ROLE role_name;`
`SHOW PRINCIPALS role_name;`
`SHOW GRANT [principal_name] ON (ALL| ([TABLE] table_or_view_name)`
`SHOW GRANT ROLE admin;`

#### Examples

##### Run query

* running a query from the command line `hive -e 'select a.col from tab1 a'`
* dumping data out from a query into a file using silent mode `hive -S -e 'select a.col from tab1 a' > a.txt`
* running a script non-interactively from local disk `hive -f /home/my/hive-script.sql`
* running a script non-interactively from a Hadoop supported filesystem `hive -f hdfs://<namenode>:<port>/hive-script.sql`, `hive -f s3://mys3bucket/s3-script.sql ``
* output information to log: `hive --hiveconf tez.queue.name=sysopt -e "select t.dt,t.times,count(distinct t.uuid) from(select dt,uuid,count(uuid) times from data_warehouse.dw_app_orc_dt where dt = '20170420' group by dt,uuid order by dt) t group by t.dt, t.times limit 10;" >> test.log 2>&1`

##### Export file

* output tab-separated file `hive -e 'select books from table' > /tmp/temp.tsv`
* output comma-delimited file: `hive -e 'select books from table' | sed 's/[[:space:]]\+/,/g' > /tmp/temp.tsv`

### Hive Configuration

[Hive Configuration Properties](https://cwiki.apache.org/confluence/display/Hive/Configuration+Properties#ConfigurationProperties-Tez )
`set hive.groupby.skewindata=true;` Hive will trigger an additional MapReduce job whose map output will randomly distribute to the reducer to avoid data skew
