terraform {
  backend "remote" {
    organization = "ilink"

    workspaces {
      name = "github-repos"
    }
  }
}

provider "github" {
  owner = var.owner
  token = var.token
}
