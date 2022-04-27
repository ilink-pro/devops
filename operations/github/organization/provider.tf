terraform {
  backend "remote" {
    organization = "ilink"

    workspaces {
      name = "github-organization"
    }
  }
}

provider "github" {
  owner = var.owner
  token = var.token
}
