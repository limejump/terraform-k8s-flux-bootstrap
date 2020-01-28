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

variable "flux_known_hosts" {
  description = "Set of hosts and their public ssh keys to mount into `/root/.ssh/known_hosts`"
  type        = set(string)
  default     = []
}
