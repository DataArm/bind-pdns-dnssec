FROM centos:7

RUN yum install -y bind bind-utils

ADD var-named /var/named
ADD etc-named.conf /etc/named.conf
ADD var-named-named.ca /root/

RUN mkdir -p /var/named/{data,dynamic,keys} \
  && touch /var/log/named.log \
  && chown -Rf named:named /var/named/ /var/log/named.log

ADD init.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 53
EXPOSE 53/udp
