#!/bin/bash

del_date=$(date +"%Y-%m-%d" -d -7day)

cd /home/xxx/fis-route/logs
rm -rf ${del_date}

cd /home/xxx/fis-tomcat/logs
rm -rf ${del_date}
