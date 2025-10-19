# Inicialização Automática do Banco de Dados

Este projeto agora inclui inicialização automática do banco de dados MongoDB, similar ao `init.sql` do PostgreSQL.

## Como funciona

O arquivo `.docker/mongo-init/01-init-admin.js` é executado automaticamente quando o container MongoDB é criado pela primeira vez.

## Configuração

1. **Copie o arquivo de exemplo de variáveis de ambiente:**
   ```bash
   cp .env.example .env
   ```

2. **Configure as variáveis no arquivo `.env`:**
   - `DATABASE`: Nome da base de dados (ex: `backend_app`)
   - `DB_USER`: Usuário root do MongoDB
   - `DB_PASS`: Senha do usuário root
   - Outras variáveis conforme necessário

## Usuário Administrador

O script automaticamente criará um usuário administrador com as seguintes credenciais:
- **Email:** `admin@123`
- **Senha:** `admin`

Este usuário será criado apenas se não existir na base de dados.

## Como executar

1. **Para ambiente de desenvolvimento:**
   ```bash
   docker-compose -f .docker/development-compose.yml up -d
   ```

2. **Para recriar o banco (forçar execução do script novamente):**
   ```bash
   # Parar e remover containers e volumes
   docker-compose -f .docker/development-compose.yml down -v
   
   # Subir novamente (executará o script de inicialização)
   docker-compose -f .docker/development-compose.yml up -d
   ```

## Adicionando mais dados iniciais

Para adicionar mais usuários ou dados iniciais:

1. Edite o arquivo `.docker/mongo-init/01-init-admin.js`
2. Adicione seus comandos de inserção no final do arquivo
3. Recrie o container para aplicar as mudanças

## Verificando se funcionou

Para verificar se o usuário foi criado:

```bash
# Conectar ao container
docker exec -it backend_mongo mongosh

# No mongosh:
use backend_app  // ou o nome da sua base de dados
db.users.findOne({email: "admin@123"})
```