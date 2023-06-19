#! /usr/bin/bash

psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5

#Check # of args
if [ "$#" -ne 5 ]; then
    echo "Illegal number of parameters"
    exit 1
fi

#Save machine statistics in MB and current machine hostname to variables
vmstat_mb=$(vmstat --unit M)
hostname=$(hostname -f)

#Current time in `2019-11-26 14:40:19` UTC format
timestamp=$(date +"%Y-%m-%d %H:%M:%S")

#Subquery to find matching id in host_info table
host=$(hostname -f);

memory_free=$(free -m | awk '/^Mem:/ {print $4}')

cpu_number=$(nproc)

cpu_architecture=$(uname -p)

cpu_model=$(lscpu | sed -n 's/Model name:[[:space:]]*//p')

cpu_mhz=$(lscpu | awk '/^CPU MHz:/ {print $3}')

l2_cache=$(lscpu | sed -n 's/L2 cache:\s*\([0-9]*\)K/\1/p')

timestamp=$(date +"%Y-%m-%d %H:%M:%S")

total_mem=$(free -k | awk '/^Mem:/ {print $2}')

#PSQL command: Inserts server usage data into host_usage table
insert_stmt="INSERT INTO host_info(id, hostname, cpu_number, cpu_architecture, cpu_model, cpu_mhz, l2_cache, timestamp, total_mem) VALUES(DEFAULT, '$hostname', '$cpu_number', '$cpu_architecture', '$cpu_model', '$cpu_mhz', '$l2_cache', '$timestamp', '$total_mem')"

#set up env var for pql cmd
export PGPASSWORD=$psql_password 
#Insert date into a database
psql -h $psql_host -p $psql_port -d $db_name -U $psql_user -c "$insert_stmt"

psql -h localhost -p $psql_port -U $psql_user << EOF
\c host_agent
EOF

insert_stmtt="SELECT * FROM host_info"
psql -h $psql_host -p $psql_port -d $db_name -U $psql_user -c "$insert_stmtt"

exit $?
