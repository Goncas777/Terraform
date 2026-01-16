# Cluster
variable "client" {
  description = "Name of the Kubernetes cluster"
  type        = string
  default     = "k8s-3tier"
}

# Namespace
variable "namespace" {
  description = "Namespace for application resources"
  type        = string
  default     = "app"
}

# Backend / API
variable "api_image" {
  description = "Docker image for backend API"
  type        = string
  default     = "cstrader:latest"
}

variable "frontend_image" {
  description = "Docker image for frontend"
  type        = string
  default     = "mynginx:latest"
}

# Database credentials
variable "db_user" {
  description = "PostgreSQL username"
  type        = string
}

variable "db_password" {
  description = "PostgreSQL password"
  type        = string
}

variable "db_name" {
  description = "PostgreSQL database name"
  type        = string
}

variable "db_host" {
  description = "PostgreSQL host"
  type        = string
}

variable "db_port" {
  description = "PostgreSQL port"
  type        = string
  default     = "5432"
}

variable "secret_key" {
  description = "Secret key for backend"
  type        = string
}

variable "algorithm" {
  description = "Algorithm used in backend"
  type        = string
  default     = "HS256"
}

variable "admin_email" {
  description = "Admin email"
  type        = string
}

variable "admin_password" {
  description = "Admin password"
  type        = string
}

variable "admin_name" {
  description = "Admin name"
  type        = string
}

variable "access_token_expire_minutes" {
  description = "Access token expiration time"
  type        = string
  default     = "120"
}