# Azure 3-Tier Task Manager

A beginner-friendly 3-tier task management application running entirely in Docker via Docker Compose, designed for local development and eventual cloud deployment to Microsoft Azure.

---

## What the Application Does

Azure 3-Tier Task Manager is a simple task management web application that allows you to:
- **View all tasks:** Loads existing tasks in real time from a PostgreSQL database.
- **Add tasks:** Create new tasks via a simple form input.
- **Toggle task status:** Mark tasks as completed or pending.
- **Delete tasks:** Remove tasks from the database.

---

## Architecture (3-Tier Local Docker Stack)

```text
Browser (Windows / Host)
   │
   ├─► http://localhost:8080 (Loads HTML/CSS/JS)
   │        │
   │        ▼
   │   Frontend Container (Nginx on port 80)
   │
   └─► http://localhost:5000 (API fetch calls)
            │
            ▼
       Backend Container (Flask REST API on port 5000)
            │
            ▼ (postgres:5432 across Docker network)
       Database Container (PostgreSQL 16 Alpine)
            │
            ▼
       Docker Volume (postgres_data)
```

1. **Frontend (Presentation Tier):** Static HTML5, CSS3, and Vanilla JavaScript served by a lightweight **Nginx** container (`taskmanager-frontend`). Port `8080` on your host is mapped to port `80` in the container.
2. **Backend (Application Tier):** Python **Flask** REST API running in a container (`taskmanager-backend`). Exposes port `5000` to the host and connects to PostgreSQL using `psycopg`.
3. **Database (Data Tier):** Official **PostgreSQL 16 Alpine** container (`taskmanager-postgres`) accessible inside the Docker Compose network at `postgres:5432`.
4. **Data Persistence:** Persistent named Docker volume (`postgres_data`) preserving database records across container restarts.

---

## Local Development Workflow (WSL2 Ubuntu)

### START
Navigate to the repository and start all three containers in the background:
```bash
cd ~/azure-3tier
docker compose up --build -d
```

### CHECK
Verify that all three services are running and healthy:
```bash
docker compose ps
```

### OPEN
Open your web browser and navigate to:
```text
http://localhost:8080
```

### VIEW LOGS
Inspect the recent logs from all services or a specific container:
```bash
docker compose logs --tail=100
```
Or for the backend only:
```bash
docker compose logs --tail=100 backend
```

### STOP
Stop all three containers while preserving your database records:
```bash
docker compose down
```

### RESET DATABASE COMPLETELY
> [!WARNING]
> Running the command below deletes the PostgreSQL Docker volume (`postgres_data`) and **permanently removes all local database data**:
```bash
docker compose down -v
```
Use this only if you intentionally want to delete all tasks and reset to a brand new, empty database.

---

## How the Components Communicate
- **Browser to Frontend:** The browser loads the webpage from `http://localhost:8080` (served by Nginx inside Docker).
- **Browser to Backend API:** When you interact with the UI, JavaScript in `app.js` sends HTTP requests directly to `http://localhost:5000` (handled by Flask inside Docker).
- **Backend to Database:** The Flask container connects to PostgreSQL using the Docker service name `postgres` on port `5432` (`postgres:5432`). PostgreSQL is not directly exposed to the browser.

---

## Terraform Foundation (Infrastructure as Code)

The `terraform/` directory defines the Infrastructure as Code (IaC) configuration for deploying this application to Microsoft Azure.

### What Terraform Commands Do
- **`terraform init`**: Initializes the working directory and downloads the required provider plugins (such as `hashicorp/azurerm`).
- **`terraform validate`**: Verifies that configuration files are syntactically valid and internally consistent.
- **`terraform plan`**: Previews the changes Terraform will make to your cloud infrastructure before touching real resources.
- **`terraform apply`**: Actually creates, updates, or provisions the cloud resources in Azure based on the execution plan.

> [!NOTE]
> We have established the foundational Resource Group and Azure networking architecture (`VNet`, `subnets`, and `NSGs`). We intentionally have **not** deployed or created the cloud architecture in Azure yet (`terraform apply` has not been run).

---

