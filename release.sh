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
    rm -Rf tld-server/keys
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
    ROOTCNT_NAME="`docker-compose ps | awk '{ print $1; }' | grep "root-server_1$"`" \
    && if [[ "${CONTAINER}" == "" ]] || [[ "${CONTAINER}" == "root-server" ]]; then
      ROOTCNT_IP="`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${ROOTCNT_NAME}`" \
      && let "SERIAL = ${SERIAL} + 1" \
      && echo "zone .
        debug
        update delete root-server. A
        update add root-server. 86400 IN A ${ROOTCNT_IP}
        update delete . NS root-server.
        update add . 86400 IN NS root-server.
        update delete localhost. A
        update delete . NS localhost" > data.txt \
      && docker cp data.txt ${ROOTCNT_NAME}:/root/ \
      && docker-compose exec root-server '/root/update-dns.sh' '/root/data.txt' \
      && docker-compose exec root-server '/root/sign-zone.sh' '.'
    fi \
    && if [[ "${CONTAINER}" == "" ]] || [[ "${CONTAINER}" == "tld-server" ]]; then
      docker-compose scale tld-server=2 \
      && for index in {1..2}; do
        docker-compose exec --index=${index} tld-server '/root/init-db.sh' "${index}" \
        && TLDCNT_NAME="`docker-compose ps | awk '{ print $1; }' | grep "tld-server_${index}$"`" \
        && TLDCNT_IP="`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${TLDCNT_NAME}`" \
        && echo "zone .
          debug
          update delete tld-server${index}. A
          update add tld-server${index}. 86400 IN A ${TLDCNT_IP}" > data.txt \
        && docker cp data.txt ${ROOTCNT_NAME}:/root/ \
        && docker-compose exec root-server '/root/update-dns.sh' '/root/data.txt'
        if [[ "${?}" != "0" ]]; then exit 1; fi
      done \
      && if [[ ! -d "tld-server/keys" ]]; then
        ESTAT="1"
        while [[ "${ESTAT}" != "0" ]]; do
          echo "Waiting for first TLD server..."
          sleep 5
          docker-compose exec tld-server pdnsutil list-all-zones
          ESTAT="${?}"
        done
        mkdir -p tld-server/keys \
        && docker-compose exec tld-server pdnsutil create-zone ktest \
        && docker-compose exec tld-server pdnsutil add-zone-key ktest ksk 2048 active rsasha256 \
        && docker-compose exec tld-server pdnsutil add-zone-key ktest zsk 2048 active rsasha256 \
        && docker-compose exec tld-server pdnsutil add-zone-key ktest zsk 2048 inactive rsasha256 \
        && docker-compose exec tld-server pdnsutil add-zone-key ktest zsk 2048 inactive rsasha256 \
        && docker-compose exec tld-server pdnsutil rectify-all-zones \
        && docker-compose exec tld-server pdnsutil export-zone-key ktest 1 > tld-server/keys/ksk.txt \
        && docker-compose exec tld-server pdnsutil export-zone-key ktest 2 > tld-server/keys/zsk1.txt \
        && docker-compose exec tld-server pdnsutil export-zone-key ktest 3 > tld-server/keys/zsk2.txt \
        && docker-compose exec tld-server pdnsutil delete-zone ktest
      fi \
      && echo "" > update-etc-hosts.sh \
      && for index in {1..2}; do
        TLDCNT_NAME="`docker-compose ps | awk '{ print $1; }' | grep "tld-server_${index}$"`" \
        && docker cp tld-server/keys ${TLDCNT_NAME}:/root/keys \
        && for zone in tld; do
          docker-compose exec --index=${index} tld-server '/root/init-zone.sh' "${index}" "${zone}" \
          && DS="`docker-compose exec --index=${index} tld-server pdnsutil show-zone ${zone} | grep -e '^DS' | sed -e "s| *;.*||g" -e "s|.*= *|update add |g" -e "s|\. IN DS|. 86400 IN DS|g"`"
          echo "zone .
            update add ${zone}. 86400 IN NS tld-server${index}.
            ${DS}" > data.txt \
          && docker cp data.txt ${ROOTCNT_NAME}:/root/ \
          && docker-compose exec root-server '/root/update-dns.sh' '/root/data.txt'
          if [[ "${?}" != "0" ]]; then exit 1; fi
        done \
        && echo "echo \"${TLDCNT_IP} tld-server${index}\" >> /etc/hosts" >> update-etc-hosts.sh
      done
      rm -Rf data.txt
    fi \
    && if [[ "${CONTAINER}" == "" ]]; then
      for cnt_name in `docker-compose ps | grep "Up" | awk '{ print $1; }'`; do
        docker cp update-etc-hosts.sh ${cnt_name}:/root/ \
        && docker exec -i ${cnt_name} bash /root/update-etc-hosts.sh
        if [[ "${?}" != "0" ]]; then exit 1; fi
      done
      rm -f update-etc-hosts.sh
    fi
    ;;
  "destroy" )
    docker images -q | xargs -IID docker rmi ID
    ;;
esac
