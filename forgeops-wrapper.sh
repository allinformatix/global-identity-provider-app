#!/bin/bash

set -euo pipefail

### === Default-Konfiguration === ###
CONFIG_PROFILE="global-identity-provider"
DOCKER_REGISTRY="docker.io/allinformatix"
IG_AGENT_SECRET=""
REALMS_ROOT_OAUTH2CLIENTS_ALLINFORMATIX_GLOBALIDP=""
SKIP_BINARIES=false
SKIP_BUILD=false
BUILD_CONTEXT="./docker"
DO_DEPLOY=false
ONLY_COMPONENT=""
ONLY_IDM=false
STAGE_FILTER=""
BUILD_TAG=""
RELEASE_TAG=""
GEN_MANIFEST=false
INSTALL_ALL=false
DELETE_ALL=false
FORCE=false
BUILD_ALL=false
STAGES_FILE="scripts/available-stages.yaml"
TMP_DIR="./tmp_binaries"
VERSION_MAIN=7.5
VERSION_AM=7.5.1
VERSION_AMSTER=7.5.1
VERSION_DS=7.5.1
VERSION_IDM=7.5.0
VERSION_IG=2025.3.0
VERSION_UI=7.5.1.0610
PROJECT_ROOT=$(pwd)
ARCHS="linux/amd64,linux/arm64"
RECREATE_NAMESPACE=false
IMAGE_INITIALIZED=""
REDEPLOY_ALL=false
DEPLOY_SECRETS=false
INGRESS_ONLY=false
DELETE_ONLY_COMPONENT=""
REDEPLOY_COMPONENT=""

### === Hilfe anzeigen === ###
show_help() {
  cat << EOF

💡 ForgeOps Build & Deploy Script

Verwendung:
  $0 [--component=<name>] [--stage=<name>] [--deploy] [--skip-build] [--skip-binaries] \
     [--idm-only] [--gen-manifest] [--install-all] [--build-all] \
     [--config-profile=<profil>] [--tag=<build-tag>] [--release-tag=<tag>] [--help]

Parameter:
  --component=<name>       ➔ Nur eine bestimmte Komponente bauen (z. B. idm, ds, am)
  --ingress-only           ➔ Shortcut: Nur Ingress bereitstellen
  --deploy                 ➔ Nach dem Bauen automatisch Deploy durchführen
  --skip-binaries          ➔ Keine Binaries aus S3 laden
  --gen-manifest           ➔ Manifest für die angegebene Stage generieren
  --deploy-secrets         ➔ Secrets für die angegebene Stage generieren
  --install-all            ➔ Installiere alle Komponenten für die angegebene Stage (nur mit --stage & ohne --component)
  --build-all              ➔ Baue alle Komponenten (nur sinnvoll mit --stage)
  --stage=<name>           ➔ Stage wählen (z. B. dev, stg, prd)
  --config-profile=<name>  ➔ Config-Profil (Standard: global-identity-provider)
  --tag=<tag>              ➔ Build-Tag für Docker (Default: Stage-Name)
  --release-tag=<tag>      ➔ Git-Tag setzen und pushen
  --help                   ➔ Zeigt diese Hilfe an

EOF
}

### === Argumente parsen === ###
for arg in "$@"; do
  case $arg in
    --recreate-namespace) RECREATE_NAMESPACE=true ;;
    --image-initialized=*) IMAGE_INITIALIZED="${arg#*=}" ;;
    --delete-all) DELETE_ALL=true ;;
    --force) FORCE=true ;;
    --delete-component=*) DELETE_ONLY_COMPONENT="${arg#*=}" ;;
    --ingress-only) INGRESS_ONLY=true ;;
    --component=*) ONLY_COMPONENT="${arg#*=}" ;;
    --deploy) DO_DEPLOY=true ;;
    --skip-build) SKIP_BUILD=true ;;
    --skip-binaries) SKIP_BINARIES=true ;;
    --gen-manifest) GEN_MANIFEST=true ;;
    --deploy-secrets) DEPLOY_SECRETS=true ;;
    --install-all) INSTALL_ALL=true ;;
    --redeploy-component=*) REDEPLOY_COMPONENT="${arg#*=}" ;;
    --redeploy-all) REDEPLOY_ALL=true ;;
    --build-all) BUILD_ALL=true ;;
    --config-profile=*) CONFIG_PROFILE="${arg#*=}" ;;
    --tag=*) BUILD_TAG="${arg#*=}" ;;
    --release-tag=*) RELEASE_TAG="${arg#*=}" ;;
    --help) show_help; exit 0 ;;
    *) echo "⚠️ Unbekannter Parameter: $arg"; show_help; exit 1 ;;
  esac
done

# Nur fragen, wenn --force nicht gesetzt ist
if [ "$FORCE" = false ]; then
  echo "⚠️  Bist du sicher, dass du die STAGE=$STAGE benutzen möchtest? (j/N)"
  read -r answer
  if [[ ! "$answer" =~ ^[Jj]$ ]]; then
    echo "❌ Abgebrochen."
    exit 1
  fi
else
  echo "✅ --force erkannt, Bestätigung übersprungen."
fi

STAGE_FILTER=$STAGE

ENV_FILE=".env.${STAGE_FILTER}"

if [ ! -f "$ENV_FILE" ]; then
  echo "❌ $ENV_FILE file not found!"
  exit 1
fi

echo "loading env file $ENV_FILE"

set -a
source "$ENV_FILE"
set +a

