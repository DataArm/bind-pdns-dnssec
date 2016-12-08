#!/usr/bin/env bash
#See README for details

ACTION="${1}"
if [[ "${ACTION}" != "" ]]; then
  CONTAINER="${2}"
  if [[ "${ACTION}" == "shell" ]]; then
    CONTAINER_ID="${3}"
    if [[ "${CONTAINER_ID}" == "" ]]; then
      CONTAINER_ID="1"
    fi
  fi
else
  ACTION="start"
fi

case "${ACTION}" in
  "build" )
    docker-compose build ${CONTAINER}
    ;;
  "logs" )
    docker-compose logs -f ${CONTAINER}
    ;;
  "rm"|"destroy" )
    docker-compose kill ${CONTAINER}
    docker-compose rm -f -v ${CONTAINER}
    ;;
  "stop" )
    docker-compose stop ${CONTAINER}
    ;;
  "shell" )
    docker-compose exec --index=${CONTAINER_ID} ${CONTAINER} bash
    ;;
  "start" )
    docker-compose up --build -d ${CONTAINER}
    ;;
  "status" )
    docker-compose ps
    ;;
esac

case "${ACTION}" in
  "start" )
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
      && docker-compose exec root-server '/root/update-dns.sh' '/root/data.txt' \
      && docker-compose exec root-server '/root/sign-zone.sh' '.'
    fi
    if [[ "${CONTAINER}" == "" ]] || [[ "${CONTAINER}" == "tld-server" ]]; then
      docker-compose scale tld-server=2
      for index in {1..2}; do
        docker-compose exec --index=${index} tld-server '/root/init-db.sh' "${index}" "${zone}"
        for zone in tld; do
          docker-compose exec --index=${index} tld-server '/root/init-zone.sh' "${index}" "${zone}"
          DS="`docker-compose exec --index=${index} tld-server 'pdnsutil' 'show-zone' "${zone}" | grep -e '^DS' | sed -e "s| *;.*||g" -e "s|.*= *|update add |g" -e "s|\. IN DS|. 86400 IN DS|g"`"
          CNT_NAME="`docker-compose ps | awk '{ print $1; }' | grep "tld-server_${index}$"`"
          IP="`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${CNT_NAME}`"
          echo "zone .
            debug
            update delete tld-server${index}. A
            update add tld-server${index}. 86400 IN A ${IP}
            update add ${zone}. 86400 IN NS tld-server${index}.
            ${DS}" > data.txt
          CNT_NAME="`docker-compose ps | awk '{ print $1; }' | grep "root-server_1$"`"
          docker cp data.txt ${CNT_NAME}:/root/ \
          && docker-compose exec root-server '/root/update-dns.sh' '/root/data.txt'
        done
      done
    fi
    ;;
  "destroy" )
    docker images -q | xargs -IID docker rmi ID
    ;;
esac
