# -----------------------------------------------------------------------------
# Frontend / Website Outputs
# -----------------------------------------------------------------------------

output "static_website_url" {
  value = azurerm_storage_account.resume_storage.primary_web_endpoint
  description = "The URL of the static website"
}

output "storage_account_name" {
  value = azurerm_storage_account.resume_storage.name
  description = "The name of the storage account"
}
output "cdn_endpoint_url" {
  value = "https://${azurerm_cdn_endpoint.resume_endpoint.name}.azureedge.net"
  description = "The CDN endpoint URL"
}

output "cdn_endpoint_name" {
  description = "CDN endpoint name for purging"
  value       = azurerm_cdn_endpoint.resume_endpoint.name
}

output "cdn_profile_name" {
  value       = azurerm_cdn_profile.resume_cdn.name
  description = "CDN Profile Name"
}