if [[ "$BUILD_ALL" == true ]]; then
  if [[ -z "$STAGE_FILTER" || -z "$BUILD_TAG" ]]; then
    echo "❌ Fehler: '--build-all' erfordert zwingend die Parameter '--stage' und '--tag'."
    echo "👉 Beispiel: ./build.sh --build-all --stage=dev --tag=v1.2.3"
    exit 1
  fi
fi

### === Logging & Cleanup Handling === ###
LOG_FILE="build.log"
exec > >(tee -i "$LOG_FILE")
exec 2>&1
cleanup() {
  echo "🩜 Cleaning up..."
  # cd $PROJECT_ROOT
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

if [[ "$RECREATE_NAMESPACE" == true ]]; then
    if [[ -z "$STAGE_FILTER" ]]; then
        echo "❌ --recreate-namespace erfordert --stage"
        exit 1
    fi
    echo "⚠️  ACHTUNG: Du bist dabei, den Namespace gidp-${STAGE_FILTER} zu löschen! Alle Daten werden gelöscht!!!"
    read -p "Bist du sicher? (yes/[no]): " CONFIRM
    if [[ "$CONFIRM" != "yes" ]]; then
        echo "❌ Vorgang abgebrochen."
        exit 1
    fi
    
    echo "🧨 Lösche zunächst Komponenten in Namespace gidp-${STAGE_FILTER} ..."
    ./bin/forgeops delete --namespace gidp-${STAGE_FILTER} --yes

    echo "🧨 Lösche den Namespace gidp-${STAGE_FILTER} ..."
    kubectl delete namespace gidp-${STAGE_FILTER} --ignore-not-found

    echo "🧨 Erstelle den Namespace gidp-${STAGE_FILTER} ..."
    kubectl create namespace gidp-${STAGE_FILTER}

    echo "Secret für cloudflare wird erstellt, im Namespace gidp-${STAGE_FILTER} ..."
    cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: cloudflare-api-token-secret
  namespace: gidp-${STAGE_FILTER}
type: Opaque
stringData:
  api-token: "$CLOUDFLARE_API_TOKEN"
EOF
    kubectl create secret docker-registry regcred \
        --docker-username="${DOCKER_USERNAME}" \
        --docker-password="${DOCKER_PASSWORD}" \
        --docker-email="${DOCKER_EMAIL}" \
        --namespace gidp-${STAGE_FILTER}
    kubectl patch serviceaccount default \
        --namespace gidp-${STAGE_FILTER} \
        -p '{"imagePullSecrets":[{"name":"regcred"}]}'

    kubectl create secret generic hetzner-s3-credentials \
        --from-literal=AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
        --from-literal=AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
        --namespace gidp-${STAGE_FILTER}

    exit 0
fi

if [[ "$DELETE_ALL" == true ]]; then
    if [[ -z "$STAGE_FILTER" ]]; then
        echo "❌ --delete-all erfordert --stage"
        exit 1
    fi
    if [[ "$FORCE" == false ]]; then
        echo "⚠️  ACHTUNG: Du bist dabei, alle Komponenten in Namespace gidp-${STAGE} zu löschen!"
        read -p "Bist du sicher? (yes/[no]): " CONFIRM
        if [[ "$CONFIRM" != "yes" ]]; then
            echo "❌ Vorgang abgebrochen."
            exit 1
        fi
    fi
    echo "🧨 Lösche Komponenten in Namespace gidp-${STAGE} ..."
    ./bin/forgeops delete --namespace gidp-${STAGE} --yes
    exit 0
fi

if [[ -n "$DELETE_ONLY_COMPONENT" ]]; then
    if [[ -z "$STAGE_FILTER" ]]; then
        echo "❌ --delete-component erfordert --stage"
        exit 1
    fi
    if [[ "$FORCE" == false ]]; then
        echo "⚠️  ACHTUNG: Du bist dabei, die Komponente $DELETE_ONLY_COMPONENT im Namespace gidp-${STAGE_FILTER} zu löschen!"
        read -p "Bist du sicher? (yes/[no]): " CONFIRM
        if [[ "$CONFIRM" != "yes" ]]; then
            echo "❌ Vorgang abgebrochen."
            exit 1
        fi
    fi
    echo "🧨 Lösche Komponente in Namespace gidp-${STAGE_FILTER} ..."
    ./bin/forgeops delete "$DELETE_ONLY_COMPONENT" \
      --namespace "gidp-${STAGE_FILTER}" \
      --yes
    exit 0
fi

### === Install-All Validierung und Steuerung === ###
if [[ "$INSTALL_ALL" == true ]]; then
  if [[ -z "$STAGE_FILTER" ]]; then
    echo "❌ --install-all erfordert --stage"
    exit 1
  fi
  if [[ -n "$ONLY_COMPONENT" || "$ONLY_IDM" == true ]]; then
    echo "❌ --install-all darf nicht mit --component oder --idm-only kombiniert werden"
    exit 1
  fi
  if [[ "$BUILD_ALL" == true ]]; then
    if [[ -z "$STAGE_FILTER" || -z "$BUILD_TAG" ]]; then
        echo "❌ Fehler: '--build-all' erfordert zwingend die Parameter '--stage' und '--tag'."
        echo "👉 Beispiel: ./build.sh --build-all --stage=dev --tag=v1.2.3"
        exit 1
    fi

    ONLY_COMPONENT=""
    ONLY_IDM=false
    DO_DEPLOY=true
  else
    echo "🚀 Installiere alle Komponenten in Namespace gidp-${STAGE_FILTER}"
    ./bin/forgeops install \
      --deploy-env "$STAGE_FILTER" \
      --ingress-class nginx \
      --custom "kustomize/overlay/${CONFIG_PROFILE}-${STAGE_FILTER}" \
      --config-profile "$CONFIG_PROFILE" \
      --namespace "gidp-${STAGE_FILTER}"
    echo "✅ Vollständige Installation abgeschlossen."
    exit 0
  fi
fi

if [[ "$REDEPLOY_ALL" == true ]]; then
    if [[ -z "$STAGE_FILTER" ]]; then
        echo "❌ --redeploy-all erfordert --stage"
        exit 1
    fi
    if [[ -n "$ONLY_COMPONENT" ]]; then
        echo "❌ --redeploy-all darf nicht mit --component kombiniert werden"
        exit 1
    fi
    
    echo "🧨 Lösche Komponenten in Namespace gidp-${STAGE_FILTER} ..."
    ./bin/forgeops delete --namespace gidp-${STAGE_FILTER} --yes

    echo "🚀 Installiere alle Komponenten in Namespace gidp-${STAGE_FILTER}"
    ./bin/forgeops install \
        --deploy-env "$STAGE_FILTER" \
        --ingress-class nginx \
        --custom "kustomize/overlay/${CONFIG_PROFILE}-${STAGE_FILTER}" \
        --config-profile "$CONFIG_PROFILE" \
        --namespace "gidp-${STAGE_FILTER}"
    echo "✅ Vollständige Installation abgeschlossen."
    exit 0
fi

if [[ -n "$REDEPLOY_COMPONENT" ]]; then
    if [[ -z "$STAGE_FILTER" ]]; then
        echo "❌ --redeploy-component erfordert --stage"
        exit 1
    fi

    VALID_COMPONENTS=("amster" "am" "idm" "ai-exec-layer" "ds" "ds-cts" "ds-idrepo" "ig" "postgres")
    # Validierung: Ist REDEPLOY_COMPONENT in der COMPONENTS-Liste?
    if [[ ! " ${VALID_COMPONENTS[*]} " =~ " ${REDEPLOY_COMPONENT} " ]]; then
        echo "❌ Ungültige Komponente: $REDEPLOY_COMPONENT"
        echo "➡️  Gültige Komponenten sind: ${VALID_COMPONENTS[*]}"
        exit 1
    fi

    if [[ "$FORCE" == false ]]; then
        echo "⚠️  ACHTUNG: Du bist dabei, die Komponente $REDEPLOY_COMPONENT im Namespace gidp-${STAGE_FILTER} zu löschen und wieder bereitzustellen!"
        read -p "Bist du sicher? (yes/[no]): " CONFIRM
        if [[ "$CONFIRM" != "yes" ]]; then
            echo "❌ Vorgang abgebrochen."
            exit 1
        fi
    fi

    echo "🧨 Lösche die Komponente: $REDEPLOY_COMPONENT im Namespace gidp-${STAGE_FILTER} ..."
    ./bin/forgeops delete "$REDEPLOY_COMPONENT" --namespace "gidp-${STAGE_FILTER}" --yes || true

    echo "🚀 Installiere die Komponente: $REDEPLOY_COMPONENT im Namespace gidp-${STAGE_FILTER} ..."
    ./bin/forgeops install "$REDEPLOY_COMPONENT" \
        --deploy-env "$STAGE_FILTER" \
        --config-profile "$CONFIG_PROFILE" \
        --namespace "gidp-${STAGE_FILTER}"

    echo "✅ Neu-Deployment von $REDEPLOY_COMPONENT abgeschlossen."
    exit 0
fi

### === Manifest-Generierung === ###
if [[ "$GEN_MANIFEST" == true ]]; then
  if [[ -z "$STAGE_FILTER" ]]; then
    echo "❌ --stage muss angegeben werden bei --gen-manifest"
    exit 1
  fi
  echo "📝 Generiere Manifest für Stage: $STAGE_FILTER"
  mkdir -p kustomize/deploy-$STAGE_FILTER
  cp -R kustomize/deploy/image-defaulter kustomize/deploy-$STAGE_FILTER/
  ./bin/forgeops generate all \
    --deploy-env "$STAGE_FILTER" \
    --ingress-class nginx \
    --config-profile "$CONFIG_PROFILE" \
    --mini \
    --debug
  echo "✅ Manifest-Erstellung abgeschlossen."
  exit 0
fi

### === Bereitstellung-Secrets === ###
if [[ "$DEPLOY_SECRETS" == true ]]; then
  if [[ -z "$STAGE_FILTER" ]]; then
    echo "❌ --stage muss angegeben werden bei --deploy-secrets"
    exit 1
  fi

  echo "📝 Stelle Secrets für Stage: $STAGE_FILTER bereit"
  NAMESPACE="gidp-${STAGE_FILTER}"

  function apply_secret() {
    echo "🔐 Erstelle Secret: $1"
    kubectl create secret generic "$1" "${@:2}" -n "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
  }

  # Cloudflare
  cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: cloudflare-api-token-secret
  namespace: $NAMESPACE
type: Opaque
stringData:
  api-token: "$CLOUDFLARE_API_TOKEN"
EOF

  # Docker Registry
  apply_secret regcred \
    --type=kubernetes.io/dockerconfigjson \
    --from-literal=.dockerconfigjson="$(jq -n --arg user "$DOCKER_USERNAME" --arg pass "$DOCKER_PASSWORD" --arg email "$DOCKER_EMAIL" \
      '{auths: {"https://index.docker.io/v1/": {"username": $user, "password": $pass, "email": $email, "auth": ($user + ":" + $pass | @base64)}}}')"

  kubectl patch serviceaccount default -n "$NAMESPACE" \
    -p '{"imagePullSecrets":[{"name":"regcred"}]}'

  # Hetzner S3
  apply_secret hetzner-s3-credentials \
    --from-literal=AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" \
    --from-literal=AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}"

  # OpenAI
  apply_secret openai-api-key --from-literal=OPENAI_API_KEY="$OPENAI_API_KEY"

  # RunPod
  apply_secret runpod-api-key --from-literal=RUNPOD_API_KEY="$RUNPOD_API_KEY"

  # IG_AGENT_SECRET
  if [[ -z "$IG_AGENT_SECRET" ]]; then
    echo "⚠️ IG_AGENT_SECRET nicht gesetzt – generiere..."
    RAW_SECRET=$(LC_ALL=C tr -dc 'a-zA-Z0-9' </dev/urandom | head -c 64 || true)
    IG_AGENT_SECRET=$(echo -n "$RAW_SECRET" | base64)
    echo "🧬 Generiert: $IG_AGENT_SECRET"
  fi

  # Realm OAuth2 Secret
  if [[ -z "$REALMS_ROOT_OAUTH2CLIENTS_ALLINFORMATIX_GLOBALIDP" ]]; then
    echo "⚠️ REALMS_ROOT_OAUTH2CLIENTS_ALLINFORMATIX_GLOBALIDP nicht gesetzt – generiere..."
    RAW_SECRET=$(LC_ALL=C tr -dc 'a-zA-Z0-9' </dev/urandom | head -c 64 || true)
    REALMS_ROOT_OAUTH2CLIENTS_ALLINFORMATIX_GLOBALIDP=$(echo -n "$RAW_SECRET" | base64)
    echo "🧬 Generiert: $REALMS_ROOT_OAUTH2CLIENTS_ALLINFORMATIX_GLOBALIDP"
  fi

  # Kombiniertes Secret für IG
  apply_secret ig-env-secrets \
    --from-literal=IG_AGENT_SECRET="$IG_AGENT_SECRET" \
    --from-literal=REALMS_ROOT_OAUTH2CLIENTS_ALLINFORMATIX_GLOBALIDP="$REALMS_ROOT_OAUTH2CLIENTS_ALLINFORMATIX_GLOBALIDP"

  echo "🚀 Secrets Agent ausführen..."
  ./bin/forgeops install secrets \
    --namespace "$NAMESPACE" \
    --deploy-env "$STAGE_FILTER" \
    --custom "kustomize/overlay/global-identity-provider-$STAGE_FILTER"

  echo "✅ Secret-Bereitstellung abgeschlossen."
  exit 0
fi

### === Update-Ingress === ###
if [[ "$INGRESS_ONLY" == true ]]; then
  if [[ -z "$STAGE_FILTER" ]]; then
    echo "❌ --stage muss angegeben werden bei --deploy-secrets"
    exit 1
  fi
  echo "📝 Stelle Ingress für Stage: $STAGE_FILTER bereit"
  cd $PROJECT_ROOT
  kubectl apply \
    -k kustomize/deploy-$STAGE_FILTER/base \
    -n gidp-$STAGE_FILTER
  echo "✅ Ingress-Bereitstellung abgeschlossen."
  exit 0
fi

if [[ -z "$IMAGE_INITIALIZED" ]]; then
  echo "❌ Parameter '--image-initialized' ist erforderlich!"
  echo "   Bitte gib an, ob die ForgeRock Images bereits initialisiert wurden:"
  echo "     --image-initialized=true   (Images bereits vorhanden)"
  echo "     --image-initialized=false  (Images müssen gebaut werden)"
  exit 1
elif [[ "$IMAGE_INITIALIZED" != "true" && "$IMAGE_INITIALIZED" != "false" ]]; then
  echo "❌ Ungültiger Wert für --image-initialized: \"$IMAGE_INITIALIZED\""
  echo "   Erlaubte Werte sind nur: true oder false"
  exit 1
fi

### === Komponenten definieren === ###
COMPONENTS=("java-17" "amster" "am" "am-upgrader" "idm" "ai-exec-layer" "ds" "ig" "ldif-importer" "postgres")
[[ "$ONLY_IDM" == true ]] && COMPONENTS=("idm")
[[ -n "$ONLY_COMPONENT" ]] && COMPONENTS=("$ONLY_COMPONENT")
[[ "$BUILD_ALL" == true && -z "$ONLY_COMPONENT" && "$ONLY_IDM" == false ]] && COMPONENTS=("java-17" "amster" "am" "am-upgrader" "idm" "ds" "ig" "ldif-importer" "postgres")

### === Vorbereitung Buildx === ###
echo "🔧 Initialisiere Docker Buildx..."
docker buildx inspect forgeops-builder >/dev/null 2>&1 || docker buildx create --name forgeops-builder
docker buildx use forgeops-builder
docker buildx inspect --bootstrap

### === Binary-Download Funktion === ###
s3_copy() {
  aws s3 cp "$1" "$2" --endpoint-url "$S3_ENDPOINT"
}

prepare_binaries() {
  cd "$PROJECT_ROOT"
  mkdir -p "$TMP_DIR"
  echo "📦 Lade Binaries für $1 ..."

  case "$1" in
    java-17)
      echo "🔁 Klone forgeops-extras neu..."
      rm -rf "$TMP_DIR/forgeops-extras"
      git clone https://github.com/ForgeRock/forgeops-extras.git "$TMP_DIR/forgeops-extras"
      ;;
    idm)
      local zip="$TMP_DIR/IDM.zip"
      [[ -f "$zip" ]] || s3_copy "s3://${S3_BUCKET}/ForgeRock/IDM/${VERSION_MAIN}/IDM-${VERSION_IDM}.zip" "$zip"
      unzip -q "$zip" -d "$TMP_DIR"
      ;;
    ai-exec-layer)
      local zip="$TMP_DIR/IDM.zip"
      [[ -f "$zip" ]] || s3_copy "s3://${S3_BUCKET}/ForgeRock/IDM/${VERSION_MAIN}/IDM-${VERSION_IDM}.zip" "$zip"
      unzip -q "$zip" -d "$TMP_DIR"
      ;;
    ds)
      local zip="$TMP_DIR/DS.zip"
      [[ -f "$zip" ]] || s3_copy "s3://${S3_BUCKET}/ForgeRock/DS/${VERSION_MAIN}/DS-${VERSION_DS}.zip" "$zip"
      unzip -q "$zip" -d "$TMP_DIR"
      ;;
    ig)
      local zip="$TMP_DIR/IG.zip"
      [[ -f "$zip" ]] || s3_copy "s3://${S3_BUCKET}/ForgeRock/IG/PingGateway-${VERSION_IG}.zip" "$zip"
      unzip -q "$zip" -d "$TMP_DIR"
      ;;
    am)
      local zip="$TMP_DIR/AM.zip"
      [[ -f "$zip" ]] || s3_copy "s3://${S3_BUCKET}/ForgeRock/AM/${VERSION_MAIN}/AM-${VERSION_AM}.zip" "$zip"
      unzip -q "$zip" -d "$TMP_DIR"
      ;;
    amster)
      local zip="$TMP_DIR/Amster.zip"
      [[ -f "$zip" ]] || s3_copy "s3://${S3_BUCKET}/ForgeRock/AM/${VERSION_MAIN}/Amster-${VERSION_AM}.zip" "$zip"
      unzip -q "$zip" -d "$TMP_DIR"
      ;;
    am-upgrader)
      local zip="$TMP_DIR/AM.zip"
      [[ -f "$zip" ]] || s3_copy "s3://${S3_BUCKET}/ForgeRock/AM/${VERSION_MAIN}/AM-${VERSION_AM}.zip" "$zip"
      rm -rf "$TMP_DIR/openam"
      unzip -q "$zip" -d "$TMP_DIR"
      unzip -q "$TMP_DIR/openam/Config-Upgrader-${VERSION_AM}.zip" -d "$TMP_DIR/openam"
      ;;
    *) echo "⏩ Keine Binaries notwendig für '$1'" ;;
  esac
}


