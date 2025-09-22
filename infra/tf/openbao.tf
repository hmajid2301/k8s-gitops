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
  provider         = postgresql.homelab
  name             = "bugsink"
  login            = true
  password         = random_password.bugsink_db_password.result
  create_database  = true
  create_role      = false
  superuser        = false
}

# Store Bugsink secrets in OpenBao
resource "vault_kv_secret_v2" "bugsink" {
  mount               = "kv"
  name                = "apps/bugsink"
  cas                 = 1
  delete_all_versions = true

  data_json = jsonencode({
    secret_key         = random_password.bugsink_secret_key.result
    admin_user         = "admin"
    admin_pass         = "admin"
    database_url       = "postgresql://${postgresql_role.bugsink.name}:${random_password.bugsink_db_password.result}@${var.postgres_host}:${var.postgres_port}/${postgresql_database.bugsink.name}?sslmode=disable"
    db_user           = postgresql_role.bugsink.name
    db_password       = random_password.bugsink_db_password.result
    db_name           = postgresql_database.bugsink.name
    db_host           = var.postgres_host
    db_port           = var.postgres_port
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
    token = var.gitlab_token
    webhook_token = random_password.gitlab_webhook_token.result
  })
}

# Create OpenBao policy for GitLab access (used by flux-system)
resource "vault_policy" "gitlab" {
  name = "gitlab"

  policy = <<EOT
# Allow read access to gitlab secrets for preview environments
path "kv/data/apps/gitlab" {
  capabilities = ["read"]
}

path "kv/metadata/apps/gitlab" {
  capabilities = ["read", "list"]
}
EOT
}

# Create combined policy for flux-system namespace
resource "vault_policy" "flux_system" {
  name = "flux-system"

  policy = <<EOT
# Allow read access to gitlab secrets for preview environments
path "kv/data/apps/gitlab" {
  capabilities = ["read"]
}

path "kv/metadata/apps/gitlab" {
  capabilities = ["read", "list"]
}

# Allow read access to bugsink secrets if needed
path "kv/data/apps/bugsink" {
  capabilities = ["read"]
}

path "kv/metadata/apps/bugsink" {
  capabilities = ["read", "list"]
}
EOT
}
