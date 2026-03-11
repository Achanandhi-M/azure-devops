###############################################################################
# variables.tf — Root Module Variables
# All variables have descriptions, types, and validation rules.
###############################################################################

# ── General ───────────────────────────────────────────────────────────────────

variable "project_name" {
  description = "Base name used to prefix all Azure resources. Keep it short (≤8 chars)."
  type        = string
  default     = "sampleapp"

  validation {
    condition     = can(regex("^[a-z][a-z0-9]{2,14}$", var.project_name))
    error_message = "project_name must be 3-15 lowercase alphanumerics starting with a letter."
  }
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "location" {
  description = "Azure region for all resources."
  type        = string
  default     = "East US"
}

variable "tags" {
  description = "Common tags applied to all Azure resources."
  type        = map(string)
  default     = {}
}

# ── Networking ────────────────────────────────────────────────────────────────

variable "vnet_address_space" {
  description = "Address space for the Virtual Network (CIDR)."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "aks_subnet_address_prefix" {
  description = "Address prefix for the AKS subnet."
  type        = string
  default     = "10.0.1.0/24"
}

# ── ACR ───────────────────────────────────────────────────────────────────────

variable "acr_sku" {
  description = "SKU for Azure Container Registry. Basic is cheapest for learning."
  type        = string
  default     = "Basic"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.acr_sku)
    error_message = "acr_sku must be Basic, Standard, or Premium."
  }
}

# ── AKS ───────────────────────────────────────────────────────────────────────

variable "kubernetes_version" {
  description = "Kubernetes version for the AKS cluster."
  type        = string
  default     = "1.35"
}

variable "aks_node_count" {
  description = "Initial number of nodes in the default node pool."
  type        = number
  default     = 1

  validation {
    condition     = var.aks_node_count >= 1 && var.aks_node_count <= 10
    error_message = "aks_node_count must be between 1 and 10."
  }
}

variable "aks_node_vm_size" {
  description = "VM SKU for the AKS node pool."
  type        = string
  default     = "Standard_DC2s_v3"
}

variable "aks_min_node_count" {
  description = "Minimum node count for cluster autoscaler."
  type        = number
  default     = 1
}

variable "aks_max_node_count" {
  description = "Maximum node count for cluster autoscaler."
  type        = number
  default     = 2
}

# ── Azure DevOps ──────────────────────────────────────────────────────────────

variable "azdo_org_name" {
  description = "Azure DevOps organisation name (the part after dev.azure.com/)."
  type        = string
}

variable "azdo_project_name" {
  description = "Name for the Azure DevOps project to create."
  type        = string
  default     = "SampleAKSApp"
}

variable "azdo_project_description" {
  description = "Description for the Azure DevOps project."
  type        = string
  default     = "Sample C# Web App deployed to AKS — learning Terraform + Azure DevOps"
}

variable "azure_subscription_id" {
  description = "Azure Subscription ID used by the Azure DevOps service connection."
  type        = string
  sensitive   = true
}

variable "azure_subscription_name" {
  description = "Human-readable name of the Azure subscription."
  type        = string
  default     = "My Azure Subscription"
}

variable "azure_tenant_id" {
  description = "Azure tenant (directory) ID."
  type        = string
  sensitive   = true
}

# ── GitHub ────────────────────────────────────────────────────────────────────

variable "github_repo_url" {
  description = "Full GitHub repository URL, e.g. https://github.com/username/repo-name"
  type        = string
}

variable "github_pat" {
  description = "GitHub Personal Access Token with 'repo' scope — for the Azure DevOps GitHub service connection."
  type        = string
  sensitive   = true
}

# ── Self-Hosted VM Agent ──────────────────────────────────────────────────────

variable "azdo_pat" {
  description = "Azure DevOps Personal Access Token with 'Agent Pools (Read & Manage)' scope to register the self-hosted agent."
  type        = string
  sensitive   = true
}

variable "vm_admin_password" {
  description = "Admin password for the self-hosted Ubuntu VM agent."
  type        = string
  sensitive   = true
}
