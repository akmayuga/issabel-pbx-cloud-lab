#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 3 ]; then
  echo "Usage: $0 <to-email> <subject> <message>"
  exit 1
fi

to="$1"
subject="$2"
shift 2
message="$*"

if command -v mail >/dev/null 2>&1; then
  printf "%s\n" "$message" | mail -s "$subject" "$to"
elif command -v sendmail >/dev/null 2>&1; then
  {
    printf "To: %s\n" "$to"
    printf "Subject: %s\n" "$subject"
    printf "\n%s\n" "$message"
  } | sendmail -t
else
  echo "No mail or sendmail command found. Install mailx, postfix, or msmtp."
  exit 1
fi

echo "Alert sent to $to"
