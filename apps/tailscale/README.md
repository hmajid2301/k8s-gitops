# Tailscale Integration

This setup provides Tailscale connectivity for the Kubernetes cluster to access homelab services.

## Architecture

Two deployment patterns are supported:

### 1. DaemonSet (Node-level connectivity)
- Runs on every node
- Provides cluster-wide Tailscale connectivity
- All pods can access homelab services through the node's Tailscale connection

### 2. Sidecar (Pod-level connectivity)
- Individual pods get their own Tailscale connection
- More granular control
- Better for specific applications that need dedicated connectivity

## Setup

1. **Get Tailscale Auth Key:**
   - Go to https://login.tailscale.com/admin/settings/keys
   - Create a new auth key (preferably reusable and ephemeral)
   - Update the `TS_AUTHKEY` in `secret.yaml`

2. **Update Secret:**
   ```bash
   # Edit the secret with your actual auth key
   kubectl edit secret tailscale-auth -n tailscale
   ```

3. **Deploy:**
   ```bash
   # Apply the resources
   flux reconcile kustomization flux-system
   ```

## Configuration

### Environment Variables

- `TS_AUTHKEY`: Tailscale authentication key
- `TS_HOSTNAME`: Custom hostname for the Tailscale node
- `TS_ROUTES`: Routes to advertise (K3s CIDRs)
- `TS_ACCEPT_DNS`: Accept DNS configuration from Tailscale
- `TS_EXTRA_ARGS`: Additional Tailscale arguments

### Network Routes

The DaemonSet advertises these routes to your Tailscale network:
- `10.42.0.0/16` - K3s pod network
- `10.43.0.0/16` - K3s service network

## Usage

### For Applications

Once deployed, your applications can connect to homelab services using their Tailscale hostnames:

```yaml
env:
- name: DATABASE_HOST
  value: "postgres.homelab.haseebmajid.dev"
- name: REDIS_HOST
  value: "redis.homelab.haseebmajid.dev:6381"
```

### Verification

```bash
# Check DaemonSet status
kubectl get daemonset -n tailscale

# Check pod status
kubectl get pods -n tailscale

# Check logs
kubectl logs -n tailscale -l app=tailscale

# Test connectivity from a pod
kubectl run test-pod --rm -it --image=busybox -- nslookup postgres.homelab.haseebmajid.dev
```

## Security

- Service account has minimal permissions (only node read access)
- NET_ADMIN capability required for network tunnel management
- Secrets stored in Kubernetes Secret (consider using SOPS for GitOps)
- Auth key should be ephemeral and reusable for security

## Troubleshooting

1. **Pod not starting:** Check if `/dev/net/tun` exists on nodes
2. **DNS not working:** Verify `TS_ACCEPT_DNS=true` is set
3. **Routes not advertised:** Check Tailscale admin console for subnet routes
4. **Connection issues:** Verify auth key is valid and not expired
