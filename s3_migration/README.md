This webservice will process reports from store-and-forward workflows to track processed GNOS entities for elasticsearch:

Configure Apache:

sudo apt-get install apache2 git
git clone 
sudo cp /s3_migration/ /etc/apache2/sites-available/default
sudo a2enmod proxy
sudo service apache2 restart

Start the Webservice:
sudo useradd -r -s /bin/false s3migration
sudo cp /s3_migration /
