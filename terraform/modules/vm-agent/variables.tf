variable "name" {
  description = "Name of the VM agent"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "vm_size" {
  description = "The SKU size for the virtual machine"
  type        = string
  default     = "Standard_DC2s_v3" # Using the same size as AKS to ensure availability
}


variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where the VM will be deployed"
  type        = string
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "azureuser"
}

variable "admin_password" {
  description = "Admin password for the VM"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "azdo_org_url" {
  description = "Azure DevOps organization URL"
  type        = string
}

variable "azdo_pat" {
  description = "Azure DevOps Personal Access Token"
  type        = string
  sensitive   = true
}

variable "azdo_pool_name" {
  description = "Name of the agent pool to join"
  type        = string
}
