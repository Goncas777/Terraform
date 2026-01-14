resource "minikube_cluster" "my_cluster" {
  cluster_name = var.client
  nodes = 3
}

resource "kubernetes_namespace_v1" "app" {
  metadata {
    name = "app"
  }
}
