#!/bin/bash -e

/usr/libexec/postfix/aliasesdb
/usr/sbin/postfix start

while [ /bin/true ]; then
    postfix status
    sleep 60
fi
