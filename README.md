# Marketplace de Skins de CS2

Este projeto é um **marketplace de skins de CS2** construído com **backend em Python (FastAPI)** e **frontend SPA em Nginx**, orquestrado com **Terraform + Kubernetes**, rodando em um **Dev Container Kubernetes Minikube dentro do Docker**.

---

## Executando o Projeto

### 1️⃣ Ambiente (Dev Container + Minikube in Docker)
Pensado para rodar dentro de um **Dev Container** com **Minikube usando o driver Docker**. Nesse ambiente já há Docker, kubectl, Terraform e Make instalados.

### 2️⃣ Subir tudo com Terraform + Kubernetes
1. **Build das imagens locais** (imagePullPolicy: Never)
	```bash
	docker build -f frontend/Dockerfile -t mynginx frontend
	docker build -f backend/ops/Dockerfile -t cstrader .
	minikube image load mynginx cstrader
	```
2. **Provisionar Kubernetes via Terraform**
	```bash
	cd infra
	terraform init
	terraform apply -auto-approve
	```
3. **Rodar migrations do backend**
	```bash
	BACKEND_POD=$(kubectl get pods -n app -l app=api -o jsonpath='{.items[0].metadata.name}')
	kubectl exec -n app -it "$BACKEND_POD" -- poetry run alembic -c backend/alembic.ini upgrade head
	```
4. **Acessar o frontend (port-forward)**
	```bash
	kubectl port-forward svc/frontend-service -n app 8080:3000
	```
	Abra: http://localhost:8080

### 3️⃣ Pipeline via scripts (atalhos)
```bash
scripts/apply.sh     # build (imagens locais) + terraform apply + port-forward
scripts/migrate.sh   # executa migrations no pod do backend
scripts/test.sh      # faz teste simples de registro via pod
scripts/destroy.sh   # terraform destroy + limpar cluster
```

### 4️⃣ Pipeline completa via Makefile
```bash
make run         # start-cluster + build imagens + deploy k8s + migrations + teste
```
> Observação: o Makefile assume o cluster Minikube rodando no dev container e usa as imagens locais com cache do Minikube.

### 5️⃣ Checagens rápidas
```bash
kubectl get pods -n app
kubectl logs -n app -l app=frontend --tail=20
kubectl logs -n app -l app=api --tail=20
```

### 6️⃣ Se algo der errado
- Hard refresh no navegador (Ctrl+Shift+R) após atualizar o frontend.
- Reaplique só o ConfigMap do Nginx: `terraform apply -target=kubernetes_config_map_v1.frontend_nginx_config -auto-approve`.
- Se mudar HTML/JS/CSS: `docker build -f frontend/Dockerfile -t mynginx frontend && minikube image load mynginx && kubectl rollout restart deployment/frontend -n app`.

---

## O que mudou com Terraform + Kubernetes

- **Orquestração infra-as-code:** antes os manifests Kubernetes eram aplicados manualmente; agora ficam declarados em `infra/` e são criados/atualizados pelo `terraform apply`.
- **Recursos reaproveitados:** Deployments, Services, ConfigMaps (Nginx), Secrets e Ingress continuam os mesmos objetos Kubernetes — apenas passaram a ser geridos pelo Terraform.
- **Imagens e build:** continuam as mesmas (frontend `mynginx`, backend `cstrader`). A política `imagePullPolicy: Never` segue exigindo `minikube image load` para usar as imagens locais.
- **Configuração Nginx:** o ConfigMap segue a mesma base usada no cluster Kubernetes manual; a diferença é que agora é versionado/aplicado via Terraform.
- **Migrations e fluxo de app:** nada mudou no backend ou nas migrations Alembic;
- **Operação diária:** port-forward, inspeção de logs e testes via pods continuam iguais; apenas o provisionamento/destruição do cluster passou a ser automatizado.

### Por que usar Terraform + Kubernetes em vez de só Kubernetes
- **Estado versionado e reproduzível:** Terraform mantém o estado da infraestrutura, evitando drift entre ambientes e facilitando reproduzir o cluster.
- **Mudanças auditáveis:** alterações passam por código e podem ser revisadas/PR, em vez de `kubectl apply` solto.
- **Plan antes de aplicar:** é possivel ver o que vai mudar (`terraform plan`) antes de executar, reduzindo riscos.
- **Rollback facilitado:** o state registra recursos criados; destruir ou recriar é previsível (`terraform destroy/apply`).
- **Reuso e módulos:** componentes podem virar módulos reutilizáveis (ingress, deployments, secrets), simplificando futuras evoluções.

---

## Executando o Projeto

### 1️⃣ Pipeline completa com Makefile

O `Makefile` facilita a execução completa:

```bash
# Executa build, deploy, migrations e teste da API
make run

# Deploy completo
scripts/apply.sh

# Migrations do backend
scripts/migrate.sh

# Teste de criação de usuário via frontend pod
scripts/test.sh

# Destruir a infraestrutura
scripts/destroy.sh
