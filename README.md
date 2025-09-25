# K8s GitOps with Flux and OpenTofu

Simple GitOps setup following k3s-config patterns.

## Setup

```bash
nix develop
# or
direnv allow
```

```bash
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
```

Edit with your GitLab token and project details.

```bash
cd terraform
tofu init
tofu apply
```

## Structure

```
├── dev/                    # Dev namespace
├── prod/                   # Prod namespace
├── apps/                   # Applications (repo-per-app pattern)
│   ├── namespace.yaml      # Apps namespace
│   ├── sources/            # Git sources for external repos
│   └── banterbus/          # Banterbus app (points to banterbus/banterbus repo)
├── clusters/              # Flux bootstrap point
└── terraform/              # Bootstrap configuration
```

#  Manual step

To setup homelab some commands need to be run manually for now until we can move it into terraform/automate it.

### GitLab

Create a PAT in GitLab

```
# Create a GitLab Personal Access Token with these scopes:
# - 'api' (for preview environments, webhooks, MR access)
# - 'read_repository' (for cloning, branch access)
# - 'write_repository' (for Flux GitOps commits)
# - 'read_user' (for MR author info in preview environments)
```

### Tailscale

Create the following tags in your policy

```json
"tagOwners": {
   "tag:k8s-operator": [],
   "tag:k8s": ["tag:k8s-operator"],
}
```

Create an OAuth client in the OAuth clients page of the admin console.
Create the client with Devices Core and Auth Keys write scopes, and the tag tag:k8s-operator.

Then manually add it to k8s

```bash
kubectl create secret generic operator-oauth -n tailscale \
        --from-literal=client_id=$TAILSCALE_CLIENT_ID  \
        --from-literal=client_secret=$TAILSCALE_CLIENT_SECRET
```

Potentially solved using init container with host network, assuming host is already on tailnet

### OpenBao

Setup the terraform policy and user and password manually so it can configure everything else we need with openbao.

Potentially solved with this: https://openbao.org/docs/rfcs/self-init/#proof-of-concept

### Grafana

Create a terraform service account.

# TODO

- bugsink to use postgres

- kubernetes_secret.gitlab_api_token created in terraform get it to use openbao having issues with `VaultStaticSecret`.

- traefik token and cert in nixicle

```bash
# Get the token
kubectl get secret traefik-token -n kube-system -o jsonpath='{.data.token}' | base64 -d

# Get the CA certificate
kubectl get secret traefik-token -n kube-system -o jsonpath='{.data.ca\.crt}' | base64 -d

# Get the server URL
kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}'
```
