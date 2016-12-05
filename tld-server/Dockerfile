FROM centos:7

RUN yum install -y epel-release yum-plugin-priorities \
&& curl -o /etc/yum.repos.d/powerdns-auth-40.repo https://repo.powerdns.com/repo-files/centos-auth-40.repo \
&& yum install -y pdns-backend-mysql

ADD pdns.conf /etc/pdns/pdns.conf
RUN sed -i -e "s|^gmysql-host.*|gmysql-host = mariadb|g" /etc/pdns/pdns.conf

ADD init-zone.sh /root/
RUN chmod +x /root/*.sh

CMD ["pdns_server", "--daemon=no", "--guardian"]

EXPOSE 53
EXPOSE 53/udp
