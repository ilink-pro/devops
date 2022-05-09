resource "google_service_account" "flux_image_reflector" {
  account_id   = "flux-image-reflector-${var.environment}"
  display_name = "Service account for Flux Gcr"
}

resource "google_service_account_iam_member" "flux_image_reflector" {
  service_account_id = google_service_account.flux_image_reflector.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${data.google_client_config.default.project}.svc.id.goog[flux-system/image-reflector-controller]"
}

resource "google_project_iam_member" "flux_image_reflector" {
  member = "serviceAccount:${google_service_account.flux_image_reflector.email}"
  role   = "roles/storage.objectViewer"
}

locals {
  flux_branch = "main"
  flux_path   = "specs/${var.environment}"
  known_hosts = "github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg="
  patches     = {
    image-reflector-sa = <<EOT
apiVersion: v1
kind: ServiceAccount
metadata:
  name: image-reflector-controller
  namespace: flux-system
  annotations:
    iam.gke.io/gcp-service-account: ${google_service_account.flux_image_reflector.email}
EOT
  }
}

data "flux_install" "main" {
  target_path = local.flux_path
  components  = ["source-controller", "kustomize-controller", "helm-controller", "notification-controller", "image-reflector-controller", "image-automation-controller"]
  version     = "v0.28.2"
}

data "flux_sync" "main" {
  target_path = local.flux_path
  branch      = local.flux_branch
  url         = "ssh://git@github.com/ilink-pro/devops.git"
  patch_names = keys(local.patches)
}

resource "kubernetes_namespace" "flux_system" {
  metadata {
    name = "flux-system"
  }

  lifecycle {
    ignore_changes = [
      metadata[0].labels,
    ]
  }
}

data "kubectl_file_documents" "install" {
  content = data.flux_install.main.content
}

data "kubectl_file_documents" "sync" {
  content = data.flux_sync.main.content
}

locals {
  install = [for v in data.kubectl_file_documents.install.documents : {
    data : yamldecode(v)
    content : v
    }
  ]
  sync = [for v in data.kubectl_file_documents.sync.documents : {
    data : yamldecode(v)
    content : v
    }
  ]
}

resource "kubectl_manifest" "install" {
  for_each   = { for v in local.install : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
  depends_on = [kubernetes_namespace.flux_system]
  yaml_body  = each.value
}

resource "kubectl_manifest" "sync" {
  for_each   = { for v in local.sync : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
  depends_on = [kubernetes_namespace.flux_system]
  yaml_body  = each.value
}

resource "tls_private_key" "main" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "kubernetes_secret" "main" {
  depends_on = [kubectl_manifest.install]

  metadata {
    name      = data.flux_sync.main.name
    namespace = data.flux_sync.main.namespace
  }

  data = {
    identity       = tls_private_key.main.private_key_pem
    "identity.pub" = tls_private_key.main.public_key_pem
    known_hosts    = local.known_hosts
  }
}

resource "github_repository_file" "install" {
  repository = "infrastructure"
  file       = data.flux_install.main.path
  content    = data.flux_install.main.content
  branch     = local.flux_branch
}

resource "github_repository_file" "sync" {
  repository = "infrastructure"
  file       = data.flux_sync.main.path
  content    = data.flux_sync.main.content
  branch     = local.flux_branch
}

resource "github_repository_file" "kustomize" {
  repository          = "infrastructure"
  file                = data.flux_sync.main.kustomize_path
  branch              = local.flux_branch
  overwrite_on_create = true
  content             =  <<EOT
${data.flux_sync.main.kustomize_content}
patches:
- target:
    version: v1
    group: apps
    kind: Deployment
    name: image-reflector-controller
    namespace: flux-system
  patch: |-
    - op: add
      path: /spec/template/spec/containers/0/args/-
      value: --gcp-autologin-for-gcr    
EOT
}

resource "github_repository_file" "patches" {
  for_each   = data.flux_sync.main.patch_file_paths

  repository = "infrastructure"
  file       = each.value
  content    = local.patches[each.key]
  branch     = local.flux_branch
}
