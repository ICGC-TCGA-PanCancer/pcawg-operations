#!/bin/bash
keyfile="~/.ssh/wei-dkfz.pem"

subnet=`cat ~.orchestra_subnet`
echo "Installing dependencies ..."
echo "" > ~.orchestra_subnet
sudo apt-get install -y python-pip 2>&1 > /dev/null
sudo pip install netaddr 2>&1 > /dev/null
sudo cp orchestra.py /bin/bash/orchestra
sudo chmod +x /bin/bash/orchestra

python subnet-install.py $subnet $keyfile

