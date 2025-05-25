#!/usr/bin/env bash
set -euo pipefail

CSV_FILE="idmRepo_index_table.csv"
BACKEND_NAME="idmRepo"

echo "📦 Erstelle Indizes für Backend: $BACKEND_NAME aus CSV: $CSV_FILE"

IFS=','
tail -n +2 "$CSV_FILE" | while read -r index_name index_type index_entry_limit extensible_rule big_extensible_rule; do
  echo "🔧 Erstelle Index: $index_name ($index_type)"
  CMD=(dsconfig create-backend-index
       --backend-name "$BACKEND_NAME"
       --type generic
       --index-name "$index_name"
       --offline)
  IFS=';' read -ra TYPES <<< "${index_type//,/;}"
  for t in "${TYPES[@]}"; do
    CMD+=(--set "index-type:$t")
  done
  if [[ -n "$extensible_rule" && "$extensible_rule" != "-" ]]; then
    IFS=';' read -ra RULES <<< "${extensible_rule//,/;}"
    for r in "${RULES[@]}"; do
      CMD+=(--set "index-extensible-matching-rule:$r")
    done
  fi
  if [[ -n "$big_extensible_rule" && "$big_extensible_rule" != "-" ]]; then
    IFS=';' read -ra BRULES <<< "${big_extensible_rule//,/;}"
    for br in "${BRULES[@]}"; do
      CMD+=(--set "big-index-extensible-matching-rule:$br")
    done
  fi
  CMD+=(--set "index-entry-limit:$index_entry_limit")
  echo "${CMD[@]}"
  "${CMD[@]}"
done