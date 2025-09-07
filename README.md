# K8s GitOps (Flux and OpenTofu)

This repository contains the GitOps configuration for Kubernetes clusters using Flux CD and OpenTofu for infrastructure provisioning.

## Setup

```bash
nix develop

# or

direnv allow
```

```bash
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
```

```hcl
gitlab_token = "your-gitlab-token-here"
gitlab_project = "your-username/your-repo-name"
git_branch = "main"
```

Go to GitLab → Settings → Access Tokens → Add new token

Create a GitLab Personal Access Token with the following scopes:
- `api` - Required for Flux to create deploy keys and access the GitLab API
- `read_repository` - Required for reading repository content
- `write_repository` - Required for image automation commits


```bash
cd terraform
tofu init
tofu plan
tofu apply


flux check
```

This will:
- Bootstrap Flux on your Kubernetes cluster using GitLab token authentication
- Configure Flux to sync from this repository with read/write access for image automation
- Set up proper authentication for automated image updates
