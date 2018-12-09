
Usage: start mail server
========================

Main usage:


```

# 在宿主机上创建一个目录/srv/mail/home，此目录将被挂载到docker容器的/home
mkdir -p /srv/mail

# start docker container
docker run -d -n mail -e mydomain=example.com \
    -v /dev/log:/dev/log -v /srv/mail:/home \
    -p 10025:25 -p 465:465 -p 143:143 -p 993:993 -p 110:110 -p 995:995 inetlinux/mail
```

For Debug:

```
docker run -e mydomain=example.com \
    -v /dev/log:/dev/log \
    -p 10025:25 -p 465:465 -p 143:143 -p 993:993 inetlinux/mail
docker run --rm -v /home:/home -it inetlinux/mail /bin/bash
```

verify
------




APPENDIX A - build
==================

    docker build -t inetlinux/mail .

    # delete images named <none>
    docker rmi $(docker images |grep '<none>'|awk '{ print $3 }')
