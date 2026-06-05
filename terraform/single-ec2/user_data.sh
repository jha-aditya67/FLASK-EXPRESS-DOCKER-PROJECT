#!/bin/bash

apt update -y
apt install -y python3 python3-pip nodejs npm git

cd /home/ubuntu

git clone https://github.com/jha-aditya67/FLASK-EXPRESS-DOCKER-PROJECT.git app

# Flask backend
cd app/backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
nohup venv/bin/python app.py &

# Express frontend
cd ../frontend
npm install
nohup npm start &
