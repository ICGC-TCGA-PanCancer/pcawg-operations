#!/bin/bash
keyfile="~/.ssh/wei-dkfz.pem"

if [ ! -f ~/.orchestra_subnet ]; then
    echo "Create your orchestra subnet file."
    exit 1
fi

subnet=`cat ~/.orchestra_subnet`
echo "Installing dependencies ..."
sudo apt-get install -y python-pip 2>&1 > /dev/null
sudo pip install netaddr 2>&1 > /dev/null
sudo sudo ln -s orchestra.py /bin/orchestra
sudo chmod +x orchestra.py

python subnet-install.py $subnet $keyfile

