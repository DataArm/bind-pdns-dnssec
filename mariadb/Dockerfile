FROM mariadb:5.5

ADD init-pdns.sql init.sh /root/
RUN chmod +x /root/*.sh

EXPOSE 3306
