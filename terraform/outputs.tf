output "resource_group_name" {
  description = "The name of the provisioned Azure Resource Group."
  value       = azurerm_resource_group.main.name
}

output "resource_group_location" {
  description = "The Azure location of the provisioned Resource Group."
  value       = azurerm_resource_group.main.location
}

output "vnet_name" {
  description = "The name of the Virtual Network."
  value       = azurerm_virtual_network.main.name
}

output "vnet_id" {
  description = "The ID of the Virtual Network."
  value       = azurerm_virtual_network.main.id
}

output "backend_subnet_id" {
  description = "The ID of the backend App Service integration subnet."
  value       = azurerm_subnet.backend.id
}

output "database_subnet_id" {
  description = "The ID of the database subnet."
  value       = azurerm_subnet.database.id
}

output "backend_nsg_id" {
  description = "The ID of the backend Network Security Group."
  value       = azurerm_network_security_group.backend.id
}

output "database_nsg_id" {
  description = "The ID of the database Network Security Group."
  value       = azurerm_network_security_group.database.id
}

output "postgres_server_name" {
  description = "The name of the PostgreSQL Flexible Server."
  value       = azurerm_postgresql_flexible_server.main.name
}

output "postgres_server_fqdn" {
  description = "The fully qualified domain name (FQDN) of the PostgreSQL Flexible Server."
  value       = azurerm_postgresql_flexible_server.main.fqdn
}

output "postgres_database_name" {
  description = "The name of the provisioned PostgreSQL database."
  value       = azurerm_postgresql_flexible_server_database.main.name
}

output "postgres_private_dns_zone_id" {
  description = "The resource ID of the PostgreSQL Private DNS Zone."
  value       = azurerm_private_dns_zone.postgresql.id
}

output "acr_name" {
  description = "The name of the Azure Container Registry."
  value       = azurerm_container_registry.main.name
}

output "acr_login_server" {
  description = "The login server URL for the Azure Container Registry."
  value       = azurerm_container_registry.main.login_server
}

output "acr_id" {
  description = "The resource ID of the Azure Container Registry."
  value       = azurerm_container_registry.main.id
}

output "app_service_plan_name" {
  description = "The name of the Linux App Service Plan."
  value       = azurerm_service_plan.main.name
}

output "frontend_app_name" {
  description = "The name of the frontend Linux Web App."
  value       = azurerm_linux_web_app.frontend.name
}

output "frontend_default_hostname" {
  description = "The default hostname of the frontend Linux Web App."
  value       = azurerm_linux_web_app.frontend.default_hostname
}

output "backend_app_name" {
  description = "The name of the backend Linux Web App."
  value       = azurerm_linux_web_app.backend.name
}

output "backend_default_hostname" {
  description = "The default hostname of the backend Linux Web App."
  value       = azurerm_linux_web_app.backend.default_hostname
}

output "github_actions_identity_name" {
  description = "The name of the User Assigned Managed Identity for GitHub Actions."
  value       = azurerm_user_assigned_identity.github_actions.name
}

output "github_actions_client_id" {
  description = "The Client ID of the User Assigned Managed Identity for GitHub Actions (configure as AZURE_CLIENT_ID secret)."
  value       = azurerm_user_assigned_identity.github_actions.client_id
}

output "github_actions_principal_id" {
  description = "The Principal ID (Object ID) of the User Assigned Managed Identity for GitHub Actions."
  value       = azurerm_user_assigned_identity.github_actions.principal_id
}

output "github_actions_tenant_id" {
  description = "The Tenant ID of the User Assigned Managed Identity for GitHub Actions (configure as AZURE_TENANT_ID secret)."
  value       = azurerm_user_assigned_identity.github_actions.tenant_id
}


