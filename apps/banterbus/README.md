# Banterbus Application

This follows the **repo-per-app** pattern where the application configuration lives in the banterbus repository.

## Source Repository

- **Repository**: https://gitlab.com/banterbus/banterbus
- **Config Path**: `k8s/` directory in the banterbus repo
- **Pattern**: Only the `k8s/` folder is synced from the banterbus repository

## Expected Structure in Banterbus Repo

The banterbus repository should have this structure:

```
banterbus/
├── src/                    # Application source code
├── Dockerfile
├── k8s/                    # Kubernetes configurations (synced by Flux)
│   ├── base/              # Base manifests
│   │   ├── kustomization.yaml
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   └── configmap.yaml
│   ├── dev/               # Dev environment overlay
│   │   ├── kustomization.yaml
│   │   ├── deployment-patch.yaml
│   │   └── configmap-patch.yaml
│   └── prod/              # Prod environment overlay
│       ├── kustomization.yaml
│       ├── deployment-patch.yaml
│       └── configmap-patch.yaml
└── ...
```

## Deployments

- **Dev**: `k8s/dev/` → deployed to `dev` namespace
- **Prod**: `k8s/prod/` → deployed to `prod` namespace

## Benefits

- **Developer Ownership**: Banterbus team controls their K8s configs
- **Single Source of Truth**: App code and deployment config in one place
- **Independent Releases**: Can update app config without touching GitOps repo
- **GitOps Compliance**: Still follows GitOps principles with Git as source of truth
