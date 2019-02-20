Usage: start mail server
========================

Main usage:

```
# 在宿主机上创建一个目录/srv/mail/home，此目录将被挂载到docker容器的/home
rm -rf /srv/mail && mkdir -p /srv/mail

# start docker container
docker run -d --restart=always --name mail
    -e mydomain=inetlinux.com\
    -e securitylevel=may\
    -v /dev/log:/dev/log\
    -v /srv/mail:/home\
    -v /etc/pki/tls/private/inetlinux.com.key:/etc/pki/tls/private/dovecot.pem\
    -v /etc/pki/tls/certs/inetlinux.com.crt:/etc/pki/tls/certs/dovecot.pem\
    -p 25:25 -p 587:587 -p 993:993 inetlinux/mail

# Add user
docker exec mail /useradd your_name your_password

```

Security
--------
http://www.postfix.org/TLS_README.html
http://www.postfix.org/SASL_README.html
https://wiki.dovecot.org/SSL


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
echo -ne "demo\0demo\0password"|base64
```
APPENDIX A - build
==================

    docker build --force-rm -t inetlinux/mail .
