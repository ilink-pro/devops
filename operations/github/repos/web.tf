resource "github_repository" "web" {
  name = "web"

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

resource "github_repository_webhook" "web" {
  repository = github_repository.web.name

  configuration {
    url          = var.web-discord-webhook
    content_type = "json"
    insecure_ssl = false
  }

  events = ["*"]
}
