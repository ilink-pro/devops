resource "github_repository" "ui" {
  name = "ui"

  visibility = "public"
  license_template = "bsd-3-clause"

  homepage_url = "https://ui.ilink.dev"

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

resource "github_repository_webhook" "ui" {
  repository = github_repository.ui.name

  configuration {
    url          = var.ui-discord-webhook
    content_type = "json"
    insecure_ssl = false
  }

  events = ["*"]
}
