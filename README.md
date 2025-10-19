# Back End

Back-End do Projeto Integrador 2

---

## Para desenvolver

### Pré-requistos

- Tenha o Docker instalado.

### Para rodar o ambiente de desenvolvimento (Docker)

```bash
sudo docker compose -f .docker/development-compose.yml -p backend --env-file .env up -d
```

Acesse [http://localhost:3000/api/v1/teste]

### Para parar o ambiente de desenvolvimento (Docker)

```bash
sudo docker compose -f .docker/development-compose.yml -p backend --env-file .env down
```

---

## Configuração de Deploy (CI/CD)

### Variáveis de Ambiente Necessárias

O arquivo `.env` deve conter as seguintes variáveis:

```env
# Aplicação
APP_PORT=3000

# Banco de Dados
DB_DRIVER=mongo
DB_PORT=27017
DB_URI=mongodb://app:abc1234@db:27017
DB_USER=app
DB_PASS=abc1234
DATABASE=backend_app

# JWT
JWT_SECRET=sua_chave_secreta_jwt_muito_segura_aqui_2024
```

### Secrets do GitHub Actions

Para o deploy funcionar, configure os seguintes **Repository Secrets** no GitHub:

#### SSH e Servidor
- `SSH_SECRET_KEY` - Chave privada SSH para acesso ao servidor
- `SSH_PORT` - Porta SSH do servidor (geralmente 22)
- `SSH_NAME_USER` - Nome do usuário no servidor
- `SSH_HOST` - IP ou domínio do servidor

#### Variáveis de Ambiente do Homologação
- `ENV_HOMO_APP_PORT` - Porta da aplicação (ex: 3000)
- `ENV_HOMO_DB_DRIVER` - Driver do banco (mongo)
- `ENV_HOMO_DB_USER` - Usuário do MongoDB
- `ENV_HOMO_DB_PORT` - Porta do MongoDB (27017)
- `ENV_HOMO_DB_PASS` - Senha do MongoDB
- `ENV_HOMO_DB_URI` - URI completa do MongoDB
- `ENV_HOMO_DATABASE` - Nome da database (backend_app)
- `ENV_HOMO_JWT_SECRET` - Chave secreta do JWT

### Usuário Administrador Inicial

O sistema cria automaticamente um usuário administrador quando o MongoDB é inicializado:

- **Email:** `admin@123`
- **Senha:** `admin`

**⚠️ IMPORTANTE:** Altere essas credenciais após o primeiro login em produção!

### Como fazer deploy

1. Faça suas alterações e commit
2. Push para qualquer branch
3. O GitHub Actions executará automaticamente o CI/CD
4. O deploy será feito no ambiente de homologação

```bash
git add .
git commit -m "fix: corrigir autenticação e variáveis de ambiente"
git push origin ci/cd
```
# Deploy com compose files unificados
# Deploy ready
# Fixed CD workflow
# Fixed .env
# Proxy network added
