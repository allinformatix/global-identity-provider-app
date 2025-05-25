# allinformatix-global-idp-app
```bash
ssh-keygen -t rsa -b 4096 -C "infra-runner-allinformatix-global-idp-app" -f ~/.ssh/project_allinformatix-global-idp-app -N ""

cat <<EOF >> ~/.ssh/config
# SSH-Konfiguration für allinformatix IAC Repo
Host infra-runner-allinformatix-global-idp-app
    HostName github.com
    User git
    IdentityFile ~/.ssh/project_allinformatix-global-idp-app
    IdentitiesOnly yes
EOF

# Test
ssh -T git@infra-runner-allinformatix-global-idp-app

# 
git remote add origin git@infra-runner-allinformatix-global-idp-app:allinformatix/allinformatix-global-idp-app.git
```

## age key erstellen
```bash
age-keygen -o ~/.config/sops/age/keystore-handler.key

##############
export SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt
sops --encrypt secrets/keystore-config.yaml > secrets/keystore-config.yaml.enc

kubectl create secret generic sops-config-encrypted \
  --from-file=/home/infra-runner/projects/allinformatix-global-idp-app/secrets/keystore-config.yaml.enc \
  -n gidp

kubectl create secret generic sops-age-key \
  --from-file=/home/infra-runner/.config/sops/age/keystore-handler.key \
  -n gidp
kubectl get secrets -n gidp
```

