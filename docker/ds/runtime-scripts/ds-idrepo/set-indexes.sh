#!/usr/bin/env bash
set -e

# Vollständige Indexerstellung für Backend: idmRepo

echo "🔧 Erstelle Index: uid"
dsconfig create-backend-index \
  --backend-name idmRepo \
  --type generic \
  --index-name uid \
  --set index-type:equality \
  --set index-entry-limit:4000 \
  --offline

echo "🔧 Erstelle Index: mail"
dsconfig create-backend-index \
  --backend-name idmRepo \
  --type generic \
  --index-name mail \
  --set index-type:equality \
  --set index-type:substring \
  --set index-entry-limit:4000 \
  --offline

echo "🔧 Erstelle Index: aci"
dsconfig create-backend-index \
  --backend-name idmRepo \
  --type generic \
  --index-name aci \
  --set index-type:presence \
  --set index-entry-limit:4000 \
  --offline

echo "🔧 Erstelle Index: pwdChangedTime"
dsconfig create-backend-index \
  --backend-name idmRepo \
  --type generic \
  --index-name pwdChangedTime \
  --set index-type:ordering \
  --set index-entry-limit:4000 \
  --offline

echo "🔧 Erstelle Index: fr-idm-managed-user-meta"
dsconfig create-backend-index \
  --backend-name idmRepo \
  --type generic \
  --index-name fr-idm-managed-user-meta \
  --set index-type:extensible \
  --set index-extensible-matching-rule:1.3.6.1.4.1.36733.2.1.4.7 \
  --set index-extensible-matching-rule:1.3.6.1.4.1.36733.2.1.4.8 \
  --set index-entry-limit:4000 \
  --offline

echo "🔧 Erstelle Index: fr-idm-managed-user-groups"
dsconfig create-backend-index \
  --backend-name idmRepo \
  --type generic \
  --index-name fr-idm-managed-user-groups \
  --set index-type:big-extensible \
  --set big-index-extensible-matching-rule:1.3.6.1.4.1.36733.2.1.4.7 \
  --set big-index-extensible-matching-rule:1.3.6.1.4.1.36733.2.1.4.8 \
  --set index-entry-limit:4000 \
  --offline

echo "🔧 Erstelle Index: fr-idm-reconassocentry-situation"
dsconfig create-backend-index \
  --backend-name idmRepo \
  --type generic \
  --index-name fr-idm-reconassocentry-situation \
  --set index-type:big-equality \
  --set index-entry-limit:4000 \
  --offline

echo "🔧 Erstelle Index: givenName"
dsconfig create-backend-index \
  --backend-name idmRepo \
  --type generic \
  --index-name givenName \
  --set index-type:equality \
  --set index-type:substring \
  --set index-entry-limit:4000 \
  --offline

echo "🔧 Erstelle Index: objectClass"
dsconfig create-backend-index \
  --backend-name idmRepo \
  --type generic \
  --index-name objectClass \
  --set index-type:big-equality \
  --set index-type:equality \
  --set index-entry-limit:4000 \
  --offline