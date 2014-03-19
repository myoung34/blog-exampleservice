#!/bin/bash
# If this is an upgrade
if [ "$1" -ge "1" ] ; then
  /sbin/service myapp stop >/dev/null 2>&1 || :
fi
