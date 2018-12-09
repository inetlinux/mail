
Usage: start mail server
========================

Main usage:

    # start docker container
    docker run -d -n mail -v /dev/log:/dev/log -v /home:/home -p 10025:25 -p 465:465 -p 143:143 -p 993:993 -p 110:110 -p 995:995 --name mail inetlinux/mail

For Debug:

    docker run -v /dev/log:/dev/log -v /home:/home -p 10025:25 -p 465:465 -p 143:143 -p 993:993 -p 110:110 -p 995:995  inetlinux/mail
    docker run --rm -v /home:/home -it inetlinux/mail /bin/bash

verify
------


APPENDIX A - build
==================

    docker build -t inetlinux/mail .

    # delete images named <none>
    docker rmi $(docker images |grep '<none>'|awk '{ print $3 }')
