# bind-pdns-dnssec

Self-contained internet DNSSEC proof-of-concept with BIND and PowerDNS

## design

The "." (root) zone is configured on "root-server", an authoritative, non-recursive
BIND9 using "inline-signing".

The "tld" zone is configured on "tld-server", an authoritative, non-recursive
PowerDNS using "secure-zone".

The "tld" zone is delegated from the "." zone via NS and DS records.

"recursive" is a recursive BIND9 configured to trust "."'s DNS Keys via "managed-keys"
and knows about "root-server" through the "named.ca" hint file for the "." zone

## Installation

You need the following requisites:

1. Docker engine (tested 1.12.3 on a Mac)
1. docker-compose (v2 support, normally part of the above)
1. bash
1. git

Steps:

1. Checkout this repository (git clone https://github.com/DataArm/bind-pdns-dnssec.git)
1. cd to the repository and run: `bash release.sh`
1. A lot of information will come up, at the end, you should see 4 containers running,
when executing `bash release.sh status`, e.g:
```            Name                          Command               State       Ports
--------------------------------------------------------------------------------------
bindpdnsdnssec_client_1        tail -F /dev/null                Up
bindpdnsdnssec_mariadb_1       docker-entrypoint.sh mysqld      Up      3306/tcp
bindpdnsdnssec_recursive_1     /docker-entrypoint.sh            Up      53/tcp, 53/udp
bindpdnsdnssec_root-server_1   named -g -u named -d 99          Up      53/tcp, 53/udp
bindpdnsdnssec_tld-server_1    pdns_server --daemon=no -- ...   Up      53/tcp, 53/udp
```
1. Open up a screen and keep an eye on the logs by executing: `bash release.sh logs`

## Usage

Log in to the "client" container by executing: `bash release.sh shell client` and
run: `dig @recursive . +dnssec` which will show the "do" and "ad" flags (correct
DNSSEC per ftp://ftp.rfc-editor.org/in-notes/rfc3655.txt), e.g:

```;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 61015
;; flags: qr rd ra ad; QUERY: 1, ANSWER: 0, AUTHORITY: 4, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags: do; udp: 4096
;; QUESTION SECTION:
;.     				IN     	A

;; AUTHORITY SECTION:
.      			1200   	IN     	SOA    	root-server. isaac.uribe.icann.org. 6 3600 900 604800 1200
.      			1200   	IN     	RRSIG  	SOA 8 0 86400 20170104220852 20161205210852 62970 . U1345uXdQ9kYS9Pc0YxC/sxgq4wfkjSgL0e2Ss0dSK8DiIVvKQetkhZ2 lgb9zBrP3zDgBs5u5WHHzLHLinTNPZiepGvlSV7N+8O+NyT6utF6Cha3 duqarghwiGXoXkp9sZfWLvm1kZF7iwA1ZgCJHZI1l7gGgcMJLQqyHGMq RNSyDPYLzkDFE5lWAJaK0AgH9pQF8sy/1pdbyn3puqM9qTeUyqMBn/E6 VdD0uhdSWEV5cv2ettUcJvxIaxE8ff+sCrEzElz6FQm57fl9mQNh5GPZ YL34qGnluYTiLN0D+gKIAyHhcjDcaaL0B/OndAEzGdlMI4CArWbRnjwU Xr6eow==
QK4T7IV3QQ3V9RHKGQ1PGBURIJCGUK4M. 1200 IN RRSIG	NSEC3 8 1 1200 20170104220852 20161205210852 62970 . I/nEmzTzqZh0Pem+w1jIMLyr6TE5gG3C7HhPRKl0E1uSe+nZXgVDrM3Z 0xrt3sMjyBZnMc5/LtEqgqkByYRRQN6/wfmlTtfsbD46cHWGzY9NxAUU FtHPB4xXVcw65BFCtyFv+R3Uf+2+9UGfct7pmH9vJ9y0EBarY8GuERU4 /COfwwaOBGjz79EpQDuTm+CTbjzL0tHyCeCYRFJZMoUqiAoJojvUxA5d fwQp2R1hG8nudfsC8v1MQHnoRh+KqjAcothpXwPNzeQGtKUqHM50eixb KWimWlSLXj/0ID9TclN3aqebu18swtpVAwn4WBG8jK3bkZlFgK/ZKcLc GX9YEg==
QK4T7IV3QQ3V9RHKGQ1PGBURIJCGUK4M. 1200 IN NSEC3	1 0 10 01D82715 00F2OOIIST9FI265DBC10KU4K22819T6 NS SOA RRSIG DNSKEY NSEC3PARAM TYPE65534

;; Query time: 15 msec
;; SERVER: 172.21.0.5#53(172.21.0.5)
;; WHEN: Mon Dec 05 22:11:35 UTC 2016
;; MSG SIZE  rcvd: 785```

You can also verify that each DNS server is indeed the authoritative by running:
`dig @root-server .` and `dig @tld-server tld.` (they will show the "aa" flag)
