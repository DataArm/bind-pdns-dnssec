#!/usr/bin/env bash

echo "Initializing TLD zone ${2} on ${1} ..."

ESTAT="1"
while [[ "${ESTAT}" != "0" ]]; do
  echo "Waiting for database..."
  sleep 5
  echo "show tables" | mysql -h 127.0.0.1 -uroot -proot rDNS >/dev/null 2>&1
  ESTAT="${?}"
done

cd && pdnsutil create-zone ${2} tld-server1 \
&& for index in {1..1}; do
  pdnsutil add-record ${2} @ NS tld-server${index}.
  if [[ "${?}" != "0" ]]; then exit 1; fi
done \
&& pdnsutil import-zone-key ${2} keys/ksk.txt ksk active \
&& pdnsutil import-zone-key ${2} keys/zsk.txt zsk active \
&& pdnsutil set-nsec3 ${2} '1 0 1 a7' \
&& pdnsutil create-zone nic.${2} tld-server1 \
&& for index in {1..1}; do
  pdnsutil add-record nic.${2} @ NS tld-server${index}. \
  && pdnsutil add-record ${2} nic NS tld-server${index}.
  if [[ "${?}" != "0" ]]; then exit 1; fi
done \
&& pdnsutil add-record nic.${2} whois A 177.2.3.4 \
&& pdnsutil import-zone-key nic.${2} keys/ksk.txt ksk active \
&& pdnsutil import-zone-key nic.${2} keys/zsk.txt zsk active \
&& pdnsutil show-zone nic.${2} 2>&1 | grep -e '^DS' | grep -E -e 'SHA[0-9]+' | sed -e "s| *;.*||g" -e "s|nic\.${2}\.|nic|g" -e "s|.*= *|pdnsutil add-record ${2} |g" -e "s| IN DS *| DS 86400 '|g" -e "s|$|'|g" > update.sh \
&& bash update.sh \
&& pdnsutil rectify-all-zones \
&& exit ${?}
