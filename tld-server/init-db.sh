#!/usr/bin/env bash

echo "Initializing tld-server..."
cd
ESTAT="1"
while [[ "${ESTAT}" != "0" ]]; do
  echo "Waiting for database..."
  sleep 5
  echo "show databases" | mysql -h 127.0.0.1 -uroot >/dev/null 2>&1
  ESTAT="${?}"
done

echo "Database is available, initializing..."
mysqladmin -u root password 'root' \
&& mysql -h 127.0.0.1 -uroot -proot < "init-pdns.sql" \
&& echo "flush privileges;" | mysql -h 127.0.0.1 -uroot -proot
