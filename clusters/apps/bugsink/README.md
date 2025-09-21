# Bugsink Configuration

This directory contains the Flux configuration for Bugsink error tracking in the production environment.

## Components

- `helm-repository.yaml` - Bugsink Helm repository
- `helm-release.yaml` - Bugsink Helm release configuration
- `vault-secret.yaml` - OpenBao secret for database credentials
- `prod.yaml` - Kustomization for prod namespace deployment

## Configuration Notes

### Database Setup

Bugsink is configured to use external PostgreSQL for main application data:

- **PostgreSQL**: Managed via Terraform in `infra/tf/openbao.tf`
- **Database**: `bugsink`
- **User**: `bugsink`
- **Credentials**: Stored in OpenBao at `kv/apps/bugsink`

### Task Queue Configuration

Bugsink uses "snappea" for background task processing, which requires SQLite:

- **SQLite Database**: `/tmp/snappea.db` (in emptyDir volume)
- **Init Container**: Runs snappea migrations before main container starts
- **Write Permissions**: Container runs as root (UID 0) for SQLite write access

### Manual Post-Deployment Steps

After Flux deploys the Helm release, the following manual steps are required:

1. **Add environment variables to Helm-generated secret**:
   ```bash
   kubectl patch secret bugsink -n prod --type merge -p '{
     "data": {
       "DIGEST_IMMEDIATELY": "VHJ1ZQ==",
       "TASK_ALWAYS_EAGER": "VHJ1ZQ==",
       "SNAPPEA_DATABASE_PATH": "L3RtcC9zbmFwcGVhLmRi",
       "DATABASE_URL": "<base64-encoded-database-url>"
     }
   }'
   ```

2. **Add volume mount for SQLite databases**:
   ```bash
   kubectl patch deployment bugsink -n prod --type='json' -p='[
     {
       "op": "add",
       "path": "/spec/template/spec/volumes",
       "value": [{"name": "tmp-data", "emptyDir": {}}]
     },
     {
       "op": "add",
       "path": "/spec/template/spec/containers/0/volumeMounts",
       "value": [{"name": "tmp-data", "mountPath": "/tmp"}]
     }
   ]'
   ```

3. **Add init container for snappea migrations**:
   ```bash
   kubectl patch deployment bugsink -n prod --type='json' -p='[
     {
       "op": "add",
       "path": "/spec/template/spec/initContainers",
       "value": [{
         "name": "snappea-init",
         "image": "bugsink/bugsink:latest",
         "command": ["/bin/bash", "-c", "bugsink-manage migrate --database=snappea"],
         "envFrom": [
           {"secretRef": {"name": "bugsink"}},
           {"configMapRef": {"name": "bugsink"}}
         ],
         "volumeMounts": [{"name": "tmp-data", "mountPath": "/tmp"}]
       }]
     }
   ]'
   ```

4. **Set root permissions for SQLite write access**:
   ```bash
   kubectl patch deployment bugsink -n prod --type='json' -p='[
     {
       "op": "replace",
       "path": "/spec/template/spec/securityContext",
       "value": {"runAsUser": 0, "runAsGroup": 0, "fsGroup": 0}
     },
     {
       "op": "replace",
       "path": "/spec/template/spec/containers/0/securityContext",
       "value": {"runAsUser": 0}
     }
   ]'
   ```

### Access

Bugsink will be accessible at `https://bugsink.haseebmajid.dev` via Cloudflare tunnel.

Default credentials (if CREATE_SUPERUSER worked):
- Username: `admin`
- Password: `admin`

## Troubleshooting

### Common Issues

1. **"readonly database" errors**: SQLite needs write permissions
   - Solution: Ensure container runs as root and has writable volume mounted

2. **"no such table: snappea_task"**: Snappea database not initialized
   - Solution: Ensure init container runs snappea migrations

3. **Database connection errors**: PostgreSQL credentials not available
   - Solution: Check VaultStaticSecret and ensure OpenBao can authenticate

### Logs

Check deployment logs:
```bash
kubectl logs -n prod deployment/bugsink -f
```

Check init container logs:
```bash
kubectl logs -n prod <pod-name> -c snappea-init
```
