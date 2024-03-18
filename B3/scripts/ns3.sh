#!/usr/bin/env bash

sudo tee /etc/bind/named.conf.options <<EOL
options {
    directory "/var/cache/bind";

    listen-on { 127.0.0.1; 192.168.1.4; };
    allow-query { 127.0.0.1; 192.168.1.0/24; };
};
EOL

sudo tee /etc/bind/named.conf.local <<EOL
key ns2.key {
	algorithm hmac-sha1;
	secret "FuzYHMYE6D3IhrYgoAUvVZgVjMU=";
};

server 192.168.1.3 {
  keys { ns2.key; };
};

zone "not.insec" {
   type slave;
   file "/var/cache/bind/db.not.insec";
   masters { 192.168.1.3; };
};
EOL

sudo service bind9 restart