# Resumo das configurações do Docker

## Ambiente de Desenvolvimento

Para rodar o ambiente de desenvolvimento usando o docker faça:

```bash
# Crie as variáveis de ambiente
cp .env.example .env
```

```bash
# Iniciar os container usando o arquivo development-compose.yml
docker compose -f .docker/development-compose.yml -p backend --env-file .env up -d
```

```bash
# Derrubar os container
docker compose -f .docker/development-compose.yml -p backend --env-file .env down
```
