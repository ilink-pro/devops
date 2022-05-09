output "flux_deploy_key" {
  value = tls_private_key.main.public_key_openssh
}
