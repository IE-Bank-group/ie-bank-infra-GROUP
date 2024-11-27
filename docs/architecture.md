# Architecture Design

## Overview
The system is designed to support scalability, reliability, and performance, leveraging Azure services.

### Key Components
1. **Frontend:**
   - Hosted on Azure Static Web Apps.
   - Built using React.

2. **Backend:**
   - Hosted on Azure App Service for Containers.
   - Built with Node.js.

3. **Infrastructure:**
   - Provisioned using Infrastructure as Code (Bicep).
   - Includes PostgreSQL, Key Vault, and Application Insights.

### Architecture Diagram
![Infrastructure Diagram](diagrams/infra-diagram.png)

For more details, refer to the [CI/CD Pipelines](ci-cd.md) and [Monitoring](monitoring.md) sections.