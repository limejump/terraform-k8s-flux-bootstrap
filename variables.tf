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

variable "flux_liveness_probe_failure_threshold" {
  description = "The liveness probe failure threhold"
  type        = number
  default     = 3
}

variable "flux_liveness_probe_initial_delay_seconds" {
  description = "The liveness probe initial delay in seconds"
  type        = number
  default     = 5
}

variable "flux_liveness_probe_period_seconds" {
  description = "The liveness probe period in seconds"
  type        = number
  default     = 10
}

variable "flux_liveness_probe_success_threshold" {
  description = "The liveness probe success threhold"
  type        = number
  default     = 1
}

variable "flux_liveness_probe_timeout_seconds" {
  description = "The liveness probe timeout in seconds"
  type        = number
  default     = 5
}

variable "flux_liveness_probe_http_get_path" {
  description = "The liveness probe http get path"
  type        = string
  default     = "/api/flux/v6/identity.pub"
}

variable "flux_liveness_probe_http_get_port" {
  description = "The liveness probe http get port"
  type        = number
  default     = 3030
}

variable "flux_liveness_probe_http_get_scheme" {
  description = "The liveness probe http get scheme"
  type        = string
  default     = "HTTP"
}

variable "flux_readiness_probe_failure_threshold" {
  description = "The readiness probe failure threhold"
  type        = number
  default     = 3
}

variable "flux_readiness_probe_initial_delay_seconds" {
  description = "The readiness probe initial delay in seconds"
  type        = number
  default     = 5
}

variable "flux_readiness_probe_period_seconds" {
  description = "The readiness probe period in seconds"
  type        = number
  default     = 10
}

variable "flux_readiness_probe_success_threshold" {
  description = "The readiness probe success threhold"
  type        = number
  default     = 1
}

variable "flux_readiness_probe_timeout_seconds" {
  description = "The readiness probe timeout in seconds"
  type        = number
  default     = 5
}

variable "flux_readiness_probe_http_get_path" {
  description = "The readiness probe http get path"
  type        = string
  default     = "/api/flux/v6/identity.pub"
}

variable "flux_readiness_probe_http_get_port" {
  description = "The readiness probe http get port"
  type        = number
  default     = 3030
}

variable "flux_readiness_probe_http_get_scheme" {
  description = "The readiness probe http get scheme"
  type        = string
  default     = "HTTP"
}

variable "container_port" {
  description = "Port to expose on container"
  type        = number
  default     = 3030
}

variable "host_port" {
  description = "Port to expose on host"
  type        = number
  default     = 0
}

variable "protocol" {
  description = "Port protocol (must be TCP or UDP)"
  type        = string
  default     = "TCP"
}

variable "container_cpu_request" {
  description = "How much CPU resource to request"
  type        = string
  default     = "250m"
}

variable "container_cpu_limit" {
  description = "Upper boundary of CPU resource"
  type        = string
  default     = "1"
}

variable "container_memory_request" {
  description = "How much memory resource to request"
  type        = string
  default     = "1Gi"
}

variable "container_memory_limit" {
  description = "Upper boundary of memory resource"
  type        = string
  default     = "1Gi"
}

variable "memcached_docker_tag" {
  description = "Tag of memcached Docker image to pull"
  type        = string
  default     = "1.4.25"
}
