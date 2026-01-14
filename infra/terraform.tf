terraform {
  required_providers {
    minikube = {
      source  = "scott-the-programmer/minikube"
      version = "0.6.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.0.1"
    }
  }
}

provider "minikube" {}

provider "kubernetes" {
  host                   = minikube_cluster.my_cluster.host
  client_certificate     = minikube_cluster.my_cluster.client_certificate
  client_key             = minikube_cluster.my_cluster.client_key
  cluster_ca_certificate = minikube_cluster.my_cluster.cluster_ca_certificate
}
