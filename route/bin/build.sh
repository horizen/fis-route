#!/bin/bash

cd $(dirname $0)
cd ..

if [ -f ../bin/resty ]; then
    resty=../bin/resty
elif [ -f /home/xiaoju/openresty/bin/resty ]; then
    resty=/home/xiaoju/openresty/bin/resty
elif [ -f /usr/local/openresty/bin/resty ]; then
    resty=/usr/local/openresty/bin/resty
else
    resty=$RESTY
fi

arg=$@

if [ "$arg" == "all" ]; then
    cd conf/route
    arg=`ls *.json`
    cd ../..
fi

echo $resty src/lua/gen.lua
$resty src/lua/gen.lua `pwd` $arg
