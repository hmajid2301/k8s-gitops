output "flux_repository_url" {
  description = "The repository URL for Flux"
  value       = "https://gitlab.com/${var.gitlab_project}.git"
}

output "flux_bootstrap_status" {
  description = "Confirmation that Flux was bootstrapped"
  value       = "Flux bootstrapped successfully for ${var.gitlab_project}"
}

output "cloudflare_tunnel_id" {
  description = "The ID of the created Cloudflare tunnel"
  value       = cloudflare_zero_trust_tunnel_cloudflared.k8s_gitops.id
}

output "cloudflare_tunnel_secret" {
  description = "The secret for the Cloudflare tunnel (sensitive)"
  value       = random_password.tunnel_secret.result
  sensitive   = true
}

output "cloudflare_tunnel_token" {
  description = "The tunnel token for cloudflared (sensitive)"
  value       = cloudflare_zero_trust_tunnel_cloudflared.k8s_gitops.tunnel_token
  sensitive   = true
}

output "openbao_secret_path" {
  description = "The path where the tunnel token is stored in OpenBao"
  value       = "kv/infra/cloudflare"
}

output "tunnel_status" {
  description = "Status of the tunnel creation and secret storage"
  value       = "Tunnel created and token saved to OpenBao at kv/infra/cloudflare"
}

output "kubernetes_secret_name" {
  description = "Name of the Kubernetes secret that will be created by Vault Secrets Operator"
  value       = "cloudflare-tunnel-token"
}
