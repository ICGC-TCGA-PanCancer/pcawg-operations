### orchestra

This is an experimental webservice for managing machines in a subnet.<br>
On your launcher node, clone this repo and navigate to this folder.<br><br>

The premise is very simple, a tiny webservice that runs on all machines.<br>
You can run ```orchestra list``` to poll the entire subnet to find workers.<br>
This allows you to generate lists of workers from the command line to poll or schedule to.<br><br>

#### Provision an Entire Subnet Automatically

To get started, put the CIDR of your subnet in this file:<br>
```vi ~/.orchestra_subnet```<br><br>

Next, edit the install script to point to your ssh keyfile:<br>
```vi install.sh```<br><br>

Once this is in place, you can install orchestra on the whole subnet:<br>
```bash install.sh```<br><br>

This will take some time to complete.<br>
Once it's done, you can do the following to confirm you can manage your machines:<br>
```orchestra list```<br><br>

#### Provision A Single Worker
Get the IP of your host.<br>
```bash install/push.sh [ip address]```<br><br>
