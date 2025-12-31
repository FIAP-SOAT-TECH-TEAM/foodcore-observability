#!/bin/bash

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
PROJECT_ROOT=$(dirname "$SCRIPT_DIR")

echo "===== Iniciando infraestrutura ====="

# Verificar se o Docker está rodando
check_docker() {
  docker info &>/dev/null
  return $?
}

if ! check_docker; then
  echo "ERRO: O Docker não está rodando."
  echo "Inicie o Docker e tente novamente."
  exit 1
fi

# Ir para o diretório docker
cd "$PROJECT_ROOT/docker" || {
  echo "ERRO: Diretório docker não encontrado."
  exit 1
}

# Iniciar Zipkin
echo "-> Iniciando Zipkin..."
docker compose up -d zipkin

ZIPKIN_RETRIES=15
ZIPKIN_COUNT=0
while [ $ZIPKIN_COUNT -lt $ZIPKIN_RETRIES ]; do
  STATUS=$(docker inspect --format='{{.State.Status}}' foodcore-zipkin 2>/dev/null)
  if [ "$STATUS" = "running" ]; then
    echo "-> Zipkin está em execução!"
    break
  fi
  ZIPKIN_COUNT=$((ZIPKIN_COUNT + 1))
  echo "Aguardando Zipkin... ($ZIPKIN_COUNT/$ZIPKIN_RETRIES)"
  sleep 2
done

# Iniciar Prometheus
echo "-> Iniciando Prometheus..."
docker compose up -d prometheus

PROM_RETRIES=15
PROM_COUNT=0
while [ $PROM_COUNT -lt $PROM_RETRIES ]; do
  STATUS=$(docker inspect --format='{{.State.Status}}' foodcore-prometheus 2>/dev/null)
  if [ "$STATUS" = "running" ]; then
    echo "-> Prometheus está em execução!"
    break
  fi
  PROM_COUNT=$((PROM_COUNT + 1))
  echo "Aguardando Prometheus... ($PROM_COUNT/$PROM_RETRIES)"
  sleep 2
done

echo
echo "===== Infraestrutura iniciada com sucesso ====="
echo
echo "Serviços disponíveis:"
echo "- Zipkin"
echo "- Prometheus"
echo
echo "Use 'docker compose ps' para verificar o status."