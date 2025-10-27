# Cloudflare tunnel secret is managed automatically by Terraform
# Secret path: kv/infra/cloudflare
# Contains: tunnel_id, account_id, tunnel_name, tunnel_token, tunnel_secret

# Create OpenBao policy for Cloudflare tunnel access
resource "vault_policy" "cloudflare_tunnel" {
  name = "cloudflare-tunnel"

  policy = <<EOT
# Allow full access to cloudflare tunnel secrets
path "kv/data/infra/cloudflare" {
  capabilities = ["create", "read", "update", "delete"]
}

path "kv/metadata/infra/cloudflare" {
  capabilities = ["read", "list"]
}

# Allow reading tunnel token for Kubernetes deployment
path "kv/data/infra/cloudflare" {
  capabilities = ["read"]
}
EOT
}

# Generate random secret key for Bugsink
resource "random_password" "bugsink_secret_key" {
  length  = 50
  special = true
  upper   = true
  lower   = true
  numeric = true
}

# Generate random password for Bugsink database user
resource "random_password" "bugsink_db_password" {
  length  = 32
  special = true
  upper   = true
  lower   = true
  numeric = true
}

# Create PostgreSQL database for Bugsink
resource "postgresql_database" "bugsink" {
  provider = postgresql.homelab
  name     = "bugsink"
  owner    = postgresql_role.bugsink.name
}

# Create PostgreSQL role for Bugsink
resource "postgresql_role" "bugsink" {
  provider        = postgresql.homelab
  name            = "bugsink"
  login           = true
  password        = random_password.bugsink_db_password.result
  create_database = true
  create_role     = false
  superuser       = false
}

# Store Bugsink secrets in OpenBao
resource "vault_kv_secret_v2" "bugsink" {
  mount               = "kv"
  name                = "apps/bugsink"
  cas                 = 1
  delete_all_versions = true

  data_json = jsonencode({
    secret_key   = random_password.bugsink_secret_key.result
    admin_user   = "admin"
    admin_pass   = "admin"
    database_url = "postgresql://${postgresql_role.bugsink.name}:${random_password.bugsink_db_password.result}@${var.postgres_host}:${var.postgres_port}/${postgresql_database.bugsink.name}?sslmode=disable"
    db_user      = postgresql_role.bugsink.name
    db_password  = random_password.bugsink_db_password.result
    db_name      = postgresql_database.bugsink.name
    db_host      = var.postgres_host
    db_port      = var.postgres_port
  })

  depends_on = [
    postgresql_role.bugsink,
    postgresql_database.bugsink,
    random_password.bugsink_db_password
  ]
}

# Create OpenBao policy for Bugsink access
resource "vault_policy" "bugsink" {
  name = "bugsink"

  policy = <<EOT
# Allow full access to bugsink secrets
path "kv/data/apps/bugsink" {
  capabilities = ["create", "read", "update", "delete"]
}

path "kv/metadata/apps/bugsink" {
  capabilities = ["read", "list"]
}
EOT
}

# Generate random webhook token for GitLab integration
resource "random_password" "gitlab_webhook_token" {
  length  = 32
  special = false
  upper   = true
  lower   = true
  numeric = true
}

# Store GitLab secrets in OpenBao for preview environments
resource "vault_kv_secret_v2" "gitlab" {
  mount               = "kv"
  name                = "apps/gitlab"
  cas                 = 1
  delete_all_versions = true

  data_json = jsonencode({
    # You need to manually set this in GitLab with api, read_repository scopes
    token         = var.gitlab_token
    username      = var.gitlab_username
    password      = var.gitlab_token
    webhook_token = random_password.gitlab_webhook_token.result
  })
}

# Enable Kubernetes auth backend
resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
  path = "kubernetes"
}

# Create service account for OpenBao token review
resource "kubernetes_service_account" "openbao_auth" {
  metadata {
    name      = "openbao-auth"
    namespace = "kube-system"
  }
}

# Create ClusterRoleBinding for token review
resource "kubernetes_cluster_role_binding" "openbao_auth" {
  metadata {
    name = "openbao-auth-delegator"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:auth-delegator"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.openbao_auth.metadata[0].name
    namespace = kubernetes_service_account.openbao_auth.metadata[0].namespace
  }
}

# Create OpenBao policy for GitLab agent access
resource "vault_policy" "gitlab_agent" {
  name = "gitlab-agent"

  policy = <<EOT
# Allow read access to GitLab secrets
path "kv/data/infra/gitlab" {
  capabilities = ["read"]
}

path "kv/metadata/infra/gitlab" {
  capabilities = ["read", "list"]
}
EOT
}

# Get the service account token for Kubernetes auth
data "kubernetes_secret" "openbao_auth_token" {
  metadata {
    name      = kubernetes_service_account.openbao_auth.default_secret_name
    namespace = kubernetes_service_account.openbao_auth.metadata[0].namespace
  }

  depends_on = [kubernetes_service_account.openbao_auth]
}

# Configure Kubernetes auth backend
resource "vault_kubernetes_auth_backend_config" "k8s" {
  backend            = vault_auth_backend.kubernetes.path
  kubernetes_host    = "https://vps:6443"
  kubernetes_ca_cert = data.kubernetes_secret.openbao_auth_token.data["ca.crt"]
  token_reviewer_jwt = data.kubernetes_secret.openbao_auth_token.data["token"]
}

# Create Kubernetes auth role for k8s services
resource "vault_kubernetes_auth_backend_role" "k8s_auth_role" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "k8s-auth-role"
  bound_service_account_names      = ["cloudflare-tunnel", "bugsink", "gitlab-agent"]
  bound_service_account_namespaces = ["cloudflare-tunnel", "prod", "gitlab-agent-k8s"]
  token_ttl                        = 3600
  token_policies                   = ["cloudflare-tunnel", "bugsink", "gitlab-agent"]

  depends_on = [
    vault_kubernetes_auth_backend_config.k8s,
    vault_policy.cloudflare_tunnel,
    vault_policy.bugsink,
    vault_policy.gitlab_agent
  ]
}
