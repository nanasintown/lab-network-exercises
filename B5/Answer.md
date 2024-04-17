## 1.1

<!-- ```bash
vagrant@lab2:~$ sudo ip addr add 192.168.0.3/24 dev enp0s8
vagrant@lab3:~$ sudo ip addr add 192.168.2.3/24 dev enp0s8 -->

<!-- ```` -->

```bash
vagrant@lab1:~$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 02:5a:8d:6b:4f:52 brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 metric 100 brd 10.0.2.255 scope global dynamic enp0s3
       valid_lft 86015sec preferred_lft 86015sec
    inet6 fe80::5a:8dff:fe6b:4f52/64 scope link
       valid_lft forever preferred_lft forever
3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:27:8e:0a brd ff:ff:ff:ff:ff:ff
    inet 192.168.0.2/24 brd 192.168.0.255 scope global enp0s8
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe27:8e0a/64 scope link
       valid_lft forever preferred_lft forever
4: enp0s9: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:f2:5a:4c brd ff:ff:ff:ff:ff:ff
    inet 192.168.2.2/24 brd 192.168.2.255 scope global enp0s9
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fef2:5a4c/64 scope link
       valid_lft forever preferred_lft forever

```

```bash
vagrant@lab2:~$ ip addr show enp0s8
3: enp0s8: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether 08:00:27:bc:3c:f8 brd ff:ff:ff:ff:ff:ff
    inet 192.168.0.3/24 scope global enp0s8
       valid_lft forever preferred_lft forever

vagrant@lab3:~$ ip addr show enp0s8
3: enp0s8: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether 08:00:27:17:b3:b5 brd ff:ff:ff:ff:ff:ff
    inet 192.168.2.3/24 scope global enp0s8
       valid_lft forever preferred_lft forever
```

```bash
vagrant@lab3:~$ ping lab2
PING lab2 (192.168.0.3) 56(84) bytes of data.
From _gateway (10.0.2.2) icmp_seq=6 Destination Net Unreachable
From _gateway (10.0.2.2) icmp_seq=7 Destination Net Unreachable
From _gateway (10.0.2.2) icmp_seq=8 Destination Net Unreachable
From _gateway (10.0.2.2) icmp_seq=9 Destination Net Unreachable
^C
--- lab2 ping statistics ---
9 packets transmitted, 0 received, +4 errors, 100% packet loss, time 8666ms
```

## 2.1 What is the purpose of each of the generated files? Which ones are needed by the client?

```bash
The purpose of each of the generated files in the PKI for OpenVPN is as follows:

Master Certificate Authority (CA) certificate/key: This is the root certificate/key that is used to sign all other certificates in the PKI. It is used to establish trust between the OpenVPN server and the clients.
Server certificate/key: This certificate/key is used by the OpenVPN server to authenticate itself to the clients.
Client certificate/key: This certificate/key is used by the OpenVPN clients to authenticate themselves to the server.
Diffie-Hellman (DH) parameters: These parameters are used to establish the initial encryption key that is used for the OpenVPN connection.
HMac signature: This is used to authenticate the OpenVPN packets and prevent unauthorized access.

Client

ca.key
vpnclient.crt
vpnclient.key
dh.pem
```

## 2.2 Is there a simpler way of authentication available in OpenVPN? What are its benefits/drawbacks?

```bash
Yes

