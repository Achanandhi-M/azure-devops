###############################################################################
# main.tf — Root Module
# Orchestrates all child modules. Think of this as the "glue" that wires
# networking → ACR → AKS → Azure DevOps together.
###############################################################################

# ── Random suffix to ensure globally unique names ─────────────────────────────
resource "random_string" "suffix" {
  length  = 5
  special = false
  upper   = false
}

locals {
  # Consistent naming: {project}-{env}-{suffix}
  name_prefix = "${var.project_name}-${var.environment}"
  unique_name = "${var.project_name}${var.environment}${random_string.suffix.result}"

  common_tags = merge(var.tags, {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    CreatedAt   = timestamp()
  })
}

# ── Module: Networking ────────────────────────────────────────────────────────
module "networking" {
  source = "./modules/networking"

  project_name              = var.project_name
  environment               = var.environment
  location                  = var.location
  vnet_address_space        = var.vnet_address_space
  aks_subnet_address_prefix = var.aks_subnet_address_prefix
  tags                      = local.common_tags
}

# ── Module: Azure Container Registry ─────────────────────────────────────────
module "acr" {
  source = "./modules/acr"

  name                = "acr${local.unique_name}"
  location            = var.location
  resource_group_name = module.networking.resource_group_name
  sku                 = var.acr_sku
  tags                = local.common_tags

  depends_on = [module.networking]
}

# ── Module: AKS Cluster ────────────────────────────────────────────────────────
module "aks" {
  source = "./modules/aks"

  cluster_name        = "aks-${local.name_prefix}"
  location            = var.location
  resource_group_name = module.networking.resource_group_name
  kubernetes_version  = var.kubernetes_version
  subnet_id           = module.networking.aks_subnet_id
  node_count          = var.aks_node_count
  node_vm_size        = var.aks_node_vm_size
  min_node_count      = var.aks_min_node_count
  max_node_count      = var.aks_max_node_count
  tags                = local.common_tags

  depends_on = [module.networking]
}

# ── ACR Pull Role Assignment: AKS → ACR ──────────────────────────────────────
# Grants the AKS kubelet identity permission to pull images from ACR
resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id                     = module.aks.kubelet_identity_object_id
  role_definition_name             = "AcrPull"
  scope                            = module.acr.acr_id
  skip_service_principal_aad_check = true

  depends_on = [module.aks, module.acr]
}

# ── Module: Azure DevOps ──────────────────────────────────────────────────────
module "azure_devops" {
  source = "./modules/azure-devops"

  project_name            = var.azdo_project_name
  project_description     = var.azdo_project_description
  azure_subscription_id   = var.azure_subscription_id
  azure_subscription_name = var.azure_subscription_name
  azure_tenant_id         = var.azure_tenant_id
  aks_cluster_name        = module.aks.cluster_name
  aks_resource_group_name = module.networking.resource_group_name
  acr_login_server        = module.acr.login_server
  acr_id                  = module.acr.acr_id
  github_repo_url         = var.github_repo_url
  github_pat              = var.github_pat

  depends_on = [module.aks, module.acr]
}

# ── Module: VM Agent (Self-Hosted Pool) ───────────────────────────────────────
module "vm_agent" {
  source = "./modules/vm-agent"

  name                = "agent-${local.unique_name}"
  location            = var.location
  resource_group_name = module.networking.resource_group_name
  subnet_id           = module.networking.aks_subnet_id
  
  admin_password      = var.vm_admin_password
  azdo_org_url        = var.azdo_org_url
  azdo_pat            = var.azdo_pat
  azdo_pool_name      = "self-hosted-pool"

  tags = local.common_tags

  depends_on = [module.networking, module.azure_devops]
}
