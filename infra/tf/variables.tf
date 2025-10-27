variable "gitlab_token" {
  description = "The GitLab token to use for authenticating against the GitLab API"
  type        = string
  sensitive   = true
}

variable "gitlab_username" {
  description = "GitLab username for API authentication"
  type        = string
}

variable "gitlab_project" {
  description = "The GitLab project path (e.g., 'username/repo-name')"
  type        = string
}

variable "git_branch" {
  description = "The Git branch to use for Flux"
  type        = string
  default     = "main"
}

variable "cloudflare_token" {
  description = "Cloudflare API token with tunnel permissions"
  type        = string
  sensitive   = true
}

variable "cloudflare_account_id" {
  description = "Cloudflare Account ID"
  type        = string
}

variable "openbao_address" {
  description = "OpenBao server address"
  type        = string
  default     = "https://openbao.homelab.haseebmajid.dev"
}

variable "openbao_token" {
  description = "OpenBao authentication token"
  type        = string
  sensitive   = true
}

variable "ssh_private_key_path" {
  description = "Path to SSH private key for Flux"
  type        = string
  default     = "~/.ssh/id_ed25519"
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key for Flux"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "postgres_host" {
  description = "PostgreSQL host"
  type        = string
}

variable "postgres_port" {
  description = "PostgreSQL port"
  type        = number
  default     = 5432
}

variable "postgres_username" {
  description = "PostgreSQL username"
  type        = string
}

variable "postgres_password" {
  description = "PostgreSQL password"
  type        = string
  sensitive   = true
}

variable "kubernetes_host" {
  description = "Kubernetes API server host (external URL since OpenBao runs outside the cluster)"
  type        = string
}
