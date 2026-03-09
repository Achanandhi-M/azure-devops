#!/usr/bin/env bash
###############################################################################
# scripts/bootstrap.sh
#
# Creates the Azure Storage Account and Blob Container used for Terraform
# remote state. Run this ONCE before running `terraform init`.
#
# USAGE:
#   chmod +x scripts/bootstrap.sh
#   ./scripts/bootstrap.sh
#
# REQUIREMENTS:
#   - Azure CLI installed and logged in (az login)
#   - Correct subscription selected (az account set -s <id>)
###############################################################################

set -euo pipefail

# ── Configuration ─────────────────────────────────────────────────────────────
RESOURCE_GROUP_NAME="rg-terraform-state"
LOCATION="eastus"
STORAGE_ACCOUNT_NAME="tfstate$(openssl rand -hex 4)"   # Random 8-char suffix for uniqueness
CONTAINER_NAME="tfstate"

echo "=================================================="
echo " Terraform Remote State Bootstrap"
echo "=================================================="
echo ""
echo "Resource Group : $RESOURCE_GROUP_NAME"
echo "Location       : $LOCATION"
echo "Storage Account: $STORAGE_ACCOUNT_NAME"
echo "Container      : $CONTAINER_NAME"
echo ""

# ── Create Resource Group ──────────────────────────────────────────────────────
echo "➡️  Creating resource group..."
az group create \
  --name "$RESOURCE_GROUP_NAME" \
  --location "$LOCATION" \
  --output table

# ── Create Storage Account ─────────────────────────────────────────────────────
echo "➡️  Creating storage account..."
az storage account create \
  --name "$STORAGE_ACCOUNT_NAME" \
  --resource-group "$RESOURCE_GROUP_NAME" \
  --location "$LOCATION" \
  --sku Standard_LRS \
  --kind StorageV2 \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false \
  --output table

# ── Enable Versioning for state file protection ──────────────────────────────
echo "➡️  Enabling blob versioning..."
az storage account blob-service-properties update \
  --resource-group "$RESOURCE_GROUP_NAME" \
  --account-name "$STORAGE_ACCOUNT_NAME" \
  --enable-versioning true \
  --output table

# ── Create Blob Container ──────────────────────────────────────────────────────
echo "➡️  Creating blob container..."
az storage container create \
  --name "$CONTAINER_NAME" \
  --account-name "$STORAGE_ACCOUNT_NAME" \
  --auth-mode login \
  --output table

echo ""
echo "=================================================="
echo " ✅  Bootstrap complete!"
echo "=================================================="
echo ""
echo "Next step — run terraform init with these flags:"
echo ""
echo "  cd terraform/"
echo "  terraform init \\"
echo "    -backend-config=\"resource_group_name=${RESOURCE_GROUP_NAME}\" \\"
echo "    -backend-config=\"storage_account_name=${STORAGE_ACCOUNT_NAME}\" \\"
echo "    -backend-config=\"container_name=${CONTAINER_NAME}\" \\"
echo "    -backend-config=\"key=azure-devops-aks/dev.tfstate\""
echo ""
