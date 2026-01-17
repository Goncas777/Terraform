resource "kubernetes_ingress_v1" "myingress" {
  metadata {
    name      = "myingress"
    namespace = "app"
    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target" = "/$2"
      "nginx.ingress.kubernetes.io/use-regex"      = "true"
    }
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      http {
        path {
          path     = "/api(/|$)(.*)"
          path_type = "ImplementationSpecific"

          backend {
            service {
              name = kubernetes_service.api.metadata[0].name
              port {
                number = 8000
              }
            }
          }
        }

        path {
          path     = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service_v1.frontend_service.metadata[0].name
              port {
                number = 3000
              }
            }
          }
        }
      }
    }
  }
}
