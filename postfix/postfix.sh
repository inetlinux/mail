#!/bin/bash

/usr/libexec/postfix/aliasesdb
/usr/sbin/postfix start

while [ 0 ]; do
    postfix status || /usr/sbin/postfix start
    sleep 60
done
