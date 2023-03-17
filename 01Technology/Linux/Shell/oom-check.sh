# 待修改
# 目标路径
# mem_limit 获取方法
# 格式

#!/bin/bash

SCRIPT_NAME=$(basename $0)
HOST_NAME=$(hostname -f)
CURRENT_TIME=$(date +%Y%m%d_%H%M%S)

# 在 /var/log/messages-xxx 中获取 oom 信息
SOURCE_FILE='/var/log/messages'
# 中间文件和结果都会输出到 /tmp/lumen_check_oom
TARGET_PATH='/tmp/lumen_check_oom'
# 检查结果命名为 时间_check_result
TARGET_FILE="${TARGET_PATH}/${CURRENT_TIME}_check_result"

# 三个服务 impalad 0，catalogd 2，statestored 3，关键词也按这个索引存
SERVICE=('impalad' 'catalogd' 'statestored')
KEYWORD=('beeswax' 'conf/catalog.*_flags' 'conf/state.*store.*_flags')
COMM=('impalad' 'main' 'statestored')


# 调整输出信息颜色并输出到文件，info 绿色，warn 黄色，error 红色，print 正常输入
function info() {
    echo -e "\e[1;32;40m$@ \e[0m" | tee -a "${TARGET_FILE}"
}

function warn() {
    echo -e "\e[1;33;40m$@ \e[0m" | tee -a "${TARGET_FILE}"
}

function error() {
    echo -e "\e[1;31;40m$@ \e[0m" | tee -a "${TARGET_FILE}"
}

function print() {
    echo -e "$@" | tee -a "${TARGET_FILE}"
}

# 需要使用 sa_cluster 用户运行
function check_user() {
    if [[ $(whoami) != 'sa_cluster' ]]; then
        error "本脚本需要使用 sa_cluster 用户运行！" 
        exit 1
    fi
}

# 使用方法
function print_usage() {
    cat <<EOF
Usage:
    ${SCRIPT_NAME} 检查 impala 相关进程是否存在系统 oom
    
    ${SCRIPT_NAME} -i  检查 impalad oom 情况
    ${SCRIPT_NAME} -c  检查 catalogd oom 情况
    ${SCRIPT_NAME} -s  检查 statestored oom 情况
    ${SCRIPT_NAME} -a  检查上述三个进程 oom 情况
    ${SCRIPT_NAME} -h  显示使用方法
EOF
    exit 1
}

# 输出当前服务器信息
function print_host_info() {
    mkdir -p ${TARGET_PATH}
    info "当前服务器为 ${HOST_NAME}"
    print "$(ls -ltr ${SOURCE_FILE}*)"
    print "检查结果记录在 ${TARGET_FILE}"
    print
}

# 检查进程存活情况
# check_service index
function check_service() {
    service_name=${SERVICE[$1]}
    service_keyword=${KEYWORD[$1]}
    service_num=$(ps -ef | grep ^impala | grep -c ${service_keyword})
    if [[ ${service_num} == 0 ]]; then
        warn "本机没有在运行的 ${service_name}"
    else
        info "本机运行 ${service_name}: ${service_num} 个"
        [[ $1 == 0 ]] && get_mem_limit
        print "$(ps -ef | grep ^impala | grep ${service_keyword})"
    fi
    print
}

# 获取 impalad mem_limit
function get_mem_limit() {
    impalad_flags=$(ps -ef | grep beeswax | grep -o 'flagfile=.*impalad_flags' | uniq | cut -d= -f2)
    mem_limit=$(sudo grep '\-mem_limit' ${impalad_flags} | cut -d= -f2)
    mem_limit=$(echo "scale=2; ${mem_limit} / 1024 / 1024 / 1024" | bc)
    info "impalad mem_limit: ${mem_limit}G"
}

# 检查系统 oom 情况
# check_oom index
function check_oom() {
    service_name=${SERVICE[$1]}
    service_comm=${COMM[$1]}

    # 按 进程名_当前时间 的格式命名 oom 记录文件
    oom_record="${TARGET_PATH}/${CURRENT_TIME}_${service_name}"

    # 从所有的 /var/log/messages 文件里寻找 oom 记录
    for messages in $(ls -tr ${SOURCE_FILE}*); do
        sudo grep "Killed process.*(${service_comm})" ${messages} >> ${oom_record}
    done
    
    # 输出近 10 次 oom 时的内存占用
    if [[ -s ${oom_record} ]]; then
        oom_mem=$(tail -n10 ${oom_record} | awk '{match($0,"anon-rss:([0-9]+)",mem); printf("%6.2fG;",mem[1]/1024/1024)}')
        warn "${service_name} oom 时的内存占用为：${oom_mem}"
        print "oom 信息记录在 ${oom_record}"
        print "$(tail -n10 ${oom_record})"
    else
        info "${service_name} 没有 oom 记录"
        earlyoom -h &>/dev/null
        [[ $? = 0 ]] && warn "需二次检查 earlyoom 配置及日志"
    fi
    print
}

# 通过 oom 时的记录获取超过 1G 内存的进程，文件输入为 /var/log/messages 里的部分
function get_oom_info_by_file() {
    file=$1
    if [[ -e ${file} ]]; then
        cat ${file} | 
        grep -E -v 'Kill|pid' | 
        awk -F'kernel:' '{print $2}' | 
        sed -n 's/[][]//gp' | 
        awk '{pid=$1; mem=$5*4/1024/1024; name=$9; if(mem > 1) printf("%6s %6.2fG %s\n",pid,mem,name)}' | 
        sort -nrk2 |
        awk '{pid=$1; print; system("ps -p "pid" -o user,args -hwww"); printf("\n")}'
    else
        error "需要输入文件绝对路径，文件格式如下："
        print "$(cat <<EOF
Apr 26 19:58:38 hybrid01 kernel: [ pid ]   uid  tgid total_vm      rss nr_ptes swapents oom_score_adj name
Apr 26 19:58:39 hybrid01 kernel: [25362]  1001 25362  5779217  1238499    2901        0             0 java
...
Apr 26 19:58:39 hybrid01 kernel: Killed process 26982 (impalad), UID 980, total-vm:114197596kB, anon-rss:40922232kB, file-rss:0kB, shmem-rss:4kB
EOF
)"
    fi
}

# 完整的检查流程
# check_program index
function check_program() {
    info '----------------------------------------------------------------------------------------------------'
    check_service $1
    check_oom $1
}

function main() {
    check_user
    case $1 in 
        '-i') 
            index=0
            ;;
        '-c') 
            index=1
            ;;
        '-s') 
            index=2
            ;;
        '-a')
            print_host_info
            check_program 0
            check_program 1
            check_program 2
            exit
            ;;
        'file') 
            get_oom_info_by_file $2
            exit
            ;;
        *) 
            print_usage
    esac
    print_host_info
    check_program ${index}
}

main $1 $2
