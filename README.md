# redirectTrafficOV

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
