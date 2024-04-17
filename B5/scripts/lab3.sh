#!/usr/bin/env bash

sudo cp pki/private/vpnclient.key /etc/openvpn/
sudo cp pki/issued/vpnclient.crt /etc/openvpn/
sudo cp pki/ca.crt /etc/openvpn/
sudo cp pki/dh.pem /etc/openvpn/
sudo cp ta.key /etc/openvpn/

sudo cp /usr/share/doc/openvpn/examples/sample-config-files/client.conf /etc/openvpn/

## Start client
sudo systemctl enable openvpn@client --now

# sudo systemctl stop openvpn@client
# sudo cp /vagrant/client-routed.conf /etc/openvpn/client.conf
# sudo systemctl start openvpn@client
# sudo systemctl stop openvpn@client
# sudo cp /vagrant/client.conf /etc/openvpn/
# sudo systemctl start openvpn@client
#################
sudo tee -a /usr/share/easy-rsa/vars > /dev/null <<EOF
export KEY_COUNTRY="FI"
export KEY_PROVINCE="Espoo"
export KEY_CITY="Espoo"
export KEY_ORG="aalto"
export KEY_EMAIL="nhut.cao@aalto.fi"
export KEY_OU="aalto"
EOF

# sudo source /usr/share/easy-rsa/vars

# sudo /usr/share/easy-rsa/easyrsa init-pki
# sudo /usr/share/easy-rsa/easyrsa build-ca nopass
# sudo /usr/share/easy-rsa/easyrsa build-server-full vpnserver nopass
# sudo /usr/share/easy-rsa/easyrsa build-client-full vpnclient nopass
# sudo /usr/share/easy-rsa/easyrsa gen-dh
# sudo /usr/sbin/openvpn --genkey secret ta.key


# sudo /usr/share/easy-rsa/easyrsa init-pki
# sudo /usr/share/easy-rsa/easyrsa build-ca nopass
# ./easyrsa gen-req vpnserver nopass  
# ./easyrsa sign-req server vpnserver
# sudo /usr/share/easy-rsa/easyrsa gen-dh
# sudo /usr/sbin/openvpn --genkey --secret ta.key
# Meeting ID: 676 6143 7829
# Passcode: 328315