## Azure Networking Foundation (Step 7)

The `terraform/network.tf` file declares the core cloud networking foundation:

- **Virtual Network (VNet):** An isolated private network in Azure. We use `10.0.0.0/16`, providing 65,536 private IP addresses to slice into smaller subnets as the project grows.
- **Backend Integration Subnet (`10.0.1.0/24`):** A dedicated subnet reserved for Azure App Service regional VNet integration. It is delegated to `Microsoft.Web/serverFarms`, giving Azure App Service permission to attach private virtual network interfaces so the backend can securely talk to private backend services.
- **Database Subnet (`10.0.2.0/24`):** An isolated subnet reserved for the future private PostgreSQL Flexible Server. It is kept strictly separate from compute workloads.
- **Network Security Groups (NSGs):** Virtual firewalls applied at the subnet level. They inspect and control traffic flow.
- **Why PostgreSQL is Private:** In professional 3-tier architectures, databases should never have public IP addresses or accept direct traffic from the public Internet. Restricting database access to private subnets prevents unauthorized external access.

---

## Azure PostgreSQL Flexible Server — Step 8

The `terraform/postgresql.tf` file configures the production database tier for Azure:

- **Managed Database Service:** Azure handles database infrastructure provisioning, operating system patching, automated hardware maintenance, and health monitoring, eliminating manual database maintenance.
- **Why Flexible Server:** Azure Database for PostgreSQL Flexible Server is Microsoft's modern managed PostgreSQL service, offering cost-effective burstable SKUs (`B_Standard_B1ms`), granular server parameter tuning, and native private VNet integration.
- **Private VNet Integration:** The Flexible Server is injected directly into our private virtual network using the dedicated database subnet (`10.0.2.0/24`), which is delegated to `Microsoft.DBforPostgreSQL/flexibleServers`.
- **Database Subnet Role:** Isolates database network interfaces in a dedicated network segment separated from compute and frontend workloads.
- **Private DNS Zone (`.postgres.database.azure.com`):** Resolves the private PostgreSQL server name into its internal private IP address inside our VNet. Linked to `azurerm_virtual_network.main` via a private DNS virtual network link.
- **No Public Access:** `public_network_access_enabled = false` and no public IPs or firewall rules exist. The database is completely unexposed to the public Internet and only reachable from resources inside the private VNet.
- **Sensitive Variable Security:** The administrator password is defined as a `sensitive = true` variable with no default value in Terraform, preventing plaintext credentials from being recorded in Git or terminal logs. It is provided at runtime via `TF_VAR_postgres_admin_password`.
- **Deployment Status:** The Terraform configuration and execution plan have been validated with `terraform plan` (12 resources planned). Cloud resources have **not** been provisioned in Azure yet because `terraform apply` has not been executed.

---

## Azure Container Registry — Step 9

The `terraform/acr.tf` file configures a private container image registry in Azure:

- **What Azure Container Registry (ACR) Does:** ACR is a managed private Open Container Initiative (OCI) registry hosted in Azure that stores and manages container images.
- **Why the Project Needs It:** It provides a secure, private cloud registry to host our custom `frontend` and `backend` container images so Azure App Service instances can pull and run them.
- **Basic SKU Efficiency:** The `Basic` SKU provides a cost-effective development tier with 10 GB of storage and full OCI compatibility, keeping expenses minimal for a portfolio project without sacrificing functionality.
- **Disabled Admin Credentials:** `admin_enabled = false` adheres to least-privilege security by disabling static shared administrator passwords and preventing credential sprawl.
- **Container Image Storage Pattern:** Container images will be organized under the registry login server: `<acr-login-server>/frontend:<tag>` and `<acr-login-server>/backend:<tag>`. Repositories are created automatically upon first push.
- **Automated Image Publishing:** GitHub Actions workflows will build and push the container images to ACR during the CI/CD pipeline in a later step.
- **Secure Image Pulls via Managed Identity:** Azure App Services will pull container images using Azure Managed Identities and Azure RBAC (`AcrPull`), avoiding embedded secrets.
- **Deployment Status:** The ACR configuration and updated execution plan have been verified with `terraform plan` (13 resources planned). Cloud infrastructure has **not** been created yet because `terraform apply` has not been executed.

