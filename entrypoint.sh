#!/bin/bash -e

echo $@
if [ "${1}x" = "/usr/bin/supervisordx" ]; then
    echo "configure postfix"
    postconf -e 'inet_interfaces = all'
    postconf -e "myhostname=mail.$mydomain"
    postconf -e 'mydestination = localhost, localhost.$mydomain, $myhostname, $mydomain'
    postconf -e 'home_mailbox = mail/'
    postconf -e 'mailbox_command = /usr/libexec/dovecot/dovecot-lda -f "$SENDER" -a "$RECIPIENT"'
    postconf -e 'message_size_limit=52428800'


    postconf -e 'smtpd_tls_cert_file = /etc/pki/tls/certs/dovecot.pem'
    postconf -e 'smtpd_tls_key_file = /etc/pki/tls/private/dovecot.pem'
    postconf -e 'smtpd_tls_loglevel = 0'
    postconf -e 'smtpd_tls_security_level = may'

    # postconf -e 'smtpd_sasl_type = dovecot'
    # postconf -e 'smtpd_sasl_auth_enable = yes'
    # postconf -e 'smtpd_recipient_restrictions = permit_sasl_authenticated,permit_mynetworks,reject_unauth_destination'
    # postconf -e 'smtpd_sasl_path = private/auth'
    echo "done"
fi

exec "$@"
