#!/bin/bash -e

echo $@
cat >/tmp/openssl.cnf <<EOF
[ req ]
default_bits = 4096
encrypt_key = yes
distinguished_name = req_dn
x509_extensions = cert_type
prompt = no

[ req_dn ]
C=CN
ST=Beijing
L=Chaoyang
O=Inetlinux
OU=Mail
CN=mail.$mydomain
emailAddress=postmaster@$mydomain

[ cert_type ]
nsCertType = server
EOF

keyfile=/etc/pki/tls/private/dovecot.pem
crtfile=/etc/pki/tls/certs/dovecot.pem

if [ "${1}x" = "/usr/bin/supervisordx" ]; then
    if [ ! -f $crtfile ]; then
        echo "generating ssl cert..."
        openssl req -new -x509 -nodes -config /tmp/openssl.cnf -out $crtfile -keyout $keyfile -days 365
        chmod 0600 $keyfile
        echo
        openssl x509 -subject -fingerprint -noout -in $crtfile
    fi

    echo "configure postfix"
    postconf -e 'inet_interfaces = all'
    postconf -e "myhostname=mail.$mydomain"
    postconf -e 'mydestination = localhost, localhost.$mydomain, $myhostname, $mydomain'
    postconf -e 'home_mailbox = mail/'
    postconf -e 'mailbox_command = /usr/libexec/dovecot/dovecot-lda -f "$SENDER" -a "$RECIPIENT"'
    postconf -e 'message_size_limit=51200000'
    postconf -e 'mailbox_size_limit=51200000'

    postconf -e "smtpd_tls_cert_file = $crtfile"
    postconf -e "smtpd_tls_key_file = $keyfile"
    postconf -e 'smtpd_tls_loglevel = 0'
    postconf -e 'smtpd_tls_security_level = may'

    postconf -e 'smtpd_sasl_type = dovecot'
    postconf -e 'smtpd_sasl_auth_enable = yes'
    postconf -e 'smtpd_recipient_restrictions = permit_sasl_authenticated,permit_mynetworks,reject_unauth_destination'
    postconf -e 'smtpd_sasl_path = private/auth'
    echo "done"
fi

exec "$@"
