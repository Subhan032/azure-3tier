# User Assigned Managed Identity for GitHub Actions CI/CD
resource "azurerm_user_assigned_identity" "github_actions" {
  name                = local.github_actions_identity_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags                = local.common_tags
}

# Federated Identity Credential for GitHub Actions OIDC authentication
resource "azurerm_federated_identity_credential" "github_actions" {
  name                      = local.github_actions_federated_credential_name
  user_assigned_identity_id = azurerm_user_assigned_identity.github_actions.id
  issuer                    = "https://token.actions.githubusercontent.com"
  audience                  = ["api://AzureADTokenExchange"]
  subject                   = "repo:${local.github_repository}:ref:refs/heads/${local.github_default_branch}"
}

# Role Assignment: AcrPush on ACR for GitHub Actions identity
resource "azurerm_role_assignment" "github_acr_push" {
  scope                            = azurerm_container_registry.main.id
  role_definition_name             = "AcrPush"
  principal_id                     = azurerm_user_assigned_identity.github_actions.principal_id
  skip_service_principal_aad_check = true
}

# Role Assignment: Website Contributor on Frontend Web App
resource "azurerm_role_assignment" "github_frontend_contributor" {
  scope                            = azurerm_linux_web_app.frontend.id
  role_definition_name             = "Website Contributor"
  principal_id                     = azurerm_user_assigned_identity.github_actions.principal_id
  skip_service_principal_aad_check = true
}

# Role Assignment: Website Contributor on Backend Web App
resource "azurerm_role_assignment" "github_backend_contributor" {
  scope                            = azurerm_linux_web_app.backend.id
  role_definition_name             = "Website Contributor"
  principal_id                     = azurerm_user_assigned_identity.github_actions.principal_id
  skip_service_principal_aad_check = true
}

