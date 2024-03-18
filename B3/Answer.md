# Answer

## 2) Caching-only nameserver

- 2.1
  Forwarders: Specifies other DNS servers to which queries should be forwarded if the local server cannot answer them authoritatively.

```bash
vagrant@ns1:~$ cat /etc/bind/named.conf.options
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

```

```bash
The "directory" option sets the location where the nameserver should store its cache. The "forwarders" option specifies the IP address of the public nameserver (in this case, Google's public DNS server at 8.8.8.8) to which queries for which the nameserver does not have a cached answer should be forwarded. The "allow-recursion" and "allow-query" options restrict the nameserver to accept recursive queries and queries from local networks only. The "recursion" option is set to "yes" to enable the nameserver to perform recursive queries on behalf of its clients.
```

```bash
vagrant@ns1:~$ dig google.com @127.0.0.1

; <<>> DiG 9.18.18-0ubuntu0.22.04.2-Ubuntu <<>> google.com @127.0.0.1
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 63370
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: 88e4f38d95d6f84b0100000065db3cc75097b10aca96c420 (good)
;; QUESTION SECTION:
;google.com.			IN	A

;; ANSWER SECTION:
google.com.		18	IN	A	172.217.31.14

;; Query time: 699 msec
;; SERVER: 127.0.0.1#53(127.0.0.1) (UDP)
;; WHEN: Sun Feb 25 13:12:39 UTC 2024
;; MSG SIZE  rcvd: 83

```

Overall, the output confirms that the DNS server running on 127.0.0.1 responded with the IP address 172.217.31.14 for the domain name google.com. The query time was 699 milliseconds.

- 2.2

```markdown
A recursive query is a DNS query where the DNS resolver asks another DNS server to fully resolve the requested domain name on its behalf. The resolver expects a complete answer and relies on the DNS server to handle all necessary lookups recursively until it finds the final result. In contrast, an iterative query is a DNS query where the DNS resolver asks another DNS server for the best information it currently has, and the queried DNS server either provides the requested information or refers the resolver to another DNS server closer to the requested domain. In iterative queries, the resolver is responsible for conducting multiple queries until it finds the final result or receives a referral to the authoritative DNS server.
```

## 3)

- 3.1

```bash
The configuration I provided is for a primary master nameserver for the ".insec" domain, using the bind9 DNS server software. The nameserver is set up to be authoritative for the ".insec" domain and its reverse mapping zone, and to serve DNS queries for the domain and cache the results.

The configuration includes two zone files, one for the ".insec" domain and one for its reverse mapping zone. The zone files specify the SOA (Start of Authority) record, NS (Name Server) record, and A (Address) record for the host "ns1.insec". The SOA record provides information about the primary name server for the zone, the hostmaster's email address, and various time limits for refresh, retry, expire, and minimum TTL values.

The named configuration file, /etc/bind/named.conf, specifies the zones for ".insec" and its reverse mapping, and the location of the corresponding zone files. The configuration also disallows updates to the zones.

Finally, the bind9 service is restarted to apply the changes, and the syslog is checked for any error messages. The nameserver can be tested from a client machine using the dig command, which should resolve the host "ns1.insec" to its IP address.
```

- 3.2

```bash
vagrant@ns1:~$ dig ns1.insec @127.0.0.1

; <<>> DiG 9.18.18-0ubuntu0.22.04.2-Ubuntu <<>> ns1.insec @127.0.0.1
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 14378
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: 56f08d97224b38130100000065db43d65f51922f46e5d337 (good)
;; QUESTION SECTION:
;ns1.insec.			IN	A

;; ANSWER SECTION:
ns1.insec.		60	IN	A	192.168.1.2

;; Query time: 76 msec
;; SERVER: 127.0.0.1#53(127.0.0.1) (UDP)
;; WHEN: Sun Feb 25 13:42:46 UTC 2024
;; MSG SIZE  rcvd: 82

```

```bash
vagrant@ns1:~$ dig -x 192.168.1.2 @127.0.0.1

; <<>> DiG 9.18.18-0ubuntu0.22.04.2-Ubuntu <<>> -x 192.168.1.2 @127.0.0.1
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: SERVFAIL, id: 36057
;; flags: qr rd ra; QUERY: 1, ANSWER: 0, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: c8f611cc4ce43d030100000065db43f7dece3a3ba19b5410 (good)
;; QUESTION SECTION:
;2.1.168.192.in-addr.arpa.	IN	PTR

;; Query time: 0 msec
;; SERVER: 127.0.0.1#53(127.0.0.1) (UDP)
;; WHEN: Sun Feb 25 13:43:19 UTC 2024
;; MSG SIZE  rcvd: 81

```

