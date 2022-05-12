resource "github_repository" "dsm" {
  name = "dsm"

  visibility = "public"
  license_template = "bsd-3-clause"

  homepage_url = "https://dsm.ilink.dev"

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

resource "github_repository_webhook" "dsm" {
  repository = github_repository.dsm.name

  configuration {
    url          = var.web-discord-webhook
    content_type = "json"
    insecure_ssl = false
  }

  events = ["*"]
}
