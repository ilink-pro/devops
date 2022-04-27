resource "github_repository" "template" {
  name = "template"

  visibility  = "public"

  has_wiki      = false
  has_issues    = true
  has_projects  = false

  auto_init = true

  is_template = true

  license_template = "bsd-3-clause"

  delete_branch_on_merge = true
}

resource "github_repository_webhook" "template" {
  repository = github_repository.template.name

  configuration {
    url          = var.devops-discord-webhook
    content_type = "json"
    insecure_ssl = false
  }

  events = ["*"]
}
