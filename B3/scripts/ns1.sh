#!/usr/bin/env bash




cat >> ~/.ssh/config <<EOL
Host ns2
    AddKeysToAgent yes
    IdentityFile ~/.ssh/id_ed25519
    ForwardAgent yes

Host ns3
    AddKeysToAgent yes
    IdentityFile ~/.ssh/id_ed25519
    ForwardAgent yes

Host client
    AddKeysToAgent yes
    IdentityFile ~/.ssh/id_ed25519
    ForwardAgent yes
EOL

chmod 600 ~/.ssh/*

sudo tee /etc/bind/named.conf.options <<EOL
options {
    directory "/var/cache/bind";

    forwarders {
        # 127.0.0.1 port 5353;
        8.8.8.8;
    };

    recursion yes;
    allow-recursion { localnets; };

    listen-on { 127.0.0.1; 192.168.1.2; };
    allow-query { 127.0.0.1; 192.168.1.0/24; };
};
EOL

sudo tee /etc/bind/db.insec <<EOL
\$TTL 60
@	IN	SOA	ns1.insec. hostmaster.insec. (
			2024022701      ; Serial YYYYMMDDnn
			60		; refresh (1 minute)
			60		; retry (1 minute)
			604800		; expire (1 week)
			60	)	; minimum (1 minute)
			
@	IN	NS	ns1
@	IN	NS	ns2
ns1	IN	A	192.168.1.2
ns2 IN  A   192.168.1.3
ns3 IN  A   192.168.1.4
client IN  A   192.168.1.5

not.insec.	IN	NS	ns2.not.insec.
ns2.not.insec.	IN	A	192.168.1.3
EOL

sudo tee /etc/bind/1.168.192.in-addr.arpa <<EOL
\$TTL 60
@	IN	SOA	1.168.192.in-addr.arpa hostmaster.insec. (
			2024022701      ; Serial YYYYMMDDnn
			60		; refresh (1 minute)
			60		; retry (1 minute)
			604800		; expire (1 week)
			60	)	; minimum (1 minute)
			
@	IN	NS	ns1
@	IN	NS	ns2
192.168.1.2	IN	PTR	ns1
192.168.1.3	IN	PTR	ns2
192.168.1.4	IN	PTR	ns3
192.168.1.5	IN	PTR	client
EOL

sudo tee -a /etc/bind/named.conf.local <<EOL
zone "insec" {
	type master;
	file "/etc/bind/db.insec";
	allow-transfer {192.168.1.3; };
	also-notify {192.168.1.3; };
};

zone "1.168.192.in-addr.arpa" {
	type master;
	file "/etc/bind/db.1.168.192";
	allow-transfer {192.168.1.3; };
	also-notify {192.168.1.3; };
};

zone "not.insec" {
	type forward;
	forwarders { 192.168.1.3; };
};
EOL

sudo service bind9 restart
# done part 3.1

sudo mkdir -p /etc/pihole
sudo tee /etc/pihole/setupVars.conf <<EOL
PIHOLE_INTERFACE=enp0s8
PIHOLE_DNS_1=8.8.8.8
PIHOLE_DNS_2=8.8.4.4
QUERY_LOGGING=true
INSTALL_WEB_SERVER=false
INSTALL_WEB_INTERFACE=false
LIGHTTPD_ENABLED=false
CACHE_SIZE=10000
DNS_FQDN_REQUIRED=true
DNS_BOGUS_PRIV=true
DNSMASQ_LISTENING=local
BLOCKING_ENABLED=true
EOL

curl -L https://install.pi-hole.net | sudo PIHOLE_SKIP_OS_CHECK=true bash /dev/stdin --unattended
pihole -b google.com
# pihole -b -d google.com
sudo tee -a /etc/dnsmasq.conf <<EOL
port=5353
EOL
pihole restartdns