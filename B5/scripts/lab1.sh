#!/usr/bin/env bash


cat >> ~/.ssh/config <<EOL
Host lab2
    AddKeysToAgent yes
    IdentityFile ~/.ssh/id_ed25519
    ForwardAgent yes

Host lab3
    AddKeysToAgent yes
    IdentityFile ~/.ssh/id_ed25519
    ForwardAgent yes
EOL

chmod 600 ~/.ssh/*

sudo cp /vagrant/Server/pki/private/server.key /etc/openvpn/
sudo cp /vagrant/CA/pki/issued/server.crt /etc/openvpn/
sudo cp /vagrant/CA/pki/ca.crt /etc/openvpn/
sudo cp /vagrant/Server/pki/dh.pem /etc/openvpn/
sudo cp /vagrant/Server/ta.key /etc/openvpn/

sudo cp /vagrant/server.conf /etc/openvpn/

sudo cp /usr/share/doc/openvpn/examples/sample-scripts/bridge-start /etc/openvpn/
sudo sed -i 's/eth0/enp0s8/g' /etc/openvpn/bridge-start
sudo sed -i 's/192.168.8./192.168.0./g' /etc/openvpn/bridge-start
sudo sed -i 's/192.168.0.4/192.168.0.2/g' /etc/openvpn/bridge-start
sudo /etc/openvpn/bridge-start
# These commands use `sed` to perform search and 
# replace operations in the file `/etc/openvpn/bridge-start`. 
# They replace occurrences of "eth0" with "enp0s8", IP addresses 
# starting with "192.168.8." with "192.168.0.", 
# and the IP address "192.168.0.4" with "192.168.0.2", respectively. 
# These modifications are likely made to adapt the script to changes 
# in network interface names and IP address ranges.


## Start server
sudo systemctl enable openvpn@server --now

sudo cp /usr/share/doc/openvpn/examples/sample-scripts/bridge-stop /etc/openvpn/

# sudo systemctl stop openvpn@server
# sudo /etc/openvpn/bridge-stop

# sudo cp /vagrant/server-routed.conf /etc/openvpn/server.conf
# sudo systemctl start openvpn@server

sudo sysctl -w net.ipv4.ip_forward=1
sudo iptables -t nat -A POSTROUTING -o enp0s8 -j MASQUERADE


