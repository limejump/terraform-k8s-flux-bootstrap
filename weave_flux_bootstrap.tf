# The cluster will use a GitOps repo for Kubernetes configuration. this file
# will bootstrap the configuration of Flux such that all the manifests from the
# repository will be automatically applied when the cluster is created.

data "aws_eks_cluster" "cluster" {
  name = var.eks_cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.eks_cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
}

locals {
  k8s-ns = "flux"
  flux_additional_arguments = [
    for key in keys(var.flux_args_extra) :
    "--${key}=${var.flux_args_extra[key]}"
  ]
}

resource "kubernetes_namespace" "flux" {
  metadata {
    name = local.k8s-ns
  }

  depends_on = [kubernetes_namespace.flux]
}

resource "kubernetes_service_account" "flux" {
  metadata {
    name      = "flux"
    namespace = local.k8s-ns

    labels = {
      name = "flux"
    }
  }

  automount_service_account_token = true

  depends_on = [kubernetes_namespace.flux]
}

resource "kubernetes_cluster_role" "flux" {
  metadata {
    name = "flux"

    labels = {
      name = "flux"
    }
  }

  rule {
    api_groups = ["*"]
    resources  = ["*"]
    verbs      = ["*"]
  }

  rule {
    non_resource_urls = ["*"]
    verbs             = ["*"]
  }

  depends_on = [kubernetes_namespace.flux]
}

resource "kubernetes_cluster_role_binding" "flux" {
  metadata {
    name = "flux"

    labels = {
      name = "flux"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "flux"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "flux"
    namespace = local.k8s-ns
    api_group = ""
  }

  depends_on = [
    kubernetes_namespace.flux,
    kubernetes_cluster_role.flux,
    kubernetes_service_account.flux,
  ]
}

resource "kubernetes_config_map" "root_sshdir" {
  metadata {
    name      = "flux-root-sshdir"
    namespace = local.k8s-ns

    labels = {
      name = "flux"
    }
  }
  data = {
    "known_hosts" = join("\n", var.flux_known_hosts)
  }

  depends_on = [
    kubernetes_namespace.flux,
  ]
}

resource "kubernetes_deployment" "flux" {
  metadata {
    name      = "flux"
    namespace = local.k8s-ns
    labels    = var.flux_deployment_labels
  }

  spec {
    selector {
      match_labels = {
        name = "flux"
      }
    }

    strategy {
      type = "Recreate"
    }

    template {
      metadata {
        labels      = var.flux_deployment_labels
        annotations = var.flux_deployment_annotations
      }

      spec {
        service_account_name = "flux"

        # See the following GH issue for why we have to do this manually
        # https://github.com/terraform-providers/terraform-provider-kubernetes/issues/38
        volume {
          name = kubernetes_service_account.flux.default_secret_name

          secret {
            secret_name = kubernetes_service_account.flux.default_secret_name
          }
        }

        volume {
          name = "git-key"

          secret {
            secret_name  = "flux-git-deploy"
            default_mode = "0400"
          }
        }

        volume {
          name = "git-keygen"

          empty_dir {
            medium = "Memory"
          }
        }

        volume {
          name = "root-sshdir"
          config_map {
            name         = kubernetes_config_map.root_sshdir.metadata[0].name
            default_mode = "0600"
          }
        }

        container {
          name  = "flux"
          image = "docker.io/fluxcd/flux:${var.flux_docker_tag}"

          # See the following GH issue for why we have to do this manually
          # https://github.com/terraform-providers/terraform-provider-kubernetes/issues/38
          volume_mount {
            mount_path = "/var/run/secrets/kubernetes.io/serviceaccount"
            name       = kubernetes_service_account.flux.default_secret_name
            read_only  = true
          }

          volume_mount {
            name       = "git-key"
            mount_path = "/etc/fluxd/ssh"
            read_only  = true
          }

          volume_mount {
            name       = "git-keygen"
            mount_path = "/var/fluxd/keygen"
          }

          volume_mount {
            name       = "root-sshdir"
            mount_path = "/root/.ssh"
            read_only  = true
          }

          args = concat([
            "${var.deploy_memcached ? "--memcached-service=memcached" : "--registry-disable-scanning"}",
            "--ssh-keygen-dir=/var/fluxd/keygen",
            "--git-url=${data.github_repository.flux-repo.ssh_clone_url}",
            "--git-branch=${var.github_repository_branch}",
          ], local.flux_additional_arguments)

          liveness_probe {
            failure_threshold     = 3
            initial_delay_seconds = 5
            period_seconds        = 10
            success_threshold     = 1
            timeout_seconds       = 5

            http_get {
              path   = "/api/flux/v6/identity.pub"
              port   = 3030
              scheme = "HTTP"
            }
          }

          readiness_probe {
            failure_threshold     = 3
            initial_delay_seconds = 5
            period_seconds        = 10
            success_threshold     = 1
            timeout_seconds       = 5

            http_get {
              path   = "/api/flux/v6/identity.pub"
              port   = 3030
              scheme = "HTTP"
            }
          }

          port {
            container_port = 3030
            host_port      = 0
            protocol       = "TCP"
          }

          resources {
            limits {
              cpu    = "1"
              memory = "1Gi"
            }
            requests {
              cpu    = "250m"
              memory = "1Gi"
            }
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_cluster_role_binding.flux,
    kubernetes_secret.flux-git-deploy,
  ]
}

resource "kubernetes_secret" "flux-git-deploy" {
  metadata {
    name      = "flux-git-deploy"
    namespace = local.k8s-ns
  }

  type = "Opaque"

  data = {
    identity = length(tls_private_key.flux) > 0 ? tls_private_key.flux[0].private_key_pem : var.private_key_pem
  }

  depends_on = [kubernetes_namespace.flux]
}

resource "kubernetes_deployment" "memcached" {
  count = var.deploy_memcached ? 1 : 0

  metadata {
    name      = "memcached"
    namespace = local.k8s-ns
  }

  spec {
    selector {
      match_labels = {
        name = "memcached"
      }
    }

    template {
      metadata {
        labels = {
          name = "memcached"
        }
      }

      spec {
        container {
          name  = "memcached"
          image = "memcached:${var.memcached_docker_tag}"

          port {
            name           = "clients"
            container_port = 11211
          }
        }
      }
    }
  }

  depends_on = [kubernetes_namespace.flux]
}

resource "kubernetes_service" "memcached" {
  count = var.deploy_memcached ? 1 : 0

  metadata {
    name      = "memcached"
    namespace = local.k8s-ns
  }

  spec {
    port {
      name = "memcached"
      port = 11211
    }

    selector = {
      name = "memcached"
    }
  }

  depends_on = [kubernetes_namespace.flux]
}
