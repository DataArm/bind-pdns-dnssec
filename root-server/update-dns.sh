#!/usr/bin/env bash
set -x

cd
data="`cat data.txt`"
cat <<-EOF | nsupdate
server 127.0.0.1
  ${data}
send
EOF
