#!/usr/bin/env bash

echo "Starting tld-server ${1}..."
ESTAT="1"
while [[ "${ESTAT}" != "0" ]]; do
  echo "Waiting for database..."
  sleep 5
  echo "show databases" | mysql -h 127.0.0.1 -uroot >/dev/null 2>&1
  ESTAT="${?}"
done

echo "Database is available, initializing..."
cd && mysqladmin -u root password 'root' \
&& mysql -h 127.0.0.1 -uroot -proot < "init-pdns.sql" \
&& echo "flush privileges;" | mysql -h 127.0.0.1 -uroot -proot \
&& exit ${?}
