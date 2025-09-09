# OpenBao Kubernetes Authentication

This directory contains the Kubernetes resources needed for OpenBao's Kubernetes authentication method.

## Resources

- **ServiceAccount**: `openbao-auth` - Used by OpenBao to authenticate with Kubernetes
- **ClusterRoleBinding**: `openbao-auth-binding` - Grants `system:auth-delegator` permissions

## Usage

### Get JWT Token for OpenBao Configuration

```bash
# Get the service account JWT token
kubectl create token openbao-auth --duration=87600h

# Get cluster CA certificate
kubectl config view --raw --minify --flatten -o jsonpath='{.clusters[].cluster.certificate-authority-data}' | base64 -d

# Get Kubernetes API server URL
kubectl config view --raw --minify --flatten -o jsonpath='{.clusters[].cluster.server}'
```

### Configure OpenBao

```bash
# Enable Kubernetes auth
bao auth enable kubernetes

# Configure Kubernetes auth method
bao write auth/kubernetes/config \
  kubernetes_host="https://your-k8s-api:6443" \
  kubernetes_ca_cert="-----BEGIN CERTIFICATE-----..." \
  token_reviewer_jwt="eyJhbGciOiJSUzI1NiIs..."
```

## Permissions

The `system:auth-delegator` ClusterRole provides the necessary permissions for:
- TokenReview API access (verify service account tokens)
- SubjectAccessReview API access (check permissions)

This allows OpenBao to authenticate Kubernetes service accounts and validate their permissions.
