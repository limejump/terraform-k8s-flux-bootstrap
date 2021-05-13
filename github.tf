# Generate a keypair. The private key will go to Flux in-cluster, public key
# will be added as a deploy key to the Github repo.

resource "tls_private_key" "flux" {
  count     = var.private_key_pem == null ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 2048
}

data "tls_public_key" "user_provided" {
  count           = var.private_key_pem == null ? 0 : 1
  private_key_pem = var.private_key_pem
}

resource "github_repository_deploy_key" "flux" {
  count      = var.github_install_deploy_key == true ? 1 : 0
  title      = var.github_deploy_key_title
  repository = var.github_repository_name
  read_only  = false
  key        = length(tls_private_key.flux) > 0 ? tls_private_key.flux[0].public_key_openssh : data.tls_public_key.user_provided[0].public_key_openssh
}

output "public_key_openssh" {
  value = length(tls_private_key.flux) > 0 ? tls_private_key.flux[0].public_key_openssh : data.tls_public_key.user_provided[0].public_key_openssh
}
