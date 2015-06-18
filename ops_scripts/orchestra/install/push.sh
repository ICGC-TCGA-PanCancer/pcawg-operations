#!/bin/bash

# Installs the webservice onto a single worker node, and tests it for functionality
# Takes an ip address and a key file as arguments

# Although Orchestra will work in any posix environment, this install script
# is Ubuntu only

keyfile="$2"
target="$1"

connector () {

    _keyfile="$1"
    _target="$2"
    _command="$3"

    ssh -i ${_keyfile} ubuntu@${_target} "${_command}"

}

copy () {

    _keyfile="$1"
    _target="$2"
    _source="$3"
    _destination="$4"

    scp -i ${_keyfile} ${_source} ubuntu@${_target}:${_destination}


}

# Skip machines you can't ping

ping -c 3 $target
[[ $? -ne 0 ]] && exit 0

# Create the install script

echo "#!/bin/bash"                                                               > setup.sh
echo "echo \"INSTALLING ON $target\""                                            >> setup.sh
echo "# Test if docker is on this box"                                           >> setup.sh
echo "docker 2>&1 > /dev/null"                                                   >> setup.sh
echo "[[ $? -ne 0 ]] && exit 0"                                                  >> setup.sh
echo "# Install Orchestra"                                                       >> setup.sh
echo "sudo apt-get -y install git 2>&1 > /dev/null"                              >> setup.sh
echo "rm -rf gitroot 2>&1 > /dev/null"                                           >> setup.sh
echo "mkdir gitroot 2>&1 > /dev/null"                                            >> setup.sh
echo "cd gitroot"                                                                >> setup.sh
echo "git clone https://github.com/ICGC-TCGA-PanCancer/pcawg-operations.git 2>&1 > /dev/null"     >> setup.sh
echo "cd pcawg-operations/ops_scripts/orchestra/install"                         >> setup.sh
echo "sudo cp orchestra.service /etc/init.d/orchestra"                           >> setup.sh
echo "sudo update-rc.d orchestra defaults 2>&1 > /dev/null"                      >> setup.sh
echo "sudo chmod +x /etc/init.d/orchestra"					                     >> setup.sh
echo "sudo service orchestra start"                                              >> setup.sh

# Begin Remote Install

copy $keyfile $target "setup.sh" "setup.sh"
connector $keyfile $target "bash setup.sh"

# Cleanup

rm setup.sh

curl $target:9009/healthy

