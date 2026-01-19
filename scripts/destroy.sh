#!/bin/bash
set -euo pipefail

echo "=== Entrando no diretório infra ==="
cd infra

echo "=== Executando Terraform destroy ==="
terraform destroy -auto-approve

echo "=== Destroy completo ==="
