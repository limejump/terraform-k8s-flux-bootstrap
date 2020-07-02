variable "eks_cluster_name" {
  description = "Name of the EKS cluster upon which to configure Flux"
}

variable "github_base_url" {
  description = "This is the target GitHub base API endpoint. Providing a value is a requirement when working with GitHub Enterprise."
  default     = null
}

variable "github_org_name" {
  description = "Name of the Github Organisation"
}

variable "github_repository_name" {
  description = "Name of the Github repository for Flux"
}

variable "github_repository_branch" {
  description = "Branch to use as the upstream GitOps reference"
  type        = string
  default     = "master"
}

variable "flux_docker_tag" {
  description = "Tag of flux Docker image to pull"
  type        = string
  default     = "1.18.0"
}

variable "flux_known_hosts" {
  description = "Set of hosts and their public ssh keys to mount into `/root/.ssh/known_hosts`"
  type        = set(string)
  default     = []
}

variable "flux_args_extra" {
  description = "Mapping of additional arguments to provide to the flux daemon"
  type        = map(string)
  default     = {}
}

variable "private_key_pem" {
  description = "Alternative Private Key for Flux to use when polling git via ssh"
  type        = string
  default     = null
}

variable "deploy_memcached" {
  description = "If true, deploy memcached for use with flux registry scanning"
  type        = bool
  default     = true
}

variable "flux_deployment_annotations" {
  description = "Optional annotations to apply to the Flux deployment"
  type        = map(string)
  default     = {}
}

variable "flux_deployment_labels" {
  description = "Optional labels to apply to the Flux deployment"
  type        = map(string)
  default = {
    app  = "flux"
    name = "flux"
  }
}

variable "memcached_docker_tag" {
  description = "Tag of memcached Docker image to pull"
  type        = string
  default     = "1.4.25"
}
