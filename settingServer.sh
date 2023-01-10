#!/bin/bash

clear
yum install epel-release nano wget httpd -y
clear

#echo "Enter WAN ip_address you server: "
#read wanip

wanip=$(wget -qO- eth0.me) # Auto IP
echo $wanip
sleep 15

#echo "Enter password for CA cert: "
#read passwordcacert

sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

# Comment or uncomment needs strings (depends from you firewall) 

#systemctl enable firewalld
#systemctl start firewalld
#firewall-cmd --permanent --add-port=443/udp
#firewall-cmd --permanent --zone=public --add-port=80/tcp
#firewall-cmd --reload

iptables -I INPUT -p tcp --dport 80 -j ACCEPT
iptables -I INPUT -p tcp --dport 443 -j ACCEPT
iptables -I INPUT -p udp --dport 80 -j ACCEPT
iptables -I INPUT -p udp --dport 443 -j ACCEPT

yum install openvpn easy-rsa dnsmasq -y

cd /usr/share/easy-rsa/3
touch vars
echo "export KEY_COUNTRY=\"EU\"" >> vars
echo "export KEY_PROVINCE=\"UNKNOW\"" >> vars
echo "export KEY_CITY=\"UNKNOW\"" >> vars
echo "export KEY_ORG=\"UNKNOW\"" >> vars
echo "export KEY_EMAIL=\"UNKNOW@UNKNOW.UNKNOW\"" >> vars
echo "export KEY_CN=\"UNKNOW\"" >> vars
echo "export KEY_OU=\"UNKNOW\"" >> vars
echo "export KEY_NAME=\"UNKNOW\"" >> vars
echo "export KEY_ALTNAMES=\"UNKNOW\"" >> vars

. ./vars
./easyrsa init-pki
./easyrsa build-ca
./easyrsa gen-dh

clear

#if [[ $servercert ]] 
#then 
#./easyrsa gen-req vpn-server
#else
./easyrsa gen-req vpn-server nopass
#fi

./easyrsa sign-req server vpn-server
openvpn --genkey --secret pki/ta.key

mkdir /etc/openvpn/keys
cp -r pki/* /etc/openvpn/keys/

mkdir /var/log/openvpn

systemctl enable openvpn@server
systemctl start openvpn@server

cd /usr/share/easy-rsa/3

clear

#if [[ $clientcert ]] 
#then 
#./easyrsa gen-req client
#else
./easyrsa gen-req client nopass
#fi

./easyrsa sign-req client client
mkdir /tmp/keys
cp pki/issued/client.crt pki/private/client.key pki/dh.pem pki/ca.crt pki/ta.key /tmp/keys
chmod -R a+r /tmp/keys

echo "local $wanip" >> /etc/openvpn/server.conf
echo "port 443" >> /etc/openvpn/server.conf
echo "proto udp4" >> /etc/openvpn/server.conf
echo "dev tun" >> /etc/openvpn/server.conf
echo "ca keys/ca.crt" >> /etc/openvpn/server.conf
echo "cert keys/issued/vpn-server.crt" >> /etc/openvpn/server.conf
echo "key keys/private/vpn-server.key" >> /etc/openvpn/server.conf
echo "dh keys/dh.pem" >> /etc/openvpn/server.conf
echo "tls-auth keys/ta.key 0" >> /etc/openvpn/server.conf
echo "server 172.16.10.0 255.255.255.0" >> /etc/openvpn/server.conf
echo "ifconfig-pool-persist ipp.txt" >> /etc/openvpn/server.conf
echo "keepalive 10 120" >> /etc/openvpn/server.conf
echo "max-clients 32" >> /etc/openvpn/server.conf
echo "client-to-client" >> /etc/openvpn/server.conf
echo "persist-key" >> /etc/openvpn/server.conf
echo "persist-tun" >> /etc/openvpn/server.conf
echo "status /var/log/openvpn/openvpn-status.log" >> /etc/openvpn/server.conf
echo "log-append /var/log/openvpn/openvpn.log" >> /etc/openvpn/server.conf
echo "verb 0" >> /etc/openvpn/server.conf
echo "mute 20" >> /etc/openvpn/server.conf
echo "daemon" >> /etc/openvpn/server.conf
echo "mode server" >> /etc/openvpn/server.conf
echo "tls-server" >> /etc/openvpn/server.conf
echo "comp-lzo" >> /etc/openvpn/server.conf
echo "push \"redirect-gateway def1\"" >> /etc/openvpn/server.conf
echo "push \"dhcp-option DNS 8.8.8.8\"" >> /etc/openvpn/server.conf

echo "listen-address=127.0.0.1,172.16.10.1" >> /etc/dnsmasq.conf 
echo "bind-interfaces" >> /etc/dnsmasq.conf 

echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf #Activete Redirect traffic beetwen interfaces after reload
echo 1 > /proc/sys/net/ipv4/ip_forward #Activete Redirect traffic beetwen interfaces now

chmod +x /etc/rc.local
chmod 0777 /etc/rc.local

#firewall-cmd --direct --permanent --add-rule ipv4 filter FORWARD 0 -i eth0 -o tun0 -j ACCEPT
#firewall-cmd --direct --permanent --add-rule ipv4 filter FORWARD 0 -i tun0 -o eth0 -j ACCEPT
#firewall-cmd --permanent --zone=dmz --add-masquerade
#firewall-cmd --permanent --add-masquerade
#firewall-cmd --permanent --direct --add-rule ipv4 nat POSTROUTING 0 -o eth0 -j MASQUERADE
#firewall-cmd --direct --permanent --add-rule ipv4 filter FORWARD 0 -i eth0 -o tun0 -m state --state RELATED,ESTABLISHED -j ACCEPT

iptables -I INPUT -i eth0 -m state --state NEW -p udp --dport 443 -j ACCEPT
iptables -I FORWARD -i tun+ -j ACCEPT  
iptables -I FORWARD -i tun+ -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT  
iptables -I FORWARD -i eth0 -o tun+ -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -t nat -A POSTROUTING -s 172.16.10.0/24 -o eth0 -j MASQUERADE
iptables -A OUTPUT -o tun+ -j ACCEPT



echo "service dnsmasq start" >> /etc/rc.local

mkdir /var/www/html/keys
cp -rf /tmp/keys/* /var/www/html/keys
cd /var/www/html
tar -cvf keys.tar.gz keys
cp keys.tar.gz keys/

cd  /var/www/html/keys
tar -cvf client.tar.gz client.*
systemctl start httpd

clear

echo "Please download you key pack, in browser: http://"$wanip"/keys/keys.tar.gz"
echo "Please download you key pack for newClient, in browser: http://"$wanip"/keys/client.tar.gz"
echo "After reboot web server will disable and server reboot"
echo "Warning: You have ONE minute for download"

secs=$((5 * 12))
while [ $secs -gt 0 ]; do
   echo -ne "$secs\033[0K\r"
   sleep 1
   : $((secs--))
done

reboot
