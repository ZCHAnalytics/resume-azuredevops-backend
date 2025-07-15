# ----- Terraform Settings -----
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0" # Use version 3.x (latest minor patch version will be used)
    }
  }
  required_version = ">= 1.0" # Ensure Terraform CLI is v1.0 or newer
}
/*
This is an old backend configuration that worked with Github Actions and Azure_cred secrets. 
It is not used in the Azuredevops, where credentials are passed using service principal connection
# ----- Backend Configuration -----
# This block stores Terraform state remotely in an Azure Storage Account

terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"                 # Must exist before 'terraform init'        
    storage_account_name = "zchtfstatestorageacc"       # Must be globally unique
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}
# Note: The backend block is essential during 'terraform init' (both plan and apply).
# It configures remote state storage used in GitHub Actions workflows:
#    - 'Terraform Init' step in plan and apply jobs uses this to connect state storage.
*/

# ----- Provider Setup -----
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false # Allow RG deletion even if not empty (use with caution)
    }
  }
}
# Provider block used during all Terraform commands (init, plan, apply).

# ----- Resource Group -----
resource "azurerm_resource_group" "resume_rg" {
  name     = var.resource_group_name
  location = var.location
}
# Created or checked during both plan and apply.
# Variables (like resource_group_name, location) come from the tfvars file in iaac folder.

# ----- CosmosDB Account -----

# ----- CosmosDB Account -----
resource "azurerm_cosmosdb_account" "resume_cosmos" {
  name                = var.cosmosdb_account_name
  location            = azurerm_resource_group.resume_rg.location
  resource_group_name = azurerm_resource_group.resume_rg.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  # Enables table API (for key-value access)
  capabilities {
    name = "EnableTable"
  }

  # Enables serverless billing model (best for low traffic)
  capabilities {
    name = "EnableServerless"
  }

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = azurerm_resource_group.resume_rg.location
    failover_priority = 0
  }

  free_tier_enabled = true # First 1000 RU/s free (one account per region only)
}

# Created/managed during plan/apply.
# Sensitive values like primary keys are exposed via terraform output commands
# but keys should NOT be stored in tfvars or source control.
# Outputs like cosmosdb_endpoint are often consumed later in workflows or apps.

# ----- CosmosDB Tables -----
# Table for counting visits
resource "azurerm_cosmosdb_table" "visitor_counter" {
  name                = "VisitorCounter"
  resource_group_name = azurerm_resource_group.resume_rg.name
  account_name        = azurerm_cosmosdb_account.resume_cosmos.name
}


# Table for tracking individual visitor metadata (optional)
resource "azurerm_cosmosdb_table" "visitors" {
  name                = "Visitors"
  resource_group_name = azurerm_resource_group.resume_rg.name
  account_name        = azurerm_cosmosdb_account.resume_cosmos.name
}

# Created as part of infrastructure, referenced in Terraform plan/apply.

# ----- Log Analytics Workspace -----
resource "azurerm_log_analytics_workspace" "resume_workspace" {
  name                = "resume-log-analytics"
  location            = azurerm_resource_group.resume_rg.location
  resource_group_name = azurerm_resource_group.resume_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30 # Retain logs for 30 days
}


# ----- Application Insights -----
resource "azurerm_application_insights" "resume_insights" {
  name                = "resume-app-insights"
  location            = azurerm_resource_group.resume_rg.location
  resource_group_name = azurerm_resource_group.resume_rg.name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.resume_workspace.id
}

# Created during apply; outputs (instrumentation key) used by Function App settings.


# ----- Azure Storage for Function App -----
resource "azurerm_storage_account" "function_storage" {
  name                     = var.function_storage_name
  resource_group_name      = azurerm_resource_group.resume_rg.name
  location                 = azurerm_resource_group.resume_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
# Created/managed during plan/apply.
# Storage account keys are sensitive — output handled carefully.


# ----- App Service Plan (Linux Consumption Tier) -----
resource "azurerm_service_plan" "resume_plan" {
  name                = "resume-function-plan"
  resource_group_name = azurerm_resource_group.resume_rg.name
  location            = azurerm_resource_group.resume_rg.location
  os_type             = "Linux"
  sku_name            = "Y1" # Serverless tier (Pay per execution, ideal for low traffic)
}

# Created during apply; SKU set here (Y1 = Consumption Plan).


# ----- Azure Function App (Python) -----
resource "azurerm_linux_function_app" "resume_function" {
  name                = var.function_app_name
  resource_group_name = azurerm_resource_group.resume_rg.name
  location            = azurerm_resource_group.resume_rg.location
  
  storage_account_name       = azurerm_storage_account.function_storage.name
  storage_account_access_key = azurerm_storage_account.function_storage.primary_access_key
  service_plan_id            = azurerm_service_plan.resume_plan.id

  site_config {
    application_insights_key = azurerm_application_insights.resume_insights.instrumentation_key
    application_stack {
      python_version = "3.10" # Use supported Python version
    }
    cors {
      allowed_origins = var.frontend_origin_urls # Enable CORS for the  site
    }
  }

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME"         = "python"
    "AzureWebJobsStorage"             = azurerm_storage_account.function_storage.primary_connection_string
    "COSMOS_ENDPOINT"                 = azurerm_cosmosdb_account.resume_cosmos.endpoint
    "COSMOS_KEY"                      = azurerm_cosmosdb_account.resume_cosmos.primary_key
    "APPINSIGHTS_INSTRUMENTATIONKEY"  = azurerm_application_insights.resume_insights.instrumentation_key
  }
}

# Created during apply.
# Reads sensitive keys and connection strings from associated resources.
# app_settings consume outputs from other blocks.

# ===== Summary of File Usage in GitHub Workflows =====
# - The entire `main.tf` is used during both `terraform plan` and `terraform apply` steps.
# - Variables referenced here (e.g., `var.resource_group_name`) should be supplied in the 
#   `terraform.tfvars` file (non-sensitive values), which is checked into Git.
# - Sensitive credentials such as Cosmos DB keys and Storage Account keys are NOT stored
#   in `tfvars` but are handled via internal outputs (not printed in development), or managed
#   securely using Azure Key Vault (recommended for production).
# - The GitHub Actions workflow uses secrets (`AZURE_CREDENTIALS` and `AZURE_SUBSCRIPTION_ID`) to authenticate and
#   run these Terraform commands, referencing both this file and the `tfvars`.
# - The `plan` job generates an execution plan file, which the `apply` job later consumes.
# - Terraform outputs (e.g., endpoint URLs and the Function App URL) are captured post-apply
#   to populate the GitHub step summary or to support downstream deployment steps.
