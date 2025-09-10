output "flux_repository_url" {
  description = "The repository URL for Flux"
  value       = "https://gitlab.com/${var.gitlab_project}.git"
}

output "flux_bootstrap_status" {
  description = "Confirmation that Flux was bootstrapped"
  value       = "Flux bootstrapped successfully for ${var.gitlab_project}"
}