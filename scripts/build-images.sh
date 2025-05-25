#!/bin/bash

set -euo pipefail

CONFIG_PROFILE="global-identity-provider"
DOCKER_REGISTRY="docker.io/allinformatix"
BUILD_TAG=""
RELEASE_TAG=""
ONLY_IDM=false
ONLY_COMPONENT=""
DO_DEPLOY=false
SKIP_BUILD=false
STAGE_FILTER=""
STAGES_FILE="scripts/available-stages.yaml"

show_help() {
cat << EOF

\U0001F4A1 ForgeOps Build & Deployment Script

Dieses Skript automatisiert den Bau (und optional Deployment) von ForgeRock Docker-Images für verschiedene Stages.

🔧 Verfügbare Parameter:

  --idm-only                 ➔ Nur die IDM-Komponente bauen.
  --component=<name>         ➔ Nur eine bestimmte Komponente bauen (z. B. ds-idrepo).
  --deploy                   ➔ Nach dem Bauen: automatisches Löschen & Neuinstallieren der Komponenten.
  --skip-build               ➔ Build überspringen, nur Deployment durchführen.
  --stage=<name>             ➔ Nur die angegebene Stage verarbeiten (z. B. dev, stg, prd).
  --config-profile=<name>    ➔ Name des zu verwendenden Config-Profils (Standard: global-identity-provider).
  --tag=<tag>                ➔ Docker-Tag setzen (Standard: latest).
  --help                     ➔ Zeigt diese Hilfe an.

📂 Erwartete Datei:
  scripts/available-stages.yaml ➔ Enthält die Liste aller verfügbaren Stages.

🦪 Beispielaufrufe:

  ./scripts/build-images.sh --idm-only
  ./scripts/build-images.sh --stage=dev --deploy
  ./scripts/build-images.sh --component=ds-idrepo --stage=dev --deploy
  ./scripts/build-images.sh --stage=stg --config-profile=custom-profile --tag=staging
  ./scripts/build-images.sh --component=ig --stage=dev --deploy --skip-build

EOF
}

# Argumente parsen
for arg in "$@"; do
  case $arg in
    --idm-only)
      ONLY_IDM=true
      ;;
    --component=*)
      ONLY_COMPONENT="${arg#*=}"
      ;;
    --deploy)
      DO_DEPLOY=true
      ;;
    --skip-build)
      SKIP_BUILD=true
      ;;
    --stage=*)
      STAGE_FILTER="${arg#*=}"
      ;;
    --config-profile=*)
      CONFIG_PROFILE="${arg#*=}"
      ;;
    --tag=*)
      BUILD_TAG="${arg#*=}"
      ;;
    --release-tag=*)
      RELEASE_TAG="${arg#*=}"
      ;;
    --help)
      show_help
      exit 0
      ;;
    *)
      echo "⚠️  Unbekannter Parameter: $arg"
      show_help
      exit 1
      ;;
  esac
done

VALID_COMPONENTS=("am" "amster" "idm" "ds" "ig" "ds-cts" "ds-idrepo" "ldif-importer")
if [[ -n "$ONLY_COMPONENT" && ! " ${VALID_COMPONENTS[*]} " =~ " ${ONLY_COMPONENT} " ]]; then
  echo "❌ Ungültige Komponente: $ONLY_COMPONENT"
  echo "➞  Gültige Werte: ${VALID_COMPONENTS[*]}"
  exit 1
fi

STAGES=$(yq -r '.stages[]' "$STAGES_FILE")

