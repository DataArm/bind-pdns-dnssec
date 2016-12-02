FROM centos:7

RUN yum install -y bind bind-utils iproute

ADD var-named /var/named
ADD etc-named.conf /etc/named.conf

RUN cd /var/named/keys \
  && dnssec-keygen . \
  && dnssec-keygen -fk . \
  && dnssec-keygen 21.172.in-addr.arpa. \
  && dnssec-keygen -fk 21.172.in-addr.arpa. \
  && touch /var/log/named.log && chown -Rf named:named /var/named/ /var/log/named.log

CMD ["named", "-g", "-u", "named", "-d", "99"]

EXPOSE 53
EXPOSE 53/udp
