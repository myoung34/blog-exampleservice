#!/bin/bash
# If this is an actual deinstallation
if [ $1 -eq 0 ] ; then
  /sbin/service myapp stop >/dev/null 2>&1
  /sbin/chkconfig --del myapp
fi

