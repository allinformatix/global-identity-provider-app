#!/bin/bash

PS4='+ $(date "+%H:%M:%S")\011 '
set -eo pipefail

ADMIN_PASS=$(cat /var/run/secrets/opendj-passwords/dirmanager.pw)

echo "GIDP ADMINS group member can access changelog attributes on root DSE and the changelog data"
dsconfig set-access-control-handler-prop \
    --add global-aci:"(target=\"ldap:///\")\
    (targetattr=\"changeLog||firstChangeNumber||lastChangeNumber||lastExternalChangeLogCookie\")\
    (version 3.0; acl \"GIDP ADMINS group member can access changelog attributes on root DSE\"; \
    allow (read,search,compare) \
    groupdn =\"ldap:///cn=GIDP ADMINS,ou=groups,ou=identities\";)" \
    --add global-aci:"(target=\"ldap:///cn=changelog\")(targetattr=\"*||+\")\
    (version 3.0; acl \"GIDP ADMINS group member can access cn=changelog\"; \
    allow (read,search,compare) \
    groupdn =\"ldap:///cn=GIDP ADMINS,ou=groups,ou=identities\";)" \
    --hostname "ds-idrepo-0.ds-idrepo" \
    --port 4444 \
    --bindDN "uid=admin" \
    --bindPassword "${ADMIN_PASS}" \
    --trustAll \
    --no-prompt

dsconfig set-access-control-handler-prop \
    --add global-aci:"(targetcontrol=\"Ecl\")\
        (version 3.0; acl \"GIDP ADMINS group member can use the public changelog exchange control\"; \
        allow (read,search,compare) \
        groupdn =\"ldap:///cn=GIDP ADMINS,ou=groups,ou=identities\";)" \
    --hostname "ds-idrepo-0.ds-idrepo" \
    --port 4444 \
    --bindDN "uid=admin" \
    --bindPassword "${ADMIN_PASS}" \
    --trustAll \
    --no-prompt

echo "GIDP ADMINS group member can access cn=task"
dsconfig set-access-control-handler-prop \
    --add global-aci:"(target=\"ldap:///cn=tasks\")(targetattr=\"*||+\")\
    (version 3.0; acl \"GIDP ADMINS group member can access cn=tasks\"; \
    allow (add,write,read,search,compare) \
    groupdn =\"ldap:///cn=GIDP ADMINS,ou=groups,ou=identities\";)" \
    --hostname "ds-idrepo-0.ds-idrepo" \
    --port 4444 \
    --bindDN "uid=admin" \
    --bindPassword "${ADMIN_PASS}" \
    --trustAll \
    --no-prompt
