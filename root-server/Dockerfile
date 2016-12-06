FROM centos:7

RUN yum install -y bind bind-utils

ADD update-dns.sh sign-zone.sh /root/
RUN chmod +x /root/*.sh

ADD var-named /var/named
ADD etc-named.conf /etc/named.conf
ADD etc-rndc.conf /etc/rndc.conf

RUN mkdir -p /var/named/{data,dynamic,keys} && touch /var/log/named.log && chown -Rf named:named /var/named/ /var/log/named.log

CMD ["named", "-g", "-u", "named", "-d", "99"]

EXPOSE 53
EXPOSE 53/udp
