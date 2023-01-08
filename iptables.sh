#/bin/bash

systemctl stop firewalld 
systemctl disable firewalld
yum remove firewalld -y
yum install iptables-services -y
systemctl start iptables
systemctl enable iptables
