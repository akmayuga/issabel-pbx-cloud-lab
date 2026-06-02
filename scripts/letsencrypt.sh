#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <domain> <admin-email>"
  exit 1
fi

domain="$1"
email="$2"

dnf install -y certbot python3-certbot-apache

certbot --apache \
  --non-interactive \
  --agree-tos \
  --redirect \
  --email "$email" \
  -d "$domain"

systemctl reload httpd
echo "Let's Encrypt certificate installed for $domain"
