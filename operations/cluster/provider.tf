terraform {
  backend "remote" {
    organization = "ilink-pro"

    workspaces {
      prefix = "cluster-"
    }
  }
}

provider "google" {
  project = "task-monit-1599295644751"
  region  = "europe-west3"
}

provider "google-beta" {}
