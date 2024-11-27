# Release Strategy

## Environment Design

The IE Bank project utilizes the following environments:
- **Development (DEV):** For active development and unit testing.
- **User Acceptance Testing (UAT):** For validating features and obtaining stakeholder feedback.
- **Production (PROD):** Live system serving end-users.

### Key Configurations
- CI/CD Pipelines: Implemented with GitHub Actions.
- Deployment Strategy: Blue-Green deployments for minimizing downtime.

## Decisions from DevOps Checklist

- **Version Control:** All code resides in GitHub repositories with branching strategies (`main`, `dev`, `feature` branches).
- **Automated Testing:** Integrated testing for backend and frontend.
- **Monitoring and Feedback:** Application Insights and Log Analytics for monitoring.
- **Documentation:** Automated generation of API documentation using tools like Swagger.

## Decisions from DevSecOps with GitHub Security

- **Dependency Scanning:** Enabled Dependabot alerts and updates.
- **Code Scanning:** Integrated GitHub Advanced Security with CodeQL for vulnerability detection.
- **Secrets Management:** Stored sensitive credentials in Azure Key Vault and accessed using managed identities.

---