#!/usr/bin/env bash

echo "Loading keys and signing zone ${1} ..."
cd /var/named/keys \
&& dnssec-keygen -a RSASHA256 -b 2048 -3 ${1} \
&& dnssec-keygen -a RSASHA256 -b 2048 -3 -fk ${1} \
&& chown -Rf named:named /var/named/keys \
&& rndc loadkeys ${1} \
&& rndc signing -nsec3param 1 0 10 01D82715 ${1} \
&& exit ${?}
