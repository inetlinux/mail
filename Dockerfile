FROM centos

ENV mydomain=inetlinux.com

RUN curl https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py && python /tmp/get-pip.py && yum install -y postfix dovecot && pip install supervisor && rm -rf /etc/supervisord.conf /tmp/get-pip.py /var/cache/yum /root/.cache/pip

ADD postfix/postfix.sh entrypoint.sh useradd /
ADD supervisor /etc/supervisor
ADD dovecot/10-master.conf /etc/dovecot/conf.d/
ADD dovecot/10-mail.conf /etc/dovecot/conf.d/
ADD dovecot/10-auth.conf /etc/dovecot/conf.d/
ADD dovecot/10-ssl.conf /etc/dovecot/conf.d/
ADD dovecot/10-logging.conf /etc/dovecot/conf.d/
ADD dovecot/15-lda.conf /etc/dovecot/conf.d/
ADD postfix/master.cf /etc/postfix/

VOLUME ["/var/mail", "/home"]
EXPOSE 25 110 143 587 993 995

ENTRYPOINT ["/entrypoint.sh"]

CMD [ "/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf" ]