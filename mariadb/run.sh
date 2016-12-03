#!/usr/bin/env bash

cd
mysql -h 127.0.0.1 -uroot -proot < "loadDB.sql" \
&& echo "flush privileges;" | mysql -h 127.0.0.1 -uroot -proot \
&& mysql -h 127.0.0.1 -uroot -proot < "zone.sql"
