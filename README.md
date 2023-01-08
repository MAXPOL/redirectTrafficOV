# redirectTrafficOV

SERVER

______

systemctl start openvpn@server

systemctl status openvpn@server

systemctl enable openvpn@server

CLIENT
_______

For Windows client use GUI

For linux use command:

systemctl start openvpn-client@client.service

systemctl stop openvpn-client@client.service

systemctl enable openvpn-client@client.service

If you use in config server strings:

push "redirect-gateway def1"

push "dhcp-option DNS 8.8.8.8"

All traffic with client go via server

If not use it string you just connect VPN tunnel with server

IF NOT CONNECT
_____

Add this string in /etc/rc.local

iptables -I INPUT -p tcp --dport 80 -j ACCEPT

iptables -I INPUT -p tcp --dport 443 -j ACCEPT

iptables -I INPUT -p udp --dport 80 -j ACCEPT

iptables -I INPUT -p udp --dport 443 -j ACCEPT

iptables -I INPUT -i eth0 -m state --state NEW -p udp --dport 443 -j ACCEPT

iptables -I FORWARD -i tun+ -j ACCEPT

iptables -I FORWARD -i tun+ -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT

iptables -I FORWARD -i eth0 -o tun+ -m state --state RELATED,ESTABLISHED -j ACCEPT

iptables -t nat -A POSTROUTING -s 172.16.10.0/24 -o eth0 -j MASQUERADE

iptables -A OUTPUT -o tun+ -j ACCEPT
