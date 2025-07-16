# Azure DevOps Cloud Resume Challenge

This repository contains both backend and frontend code that adapts the traditional [Cloud Resume Challenge](https://cloudresumechallenge.dev/) for **Azure DevOps**. It replaces GitHub Actions with Azure Pipelines and runs CI/CD using a local Windows agent with PowerShell scripting.

## Overview

The backend service powers a **visitor counter API** exposed via Azure Functions and tracks visits to the frontend résumé site. Frontend files are deployed to a static website hosted in Azure Storage and delivered securely via Azure CDN.

---

##  Challenge Steps Completed & Enhancements

### ☁️ Infrastructure & Deployment

-  Fully automated **Infrastructure as Code** using **Terraform**
-  Deployed using **Azure DevOps Pipelines**
-  Remote state stored securely in separate Azure Storage
-  CDN-enabled static website (HTTPS enforced via Azure CDN)

### 🛠 Backend (API)

-  Built using **Python Azure Functions**
-  Visitor data stored in **Azure Cosmos DB** (Table API)
-  Azure Function triggered via HTTP with CORS & security headers

### 🔄 CI/CD Process

-  Terraform runs triggered by changes in the `iaac/` directory
-  Azure Function deployed only after infrastructure is provisioned successfully
-  End-to-end tests executed using **Cypress** before final deployment
-  All Bash commands rewritten in **PowerShell** for Windows compatibility

###  Security & Compliance

-  **SBOM (Software Bill of Materials)** generated using [Syft](https://github.com/anchore/syft)
-  Vulnerability scanning with [Grype](https://github.com/anchore/grype)
-  Azure Service Principal configured with minimal RBAC permissions
-  Secrets stored securely in Azure DevOps Pipelines Library

---

##  Testing

- **Cypress** is used for end-to-end testing after successful backend deployment
- Tests verify the CDN-delivered site and API integration

---

##  Notes

- Commits are signed and saved using `GPG secure commit`.

---
