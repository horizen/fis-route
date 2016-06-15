#!/bin/bash

function init()
{
    cd `dirname $0`
    cd ..

    if [ -f "./sbin/nginx" ]; then
        NGINX_PATH=.
    elif [ -d "/home/xiaoju/openresty/nginx" ]; then
        NGINX_PATH=/home/xiaoju/openresty/nginx
    else
        NGINX_PATH=/usr/local/openresty/nginx
    fi

    APP_PATH=`pwd`
}

function start() 
{
    echo "$NGINX_PATH/sbin/nginx -p $APP_PATH"
    $NGINX_PATH/sbin/nginx -p $APP_PATH
}

function stop() 
{
    if [ -f "$APP_PATH/logs/nginx.pid" ]; then
        pid=$(cat $APP_PATH/logs/nginx.pid)
    else
        pid=$(ps -ef | grep 'nginx' | grep 'master' | awk '{print $2}')
    fi

    echo "kill $pid"
    kill $pid
}

function restart() 
{
    $NGINX_PATH/sbin/nginx -p $APP_PATH -t
    if [ "$?" != "0" ]; then
        exit 1
    fi

    $NGINX_PATH/sbin/nginx -p $APP_PATH -s reload
    if [ "$?" != "0" ]; then
        echo "restart failure"
        exit 1
    fi
}


function execute()
{
    command=$1
    case $command in
        start)
            start
            ;;

        stop)
            stop
            ;;

        restart)
            restart
            ;;

        *)
            echo "unknown command $command" 
            exit 1
            ;;
    esac
}

init
execute $@
