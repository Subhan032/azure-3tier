variable "project_name" {
  type        = string
  description = "The name of the project, used for resource naming."
  default     = "azure-3tier"
}

variable "environment" {
  type        = string
  description = "The deployment environment (e.g., dev, staging, prod)."
  default     = "dev"
}

variable "location" {
  type        = string
  description = "The Azure region where resources will be provisioned."
  default     = "westus"
}

variable "vnet_address_space" {
  type        = list(string)
  description = "The address space for the Virtual Network in CIDR notation."
  default     = ["10.0.0.0/16"]
}

variable "backend_subnet_address_prefix" {
  type        = list(string)
  description = "The address prefix for the backend App Service VNet integration subnet."
  default     = ["10.0.1.0/24"]
}

variable "database_subnet_address_prefix" {
  type        = list(string)
  description = "The address prefix for the private database subnet."
  default     = ["10.0.2.0/24"]
}

variable "postgres_admin_username" {
  type        = string
  description = "The administrator username for the PostgreSQL Flexible Server."
  default     = "taskadmin"
}

variable "postgres_admin_password" {
  type        = string
  description = "The administrator password for the PostgreSQL Flexible Server."
  sensitive   = true
}

variable "postgres_version" {
  type        = string
  description = "The major version of PostgreSQL Flexible Server."
  default     = "16"
}

variable "postgres_sku_name" {
  type        = string
  description = "The SKU name for the PostgreSQL Flexible Server."
  default     = "B_Standard_B1ms"
}

variable "postgres_storage_mb" {
  type        = number
  description = "The storage capacity for the PostgreSQL Flexible Server in MB."
  default     = 32768
}
