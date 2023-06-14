#! /usr/bin/bash

sudo systemctl status docker || systemctl

CONTAINER_NAME="jrvs-psql"

create_container() {
  local username="$1"
  local password="$2"
  
  if docker ps -a --format '{{.Names}}' | grep -Eq "^$CONTAINER_NAME$"; then
    echo "Error: PostgreSQL container is already created."
    exit 1
  fi
  
  if [ -z "$username" ] || [ -z "$password" ]; then
    echo "Error: Missing username or password. Usage: $0 create <username> <password>"
    exit 1
  fi
  
  echo "Creating PostgreSQL container..."
  if ! [ -d ~/docker_volumn ]; then
    mkdir ~/docker_volumn
  else
    echo "Folder does not exist."
  fi
  export PGPASSWORD='password'
  docker volumn create my_vol
  docker run --name "$CONTAINER_NAME" -e JRVS_USER="$username" -e JRVS_PASSWORD="$password" -v my_volumn:~/docker_volumn
  echo "PostgreSQL container created."
}

start_container() {
  if ! docker ps -a --format '{{.Names}}' | grep -Eq "^$CONTAINER_NAME$"; then
    echo "Error: Container is not created."
    exit 1
  fi
  
  echo "Starting PostgreSQL container..."
  docker start "$CONTAINER_NAME" 
  echo "PostgreSQL container started."
}

stop_container() {
  if ! docker ps -a --format '{{.Names}}' | grep -Eq "^$CONTAINER_NAME$"; then
    echo "Error: Container is not created."
    exit 1
  fi
  
  echo "Stopping Container..."
  docker stop "$CONTAINER_NAME"
  echo "Container stopped."
}

case "$1" in
  create)
    create_container "$2" "$3"
    ;;
  start)
    start_container
    ;;
  stop)
    stop_container
    ;;
  *)
    exit 1
    ;;
esac
