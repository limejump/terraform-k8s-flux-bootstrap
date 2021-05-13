terraform {
  required_providers {
    github = {
      source = "integrations/github"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
    }

    tls = {
      source  = "hashicorp/tls"
    }
  }

  required_version = ">= 0.12"
}
