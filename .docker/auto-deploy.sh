#!/bin/bash
# Script de auto-deploy para containers via webhook do GitHub Actions
# Deve ser executado pelo usuário 'deploy'

set -e

# Configuração
COMPOSE_DIR="/opt/compose"
LOG_DIR="/opt/logs"
ENVIRONMENT="${1:-}"

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
  echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_DIR/$ENVIRONMENT/deploy.log"
}

log_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_DIR/$ENVIRONMENT/deploy.log"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_DIR/$ENVIRONMENT/deploy.log"
}

log_warning() {
  echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_DIR/$ENVIRONMENT/deploy.log"
}

# Validar argumentos
if [ -z "$ENVIRONMENT" ] || [ "$ENVIRONMENT" != "homo" ] && [ "$ENVIRONMENT" != "prod" ]; then
  echo "Uso: $0 {homo|prod}"
  echo ""
  echo "Ambientes válidos:"
  echo "  homo - Ambiente de homologação"
  echo "  prod - Ambiente de produção"
  exit 1
fi

# Configurar variáveis baseado no ambiente
if [ "$ENVIRONMENT" == "homo" ]; then
  BACKEND_IMAGE="ghcr.io/univesp-pi-2/backend:homo-latest"
  FRONTEND_IMAGE="ghcr.io/univesp-pi-2/frontend:homo-latest"
  BACKEND_COMPOSE="homologacao-compose.yml"
  FRONTEND_COMPOSE="homologacao-compose.yml"
  BACKEND_DIR="/opt/compose/backend"
  FRONTEND_DIR="/opt/compose/frontend"
  CONTAINER_PREFIX="homo"
else
  BACKEND_IMAGE="ghcr.io/univesp-pi-2/backend:latest"
  FRONTEND_IMAGE="ghcr.io/univesp-pi-2/frontend:latest"
  BACKEND_COMPOSE="producao-compose.yml"
  FRONTEND_COMPOSE="producao-compose.yml"
  BACKEND_DIR="/opt/compose/backend"
  FRONTEND_DIR="/opt/compose/frontend"
  CONTAINER_PREFIX="prod"
fi

# Criar diretório de log
mkdir -p "$LOG_DIR/$ENVIRONMENT"

log_info "=========================================="
log_info "Iniciando deploy $ENVIRONMENT"
log_info "=========================================="
log_info "Timestamp: $(date)"

# Validar se arquivo .env existe
if [ ! -f "$COMPOSE_DIR/.env" ]; then
  log_error "Arquivo $COMPOSE_DIR/.env não encontrado!"
  exit 1
fi

# Fazer login no GHCR
log_info "Fazendo login no GitHub Container Registry..."
if [ -z "$GHCR_TOKEN" ]; then
  log_warning "GHCR_TOKEN não definido. Pulando login."
else
  echo "$GHCR_TOKEN" | docker login -u "$GHCR_USERNAME" --password-stdin ghcr.io 2>/dev/null || true
  log_success "Login realizado"
fi

# Deploy Backend
log_info "Iniciando deploy do Backend..."
cd "$BACKEND_DIR" || { log_error "Diretório $BACKEND_DIR não encontrado"; exit 1; }

log_info "Pulling imagem: $BACKEND_IMAGE"
if docker pull "$BACKEND_IMAGE" 2>&1 | tee -a "$LOG_DIR/$ENVIRONMENT/backend-pull.log"; then
  log_success "Imagem backend baixada com sucesso"
else
  log_error "Falha ao baixar imagem backend"
  exit 1
fi

log_info "Parando containers backend antigos..."
docker compose -f "$BACKEND_COMPOSE" --env-file "$COMPOSE_DIR/.env" down || true

log_info "Iniciando novos containers backend..."
if docker compose -f "$BACKEND_COMPOSE" --env-file "$COMPOSE_DIR/.env" up -d --no-build 2>&1 | tee -a "$LOG_DIR/$ENVIRONMENT/backend-up.log"; then
  log_success "Containers backend iniciados"
else
  log_error "Falha ao iniciar containers backend"
  exit 1
fi

# Aguardar um pouco para backend estar pronto
sleep 5

# Deploy Frontend
log_info "Iniciando deploy do Frontend..."
cd "$FRONTEND_DIR" || { log_error "Diretório $FRONTEND_DIR não encontrado"; exit 1; }

log_info "Pulling imagem: $FRONTEND_IMAGE"
if docker pull "$FRONTEND_IMAGE" 2>&1 | tee -a "$LOG_DIR/$ENVIRONMENT/frontend-pull.log"; then
  log_success "Imagem frontend baixada com sucesso"
else
  log_error "Falha ao baixar imagem frontend"
  exit 1
fi

log_info "Parando containers frontend antigos..."
docker compose -f "$FRONTEND_COMPOSE" --env-file "$COMPOSE_DIR/.env" down || true

log_info "Iniciando novos containers frontend..."
if docker compose -f "$FRONTEND_COMPOSE" --env-file "$COMPOSE_DIR/.env" up -d --no-build 2>&1 | tee -a "$LOG_DIR/$ENVIRONMENT/frontend-up.log"; then
  log_success "Containers frontend iniciados"
else
  log_error "Falha ao iniciar containers frontend"
  exit 1
fi

# Verificar status
log_info "Verificando status dos containers..."
docker ps --filter "name=$CONTAINER_PREFIX" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | tee -a "$LOG_DIR/$ENVIRONMENT/status.log"

log_success "=========================================="
log_success "Deploy $ENVIRONMENT concluído com sucesso!"
log_success "=========================================="
log_info "Timestamp final: $(date)"
