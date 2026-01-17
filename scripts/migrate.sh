#!/bin/bash
set -euo pipefail

# Espera pelo pod do Postgres
kubectl wait --for=condition=ready pod -n app --selector=app=postgres --timeout=120s

# Pega o nome do pod do backend (API)
BACKEND_POD=$(kubectl get pods -n app -l app=api -o jsonpath='{.items[0].metadata.name}')

# Executa as migrations dentro do pod do backend
kubectl exec -it "$BACKEND_POD" -n app -- poetry run alembic -c backend/alembic.ini upgrade head

echo "Migrations concluídas!"
