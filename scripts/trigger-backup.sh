#!/bin/bash

set -e

# Stage / Namespace wird als erster Parameter übergeben
NAMESPACE="$1"
CRONJOB_NAME="ds-backup-management"
JOB_NAME="manual-ds-backup-$(date +%s)"
TTL_SECONDS=300

if [[ -z "$NAMESPACE" ]]; then
  echo "❌ Fehler: Bitte gib eine Stage (Namespace) an."
  echo "🔧 Beispiel: ./trigger-backup.sh gidp-dev"
  exit 1
fi

echo "🚀 Starte manuelles Backup in Namespace '$NAMESPACE'..."

# Job erzeugen aus CronJob
kubectl create job "$JOB_NAME" --from=cronjob/"$CRONJOB_NAME" -n "$NAMESPACE"

# TTL setzen (optional, löscht den Job nach X Sekunden)
kubectl patch job "$JOB_NAME" -n "$NAMESPACE" -p "{\"spec\": {\"ttlSecondsAfterFinished\": $TTL_SECONDS}}"

# Auf Job warten
echo "⏳ Warte auf Fertigstellung des Jobs '$JOB_NAME'..."
kubectl wait --for=condition=complete job/"$JOB_NAME" -n "$NAMESPACE" --timeout=300s || {
  echo "❌ Der Job wurde nicht erfolgreich abgeschlossen."
  exit 1
}

# Logs beider Container ausgeben
echo "📦 Logs von 'ds-backup-move':"
kubectl logs job/"$JOB_NAME" -n "$NAMESPACE" -c ds-backup-move || echo "(Keine Logs)"

echo ""
echo "🧹 Logs von 'ds-backup-delete':"
kubectl logs job/"$JOB_NAME" -n "$NAMESPACE" -c ds-backup-delete || echo "(Keine Logs)"

echo ""
echo "✅ Backup in Stage '$NAMESPACE' wurde manuell getriggert und abgeschlossen."