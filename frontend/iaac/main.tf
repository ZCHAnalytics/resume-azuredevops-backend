terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.0"
}
terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "zchtfstatestorageacc"
    container_name       = "tfstate"
    key                  = "frontend.tfstate"
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# Create the resource group
resource "azurerm_resource_group" "resume_rg" {
  name     = var.resource_group_name
  location = var.location
}

# Storage Account for Static Website
resource "azurerm_storage_account" "resume_storage" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.resume_rg.name
  location                 = azurerm_resource_group.resume_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_account_static_website" "resume" {
  storage_account_id = azurerm_storage_account.resume_storage.id
  index_document     = "index.html"
  error_404_document = "404.html"
}

# CDN Profile
resource "azurerm_cdn_profile" "resume_cdn" {
  name                = "resume-cdn-profile"
  location            = "Global"
  resource_group_name = azurerm_resource_group.resume_rg.name
  sku                 = "Standard_Microsoft"
}

# CDN Endpoint
resource "azurerm_cdn_endpoint" "resume_endpoint" {
  name                = var.cdn_endpoint_name
  profile_name        = azurerm_cdn_profile.resume_cdn.name
  location            = "Global"
  resource_group_name = azurerm_resource_group.resume_rg.name

  origin {
    name      = "resume-origin"
    host_name = azurerm_storage_account.resume_storage.primary_web_host
  }

  origin_host_header = azurerm_storage_account.resume_storage.primary_web_host

  delivery_rule {
    name  = "EnforceHTTPS"
    order = 1

    request_scheme_condition {
      operator     = "Equal"
      match_values = ["HTTP"]
    }

    url_redirect_action {
      redirect_type = "PermanentRedirect"
      protocol      = "Https"
    }
  }
}
