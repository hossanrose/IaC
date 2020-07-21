#!/bin/bash
sleep 1m
# Install AWS EFS Utilities / httpd
sudo yum install -y amazon-efs-utils httpd php php-mysql
sudo systemctl start httpd
# Mount EFS
sudo mkdir /uploads
efs_id="${efs_id}"
sudo mount -t efs $efs_id:/ /uploads
# Edit fstab so EFS automatically loads on reboot
echo $efs_id:/ /uploads efs defaults,_netdev 0 0 | sudo tee -a /etc/fstab
# Setup wordpress
cd /var/www/html
sudo wget https://wordpress.org/latest.tar.gz
sudo tar -xvzf latest.tar.gz

