 terraform {
  required_version = ">= 1.7.0"

  required_providers {
    flux = {
      source  = "fluxcd/flux"
      version = ">= 1.2"
    }
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = ">= 16.10"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 4.4.0"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.21"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.32"
    }
  }
}

# Configure the GitLab Provider
provider "gitlab" {
  token = var.gitlab_token
}

# Configure the Flux Provider
provider "flux" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
  git = {
    url = "https://gitlab.com/${var.gitlab_project}.git"
    branch = var.git_branch
    http = {
      username = "git"
      password = var.gitlab_token
    }
  }
}

# Configure the Cloudflare Provider
provider "cloudflare" {
  api_token = var.cloudflare_token
}

# Configure the OpenBao Provider
provider "vault" {
  address = var.openbao_address
  token   = var.openbao_token
}

# Configure the PostgreSQL Provider
provider "postgresql" {
  alias           = "homelab"
  host            = var.postgres_host
  port            = var.postgres_port
  database        = "postgres" # Connect to default database
  username        = var.postgres_username
  password        = var.postgres_password
  sslmode         = "disable"
  connect_timeout = 15
  superuser       = true
}

# Configure the Kubernetes Provider
provider "kubernetes" {
  config_path = "~/.kube/config"
}

# ==========================================
# Bootstrap Flux with token authentication
# ==========================================

resource "flux_bootstrap_git" "this" {
  embedded_manifests = true
  path               = "clusters"
}
