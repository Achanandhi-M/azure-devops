###############################################################################
# Remote State Backend — Azure Blob Storage
#
# BEFORE RUNNING terraform init:
# 1. Create the storage account manually once (or run scripts/bootstrap.sh)
# 2. Replace the placeholder values below with your real values
# 3. Never commit real values to source control — use environment variables or
#    -backend-config flags instead:
#
#   terraform init \
#     -backend-config="resource_group_name=rg-terraform-state" \
#     -backend-config="storage_account_name=<YOUR_STORAGE_ACCOUNT>" \
#     -backend-config="container_name=tfstate" \
#     -backend-config="key=azure-devops-aks/dev.tfstate"
###############################################################################

terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"        # Change me
    storage_account_name = "YOUR_STORAGE_ACCOUNT_NAME" # Change me (must be globally unique)
    container_name       = "tfstate"
    key                  = "azure-devops-aks/dev.tfstate"
  }
}
