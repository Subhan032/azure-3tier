locals {
  resource_group_name = "rg-${var.project_name}-${var.environment}"
  vnet_name           = "vnet-${var.project_name}-${var.environment}"

  backend_subnet_name  = "snet-backend-integration"
  database_subnet_name = "snet-database"

  backend_nsg_name  = "nsg-${var.project_name}-backend-${var.environment}"
  database_nsg_name = "nsg-${var.project_name}-database-${var.environment}"

  postgres_server_name        = "psql-${var.project_name}-${var.environment}"
  postgres_dns_zone_name      = "${var.project_name}-${var.environment}.postgres.database.azure.com"
  postgres_dns_vnet_link_name = "vnetlink-${var.project_name}-${var.environment}"
  postgres_database_name      = "taskmanager"

  acr_name = "acr${replace(var.project_name, "-", "")}${var.environment}"

  app_service_plan_name = "asp-${var.project_name}-${var.environment}"
  frontend_app_name     = "app-${var.project_name}-${var.environment}-frontend"
  backend_app_name      = "app-${var.project_name}-${var.environment}-backend"

  github_repository     = "Subhan032/azure-3tier-task-manager"
  github_default_branch = "main"

  github_actions_identity_name             = "uami-${var.project_name}-${var.environment}-github"
  github_actions_federated_credential_name = "fic-${var.project_name}-${var.environment}-github"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
