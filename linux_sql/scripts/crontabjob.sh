#! /usr/bin/bash

crontab -l > crontab_new

echo "* * * * * bash /home/centos/dev/jarvis_data_eng_demo/linux_sql/scripts/host_usage.sh localhost 5432 host_agent postgres password > /tmp/host_usage.log" >> crontab_new

crontab crontab_new
