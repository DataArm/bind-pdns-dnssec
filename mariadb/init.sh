#!/usr/bin/env bash

echo "Initializing database..."
cd
ESTAT="1"
while [[ "${ESTAT}" != "0" ]]; do
  echo "Waiting for database..."
  sleep 5
  echo "show databases" | mysql -h 127.0.0.1 -uroot -proot >/dev/null 2>&1
  ESTAT="${?}"
done

echo "Database is up, initializing PDNS schema..."
mysql -h 127.0.0.1 -uroot -proot < "init-pdns.sql" \
&& echo "flush privileges;" | mysql -h 127.0.0.1 -uroot -proot
