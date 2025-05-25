# Kubeconfig laden
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo -e "${GREEN}🔐 Lade kubeconfig...${NC}"

TF_DIR="$HOME/projects/allinformatix-global-idp-iac/infra/terraform/hetzner/prd/k8s"
FIRST_CP=$(terraform -chdir="$TF_DIR" output -json control_plane_ips | jq -r '.[0]')
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  root@"$FIRST_CP":/etc/kubernetes/admin.conf "$BASE_DIR/kubeconfig"

# Hostname in admin.conf auf Public IP ändern
if [[ "$OSTYPE" == "darwin"* ]]; then
  sed -i '' "s|^\(\s*server:\s*\)https://.*:6443$|\1https://${FIRST_CP}:6443|" "$BASE_DIR/kubeconfig"
else
  sed -i "s|^\(\s*server:\s*\)https://.*:6443$|\1https://${FIRST_CP}:6443|" "$BASE_DIR/kubeconfig"
fi

KUBECONFIG=$HOME/.kube/config:$BASE_DIR/kubeconfig kubectl config view --flatten > $HOME/.kube/merged-config

mv $HOME/.kube/merged-config $HOME/.kube/config

export KUBECONFIG="$HOME/.kube/config"