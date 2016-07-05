#!/bin/sh

cd `dirname $0`

mvn clean package

rm -rf release

mkdir -p release/WEB-INF

cp -r target/classes release/WEB-INF/
