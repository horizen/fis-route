#!/bin/sh

cd `dirname $0`

rm -rf output
jello release -r test -cmopd output
