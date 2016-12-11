#!/usr/bin/env bash

echo "Initializing recursive DNS server..."
ESTAT="1"
ROOT_KEYS=""
while [[ "${ESTAT}" != "0" ]] || [[ "${ROOT_KEYS}" == "" ]]; do
  echo "Waiting for root-server..."
  sleep 5
  ROOT_KEYS="`dig @root-server . dnskey +short`"
  ESTAT="${?}"
done

echo "root-server's up, configuring..."
cd && ROOT_SERVER_IPV4="`dig root-server A +short`" \
&& sed -e "s|##__ROOT_SERVER_IPV4__##|${ROOT_SERVER_IPV4}|g" /root/var-named-named.ca > /var/named/named.ca \
&& cat <<EOF >> /etc/named.conf
managed-keys {
EOF
if [[ "${?}" == "0" ]]; then
  IFS=$'\n'; for key in `dig @root-server . dnskey +short | grep -E "^257 +3 +8" | sed -re "s|^[0-9 ]+||g"`; do
    echo "Found key..."
    echo "  \".\" initial-key 257 3 8 \"${key}\";" >> /etc/named.conf
    if [[ "${?}" != "0" ]]; then exit 1; fi
  done \
  && cat <<EOF >> /etc/named.conf
  };
EOF
  if [[ "${?}" == "0" ]]; then
    exec named -g -u named -d 99
  fi
fi
