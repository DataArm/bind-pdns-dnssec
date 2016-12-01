# bind-pdns-dnssec

Proof-of-concept

Self-contained internet (DNS) with BIND as the dns-master for BIND
root servers (the root zone), and PDNS as the authoritative for
TLD DNS servers (Top-level domain)

Installation

You need Docker engine (tested 1.12.3 on a Mac) and docker-compose v2 support

1. Checkout this repository
1. cd to the repository and run: `docker-compose up --build -d`

That is it, execute `docker-compose ps` to see the list of containers and
forwarded ports
