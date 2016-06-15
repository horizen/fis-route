#!/bin/sh

cd `dirname $0`
cd ..

./bin/build.sh $@
./bin/nginx.sh restart
