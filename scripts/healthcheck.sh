#!/usr/bin/env bash
set -euo pipefail

warn=0

section() {
  printf "\n== %s ==\n" "$1"
}

check_service() {
  local service="$1"
  if systemctl is-active --quiet "$service"; then
    printf "OK: %s is active\n" "$service"
  else
    printf "WARN: %s is not active\n" "$service"
    warn=1
  fi
}

section "System"
hostnamectl || true
uptime

section "CPU"
top -bn1 | sed -n '1,5p'

section "Memory"
free -h

section "Disk"
df -h /
df -h /var || true

section "Services"
check_service asterisk
check_service httpd
check_service mariadb
check_service fail2ban
check_service firewalld

section "Asterisk"
if command -v asterisk >/dev/null 2>&1 && systemctl is-active --quiet asterisk; then
  asterisk -rx "core show uptime" || true
  asterisk -rx "pjsip show endpoints" || true
  asterisk -rx "pjsip show contacts" || true
else
  printf "Asterisk CLI unavailable; install/start Issabel first.\n"
fi

section "Security"
firewall-cmd --list-all || true
fail2ban-client status || true
fail2ban-client status asterisk || true

section "Recent Logs"
journalctl -u asterisk -n 20 --no-pager || true
journalctl -u fail2ban -n 20 --no-pager || true

if [ "$warn" -eq 0 ]; then
  printf "\nHealth check completed: OK\n"
else
  printf "\nHealth check completed: WARNINGS FOUND\n"
fi

exit "$warn"
