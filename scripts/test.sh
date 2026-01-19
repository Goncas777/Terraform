#!/bin/bash
set -euo pipefail

# Espera até que pelo menos um pod frontend esteja Running
echo "Aguardando pod frontend estar pronto..."
kubectl wait --for=condition=ready pod -n app --selector=app=frontend --timeout=120s

# Pega o nome de um pod frontend que esteja Running
FRONTEND_POD=$(kubectl get pods -n app -l app=frontend \
  --field-selector=status.phase=Running \
  -o jsonpath='{.items[0].metadata.name}')

echo "Usando pod frontend: $FRONTEND_POD"

# Executa o curl de teste dentro do pod frontend
kubectl exec -it -n app "$FRONTEND_POD" -- curl -s -X POST http://api:8000/register_user \
  -H "Content-Type: application/json" \
  -d '{"name": "Teste", "email": "testa@tesat.com", "password": "Secure1!"}'

echo
echo "Teste concluído!"

kubectl port-forward svc/frontend-service -n app 8080:3000