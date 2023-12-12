#!/bin/bash
sudo yum -y update
sudo yum -y install httpd
cd /var/www/html/
sudo curl -0 https://acs730-group6-s3bucket.s3.amazonaws.com/index.html --output index.html
sudo curl -0 https://acs730-group6-s3bucket.s3.amazonaws.com/acs7301.jpg --output acs730.jpg 
sudo systemctl start httpd
sudo systemctl enable httpd
sudo systemctl restart httpd