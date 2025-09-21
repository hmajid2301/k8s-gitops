# mirrord Setup

## Overview
mirrord allows you to run local processes while connected to remote Kubernetes environments, enabling:
- Network traffic mirroring/stealing from remote pods
- File system access to remote containers
- Environment variable sharing

## Configuration

### Dev Environment (`dev` namespace)
- **Network Mode**: `steal` - intercepts traffic from remote pods
- **File System**: Read/write access to config files, read-only logs
- **Environment**: Includes database and service URLs, excludes secrets
- **TTL**: 1 hour sessions

### Prod Environment (`prod` namespace)
- **Network Mode**: `mirror` - copies traffic (safer for production)
- **File System**: Read-only access only
- **Environment**: Includes database and service URLs, excludes secrets
- **TTL**: 30 minute sessions

## Usage

### Install mirrord CLI
```bash
curl -fsSL https://raw.githubusercontent.com/metalbear-co/mirrord/main/scripts/install.sh | bash
```

### Basic Usage

#### Connect to dev environment:
```bash
# Target a specific pod in dev namespace
mirrord exec --target pod/my-app-dev --config-file /path/to/mirrord-config-dev.json -- my-local-app

# Target deployment in dev namespace
mirrord exec --target deployment/my-app --namespace dev -- my-local-app
```

#### Connect to prod environment:
```bash
# Mirror traffic from prod (read-only, safer)
mirrord exec --target pod/my-app-prod --config-file /path/to/mirrord-config-prod.json -- my-local-app
```

### IDE Integration

#### VS Code:
1. Install the mirrord extension
2. Set configuration file path in settings
3. Use "Run with mirrord" option

#### IntelliJ/PyCharm:
1. Install mirrord plugin
2. Configure target in run configuration
3. Enable mirrord for debug sessions

### Configuration Files
- Dev config: Available in `dev` namespace as ConfigMap `mirrord-config-dev`
- Prod config: Available in `prod` namespace as ConfigMap `mirrord-config-prod`

### Security Notes
- Prod environment has restricted permissions (read-only, mirror mode)
- Secrets and sensitive environment variables are excluded
- Sessions auto-expire (dev: 1hr, prod: 30min)
- All mirrord activity is logged and auditable
