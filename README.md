#  pcawg-operations
./scripts contains scripts used to automatically update the blacklist once daily using this crontab
1 4 * * * sudo -u ubuntu bash /home/ubuntu/blacklist/update_blacklist.sh >> /home/ubuntu/logs/blacklist.log 2>&1