---

## Azure App Services — Step 10

The `terraform/app_service.tf` file configures the compute hosting tier using Azure App Services:

- **Linux App Service Plan:** A single shared Linux App Service Plan (`B1` Basic SKU) hosts both the frontend and backend web apps, keeping hosting costs minimal for a development/portfolio environment while supporting custom containers and regional VNet integration.
- **Public Frontend App Service (`azurerm_linux_web_app.frontend`):** Configured to host the static Nginx/HTML/CSS/JS frontend container. It is exposed to the public Internet with HTTPS-only enforcement and TLS 1.2 minimum.
- **Private-Facing Backend App Service (`azurerm_linux_web_app.backend`):** Configured to host the Python Flask REST API container on port 5000. Enforces HTTPS-only and TLS 1.2.
- **Backend Regional VNet Integration:** Injected into `azurerm_subnet.backend` (`10.0.1.0/24`) with all outbound traffic routed through the virtual network (`vnet_route_all_enabled = true`). The frontend remains outside the VNet, preserving tier separation.
- **Private PostgreSQL Connectivity:** The backend container environment variables (`DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`) connect privately to the PostgreSQL Flexible Server FQDN across the VNet via internal private DNS resolution.
- **Zero ACR Credentials via Managed Identities & RBAC:** Both web apps use Azure System-Assigned Managed Identities with `AcrPull` role assignments scoped directly to the Azure Container Registry. Static registry administrator passwords remain disabled.
- **Deployment Status:** The App Service configuration has been validated in Terraform with `terraform plan` (18 resources planned). Cloud infrastructure has **not** been deployed yet because `terraform apply` has not been executed.

---

## GitHub Actions CI/CD — Step 11

The `.github/workflows/deploy.yml` workflow and `terraform/github_actions.tf` configure automated CI/CD using modern OpenID Connect (OIDC) authentication:

- **Passwordless Azure OIDC:** GitHub Actions authenticates directly with Microsoft Entra ID (Azure AD) using short-lived OIDC tokens. No long-lived client secrets, management passwords, or service principal credentials are stored.
- **User Assigned Managed Identity (`uami-azure-3tier-dev-github`):** A dedicated Azure identity created specifically for GitHub Actions runners.
- **Strict Federated Credential:** The Federated Identity Credential (`fic-azure-3tier-dev-github`) trusts only our specific repository and default branch:
  `repo:Subhan032/azure-3tier-task-manager:ref:refs/heads/main`
  No other repository or untrusted branch can assume this identity.
- **Least-Privilege RBAC Permissions:**
  - `AcrPush` scoped strictly to `azurerm_container_registry.main` (pushes custom images without admin credentials).
  - `Website Contributor` scoped directly to `azurerm_linux_web_app.frontend` and `azurerm_linux_web_app.backend` (updates container images without broad resource-group or subscription-wide rights).
- **Immutable Docker Image Tags:** Built and tagged with `${{ github.sha }}` (`<acr-login-server>/frontend:<git-sha>` and `<acr-login-server>/backend:<git-sha>`), ensuring full traceability from Git commit to cloud runtime.
- **GitHub Secrets Configuration (Required after `terraform apply`):**
  Once Terraform is applied, configure the following repository secrets in GitHub (**Settings > Secrets and variables > Actions**):
  - `AZURE_CLIENT_ID`: The Client ID of `uami-azure-3tier-dev-github` (from Terraform output `github_actions_client_id`).
  - `AZURE_TENANT_ID`: Your Azure Tenant / Directory ID (from Terraform output `github_actions_tenant_id`).
  - `AZURE_SUBSCRIPTION_ID`: Your Azure Subscription ID.
  *(Note: These are public cloud identifiers, not passwords or secrets.)*
- **Deployment Status:** Workflow and OIDC federation have been declared and validated in Terraform (`terraform plan` with 23 resources planned). The workflow has **not** been executed and no Docker images have been pushed yet because cloud resources have not been provisioned with `terraform apply`.




