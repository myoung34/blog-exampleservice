#!/bin/bash
python -m SimpleHTTPServer 8000 > /var/log/myapp 2>&1 &
