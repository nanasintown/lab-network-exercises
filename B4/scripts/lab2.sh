#!/usr/bin/env bash

cat <<EOF | sudo debconf-set-selections
davfs2 davfs2/suid_file boolean false
EOF

sudo apt-get install nfs-common cifs-utils sshfs cadaver davfs2 -y

sudo adduser --disabled-password --gecos "" --uid 1003 testuser1
sudo adduser --disabled-password --gecos "" --uid 1002 testuser2

sudo -u testuser1 mkdir /home/testuser1/.ssh


sudo -u testuser1 tee -a /home/testuser1/.ssh/config <<EOL
Host lab1
    AddKeysToAgent yes
    IdentityFile /home/testuser1/.ssh/id_ed25519
    ForwardAgent yes
EOL

sudo -u testuser1 chmod 600 /home/testuser1/.ssh/id_ed25519
#### 2
sudo mount -t nfs lab1:/home /mnt
sudo -u testuser1 cat /mnt/testuser1/test.txt
sudo umount /mnt
#### 3
sudo mount -t cifs -o username=testuser1 -o password=123456 //lab1/testuser1 /mnt
cat /mnt/test.txt
sudo umount /mnt
#########
sudo -u testuser1 mkdir /home/testuser1/mnt
sudo -u testuser1 sshfs -o StrictHostKeyChecking=no lab1:/home/testuser1 /home/testuser1/mnt

echo "test" > test.txt

sudo tee -a /etc/davfs2/davfs2.conf <<< "use_locks 0"
sudo mkdir /mnt/webdav
sudo mount -t davfs http://lab1/webdav /mnt/webdav -o username=testuser <<< "123456"


#6
# sudo apt-get install nfs-common -y

sudo mkdir -p ~/mnt/nas-client
sudo mount -t nfs lab1:/mnt/nas ~/mnt/nas-client

# sudo mkdir /mnt/raid5
# sudo mount -t nfs lab1:/mnt/raid5 /mnt/raid5
cp ~/test.txt /mnt/raid5/test.txt

