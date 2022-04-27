resource "github_repository" "devops" {
  name = "devops"

  visibility = "public"
  license_template = "bsd-3-clause"

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

resource "github_repository_webhook" "devops" {
  repository = github_repository.devops.name

  configuration {
    url          = var.devops-discord-webhook
    content_type = "json"
    insecure_ssl = false
  }

  events = ["*"]
}
