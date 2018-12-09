#!/bin/bash

echo $#
echo $0
echo $1
if [ $# -gt 1 -a "$1" = "/usr/bin/supervisord" ]; then
    mkdir /etc/dovecot/private
    ln -s /etc/pki/tls/certs/dovecot.pem /etc/dovecot/dovecot.pem
    ln -s /etc/pki/tls/private/dovecot.pem /etc/dovecot/private/dovecot.pem

    postconf -e mydomain=$mydomain
    postconf -e myhostname=mail.$mydomain
    postconf -e 'inet_interfaces = all'
    postconf -e "mydestination = localhost, localhost.$mydomain, $myhostname, $mydomain"
    postconf -e 'smtpd_sasl_type = dovecot'
    postconf -e 'smtpd_sasl_auth_enable = yes'
    postconf -e 'smtpd_recipient_restrictions = permit_sasl_authenticated,permit_mynetworks,reject_unauth_destination'
    postconf -e 'smtpd_sasl_path = private/auth'
    postconf -e message_size_limit=52428800
fi

exec "$@"
