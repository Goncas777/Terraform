terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.0.1"
    }
  }
}

# Usar o cluster Minikube já existente
provider "kubernetes" {
  config_path = "~/.kube/config"
}
