#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

docker run -i stedolan/jq < ${SCRIPT_DIR}/Tests.postman_collection.json --raw-output '.item | to_entries | .[] | .value.name as $tenantname | .key as $tenantnumber | .value.item | to_entries | .[] | .value.name as $testcasename | .value.description as $testcasedescription | .key as $testcasenumber | .value.item | to_entries | .[] | [ (($tenantnumber*100 + $testcasenumber + 1) ), ($tenantname + " / " + $testcasename), ($testcasedescription), "CIAM Dev Team", "automated", ((.key+1) ), (if (.value.request | has("description")) then .value.request.description else .value.name end), " ", " ", "Not executed", " " ] | @csv' > ${SCRIPT_DIR}/testList.csv
