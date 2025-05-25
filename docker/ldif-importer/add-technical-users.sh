#!/bin/bash

PS4='+ $(date "+%H:%M:%S")\011 '
set -e

runFile () {
    local HOST=$1
    local ADMIN_PASS=$2
    local FILE_TO_RUN=$3
    #add -c option to continue processing even if there are errors 
    CXN="-c -h ${HOST} -p 1389 -w ${ADMIN_PASS}"
    MOD_RESPONSE=0
    ldapmodify ${CXN} -D "uid=admin" ${FILE_TO_RUN} || MOD_RESPONSE=$?
    case "${MOD_RESPONSE}" in
        "0")
            echo "Users have been added"
        ;;
        "68")
            echo "Duplicate user, skipping..."
            exit 0
        ;;
        *)
            echo "ERROR: Error when adding user, response $SEARCH_RESPONSE"
            exit 1
        ;;
    esac
}

ADMIN_PASS=$(cat /var/run/secrets/opendj-passwords/dirmanager.pw)

runFile ds-idrepo-0.ds-idrepo ${ADMIN_PASS} allinformatixTechUsers.ldif

echo "Users script finished"
