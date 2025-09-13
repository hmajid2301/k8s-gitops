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


## Manual step

To setup homelab some commands need to be run manually for now until we can move it into terraform/automate it.

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
