output "vpc" {
  value = module.vpc
}

output "gke_auth" {
  value     = module.gke_auth
  sensitive = true
}
