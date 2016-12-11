#!/usr/bin/env bash

echo "Initializing TLD zone ${2} on ${1} ..."

cd
ESTAT="1"
while [[ "${ESTAT}" != "0" ]]; do
  echo "Waiting for database..."
  sleep 5
  echo "show tables" | mysql -h 127.0.0.1 -uroot -proot rDNS >/dev/null 2>&1
  ESTAT="${?}"
done
pdnsutil create-zone ${2} tld-server1
if [[ "${?}" == "0" ]]; then
  for index in {1..2}; do
    pdnsutil add-record ${2} @ NS tld-server${index}.
  done
fi
if [[ "${?}" == "0" ]]; then
  pdnsutil import-zone-key ${2} keys/ksk.txt ksk active \
  && pdnsutil import-zone-key ${2} keys/zsk1.txt zsk active \
  && pdnsutil import-zone-key ${2} keys/zsk2.txt zsk inactive \
  && pdnsutil set-nsec3 ${2} '1 0 1 a7' \
  && pdnsutil rectify-all-zones
fi
