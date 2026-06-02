#!/usr/bin/env bash
set -euo pipefail

out_dir="${1:-/var/lib/node_exporter/textfile_collector}"
tmp_file="$out_dir/asterisk.prom.$$"
out_file="$out_dir/asterisk.prom"

mkdir -p "$out_dir"

if systemctl is-active --quiet asterisk; then
  active=1
else
  active=0
fi

registered_contacts=0
if command -v asterisk >/dev/null 2>&1 && [ "$active" -eq 1 ]; then
  registered_contacts="$(asterisk -rx 'pjsip show contacts' | awk '/Contact:/ {count++} END {print count+0}')"
fi

cat > "$tmp_file" <<EOF
# HELP asterisk_service_up Whether the Asterisk service is active.
# TYPE asterisk_service_up gauge
asterisk_service_up $active
# HELP asterisk_pjsip_registered_contacts Number of visible PJSIP contacts.
# TYPE asterisk_pjsip_registered_contacts gauge
asterisk_pjsip_registered_contacts $registered_contacts
EOF

mv "$tmp_file" "$out_file"
