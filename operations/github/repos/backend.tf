resource "github_repository" "backend" {
  name = "backend"

  visibility = "public"
  license_template = "bsd-3-clause"

  homepage_url = "https://api.ilink.dev"

  auto_init = true

  has_wiki = true
  has_issues = true
  has_projects = false

  delete_branch_on_merge = true

  template {
    owner      = var.owner
    repository = "template"
  }
}

resource "github_repository_webhook" "backend" {
  repository = github_repository.backend.name

  configuration {
    url          = var.backend-discord-webhook
    content_type = "json"
    insecure_ssl = false
  }

  events = ["*"]
}
