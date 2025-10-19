# GitHub Secrets Configuration

## Overview
This document contains all the GitHub Secrets required for CI/CD deployment. Configure these secrets in your GitHub repository settings under `Settings > Secrets and variables > Actions`.

## Required Secrets

### SSH & Server Access
These secrets are used for SSH deployment to the VPS.

```
SSH_SECRET_KEY         = [Your private SSH key for deploy user]
SSH_PORT               = 22
SSH_NAME_USER          = deploy
SSH_HOST               = projeto-integrador.app.br
GITHUB_TOKEN           = [GitHub Personal Access Token with repo scope]
```

### GHCR (GitHub Container Registry) Authentication
Used for pushing Docker images to GHCR.

```
GHCR_USERNAME          = [GitHub username]
GHCR_TOKEN             = [GitHub Personal Access Token with read:packages, write:packages scope]
```

### Environment Variables - HOMOLOGAÇÃO (homo branch)
These will be passed via secrets and converted to `.env.homo` during CI/CD deployment.

```
DB_URI_HOMO                = mongodb://mongo_user:mongo_pass@homo-back-db:27017/backend_homo?authSource=admin
DB_USER_HOMO               = mongo_user
DB_PASS_HOMO               = mongo_pass
DATABASE_HOMO              = backend_homo
JWT_SECRET_HOMO            = [Generate a random 32+ character string for JWT signing]
HEADER_START_HOMO          = Authorization
DEBUG_HOMO                 = true
APP_PORT_HOMO              = 3000
```

**Example JWT_SECRET generation:**
```bash
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

### Environment Variables - PRODUÇÃO (main branch)
These will be passed via secrets and converted to `.env.prod` during CI/CD deployment.

```
DB_URI_PROD                = mongodb://mongo_user:mongo_pass@prod-back-db:27017/backend_prod?authSource=admin
DB_USER_PROD               = mongo_user
DB_PASS_PROD               = mongo_pass
DATABASE_PROD              = backend_prod
JWT_SECRET_PROD            = [Generate a DIFFERENT random 32+ character string]
HEADER_START_PROD          = Authorization
DEBUG_PROD                 = false
APP_PORT_PROD              = 3000
```

## Setup Instructions

### 1. Generate SSH Key (if not already done)
```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_rsa_deploy -C "github-actions-deploy"
# Copy the public key to VPS: /home/deploy/.ssh/authorized_keys
```

### 2. Add Secrets to GitHub
Go to: `Settings > Secrets and variables > Actions > New repository secret`

Add each secret from above with the exact name and value.

### 3. Generate JWT Secrets
```bash
# Generate random JWT secret for HOMO
node -e "console.log('JWT_SECRET_HOMO=' + require('crypto').randomBytes(32).toString('hex'))"

# Generate random JWT secret for PROD
node -e "console.log('JWT_SECRET_PROD=' + require('crypto').randomBytes(32).toString('hex'))"
```

### 4. Verify Secrets
Run this command to verify (without showing values):
```bash
gh secret list --repo UNIVESP-PI-2/back
```

## Security Notes

- ⚠️ Never commit `.env` files to the repository
- ⚠️ Rotate JWT_SECRET_PROD regularly in production
- ⚠️ Keep SSH private key secure
- ⚠️ Use different credentials for homo and prod
- ✅ All secrets are injected during GitHub Actions workflow
- ✅ CI/CD will never write secrets to VPS disk

## MongoDB Initial User

The MongoDB initialization script automatically creates:
- **Email:** `admin@123`
- **Password:** `admin`

Change these after first login in production!

## Troubleshooting

### "Authentication failed" in prod-back-db
- Check `DB_PASS_PROD` matches MongoDB initialization
- Verify `DB_URI_PROD` has correct `authSource=admin`

### "Token invalid" errors
- Ensure `JWT_SECRET_HOMO` and `JWT_SECRET_PROD` are set correctly
- Different secrets should be used for each environment

### SSH deployment failing
- Verify SSH public key is in `/home/deploy/.ssh/authorized_keys` on VPS
- Check `SSH_SECRET_KEY` is the correct private key format
- Confirm `SSH_HOST` and `SSH_PORT` are correct

## CI/CD Flow

1. Developer pushes to `homo` or `main` branch
2. GitHub Actions reads all environment secrets
3. CI builds and tests the application
4. Docker image is pushed to GHCR with appropriate tag
5. CD workflow SSH into VPS and pulls the new image
6. Docker Compose updates containers with new image
7. Environment variables are injected via GitHub Secrets (no .env files)

