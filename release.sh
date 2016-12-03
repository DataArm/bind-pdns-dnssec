#!/usr/bin/env bash

ACTION="${1}"
if [[ "${ACTION}" != "" ]]; then
  CONTAINER="${2}"
else
  echo "No action defined, I should use argsparse"
  exit 1
fi

case "${ACTION}" in
  "destroy" )
    docker-compose kill
    docker ps -a -q | xargs -IID docker stop ID
    docker ps -a -q | xargs -IID docker rm ID
    docker images -q | xargs -IID docker rmi ID
    ;;
  "prepare" | "build" )
    docker-compose build ${CONTAINER}
    ;;
  "stop" )
    docker-compose stop ${CONTAINER}
    ;;
esac

case "${ACTION}" in
  "build" | "start" )
    docker-compose up --build -d ${CONTAINER}
    if [[ "${CONTAINER}" == "" ]] || [[ "${CONTAINER}" == "root-server" ]]; then
      CNT_NAME="`docker-compose ps | awk '{ print $1; }' | grep "root-server_1$"`"
      IP="`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${CNT_NAME}`"
      let "SERIAL = ${SERIAL} + 1"
      echo "zone .
        debug
        update delete root-server. A
        update add root-server. 86400 IN A ${IP}
        update delete . NS root-server.
        update add . 86400 IN NS root-server.
        update delete localhost. A
        update delete . NS localhost" > data.txt
      docker cp data.txt ${CNT_NAME}:/root/ \
      && docker-compose exec root-server '/root/update-dns.sh'
    fi
    if [[ "${CONTAINER}" == "" ]] || [[ "${CONTAINER}" == "mariadb" ]]; then
      docker-compose exec mariadb '/root/run.sh'
    fi
    if [[ "${CONTAINER}" == "" ]] || [[ "${CONTAINER}" == "tld-server" ]]; then
      docker-compose exec tld-server '/root/run.sh'
      DS="`docker-compose exec tld-server 'pdnsutil' 'show-zone' | sed -e "s| *;.*||g" -e "s|.*= *|update add |g"`"
      CNT_NAME="`docker-compose ps | awk '{ print $1; }' | grep "tld-server_1$"`"
      IP="`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${CNT_NAME}`"
      echo "zone .
        debug
        update delete tld-server. A
        update add tld-server. 86400 IN A ${IP}
        update delete tld. NS
        update add tld. 86400 IN NS tld-server." > data.txt
      CNT_NAME="`docker-compose ps | awk '{ print $1; }' | grep "root-server_1$"`"
      docker cp data.txt ${CNT_NAME}:/root/ \
      && docker-compose exec root-server '/root/update-dns.sh'
    fi
    ;;
  "logs" )
    docker-compose logs -f ${CONTAINER}
    ;;
  "shell" )
    docker-compose exec ${CONTAINER} bash
    ;;
  "status" )
    docker-compose ps
    ;;
esac
