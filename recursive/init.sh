#!/usr/bin/env bash

echo "Initializing recursive DNS server..."
ESTAT="1"
INITIAL_KEY=""
while [[ "${ESTAT}" != "0" ]] || [[ "${INITIAL_KEY}" == "" ]]; do
  echo "Waiting for root-server..."
  sleep 5
  INITIAL_KEY="`dig @root-server . dnskey +short | grep ^257 | sed -re "s|^[0-9 ]+||g"`"
  ESTAT="${?}"
done

cat /root/etc-named.conf > /etc/named.conf
cat <<EOF >> /etc/named.conf
managed-keys {
  "." initial-key 257 3 8
    "${INITIAL_KEY}";
};
EOF

sleep 15
named -g -u named -d 99
