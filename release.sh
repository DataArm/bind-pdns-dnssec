#!/usr/bin/env bash
source lib/dns.sh

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
    if [[ "${CONTAINER}" == "" ]] || [[ "${CONTAINER}" == "dns-root" ]]; then
      PORT="`docker-compose port --protocol=udp dns-root 53 | sed -e "s|.*:||g"`"
      CNT_NAME="`docker-compose ps | awk '{ print $1; }' | grep "dns-root_1$"`"
      IP="`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${CNT_NAME}`"
      SERIAL="`dig +short @127.0.0.1 -p ${PORT} . SOA | awk '{ print $3; }'`"
      let "SERIAL = ${SERIAL} + 1"
      read -r -d '' QUERY <<-EOF
        zone .
        debug
        update delete master.root-servers. A
        update add master.root-servers. 86400 IN A ${IP}
        update delete . NS master.root-servers.
        update add . 86400 IN NS master.root-servers.
        update delete . NS localhost
        update add . 86400 IN SOA master.root-servers. isaac.uribe.icann.org. ${SERIAL} 3600 900 604800 1200
        update delete . SOA
EOF
      update_dns "127.0.0.1" "${PORT}" "${QUERY}"
    fi
    ;;
  "logs" )
    docker-compose logs -f ${CONTAINER}
    ;;
  "shell" )
    docker-compose exec ${CONTAINER} sh
    ;;
  "status" )
    docker-compose ps
    ;;
esac
