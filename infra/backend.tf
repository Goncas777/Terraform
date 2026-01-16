# Secret com todas as variáveis sensíveis da aplicação
resource "kubernetes_secret" "database_credentials" {
  metadata {
    name      = "database-credentials"
    namespace = var.namespace
  }

  type = "Opaque"

  data = {
    SECRET_KEY               = var.secret_key
    ALGORITHM                = var.algorithm
    ACCESS_TOKEN_EXPIRE_MINUTES = var.access_token_expire_minutes

    POSTGRES_DB              = var.db_name
    POSTGRES_USER            = var.db_user
    POSTGRES_PASSWORD        = var.db_password
    DATABASE_HOST            = var.db_host
    DATABASE_PORT            = var.db_port
    DATABASE_NAME            = var.db_name

    ADMIN_EMAIL              = var.admin_email
    ADMIN_PASSWORD           = var.admin_password
    ADMIN_NAME               = var.admin_name
  }
}

# --- Secret já existente: kubernetes_secret.database_credentials ---

# Deployment do backend/API
resource "kubernetes_deployment" "api" {
  metadata {
    name      = "api"
    namespace = var.namespace
    labels = {
      app = "api"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "api"
      }
    }

    template {
      metadata {
        labels = {
          app = "api"
        }
      }

      spec {
        container {
          name  = "cstrader"
          image = var.api_image  # "cstrader:latest" ou imagem do Docker Hub
          image_pull_policy = "Never"

          port {
            container_port = 8000
            name           = "http"
          }

          # Variáveis de ambiente do Secret
          env {
            name = "POSTGRES_USER"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.database_credentials.metadata[0].name
                key  = "POSTGRES_USER"
              }
            }
          }

          env {
            name = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.database_credentials.metadata[0].name
                key  = "POSTGRES_PASSWORD"
              }
            }
          }

          env {
            name = "POSTGRES_DB"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.database_credentials.metadata[0].name
                key  = "POSTGRES_DB"
              }
            }
          }

          env {
            name = "SECRET_KEY"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.database_credentials.metadata[0].name
                key  = "SECRET_KEY"
              }
            }
          }

          env {
            name = "ALGORITHM"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.database_credentials.metadata[0].name
                key  = "ALGORITHM"
              }
            }
          }

          env {
            name  = "DATABASE_DRIVER"
            value = "postgresql"
          }

          env {
            name = "DATABASE_USERNAME"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.database_credentials.metadata[0].name
                key  = "POSTGRES_USER"
              }
            }
          }

          env {
            name = "DATABASE_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.database_credentials.metadata[0].name
                key  = "POSTGRES_PASSWORD"
              }
            }
          }

          env {
            name = "DATABASE_HOST"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.database_credentials.metadata[0].name
                key  = "DATABASE_HOST"
              }
            }
          }

          env {
            name = "DATABASE_PORT"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.database_credentials.metadata[0].name
                key  = "DATABASE_PORT"
              }
            }
          }

          env {
            name = "DATABASE_NAME"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.database_credentials.metadata[0].name
                key  = "DATABASE_NAME"
              }
            }
          }
        }
      }
    }
  }
}

# Service ClusterIP para o backend/API
resource "kubernetes_service" "api" {
  metadata {
    name      = "api"
    namespace = var.namespace
    labels = {
      app = "api"
    }
  }

  spec {
    selector = {
      app = "api"
    }

    port {
      name        = "http"
      port        = 8000
      target_port = 8000
    }

    type = "ClusterIP"
  }
}