The `-x` option indicates that a reverse DNS lookup should be performed. It queries the DNS server for the hostname associated with the specified IP address (`192.168.1.2`).

- 3.3 IP address to zone file

```bash
An IPv6 address entry can be added to a zone file by adding an AAAA record. The format for an AAAA record is:

hostname	IN	AAAA	IPv6Address
For example, if the hostname is "ns1" and the IPv6 address is "2001:0db8:85a3:0000:0000:8a2e:0370:.

```

## 4

- 4.1

```bash
vagrant@ns1:~$ sudo grep 'named' /var/log/syslog

Feb 25 14:16:45 ns1 named[1879]: client @0x7fdbac0060b8 192.168.1.3#39811 (insec): transfer of 'insec/IN': IXFR version not in journal, falling back to AXFR
Feb 25 14:16:45 ns1 named[1879]: client @0x7fdbac0060b8 192.168.1.3#39811 (insec): transfer of 'insec/IN': AXFR-style IXFR started (serial 2024022501)
Feb 25 14:16:45 ns1 named[1879]: client @0x7fdbac0060b8 192.168.1.3#39811 (insec): transfer of 'insec/IN': AXFR-style IXFR ended: 1 messages, 10 records, 255 bytes, 0.001 secs (255000 bytes/sec) (serial 2024022501)
```

```bash
vagrant@ns2:~$ sudo grep 'named' /var/log/syslog | grep 'transfer'

Feb 25 14:16:45 ns2 named[1665]: transfer of 'insec/IN' from 192.168.1.2#53: connected using 192.168.1.2#53
Feb 25 14:16:46 ns2 named[1665]: zone insec/IN: transferred serial 2024022501
Feb 25 14:16:46 ns2 named[1665]: transfer of 'insec/IN' from 192.168.1.2#53: Transfer status: success
Feb 25 14:16:46 ns2 named[1665]: transfer of 'insec/IN' from 192.168.1.2#53: Transfer completed: 1 messages, 10 records, 255 bytes, 0.467 secs (546 bytes/sec) (serial 2024022501)

```

- 4.2 Explain the changes you made.

```bash
To configure ns2 as a slave for the .insec domain, the following changes were made:

On the master server, an entry for the slave server was added in the .insec zone file, including an A record, a PTR record, and an NS record. The serial number of the zone was incremented.
The master server's named.conf file was updated to allow zone transfers to the slave server. The allow-transfer option was added to the zone definition for .insec.
On the slave server, the named.conf file was updated to include a zone definition for .insec as a slave zone, specifying the master server's IP address.
The configuration files for both servers were reloaded to apply the changes.
```

- 4.3 Provide the output of dig(1) for a successful query from the slave server. Are there any differences to the queries from the master?

```bash
vagrant@ns2:~$ dig ns1.insec @127.0.0.1

; <<>> DiG 9.18.18-0ubuntu0.22.04.2-Ubuntu <<>> ns1.insec @127.0.0.1
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 36720
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: 3a2976013572e07b0100000065db4caea559506209bade97 (good)
;; QUESTION SECTION:
;ns1.insec.			IN	A

;; ANSWER SECTION:
ns1.insec.		60	IN	A	192.168.1.2

;; Query time: 0 msec
;; SERVER: 127.0.0.1#53(127.0.0.1) (UDP)
;; WHEN: Sun Feb 25 14:20:30 UTC 2024
;; MSG SIZE  rcvd: 82


```

## 5)

- 5.1

```
On the master server ns2, create a zone file for .not.insec with the necessary A, PTR, and NS records. Make sure to increment the serial number for the zone.

Add an NS record for .not.insec in the .insec zone file, pointing to ns2.not.insec. This is to delegate the responsibility of the subdomain to ns2.

On ns3, configure it as a slave for the .not.insec domain. This can be done by creating a similar configuration as for the master, but without creating a zone file.

On the master server ns2, allow zone transfers to ns3.

Reload configuration files in all three servers and check the logs for any errors.

Verify that the zone files get transferred to the slave servers ns3. This can be done by checking if the zone file for .not.insec exists on ns3 and if it contains the latest updates.
```

- 5.2

```bash
vagrant@client:~$ dig ns2.not.insec @ns1

; <<>> DiG 9.18.18-0ubuntu0.22.04.2-Ubuntu <<>> ns2.not.insec @ns1
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 27566
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: 92417f5384e6300b0100000065db4db84046a369602b3958 (good)
;; QUESTION SECTION:
;ns2.not.insec.			IN	A

;; ANSWER SECTION:
ns2.not.insec.		60	IN	A	192.168.1.3

;; Query time: 4 msec
;; SERVER: 192.168.1.2#53(ns1) (UDP)
;; WHEN: Sun Feb 25 14:24:56 UTC 2024
;; MSG SIZE  rcvd: 86
```

