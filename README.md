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
├── dev/                    # Dev namespace and apps
├── prod/                   # Prod namespace and apps
├── apps/                   # Shared apps namespace
├── clusters/k8s-cluster/   # Flux bootstrap point
└── terraform/              # Bootstrap configuration
```

## Adding Apps

Just add manifests to the respective folders:
- `dev/` for dev environment
- `prod/` for production
- `apps/` for shared applications

Update the `kustomization.yaml` in each folder to include your new resources.

Simple and clean - just like k3s-config!
