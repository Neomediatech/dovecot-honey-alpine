FROM alpine

LABEL maintainer="docker-dario@neomediatech.it"

RUN apk update; apk upgrade ; apk add --no-cache tzdata; cp /usr/share/zoneinfo/Europe/Rome /etc/localtime
RUN apk add --no-cache tini dovecot
RUN rm -rf /usr/local/share/doc /usr/local/share/man
RUN rm -rf /etc/dovecot/* ; mkdir -p /var/log/dovecot /var/lib/dovecot ; chmod 777 /var/log/dovecot
COPY dovecot.conf users dovecot-ssl.cnf /etc/dovecot/
RUN openssl req -new -x509 -nodes -days 3650 -config /etc/dovecot/dovecot-ssl.cnf -out /etc/dovecot/server.pem -keyout /etc/dovecot/server.key ; \
    chmod 0600 /etc/dovecot/server.key ; openssl dhparam -dsaparam -out /etc/dovecot/dh.pem 2048

COPY init.sh /
RUN chmod +x /init.sh

EXPOSE 110 143 993 995

#CMD ["/usr/sbin/dovecot", "-F"]
ENTRYPOINT ["tini", "--", "/init.sh"]
