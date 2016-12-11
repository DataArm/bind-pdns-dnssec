#!/usr/bin/env bash

echo "Initializing TLD zone ${2} on ${1} ..."

if [[ -f "/root/update-etc-hosts.sh" ]]; then
  bash /root/update-etc-hosts.sh
fi
exec supervisord