there is a simpler way of authentication available in OpenVPN called "static key authentication". In this method, a pre-shared secret key is used instead of a PKI.
Another simpler way is to securely obtain a username and password from a connecting client, and to use that information as a basis for authenticating the client. It is also possible to disable the use of client certificates, and force username/password authentication only.
Use client-cert-not-required may also remove the cert and key directives from the client configuration file, but not the ca directive, because it is necessary for the client to verify the server certificate.
The benefit of this method is that it is simple to set up and does not require the overhead of a PKI. However, the drawback is that it is less secure than using a PKI, as there is only one shared secret key for all clients and the server. This means that if the key is compromised, all clients are compromised.
```

## 3.1

```bash
# server.conf
dev tap0
server-bridge 192.168.0.2 255.255.255.0 192.168.0.50 192.168.0.100
```

This configuration sets up OpenVPN to operate in bridged mode (`dev tap0`), with the server acting as a bridge between the VPN and the physical network (`server-bridge`). The server's bridge interface is assigned the IP address `192.168.0.2`, and it dynamically assigns IP addresses to VPN clients from the range `192.168.0.50` to `192.168.0.100`.

## 3.2 What IP address space did you allocate to the OpenVPN clients?

```bash
192.168.0.2/24 192.168.0.50-192.168.0.100

