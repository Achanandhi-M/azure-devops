variable "project_name" {
  description = "Name of the Azure DevOps project."
  type        = string
}

variable "project_description" {
  description = "Description for the Azure DevOps project."
  type        = string
  default     = ""
}

variable "azure_subscription_id" {
  description = "Azure subscription ID for the ARM service connection."
  type        = string
  sensitive   = true
}

variable "azure_subscription_name" {
  description = "Human-readable Azure subscription name."
  type        = string
}

variable "azure_tenant_id" {
  description = "Azure tenant ID."
  type        = string
  sensitive   = true
}

variable "aks_cluster_name" {
  description = "Name of the AKS cluster — injected as a pipeline variable."
  type        = string
}

variable "aks_resource_group_name" {
  description = "Resource group containing the AKS cluster."
  type        = string
}

variable "acr_login_server" {
  description = "ACR login server FQDN — used in Docker service connection and pipeline variable."
  type        = string
}

variable "acr_id" {
  description = "Resource ID of the ACR (reserved for future RBAC use)."
  type        = string
}

# ── GitHub ───────────────────────────────────────────────────────────────────
variable "github_repo_url" {
  description = "Full GitHub repo URL, e.g. https://github.com/username/repo-name"
  type        = string
}

variable "github_pat" {
  description = "GitHub Personal Access Token with repo scope — used to create the GitHub service connection."
  type        = string
  sensitive   = true
}
