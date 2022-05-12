resource "kubernetes_namespace" "istio_system" {
  metadata {
    name = "istio-system"
  }
}

resource "helm_release" "istio_operator" {
  name  = "istio-operator"
  chart = "./charts/istio-operator"

  values = [
    <<-EOF
    watchedNamespaces: "${kubernetes_namespace.istio_system.metadata.0.name}"
    hub: docker.io/istio
    tag: 1.12.1
    EOF
  ]
}

resource "kubectl_manifest" "istio" {
  yaml_body = <<YAML
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
metadata:
  namespace: "${kubernetes_namespace.istio_system.metadata.0.name}"
  name: istiocontrolplane
spec:
  profile: default

  components:
    ingressGateways:
      - name: istio-ingressgateway
        enabled: true
        k8s:
          service:
            ports:
              - name: status-port
                nodePort: 30498
                port: 15021
                protocol: TCP
                targetPort: 15021
              - name: http2
                nodePort: 30889
                port: 80
                protocol: TCP
                targetPort: 8080
              - name: https
                nodePort: 31287
                port: 443
                protocol: TCP
                targetPort: 8443
              - name: tcp-istiod
                nodePort: 31860
                port: 15012
                protocol: TCP
                targetPort: 15012
              - name: tls
                nodePort: 31602
                port: 15443
                protocol: TCP
                targetPort: 15443
              - name: tunnel1
                nodePort: 31811
                port: 14231
                protocol: TCP
                targetPort: 14231
              - name: tunnel2
                nodePort: 31812
                port: 14232
                protocol: TCP
                targetPort: 14232
              - name: tunnel3
                nodePort: 31813
                port: 14233
                protocol: TCP
                targetPort: 14233
YAML
}