```

The server itself will use `192.168.0.2` as its bridge interface address within the OpenVPN network.

## 3.3 Where can you find the log messages of the server by default? How can you change this?

The log messages of the OpenVPN server are typically stored in the syslog on Linux systems. However, the location can be changed by modifying the "status", "log", "log-append" option in the OpenVPN server configuration file. Additionally, the "verb" option can be used to control the verbosity of the log messages.

## 4.1

(Can also use ip a)

```bash
vagrant@lab1:~$ sudo /etc/openvpn/bridge-start
2024-03-31 12:28:30 TUN/TAP device tap0 opened
2024-03-31 12:28:30 Persist state set to: ON
```

```bash
vagrant@lab1:~$ ifconfig
br0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.0.2  netmask 255.255.255.0  broadcast 192.168.0.255
        inet6 fe80::f456:fbff:fed0:8f0b  prefixlen 64  scopeid 0x20<link>
        ether f6:56:fb:d0:8f:0b  txqueuelen 1000  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 9  bytes 774 (774.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

enp0s3: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 10.0.2.15  netmask 255.255.255.0  broadcast 10.0.2.255
        inet6 fe80::5a:8dff:fe6b:4f52  prefixlen 64  scopeid 0x20<link>
        ether 02:5a:8d:6b:4f:52  txqueuelen 1000  (Ethernet)
        RX packets 52298  bytes 75078992 (75.0 MB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 9626  bytes 704935 (704.9 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

enp0s8: flags=4419<UP,BROADCAST,RUNNING,PROMISC,MULTICAST>  mtu 1500
        inet6 fe80::a00:27ff:fe27:8e0a  prefixlen 64  scopeid 0x20<link>
        ether 08:00:27:27:8e:0a  txqueuelen 1000  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 30  bytes 2412 (2.4 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

enp0s9: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.2.2  netmask 255.255.255.0  broadcast 192.168.2.255
        inet6 fe80::a00:27ff:fef2:5a4c  prefixlen 64  scopeid 0x20<link>
        ether 08:00:27:f2:5a:4c  txqueuelen 1000  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 21  bytes 1626 (1.6 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 108  bytes 10545 (10.5 KB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 108  bytes 10545 (10.5 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

tap0: flags=4355<UP,BROADCAST,PROMISC,MULTICAST>  mtu 1500
        ether 7e:f7:39:b2:2f:02  txqueuelen 1000  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```

## 4.2

Routing and bridging are two different methods for connecting VPN clients to a network. Here's a brief comparison of the two and when you might use each:

1. **Routing:**

   - In routing, VPN clients are assigned IP addresses from a separate subnet and communicate with the VPN server through IP routing.
   - Benefits:
     - Easier to set up and manage.
     - Lower overhead due to reduced broadcast traffic.
     - Better security since you can apply firewall rules on the VPN subnet.
     - Typically more scalable, as it works well with large networks.
   - Disadvantages:

     - Inability to handle certain network configurations like when devices require Layer 2 (Ethernet) visibility.

     - Routing requires more configuration on the client-side, and may not be as straightforward as setting up a bridge.

2. **Bridging:**

   - In bridging, VPN clients are connected directly to the local network, appearing as if they are physically connected to the same LAN as the VPN server.
   - Benefits:
     - Bridging is simpler to set up and manage than routing, especially for small-scale networks.
     - it allows to connect multiple devices and networks as if they were on the same LAN.
       -Bridging is useful for applications that rely on broadcast traffic, such as DHCP, ARP, and some network discovery protocols.
   - Disadvantages:

     - Bridging can lead to broadcast storms and network congestion if the network is too large or has too many connected devices.

     - Bridging can be less secure than routing as firewall rules cannot be applied at the VPN subnet level.

**When to use routing:**

- Routing is typically preferred in scenarios where you need to segregate VPN traffic from the local network, or when scalability and network efficiency are important factors.

**When to use bridging:**

- Bridging is useful when VPN clients need seamless access to resources on the local network, such as file shares or printers, and when broadcast and multicast support are required.

## 5.1

```bash
# client.conf
dev tap (bridging)
remote lab1 1194 udp
ca ca.crt
cert vpnclient.crt (Use correct name)
key vpnclient.key (use correct name)
tls-auth /etc/openvpn/ta.key 1
```

## 5.2 Demonstrate that you can reach the SS from the RW. Setup a server on the client with netcat and connect to this with telnet/nc. Send messages to both directions.

```bash
vagrant@lab2:~$ nc -l 8080
vagrant@lab3:~$ nc lab2 8080
```

## 5.3 Capture incoming/outgoing traffic on GW's enp0s9 or RW's enp0s8. Why can't you read the messages sent in 5.2 (in plain text) even if you comment out the cipher command in the config-files?

Because after openVPN v2.4 client/server will automatically negotiate AES-256-GCM in TLS mode, the OpenVPN protocol encapsulates the messages inside encrypted packets using SSL/TLS encryption. The messages are only decrypted on the receiving end after going through the OpenVPN encryption and decryption process.

```bash
vagrant@lab1:~$ sudo tcpdump -i enp0s9 -s 0 -w - port 1194
```

```bash
vagrant@lab1:~$ sudo tcpdump -i enp0s8
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on enp0s8, link-type EN10MB (Ethernet), snapshot length 262144 bytes
13:37:01.467253 IP6 lab1 > ip6-allrouters: ICMP6, router solicitation, length 16
13:37:45.835983 ARP, Request who-has lab2 tell lab1, length 28
13:37:47.005013 ARP, Request who-has lab2 tell lab1, length 28
13:37:48.112751 ARP, Request who-has lab2 tell lab1, length 28
13:37:49.662241 ARP, Request who-has lab2 tell lab1, length 28
13:37:50.709391 ARP, Request who-has lab2 tell lab1, length 28
13:37:51.822201 ARP, Request who-has lab2 tell lab1, length 28
```

## 5.4 Enable ciphering. Is there a way to capture and read the messages sent in 5.2 on GW despite the encryption? Where is the message encrypted and where is it not?

Yes, as enabling ciphering in the OpenVPN configuration will only encrypt the messages being sent between the client and the server using SSL/TLS encryption. The encryption only happens on the client-side after sending the messages and on the server-side before receiving the messages. Therefore, if we capture the packets using a packet capture tool like tcpdump or Wireshark at br0, enp0s8, we are able to read the messages in plain text.

Also, as we store certificates on GW (lab1), we have the correct encryption keys or certificates, so we can also decrypt the captured packets and read the messages in plain text. This can be done using Wireshark's SSL/TLS decryption feature. By providing the decryption keys or certificates, Wireshark can decrypt the captured packets and display the contents in plain text.

## 5.5

```bash
vagrant@lab2:~$ traceroute lab3
traceroute to lab3 (192.168.2.3), 64 hops max
  1   10.0.2.2  80.461ms  0.373ms  0.334ms
  2   192.168.0.1  3.632ms  92.730ms  35.364ms
```

Traceroute displays the route packets take from the source to the destination, showing each hop's IP address and round-trip time (RTT). In this example, packets first reach the router at 10.0.2.2 with varying RTT values, then proceed to the next hop at 192.168.0.1 before reaching the destination at 192.168.2.3.

```bash
vagrant@lab3:~$ traceroute lab2
traceroute to lab2 (192.168.0.3), 64 hops max
  1   10.0.2.2  70.379ms  38.333ms  42.687ms
```

This traceroute output indicates the path taken by packets from the source "lab3" to the destination "lab2" with the IP address 192.168.0.3, allowing a maximum of 64 hops. The output displays that the packets first reach the router at 10.0.2.2, with round-trip time (RTT) values of 70.379ms, 38.333ms, and 42.687ms for three consecutive packets.

## 6.1

```bash
# server.conf
dev tun
# # Configure server mode and supply a VPN subnet
# for OpenVPN to draw client addresses from.
# The server will take 10.8.0.1 for itself,
# the rest will be made available to clients.
# Each client will be able to reach the server
# on 10.8.0.1. Comment this line out if you are
# ethernet bridging. See the man page for more info.
server 10.8.0.0 255.255.255.0
push "route 192.168.0.0 255.255.255.0" # subnet address space behind the openvpn server
```

In the `server.conf` file, the `server` directive configures the OpenVPN server to operate in server mode, using the VPN subnet `10.8.0.0/24`. This means the server will have the IP address `10.8.0.1`, and the remaining IP addresses in the subnet will be available for clients to connect to. Additionally, the `push` directive is used to push a route to the clients, allowing them to access the subnet `192.168.0.0/24` behind the OpenVPN server.

```bash
vagrant@lab1:~$ sudo systemctl restart openvpn@server
vagrant@lab3:~$ sudo systemctl restart openvpn@client
```

## 6.2

```bash
vagrant@lab1:~$ ifconfig
br0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.0.2  netmask 255.255.255.0  broadcast 192.168.0.255
        inet6 fe80::f456:fbff:fed0:8f0b  prefixlen 64  scopeid 0x20<link>
        ether f6:56:fb:d0:8f:0b  txqueuelen 1000  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 30  bytes 1908 (1.9 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

enp0s3: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 10.0.2.15  netmask 255.255.255.0  broadcast 10.0.2.255
        inet6 fe80::5a:8dff:fe6b:4f52  prefixlen 64  scopeid 0x20<link>
        ether 02:5a:8d:6b:4f:52  txqueuelen 1000  (Ethernet)
        RX packets 54342  bytes 75245276 (75.2 MB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 11509  bytes 861821 (861.8 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

enp0s8: flags=4419<UP,BROADCAST,RUNNING,PROMISC,MULTICAST>  mtu 1500
        inet6 fe80::a00:27ff:fe27:8e0a  prefixlen 64  scopeid 0x20<link>
        ether 08:00:27:27:8e:0a  txqueuelen 1000  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 53  bytes 3902 (3.9 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

enp0s9: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.2.2  netmask 255.255.255.0  broadcast 192.168.2.255
        inet6 fe80::a00:27ff:fef2:5a4c  prefixlen 64  scopeid 0x20<link>
        ether 08:00:27:f2:5a:4c  txqueuelen 1000  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 44  bytes 3026 (3.0 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 210  bytes 25155 (25.1 KB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 210  bytes 25155 (25.1 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

tap0: flags=4355<UP,BROADCAST,PROMISC,MULTICAST>  mtu 1500
        ether 7e:f7:39:b2:2f:02  txqueuelen 1000  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

tun0: flags=4305<UP,POINTOPOINT,RUNNING,NOARP,MULTICAST>  mtu 1500
        inet 10.8.0.1  netmask 255.255.255.255  destination 10.8.0.2
        inet6 fe80::2692:f5e6:614d:2921  prefixlen 64  scopeid 0x20<link>
        unspec 00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00  txqueuelen 500  (UNSPEC)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 6  bytes 288 (288.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```
