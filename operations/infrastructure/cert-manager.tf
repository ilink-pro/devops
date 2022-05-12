resource "google_service_account" "cert_manager_dns" {
  account_id   = "cert-manager-dns-${var.environment}"
  display_name = "Service account for Cert Manager DNS ${var.environment}"
}

resource "google_project_iam_member" "cert_manager_dns" {
  member = "serviceAccount:${google_service_account.cert_manager_dns.email}"
  role   = "roles/dns.admin"
}

resource "google_service_account_key" "cert_manager" {
  service_account_id = google_service_account.cert_manager_dns.name
}

resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"

    labels = {
      "certmanager.k8s.io/disable-validation" = "true"
    }
  }
}

resource "kubernetes_secret" "cert_manager_credentials" {
  metadata {
    name      = "cert-manager-credentials"
    namespace = kubernetes_namespace.cert_manager.metadata.0.name
  }

  data = {
    "credentials.json" = base64decode(google_service_account_key.cert_manager.private_key)
  }
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  chart      = "cert-manager"
  version    = "v1.6.1"
  repository = "https://charts.jetstack.io"
  namespace  = kubernetes_namespace.cert_manager.metadata.0.name

  values = [
    <<-EOF
    installCRDs: true
    ingressShim:
      defaultIssuerName: letsencrypt
      defaultIssuerKind: ClusterIssuer
      defaultACMEChallengeType: dns01
    EOF
  ]
}

resource "kubectl_manifest" "clusterissuer" {
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt
  namespace: cert-manager
spec:
  acme:
    email: devops@i-link.pro
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: cert-manager-letsencrypt-cluster-issuer
    solvers:
    - dns01:
        cloudDNS:
          project: "${data.google_client_config.default.project}"
          serviceAccountSecretRef:
            name: cert-manager-credentials
            key: credentials.json
YAML
}
