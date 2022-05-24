terraform {
  backend "remote" {
    organization = "ilink-pro"

    workspaces {
      name = "repos"
    }
  }
}

provider "github" {
  owner = var.owner
  token = var.token
}
