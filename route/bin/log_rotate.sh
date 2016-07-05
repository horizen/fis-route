#!/bin/bash

init () {
    nginx_logs_dir=/home/xxx/fis-route/logs
    tomcat_logs_dir=/home/xxx/fis-tomcat/logs

    backup_date=$(date +"%Y-%m-%d" -d -1day)

    if [ -f ${nginx_logs_dir}/nginx.pid ];then
        pid=`cat ${nginx_logs_dir}/nginx.pid`
    else
        pid=`ps -ef | grep 'nginx' | grep 'master' | awk '{print $2}'`
    fi
}

rotate_nginx() {
    cd $nginx_logs_dir
    mkdir -p ${backup_date}
    mv access.log ${backup_date}
    mv biz.log ${backup_date}
    mv error.log ${backup_date}

    kill -USR1 $pid
    cd ${backup_date}
    tar -czf route.tar.gz *.log
    rm -rf *.log
}

rotate_tomcat() {
    cd $tomcat_logs_dir
    if [ ! -d ${backup_date} ]; then
        mkdir -p ${backup_date}
    fi
    mv *${backup_date}.log ${backup_date}
    cd ${backup_date}
    tar -czf tomcat.tar.gz *.${backup_date}.log 
    rm -rf *.${backup_date}.log
}

main () {
    init
    rotate_nginx
    rotate_tomcat
}

main
