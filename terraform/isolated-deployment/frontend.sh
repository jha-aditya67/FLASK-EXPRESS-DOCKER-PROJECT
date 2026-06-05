#!/bin/bash

apt update -y
apt upgrade -y

apt install -y nodejs npm git

cd /home/ubuntu

git clone https://github.com/jha-aditya67/FLASK-EXPRESS-DOCKER-PROJECT.git app

cd app/frontend

npm install

# Terraform will inject backend IP here
echo "BACKEND_URL=http://${backend_ip}:5000" > .env

# Patch the repo's hardcoded backend hostname to use the backend private IP
sed -i "s|http://backend:5000/submit|http://${backend_ip}:5000/submit|g" server.js

# Start frontend
nohup node server.js > frontend.log 2>&1 &

echo "Frontend running on port 3000"
