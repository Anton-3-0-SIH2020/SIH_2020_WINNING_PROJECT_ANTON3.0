#!/bin/bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
RESTAPIDIR="${CURRENT_DIR}/RESTAPI/"
SCHEDULERAPIDIR="${CURRENT_DIR}/SchedulerAPI/"
BSESCHEDULERDIR="${CURRENT_DIR}/ScheduledTask/BSE/"
NSESCHEDULERDIR="${CURRENT_DIR}/ScheduledTask/NSE/"
MCSCHEDULERDIR="${CURRENT_DIR}/ScheduledTask/MoneyControl/"

echo "Executing from ${CURRENT_DIR}"
echo "RESTAPI to be installed from ${RESTAPIDIR}"

git submodule update --init

# Dependencies for RESTAPI

cd $RESTAPIDIR
echo "\n\n"
echo "Please provide the database configurations\n"
echo "Database host"
read HOST
echo "Database port"
read PORT
echo "Database user"
read USER
echo "Database password"
read PASSWORD
echo "Database name"
read DATABASE

echo "\n\n"
echo "Please provide the AWS configurations"
echo "AWS Access Key"
read ACCESS_KEY
echo "AWS Secret Key"
read SECRET_KEY
echo "AWS S3 Bucket"
read BUCKET
echo "AWS S3 Region"
read REGION

touch secret.ini
echo "[POSTGRES]\n
DATABASE=${DATABASE}\n
USER=${USER}\n
PASSWORD=${PASSWORD}\n
HOST=${HOST}\n
PORT=${PORT}\n
[AWS]\n
ACCESS_KEY=${ACCESS_KEY}\n
SECRET_KEY=${SECRET_KEY}\n
BUCKET=${BUCKET}\n
REGION=${REGION}\n
" >secret.ini

# Create a virtual environment

python3 -m venv env
source env/bin/activate
pip3 install -r requirements.txt

echo "\n\n"

echo "Setup for REST API Completed\n"

# Dependencies for SchedulerAPI

cd $SCHEDULERAPIDIR

touch secret.ini
echo "[POSTGRES]\n
DATABASE=${DATABASE}\n
USER=${USER}\n
PASSWORD=${PASSWORD}\n
HOST=${HOST}\n
PORT=${PORT}\n
[AWS]\n
ACCESS_KEY=${ACCESS_KEY}\n
SECRET_KEY=${SECRET_KEY}\n
BUCKET=${BUCKET}\n
" >secret.ini

python3 -m venv env
source env/bin/activate
pip3 install -r requirements.txt
echo "\n"
sh setup.sh

echo "\n\n"

echo "Setup for Scheduler API Completed"

echo "\n"

API_KEY=$(cat api_secret.txt)

# Dependencies for Task Scheduler

# BSE

cd $BSESCHEDULERDIR

touch secret.ini
echo "[API_KEY] \n
key=${API_KEY}\
" >secret.ini

python3 -m venv env
source env/bin/activate
pip3 install -r requirements.txt

echo "\n\n"

echo "Setup for Task Scheduler BSE Completed"

echo "\n"

# NSE

cd $BSESCHEDULERDIR

touch secret.ini
echo "[API_KEY] \n
key=${API_KEY}\
" >secret.ini

python3 -m venv env
source env/bin/activate
pip3 install -r requirements.txt

echo "\n\n"

echo "Setup for Task Scheduler NSE Completed"

echo "\n"

# Money Control

cd $MCSCHEDULERDIR

touch secret.ini
echo "[API_KEY] \n
key=${API_KEY}\
" >secret.ini

python3 -m venv env
source env/bin/activate
pip3 install -r requirements.txt

echo "\n\n"

echo "Setup for Task Scheduler Money Control Completed"

echo "\n"

echo "Setup for Task Scheduler Complete"

echo "Repo build successfully\n"