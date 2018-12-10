#!/bin/bash -e

echo $@
if [ "/${1}" = "//usr/bin/supervisord"]; then
    echo "configure postfix"
    postconf -e 'inet_interfaces = all'
    postconf -e mydomain=$mydomain
    postconf -e myhostname=mail.$mydomain
    postconf -e "mydestination = localhost, localhost.$mydomain, $myhostname, $mydomain"
    postconf -e 'home_mailbox = mail/'
    postconf -e 'mailbox_command = /usr/libexec/dovecot/dovecot-lda -f "$SENDER" -a "$RECIPIENT"'
    postconf -e 'message_size_limit=52428800'

    # postconf -e 'smtpd_sasl_type = dovecot'
    # postconf -e 'smtpd_sasl_auth_enable = yes'
    # postconf -e 'smtpd_recipient_restrictions = permit_sasl_authenticated,permit_mynetworks,reject_unauth_destination'
    # postconf -e 'smtpd_sasl_path = private/auth'
    echo "done"
fi

exec "$@"
