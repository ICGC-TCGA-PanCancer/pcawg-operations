# S3 Migration Service

This webservice will process reports from store-and-forward workflows to track processed GNOS entities for elasticsearch:

#### Configure Apache:
`sudo apt-get install apache2 git`
`mkdir /home/ubuntu/gitroot && cd /home/ubuntu/gitroot`
`git clone`
`sudo cp /s3_migration/ /etc/apache2/sites-available/default`
`sudo a2enmod proxy`
`sudo service apache2 restart`


####Start the Webservice:
`sudo useradd -r -s /bin/false s3migration<br>
sudo cp /s3_migration /<br>`
<br>
