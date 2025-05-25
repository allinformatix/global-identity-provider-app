#!/usr/bin/env bash

# test k8s connection
kubectl cluster-info
if [[ $? -ne 0 ]]; then
    echo "k8s connection not established. Stopping script..."
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ENVIRONMENT_TO_BUILD=${ENVIRONMENT_TO_BUILD:-dev}
NEWMAN_OPTS=""

case "${ENVIRONMENT_TO_BUILD}" in
    dev)
        POSTMAN_ENVIRONMENT_PREFIX="dev"
        NEWMAN_OPTS="${NEWMAN_OPTS}"
        ;;
    exp)
        POSTMAN_ENVIRONMENT_PREFIX="exp"
        NEWMAN_OPTS="${NEWMAN_OPTS}"
        ;;
    abn)
        POSTMAN_ENVIRONMENT_PREFIX="abn"
        NEWMAN_OPTS="${NEWMAN_OPTS}"
        ;;
    prod)
        POSTMAN_ENVIRONMENT_PREFIX="prod"
        NEWMAN_OPTS="${NEWMAN_OPTS}"
        ;;
    *)
        echo "Unknown environment to use: ${ENVIRONMENT_TO_BUILD}"
        exit 1
        ;;
esac

URL_ENV_VAR=""
if [[ ! -z "${ENVIRONMENT_URL}" ]]; then
    URL_ENV_VAR="--env-var \"url=${ENVIRONMENT_URL}\""
fi

# Get the required secrets for the tests
customerportal_password="$(kubectl get secret ds-env-secrets -o jsonpath={.data.CUSTOMERPORTAL_TECHUSER_T_CUSTOMERPORTAL} | base64 -d)"
oneclickinsurance_password="$(kubectl get secret ds-env-secrets -o jsonpath={.data.CUSTOMERPORTAL_TECHUSER_T_ONECLICKINSURANCE} | base64 -d)"
ems_password="$(kubectl get secret ds-env-secrets -o jsonpath={.data.EMS_TECHUSER_T_EMS} | base64 -d)"
digitalfactory_password="$(kubectl get secret ds-env-secrets -o jsonpath={.data.DIGITALFACTORY_TECHUSER_T_DIGITALFACTORY} | base64 -d)"
customerportal_oauth2_clientsecret="$(kubectl get secret amster-env-secrets -o jsonpath={.data.CUSTOMERPORTAL_OAUTH2_MYERGO_CLIENTSECRET} | base64 -d)"
customerportal_agent_password="$(kubectl get secret amster-env-secrets -o jsonpath={.data.CUSTOMERPORTAL_AGENT_WPA_PASSWORD} | base64 -d)"
customerportal_cupo_auth_service_agent_password="$(kubectl get secret amster-env-secrets -o jsonpath={.data.CUSTOMERPORTAL_CUPO_AUTH_SERVICE_AGENT_PASSWORD} | base64 -d)"


# Build the test container
docker build -t postman-tests ${SCRIPT_DIR}

#Run the test container
docker run --rm -t postman-tests \
    run Tests.postman_collection.json "${NEWMAN_OPTS}" \
    --environment "${POSTMAN_ENVIRONMENT_PREFIX}".postman_environment.json \
    --reporters cli,junit \
    --reporter-junit-export "postman-test-results.xml" \
    --env-var "customerportal_oauth2_clientsecret=${customerportal_oauth2_clientsecret}" \
    --env-var "tecuser_password=${customerportal_password}" \
    --env-var "ociuser_password=${oneclickinsurance_password}" \
    --env-var "agent_password=${customerportal_agent_password}" \
    --env-var "cupo_auth_service_agent_password=${customerportal_cupo_auth_service_agent_password}" \
    --env-var "emstecuser_password=${ems_password}" \
    --env-var "dftecuser_password=${digitalfactory_password}" \
    ${URL_ENV_VAR}