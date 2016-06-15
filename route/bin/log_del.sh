#!/bin/bash

del_date=$(date +"%Y-%m-%d" -d -7day)

cd /home/xiaoju/fis-route/logs
rm -rf ${del_date}

cd /home/xiaoju/fis-tomcat/logs
rm -rf ${del_date}