for STAGE in $STAGES; do
  if [[ -n "$STAGE_FILTER" && "$STAGE" != "$STAGE_FILTER" ]]; then
    continue
  fi

  echo "🔁 Processing stage: $STAGE"

  OVERLAY_PATH="kustomize/overlay/global-identity-provider-${STAGE}"
  PATCH_FILE="${OVERLAY_PATH}/platform-config-patch.yaml"
  TEMPLATE_FILE="docker/idm/config-profiles/${CONFIG_PROFILE}/conf/ui-configuration.json.template"
  OUTPUT_FILE="docker/idm/config-profiles/${CONFIG_PROFILE}/conf/ui-configuration.json"

  if [[ -f "$PATCH_FILE" ]]; then
    export DOMAIN=$(yq '.data.DOMAIN' "$PATCH_FILE" | tr -d '"')
    export FQDN=$(yq '.data.FQDN' "$PATCH_FILE" | tr -d '"')
    echo "🌐 FQDN: $FQDN"
    echo "🌍 DOMAIN: $DOMAIN"
  else
    echo "⚠️  Skipping \"$STAGE\": Patch file not found ($PATCH_FILE)"
    continue
  fi

  COMPONENTS=("am" "amster" "idm" "ds" "ig" "ds-cts" "ds-idrepo" "ldif-importer")
  if [[ "$ONLY_IDM" == true ]]; then
    COMPONENTS=("idm")
  elif [[ -n "$ONLY_COMPONENT" ]]; then
    COMPONENTS=("$ONLY_COMPONENT")
  fi

  LDIF_USED=false

  if [[ "$SKIP_BUILD" == false ]]; then
    for component in "${COMPONENTS[@]}"; do
      if [[ "$component" == "idm" && -f "$TEMPLATE_FILE" ]]; then
        echo "🔧 Substituting variables into ui-configuration.json for stage \"$STAGE\""
        envsubst < "$TEMPLATE_FILE" > "$OUTPUT_FILE"
      fi

      if [[ "$component" == "ldif-importer" ]]; then
        echo "📆 Building custom component ldif-importer"
        DOCKER_REGISTRY="docker.io/allinformatix"
        ARCHS="linux/amd64,linux/arm64"
        docker buildx build docker/ldif-importer --platform $ARCHS --tag $DOCKER_REGISTRY/global-identity-provider-ldif-importer:7.5.1 --push
        # docker push $DOCKER_REGISTRY/global-identity-provider-ldif-importer:7.5.1
        LDIF_USED=true
        continue
      fi

      echo "📦 Building $component for $STAGE..."
      ./bin/forgeops build "$component" \
        --deploy-env "$STAGE" \
        --push-to "$DOCKER_REGISTRY" \
        --tag "$STAGE" \
        --config-profile "$CONFIG_PROFILE"
    done
  else
    echo "⏭️ Build wurde übersprungen (--skip-build aktiviert)"
  fi

  if [[ -n "$RELEASE_TAG" ]]; then
    echo "🏷️  Tagging Komponenten als $RELEASE_TAG"
    for component in "${COMPONENTS[@]}"; do
      if [[ "$component" == "ldif-importer" ]]; then
        # docker tag "$DOCKER_REGISTRY/global-identity-provider-ldif-importer:7.5.1" "$DOCKER_REGISTRY/global-identity-provider-ldif-importer:$RELEASE_TAG"
        # docker push "$DOCKER_REGISTRY/global-identity-provider-ldif-importer:$RELEASE_TAG"
        DOCKER_REGISTRY="docker.io/allinformatix"
        ARCHS="linux/amd64,linux/arm64"
        docker buildx build docker/ldif-importer --platform $ARCHS --tag $DOCKER_REGISTRY/global-identity-provider-ldif-importer:$RELEASE_TAG --push
        
      else
        # docker tag "$DOCKER_REGISTRY/$component:$STAGE" "$DOCKER_REGISTRY/$component:$RELEASE_TAG"
        # docker push "$DOCKER_REGISTRY/$component:$RELEASE_TAG"
        DOCKER_REGISTRY="docker.io/allinformatix"
        ARCHS="linux/amd64,linux/arm64"
        docker buildx build docker/ldif-importer --platform $ARCHS --tag $DOCKER_REGISTRY/global-identity-provider-ldif-importer:$RELEASE_TAG --push
        
      fi
    done
    echo "📌 Git-Tag wird gesetzt: $RELEASE_TAG"
    git tag "$RELEASE_TAG"
    git push origin "$RELEASE_TAG"
  fi

  if [[ "$DO_DEPLOY" == true ]]; then
    echo "🧹 Deleting existing components in gidp-${STAGE}..."
    for component in "${COMPONENTS[@]}"; do
      if [[ "$component" == "ldif-importer" ]]; then
        echo "🔀 Skipping deletion for ldif-importer (non-Kubernetes component)"
        continue
      fi
      # if [[ "$component" == "idm" && -f "$TEMPLATE_FILE" ]]; then
      #   echo "🔧 Substituting variables into ui-configuration.json for stage \"$STAGE\""
      #   envsubst < "$TEMPLATE_FILE" > "$OUTPUT_FILE"
      # fi
      ./bin/forgeops delete "$component" --namespace "gidp-${STAGE}" --yes || true
    done

    if [[ "$LDIF_USED" == true ]]; then
      echo "💥 Reinstalling ds-idrepo (forced by ldif-importer)..."
      ./bin/forgeops delete ds-idrepo --namespace "gidp-${STAGE}" --yes || true
      ./bin/forgeops install ds-idrepo \
        --deploy-env "$STAGE" \
        --config-profile "$CONFIG_PROFILE" \
        --namespace "gidp-${STAGE}"
    fi

    echo "🚀 Installing components into gidp-${STAGE}..."
    for component in "${COMPONENTS[@]}"; do
      if [[ "$component" == "ldif-importer" ]]; then
        echo "🔀 Skipping install for ldif-importer (non-Kubernetes component)"
        continue
      fi
      if [[ "$component" == "idm" && -f "$TEMPLATE_FILE" ]]; then
        echo "🔧 3. Substituting variables into ui-configuration.json for stage \"$STAGE\""
        envsubst < "$TEMPLATE_FILE" > "$OUTPUT_FILE"
      fi
      echo "CONFIG_PROFILE --> $CONFIG_PROFILE"
      ./bin/forgeops install "$component" \
        --deploy-env "$STAGE" \
        --config-profile "$CONFIG_PROFILE" \
        --namespace "gidp-${STAGE}"
    done
  fi

done

echo "✅ Alle gewünschten Aktionen erfolgreich abgeschlossen."
