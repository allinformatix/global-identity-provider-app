dsconfig list-backend-indexes \
  --backend-name idmRepo \
  --hostname localhost \
  --port 4444 \
  --bindDN "uid=admin" \
  --bindPassword "$(cat "$DS_UID_ADMIN_PASSWORD_FILE")" \
  --trustAll


Backend Index                                   : index-type             : index-entry-limit : index-extensible-matching-rule                       : big-index-extensible-matching-rule                   : confidentiality-enabled
------------------------------------------------:------------------------:-------------------:------------------------------------------------------:------------------------------------------------------:------------------------
aci                                             : presence               : 4000              : -                                                    : -                                                    : false
cn                                              : equality, substring    : 4000              : -                                                    : -                                                    : false
ds-certificate-fingerprint                      : equality               : 4000              : -                                                    : -                                                    : false
ds-certificate-subject-dn                       : equality               : 4000              : -                                                    : -                                                    : false
ds-sync-conflict                                : equality               : 4000              : -                                                    : -                                                    : false
ds-sync-hist                                    : ordering               : 4000              : -                                                    : -                                                    : false
entryUUID                                       : equality               : 4000              : -                                                    : -                                                    : false
fr-idm-cluster-json                             : equality               : 4000              : -                                                    : -                                                    : false
fr-idm-custom-attrs                             : equality               : 4000              : -                                                    : -                                                    : false
fr-idm-internal-role-authzmembers-internal-user : big-extensible         : 4000              : -                                                    : 1.3.6.1.4.1.36733.2.1.4.7, 1.3.6.1.4.1.36733.2.1.4.8 : false
fr-idm-internal-role-authzmembers-managed-user  : big-extensible         : 4000              : -                                                    : 1.3.6.1.4.1.36733.2.1.4.7, 1.3.6.1.4.1.36733.2.1.4.8 : false
fr-idm-internal-user-authzroles-internal-role   : big-extensible         : 4000              : -                                                    : 1.3.6.1.4.1.36733.2.1.4.7, 1.3.6.1.4.1.36733.2.1.4.8 : false
fr-idm-internal-user-authzroles-managed-role    : big-extensible         : 4000              : -                                                    : 1.3.6.1.4.1.36733.2.1.4.7, 1.3.6.1.4.1.36733.2.1.4.8 : false
fr-idm-json                                     : equality               : 4000              : -                                                    : -                                                    : false
fr-idm-link-firstid                             : equality               : 4000              : -                                                    : -                                                    : false
fr-idm-link-firstid-constraint                  : equality               : 4000              : -                                                    : -                                                    : false
fr-idm-link-qualifier                           : equality               : 4000              : -                                                    : -                                                    : false
fr-idm-link-secondid                            : equality               : 4000              : -                                                    : -                                                    : false
fr-idm-link-secondid-constraint                 : equality               : 4000              : -                                                    : -                                                    : false
fr-idm-link-type                                : equality               : 4000              : -                                                    : -                                                    : false
fr-idm-lock-nodeid                              : equality               : 4000              : -                                                    : -                                                    : false
fr-idm-managed-application-json                 : equality               : 4000              : -                                                    : -                                                    : false
fr-idm-managed-application-member               : big-extensible         : 4000              : -                                                    : 1.3.6.1.4.1.36733.2.1.4.7, 1.3.6.1.4.1.36733.2.1.4.8 : false
fr-idm-managed-application-owner                : big-extensible         : 4000              : -                                                    : 1.3.6.1.4.1.36733.2.1.4.7, 1.3.6.1.4.1.36733.2.1.4.8 : false
fr-idm-managed-assignment-json                  : equality               : 4000              : -                                                    : -                                                    : false
fr-idm-managed-assignment-member                : big-extensible         : 4000              : -                                                    : 1.3.6.1.4.1.36733.2.1.4.7, 1.3.6.1.4.1.36733.2.1.4.8 : false
fr-idm-managed-group-json                       : equality               : 4000              : -                                                    : -                                                    : false
fr-idm-managed-organization-admin               : big-extensible         : 4000              : -                                                    : 1.3.6.1.4.1.36733.2.1.4.7, 1.3.6.1.4.1.36733.2.1.4.8 : false
fr-idm-managed-organization-json                : equality               : 4000              : -                                                    : -                                                    : false
fr-idm-managed-organization-member              : big-extensible         : 4000              : -                                                    : 1.3.6.1.4.1.36733.2.1.4.7, 1.3.6.1.4.1.36733.2.1.4.8 : false
fr-idm-managed-organization-name                : equality               : 4000              : -                                                    : -                                                    : false
fr-idm-managed-organization-owner               : big-extensible         : 4000              : -                                                    : 1.3.6.1.4.1.36733.2.1.4.7, 1.3.6.1.4.1.36733.2.1.4.8 : false
fr-idm-managed-organization-parent              : big-extensible         : 4000              : -                                                    : 1.3.6.1.4.1.36733.2.1.4.7, 1.3.6.1.4.1.36733.2.1.4.8 : false
fr-idm-managed-role-applications                : big-extensible         : 4000              : -                                                    : 1.3.6.1.4.1.36733.2.1.4.7, 1.3.6.1.4.1.36733.2.1.4.8 : false
fr-idm-managed-role-assignments                 : big-extensible         : 4000              : -                                                    : 1.3.6.1.4.1.36733.2.1.4.7, 1.3.6.1.4.1.36733.2.1.4.8 : false
fr-idm-managed-role-json                        : equality               : 4000              : -                                                    : -                                                    : false
fr-idm-managed-user-active-date                 : ordering               : 4000              : -                                                    : -                                                    : false
fr-idm-managed-user-authzroles-internal-role    : big-extensible         : 4000              : -                                                    : 1.3.6.1.4.1.36733.2.1.4.7, 1.3.6.1.4.1.36733.2.1.4.8 : false
fr-idm-managed-user-authzroles-managed-role     : big-extensible         : 4000              : -                                                    : 1.3.6.1.4.1.36733.2.1.4.7, 1.3.6.1.4.1.36733.2.1.4.8 : false
fr-idm-managed-user-custom-attrs                : equality               : 4000              : -                                                    : -                                                    : false
fr-idm-managed-user-groups                      : big-extensible         : 4000              : -                                                    : 1.3.6.1.4.1.36733.2.1.4.7, 1.3.6.1.4.1.36733.2.1.4.8 : false
fr-idm-managed-user-inactive-date               : ordering               : 4000              : -                                                    : -                                                    : false
fr-idm-managed-user-json                        : equality               : 4000              : -                                                    : -                                                    : false
fr-idm-managed-user-manager                     : big-extensible         : 4000              : -                                                    : 1.3.6.1.4.1.36733.2.1.4.7, 1.3.6.1.4.1.36733.2.1.4.8 : false
fr-idm-managed-user-meta                        : extensible             : 4000              : 1.3.6.1.4.1.36733.2.1.4.7, 1.3.6.1.4.1.36733.2.1.4.8 : -                                                    : false
fr-idm-managed-user-notifications               : extensible             : 4000              : 1.3.6.1.4.1.36733.2.1.4.7, 1.3.6.1.4.1.36733.2.1.4.8 : -                                                    : false
fr-idm-managed-user-roles                       : big-extensible         : 4000              : -                                                    : 1.3.6.1.4.1.36733.2.1.4.7, 1.3.6.1.4.1.36733.2.1.4.8 : false
fr-idm-managed-user-task-principals             : big-extensible         : 4000              : -                                                    : 1.3.6.1.4.1.36733.2.1.4.7, 1.3.6.1.4.1.36733.2.1.4.8 : false
fr-idm-reconassocentry-situation                : big-equality           : 4000              : -                                                    : -                                                    : false
fr-idm-reference-1                              : big-extensible         : 4000              : -                                                    : 1.3.6.1.4.1.36733.2.1.4.7, 1.3.6.1.4.1.36733.2.1.4.8 : false
fr-idm-reference-2                              : big-extensible         : 4000              : -                                                    : 1.3.6.1.4.1.36733.2.1.4.7, 1.3.6.1.4.1.36733.2.1.4.8 : false
fr-idm-reference-3                              : big-extensible         : 4000              : -                                                    : 1.3.6.1.4.1.36733.2.1.4.7, 1.3.6.1.4.1.36733.2.1.4.8 : false
fr-idm-reference-4                              : big-extensible         : 4000              : -                                                    : 1.3.6.1.4.1.36733.2.1.4.7, 1.3.6.1.4.1.36733.2.1.4.8 : false
fr-idm-reference-5                              : big-extensible         : 4000              : -                                                    : 1.3.6.1.4.1.36733.2.1.4.7, 1.3.6.1.4.1.36733.2.1.4.8 : false
fr-idm-relationship-json                        : big-equality           : 4000              : -                                                    : -                                                    : false
fr-idm-syncqueue-createdate                     : equality               : 4000              : -                                                    : -                                                    : false
fr-idm-syncqueue-mapping                        : equality               : 4000              : -                                                    : -                                                    : false
fr-idm-syncqueue-resourceid                     : equality               : 4000              : -                                                    : -                                                    : false
fr-idm-syncqueue-state                          : equality               : 4000              : -                                                    : -                                                    : false
fr-idm-uuid                                     : equality               : 4000              : -                                                    : -                                                    : false
givenName                                       : equality, substring    : 4000              : -                                                    : -                                                    : false
mail                                            : equality, substring    : 4000              : -                                                    : -                                                    : false
member                                          : equality               : 4000              : -                                                    : -                                                    : false
objectClass                                     : big-equality, equality : 4000              : -                                                    : -                                                    : false
pwdChangedTime                                  : ordering               : 4000              : -                                                    : -                                                    : false
sn                                              : equality, substring    : 4000              : -                                                    : -                                                    : false
telephoneNumber                                 : equality, substring    : 4000              : -                                                    : -                                                    : false
uid                                             : equality               : 4000              : -                                                    : -                                                    : false
uniqueMember                                    : equality               : 4000              : -                                                    : -                                                    : false