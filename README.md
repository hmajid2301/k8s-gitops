# K8s GitOps with Flux and OpenTofu

This repository contains the GitOps configuration for Kubernetes clusters using Flux CD and OpenTofu for infrastructure provisioning.

## Prerequisites

- [Nix](https://nixos.org/download.html) with flakes enabled
- [direnv](https://direnv.net/) (optional but recommended)
- A GitLab repository for this project
- A GitLab personal access token with API permissions
- A Kubernetes cluster

## Setup

### 1. Development Environment

Enter the development shell using Nix:

```bash
nix develop
```

Or if using direnv, simply navigate to the project directory and allow the `.envrc`:

```bash
cd /path/to/k8s-gitops
direnv allow
```

### 2. Create GitLab Personal Access Token

Create a GitLab Personal Access Token with the following scopes:
- `api` - Required for Flux to create deploy keys and access the GitLab API
- `read_repository` - Required for reading repository content
- `write_repository` - Required for image automation commits

Go to GitLab → Settings → Access Tokens → Add new token

### 3. Configure OpenTofu

1. Copy the example variables file:
   ```bash
   cp terraform/terraform.tfvars.example terraform/terraform.tfvars
   ```

2. Edit `terraform/terraform.tfvars` with your GitLab details:
   ```hcl
   gitlab_token = "your-gitlab-token-here"
   gitlab_project = "your-username/your-repo-name"
   git_branch = "main"
   ```

### 4. Initialize and Apply OpenTofu

```bash
cd terraform
tofu init
tofu plan
tofu apply
```

This will:
- Bootstrap Flux on your Kubernetes cluster using GitLab token authentication
- Configure Flux to sync from this repository with read/write access for image automation
- Set up proper authentication for automated image updates

### 5. Verify Flux Installation

Check that Flux is running:

```bash
kubectl get pods -n flux-system
flux check
```

## Repository Structure

```
├── clusters/
│   └── k8s-cluster/           # Cluster-specific configurations
│       ├── flux-system/       # Flux system components
│       └── kustomization.yaml
├── terraform/                 # OpenTofu/Terraform configurations
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars.example
├── flake.nix                  # Nix development environment
├── .envrc                     # direnv configuration
└── README.md
```

## Usage

### Adding Applications

1. Create manifests in the `clusters/k8s-cluster/` directory
2. Update the `kustomization.yaml` to include your new resources
3. Commit and push changes
4. Flux will automatically sync the changes to your cluster

### Checking Sync Status

```bash
flux get sources git
flux get kustomizations
```

## Tools Included

The development environment includes:
- `fluxcd` - Flux CLI
- `kubectl` - Kubernetes CLI
- `opentofu` - OpenTofu CLI
- `k9s` - Kubernetes UI
- `sops` - Secrets management
- `kustomize` - Kubernetes configuration management
- `go-task` - Task runner

## Security

- Secrets are managed using SOPS
- GitLab token authentication provides read/write access for image automation
- The GitLab token is stored securely in the cluster as a Kubernetes secret
- Never commit sensitive data like tokens to version control