```bash
vagrant@client:~$ dig ns2.not.insec @ns2

; <<>> DiG 9.18.18-0ubuntu0.22.04.2-Ubuntu <<>> ns2.not.insec @ns2
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 2446
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: 91cb519ca03478d20100000065db4dc42d055d609240ed4c (good)
;; QUESTION SECTION:
;ns2.not.insec.			IN	A

;; ANSWER SECTION:
ns2.not.insec.		60	IN	A	192.168.1.3

;; Query time: 4 msec
;; SERVER: 192.168.1.3#53(ns2) (UDP)
;; WHEN: Sun Feb 25 14:25:08 UTC 2024
;; MSG SIZE  rcvd: 86

```

```bash
vagrant@client:~$ dig ns2.not.insec @ns3

; <<>> DiG 9.18.18-0ubuntu0.22.04.2-Ubuntu <<>> ns2.not.insec @ns3
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 12471
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: 9a254a1dbef4d6320100000065ddffcc2ecd3f5648c8298d (good)
;; QUESTION SECTION:
;ns2.not.insec.			IN	A

;; ANSWER SECTION:
ns2.not.insec.		60	IN	A	192.168.1.3

;; Query time: 51 msec
;; SERVER: 192.168.1.4#53(ns3) (UDP)
;; WHEN: Tue Feb 27 15:29:16 UTC 2024
;; MSG SIZE  rcvd: 86

```

## 6

- 6.1
  > to implement transaction signatures in the .not.insec domain, the following steps can be taken: Generate a secret key to be shared between the master and slave name servers using the tsig-keygen command and selecting the HMAC-SHA1 algorithm.
  > Create a shared key file using the template provided, filling in the generated key and the IP address of the servers.
  > Make the key available to both name servers by including the key file in their named.conf files. Configure the servers to only allow transfers signed with the key by adding the appropriate statements in the named.conf files.Verify that an unauthenticated transfer fails and that an authenticated transfer using the transaction signature succeeds.

```bash
vagrant@ns2:~$ sudo tail -f /var/log/syslog

Feb 27 14:58:11 ns2 named[14137]: network unreachable resolving './DNSKEY/IN': 2001:500:1::53#53
Feb 27 14:58:11 ns2 named[14137]: network unreachable resolving './NS/IN': 2001:500:1::53#53
Feb 27 14:58:11 ns2 named[14137]: client @0x7fbd84009ac8 192.168.1.4#44823/key ns2.key (not.insec): transfer of 'not.insec/IN': IXFR version not in journal, falling back to AXFR
Feb 27 14:58:11 ns2 named[14137]: client @0x7fbd84009ac8 192.168.1.4#44823/key ns2.key (not.insec): transfer of 'not.insec/IN': AXFR-style IXFR started: TSIG ns2.key (serial 2024022701)
Feb 27 14:58:11 ns2 named[14137]: client @0x7fbd84009ac8 192.168.1.4#44823/key ns2.key (not.insec): transfer of 'not.insec/IN': AXFR-style IXFR ended: 1 messages, 6 records, 244 bytes, 0.092 secs (2652 bytes/sec) (serial 2024022701)
Feb 27 14:58:11 ns2 named[14137]: network unreachable resolving './DNSKEY/IN': 2001:dc3::35#53
Feb 27 14:58:11 ns2 named[14137]: resolver priming query complete: success
Feb 27 14:58:11 ns2 named[14137]: managed-keys-zone: Key 20326 for zone . is now trusted (acceptance timer complete)
Feb 27 14:58:13 ns2 named[14137]: zone 1.168.192.in-addr.arpa/IN: refresh: unexpected rcode (SERVFAIL) from primary 192.168.1.2#53 (source 0.0.0.0#0)
Feb 27 14:59:10 ns2 named[14137]: zone 1.168.192.in-addr.arpa/IN: refresh: unexpected rcode (SERVFAIL) from primary 192.168.1.2#53 (source 0.0.0.0#0)
Feb 27 15:00:56 ns2 named[14137]: zone 1.168.192.in-addr.arpa/IN: refresh: unexpected rcode (SERVFAIL) from primary 192.168.1.2#53 (source 0.0.0.0#0)
Feb 27 15:01:04 ns2 named[14137]: client @0x7fbd9000e658 192.168.1.4#40053 (not.insec): zone transfer 'not.insec/AXFR/IN' denied
Feb 27 15:01:25 ns2 named[14137]: zone insec/IN: Transfer started.
Feb 27 15:01:26 ns2 named[14137]: transfer of 'insec/IN' from 192.168.1.2#53: connected using 192.168.1.2#53
Feb 27 15:01:26 ns2 named[14137]: zone insec/IN: transferred serial 2024022701
Feb 27 15:01:26 ns2 named[14137]: transfer of 'insec/IN' from 192.168.1.2#53: Transfer status: success
Feb 27 15:01:26 ns2 named[14137]: transfer of 'insec/IN' from 192.168.1.2#53: Transfer completed: 1 messages, 10 records, 255 bytes, 0.352 secs (724 bytes/sec) (serial 2024022701)

```

