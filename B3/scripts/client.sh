#!/usr/bin/env bash




sudo sed -i 's/nameserver .*/nameserver 192.168.1.2/' /etc/resolv.conf

# The command `sudo sed -i 's/nameserver .*/nameserver 192.168.1.2/' /etc/resolv.conf` 
# utilizes the `sed` stream editor to modify the `/etc/resolv.conf` file. 
# It replaces any existing `nameserver` entries in the file with `nameserver 192.168.1.2`, 
# effectively configuring the system to use the specified DNS server (`192.168.1.2`). 
# The `-i` option ensures that the changes are made directly in the file, allowing for 
# seamless modification of DNS resolver settings with superuser privileges.