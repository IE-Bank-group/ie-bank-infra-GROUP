# CI/CD Pipelines

## Overview
The pipelines are implemented using GitHub Actions to automate deployment for frontend, backend, and infrastructure.

### Frontend
- Workflow: `deploy-fe.yml`
- Deploys React app to Azure Static Web Apps.

### Backend
- Workflow: `deploy-be.yml`
- Builds and deploys Docker containers to Azure App Service.

### Infrastructure
- Workflow: `deploy-infra.yml`
- Provisions infrastructure using Bicep templates.

### Key Features
1. Automated linting and testing.
2. Multi-environment deployment (Dev, UAT, Prod).
3. Notifications on pipeline status.