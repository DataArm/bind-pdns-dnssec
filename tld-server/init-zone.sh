#!/usr/bin/env bash

echo "Creating zone ${1} ..."
pdnsutil create-zone ${1} tld-server

echo "Signing zone ${1} ..."
pdnsutil secure-zone ${1}
pdnsutil set-nsec3 ${1} '1 0 1 a7'
