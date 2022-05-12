terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.90.1"
    }

    google-beta = {
      source  = "hashicorp/google-beta"
      version = "3.90.1"
    }

    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.7.1"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.13.1"
    }

    helm = {
      source = "hashicorp/helm"
      version = "2.4.1"
    }

    flux = {
      source  = "fluxcd/flux"
      version = ">= 0.11.2"
    }

    tls = {
      source = "hashicorp/tls"
      version = "3.1.0"
    }
  }
}
