resource "google_service_account" "external_dns" {
  account_id   = "external-dns-${var.environment}"
  display_name = "Service account for ExternalDNS ${var.environment}"
}

resource "google_project_iam_member" "external_dns" {
  member = "serviceAccount:${google_service_account.external_dns.email}"
  role   = "roles/dns.admin"
}

resource "google_service_account_key" "external_dns" {
  service_account_id = google_service_account.external_dns.name
}

resource "kubernetes_namespace" "external_dns" {
  metadata {
    name = "external-dns"
  }
}

resource "kubernetes_secret" "external_dns" {
  metadata {
    name      = "external-dns"
    namespace = kubernetes_namespace.external_dns.metadata.0.name
  }

  data = {
    "credentials.json" = base64decode(google_service_account_key.external_dns.private_key)
  }
}

resource "helm_release" "external_dns" {
  name       = "external-dns"
  chart      = "external-dns"
  repository = "https://charts.bitnami.com/bitnami"
  namespace  = kubernetes_namespace.external_dns.metadata.0.name

  values = [
    <<-EOF
    provider: google
    google:
      project: "${data.google_client_config.default.project}"
      serviceAccountSecret: "${kubernetes_secret.external_dns.metadata.0.name}"
    txtOwnerId: ".txt"
    txtPrefix: "_ed."
    rbac:
      create: true
    sources:
    - service
    - ingress
    - istio-gateway
    EOF
  ]
}

