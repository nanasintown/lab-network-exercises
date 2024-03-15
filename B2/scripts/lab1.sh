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

sudo apt install -y nginx
sudo sed -i 's#http {# \
http { \
server { \
    listen 80; \
    server_name lab1; \
    location /apache { \
        rewrite /apache(/|$)(.*) /$2  break; \
        proxy_pass http://lab2:80/; \
    } \
    location /node { \
        proxy_pass http://lab3:8080/; \
    } \
}#g' /etc/nginx/nginx.conf

sudo systemctl restart nginx

sudo apt install -y nikto
EOL

