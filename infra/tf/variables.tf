variable "gitlab_token" {
  description = "The GitLab token to use for authenticating against the GitLab API"
  type        = string
  sensitive   = true
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
