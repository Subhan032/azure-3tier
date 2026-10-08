# Azure Private DNS Zone for PostgreSQL Flexible Server
resource "azurerm_private_dns_zone" "postgresql" {
  name                = local.postgres_dns_zone_name
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.common_tags
}

# Link Private DNS Zone to the Virtual Network
resource "azurerm_private_dns_zone_virtual_network_link" "postgresql" {
  name                = local.postgres_dns_vnet_link_name
  private_dns_zone_id = azurerm_private_dns_zone.postgresql.id
  virtual_network_id  = azurerm_virtual_network.main.id
  tags                = local.common_tags
}

# Azure Database for PostgreSQL Flexible Server with private VNet integration
resource "azurerm_postgresql_flexible_server" "main" {
  name                   = local.postgres_server_name
  resource_group_name    = azurerm_resource_group.main.name
  location               = azurerm_resource_group.main.location
  version                = var.postgres_version
  delegated_subnet_id    = azurerm_subnet.database.id
  private_dns_zone_id    = azurerm_private_dns_zone.postgresql.id
  administrator_login    = var.postgres_admin_username
  administrator_password = var.postgres_admin_password
  sku_name               = var.postgres_sku_name
  storage_mb             = var.postgres_storage_mb
  backup_retention_days  = 7

  public_network_access_enabled = false
  auto_grow_enabled             = true

  tags = local.common_tags

  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.postgresql
  ]
}

# PostgreSQL Database
resource "azurerm_postgresql_flexible_server_database" "main" {
  name      = local.postgres_database_name
  server_id = azurerm_postgresql_flexible_server.main.id
  collation = "en_US.utf8"
  charset   = "UTF8"
}

