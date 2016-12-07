#!/usr/bin/env bash

echo "Initializing tld-server..."
cd
mysql_install_db --user=mysql && mysqld_safe --no-auto-restart &
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

cat /var/run/mariadb/mariadb.pid | xargs kill \
&& exec supervisord
