resource "google_service_account" "external_secrets_manager" {
  account_id   = "external-secrets-manager-${var.environment}"
  display_name = "Service account for External Secrets Manager ${var.environment}"
}

resource "google_project_iam_member" "external_secret_manager" {
  member = "serviceAccount:${google_service_account.external_secrets_manager.email}"
  role   = "roles/secretmanager.secretAccessor"
}

resource "google_service_account_key" "external_secrets" {
  service_account_id = google_service_account.external_secrets_manager.name
}

resource "kubernetes_namespace" "external_secrets" {
  metadata {
    name = "external-secrets"
  }
}

resource "kubernetes_secret" "external_secrets_credentials" {
  metadata {
    name      = "external-secrets-credentials"
    namespace = kubernetes_namespace.external_secrets.metadata.0.name
  }

  data = {
    "credentials.json" = base64decode(google_service_account_key.external_secrets.private_key)
  }
}

resource "helm_release" "external_secrets" {
  name       = "external-secrets"
  chart      = "external-secrets"
  version    = "0.3.10"
  repository = "https://charts.external-secrets.io"
  namespace  = kubernetes_namespace.external_secrets.metadata.0.name

  values = [
    <<-EOF
    installCRDs: true
    EOF
  ]
}

resource "kubectl_manifest" "secretstore" {
  yaml_body = <<YAML
apiVersion: external-secrets.io/v1alpha1
kind: ClusterSecretStore
metadata:
  name: gcpsm
  namespace: external-secrets
spec:
  provider:
      gcpsm:
        auth:
          secretRef:
            secretAccessKeySecretRef:
              name: external-secrets-credentials
              key: credentials.json
              namespace: external-secrets
        projectID: "${data.google_client_config.default.project}"       
YAML
}
