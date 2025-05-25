#!/usr/bin/env bash
set -e
# Indizes für Backend: idmRepo

echo "🔧 Erstelle Index: aci"
dsconfig create-backend-index \
  --backend-name idmRepo \
  --type generic \
  --index-name aci \
  --set index-type:presence \
  --set index-entry-limit:4000 \
  --offline

echo "🔧 Erstelle Index: cn"
dsconfig create-backend-index \
  --backend-name idmRepo \
  --type generic \
  --index-name cn \
  --set index-type:equality \
  --set index-type:substring \
  --set index-entry-limit:4000 \
  --offline

echo "🔧 Erstelle Index: ds-certificate-fingerprint"
dsconfig create-backend-index \
  --backend-name idmRepo \
  --type generic \
  --index-name ds-certificate-fingerprint \
  --set index-type:equality \
  --set index-entry-limit:4000 \
  --offline

echo "🔧 Erstelle Index: ds-certificate-subject-dn"
dsconfig create-backend-index \
  --backend-name idmRepo \
  --type generic \
  --index-name ds-certificate-subject-dn \
  --set index-type:equality \
  --set index-entry-limit:4000 \
  --offline

echo "🔧 Erstelle Index: ds-sync-conflict"
dsconfig create-backend-index \
  --backend-name idmRepo \
  --type generic \
  --index-name ds-sync-conflict \
  --set index-type:equality \
  --set index-entry-limit:4000 \
  --offline

echo "🔧 Erstelle Index: ds-sync-hist"
dsconfig create-backend-index \
  --backend-name idmRepo \
  --type generic \
  --index-name ds-sync-hist \
  --set index-type:ordering \
  --set index-entry-limit:4000 \
  --offline

echo "🔧 Erstelle Index: entryUUID"
dsconfig create-backend-index \
  --backend-name idmRepo \
  --type generic \
  --index-name entryUUID \
  --set index-type:equality \
  --set index-entry-limit:4000 \
  --offline

echo "🔧 Erstelle Index: fr-idm-cluster-json"
dsconfig create-backend-index \
  --backend-name idmRepo \
  --type generic \
  --index-name fr-idm-cluster-json \
  --set index-type:equality \
  --set index-entry-limit:4000 \
  --offline

echo "🔧 Erstelle Index: fr-idm-custom-attrs"
dsconfig create-backend-index \
  --backend-name idmRepo \
  --type generic \
  --index-name fr-idm-custom-attrs \
  --set index-type:equality \
  --set index-entry-limit:4000 \
  --offline

echo "🔧 Erstelle Index: fr-idm-internal-role-authzmembers-internal-user"
dsconfig create-backend-index \
  --backend-name idmRepo \
  --type generic \
  --index-name fr-idm-internal-role-authzmembers-internal-user \
  --set index-type:big-extensible \
  --set big-index-extensible-matching-rule:1.3.6.1.4.1.36733.2.1.4.7 \
  --set big-index-extensible-matching-rule:1.3.6.1.4.1.36733.2.1.4.8 \
  --set index-entry-limit:4000 \
  --offline

echo "🔧 Erstelle Index: fr-idm-internal-role-authzmembers-managed-user"
dsconfig create-backend-index \
  --backend-name idmRepo \
  --type generic \
  --index-name fr-idm-internal-role-authzmembers-managed-user \
  --set index-type:big-extensible \
  --set big-index-extensible-matching-rule:1.3.6.1.4.1.36733.2.1.4.7 \
  --set big-index-extensible-matching-rule:1.3.6.1.4.1.36733.2.1.4.8 \
  --set index-entry-limit:4000 \
  --offline

echo "🔧 Erstelle Index: fr-idm-internal-user-authzroles-internal-role"
dsconfig create-backend-index \
  --backend-name idmRepo \
  --type generic \
  --index-name fr-idm-internal-user-authzroles-internal-role \
  --set index-type:big-extensible \
  --set big-index-extensible-matching-rule:1.3.6.1.4.1.36733.2.1.4.7 \
  --set big-index-extensible-matching-rule:1.3.6.1.4.1.36733.2.1.4.8 \
  --set index-entry-limit:4000 \
  --offline

echo "🔧 Erstelle Index: fr-idm-internal-user-authzroles-managed-role"
dsconfig create-backend-index \
  --backend-name idmRepo \
  --type generic \
  --index-name fr-idm-internal-user-authzroles-managed-role \
  --set index-type:big-extensible \
  --set big-index-extensible-matching-rule:1.3.6.1.4.1.36733.2.1.4.7 \
  --set big-index-extensible-matching-rule:1.3.6.1.4.1.36733.2.1.4.8 \
  --set index-entry-limit:4000 \
  --offline

