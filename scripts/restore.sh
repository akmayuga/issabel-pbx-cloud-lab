#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 /path/to/issabel-backup-YYYYMMDD-HHMMSS.tar.gz"
  exit 1
fi

archive="$1"
if [ ! -f "$archive" ]; then
  echo "Backup archive not found: $archive"
  exit 2
fi

if [ -f "$archive.sha256" ]; then
  sha256sum -c "$archive.sha256"
fi

echo "This will restore files into / and restart PBX services."
read -r -p "Type RESTORE to continue: " confirm
if [ "$confirm" != "RESTORE" ]; then
  echo "Restore cancelled."
  exit 3
fi

systemctl stop asterisk || true
tar -xzf "$archive" -C /
chown -R asterisk:asterisk /etc/asterisk /var/lib/asterisk /var/spool/asterisk || true
restorecon -Rv /etc/asterisk /var/lib/asterisk /var/spool/asterisk || true

systemctl restart mariadb || true
systemctl restart httpd || true
systemctl restart asterisk
systemctl restart fail2ban || true
firewall-cmd --reload || true

echo "Restore complete. Run /usr/local/sbin/healthcheck.sh next."
