terraform {
  backend "remote" {
    organization = "ilink-pro"

    workspaces {
      prefix = "infrastructure-"
    }
  }
}

provider "google" {
  project = "task-monit-1599295644751"
  region  = "europe-west3"
}

provider "google-beta" {}

provider "tls" {}

provider "kubernetes" {
  host                   = data.terraform_remote_state.cluster.outputs.gke_auth.host

  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = data.terraform_remote_state.cluster.outputs.gke_auth.cluster_ca_certificate
}

provider "helm" {
  kubernetes {
    host                   = data.terraform_remote_state.cluster.outputs.gke_auth.host

    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = data.terraform_remote_state.cluster.outputs.gke_auth.cluster_ca_certificate
  }
}

provider "kubectl" {
  load_config_file = false

  host                   = data.terraform_remote_state.cluster.outputs.gke_auth.host

  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = data.terraform_remote_state.cluster.outputs.gke_auth.cluster_ca_certificate
}

provider "flux" {}

provider "github" {
  owner = "ilink-pro"
}
