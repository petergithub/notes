# HBase Notes

[quickstart](https://hbase.apache.org/book.html#quickstart)

按照默认配置，

RegionSize = 10G，对应参数为hbase.hregion.max.filesize；
MemstoreSize = 128M，对应参数为hbase.hregion.memstore.flush.size；
ReplicationFactor = 3，对应参数为dfs.replication；
HeapFractionForMemstore = 0.4，对应参数为hbase.regionserver.global.memstore.lowerLimit；
推导公式;

硬盘容量纬度下Region个数：
Disk Size / (RegionSize * ReplicationFactor)
Java Heap纬度下Region个数：
Java Heap * HeapFractionForMemstore / (MemstoreSize / 2 )

作者：sunTengSt
链接：https://www.jianshu.com/p/ec9c6414dfe7
来源：简书
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。

## Startup

`conf/hbase-site.xml` is the main HBase configuration file

1. Start HBase: `bin/start-hbase.sh`
2. Stop HBase: `bin/stop-hbase.sh`
3. Start HBase Master Server `bin/local-master-backup.sh start 2` (number signifies specific server)
4. Start Region `bin/local-regionservers.sh start 3`
5. Connect to HBase: `./bin/hbase shell`, Exit the HBase Shell: `quit`
6. Start Thrift server: `bin/hbase-daemon.sh start thrift -p <port> --infoport <infoport>`

## Basic command

1. `table_help`, `status`, `version`, `whoami`
2. `list` list tables, `describe 'table name'` **Single quote is required**
3. Create a table: `create 'test_tbl', 'columnFamily'`
4. List Information About your Table: `list 'test_tbl'`
5. Put data into your table: `put 'test_tbl', 'row1', 'cf:a', 'value1'`
6. Scan the table for all data at once: `scan 'test_tbl'`, `scan 't1', { TIMERANGE => [0, 1416083300000] }`
7. Get a single row of data: `get 'test_tbl', 'row1'`
8. 默认get 到最新版本数据，如果需要获取多个版本的数据，需要使用 `scan 'test_tbl',{FILTER => "PrefixFilter ('rowkey')",RAW => true, VERSIONS => 10}`
9. Disable a table: `disable 'test_tbl'`, `enable 'test_tbl'`If you want to delete a table or change its settings, as well as in some other situations, you need to disable the table first
10. limit: `hbase> scan 'test_tbl', {'LIMIT' => 5}` Command like SQL LIMIT in HBase
11. `count 'tablename', CACHE => 1000` 配置正确的 CACHE 时速度非常快, 上述计数一次取 1000 行。如果行很大，请将 CACHE 设置得较低。默认是每次读取一行。
12. Drop the table: `drop 'test_tbl'`

### Add Node

1. HMaster节点的配置regionservers `echo node04 >> $HBASE_HOME/conf/regionservers`
2. 在新节点中通过下面命令启动HRegionServer: `hbase-daemon.sh start regionserver`
3. 验证HRegionServer：`jps | grep -e HRegionServer -e DataNode -e QuorumPeerMain -e DataNode`

### Remove Node

1. `graceful_stop.sh node04` 会自动先设置 `balance_switch` 为 false, 然后关闭hbase, 再设置为 true
2. `hbase-daemon.sh stop regionserver` 需要?
3. `http://hmaster_ip:16010/master-status` 查看状态
4. 从文件 `$HBASE_HOME/conf/regionservers` 删掉 `node4`

## 压缩数据

[HBase系列之compact | WBINGのBLOG](https://wbice.cn/article/hbase-compact.html#ExploringCompactionPolicy)

[hbase2.1.x 压缩算法-马育民老师](https://www.malaoshi.top/show_1IX1y3a332gi.html)

LZ4 表存储量较小，但 qps 大，对 rt 要求极高。针对这种场景，可使用 lz4 压缩，其解压速度在部分场景下可以达到 lzo 的两倍以上。一旦读操作落盘需要解压缩，lz4 解压的rt和cpu开销都明显小于lzo压缩

```sh
# hadoop支持的算法
[root@hostname logs]# hadoop checknative
22/06/24 10:43:23 WARN bzip2.Bzip2Factory: Failed to load/initialize native-bzip2 library system-native, will use pure-Java version
22/06/24 10:43:23 INFO zlib.ZlibFactory: Successfully loaded & initialized native-zlib library
Native library checking:
hadoop:  true /data/local/bigdata/project/hadoop-2.7.3/lib/native/libhadoop.so.1.0.0
zlib:    true /lib64/libz.so.1
snappy:  false
lz4:     true revision:99
bzip2:   false
openssl: false Cannot load libcrypto.so (libcrypto.so: cannot open shared object file: No such file or directory)!

# To check if the Hadoop native library is available to HBase, run the following tool (available in Hadoop 2.1 and greater):
[root@hostname ~]# hbase --config ~/conf_hbase org.apache.hadoop.util.NativeLibraryChecker
Native library checking:
hadoop: true /data/local/bigdata/project/hadoop-2.7.3/lib/native/libhadoop.so.1.0.0
zlib:   true /lib64/libz.so.1
snappy: false
lz4:    true revision:99
bzip2:  false

# 测试是否支持压缩的算法
hbase org.apache.hadoop.hbase.util.CompressionTest file:///tmp/testfile gz
hbase org.apache.hadoop.hbase.util.CompressionTest file:///tmp/testfile lz4

hbase org.apache.hadoop.hbase.util.CompressionTest file:///tmp/testfile snappy
hbase org.apache.hadoop.hbase.util.CompressionTest file:///tmp/testfile lzo

# 对表列族启用压缩
disable 'table_name' #停用表
alter 'table_name', NAME => 'month', COMPRESSION => 'gz'     #修改压缩
alter 'table_name', NAME => 'month', COMPRESSION => 'none'     #去掉压缩
enable 'table_name'                                            #enable表后压缩还不会生效, 需要立即生效
major_compact 'table_name'
```

```sh
[root@hostname ~]# export JAVA_HOME=/usr/lib/jvm/jre-1.8.0-openjdk.x86_64
[root@hostname ~]# hbase org.apache.hadoop.hbase.util.CompressionTest file:///tmp/testfile snappy
Exception in thread "main" java.lang.RuntimeException: native snappy library not available: this version of libhadoop was built without snappy support.
        at org.apache.hadoop.io.compress.SnappyCodec.checkNativeCodeLoaded(SnappyCodec.java:64)
        at org.apache.hadoop.io.compress.SnappyCodec.getCompressorType(SnappyCodec.java:132)
        at org.apache.hadoop.io.compress.CodecPool.getCompressor(CodecPool.java:148)
        at org.apache.hadoop.io.compress.CodecPool.getCompressor(CodecPool.java:163)
        at org.apache.hadoop.hbase.io.compress.Compression$Algorithm.getCompressor(Compression.java:303)
        at org.apache.hadoop.hbase.io.encoding.HFileBlockDefaultEncodingContext.<init>(HFileBlockDefaultEncodingContext.java:90)
        at org.apache.hadoop.hbase.io.hfile.HFileBlock$Writer.<init>(HFileBlock.java:879)
        at org.apache.hadoop.hbase.io.hfile.HFileWriterV2.finishInit(HFileWriterV2.java:126)
        at org.apache.hadoop.hbase.io.hfile.HFileWriterV2.<init>(HFileWriterV2.java:118)
        at org.apache.hadoop.hbase.io.hfile.HFileWriterV3.<init>(HFileWriterV3.java:67)
        at org.apache.hadoop.hbase.io.hfile.HFileWriterV3$WriterFactoryV3.createWriter(HFileWriterV3.java:59)
        at org.apache.hadoop.hbase.io.hfile.HFile$WriterFactory.create(HFile.java:309)
        at org.apache.hadoop.hbase.util.CompressionTest.doSmokeTest(CompressionTest.java:124)
        at org.apache.hadoop.hbase.util.CompressionTest.main(CompressionTest.java:160)


[root@hostname logs]# hbase org.apache.hadoop.hbase.util.CompressionTest file:///tmp/testfile lzo
2022-06-24 10:41:45,427 INFO  [main] hfile.CacheConfig: Created cacheConfig: CacheConfig:disabled
Exception in thread "main" java.lang.RuntimeException: java.lang.ClassNotFoundException: com.hadoop.compression.lzo.LzoCodec
        at org.apache.hadoop.hbase.io.compress.Compression$Algorithm$1.buildCodec(Compression.java:130)
        at org.apache.hadoop.hbase.io.compress.Compression$Algorithm$1.getCodec(Compression.java:116)
        at org.apache.hadoop.hbase.io.compress.Compression$Algorithm.getCompressor(Compression.java:301)
        at org.apache.hadoop.hbase.io.encoding.HFileBlockDefaultEncodingContext.<init>(HFileBlockDefaultEncodingContext.java:90)
        at org.apache.hadoop.hbase.io.hfile.HFileBlock$Writer.<init>(HFileBlock.java:879)
        at org.apache.hadoop.hbase.io.hfile.HFileWriterV2.finishInit(HFileWriterV2.java:126)
        at org.apache.hadoop.hbase.io.hfile.HFileWriterV2.<init>(HFileWriterV2.java:118)
        at org.apache.hadoop.hbase.io.hfile.HFileWriterV3.<init>(HFileWriterV3.java:67)
        at org.apache.hadoop.hbase.io.hfile.HFileWriterV3$WriterFactoryV3.createWriter(HFileWriterV3.java:59)
        at org.apache.hadoop.hbase.io.hfile.HFile$WriterFactory.create(HFile.java:309)
        at org.apache.hadoop.hbase.util.CompressionTest.doSmokeTest(CompressionTest.java:124)
        at org.apache.hadoop.hbase.util.CompressionTest.main(CompressionTest.java:160)
Caused by: java.lang.ClassNotFoundException: com.hadoop.compression.lzo.LzoCodec
        at java.net.URLClassLoader.findClass(URLClassLoader.java:381)
        at java.lang.ClassLoader.loadClass(ClassLoader.java:424)
        at sun.misc.Launcher$AppClassLoader.loadClass(Launcher.java:331)
        at java.lang.ClassLoader.loadClass(ClassLoader.java:357)
        at org.apache.hadoop.hbase.io.compress.Compression$Algorithm$1.buildCodec(Compression.java:125)
        ... 11 more
```

## 参数调优

[生产环境中的HBase核心参数到底该怎么优化？这篇文章可以一看 - 墨天轮](https://www.modb.pro/db/81894)
