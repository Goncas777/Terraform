# Makefile para executar apply, migrate e test em sequência
# Inclui chmod automático para todos os scripts na pasta scripts/

.PHONY: all chmod apply migrate test run destroy

# Comando padrão
all: run

# Dá permissão de execução a todos os scripts
chmod:
	@echo "=== Definindo permissões de execução nos scripts ==="
	chmod +x scripts/apply.sh scripts/migrate.sh scripts/test.sh scripts/destroy.sh

# Build e deploy
apply: chmod
	@echo "=== Executando apply.sh ==="
	scripts/apply.sh

# Executa migrations
migrate: chmod
	@echo "=== Executando migrate.sh ==="
	scripts/migrate.sh

# Executa teste de API via frontend pod
test: chmod
	@echo "=== Executando test.sh ==="
	scripts/test.sh

# Executa tudo em sequência: apply -> migrate -> test
run: chmod apply migrate test
	@echo "=== Tudo concluído! ==="

# Destroy da infraestrutura
destroy: chmod
	@echo "=== Executando destroy.sh ==="
	scripts/destroy.sh
