#!/bin/sh
set -e

BASE_URL="http://ig/productFetcherNoAuth/azure"
COOKIE=""
PAGE=0

echo "[$(date)] ⏳ Starte vollständigen Durchlauf aller Azure-Produkte…"

while true; do
  URL="$BASE_URL"
  if [ -n "$COOKIE" ]; then
    URL="$BASE_URL?_pagedResultsCookie=$COOKIE"
  fi

  echo "[$(date)] 📥 Abrufe Seite $PAGE"
  RESPONSE=$(curl -s "$URL")

  COOKIE=$(echo "$RESPONSE" | jq -r '.pagedResultsCookie // empty')

  COUNT=$(echo "$RESPONSE" | jq '.result | length')

  if ! echo "$COUNT" | grep -qE '^[0-9]+$' || [ "$COUNT" -eq 0 ] || [ -z "$COOKIE" ]; then
    echo "[$(date)] ✅ Durchlauf beendet."
    break
  fi
  PAGE=$((PAGE + 1))
  sleep 1

done