echo "🔧 Erstelle Index: fr-idm-json"
dsconfig create-backend-index \
  --backend-name idmRepo \
  --type generic \
  --index-name fr-idm-json \
  --set index-type:equality \
  --set index-entry-limit:4000 \
  --offline

echo "🔧 Erstelle Index: fr-idm-link-firstid"
dsconfig create-backend-index \
  --backend-name idmRepo \
  --type generic \
  --index-name fr-idm-link-firstid \
  --set index-type:equality \
  --set index-entry-limit:4000 \
  --offline

echo "🔧 Erstelle Index: fr-idm-link-firstid-constraint"
dsconfig create-backend-index \
  --backend-name idmRepo \
  --type generic \
  --index-name fr-idm-link-firstid-constraint \
  --set index-type:equality \
  --set index-entry-limit:4000 \
  --offline

echo "🔧 Erstelle Index: fr-idm-link-qualifier"
dsconfig create-backend-index \
  --backend-name idmRepo \
  --type generic \
  --index-name fr-idm-link-qualifier \
  --set index-type:equality \
  --set index-entry-limit:4000 \
  --offline

echo "🔧 Erstelle Index: fr-idm-link-secondid"
dsconfig create-backend-index \
  --backend-name idmRepo \
  --type generic \
  --index-name fr-idm-link-secondid \
  --set index-type:equality \
  --set index-entry-limit:4000 \
  --offline

echo "🔧 Erstelle Index: fr-idm-link-secondid-constraint"
dsconfig create-backend-index \
  --backend-name idmRepo \
  --type generic \
  --index-name fr-idm-link-secondid-constraint \
  --set index-type:equality \
  --set index-entry-limit:4000 \
  --offline

echo "🔧 Erstelle Index: fr-idm-link-type"
dsconfig create-backend-index \
  --backend-name idmRepo \
  --type generic \
  --index-name fr-idm-link-type \
  --set index-type:equality \
  --set index-entry-limit:4000 \
  --offline

echo "🔧 Erstelle Index: fr-idm-lock-nodeid"
dsconfig create-backend-index \
  --backend-name idmRepo \
  --type generic \
  --index-name fr-idm-lock-nodeid \
  --set index-type:equality \
  --set index-entry-limit:4000 \
  --offline

echo "🔧 Erstelle Index: fr-idm-managed-application-json"
dsconfig create-backend-index \
  --backend-name idmRepo \
  --type generic \
  --index-name fr-idm-managed-application-json \
  --set index-type:equality \
  --set index-entry-limit:4000 \
  --offline

echo "🔧 Erstelle Index: fr-idm-managed-application-member"
dsconfig create-backend-index \
  --backend-name idmRepo \
  --type generic \
  --index-name fr-idm-managed-application-member \
  --set index-type:big-extensible \
  --set big-index-extensible-matching-rule:1.3.6.1.4.1.36733.2.1.4.7 \
  --set big-index-extensible-matching-rule:1.3.6.1.4.1.36733.2.1.4.8 \
  --set index-entry-limit:4000 \
  --offline

echo "🔧 Erstelle Index: fr-idm-managed-application-owner"
dsconfig create-backend-index \
  --backend-name idmRepo \
  --type generic \
  --index-name fr-idm-managed-application-owner \
  --set index-type:big-extensible \
  --set big-index-extensible-matching-rule:1.3.6.1.4.1.36733.2.1.4.7 \
  --set big-index-extensible-matching-rule:1.3.6.1.4.1.36733.2.1.4.8 \
  --set index-entry-limit:4000 \
  --offline

echo "🔧 Erstelle Index: fr-idm-managed-assignment-json"
dsconfig create-backend-index \
  --backend-name idmRepo \
  --type generic \
  --index-name fr-idm-managed-assignment-json \
  --set index-type:equality \
  --set index-entry-limit:4000 \
  --offline

echo "🔧 Erstelle Index: fr-idm-managed-assignment-member"
dsconfig create-backend-index \
  --backend-name idmRepo \
  --type generic \
  --index-name fr-idm-managed-assignment-member \
  --set index-type:big-extensible \
  --set big-index-extensible-matching-rule:1.3.6.1.4.1.36733.2.1.4.7 \
  --set big-index-extensible-matching-rule:1.3.6.1.4.1.36733.2.1.4.8 \
  --set index-entry-limit:4000 \
  --offline

echo "🔧 Erstelle Index: fr-idm-managed-group-json"
dsconfig create-backend-index \
  --backend-name idmRepo \
  --type generic \
  --index-name fr-idm-managed-group-json \
  --set index-type:equality \
  --set index-entry-limit:4000 \
  --offline

