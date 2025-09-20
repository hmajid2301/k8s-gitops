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

# Store Bugsink secrets in OpenBao
resource "vault_kv_secret_v2" "bugsink" {
  mount               = "kv"
  name                = "apps/bugsink"
  cas                 = 1
  delete_all_versions = true

  data_json = jsonencode({
    secret_key = random_password.bugsink_secret_key.result
    admin_user = "admin"
    admin_pass = "admin"
  })
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
