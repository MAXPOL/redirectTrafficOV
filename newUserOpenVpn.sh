#!/bin/bash

wanip=$(wget -qO- eth0.me) # Auto IP
echo $wanip

echo "Enter new client name for cert and key: "
read newClientName

cd /usr/share/easy-rsa/3
. ./vars

./easyrsa gen-req $newClientName nopass
./easyrsa sign-req client $newClientName

cp /usr/share/easy-rsa/3/pki/issued/$newClientName.crt /var/www/html/keys/
cp /usr/share/easy-rsa/3/pki/private/$newClientName.key /var/www/html/keys/

cd /var/www/html/keys/

tar -cvf $newClientName.tar.gz $newClientName.crt $newClientName.key
rm -rf $newClientName.crt $newClientName.key

systemctl start httpd

clear

echo "Please download you key pack for newClient, in browser: http://"$wanip"/keys/"$newClientName".tar.gz"
echo "Warning: You have ONE minute for download"

secs=$((5 * 12))
while [ $secs -gt 0 ]; do
   echo -ne "$secs\033[0K\r"
   sleep 1
   : $((secs--))
done

systemctl stop httpd

clear

echo "Complete !"#!/bin/bash

wanip=$(wget -qO- eth0.me) # Auto IP
echo $wanip

echo "Enter new client name for cert and key: "
read newClientName

cd /usr/share/easy-rsa/3
. ./vars

./easyrsa gen-req $newClientName nopass
./easyrsa sign-req client $newClientName

cp /usr/share/easy-rsa/3/pki/issued/$newClientName.crt /var/www/html/keys/
cp /usr/share/easy-rsa/3/pki/private/$newClientName.key /var/www/html/keys/

cd /var/www/html/keys/

tar -cvf $newClientName.tar.gz $newClientName.crt $newClientName.key
rm -rf $newClientName.crt $newClientName.key

systemctl start httpd

clear

echo "Please download you key pack for newClient, in browser: http://"$wanip"/keys/"$newClientName".tar.gz"
echo "Warning: You have ONE minute for download"

secs=$((5 * 12))
while [ $secs -gt 0 ]; do
   echo -ne "$secs\033[0K\r"
   sleep 1
   : $((secs--))
done

systemctl stop httpd

clear

echo "Complete !"