echo "🔧 Erstelle Index: fr-idm-managed-organization-admin"
dsconfig create-backend-index \
  --backend-name idmRepo \
  --type generic \
  --index-name fr-idm-managed-organization-admin \
  --set index-type:big-extensible \
  --set big-index-extensible-matching-rule:1.3.6.1.4.1.36733.2.1.4.7 \
  --set big-index-extensible-matching-rule:1.3.6.1.4.1.36733.2.1.4.8 \
  --set index-entry-limit:4000 \
  --offline

echo "🔧 Erstelle Index: fr-idm-managed-organization-json"
dsconfig create-backend-index \
  --backend-name idmRepo \
  --type generic \
  --index-name fr-idm-managed-organization-json \
  --set index-type:equality \
  --set index-entry-limit:4000 \
  --offline

echo "🔧 Erstelle Index: fr-idm-managed-organization-member"
dsconfig create-backend-index \
  --backend-name idmRepo \
  --type generic \
  --index-name fr-idm-managed-organization-member \
  --set index-type:big-extensible \
  --set big-index-extensible-matching-rule:1.3.6.1.4.1.36733.2.1.4.7 \
  --set big-index-extensible-matching-rule:1.3.6.1.4.1.36733.2.1.4.8 \
  --set index-entry-limit:4000 \
  --offline

echo "🔧 Erstelle Index: fr-idm-managed-organization-name"
dsconfig create-backend-index \
  --backend-name idmRepo \
  --type generic \
  --index-name fr-idm-managed-organization-name \
  --set index-type:equality \
  --set index-entry-limit:4000 \
  --offline

echo "🔧 Erstelle Index: fr-idm-managed-organization-owner"
dsconfig create-backend-index \
  --backend-name idmRepo \
  --type generic \
  --index-name fr-idm-managed-organization-owner \
  --set index-type:big-extensible \
  --set big-index-extensible-matching-rule:1.3.6.1.4.1.36733.2.1.4.7 \
  --set big-index-extensible-matching-rule:1.3.6.1.4.1.36733.2.1.4.8 \
  --set index-entry-limit:4000 \
  --offline

echo "🔧 Erstelle Index: fr-idm-managed-organization-parent"
dsconfig create-backend-index \
  --backend-name idmRepo \
  --type generic \
  --index-name fr-idm-managed-organization-parent \
  --set index-type:big-extensible \
  --set big-index-extensible-matching-rule:1.3.6.1.4.1.36733.2.1.4.7 \
  --set big-index-extensible-matching-rule:1.3.6.1.4.1.36733.2.1.4.8 \
  --set index-entry-limit:4000 \
  --offline

echo "🔧 Erstelle Index: fr-idm-managed-role-applications"
dsconfig create-backend-index \
  --backend-name idmRepo \
  --type generic \
  --index-name fr-idm-managed-role-applications \
  --set index-type:big-extensible \
  --set big-index-extensible-matching-rule:1.3.6.1.4.1.36733.2.1.4.7 \
  --set big-index-extensible-matching-rule:1.3.6.1.4.1.36733.2.1.4.8 \
  --set index-entry-limit:4000 \
  --offline

echo "🔧 Erstelle Index: fr-idm-managed-role-assignments"
dsconfig create-backend-index \
  --backend-name idmRepo \
  --type generic \
  --index-name fr-idm-managed-role-assignments \
  --set index-type:big-extensible \
  --set big-index-extensible-matching-rule:1.3.6.1.4.1.36733.2.1.4.7 \
  --set big-index-extensible-matching-rule:1.3.6.1.4.1.36733.2.1.4.8 \
  --set index-entry-limit:4000 \
  --offline

echo "🔧 Erstelle Index: fr-idm-managed-role-json"
dsconfig create-backend-index \
  --backend-name idmRepo \
  --type generic \
  --index-name fr-idm-managed-role-json \
  --set index-type:equality \
  --set index-entry-limit:4000 \
  --offline

echo "🔧 Erstelle Index: fr-idm-managed-user-active-date"
dsconfig create-backend-index \
  --backend-name idmRepo \
  --type generic \
  --index-name fr-idm-managed-user-active-date \
  --set index-type:ordering \
  --set index-entry-limit:4000 \
  --offline

echo "🔧 Erstelle Index: fr-idm-managed-user-authzroles-internal-role"
dsconfig create-backend-index \
  --backend-name idmRepo \
  --type generic \
  --index-name fr-idm-managed-user-authzroles-internal-role \
  --set index-type:big-extensible \
  --set big-index-extensible-matching-rule:1.3.6.1.4.1.36733.2.1.4.7 \
  --set big-index-extensible-matching-rule:1.3.6.1.4.1.36733.2.1.4.8 \
  --set index-entry-limit:4000 \
  --offline
