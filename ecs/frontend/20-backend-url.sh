#!/bin/sh
set -e
if [ -z "$BACKEND_URL" ]; then echo "ERROR: BACKEND_URL is not set"; exit 1; fi
sed -i "s|BACKEND_URL_PLACEHOLDER|${BACKEND_URL}|g" /etc/nginx/conf.d/default.conf
