# =============================================================================
# Variables Declaration File
# Used by: main.tf and tfvars file, consumed during terraform plan/apply
# =============================================================================

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  # Used in: All resources (acts as parent container)
}

variable "location" {
  description = "Azure region"
  type        = string
  # Used in: Resource group, Function App, Cosmos DB, etc.
}

variable "cdn_endpoint_name" {
  description = "Name of the CDN endpoint"
  type        = string
  # Reserved for future use if deploying CDN (not used in current main.tf)
}

variable "frontend_origin_urls" {
  description = "List of allowed frontend origins for CORS"
  type        = list(string)
  # Used in: Function App CORS settings (site_config -> cors)
}

variable "function_storage_name" {
  description = "Name of the storage account for the Function App"
  type        = string
  # Used in: Storage Account and Function App linkage
}

variable "function_app_name" {
  description = "Name of the Azure Function App"
  type        = string
  # Used in: Function App name 
}

variable "cosmosdb_account_name" {
  description = "Name of the Cosmos DB account"
  type        = string
  # Used in: Cosmos DB resource block
}
