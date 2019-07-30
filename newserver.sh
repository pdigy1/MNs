#!/bin/bash

cd /root

#Create swap file

dd if=/dev/zero of=/var/swapfile bs=4096 count=1048576
mkswap /var/swapfile
swapon /var/swapfile
chmod 0600 /var/swapfile
chown root:root /var/swapfile
echo "/var/swapfile none swap sw 0 0" >> /etc/fstab

#Update linux
apt-get update && apt-get -y upgrade

#Allow SSH and enable firewall
ufw allow 22/tcp comment "SSH"
echo "y" | ufw enable

#Install zip and unzip tools
apt install zip unzip

#Get check.sh
wget https://getfile.dokpub.com/yandex/get/https://yadi.sk/d/98IK33Ka3UcCgg -O check.sh
chmod +x check.sh

#Finish
echo "New server setup complete. Delete this file with rm newserver.sh and reboot before installing any nodes."
