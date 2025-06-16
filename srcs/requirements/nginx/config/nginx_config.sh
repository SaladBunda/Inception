#!/bin/bash

CERT_DIR="/etc/nginx/certs"

mkdir -p "$CERT_DIR"

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout "$CERT_DIR/server.key" \
  -out "$CERT_DIR/server.crt" \
  -subj "/C=FR/ST=Login/L=Login/O=Login Inc./CN=ael-maaz.42.fr"

exec nginx -g "daemon off;";