# Azure Cloud Resume Challenge — Backend API

This repository contains the backend API for the Cloud Resume Challenge, implemented as an Azure Function app with Cosmos DB to provide a dynamic visitor counter.

## Overview

This backend service powers the unique visitor counter on the frontend resume site and exposes API endpoints for visitor tracking.

### Challenge Steps Completed & Enhancements
- AzureDevops
- Built using **Python Azure Functions** with Cosmos DB for persistent, scalable data storage.
- Fully automated infrastructure deployment via **Terraform**, managed through GitHub Actions.
- Implemented **CI/CD pipelines** that:
  - Deploy infrastructure (IaC) changes from `iaac/` directory.
  - Deploy backend function app only after successful infrastructure provisioning.
- Added **Software Bill of Materials (SBOM)** generation with Syft and vulnerability scanning using Grype to improve supply chain security.
- Modular workflows using smart triggers to deploy only when necessary.
- Ensured **workflow security** and permissions are locked down in GitHub Actions.

---


