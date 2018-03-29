#!/bin/sh

# run craft setup
/usr/bin/expect tmp/setup.exp;

# start apache in foreground
/usr/sbin/httpd -D FOREGROUND
