# S3 Migration Service

This webservice will process reports from store-and-forward workflows to track processed GNOS entities for elasticsearch:

#### Configure Apache:
`sudo apt-get install apache2 git`<br>
`mkdir /home/ubuntu/gitroot && cd /home/ubuntu/gitroot`<br>
`git clone https://github.com/ICGC-TCGA-PanCancer/pcawg-operations.git`<br>
`sudo cp /home/ubuntu/gitroot/pcawg-operations/s3_migration/apache.config /etc/apache2/sites-available/default`<br>
`sudo a2enmod proxy`<br>
`sudo service apache2 restart`<br>


####Start the Webservice:
`sudo useradd -r -s /bin/false s3migration`<br>
`sudo cp /s3_migration /`<br>
<br>
