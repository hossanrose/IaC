#!/bin/bash
sleep 5m
echo "--------------------------UserData Start---------------------------"
## Install AWS EFS Utilities / httpd
sudo yum update -y
sudo yum install -y amazon-efs-utils httpd 
sudo amazon-linux-extras install -y  php7.2
sudo systemctl start httpd
## Mount EFS
sudo mkdir /uploads
efs_id="${efs_id}"
sudo mount -t efs $efs_id:/ /uploads
## Edit fstab so EFS automatically loads on reboot
echo $efs_id:/ /uploads efs defaults,_netdev 0 0 | sudo tee -a /etc/fstab
## Setup wordpress
cd /tmp; sudo wget https://wordpress.org/latest.tar.gz
sudo tar -xvzf latest.tar.gz
sudo mv wordpress /var/www/html/cms
cd /var/www/html/cms/ 
sudo touch /var/www/html/index.html
sudo mv wp-config-sample.php wp-config.php
sudo sed -i "s/database_name_here/${name}/g" /var/www/html/cms/wp-config.php
sudo sed -i "s/username_here/${user}/g" /var/www/html/cms/wp-config.php
sudo sed -i "s/password_here/${pass}/g" /var/www/html/cms/wp-config.php
sudo sed -i "s/localhost/${addr}/g" /var/www/html/cms/wp-config.php
sudo ln -s /uploads /var/www/html/cms/wp-content/uploads
## Setting user
sudo useradd wordpress
sudo chown -R wordpress: /var/www/html/cms /uploads
echo "--------------------------UserData End---------------------------"

