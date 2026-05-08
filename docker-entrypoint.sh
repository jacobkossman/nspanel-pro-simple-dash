#!/bin/sh
set -e

# Substitute environment variables in nginx config
envsubst '${HA_URL}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

# Execute the CMD
exec "$@"
