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

Prerequisites:

- `GITHUB_TOKEN` environment variable present with appropriate Github API key
- AWS region and credentials configured via appropriate `provider` block or
    environment variables / config file etc

```hcl
module "flux-bootstrap" {
  source = "github.com/limejump/terraform-k8s-flux-bootstrap"

  eks_cluster_name       = "your-cluster-name-here"
  github_org_name        = "your-org-name-here"
  github_repository_name = "your-repo-name-here"
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
