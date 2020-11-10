# terraform-k8s-flux-bootstrap

This Terraform module will bootstrap [Weaveworks Flux][1] on a Kubernetes
cluster by doing the following things:

- Create an RSA key to be used by Flux
- Store the private key as a Kubernetes Secret
- Add the public key to the config repo in Github as a [deploy key][2]
- Configure RBAC rules and deploy flux + memcached to the cluster


## Current Limitations

- Only supports Github for the config repo (and may only work for org repos)
- Assumes the Kubernetes is an Amazon [EKS][3] cluster
- Only supports deploying to the 'flux' namespace (but will be
    automatically created)


## Usage

Providers for GitHub and Kubernetes must be configured before calling the
module.

```hcl
# `GITHUB_TOKEN` env var should be set if you don't provide it in here
provider "github" {
  organization = "my-org"
}

# Example for an AWS EKS Cluster:
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
}

module "flux-bootstrap" {
  source = "github.com/limejump/terraform-k8s-flux-bootstrap?ref=vx.y.z"

  github_repository_name = "my-gitops-repo"

  flux_args_extra = {
      git-path = "foo/bar"
      git-email = "flux@example.com"
  }
}
```


## FAQ

#### What about the Flux Helm Operator

The easiest thing to do is to add the [manifests][4] for the Helm Operator to
your flux config repo. This way, once Flux is up and running it will
automatically deploy the Helm component! You can also deploy Tiller like this!


[1]: https://github.com/weaveworks/flux/
[2]: https://developer.github.com/v3/guides/managing-deploy-keys/#deploy-keys
[3]: https://aws.amazon.com/eks/
[4]: https://github.com/weaveworks/flux/tree/master/deploy-helm
