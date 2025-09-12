# Cloudflare Tunnel Configuration
# Creates a tunnel and automatically saves the token to OpenBao

resource "cloudflare_zero_trust_tunnel_cloudflared" "k8s_gitops" {
  account_id = var.cloudflare_account_id
  name       = "k8s-gitops-tunnel"
  secret     = base64encode(random_password.tunnel_secret.result)
}

resource "random_password" "tunnel_secret" {
  length  = 32
  special = false
  upper   = true
  lower   = true
  numeric = true
}

# Save tunnel token to OpenBao
resource "vault_kv_secret_v2" "cloudflare_tunnel" {
  mount               = "kv"
  name                = "infra/cloudflare"
  cas                 = 1
  delete_all_versions = true

  data_json = jsonencode({
    tunnel_id     = cloudflare_zero_trust_tunnel_cloudflared.k8s_gitops.id
    account_id    = var.cloudflare_account_id
    tunnel_name   = cloudflare_zero_trust_tunnel_cloudflared.k8s_gitops.name
    tunnel_token  = cloudflare_zero_trust_tunnel_cloudflared.k8s_gitops.tunnel_token
    tunnel_secret = random_password.tunnel_secret.result
  })

  depends_on = [vault_policy.cloudflare_tunnel]
}