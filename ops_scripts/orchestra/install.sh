#!/bin/bash
subnet = "10.1.252.0/24"
keyfile = "~/.ssh/niall-dkfz-1.pem"

python subnet-install.py $subnet $keyfile

