#!/usr/bin/env bash

echo "Updating zone ${1} ..."
cd
data="`cat ${1}`"
cat <<-EOF | nsupdate
server 127.0.0.1
  ${data}
send
EOF
