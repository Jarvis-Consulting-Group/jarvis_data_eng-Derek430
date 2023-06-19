#! /usr/bin/bash

psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5
export PGPASSWORD=$psql_password 

#Check # of args
if [ "$#" -ne 5 ]; then
    echo "Illegal number of parameters"
    exit 1
fi

#Save machine statistics in MB and current machine hostname to variables
vmstat_mb=$(vmstat --unit M)
hostname=$(hostname -f)

#Current time in UTC format
timestamp=$(date +"%Y-%m-%d %H:%M:%S")

#Subquery to find matching id in host_info table
host_id=$(psql -h localhost -U postgres -d host_agent -t -c "SELECT id FROM host_info WHERE hostname='$hostname'");

memory_fre=$(free -m | awk '/^Mem:/ {print $4}')

cpu_idle=$(vmstat | tail -1 |awk '{print $15}'| xargs)

# Calculate the CPU kernel usage percentage
cpu_kernel=$(vmstat | tail -1 |awk '{print $14}'| xargs)
#echo cpu_kernel=$usage

disk_io=$(vmstat --unit M -d | tail -1 | awk '{print $10}' | xargs)

disk_available=$(df -BM / | tail -1 | awk '{print $4}' | sed 's/M//'| xargs)

#PSQL command: Inserts server usage data into host_usage table
#Note: be careful with double and single quotes
insert_stmt="INSERT INTO host_usage("timestamp", host_id, memory_free, cpu_idle, cpu_kernel, disk_io, disk_available) VALUES('$timestamp', '$host_id', '$memory_fre', '$cpu_idle', '$cpu_kernel', '$disk_io', '$disk_available')"

#set up env var for pql cmd
export PGPASSWORD=$psql_password 
#Insert date into a database
psql -h $psql_host -p $psql_port -d $db_name -U $psql_user -c "$insert_stmt"

exit $?
