# terraform.tfvars
# -------------------------------------------------------------------
# Used during both `terraform plan` and `terraform apply` steps.
# This file holds non-sensitive values for variable substitution.
# Do NOT put secrets here — keep them in GitHub Secrets or Key Vault.
# -------------------------------------------------------------------

resource_group_name     = "ubds-rg"               # Used for all Azure resources
location                = "uksouth"                         # Azure region for deployment

cdn_endpoint_name       = "ubds-resume"                  # Reserved for CDN if used in future

frontend_origin_urls    = ["https://ubds-resume.azureedge.net"] # CORS whitelist for Function App

function_storage_name   = "ubdsfuncstorage"        # Storage used by the Azure Function App
function_app_name       = "ubds-func-app"         # Azure Function App name (must be globally unique)

cosmosdb_account_name   = "ubds-resume-cosmos"                # CosmosDB account name
