#!/usr/bin/env bash

sudo apt-get install nfs-kernel-server samba elinks apache2 mdadm -yy

sudo adduser --disabled-password --gecos "" --uid 1003 testuser1
sudo adduser --disabled-password --gecos "" --uid 1002 testuser2

sudo -u testuser1 mkdir /home/testuser1/.ssh

sudo -u testuser1 tee -a /home/testuser1/.ssh/config <<EOL
Host lab1
    AddKeysToAgent yes
    IdentityFile /home/testuser1/.ssh/id_ed25519
    ForwardAgent yes
EOL


# sudo -u testuser1 chmod 600 /home/testuser1/.ssh/*

sudo tee -a /etc/exports <<EOL
/home lab2(rw,sync,no_subtree_check)
EOL
sudo systemctl restart nfs-kernel-server.service

# Ran in vagrant provision
sudo -u testuser1 tee /home/testuser1/test.txt <<< "Hello world"

sudo tee -a /etc/samba/smb.conf <<EOL
[homes]
   comment = Home Directories
   browseable = yes
   read only = no
   create mask = 0775
   directory mask = 0775
EOL
sudo systemctl reload smbd.service
sudo smbpasswd -a testuser1 -s << EOL
123456
123456
EOL
sudo smbpasswd -e testuser1
###

sudo mkdir -p /var/www/WebDAV/files
echo "hi" | sudo tee /var/www/WebDAV/files/hi.txt > /dev/null
sudo chown -R www-data:vagrant /var/www/WebDAV

sudo tee /etc/apache2/sites-available/000-default.conf > /dev/null <<EOF
<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html
        Alias /webdav "/var/www/WebDAV/files"
        <Directory "/var/www/WebDAV/files">
            Options Indexes FollowSymLinks
            AllowOverride None
            Require all granted
        </Directory>
        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF
sudo service apache2 restart
# ----> vagrant@lab1:~$ elinks http://lab1/webdav
sudo a2enmod auth_digest
sudo service apache2 restart
sudo htdigest -c /var/www/WebDAV/.htdigest "webdav" testuser
sudo chown www-data:root /var/www/WebDAV/.htdigest
sudo chmod 640 /var/www/WebDAV/.htdigest

sudo tee /etc/apache2/sites-available/000-default.conf > /dev/null <<EOF
<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html
        Alias /webdav "/var/www/WebDAV/files"
        <Directory "/var/www/WebDAV/files">
            Options Indexes FollowSymLinks
            AllowOverride None
            Require all granted
        </Directory>
        <Location /webdav>
            DAV On
            AuthType Digest
            AuthName "webdav"
            AuthUserFile /var/www/WebDAV/.htdigest
            Require valid-user
        </Location>
        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF
sudo service apache2 restart

### 6
sudo mdadm --create --verbose /dev/md0 --level=5 --raid-devices=3 /dev/sdc /dev/sdd /dev/sde
sudo mkfs.ext4 /dev/md0
sudo mkdir -p /mnt/nas
sudo mount /dev/md0 /mnt/nas
sudo mdadm --detail /dev/md0
sudo chmod 777 /mnt/raid5/

sudo apt-get install nfs-kernel-server -y
echo "/mnt/nas  *(rw,sync,no_root_squash,no_subtree_check)" | sudo tee -a /etc/exports
sudo service nfs-kernel-server restart
sudo systemctl restart nfs-kernel-server


sudo umount /dev/md0
sudo mdadm --manage --set-faulty /dev/md0 /dev/sdd
sudo mdadm --manage --remove /dev/md0 /dev/sdd
sudo mdadm --detail /dev/md0
sudo mkfs.ext4 /dev/sdd

sudo mdadm --manage --add /dev/md0 /dev/sdd

# Wait for raid to rebuild
sudo mdadm --wait /dev/md0
sudo mount /dev/md0 /mnt/nas
sudo mdadm --detail /dev/md0
