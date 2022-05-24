terraform {
  backend "remote" {
    organization = "ilink-pro"

    workspaces {
      name = "organization"
    }
  }
}

provider "github" {
  owner = var.owner
  token = var.token
}
