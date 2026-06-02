#!/usr/bin/env bash
set -euo pipefail

BACKUP_DIR="${BACKUP_DIR:-/var/backups/issabel}"
RETENTION_DAYS="${RETENTION_DAYS:-14}"
DATE="$(date +%Y%m%d-%H%M%S)"
TARGET="$BACKUP_DIR/issabel-backup-$DATE.tar.gz"
MANIFEST="$BACKUP_DIR/issabel-backup-$DATE.manifest.txt"

mkdir -p "$BACKUP_DIR"
chmod 700 "$BACKUP_DIR"

paths=(
  /etc/asterisk
  /etc/fail2ban
  /etc/firewalld
  /etc/httpd
  /etc/issabel.conf
  /var/lib/asterisk
  /var/log/asterisk/cdr-csv
  /var/spool/asterisk/monitor
  /var/spool/asterisk/voicemail
)

existing_paths=()
for path in "${paths[@]}"; do
  if [ -e "$path" ]; then
    existing_paths+=("$path")
  fi
done

if [ "${#existing_paths[@]}" -eq 0 ]; then
  echo "No Issabel/Asterisk paths found to back up."
  exit 1
fi

printf "%s\n" "${existing_paths[@]}" > "$MANIFEST"
tar --warning=no-file-changed -czf "$TARGET" "${existing_paths[@]}"
sha256sum "$TARGET" > "$TARGET.sha256"

find "$BACKUP_DIR" -type f -name "issabel-backup-*.tar.gz*" -mtime "+$RETENTION_DAYS" -delete
find "$BACKUP_DIR" -type f -name "issabel-backup-*.manifest.txt" -mtime "+$RETENTION_DAYS" -delete

echo "Backup completed: $TARGET"
echo "Checksum: $TARGET.sha256"
