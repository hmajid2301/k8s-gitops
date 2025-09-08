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
├── clusters/k8s-cluster/   # Flux bootstrap point
└── terraform/              # Bootstrap configuration
```

## Repo-per-App Pattern

Applications are configured using the **repo-per-app** pattern:

- **This repo**: Manages infrastructure (namespaces, policies) and app integration
- **App repos**: Contain both source code and k8s configs (e.g., `banterbus/banterbus`)

### Example: Banterbus
- **Source**: `gitlab.com/banterbus/banterbus`
- **K8s Config**: `k8s/` directory in banterbus repo
- **Deployments**:
  - `k8s/dev/` → `dev` namespace
  - `k8s/prod/` → `prod` namespace

## Benefits

- Apps own their deployment configs
- Single source of truth per application
- Independent development and deployment cycles
- Clean separation of platform vs application concerns
