#!/bin/bash

procmail -t RCFILE="$1" /etc/exim4/procmail.rc 2>&1 | /usr/bin/logger -t "procmail[$PPID]" -p mail.debug -u /dev/log-dgram

