FROM centos:7

RUN yum install -y epel-release yum-plugin-priorities \
&& curl -o /etc/yum.repos.d/powerdns-auth-40.repo https://repo.powerdns.com/repo-files/centos-auth-40.repo \
&& yum install -y pdns-backend-mysql mariadb-server supervisor bind-utils \
&& mysql_install_db --user=mysql

ADD etc-pdns.conf /etc/pdns/pdns.conf
ADD etc-supervisord.d-supervisord.ini /etc/supervisord.d/supervisord.ini

ADD init-pdns.sql init-zone.sh init-db.sh /root/
RUN chmod +x /root/*.sh

ADD init.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 53
EXPOSE 53/udp
