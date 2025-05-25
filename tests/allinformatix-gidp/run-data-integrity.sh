#!/usr/bin/env bash

# Default values for parameters
TEST_TYPE=""
NAMESPACE=""
INTERACTIVE=false

# Function to display usage
usage() {
    echo "Usage: $0 [--interactive] [--test-type <type> --namespace <namespace>]"
    echo "  --interactive            Run script in interactive mode"
    echo "  --test-type <type>       Specify the test type (init, test, cleanup)"
    echo "  --namespace <namespace>  Specify the Kubernetes namespace"
    exit 1
}

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --interactive) INTERACTIVE=true ;;
        --test-type)
            if [[ -n $2 && $2 != --* ]]; then
                TEST_TYPE=$2
                shift
            else
                echo "Error: --test-type requires a non-empty argument."
                usage
            fi
            ;;
        --namespace)
            if [[ -n $2 && $2 != --* ]]; then
                NAMESPACE=$2
                shift
            else
                echo "Error: --namespace requires a non-empty argument."
                usage
            fi
            ;;
        *) echo "Unknown parameter passed: $1"; usage ;;
    esac
    shift
done

# Display usage if neither interactive nor both test-type and namespace are provided
if ! $INTERACTIVE && { [[ -z $TEST_TYPE ]] || [[ -z $NAMESPACE ]]; }; then
    usage
fi

# Ensure valid test type
if [[ -n $TEST_TYPE && ! "$TEST_TYPE" =~ ^(init|test|cleanup)$ ]]; then
    echo "Error: --test-type must be one of 'init', 'test', or 'cleanup'."
    usage
fi

# test k8s connection
kubectl cluster-info
if [[ $? -ne 0 ]]; then
    echo "k8s connection not established. Stopping script..."
    exit 1
fi

echo ""
if $INTERACTIVE; then
  echo "PLEASE MAKE SURE YOU'RE USING THE CORRECT NAMESPACE"
  ns=$(kubectl config view --minify --output 'jsonpath={..namespace}')
  read -p "Current namespace is '$ns'. Do you want to continue? (y/n) " answer
  case ${answer:0:1} in
      y|Y)
          echo "Continuing test..."
          ;;
      n|N)
          echo "Stopping test..."
          exit 0
          ;;
      *)
          echo "Unrecognized answer"
          exit 1
          ;;
  esac
else
  kubectl config set-context --current --namespace="$NAMESPACE"
fi

echo "Running script on namespace $(kubectl config view --minify --output 'jsonpath={..namespace}')"
# set script VARs
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENVIRONMENT_TO_BUILD=${ENVIRONMENT_TO_BUILD:-dev}
# the script will save generated test IDs in the file below
# WARN! the file will also contain secrets, make sure to get rid of it
DATA_INTEGRITY_ENV_FILE="data-integrity.postman_environment.json"
DATA_INTEGRITY_ENV_PATH="$SCRIPT_DIR/$DATA_INTEGRITY_ENV_FILE"
DATA_INTEGRITY_ENV_EXPORT=""
URL_ENV_VAR=""
if [[ ! -z "${ENVIRONMENT_URL}" ]]; then
    URL_ENV_VAR="--env-var \"url=${ENVIRONMENT_URL}\""
fi

case "${ENVIRONMENT_TO_BUILD}" in
    dev)
        POSTMAN_ENVIRONMENT_PREFIX="dev"
        ;;
    exp)
        POSTMAN_ENVIRONMENT_PREFIX="exp"
        ;;
    snb)
        POSTMAN_ENVIRONMENT_PREFIX="snb"
        ;;
    abn)
        POSTMAN_ENVIRONMENT_PREFIX="abn"
        ;;
    prod)
        POSTMAN_ENVIRONMENT_PREFIX="prod"
        ;;
    *)
        echo "Unknown environment to use: ${ENVIRONMENT_TO_BUILD}"
        exit 1
        ;;
esac

echo ""
if $INTERACTIVE; then
  echo "Which part of the data integrity script would you like to perform?"
  PRE_UPGRADE="INIT & TEST"
  POST_UPGRADE="TEST & CLEANUP"
  TEST_ONLY="JUST TEST"
  options=("$PRE_UPGRADE" "$TEST_ONLY" "$POST_UPGRADE")
  select opt in "${options[@]}"
  do
      case $opt in
          $PRE_UPGRADE)
              TEST_TYPE="init"
              break
              ;;

          $POST_UPGRADE)
              TEST_TYPE="cleanup"
              break
              ;;

          $TEST_ONLY)
              TEST_TYPE="test"
              break
              ;;

          *)
              echo "Invalid option selected"
              exit 1
              ;;
      esac
  done
fi

case $TEST_TYPE in
    init)
        FOLDERS="--folder INIT --folder TEST"
        DATA_INTEGRITY_ENV_EXPORT="--export-environment ${DATA_INTEGRITY_ENV_FILE}"
        TEST_ENV_FILE="--environment ${POSTMAN_ENVIRONMENT_PREFIX}.postman_environment.json"
        ;;
    test)
        if [ ! -f "$DATA_INTEGRITY_ENV_PATH" ]; then
            echo "Test data file not found in '$DATA_INTEGRITY_ENV_PATH'. Exiting..."
            exit 1
        fi
        FOLDERS="--folder TEST"
        TEST_ENV_FILE="--environment ${DATA_INTEGRITY_ENV_FILE}"
        ;;
    cleanup)
        if [ ! -f "$DATA_INTEGRITY_ENV_PATH" ]; then
            echo "Test data file not found in '$DATA_INTEGRITY_ENV_PATH'. Exiting..."
            exit 1
        fi
        FOLDERS="--folder TEST --folder CLEANUP"
        TEST_ENV_FILE="--environment ${DATA_INTEGRITY_ENV_FILE}"
        ;;
esac

# Get the required secrets for the tests
customerportal_password="$(kubectl get secret ds-env-secrets -o jsonpath={.data.CUSTOMERPORTAL_TECHUSER_T_CUSTOMERPORTAL} | base64 -d)"

#Run the test container
docker run --rm --volume="$SCRIPT_DIR:/etc/newman" -t postman/newman:alpine \
    run CIAM-data-integrity.postman_collection.json \
    --reporters cli,junit \
    --reporter-junit-export "postman-test-results.xml" \
    --env-var "tecuser_password=${customerportal_password}" \
    ${TEST_ENV_FILE} \
    ${DATA_INTEGRITY_ENV_EXPORT} \
    ${FOLDERS} \
    ${URL_ENV_VAR}