# Ordnerstruktur
```bash
global-identity-provider-app/
├── helm/
│   ├── am/
│   ├── idm/
│   ├── ds/
│   ├── ig/
│   └── common/
├── kustomize/
│   ├── dev/
│   │   ├── base/
│   │   └── overlays/
│   ├── stg/
│   ├── prd/
├── config/
│   ├── am/
│   ├── idm/
│   ├── ds/
│   └── bootstrap/
├── manifests/
│   └── cert-manager/
│       ├── cluster-issuer.yaml
│       └── cloudflare-secret.yaml
├── scripts/
│   ├── deploy.sh
│   ├── export-config.sh
│   ├── import-config.sh
│   └── health-check.sh
├── .github/
│   └── workflows/
│       └── deploy.yml
└── README.md
```
# Deployment Befehle
```bash
## setzen von aliassen
echo "alias get_gidp_pws=\"cd \$HOME/projects/allinformatix-global-idp-app/bin && ./forgeops info && cd - > /dev/null\"" >> ~/.bashrc
cat ~/.bashrc
source ~/.bashrc
# Deployment zweier Replikationsserver

helm upgrade --install ds-replication-01 ./helm/directory-services/ds-replication \
  --namespace idp-prd \
  --set instanceId=01 \
  --set hostname=ds-replication-01 \
  --set serverId=core-it-ds-replication-01

helm uninstall ds-replication-01 --namespace idp-prd



helm upgrade --install ds-replication-02 ./helm/directory-services/ds-replication \
  --namespace idp-prd \
  --set instanceId=02 \
  --set hostname=ds-replication-02 \
  --set serverId=core-it-ds-replication-02



```
# KubeConfig bereitstellen
```bash
# Kubeconfig laden
echo -e "${GREEN}🔐 Lade kubeconfig...${NC}"
FIRST_CP="prd-k8s-gidp-cp-0"
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  root@"$FIRST_CP":/etc/kubernetes/admin.conf "kubeconfig"

# Hostname in admin.conf auf Public IP ändern
sed -i "s|^\(\s*server:\s*\)https://.*:6443$|\1https://${FIRST_CP}:6443|" "kubeconfig"

export KUBECONFIG="kubeconfig"


# secrets für DockerHub erstellen
kubectl create namespace idp-prd
kubectl delete secret dockerhub-secret -n idp-prd
kubectl create secret docker-registry dockerhub-secret \
  --docker-username="$DOCKER_USERNAME" \
  --docker-password="$DOCKER_PASSWORD" \
  --docker-email="$DOCKER_EMAIL" \
  --namespace=idp-prd

# Container debug modus
kubectl run debug-ds --rm -i -t \
  --image=allinformatix/core-it-ds-store:latest \
  --namespace idp-prd \
  --command -- /bin/sh

# see images
kubectl get pods -n idp-prd -o=jsonpath="{range .items[*]}{.metadata.name}{':\t'}{.spec.containers[*].image}{'\n'}{end}"

# S3 client installieren
curl -O https://dl.min.io/client/mc/release/linux-amd64/mc
chmod +x mc
sudo mv mc /usr/local/bin/

mc alias set hetzner https://nbg1.your-objectstorage.com E8VYDXXXXXX kz8OYN8XXXXX

mc mb hetzner/allinformatix                      # Bucket-Ordner erzeugen
mc cp ./ds.zip hetzner/allinformatix/ds/         # Datei hochladen
mc ls hetzner/allinformatix/ds/                  # Inhalt listen
mc rm hetzner/allinformatix/ds/ds.zip            # Datei löschen
mc mirror ./localdir hetzner/allinformatix/      # kompletten Ordner synchronisieren

# .git-Ordner gar nicht hochladen
mc mirror --exclude ".git/*" ./binaries hetzner/allinformatix
mc ls hetzner/allinformatix
mc ls hetzner/allinformatix/ForgeRock
mc rm --recursive --force hetzner/allinformatix/ForgeRock/AM/7.2

forgeops build am --push-to docker.io/allinformatix
forgeops build --deploy-env production

./forgeops install --mini --fqdn gidp.k8s.prd.allinformatix.com --namespace gidp


kubectl create namespace gidp
kubectl create secret docker-registry regcred \
  --docker-username="${DOCKER_USERNAME}" \
  --docker-password="${DOCKER_PASSWORD}" \
  --docker-email="${DOCKER_EMAIL}" \
  --namespace gidp
kubectl patch serviceaccount default \
  -n gidp \
  -p '{"imagePullSecrets":[{"name":"regcred"}]}'

kubectl create secret generic hetzner-s3-credentials \
  --from-literal=AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
  --from-literal=AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}

cd ~/projects/allinformatix-global-idp-app/bin
./forgeops install --mini --fqdn gidp.k8s.prd.allinformatix.com --namespace gidp

### Build all the images
cd /bin

./forgeops build ds \
  --push-to docker.io/allinformatix/global-identity-provider-ds \
  --tag 7.5.1 \
  --config-profile global-identity-provider-ds-new

./forgeops build ds \
  --push-to docker.io/allinformatix/global-identity-provider-ds-cts \
  --tag 7.5.1 \
  --config-profile global-identity-provider-ds-cts
  
./forgeops build ds \
  --push-to docker.io/allinformatix/global-identity-provider-ds-idrepo \
  --tag 7.5.1 \
  --config-profile global-identity-provider-ds-idrepo

./forgeops build amster \
  --push-to docker.io/allinformatix/global-identity-provider-amster \
  --tag 7.5.1 \
  --config-profile global-identity-provider-amster

./forgeops build am \
  --push-to docker.io/allinformatix/global-identity-provider-am \
  --tag 7.5.1 \
  --config-profile global-identity-provider-am

./forgeops build idm \
  --push-to docker.io/allinformatix/global-identity-provider-idm \
  --tag 7.5.0 \
  --config-profile global-identity-provider-idm

curl \
 --request POST \
 --insecure \
 --header "Content-Type: application/json" \
 --header "X-OpenAM-Username: amadmin" \
 --header "X-OpenAM-Password: XXXXXXX" \
 --header "Accept-API-Version: resource=2.0, protocol=1.0" \
 'https://gidp.k8s.prd.allinformatix.com/am/json/realms/root/authenticate'

cat << 'EOF' > /opt/openidm/conf/authentication.json
{
    "rsFilter" : {
        "clientId" : "idm-resource-server",
        "clientSecret" : "&{rs.client.secret|password}",
        "tokenIntrospectUrl" : "http://am/am/oauth2/introspect",
        "scopes" : [ "fr:idm:*" ],
        "cache" : {
            "maxTimeout" : "300 seconds"
        },
        "augmentSecurityContext" : {
          "type": "text/javascript",
          "source": "require('auth/orgPrivileges').assignPrivilegesToUser(resource, security, properties, subjectMapping, privileges, 'privileges', 'privilegeAssignments');"
        },
        "subjectMapping" : [
          {
            "queryOnResource": "managed/user",
            "propertyMapping": {
              "sub": "_id"
            },
            "userRoles": "authzRoles/*",
            "additionalUserFields": ["adminOfOrg", "ownerOfOrg"],
            "defaultRoles" : [
                "internal/role/openidm-authorized"
            ]
          }
        ],
        "anonymousUserMapping" : {
            "localUser" : "internal/user/anonymous",
            "roles" : [
                "internal/role/openidm-reg"
            ]
        },
        "staticUserMapping" : [
            {
                "subject" : "amadmin",
                "localUser" : "internal/user/openidm-admin",
                "roles" : [
                    "internal/role/openidm-authorized",
                    "internal/role/openidm-admin"
                ]
            },
            {
                "subject": "idm-provisioning",
                "localUser": "internal/user/idm-provisioning",
                "roles" : [
                    "internal/role/platform-provisioning"
                ]
            }
        ]
    }
}
EOF



cat << 'EOF' > /opt/openidm/conf/authentication.json
{
    "serverAuthContext" : {
        "sessionModule" : {
            "name" : "JWT_SESSION",
            "properties" : {
                "maxTokenLifeMinutes" : 120,
                "tokenIdleTimeMinutes" : 30,
                "sessionOnly" : true,
                "isHttpOnly" : true
            }
        },
        "authModules" : [
            {
                "name" : "STATIC_USER",
                "properties" : {
                    "queryOnResource" : "internal/user",
                    "username" : "anonymous",
                    "password" : "anonymous",
                    "defaultUserRoles" : [ "internal/role/openidm-reg" ]
                },
                "enabled" : true
            },
            {
                "name" : "STATIC_USER",
                "properties" : {
                    "queryOnResource" : "internal/user",
                    "username" : "openidm-admin",
                    "password" : "&{openidm.admin.password|openidm-admin}",
                    "defaultUserRoles" : [
                        "internal/role/openidm-authorized",
                        "internal/role/openidm-admin"
                    ]
                },
                "enabled" : true
            },
            {
                "name" : "MANAGED_USER",
                "properties" : {
                    "augmentSecurityContext": {
                        "type" : "text/javascript",
                        "source" : "var augmentYield = require('auth/customAuthz').setProtectedAttributes(security);require('auth/orgPrivileges').assignPrivilegesToUser(resource, security, properties, subjectMapping, privileges, 'privileges', 'privilegeAssignments', augmentYield);"
                    },
                    "queryId" : "credential-query",
                    "queryOnResource" : "managed/user",
                    "propertyMapping" : {
                        "authenticationId" : "username",
                        "userCredential" : "password",
                        "userRoles" : "authzRoles",
                        "additionalUserFields": ["adminOfOrg", "ownerOfOrg"]
                    },
                    "defaultUserRoles" : [
                        "internal/role/openidm-authorized"
                    ]
                },
                "enabled" : true
            },
            {
                "name" : "SOCIAL_PROVIDERS",
                "properties" : {
                    "defaultUserRoles" : [
                        "internal/role/openidm-authorized"
                    ],
                    "augmentSecurityContext" : {
                        "type" : "text/javascript",
                        "globals" : { },
                        "file" : "auth/populateAsManagedUserFromRelationship.js"
                    },
                    "propertyMapping" : {
                        "userRoles" : "authzRoles"
                    }
                },
                "enabled" : true
            }
        ]
    }
}
EOF


curl --insecure -u idm-resource-server:<client-secret> \
  -d "token=<ACCESS_TOKEN>" \
  https://gidp.k8s.prd.allinformatix.com/am/oauth2/introspect

curl --insecure -u ai-exec-layer-resource-server:<client-secret> \
  -d "token=<ACCESS_TOKEN>" \
  https://gidp.k8s.prd.allinformatix.com/am/oauth2/introspect

# Test AuthN
curl \
  --insecure \
  --header "X-OpenAM-Username: amadmin" \
  --header "X-OpenAM-Password: XXXXXXX" \
  --header "Accept-API-Version: resource=2.0, protocol=1.0" \
  --request POST \
  --data "grant_type=client_credentials" \
  --data "client_id=idm-provisioning" \
  --data "client_secret=XXXXX" \
  --data "scope=fr:idm:*" \
  "https://gidp.k8s.prd.allinformatix.com/am/oauth2/realms/root/access_token"

### export config
cd bin
./bin/amster export docker/am/config-profiles/global-identity-provider/config --namespace gidp-stg
./bin/amster export docker/am/config-profiles/global-identity-provider/config --namespace gidp-stg --full
./bin/amster export docker/am/config-profiles/global-identity-provider/config --namespace gidp-stg --global


./bin/amster import docker/am/config-profiles/global-identity-provider/config --namespace gidp-stg
./bin/amster import docker/am/config-profiles/global-identity-provider/config/realms/root/IdentityGatewayAgents --namespace gidp-stg


./opendj/import-ldif \
  --offline \
  --ldiffile "/opt/ds-user/opendj/ldif/allinformatixDirectoryTree.ldif" \
  --backendID userData \
  --excludeBranch dc=org,dc=allinformatix,dc=com \
  --excludeBranch dc=Consumer,dc=Tenants,dc=allinformatix,dc=com \
  --excludeBranch dc=Business,dc=Tenants,dc=allinformatix,dc=com


dsconfig list-backends \
  --hostname localhost \
  --port 4444 \
  --bindDN "uid=admin" \
  --bindPassword "$(cat "$DS_UID_ADMIN_PASSWORD_FILE")" \
  --trustAll

dsconfig list-backend-indexes \
  --backend-name amIdentityStore \
  --hostname localhost \
  --port 4444 \
  --bindDN "uid=admin" \
  --bindPassword "$(cat "$DS_UID_ADMIN_PASSWORD_FILE")" \
  --trustAll \
  --no-prompt

# idmRepo
dsconfig list-backend-indexes \
  --backend-name idmRepo \
  --hostname localhost \
  --port 4444 \
  --bindDN "uid=admin" \
  --bindPassword "$(cat "$DS_UID_ADMIN_PASSWORD_FILE")" \
  --trustAll

# idmAiExecLayerRepo
dsconfig list-backend-indexes \
  --backend-name idmAiExecLayerRepo \
  --hostname localhost \
  --port 4444 \
  --bindDN "uid=admin" \
  --bindPassword "$(cat "$DS_UID_ADMIN_PASSWORD_FILE")" \
  --trustAll

kustomize build kustomize/overlay/mini | yq '. | select(.kind == "ConfigMap") | select(.metadata.name == "platform-config")'
kustomize build kustomize/overlay/global-identity-provider-dev | yq '. | select(.kind == "ConfigMap") | select(.metadata.name == "platform-config")'

./bin/forgeops build --deploy-env dev --push-to docker.io/allinformatix --tag dev --config-profile global-identity-provider && \
  ./bin/forgeops build --deploy-env stg --push-to docker.io/allinformatix --tag stg --config-profile global-identity-provider && \
  ./bin/forgeops build --deploy-env prd --push-to docker.io/allinformatix --tag prd --config-profile global-identity-provider

./bin/forgeops install \
  --deploy-env dev \
  --namespace gidp \
  --fqdn gidp.k8s.prd.allinformatix.com \
  --mini \
  --ingress-class nginx \
  --config-profile global-identity-provider

./bin/forgeops generate all \
  --deploy-env prd \
  --fqdn gidp.k8s.prd.allinformatix.com \
  --config-profile global-identity-provider

./bin/forgeops generate all \
  --deploy-env dev \
  --fqdn gidp.k8s.dev.allinformatix.com \
  --ingress-class nginx \
  --config-profile global-identity-provider \
  --custom kustomize/overlay/global-identity-provider-dev \
  --debug

./bin/forgeops generate all \
  --deploy-env dev \
  --ingress-class nginx \
  --config-profile global-identity-provider \
  --custom kustomize/overlay/global-identity-provider-dev \
  --debug


./bin/forgeops generate all \
  --deploy-env stg \
  --ingress-class nginx \
  --config-profile global-identity-provider \
  --custom kustomize/overlay/global-identity-provider-stg

#### deployment strategy

kubectl create namespace gidp-dev
kubectl create namespace gidp-stg
kubectl create namespace gidp-prd

kubectl delete secret regcred --namespace gidp-prd
kubectl create secret docker-registry regcred \
  --docker-username="${DOCKER_USERNAME}" \
  --docker-password="${DOCKER_PASSWORD}" \
  --docker-email="${DOCKER_EMAIL}" \
  --namespace gidp-prd
kubectl patch serviceaccount default \
  -n gidp-prd \
  -p '{"imagePullSecrets":[{"name":"regcred"}]}'

kubectl delete secret hetzner-s3-credentials -n gidp-prd
kubectl create secret generic hetzner-s3-credentials \
  -n gidp-prd \
  --from-literal=AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
  --from-literal=AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}

./bin/forgeops install \
  --deploy-env prd \
  --ingress-class nginx \
  --custom kustomize/overlay/global-identity-provider-prd \
  --config-profile global-identity-provider \
  --namespace gidp-prd

###### DEV #####
kubectl create namespace gidp-dev
kubectl create secret docker-registry regcred \
  --docker-username="${DOCKER_USERNAME}" \
  --docker-password="${DOCKER_PASSWORD}" \
  --docker-email="${DOCKER_EMAIL}" \
  --namespace gidp-dev
kubectl patch serviceaccount default \
  -n gidp-dev \
  -p '{"imagePullSecrets":[{"name":"regcred"}]}'

kubectl create secret generic hetzner-s3-credentials \
  -n gidp-dev \
  --from-literal=AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
  --from-literal=AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}

./bin/forgeops build ds \
  --deploy-env dev \
  --push-to docker.io/allinformatix \
  --tag dev \
  --config-profile global-identity-provider

./bin/forgeops generate all \
  --deploy-env dev \
  --ingress-class nginx \
  --config-profile global-identity-provider \
  --custom kustomize/overlay/global-identity-provider-dev \
  --debug

./bin/forgeops install \
  --deploy-env dev \
  --ingress-class nginx \
  --custom kustomize/overlay/global-identity-provider-dev \
  --config-profile global-identity-provider \
  --namespace gidp-dev


#### CONFIGMAP überprüfen
kubectl get configmap platform-config -n gidp-dev -o yaml
###### STAGE ###### 
kubectl create secret docker-registry regcred \
  --docker-username="${DOCKER_USERNAME}" \
  --docker-password="${DOCKER_PASSWORD}" \
  --docker-email="${DOCKER_EMAIL}" \
  --namespace gidp-stg
kubectl patch serviceaccount default \
  -n gidp-stg \
  -p '{"imagePullSecrets":[{"name":"regcred"}]}'

kubectl create secret generic hetzner-s3-credentials \
  -n gidp-stg \
  --from-literal=AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
  --from-literal=AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}



./bin/forgeops generate all \
  --deploy-env stg \
  --ingress-class nginx \
  --config-profile global-identity-provider \
  --custom kustomize/overlay/global-identity-provider-stg \
  --debug

./bin/forgeops install \
  --deploy-env stg \
  --ingress-class nginx \
  --custom kustomize/overlay/global-identity-provider-stg \
  --config-profile global-identity-provider \
  --namespace gidp-stg

###### PROD ###### 
kubectl create secret docker-registry regcred \
  --docker-username="${DOCKER_USERNAME}" \
  --docker-password="${DOCKER_PASSWORD}" \
  --docker-email="${DOCKER_EMAIL}" \
  --namespace gidp-prd
kubectl patch serviceaccount default \
  -n gidp-prd \
  -p '{"imagePullSecrets":[{"name":"regcred"}]}'

kubectl create secret generic hetzner-s3-credentials \
  -n gidp-prd \
  --from-literal=AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
  --from-literal=AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}

./bin/forgeops generate all \
  --deploy-env prd \
  --ingress-class nginx \
  --config-profile global-identity-provider \
  --custom kustomize/overlay/global-identity-provider-prd \
  --debug

./bin/forgeops install \
  --deploy-env prd \
  --ingress-class nginx \
  --custom kustomize/overlay/global-identity-provider-prd \
  --config-profile global-identity-provider \
  --namespace gidp-prd

./bin/forgeops delete --namespace gidp-stg --y
./bin/forgeops delete --namespace gidp-dev --y
######

kustomize build kustomize/overlay/secrets-dev | yq '. | select(.kind == "SecretAgentConfiguration")'
kustomize build kustomize/overlay/global-identity-provider-dev | yq '. | select(.kind == "SecretAgentConfiguration")'
kustomize build kustomize/overlay/global-identity-provider-stg | yq '. | select(.kind == "SecretAgentConfiguration")'
kustomize build kustomize/overlay/global-identity-provider-prd | yq '. | select(.kind == "SecretAgentConfiguration")'


kustomize build kustomize/overlay/global-identity-provider-dev | yq '. | select(.kind == "ConfigMap")'
kustomize build kustomize/overlay/global-identity-provider-dev | yq '.spec.template.spec.containers[] | {name, image}'


#####

./bin/forgeops install \
  --deploy-env prd \
  --ingress-class nginx \
  --custom kustomize/overlay/global-identity-provider-prd \
  --config-profile global-identity-provider \
  --namespace gidp-prd

./bin/forgeops install \
  --deploy-env stg \
  --ingress-class nginx \
  --custom kustomize/overlay/global-identity-provider-stg \
  --config-profile global-identity-provider \
  --namespace gidp-stg

./bin/forgeops install \
  --deploy-env dev \
  --ingress-class nginx \
  --custom kustomize/overlay/global-identity-provider-dev \
  --config-profile global-identity-provider \
  --namespace gidp-dev

### DELETE Components
./bin/forgeops delete idm --namespace gidp-stg --yes
./bin/forgeops delete ig --namespace gidp-stg --yes


#####

./bin/forgeops build ds-idrepo \
  --deploy-env experimental \
  --push-to docker.io/allinformatix \
  --tag experimental
  
./bin/forgeops build ds-cts  \
  --deploy-env experimental \
  --push-to docker.io/allinformatix \
  --tag experimental

# Im Image überprüfen
docker run -it --rm --entrypoint bash docker.io/allinformatix/ds-idrepo:experimental

./scripts/build-images.sh --component=ldif-importer --stage=dev

export DOCKER_REGISTRY="docker.io/allinformatix"
export ARCHS="linux/amd64,linux/arm64"
docker buildx build docker/ldif-importer --platform "$ARCHS" --tag $DOCKER_REGISTRY/global-identity-provider-ldif-importer:7.5.1 --push

kubectl get secret ds-passwords -n gidp-stg -o jsonpath="{.data.dirmanager\.pw}" | base64 -d

### Curl Priviledges

curl 'https://gidp.k8s.stg.allinformatix.com/am/json/realms/root/groups/GIDP%20ADMINS' \
-X 'PUT' \
-H 'Content-Type: application/json' \
-H 'If-Match: *' \
-H 'Cookie: route=1744396605.791.6512.388945|c5726ba0e0fe23a53bd75227f5e370c1; amlbcookie=01; iPlanetDirectoryPro=w5w2Ju4B5x6AxVkRDm4BFeZsOaU.*AAJTSQACMDIAAlNLABxxUmp0dVpJU0JmQ1RSVFlLMDhBMkgxY0Uvdjg9AAR0eXBlAANDVFMAAlMxAAIwMQ..*' \
-H 'X-Requested-With: XMLHttpRequest' \
-H 'Priority: u=3, i' \
-H 'Accept-API-Version: protocol=2.1,resource=4.0' \
--data-raw '{"username":"GIDP ADMINS","realm":"/","universalid":["id=GIDP ADMINS,ou=group,ou=am-config"],"members":{"uniqueMember":["idm-admin"]},"cn":["GIDP ADMINS"],"privileges":{"EntitlementRestAccess":false,"ApplicationReadAccess":false,"ResourceTypeReadAccess":false,"PrivilegeRestReadAccess":false,"ApplicationTypesReadAccess":false,"SubjectAttributesReadAccess":false,"AgentAdmin":false,"PolicyAdmin":false,"LogRead":false,"SubjectTypesReadAccess":false,"CacheAdmin":false,"ConditionTypesReadAccess":false,"SessionPropertyModifyAccess":false,"LogWrite":false,"FederationAdmin":false,"PrivilegeRestAccess":false,"LogAdmin":false,"RealmReadAccess":false,"RealmAdmin":true,"ApplicationModifyAccess":false,"ResourceTypeModifyAccess":false,"DecisionCombinersReadAccess":false}}'


kubectl create secret generic cloud-storage-credentials-cts \
 --from-literal=AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
 --from-literal=AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY

kubectl create secret generic cloud-storage-credentials-idrepo \
 --from-literal=AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
 --from-literal=AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY

dsbackup create \
  --hostname localhost \
  --port 4444 \
  --bindDN uid=admin \
  --bindPassword "$(cat /var/run/secrets/admin/dirmanager.pw)" \
  --backupLocation "s3://dev-gidp-backups/ds-idrepo-0/manual-$(date +%Y%m%d%H%M%S)" \
  --storageProperty s3.keyId.env.var:AWS_ACCESS_KEY_ID \
  --storageProperty s3.secret.env.var:AWS_SECRET_ACCESS_KEY \
  --storageProperty endpoint:https://nbg1.your-objectstorage.com

manage-tasks \
  --hostname localhost \
  --port 4444 \
  --bindDN uid=admin \
  --bindPassword "$(cat /var/run/secrets/admin/dirmanager.pw)" \
  --summary 

manage-tasks \
  --info recurringBackupTask-20250415113000000 \
  --hostname localhost \
  --port 4444 \
  --bindDN uid=admin \
  --bindPassword:file /var/run/secrets/admin/dirmanager.pw \
  --trustAll

# longhorn OAuth2 Client
kubectl create secret generic longhorn-oauth2-secret \
  --namespace longhorn-system \
  --from-literal=client-secret='<CLIENT_SECRET>' \
  --from-literal=cookie-secret=$(openssl rand -hex 16)

kustomize build kustomize/overlay/global-identity-provider-dev | yq eval '. | select(.kind == "Ingress")' -

# Secret erzeugen
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: cloudflare-api-token-secret
  namespace: gidp-dev
type: Opaque
stringData:
  api-token: "$CLOUDFLARE_API_TOKEN"
EOF

kubectl annotate certificate api-sslcert cert-manager.io/force-renew=true --overwrite -n gidp-dev
kubectl delete certificate api-sslcert -n gidp-dev

kubectl logs -n cert-manager deploy/cert-manager

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: cloudflare-api-token-secret
  namespace: cert-manager
type: Opaque
stringData:
  api-token: "$CLOUDFLARE_API_TOKEN"
EOF


# AMD Nodes
kubectl get nodes -l kubernetes.io/arch=amd64
NAME                            STATUS   ROLES    AGE   VERSION
prd-k8s-gidp-worker-general-0   Ready    <none>   12d   v1.31.4
prd-k8s-gidp-worker-general-1   Ready    <none>   12d   v1.31.4
prd-k8s-gidp-worker-general-2   Ready    <none>   12d   v1.31.4
prd-k8s-gidp-worker-general-3   Ready    <none>   12d   v1.31.4

# Startet einen Curl Pod auf einen AMD Node
kubectl run curl \
  --rm -i -t \
  --image=curlimages/curl \
  --overrides='
{
  "apiVersion": "v1",
  "spec": {
    "nodeSelector": {
      "kubernetes.io/arch": "amd64"
    }
  }
}' \
  -- sh

curl -X POST \
  -u "idm-provisioning:BpH0U3cnMyPCIkD22xDiXe7a" \
  -d "grant_type=client_credentials" \
  -d "scope=openid fr:idm:*" \
  http://am:80/am/oauth2/access_token

curl -X POST \
  -u "idm-provisioning:BpH0U3cnMyPCIkD22xDiXe7a" \
  -d "grant_type=client_credentials" \
  -d "scope=fr:realm:*" \
  https://gidp.k8s.dev.allinformatix.com/am/oauth2/access_token

curl -X POST \
  -u "idm-provisioning:BpH0U3cnMyPCIkD22xDiXe7a" \
  -d "grant_type=client_credentials" \
  -d "scope=openid fr:idm:*" \
  https://gidp.k8s.dev.allinformatix.com/am/oauth2/access_token

curl -X POST \
  -u "idm-provisioning:BpH0U3cnMyPCIkD22xDiXe7a" \
  -d "grant_type=client_credentials" \
  -d "scope=openid" \
  https://gidp.k8s.dev.allinformatix.com/am/oauth2/access_token

# export IDM Config
./bin/config export idm global-identity-provider
cd kustomize/overlay/global-identity-provider-stg
kustomize build . | kubectl apply -f -

# secrets bereitstellen
./bin/forgeops install secrets \
  --namespace gidp-dev \
  --deploy-env dev \
  --custom kustomize/overlay/global-identity-provider-dev

./bin/forgeops install secrets \
  --namespace gidp-stg \
  --deploy-env stg \
  --custom kustomize/overlay/global-identity-provider-stg

./bin/forgeops install secrets \
  --namespace gidp-prd \
  --deploy-env prd \
  --custom kustomize/overlay/global-identity-provider-prd

kubectl -n longhorn-system port-forward service/longhorn-frontend 8088:80

kubectl cp gidp-$STAGE/am-6bcc84f94f-lctgw:/home/forgerock/amtruststore ./amtruststore.jks

./forgeops-build-wrapper.sh --recreate-namespace --stage=dev
./forgeops-build-wrapper.sh --install-all --stage=dev
./forgeops-build-wrapper.sh --install-all --stage=prd --tag=prd
./forgeops-build-wrapper.sh --delete-all --stage=dev --force

# build all components
./forgeops-build-wrapper.sh --build-all --stage=dev --tag=dev

# build single componente
./forgeops-build-wrapper.sh --component=am --stage=dev --tag=dev
./forgeops-build-wrapper.sh --component=ig --stage=prd --tag=prd --deploy
./forgeops-build-wrapper.sh --component=idm --stage=dev --tag=dev --deploy

./forgeops-build-wrapper.sh --component=ig --stage=prd --tag=prd --deploy --image-initialized=true
./forgeops-build-wrapper.sh --component=idm --stage=stg --tag=stg --deploy --image-initialized=true
./forgeops-build-wrapper.sh --component=idm --stage=stg --tag=v-0.1.8 --deploy --image-initialized=true
./forgeops-build-wrapper.sh --component=ig --stage=stg --tag=v-0.1.8 --deploy --image-initialized=false

# release Tag
./forgeops-build-wrapper.sh --build-all --stage=dev --tag=v-0.1.0 --release-tag=v-0.1.0 --image-initialized=true
./forgeops-build-wrapper.sh --build-all --stage=dev --tag=v-0.1.1 --release-tag=v-0.1.1 --image-initialized=true

## Passwords for an environment
./bin/forgeops info --namespace gidp-dev

## troubloshooting # authIndexType=module&authIndexValue=Application || authIndexType=service&authIndexValue=Agent
curl \
--request POST \
--header "X-OpenAM-Username: ig-agent" \
--header "X-OpenAM-Password: password" \
--header "Content-Type: application/json" \
--header "Accept-API-Version: resource=2.1" \
'https://gidp.k8s.prd.allinformatix.com/am/json/authenticate?authIndexType=service&authIndexValue=Agent'

curl \
--request POST \
--header "X-OpenAM-Username: ig-agent" \
--header "X-OpenAM-Password: password" \
--header "Content-Type: application/json" \
--header "Accept-API-Version: resource=2.1" \
'http://am:80/am/json/authenticate?authIndexType=service&authIndexValue=Agent'

curl \
--request POST \
--header "X-OpenAM-Username: test" \
--header "X-OpenAM-Password: test" \
--header "Content-Type: application/json" \
--header "Accept-API-Version: resource=2.1" \
'http://am:80/am/json/authenticate?authIndexType=service&authIndexValue=Agent'


curl \
--request POST \
--header "X-OpenAM-Username: ig-agent" \
--header "X-OpenAM-Password: password" \
--header "Content-Type: application/json" \
--header "Accept-API-Version: resource=2.1" \
'http://am:80/am/json/authenticate?authIndexType=service&authIndexValue=Agent'

export AM_URL=https://gidp.k8s.stg.allinformatix.com/am
curl -k -u "oauth2:password" \
  -d "grant_type=client_credentials&scope=profile mail employeenumber" \
  "$AM_URL/oauth2/access_token"

curl -k -X GET \
  -H "Authorization: Bearer XizGEcM48XsQIXQCgJ4aSmyIArk" \
  "https://gidp.k8s.stg.allinformatix.com/ig/rs-tokenintrospect"



kubectl create secret generic runpod-api-key \
  --from-literal=RUNPOD_API_KEY=$RUNPOD_API_KEY \
  -n gidp-prd

kubectl create secret generic runpod-api-key \
  --from-literal=RUNPOD_API_KEY=$RUNPOD_API_KEY \
  -n gidp-stg

kubectl create secret generic runpod-api-key \
  --from-literal=RUNPOD_API_KEY=$RUNPOD_API_KEY \
  -n gidp-dev

export OPENAI_API_KEY=

kubectl create secret generic openai-api-key \
  --from-literal=OPENAI_API_KEY=$OPENAI_API_KEY \
  -n gidp-prd

kubectl create secret generic openai-api-key \
  --from-literal=OPENAI_API_KEY=$OPENAI_API_KEY \
  -n gidp-stg

kubectl create secret generic openai-api-key \
  --from-literal=OPENAI_API_KEY=$OPENAI_API_KEY \
  -n gidp-dev


# Ingress Updaten
kubectl apply -k kustomize/deploy-stg/base -n gidp-stg

# Curl gegen die AI schießen
curl -X POST https://api.stg.allinformatix.com/ai/aws-suggestion \
  -H "Content-Type: application/json" \
  -d '{
        "goal": "Deploy a secure image processing pipeline",
        "services": ["lambda", "s3", "cloudfront"]
      }'

curl -X POST https://api.stg.allinformatix.com/ai/aws-suggestion \
  -H "Content-Type: application/json" \
  -d '{"prompt":"Generate Kubernetes YAML"}'

## Verfügbare Filter von ForgeRock IG
# Hier ist eine Liste der verfügbaren Filter in ForgeRock Identity Gateway (IG) Version 2025.3, basierend auf der offiziellen Dokumentation:

# Allgemeine Filter
# 	•	AllowOnlyFilter
# 	•	AmSessionIdleTimeoutFilter
# 	•	AssignmentFilter
# 	•	CapturedUserPasswordFilter
# 	•	CertificateThumbprintFilter
# 	•	ChainOfFilters
# 	•	CircuitBreakerFilter
# 	•	ConditionEnforcementFilter
# 	•	ConditionalFilter
# 	•	CookieFilter
# 	•	CorsFilter
# 	•	CrossDomainSingleSignOnFilter
# 	•	CsrfFilter
# 	•	DataPreservationFilter
# 	•	DateHeaderFilter
# 	•	EntityExtractFilter
# 	•	FileAttributesFilter
# 	•	ForwardedRequestFilter
# 	•	FragmentFilter
# 	•	HeaderFilter
# 	•	HttpBasicAuthFilter
# 	•	IdTokenValidationFilter
# 	•	JwtBuilderFilter
# 	•	JwtValidationFilter
# 	•	LocationHeaderFilter
# 	•	PasswordReplayFilter
# 	•	PolicyEnforcementFilter
# 	•	ScriptableFilter
# 	•	SessionInfoFilter
# 	•	SetCookieUpdateFilter
# 	•	SingleSignOnFilter
# 	•	SqlAttributesFilter
# 	•	StaticRequestFilter
# 	•	SwitchFilter
# 	•	ThrottlingFilter
# 	•	TokenTransformationFilter
# 	•	TransactionIdOutboundFilter
# 	•	UmaFilter
# 	•	UriPathRewriteFilter
# 	•	UserProfileFilter ￼ ￼

# OAuth 2.0 und OpenID Connect Filter
# 	•	AuthorizationCodeOAuth2ClientFilter
# 	•	ClientCredentialsOAuth2ClientFilter
# 	•	ClientSecretBasicAuthenticationFilter
# 	•	ClientSecretPostAuthenticationFilter
# 	•	EncryptedPrivateKeyJwtClientAuthenticationFilter
# 	•	GrantSwapJwtAssertionOAuth2ClientFilter
# 	•	OAuth2ResourceServerFilter
# 	•	OAuth2TokenExchangeFilter
# 	•	PrivateKeyJwtClientAuthenticationFilter
# 	•	ResourceOwnerOAuth2ClientFilter ￼ ￼

# PingOne Protect Filter
# 	•	PingOneApiAccessManagementFilter
# 	•	PingOneProtectEvaluationFilter
# 	•	PingOneProtectFeedbackFailureFilter
# 	•	PingOneProtectFeedbackSuccessFilter ￼

# SAML Filter
# 	•	SamlFederationFilter ￼

# Diese Filter ermöglichen es, Anfragen und Antworten während der Verarbeitung zu überwachen und zu verändern, beispielsweise durch das Ändern von URLs, Headern oder dem Einfügen von Authentifizierungsmechanismen. Für detaillierte Informationen zu jedem Filter, einschließlich Konfigurationsbeispielen, empfehle ich einen Blick in die offizielle Dokumentation:  ￼. ￼

# Wenn du Unterstützung bei der Konfiguration eines bestimmten Filters benötigst oder weitere Fragen hast, stehe ich gerne zur Verfügung.


# 

curl https://api.stg.allinformatix.com/ai/aws-suggestion
curl https://api.stg.allinformatix.com/ai/openai-lambda
curl -X GET https://api.runpod.ai/v2/a0ln1b3e89wmet/status/2a0d62a8-6c8e-4770-87da-4ef9297d4de9-e1 \
    -H 'Authorization: Bearer ${RUNPOD_API_KEY}'

POST https://api.openai.com/v1/chat/completions
Authorization: Bearer YOUR_API_KEY
Content-Type: application/json

curl -X POST https://api.openai.com/v1/chat/completions \
  -H "Authorization: Bearer ${OPENAI_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-4-turbo",
    "messages": [
      {
        "role": "system",
        "content": "You are a helpful DevOps assistant who only responds with Terraform JSON."
      },
      {
        "role": "user",
        "content": "Generate a JSON object representing Terraform code to create a basic AWS Lambda function that is triggered by an HTTP request."
      }
    ],
    "temperature": 0.4,
    "max_tokens": 1024
  }'



kubectl get secret ig-env-secrets -n gidp-${STAGE} -o jsonpath="{.data.IG_AGENT_SECRET}" | base64 --decode
# Hole den Base64-Wert aus Kubernetes
ENCODED_SECRET=$(kubectl get secret ig-env-secrets -n gidp-${STAGE} -o jsonpath="{.data.IG_AGENT_SECRET}")

# Base64-dekodieren:
echo "$ENCODED_SECRET" | base64 --decode

'
echo 'alias curl_console="kubectl run curl --rm -i -t --image=curlimages/curl --overrides='\''{\"apiVersion\":\"v1\",\"spec\":{\"nodeSelector\":{\"kubernetes.io/arch\":\"amd64\"}}}'\'' -- sh"' >> ~/.bashrc
source ~/.bashrc

echo 'alias curl_console="kubectl run curl --rm -i -t --image=curlimages/curl --overrides='\''{\"apiVersion\":\"v1\",\"spec\":{\"nodeSelector\":{\"kubernetes.io/arch\":\"amd64\"}}}'\'' -- sh"' >> ~/.bashrc
source ~/.zshrc

export PATH="$HOME/tools/groovy/groovy-2.5.21/bin:$PATH"
curl http://ig/ig/productFetcher/azure \
  -H "Authorization: Bearer 5Pc0H6dqVGhx_StUxH5Ulx1WbLI"
Funktion | Beispiel
Dynamischer Filter serviceName | /ig/productFetcher/azure?serviceName=Virtual Machines
Dynamischer Filter serviceFamily | /ig/productFetcher/azure?serviceFamily=Compute
Dynamischer Filter priceType | /ig/productFetcher/azure?priceType=Reservation
Dynamischer Filter currencyCode | /ig/productFetcher/azure?currencyCode=EUR
Kombinierte Filter | /ig/productFetcher/azure?serviceName=Virtual Machines&priceType=Reservation

Openidm Schema testen
curl \
  'https://gidp.k8s.stg.allinformatix.com/openidm/system?_action=schema' \
  -H 'Authorization: Bearer c_F-8jvjzNpmyXd9bXL0N5ZBnIY' -H 'Accept: application/json' -H 'Content-Type: application/json'
  
curl \
  'https://gidp.k8s.stg.allinformatix.com/openidm/system/productFetcherAzure?_action=schema' \
  -H 'Authorization: Bearer c_F-8jvjzNpmyXd9bXL0N5ZBnIY' \
  -H 'Accept: application/json' \
  -H 'Content-Type: application/json'

curl http://ig/ig/productFetcher/azure?serviceName=Virtual%20Machines \
  -H "Authorization: Bearer 5Pc0H6dqVGhx_StUxH5Ulx1WbLI"


curl 'http://ig/ig/productFetcher/azure?serviceFamily=Compute&debugging=true' \
  -H "Authorization: Bearer 5Pc0H6dqVGhx_StUxH5Ulx1WbLI"
curl 'http://ig/ig/productFetcher/azure?serviceFamily%3DCompute%26debugging%3Dtrue' -H 'Authorization: Bearer 5Pc0H6dqVGhx_StUxH5Ulx1WbLI'

curl 'http://ig/ig/productFetcher/azure?serviceFamily=Compute' \
  -H "Authorization: Bearer ujlbB3byeQrGRDVeIvMhahhKFD4"

curl 'http://ig/ig/productFetcher/azure?serviceName=Virtual%20Machines' \
  -H "Authorization: Bearer 5Pc0H6dqVGhx_StUxH5Ulx1WbLI"



kubectl delete -f kustomize/base/postgres/postgres-user-setup-job.yaml
./forgeops-build-wrapper.sh --delete-component=postgres
./forgeops-build-wrapper.sh --component=postgres --tag=v-0.1.8 --image-initialized=true --deploy --force
kubectl apply -f kustomize/base/postgres/postgres-user-setup-job.yaml 

export CONFIG_PROFILE=global-identity-provider
export STAGE_FILTER=stg
./bin/forgeops install secrets -n gidp-stg --custom "kustomize/overlay/${CONFIG_PROFILE}-${STAGE_FILTER}"
./bin/forgeops install base -n gidp-stg --custom "kustomize/overlay/${CONFIG_PROFILE}-${STAGE_FILTER}"
./bin/forgeops install ds -n gidp-stg --custom "kustomize/overlay/${CONFIG_PROFILE}-${STAGE_FILTER}"
./bin/forgeops install apps -n gidp-stg --custom "kustomize/overlay/${CONFIG_PROFILE}-${STAGE_FILTER}"
./bin/forgeops install ui -n gidp-stg --custom "kustomize/overlay/${CONFIG_PROFILE}-${STAGE_FILTER}"

kubectl apply -k /Users/fehmi/projects/allinformatix/allinformatix-global-idp-app/kustomize/deploy-stg/secrets

# To install the generated packages, run:
kubectl apply -k /Users/fehmi/projects/allinformatix/allinformatix-global-idp-app/kustomize/deploy-dev/secrets
forgeops wait secrets
kubectl apply -k /Users/fehmi/projects/allinformatix/allinformatix-global-idp-app/kustomize/deploy-dev/base
kubectl apply -k /Users/fehmi/projects/allinformatix/allinformatix-global-idp-app/kustomize/deploy-dev/ds
forgeops wait ds
kubectl apply -k /Users/fehmi/projects/allinformatix/allinformatix-global-idp-app/kustomize/deploy-dev/apps
forgeops wait apps
kubectl apply -k /Users/fehmi/projects/allinformatix/allinformatix-global-idp-app/kustomize/deploy-dev/ui


./forgeops-wrapper.sh --delete-all --force && ./forgeops-wrapper.sh --delete-component=postgres --force && ./forgeops-wrapper.sh --delete-component=ig --force && ./forgeops-wrapper.sh --delete-component=ai-exec-layer --force

./forgeops-wrapper.sh --install-all --force && ./forgeops-wrapper.sh --component=ai-exec-layer --tag=v-0.9.0 --image-initialized=true --force --deploy

kubectl rollout restart statefulset ds-idrepo -n gidp-<stage>
kubectl rollout restart deployment idm -n gidp-<stage>
