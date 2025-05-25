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
    feat)
        POSTMAN_ENVIRONMENT_PREFIX="feature"
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
postmanapiadmin_password="$(kubectl get secret ds-env-secrets -o jsonpath={.data.TECHUSER_T_POSTMANAPIADMIN_PASSWORD} | base64 -d)"
oauth_client_secret="$(kubectl get secret amster-env-secrets -o jsonpath={.data.ID_OAUTH2_IDMIDCLIENT_CLIENTSECRET} | base64 -d)"
customer_agent_password="$(kubectl get secret amster-env-secrets -o jsonpath={.data.CUSTOMER_AGENT_WPA_PASSWORD} | base64 -d)"
customer_oauth2_clientsecret="$(kubectl get secret amster-env-secrets -o jsonpath={.data.CUSTOMER_OAUTH2_MYERGO_CLIENTSECRET} | base64 -d)"

# Build the test container
docker build -t postman-tests-id ${SCRIPT_DIR}

# Run the test container
# NOTE! The --insecure flag is needed for feature environments (wildcard certificate issue)
docker run --rm -t postman-tests-id \
    run Tests.postman_collection.json ${NEWMAN_OPTS} \
    --insecure \
    --environment "${POSTMAN_ENVIRONMENT_PREFIX}.postman_environment.json" \
    --reporters cli,junit \
    --reporter-junit-export "postman-test-results.xml" \
    --env-var "postmanapiadmin_pass=${postmanapiadmin_password}" \
    --env-var "client-secret=${oauth_client_secret}" \
    --env-var "agent_password=${customer_agent_password}" \
    --env-var "customer_oauth2_clientsecret=${customer_oauth2_clientsecret}" \
    ${URL_ENV_VAR}
