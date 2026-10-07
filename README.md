# Azure 3-Tier Task Manager

## Description
A simple 3-tier task management application designed for deployment to Microsoft Azure.

## Planned Technologies
- **Tier 1 - Presentation:** HTML, CSS, Vanilla JavaScript, Docker, Azure App Service
- **Tier 2 - Application:** Python, Flask (REST API), Docker, Azure App Service
- **Tier 3 - Data:** PostgreSQL, Azure Database for PostgreSQL Flexible Server
- **Infrastructure:** Terraform (Azure Resource Group, Azure VNet, Backend Subnet, Database Subnet, NSGs, Azure Container Registry, Azure App Services, PostgreSQL Flexible Server, Azure Storage Account for Terraform state)
- **CI/CD:** GitHub Actions

## Planned Architecture
The application is structured into three tiers deployed across Microsoft Azure:

- **Tier 1 - Presentation (Frontend):**
  - Simple user interface built with HTML, CSS, and Vanilla JavaScript.
  - Packaged in a Docker container and deployed to Azure App Service.

- **Tier 2 - Application (Backend):**
  - RESTful API developed with Python and Flask.
  - Packaged in a Docker container and deployed to Azure App Service within the backend subnet.

- **Tier 3 - Data (Database):**
  - PostgreSQL database deployed using Azure Database for PostgreSQL Flexible Server.
  - Placed in a private database subnet with restricted access.

- **Networking & Infrastructure:**
  - Azure Virtual Network (VNet) with isolated backend and database subnets.
  - Network Security Groups (NSGs) to control network traffic between tiers.
  - Infrastructure provisioned via Terraform with remote state management in an Azure Storage Account.
  - Continuous integration and deployment automated via GitHub Actions.

