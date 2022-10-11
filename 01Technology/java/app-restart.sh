#!/bin/bash

# 环境
ACTIVE=publish

APP_NAME=app

# 进程名
PNAME='$APP_NAME.jar'

# 最新的打包文件路径
LAST_JAR_PATH='/data/apps/$APP_NAME'
#堆内存快照文件地址
HEAP_DUMP_PATH='/data/logs/$APP_NAME/hprof'
#gc文件地址
JVM_LOG_PATH='/data/logs/$APP_NAME/jvm'

PID=$(ps -ef | grep $PNAME | grep -v grep | awk '{print $2}')
echo "[info]$APP_NAME项目开始pid: $PID"
kill -9 $PID

export NMT_OPTS="-XX:NativeMemoryTracking=detail"
export LD_PRELOAD=/usr/local/lib/libjemalloc.so
export MALLOC_CONF=prof:true,prof_leak:true,lg_prof_interval:30,lg_prof_sample:17,prof_prefix:/data/logs/$APP_NAME/jeprof-out/jeprof

# 启动jar包
nohup java -Xms2g -Xmx2g -Xmn1g -Xss256k \
	$NMT_OPTS \
	-server \
	-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=${HEAP_DUMP_PATH} \
	-XX:ErrorFile=${JVM_LOG_PATH}/hs_err_pid%p.log \
	-verbose:gc -XX:+PrintGCDetails -XX:+PrintGCDateStamps -Xloggc:${JVM_LOG_PATH}/gc.%p.log \
	-jar ${LAST_JAR_PATH}/${PNAME} --spring.profiles.active=$ACTIVE &

NEW_PID=$(ps -ef | grep $PNAME | grep -v grep | awk '{print $2}')

echo "[info]$APP_NAME项目重启后pid: $NEW_PID"

echo "------------- end $APP_NAME ---------------"
