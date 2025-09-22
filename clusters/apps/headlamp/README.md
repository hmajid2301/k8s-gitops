# Headlamp Configuration

This directory contains the Flux configuration for Headlamp Kubernetes dashboard in the prod namespace.

## Components

- `prod.yaml` - Kustomization for prod namespace deployment
- `helm-repository.yaml` - Headlamp Helm repository
- `helm-release.yaml` - Headlamp deployment configuration
- `rbac.yaml` - RBAC for Headlamp service account
- `flux-plugin-config.yaml` - Flux plugin configuration for GitOps visibility
- `service-account.yaml` - Admin service account for cluster access

## Configuration

### Namespace
- **Namespace**: `prod` (shared with other production applications)

### Service Configuration
- **Type**: NodePort
- **Port**: 80:30080
- **Access**: Via host Traefik proxy to `headlamp.homelab.haseebmajid.dev`

### Authentication
A service account `headlamp-admin` is created with cluster-admin privileges for full cluster access.

## Getting the Access Token

After deployment, get the admin token for Headlamp authentication:

```bash
# Get the token from the secret
kubectl get secret headlamp-admin-token -n prod -o jsonpath='{.data.token}' | base64 -d

# Or create a new token with custom duration
kubectl create token headlamp-admin -n prod --duration=8760h
```

## Traefik Configuration

To expose Headlamp via Traefik, add this configuration to your host Traefik:

```yaml
# /path/to/traefik/dynamic-config/headlamp.yml
http:
  routers:
    headlamp:
      rule: "Host(`headlamp.homelab.haseebmajid.dev`)"
      service: headlamp-service
      tls:
        certResolver: letsencrypt

  services:
    headlamp-service:
      loadBalancer:
        servers:
          - url: "http://5.75.159.214:30080"
```

## Features

- **Multi-cluster support**: Can manage multiple Kubernetes clusters
- **Flux plugin**: Provides GitOps visibility for Flux resources
- **Full cluster access**: Cluster-admin permissions for complete management
- **Resource editor**: Edit Kubernetes resources with validation
- **Terminal access**: Execute commands in pods
- **Log viewing**: Stream and search container logs

## Access

1. Ensure Traefik configuration is applied on host
2. Visit: `https://headlamp.homelab.haseebmajid.dev`
3. Use the service account token from above for authentication
4. Enjoy full Kubernetes cluster management via web UI!
