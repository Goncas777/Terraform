# 1️⃣ ConfigMap para Nginx
resource "kubernetes_config_map_v1" "frontend_nginx_config" {
  metadata {
    name      = "frontend-nginx-config"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  data = {
    "default.conf" = <<EOF
server {
    listen 80;
    server_name localhost;

    # Definir tipos MIME
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    # Proxy para API - PRIORITY 1 (exact path match, highest priority)
    location /api/ {
        proxy_pass http://api:8000/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_http_version 1.1;
    }

    # Servir arquivos estáticos - PRIORITY 2 (regex match)
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot|html|json)$$ {
        root /usr/share/nginx/html;
        expires 1d;
        add_header Cache-Control "public, immutable";
    }

    # Servir raiz - PRIORITY 3 (root location)
    location = / {
        root /usr/share/nginx/html;
        try_files /index.html =404;
    }

    # Servir frontend SPA para subpastas - PRIORITY 4
    location / {
        root /usr/share/nginx/html;
        try_files \$uri \$uri/ /index.html;
    }

    # Páginas de erro
    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
        root /usr/share/nginx/html;
    }
}
EOF
  }
}

# 2️⃣ Deployment do frontend
resource "kubernetes_deployment" "frontend" {
  metadata {
    name      = "frontend"
    namespace = kubernetes_namespace.app.metadata[0].name
    labels = {
      app = "frontend"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "frontend"
      }
    }

    template {
      metadata {
        labels = {
          app = "frontend"
        }
      }

      spec {
        container {
          name              = "mynginx"
          image             = "mynginx:latest"
          image_pull_policy = "Never"

          port {
            container_port = 80
          }

          volume_mount {
            name       = "nginx-config"
            mount_path = "/etc/nginx/conf.d"
          }
        }

        volume {
          name = "nginx-config"

          config_map {
            name = kubernetes_config_map_v1.frontend_nginx_config.metadata[0].name
          }
        }
      }
    }
  }
}

# 3️⃣ Service do frontend
resource "kubernetes_service_v1" "frontend_service" {
  metadata {
    name      = "frontend-service"
    namespace = kubernetes_namespace.app.metadata[0].name
    labels = {
      app  = "frontend"
      tier = "frontend"
    }
  }

  spec {
    type = "ClusterIP" # em vez de NodePort
    selector = {
      app = kubernetes_deployment.frontend.metadata[0].labels["app"]
    }

    port {
      name        = "http"
      port        = 3000
      target_port = 80
    }
  }
}
