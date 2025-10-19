#!/bin/bash
# Script de inicialização do VPS para CI/CD com Docker
# Executar como root ou com sudo

set -e

echo "=========================================="
echo "Inicialização do VPS para CI/CD"
echo "=========================================="

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Função para imprimir com cor
print_status() {
  echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
  echo -e "${RED}✗${NC} $1"
}

# 1. Criar estrutura de diretórios
echo ""
echo "1. Criando estrutura de diretórios..."

mkdir -p /opt/compose
mkdir -p /opt/deploy
mkdir -p /opt/logs/homo
mkdir -p /opt/logs/prod

chmod 755 /opt/compose
chmod 755 /opt/deploy
chmod 755 /opt/logs

print_status "Diretórios criados"

# 2. Criar redes Docker
echo ""
echo "2. Criando redes Docker..."

docker network create homo-network-app 2>/dev/null || print_warning "Rede homo-network-app já existe"
docker network create prod-network-app 2>/dev/null || print_warning "Rede prod-network-app já existe"

print_status "Redes Docker criadas"

# 3. Criar volumes Docker
echo ""
echo "3. Criando volumes Docker..."

docker volume create homo-mongo-data 2>/dev/null || print_warning "Volume homo-mongo-data já existe"
docker volume create prod-mongo-data 2>/dev/null || print_warning "Volume prod-mongo-data já existe"

print_status "Volumes Docker criados"

# 4. Configurar permissões de usuário deploy
echo ""
echo "4. Configurando usuário deploy..."

if ! id "deploy" &>/dev/null; then
  useradd -m -s /bin/bash deploy || print_warning "Usuário deploy já existe"
else
  print_warning "Usuário deploy já existe"
fi

# Adicionar deploy ao grupo docker
usermod -aG docker deploy

# Criar .ssh para deploy
mkdir -p /home/deploy/.ssh
chmod 700 /home/deploy/.ssh
chown -R deploy:deploy /home/deploy/.ssh

print_status "Usuário deploy configurado"

# 5. Configurar permissões de sudo sem senha para docker
echo ""
echo "5. Configurando sudo para docker..."

if ! sudo -u deploy -n docker ps &>/dev/null; then
  echo "deploy ALL=(ALL) NOPASSWD: /usr/bin/docker, /usr/bin/docker-compose" >> /etc/sudoers.d/deploy-docker
  chmod 440 /etc/sudoers.d/deploy-docker
  print_status "Sudo configurado para docker"
else
  print_warning "Sudo para docker já configurado"
fi

# 6. Configurar propriedade dos diretórios
echo ""
echo "6. Configurando propriedade dos diretórios..."

chown -R deploy:deploy /opt/compose
chown -R deploy:deploy /opt/deploy
chown -R deploy:deploy /opt/logs

print_status "Propriedades configuradas"

# 7. Criar arquivo de template .env
echo ""
echo "7. Criando arquivo template .env..."

cat > /opt/compose/.env.template << 'EOF'
# Backend - Homologação
BACKEND_HOMO_DB_URI=mongodb://user:pass@homo-back-db:27017
BACKEND_HOMO_DB_USER=mongo_user
BACKEND_HOMO_DB_PASS=change_me_to_secure_password
BACKEND_HOMO_DATABASE=backend_homo
BACKEND_HOMO_JWT_SECRET=seu_jwt_secret_aqui_deve_ser_muito_longo_e_aleatorio
BACKEND_HOMO_HEADER_START=header_start_value
BACKEND_HOMO_DEBUG=true

# Backend - Produção
BACKEND_PROD_DB_URI=mongodb://user:pass@prod-back-db:27017
BACKEND_PROD_DB_USER=mongo_user
BACKEND_PROD_DB_PASS=change_me_to_secure_password
BACKEND_PROD_DATABASE=backend_prod
BACKEND_PROD_JWT_SECRET=seu_jwt_secret_aqui_deve_ser_muito_longo_e_aleatorio
BACKEND_PROD_HEADER_START=header_start_value
BACKEND_PROD_DEBUG=false
EOF

chmod 600 /opt/compose/.env.template
chown deploy:deploy /opt/compose/.env.template

print_status "Arquivo .env.template criado"

echo ""
echo "=========================================="
echo -e "${GREEN}Inicialização concluída com sucesso!${NC}"
echo "=========================================="
echo ""
echo "Próximas etapas:"
echo "1. Adicionar chave SSH pública do GitHub Actions ao /home/deploy/.ssh/authorized_keys"
echo "2. Copiar .env.template para .env e preencher com valores reais"
echo "3. Copiar docker-compose files para /opt/compose"
echo "4. Executar: chown deploy:deploy /opt/compose/.env"
echo ""
