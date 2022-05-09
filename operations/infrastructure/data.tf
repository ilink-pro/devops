data "terraform_remote_state" "cluster" {
  backend = "remote"

  config = {
    organization = "ilink-pro"

    workspaces = {
      name = "cluster-${var.environment}"
    }
  }
}

data "google_client_config" "default" {
}
