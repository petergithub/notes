[TOC]

## Hadoop
Reference: https://www.tutorialspoint.com/hbase/hbase_installation.htm  

1. start hadoop: $HADOOP_HOME/sbin/start-all.sh
2. stop hadoop: $HADOOP_HOME/sbin/stop-all.sh
3. start hbase: $HBASE_HOME/bin/start-hbase.sh
4. stop hbase: $HBASE_HOME/bin/stop-hbase.sh
5. http://localhost:8088

### Verifying Hadoop Installation
1. Name Node Setup: `hdfs namenode -format` Formatting the HDFS file system via the NameNode   
2. Verifying Hadoop dfs: `start-dfs.sh`
3. Verifying Yarn Script: `start-yarn.sh`
4. Accessing Hadoop on Browser: `http://localhost:50070`
5. Verify all Applications of Cluster: `http://localhost:8088`
6. Checking the HBase Directory in HDFS: `hadoop fs -ls /hbase`

### Configuration Files

1. `core-site.xml`
The core-site.xml file contains information such as the port number used for Hadoop instance, memory allocated for file system, memory limit for storing data, and the size of Read/Write buffers.  

```

	<configuration>
		<property>
			<name>fs.default.name</name>
			<value>hdfs://localhost:9000</value>
		</property>
	</configuration>
```
2. `hdfs-site.xml`
The hdfs-site.xml file contains information such as the value of replication data, namenode path, and datanode path of your local file systems, where you want to store the Hadoop infrastructure.  

```

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
3. `mapred-site.xml`
This file is used to specify which MapReduce framework we are using. By default, Hadoop contains a template of yarn-site.xml  

```

	<configuration>
	   <property>
	      <name>mapreduce.framework.name</name>
	      <value>yarn</value>
	   </property>
	</configuration>
```
4. `yarn-site.xml`
This file is used to configure yarn into Hadoop.   

```
	
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

## HBase
https://hbase.apache.org/book.html#quickstart  

### Startup
`conf/hbase-site.xml` is the main HBase configuration file
1. Start HBase: `bin/start-hbase.sh`
2. Stop HBase: `bin/stop-hbase.sh`
3. Start HBase Master Server `bin/local-master-backup.sh start 2` (number signifies specific server) 
4. Start Region `bin/local-regionservers.sh start 3`
5. Connect to HBase: `./bin/hbase shell`, Exit the HBase Shell: `quit`

### Basic command
`table_help`, `status`, `version`, `whoami`
`list` list tables, `describe 'table name'` 
4. Create a table: `create 'test', 'columnFamily'`
5. List Information About your Table: `list 'test'`
6. Put data into your table: `put 'test', 'row1', 'cf:a', 'value1'`
7. Scan the table for all data at once: `scan 'test'`
8. Get a single row of data: `get 'test', 'row1'`
9. Disable a table: `disable 'test'`, `enable 'test'`  
	If you want to delete a table or change its settings, as well as in some other situations, you need to disable the table first  
10. Drop the table: `drop 'test'`

## Hive 
[Apache Hive](https://hive.apache.org/ )
[GettingStarted](https://cwiki.apache.org/confluence/display/Hive/GettingStarted#GettingStarted-RunningHive )
### Hive Command Line Options
[LanguageManual Cli](https://cwiki.apache.org/confluence/display/Hive/LanguageManual+Cli )

usage: hive
 -d,--define <key=value>          Variable substitution to apply to Hive commands. e.g. -d A=B or --define A=B
 -e <quoted-query-string>         SQL from command line
 -f <filename>                    SQL from files
 -H,--help                        Print help information
 -h <hostname>                    Connecting to Hive Server on remote host
    --hiveconf <property=value>   Use value for given property
    --hivevar <key=value>         Variable substitution to apply to hive
                                  commands. e.g. --hivevar A=B
 -i <filename>                    Initialization SQL file
 -p <port>                        Connecting to Hive Server on port number
 -S,--silent                      Silent mode in interactive shell
 -v,--verbose                     Verbose mode (echo executed SQL to the
                                  console)

