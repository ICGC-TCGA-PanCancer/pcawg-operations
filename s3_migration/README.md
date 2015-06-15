# S3 Migration Service

This webservice will process reports from store-and-forward workflows to track processed GNOS entities for elasticsearch:

#### Configure Apache:
`sudo apt-get install apache2 git`<br>
`mkdir /home/ubuntu/gitroot && cd /home/ubuntu/gitroot`<br>
`git clone https://github.com/ICGC-TCGA-PanCancer/pcawg-operations.git`<br>
`sudo cp /home/ubuntu/gitroot/pcawg-operations/s3_migration/apache.config /etc/apache2/sites-available/default`<br>
`sudo a2enmod proxy`<br>
Take a minute now and enable the proxy and ssl modules in:<br>
/etc/apache2/mods-enabled (symlinks to /etc/apache2/mods-available)<br>
`cd /etc/apache2/mods-enabled<br>`
`sudo ln -s ../mods-available/proxy_http.load .`<br>
`sudo ln -s ../mods-available/ssl.* .`<br>

#### Generate the certificates
**Get a hold of the server.pem/server.key files and put them in /home/ubuntu/.ssh**<br>
`sudo service apache2 restart`<br>


####Start the Webservice:
`sudo useradd -r -s /bin/false s3migration`<br>
`sudo cp /home/ubuntu/gitroot/pcawg-operations/s3_migration/s3migration.service /etc/init.d/s3migration`<br>
`sudo chmod +x /etc/init.d/s3migration`<br>
`sudo update-rc.d s3migration defaults`<br>
`sudo service s3migration start`<br>
<br>
