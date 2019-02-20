Postfix and dovecot with LDAP
=============================

The LDAP directory needs to keep several information needed by Postfix and Dovecot to work.

* Username & Password for authentication
* UID and GID for managing permissions of the user's maildir
* Location of the maildir
* List of mail aliases for a given user to allow one user to have several mail adresses.


Usage
-----

```
mkdir /srv/mail

docker run -d --restart=always --name mail -e mydomain=example.com\
    -e ldaphost="172.17.0.1" \
    -e ldapbase="dc=example,dc=com" \
    -e ldapbinddn="cn=admin,dc=example,dc=com"\
    -e ldapbindpw="youpassword"\
    -v /dev/log:/dev/log\
    -v /srv/mail:/home\
    -v /etc/pki/tls/private/inetlinux.com.key:/etc/pki/tls/private/dovecot.pem\
    -v /etc/pki/tls/certs/inetlinux.com.crt:/etc/pki/tls/certs/dovecot.pem\
    -p 25:25 -p 587:587 -p 993:993 inetlinux/mail:ldap

```

Configuration
-------------

### Postfix

#### LDAP Mapping

Test the mapping with the postmap command, see [LDAP lookup tables](http://www.postfix.org/ldap_table.5.html)

    postmap -q example.com ldap:/etc/postfix/ldap/virtual_alias_domains
    postmap -q lijing@example.com ldap:/etc/postfix/ldap/virtual_mailbox_maps
    postmap -q lijing@example.com ldap:/etc/postfix/ldap/virtual_uid_maps
    postmap -q lijing@example.com ldap:/etc/postfix/ldap/smtpd_sender_login_maps

#### The Mailboxes

Use of the _virtual alias domain class_ and the (_virtual mailbox domain class_)[http://www.postfix.org/ADDRESS_CLASS_README.html].

### Configuration References

[TLS](http://www.postfix.org/TLS_README.html)
[SASL](http://www.postfix.org/SASL_README.html)
[LDAP](http://www.postfix.org/LDAP_README.html)
[Dovecot SSL](https://wiki.dovecot.org/SSL)


Verify
------

### StartTLS, sendmail with protocols

```
$ openssl s_client -starttls smtp -crlf -connect mail.example.com:25
....
ehlo myhostname
250-mail.example.com
250-PIPELINING
250-SIZE 51200000
250-VRFY
250-ETRN
250-AUTH PLAIN LOGIN
250-ENHANCEDSTATUSCODES
250-8BITMIME
250 DSN
auth plain <base64_value>
235 2.7.0 Authentication successful
mail from: <admin@example.com>
250 2.1.0 Ok
rcpt to: <demo@example.com>
250 2.1.5 Ok
data
354 End data with <CR><LF>.<CR><LF>
Subject: Test auth plain
testing
.
250 2.0.0 Ok: queued as BCE3A2208564E
quit
221 2.0.0 Bye
closed
```

Replace `<base64_value>` with appropriate value, the value of `auth plain` is `base64('authorization-id\0authentication-id\0passwd')` where `\0` is the null byte. Generate base64 string as follow:

```
python -c "import base64; print base64.b64encode('demo\0demo\0password')"
ZGVtbwBkZW1vAHBhc3N3b3Jk
```

APPENDIX A - build
==================

    docker build --force-rm -t inetlinux/mail:ldap .

APPENDIX B - REFERENCE
======================

https://www.vennedey.net/resources/2-LDAP-managed-mail-server-with-Postfix-and-Dovecot-for-multiple-domains