> Unsuccessful attemp

```bash
vagrant@ns3:~$ dig @192.168.1.3 not.insec axfr

; <<>> DiG 9.18.18-0ubuntu0.22.04.2-Ubuntu <<>> @192.168.1.3 not.insec axfr
; (1 server found)
;; global options: +cmd
; Transfer failed.
```

- 6.2 TSIG is one way to implement transaction signatures. DNSSEC describes another, SIG(0). Explain the differences.

```bash
TSIG (Transaction SIGnature) is one way to implement transaction signatures in DNS. TSIG uses a shared secret key to sign the messages exchanged between name servers, providing authentication and integrity protection.

DNSSEC (Domain Name System Security Extensions) describes another way to implement transaction signatures, using digital signatures instead of shared secrets. DNSSEC uses public-key cryptography to sign the zone data, providing not only authentication and integrity protection but also confidentiality protection.

In conclusion, while both TSIG and DNSSEC provide transaction signature functionality, DNSSEC provides a more secure solution through the use of digital signatures and public-key cryptography.
```

## 7

- 7.1
  > Not block google.com

```bash
vagrant@ns1:~$ dig google.com

; <<>> DiG 9.18.18-0ubuntu0.22.04.2-Ubuntu <<>> google.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 39379
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;google.com.			IN	A

;; ANSWER SECTION:
google.com.		55	IN	A	142.250.207.78

;; Query time: 8 msec
;; SERVER: 10.0.2.3#53(10.0.2.3) (UDP)
;; WHEN: Mon Feb 26 05:29:06 UTC 2024
;; MSG SIZE  rcvd: 55

```

> Block google.com, there is no IP address in response

```bash
vagrant@ns1:~$ dig @192.168.1.2 google.com
;; communications error to 192.168.1.2#53: timed out
;; communications error to 192.168.1.2#53: timed out

; <<>> DiG 9.18.18-0ubuntu0.22.04.2-Ubuntu <<>> @192.168.1.2 google.com
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: SERVFAIL, id: 26254
;; flags: qr rd ra; QUERY: 1, ANSWER: 0, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: d68b8ef4f0d372530100000065dde850296bbf64b1cec94d (good)
;; QUESTION SECTION:
;google.com.			IN	A 0.0.0.0

;; Query time: 987 msec
;; SERVER: 192.168.1.2#53(192.168.1.2) (UDP)
;; WHEN: Tue Feb 27 13:49:04 UTC 2024
;; MSG SIZE  rcvd: 67

```

- 7.1 Based on the dig-queries, how does Pi-hole block domains on a DNS level?

> Pi-hole blocks domains on a DNS level by acting as a DNS sinkhole. When a client device queries a domain like `google.com`, Pi-hole checks its blocklists. If the domain is listed, Pi-hole responds to the query with a predefined IP address. This address usually points to Pi-hole or a local IP, indicating the domain is blocked. The client receives this response, preventing access to the domain's actual IP. Pi-hole regularly updates its blocklists to include new domains associated with ads, tracking, or malware, ensuring effective blocking network-wide. This DNS-level blocking is transparent to users and functions across all devices connected to the network.

> Pi-hole blocks domains on a DNS level by intercepting the DNS queries made by the client and matching the domain name being queried with the domains in its blacklist. If the domain is found in the blacklist, Pi-hole returns an IP address that leads to nowhere, effectively blocking the client's access to the domain.

- 7.2 How could you use Pi-hole in combination with your own DNS server, such as your caching-only nameserver?
  > Pi-hole can be used in combination with a caching-only nameserver by configuring the caching-only nameserver to forward the DNS queries to Pi-hole. This way, Pi-hole can be used as a first line of defense in blocking unwanted domains, while the caching-only nameserver can be used to improve the performance of the DNS resolution by caching the frequently used domains.
