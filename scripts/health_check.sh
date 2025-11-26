#!/bin/bash

APP_URL=$1

if [[ -z "$APP_URL" ]]; then
  echo "Usage: ./health_check.sh <url>"
  exit 1
fi

echo "Performing health check on $APP_URL ..."

STATUS=$(curl -s -o /dev/null -w "%{http_code}" $APP_URL)

if [[ "$STATUS" == "200" ]]; then
  echo "Health check PASSED ✔"
  exit 0
else
  echo "Health check FAILED ✘ (HTTP $STATUS)"
  exit 1
fi
