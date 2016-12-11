# bind-pdns-dnssec

Self-contained internet DNSSEC proof-of-concept with BIND and PowerDNS

## design

The "." (root) zone is configured on "root-server", an authoritative, non-recursive
BIND9 using "inline-signing".

The "tld" zone is configured on "tld-server" 1 and 2, authoritative, non-recursive
PowerDNS servers.

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
1. A lot of information will come up, at the end, you should see 5 containers running,
when executing `bash release.sh status`, e.g:

```
Name                       Command           State       Ports
-------------------------------------------------------------------------------
bindpdnsdnssec_client_1        tail -F /dev/null         Up
bindpdnsdnssec_recursive_1     /docker-entrypoint.sh     Up      53/tcp, 53/udp
bindpdnsdnssec_root-server_1   named -g -u named -d 99   Up      53/tcp, 53/udp
bindpdnsdnssec_tld-server_1    supervisord               Up      53/tcp, 53/udp
bindpdnsdnssec_tld-server_2    supervisord               Up      53/tcp, 53/udp
```

1. Open up a screen and keep an eye on the logs by executing: `bash release.sh logs`

## Usage

Log in to the "client" container by executing: `bash release.sh shell client` and
run: `dig @recursive . +dnssec` which will show the "do" and "ad" flags (correct
DNSSEC), e.g:

```
...
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 61015
;; flags: qr rd ra ad; QUERY: 1, ANSWER: 0, AUTHORITY: 4, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags: do; udp: 4096
...
```
Or `dig @recursive does-not-exist.tld +dnssec`
```
...
;; ->>HEADER<<- opcode: QUERY, status: NXDOMAIN, id: 57872
;; flags: qr rd ra ad; QUERY: 1, ANSWER: 0, AUTHORITY: 4, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags: do; udp: 4096
...
```

You can also verify that each DNS server is indeed the authoritative by running:
`dig @root-server .`, `dig @tld-server1 tld.` `dig @tld-server2 tld.` (they will
show the "aa" flag), also, you can stop/start one of the TLD servers and confirm
the recursive is still working (e.g. `docker stop bindpdnsdnssec_tld-server_2`)

## documentation

https://doc.powerdns.com/md/authoritative/dnssec/

https://www.isc.org/downloads/bind/dnssec/

ftp://ftp.rfc-editor.org/in-notes/rfc3655.txt
