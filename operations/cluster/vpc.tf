locals {
  gke_subnet_name = "${var.environment}-gke"
}

module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "4.0.1"

  network_name = var.environment
  project_id   = data.google_client_config.default.project

  subnets = [
    {
      subnet_region = data.google_client_config.default.region
      subnet_name   = local.gke_subnet_name
      subnet_ip     = "10.2.0.0/24"
    },
  ]

  secondary_ranges = {
    "${local.gke_subnet_name}" = [
      {
        range_name    = "pods"
        ip_cidr_range = "10.3.0.0/16"
      },
      {
        range_name    = "services"
        ip_cidr_range = "10.4.0.0/20"
      },
    ],
  }
}
