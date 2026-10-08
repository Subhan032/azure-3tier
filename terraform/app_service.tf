# Linux App Service Plan for hosting frontend and backend web apps
resource "azurerm_service_plan" "main" {
  name                = local.app_service_plan_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = "B1"

  tags = local.common_tags
}

# Frontend Linux Web App (publicly reachable, Docker container via ACR)
resource "azurerm_linux_web_app" "frontend" {
  name                = local.frontend_app_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  service_plan_id     = azurerm_service_plan.main.id
  https_only          = true

  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on                               = true
    minimum_tls_version                     = "1.2"
    ftps_state                              = "Disabled"
    container_registry_use_managed_identity = true

    application_stack {
      docker_image_name   = "frontend:latest"
      docker_registry_url = "https://${azurerm_container_registry.main.login_server}"
    }
  }

  app_settings = {
    WEBSITES_PORT = "80"
  }

  tags = local.common_tags
}

# Backend Linux Web App (Docker container via ACR with regional VNet integration)
resource "azurerm_linux_web_app" "backend" {
  name                      = local.backend_app_name
  resource_group_name       = azurerm_resource_group.main.name
  location                  = azurerm_resource_group.main.location
  service_plan_id           = azurerm_service_plan.main.id
  virtual_network_subnet_id = azurerm_subnet.backend.id
  https_only                = true

  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on                               = true
    minimum_tls_version                     = "1.2"
    ftps_state                              = "Disabled"
    vnet_route_all_enabled                  = true
    container_registry_use_managed_identity = true

    application_stack {
      docker_image_name   = "backend:latest"
      docker_registry_url = "https://${azurerm_container_registry.main.login_server}"
    }
  }

  app_settings = {
    WEBSITES_PORT = "5000"
    DB_HOST       = azurerm_postgresql_flexible_server.main.fqdn
    DB_PORT       = "5432"
    DB_NAME       = azurerm_postgresql_flexible_server_database.main.name
    DB_USER       = var.postgres_admin_username
    DB_PASSWORD   = var.postgres_admin_password
  }

  tags = local.common_tags
}

# Grant AcrPull role to Frontend Web App System-Assigned Managed Identity
resource "azurerm_role_assignment" "frontend_acr_pull" {
  scope                            = azurerm_container_registry.main.id
  role_definition_name             = "AcrPull"
  principal_id                     = azurerm_linux_web_app.frontend.identity[0].principal_id
  skip_service_principal_aad_check = true
}

# Grant AcrPull role to Backend Web App System-Assigned Managed Identity
resource "azurerm_role_assignment" "backend_acr_pull" {
  scope                            = azurerm_container_registry.main.id
  role_definition_name             = "AcrPull"
  principal_id                     = azurerm_linux_web_app.backend.identity[0].principal_id
  skip_service_principal_aad_check = true
}

