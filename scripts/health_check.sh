#!/usr/bin/env bash
set -euo pipefail

# usage: ./health_check.sh http://example.com/health retry_interval_seconds max_attempts
URL="${1:-http://localhost/health}"
INTERVAL="${2:-5}"
MAX="${3:-12}"  # total timeout INTERVAL*MAX

echo "Health-checking $URL, interval=${INTERVAL}s, attempts=${MAX}"

for i in $(seq 1 "$MAX"); do
  STATUS=$(curl -s -o /dev/null -w '%{http_code}' "$URL" || echo "000")
  echo "Attempt $i: HTTP $STATUS"
  if [ "$STATUS" -eq 200 ]; then
    echo "Health check passed."
    exit 0
  fi
  sleep "$INTERVAL"
done

echo "Health check failed after $MAX attempts."
exit 1
