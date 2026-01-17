#!/usr/bin/env bash
set -e

echo "=== Step 1: Build backend Docker image ==="
docker build -f backend/ops/Dockerfile -t cstrader .

echo "=== Step 2: Build frontend Docker image ==="
docker build -f frontend/Dockerfile -t mynginx frontend

echo "=== Step 3: Ensure Minikube is running ==="
if ! minikube status >/dev/null 2>&1; then
  minikube start --driver=docker
fi

minikube addons enable ingress
minikube addons enable registry

echo "=== Step 4: Load images into Minikube ==="
minikube image load cstrader:latest
minikube image load mynginx:latest

echo "=== Step 5: Enter infra directory ==="
cd infra

echo "=== Step 6: Terraform init ==="
terraform init

echo "=== Step 7: Terraform plan ==="
terraform plan -out=tfplan

echo "=== Step 8: Terraform apply ==="
terraform apply tfplan

echo "=== Done! ==="
