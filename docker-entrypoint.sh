#!/bin/sh
set -e

# Default HA_URL if not provided, so nginx always gets a valid URL prefix.
# nginx requires proxy_pass to start with a scheme (http:// or https://);
# an empty value causes "invalid URL prefix in /etc/nginx/nginx.conf".
: "${HA_URL:=http://homeassistant.local:8123}"
export HA_URL

# Substitute environment variables in nginx config
envsubst '${HA_URL}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

# Execute the CMD
exec "$@"
