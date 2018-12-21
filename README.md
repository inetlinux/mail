Usage: start mail server
========================

Main usage:

```

# 在宿主机上创建一个目录/srv/mail/home，此目录将被挂载到docker容器的/home
mkdir -p /srv/mail

# start docker container
docker run -d --name mail -v /dev/log:/dev/log -v /srv/mail:/home -p 25:25 -p 465:465 -p 587:587 -p 143:143 -p 993:993 inetlinux/mail:v1.0

# Add user
docker exec mail /useradd your_name your_password

```

For Debug:

```
docker run -v /dev/log:/dev/log -p 25:25 -p 587:587 -p 143:143 -p 993:993 inetlinux/mail

# find contain id by docker ps
# add user jett with password 654321
docker exec <contain_id> /useradd jett 654321

docker run --rm -v /home:/home -it inetlinux/mail /bin/bash
```


Security
--------

http://www.postfix.org/TLS_README.html

http://www.postfix.org/SASL_README.html

https://wiki.dovecot.org/SSL


Verify
------

### TLS/SSL

    openssl s_client -starttls smtp -crlf -connect mail.example.com:25
    openssl s_client -starttls smtp -crlf -connect mail.example.com:25
    openssl s_client -crlf -connect mail.example.com:465

### For ESMTP Auth is LOGIN

    telnet mail.example.com 25
    ehlo myhostname
    250-mail.example.com
    250-PIPELINING
    250-SIZE 51200000
    250-VRFY
    250-ETRN
    250-STARTTLS
    250-AUTH PLAIN LOGIN
    250-ENHANCEDSTATUSCODES
    250-8BITMIME
    250 DSN
    auth login
    334 VXNlcm5hbWU6
    amV0dEBleGFtcGxlLmNvbQ==
    334 UGFzc3dvcmQ6
    NjU0MzIx
    235 2.7.0 Authentication successful
    mail from: <jett@example.com>
    250 2.1.0 Ok
    rcpt to: <jett@example.com>
    250 2.1.5 Ok
    data
    From: Jett <jett@example.com>
    To: Adam 2 <ajcody2@zcs723.EXAMPLE.com>
    Subject: Test ESMTP Auth LOGIN
    testing
    .
    250 2.0.0 Ok: queued as 6F90A119415
    quit
    221 2.0.0 Bye


https://wiki.zimbra.com/wiki/Simple_Troubleshooting_For_SMTP_Via_Telnet_And_Openssl



APPENDIX A - build
==================

    docker build -t inetlinux/mail .

    # delete images named <none>
    docker rmi $(docker images |grep '<none>'|awk '{ print $3 }')
