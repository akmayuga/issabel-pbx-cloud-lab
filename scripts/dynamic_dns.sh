#!/usr/bin/env bash
set -euo pipefail

: "${CF_API_TOKEN:?Export CF_API_TOKEN}"
: "${CF_ZONE_ID:?Export CF_ZONE_ID}"
: "${CF_RECORD_ID:?Export CF_RECORD_ID}"
: "${CF_RECORD_NAME:?Export CF_RECORD_NAME, for example pbx.example.com}"

current_ip="$(curl -fsS https://ifconfig.me/ip)"

payload="$(jq -n \
  --arg type "A" \
  --arg name "$CF_RECORD_NAME" \
  --arg content "$current_ip" \
  '{type:$type,name:$name,content:$content,ttl:120,proxied:false}')"

response="$(curl -fsS -X PUT "https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/dns_records/$CF_RECORD_ID" \
  -H "Authorization: Bearer $CF_API_TOKEN" \
  -H "Content-Type: application/json" \
  --data "$payload")"

success="$(printf "%s" "$response" | jq -r '.success')"
if [ "$success" != "true" ]; then
  printf "%s\n" "$response"
  exit 1
fi

echo "Updated $CF_RECORD_NAME to $current_ip"
