FROM centos

ENV mydomain=example.com

RUN curl https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py && python /tmp/get-pip.py && yum install -y postfix dovecot && pip install supervisor && rm -rf /etc/supervisord.conf /tmp/get-pip.py /var/cache/yum /root/.cache/pip

ADD entrypoint.sh mkcert.sh dovecot-openssl.cnf /
RUN sh /mkcert.sh && rm -f /mkcert.sh /dovecot-openssl.cnf

ADD supervisor /etc/supervisor
ADD dovecot/10-master.conf /etc/dovecot/conf.d/
ADD dovecot/10-auth.conf   /etc/dovecot/conf.d/
ADD dovecot/10-ssl.conf    /etc/dovecot/conf.d/
ADD postfix/master.cf /etc/postfix/

VOLUME ["/var/mail", "/home"]
EXPOSE 25 110 143 587 993 995

ENTRYPOINT ["/entrypoint.sh"]

CMD [ "/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf" ]