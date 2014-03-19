#!/bin/bash
# If this is an actual deinstallation
if [ $1 -eq 0 ] ; then
  rm -rf /usr/share/myapp
fi
