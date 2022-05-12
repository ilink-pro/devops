resource "google_service_account" "flux_gcr_sync" {
  account_id   = "flux-gcr-sync-${var.environment}"
  display_name = "Service account for Flux Gcr ${var.environment}"
}

resource "google_project_iam_member" "flux_gcr_sync" {
  member = "serviceAccount:${google_service_account.flux_gcr_sync.email}"
  role   = "roles/storage.objectViewer"
}

resource "google_service_account_key" "flux_gcr_sync" {
  service_account_id = google_service_account.flux_gcr_sync.name
}

resource "kubernetes_secret" "flux_sync_gcr" {
  metadata {
    name = "flux-sync-gcr"
    namespace = data.flux_sync.main.namespace
  }

  data = {
    ".dockerconfigjson" = jsonencode({
      "auths" = {
        "eu.gcr.io" = {
          "username" = "_json_key",
          "password" = base64decode(google_service_account_key.flux_gcr_sync.private_key),
          "auth"     = base64encode("_json_key:${base64decode(google_service_account_key.flux_gcr_sync.private_key)}")
        }
      }
    })
  }

  type = "kubernetes.io/dockerconfigjson"
}
