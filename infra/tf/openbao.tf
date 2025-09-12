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