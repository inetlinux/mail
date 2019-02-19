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

    sed -i "s/{{ldaphost}}/${ldaphost}" /etc/postfix/ldap/*      /etc/dovecot/dovecot-ldap.conf.ext
    sed -i "s/{{ldapbase}}/${ldapbase}" /etc/postfix/ldap/*      /etc/dovecot/dovecot-ldap.conf.ext
    sed -i "s/{{ldapbinddn}}/${ldapbinddn}" /etc/postfix/ldap/*  /etc/dovecot/dovecot-ldap.conf.ext
    sed -i "s/{{ldapbindpw}}/${ldapbindpw}" /etc/postfix/ldap/*  /etc/dovecot/dovecot-ldap.conf.ext

    echo "configure postfix"
    postconf -e 'inet_interfaces = all'
    postconf -e 'inet_protocols = ipv4'
    postconf -e "myhostname=mail.$mydomain"
    postconf -e 'mydestination = localhost, localhost.$mydomain, $myhostname, $mydomain'
    postconf -e 'home_mailbox = mail/'
    postconf -e 'mailbox_command = /usr/libexec/dovecot/dovecot-lda -f "$SENDER" -a "$RECIPIENT"'
    postconf -e 'message_size_limit=51200000'
    postconf -e 'mailbox_size_limit=51200000'

    postconf -e "smtpd_tls_cert_file = $crtfile"
    postconf -e "smtpd_tls_key_file = $keyfile"
    postconf -e 'smtpd_tls_loglevel = 2'
    postconf -e 'smtpd_tls_security_level = may'
    postconf -e 'smtp_tls_loglevel = 2'
    postconf -e 'smtp_tls_security_level = may'

    postconf -e 'smtpd_sasl_type = dovecot'
    postconf -e 'smtpd_sasl_auth_enable = yes'
    postconf -e 'smtpd_recipient_restrictions = permit_sasl_authenticated,permit_mynetworks,reject'
    postconf -e 'smtpd_sasl_path = private/auth'

    postconf -e 'virtual_mailbox_domains = $myhostname'
    postconf -e 'virtual_alias_domains = ldap:/etc/postfix/ldap/virtual_alias_domains'
    postconf -e 'virtual_alias_maps = ldap:/etc/postfix/ldap/virtual_alias_maps'
    postconf -e 'virtual_mailbox_base = /'
    postconf -e 'virtual_mailbox_maps = ldap:/etc/postfix/ldap/virtual_mailbox_maps'
    postconf -e 'virtual_uid_maps = ldap:/etc/postfix/ldap/virtual_uid_maps'
    postconf -e 'virtual_gid_maps = ldap:/etc/postfix/ldap/virtual_uid_maps'
    postconf -e 'smtpd_sender_login_maps = ldap:/etc/postfix/ldap/smtpd_sender_login_maps'

    echo "done"
fi

exec "$@"
