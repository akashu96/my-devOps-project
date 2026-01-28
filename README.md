**Purpose:** Setup and deployment guide

```markdown
# GitHub Actions + ACR Setup Guide

## Prerequisites

- GitHub repository..
- Azure subscription
- Azure Container Registry (ACR) created
- Basic Docker knowledge

## Step 1: Create Azure Container Registry

```bash
# Login to Azure CLI
az login

# Create resource group
az group create \
  --name myapp-rg \
  --location eastus

# Create ACR
az acr create \
  --resource-group myapp-rg \
  --name myacr \
  --sku Basic \
  --admin-enabled true
```

## Step 2: Get ACR Credentials

```bash
# Get login server
az acr show \
  --name myacr \
  --query loginServer \
  --output tsv
# Output: myacr.azurecr.io

# Get admin credentials
az acr credential show \
  --resource-group myapp-rg \
  --name myacr

# Save:
# - Login Server: myacr.azurecr.io
# - Username: (from credential output)
# - Password: (from credential output)
```

## Step 3: Add GitHub Secrets

1. Go to GitHub repo → Settings → Secrets and variables → Actions
2. Create three secrets:
   - `ACR_LOGIN_SERVER`: myacr.azurecr.io
   - `ACR_USERNAME`: (from Step 2)
   - `ACR_PASSWORD`: (from Step 2)

## Step 4: Set Up Environments (For Approvals)

1. Go to Settings → Environments
2. Create "staging" environment
3. Create "production" environment
4. On production: Add required reviewers under "Deployment branches and secrets"

## Step 5: Test Workflow

```bash
# Push code to trigger workflow
git add .
git commit -m "feat: add GitHub Actions workflow"
git push origin main

# Monitor in GitHub Actions tab
# Look for "Build and Push to ACR" workflow
```

## Step 6: Verify Image in ACR

```bash
# List repositories
az acr repository list \
  --name myacr \
  --output table

# List image tags
az acr repository show-tags \
  --name myacr \
  --repository myapp \
  --output table

# Pull and run locally
docker pull myacr.azurecr.io/myapp:latest
docker run -p 3000:3000 myacr.azurecr.io/myapp:latest
```

## Troubleshooting

### Workflow fails at login
- Verify secrets are set correctly
- Check ACR name spelling
- Ensure ACR exists and is accessible

### Image not pushing
- Check Docker login step
- Verify repository name in YAML
- Check ACR Storage quota

### Tests failing in container
- Run image locally: `docker run -it myacr.azurecr.io/myapp:latest bash`
- Check Dockerfile dependencies
- Verify all .npmrc or .pypirc files included

## Best Practices

✅ Use specific base image versions (not `latest`)  
✅ Implement multi-stage builds for smaller images  
✅ Run security scans on built images  
✅ Use least-privilege credentials  
✅ Set image retention policies in ACR  
✅ Monitor workflow execution times  
✅ Implement proper error handling and notifications

## Next Steps

1. Add deployment jobs to deploy to AKS or Container Instances
2. Implement image scanning for vulnerabilities
3. Set up notifications for workflow failures
4. Add manual approval gates for production
5. Implement rollback strategies
```

---

## Setup Checklist

Before running workflows:

- [ ] Azure Container Registry created
- [ ] GitHub secrets configured (ACR_LOGIN_SERVER, ACR_USERNAME, ACR_PASSWORD)
- [ ] GitHub environments created (staging, production) if using approvals
- [ ] Dockerfile present in repository root
- [ ] Workflow files in `.github/workflows/` directory
- [ ] At least one push to trigger workflow
- [ ] Docker image successfully building locally: `docker build -t myapp .`

---

**Note:** Replace `myacr`, `myapp`, and URLs with your actual values across all files..
