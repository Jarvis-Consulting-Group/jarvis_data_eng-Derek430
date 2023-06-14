#! /usr/bin/bash
export PGPASSWORD='password'
psql -h localhost -p 5432 -U postgres -W

psql -h localhost -p 5432 -U postgres << EOF
\l
CREATE DATABASE host_agent;
\c host_agent
EOF

# Run the SQL script
psql -h localhost -p 5432 -U postgres -d host_agent -f /home/centos/dev/jarvis_data_eng_demo/linux_sql/sql/ddl.sql
