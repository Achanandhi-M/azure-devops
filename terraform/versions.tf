terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "~> 0.11"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

# ── Provider Configuration ─────────────────────────────────────────────────────

provider "azurerm" {
  features {
    resource_group {
      # Prevent accidental deletion of non-empty resource groups
      prevent_deletion_if_contains_resources = false
    }
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

# Azure DevOps provider reads org_service_url and personal_access_token
# from environment variables:
#   AZDO_ORG_SERVICE_URL  — e.g. https://dev.azure.com/myorg
#   AZDO_PERSONAL_ACCESS_TOKEN
provider "azuredevops" {}