### === STAGES-Verarbeitung === ###
STAGES=$(yq -r '.stages[]' "$STAGES_FILE")

for STAGE in $STAGES; do
  [[ -n "$STAGE_FILTER" && "$STAGE" != "$STAGE_FILTER" ]] && continue

  echo "🔁 Verarbeite Stage: $STAGE"

  PATCH_FILE="kustomize/overlay/${CONFIG_PROFILE}-${STAGE}/platform-config-patch.yaml"
  TEMPLATE_FILE="docker/idm/config-profiles/${CONFIG_PROFILE}/conf/ui-configuration.json.template"
  OUTPUT_FILE="docker/idm/config-profiles/${CONFIG_PROFILE}/conf/ui-configuration.json"

  if [[ -f "$PATCH_FILE" ]]; then
    export DOMAIN=$(yq '.data.DOMAIN' "$PATCH_FILE" | tr -d '"')
    export FQDN=$(yq '.data.FQDN' "$PATCH_FILE" | tr -d '"')
  else
    echo "⚠️ Patch-Datei fehlt: $PATCH_FILE"
    continue
  fi

  COMPONENTS=("java-17" "amster" "am" "am-upgrader" "idm" "ai-exec-layer" "ds" "ig" "ldif-importer" "postgres")
  [[ "$ONLY_IDM" == true ]] && COMPONENTS=("idm")
  [[ -n "$ONLY_COMPONENT" ]] && COMPONENTS=("$ONLY_COMPONENT")
  [[ "$BUILD_ALL" == true && -z "$ONLY_COMPONENT" && "$ONLY_IDM" == false ]] && COMPONENTS=("java-17" "amster" "am" "am-upgrader" "idm" "ds" "ig" "ldif-importer" "postgres")

  LDIF_USED=false

  if [[ "$SKIP_BUILD" == false ]]; then
    for component in "${COMPONENTS[@]}"; do
        if [[ "$SKIP_BINARIES" == false && "$IMAGE_INITIALIZED" == false ]]; then
            prepare_binaries "$component"
        fi

        if [[ "$component" == "all" || "$component" == "java-17" ]]; then
            if [[ "$IMAGE_INITIALIZED" == false ]]; then
                echo "🔨 Baue Java-17..."
                # prepare_binaries "$component"
                cd "$PROJECT_ROOT"
                cd "$TMP_DIR"
                rm -rf forgeops-extras
                git clone https://github.com/ForgeRock/forgeops-extras.git
                cd forgeops-extras/images/java-17
                docker buildx build . \
                    --platform "$ARCHS" \
                    --tag "$DOCKER_REGISTRY/java-17:latest" \
                    --push
                continue
            fi
        fi

        if [[ "$component" == "all" || "$component" == "amster" ]]; then
            if [[ "$IMAGE_INITIALIZED" == false ]]; then
                echo "🔨 Baue Amster..."
                cd "$PROJECT_ROOT"
                cd "$TMP_DIR/amster/samples/docker"
                chmod +x setup.sh && ./setup.sh
                if [[ "$OSTYPE" == "darwin"* ]]; then
                    find . -name 'Dockerfile' -exec sed -i '' \
                        -e "s|^FROM .*|FROM allinformatix/java-17:latest|" \
                        {} +
                else
                    find . -name 'Dockerfile' -exec sed -i \
                        -e "s|^FROM .*|FROM allinformatix/java-17:latest|" \
                        {} +
                fi

                docker buildx build . \
                    --platform "$ARCHS" \
                    --tag "$DOCKER_REGISTRY/amster:${VERSION_AMSTER}" \
                    --push
            fi
            cd "$PROJECT_ROOT"
            cd docker/amster
            if [[ "$OSTYPE" == "darwin"* ]]; then
                find . -name 'Dockerfile' -exec sed -i '' \
                    -e "s|^FROM .*|FROM allinformatix/amster:${VERSION_AMSTER}|" \
                    {} +
            else
                find . -name 'Dockerfile' -exec sed -i \
                    -e "s|^FROM .*|FROM allinformatix/amster:${VERSION_AMSTER}|" \
                    {} +
            fi

            docker buildx build . \
                --platform "$ARCHS" \
                --tag "$DOCKER_REGISTRY/amster:customized" \
                --push
            continue
        fi

        ### === AM wird gebaut === ###
        if [[ "$component" == "all" || "$component" == "am" ]]; then
            if [[ "$IMAGE_INITIALIZED" == false ]]; then
                echo "🔨 Baue AM...empty"
                cd "$PROJECT_ROOT"
                cd "$TMP_DIR/openam/samples/docker"
                chmod +x setup.sh && ./setup.sh

                cd images/am-empty
                docker buildx build . \
                    --platform "$ARCHS" \
                    --tag "$DOCKER_REGISTRY/am-empty:${VERSION_AM}" \
                    --push

                echo "🔨 Baue AM...base"
                cd "$PROJECT_ROOT"
                cd "$TMP_DIR/openam/samples/docker"
                cd images/am-base
                if [[ "$OSTYPE" == "darwin"* ]]; then
                    find . -name 'Dockerfile' -exec sed -i '' \
                    -e "s|^ARG docker_tag=.*$|ARG docker_tag=${VERSION_AM}|" \
                    -e "s|^FROM .*/am-empty:.*$|FROM allinformatix/am-empty:${VERSION_AM}|" \
                    {} +
                else
                    find . -name 'Dockerfile' -exec sed -i \
                    -e "s|^ARG docker_tag=.*$|ARG docker_tag=${VERSION_AM}|" \
                    -e "s|^FROM .*/am-empty:.*$|FROM allinformatix/am-empty:${VERSION_AM}|" \
                    {} +
                fi

                docker buildx build . \
                    --platform "$ARCHS" \
                    --build-arg docker_tag=${VERSION_AM} \
                    --tag "$DOCKER_REGISTRY/am-base:${VERSION_AM}" \
                    --push

                echo "🔨 Baue AM...cdk"
                cd ../am-cdk
                if [[ "$OSTYPE" == "darwin"* ]]; then
                    find . -name 'Dockerfile' -exec sed -i '' \
                        -e "s|^ARG docker_tag=.*|ARG docker_tag=${VERSION_AM}|" \
                        -e "s|^FROM .*|FROM allinformatix/am-base:${VERSION_AM}|" \
                        {} +
                else
                    find . -name 'Dockerfile' -exec sed -i \
                        -e "s|^ARG docker_tag=.*|ARG docker_tag=${VERSION_AM}|" \
                        -e "s|^FROM .*|FROM allinformatix/am-base:${VERSION_AM}|" \
                        {} +
                fi

                docker buildx build . \
                    --platform "$ARCHS" \
                    --build-arg docker_tag=${VERSION_AM} \
                    --tag "$DOCKER_REGISTRY/am:${VERSION_AM}" \
                    --push                
                
                echo "🔨 Baue AM Config Upgrader..."
                cd "$PROJECT_ROOT"
                cd "$TMP_DIR/openam"
                unzip -q "Config-Upgrader-${VERSION_AM}.zip"
                cd amupgrade/samples/docker
                chmod +x setup.sh && ./setup.sh
                if [[ "$OSTYPE" == "darwin"* ]]; then
                    find . -name 'Dockerfile' -exec sed -i '' \
                        -e "s|^FROM .*|FROM allinformatix/java-17:latest|" \
                        {} +
                else
                    find . -name 'Dockerfile' -exec sed -i \
                        -e "s|^FROM .*|FROM allinformatix/java-17:latest|" \
                        {} +
                fi

                docker buildx build . \
                    --platform "$ARCHS" \
                    --tag "$DOCKER_REGISTRY/am-config-upgrader:${BUILD_TAG}" \
                    --push
            fi
            echo "🔨 Baue finales AM image..."
            cd "$PROJECT_ROOT"
            cd "$BUILD_CONTEXT/am"
            if [[ "$OSTYPE" == "darwin"* ]]; then
                find . -name 'Dockerfile' -exec sed -i '' \
                    -e "s|^ARG docker_tag=.*|ARG docker_tag=${VERSION_AM}|" \
                    -e "s|^FROM .*|FROM allinformatix/am:${VERSION_AM}|" \
                    {} +
            else
                find . -name 'Dockerfile' -exec sed -i \
                    -e "s|^ARG docker_tag=.*|ARG docker_tag=${VERSION_AM}|" \
                    -e "s|^FROM .*|FROM allinformatix/am:${VERSION_AM}|" \
                    {} +
            fi

            docker buildx build . \
                --platform "$ARCHS" \
                --tag "$DOCKER_REGISTRY/am:${BUILD_TAG}" \
                --push
            continue
        fi

        if [[ "$component" == "all" || "$component" == "ds" || "$component" == "ds-idrepo" || "$component" == "ds-cts" ]]; then
            if [[ "$IMAGE_INITIALIZED" == false ]]; then
                echo "🔨 Baue ds-empty..."
                cd "$PROJECT_ROOT"
                cd "$TMP_DIR/opendj"
                chmod +x samples/docker/setup.sh && ./samples/docker/setup.sh
                if [[ "$OSTYPE" == "darwin"* ]]; then
                    find . -name 'Dockerfile' -exec sed -i '' \
                        -e "s|^FROM .*|FROM allinformatix/java-17:latest|" \
                        {} +
                else
                    find . -name 'Dockerfile' -exec sed -i \
                        -e "s|^FROM .*|FROM allinformatix/java-17:latest|" \
                        {} +
                fi
                docker buildx build . \
                    --platform "$ARCHS" \
                    --tag "$DOCKER_REGISTRY/ds-empty:$VERSION_DS" \
                    --push
            fi
            echo "🔨 Baue ds..."
            cd "$PROJECT_ROOT"
            cd "$BUILD_CONTEXT/ds"
            if [[ "$OSTYPE" == "darwin"* ]]; then
                find . -name 'Dockerfile' -exec sed -i \
                    -e "s|^FROM .*|FROM allinformatix/ds-empty:$VERSION_DS|" \
                    {} +
            else
                find . -name 'Dockerfile' -exec sed -i '' \
                    -e "s|^FROM .*|FROM allinformatix/ds-empty:$VERSION_DS|" \
                    {} +
            fi

            docker buildx build . \
                --platform "$ARCHS" \
                --tag "$DOCKER_REGISTRY/ds:$BUILD_TAG" \
                --push
            
            continue
        fi

        if [[ "$component" == "ldif-importer" ]]; then
            cd "$PROJECT_ROOT"
            docker buildx build docker/ldif-importer \
            --platform "$ARCHS" \
            --tag "$DOCKER_REGISTRY/ldif-importer:$BUILD_TAG" \
            --push
            LDIF_USED=true
            continue
        fi

        if [[ "$component" == "all" || "$component" == "idm" ]]; then
            if [[ "$IMAGE_INITIALIZED" == false ]]; then
                echo "------ INITIALIZATION -----"
                echo "🔨 Baue IDM..."
                cd "$PROJECT_ROOT"                
                cd "$TMP_DIR/openidm"
                if [[ "$OSTYPE" == "darwin"* ]]; then
                    find bin/ -name 'Custom.Dockerfile' -exec sed -i '' \
                        -e "s|^FROM .*|FROM allinformatix/java-17:latest|" \
                        {} +
                else
                    find bin/ -name 'Custom.Dockerfile' -exec sed -i \
                        -e "s|^FROM .*|FROM allinformatix/java-17:latest|" \
                        {} +
                fi

                docker buildx build . \
                    --platform "$ARCHS" \
                    --file bin/Custom.Dockerfile \
                    --tag "$DOCKER_REGISTRY/idm:7.5.0" \
                    --push
            fi
            cd "$PROJECT_ROOT"
            cd docker/idm            
            docker buildx build . \
                --platform "$ARCHS" \
                --tag "$DOCKER_REGISTRY/idm:$BUILD_TAG" \
                --push
        fi

        if [[ "$component" == "all" || "$component" == "ai-exec-layer" ]]; then
            if [[ "$IMAGE_INITIALIZED" == false ]]; then
                echo "------ INITIALIZATION -----"
                echo "🔨 Baue IDM..."
                cd "$PROJECT_ROOT"                
                cd "$TMP_DIR/openidm"
                if [[ "$OSTYPE" == "darwin"* ]]; then
                    find bin/ -name 'Custom.Dockerfile' -exec sed -i '' \
                        -e "s|^FROM .*|FROM allinformatix/java-17:latest|" \
                        {} +
                else
                    find bin/ -name 'Custom.Dockerfile' -exec sed -i \
                        -e "s|^FROM .*|FROM allinformatix/java-17:latest|" \
                        {} +
                fi

                docker buildx build . \
                    --platform "$ARCHS" \
                    --file bin/Custom.Dockerfile \
                    --tag "$DOCKER_REGISTRY/ai-exec-layer:7.5.0" \
                    --push
            fi
            cd "$PROJECT_ROOT"
            cd docker/ai-exec-layer
            docker buildx build . \
                --platform "$ARCHS" \
                --tag "$DOCKER_REGISTRY/ai-exec-layer:$BUILD_TAG" \
                --push
        fi

        if [[ "$component" == "all" || "$component" == "ig" ]]; then
            if [[ "$IMAGE_INITIALIZED" == false ]]; then
                echo "------ INITIALIZATION -----"
                echo "🔨 Baue IG..."
                cd "$PROJECT_ROOT"
                cd "$TMP_DIR/identity-gateway-$VERSION_IG"
                if [[ "$OSTYPE" == "darwin"* ]]; then
                    find docker/ -name 'Dockerfile' -exec sed -i '' \
                        -e "s|^FROM .*|FROM allinformatix/java-17:latest|" \
                        {} +
                else
                    find docker/ -name 'Dockerfile' -exec sed -i \
                        -e "s|^FROM .*|FROM allinformatix/java-17:latest|" \
                        {} +
                fi
                # PostgreSQL JDBC-Treiber herunterladen und ins IG lib-Verzeichnis legen
                PG_DRIVER_VERSION="42.7.3"
                PG_JAR_NAME="postgresql-${PG_DRIVER_VERSION}.jar"
                PG_JAR_URL="https://jdbc.postgresql.org/download/${PG_JAR_NAME}"

                echo "🌐 Lade PostgreSQL JDBC-Treiber: $PG_JAR_URL"
                curl -fsSL "$PG_JAR_URL" -o "lib/postgresql.jar"
                docker buildx build . \
                    --file docker/Dockerfile \
                    --platform "$ARCHS" \
                    --tag "$DOCKER_REGISTRY/ig:$VERSION_IG" \
                    --push
            fi
            cd "$PROJECT_ROOT"
            cd docker/ig
            if [[ "$OSTYPE" == "darwin"* ]]; then
                find . -name 'Dockerfile' -exec sed -i '' \
                -e "s|^FROM .*|FROM allinformatix/ig:$VERSION_IG|" \
                {} +
            else
                find . -name 'Dockerfile' -exec sed -i \
                -e "s|^FROM .*|FROM allinformatix/ig:$VERSION_IG|" \
                {} +
            fi
            docker buildx build . \
                --platform "$ARCHS" \
                --tag "$DOCKER_REGISTRY/ig:$BUILD_TAG" \
                --push           
        fi

        if [[ "$component" == "all" || "$component" == "postgres" ]]; then
            cd "$PROJECT_ROOT"
            cd docker/postgres            
            docker buildx build . \
                --platform "$ARCHS" \
                --tag "$DOCKER_REGISTRY/postgres:$BUILD_TAG" \
                --push
        fi
    done
  else
    echo "⏭️ Build übersprungen (--skip-build aktiviert)"
  fi

  if [[ -n "$RELEASE_TAG" ]]; then
    echo "🏷️ Setze Release-Tag: $RELEASE_TAG"
    git tag "$RELEASE_TAG"
    git push origin "$RELEASE_TAG"
  fi
  
  if [[ -n "$BUILD_TAG" && -n "$RELEASE_TAG" ]]; then
    IMAGE_DEF_PATH="kustomize/deploy-${STAGE_FILTER}/image-defaulter/kustomization.yaml"
    if [[ -f "$IMAGE_DEF_PATH" ]]; then
        echo "🔁 Ersetze Image-Tags in $IMAGE_DEF_PATH durch \"$BUILD_TAG\"..."
        # Cross-platform sed: macOS vs. GNU
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s/newTag: .*/newTag: ${BUILD_TAG}/g" "$IMAGE_DEF_PATH"
        else
            sed -i "s/newTag: .*/newTag: ${BUILD_TAG}/g" "$IMAGE_DEF_PATH"
        fi
        echo "✅ Image-Tags erfolgreich ersetzt."
    else
        echo "⚠️  Datei $IMAGE_DEF_PATH existiert nicht – Tag-Austausch übersprungen."
    fi
  fi

  if [[ -n "$BUILD_TAG" && -n "$RELEASE_TAG" ]]; then
    echo "DEPLOYMENT des neuen Releases!"    
    echo "🧨 Lösche Komponenten in Namespace gidp-${STAGE_FILTER} ..."
    ./bin/forgeops delete --namespace gidp-${STAGE_FILTER} --yes
    echo "🚀 Installiere alle Komponenten in Namespace gidp-${STAGE_FILTER}"
    ./bin/forgeops install \
        --deploy-env "$STAGE_FILTER" \
        --ingress-class nginx \
        --custom "kustomize/overlay/${CONFIG_PROFILE}-${STAGE_FILTER}" \
        --config-profile "$CONFIG_PROFILE" \
        --namespace "gidp-${STAGE_FILTER}"
    echo "✅ Vollständige Installation abgeschlossen."
    exit 0
  fi

  if [[ "$DO_DEPLOY" == true ]]; then
    if [[ "$INSTALL_ALL" == true && "$BUILD_ALL" == true ]]; then
        echo "🚀 Installiere alle Komponenten in Namespace gidp-${STAGE}"
        ./bin/forgeops install \
        --deploy-env "$STAGE" \
        --ingress-class nginx \
        --custom "kustomize/overlay/${CONFIG_PROFILE}-${STAGE}" \
        --config-profile "$CONFIG_PROFILE" \
        --namespace "gidp-${STAGE}"
        echo "✅ Vollständige Installation abgeschlossen."
        continue
    fi
    echo "🚀 Deployment für $STAGE..."

    for component in "${COMPONENTS[@]}"; do
      [[ "$component" == "ldif-importer" ]] && continue
      cd $PROJECT_ROOT
      ./bin/forgeops delete "$component" --namespace "gidp-${STAGE}" --yes || true
    done

    if [[ "$LDIF_USED" == true ]]; then
      ./bin/forgeops delete ds-idrepo --namespace "gidp-${STAGE}" --yes || true
      ./bin/forgeops install ds-idrepo \
        --deploy-env "$STAGE" \
        --config-profile "$CONFIG_PROFILE" \
        --namespace "gidp-${STAGE}"
    fi

    for component in "${COMPONENTS[@]}"; do
      [[ "$component" == "ldif-importer" ]] && continue
      cd $PROJECT_ROOT
      ./bin/forgeops install "$component" \
        --deploy-env "$STAGE" \
        --config-profile "$CONFIG_PROFILE" \
        --namespace "gidp-${STAGE}"
    done
  fi
done

echo "✅ Alles erledigt."
