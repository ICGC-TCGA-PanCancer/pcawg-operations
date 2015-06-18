#!/bin/bash
subnet="10.252.1.135/32"
keyfile="~/.ssh/wei-dkfz.pem"

echo "Installing dependencies ..."
sudo apt-get install -y python-pip 2>&1 > /dev/null
sudo pip install netaddr 2>&1 > /dev/null

python subnet-install.py $subnet $keyfile

