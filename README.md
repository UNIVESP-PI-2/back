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
