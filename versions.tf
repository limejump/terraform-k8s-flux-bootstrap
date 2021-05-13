terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = ">= 4.9.4"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 1.13.3"
    }

    tls = {
      source  = "hashicorp/tls"
      version = ">= 3.1.0"
    }
  }

  required_version = ">= 0.12"
}
