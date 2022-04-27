resource "github_repository" "frontend" {
  name = "frontend"

  visibility = "public"
  license_template = "bsd-3-clause"

  homepage_url = "https://ilink.dev"

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

resource "github_repository_webhook" "frontend" {
  repository = github_repository.frontend.name

  configuration {
    url          = var.frontend-discord-webhook
    content_type = "json"
    insecure_ssl = false
  }

  events = ["*"]
}
