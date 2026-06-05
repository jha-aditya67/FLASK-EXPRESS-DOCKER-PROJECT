#!/bin/bash

apt update -y
apt upgrade -y

apt install -y python3 python3-pip git

cd /home/ubuntu

git clone https://github.com/jha-aditya67/FLASK-EXPRESS-DOCKER-PROJECT.git app

cd app/backend

# Create virtual environment
python3 -m venv venv

# Activate venv
source venv/bin/activate

# Install dependencies inside venv
pip install --upgrade pip
pip install -r requirements.txt

# Run Flask app (IMPORTANT: bind to 0.0.0.0)
nohup python3 app.py > backend.log 2>&1 &

echo "Flask backend running with venv on port 5000"
