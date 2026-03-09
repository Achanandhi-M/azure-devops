variable "name" {
  description = "Name of the Azure Container Registry (globally unique, alphanumeric only)."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9]{5,50}$", var.name))
    error_message = "ACR name must be 5-50 alphanumeric characters (no hyphens)."
  }
}

variable "resource_group_name" {
  description = "Resource group to deploy the ACR into."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "sku" {
  description = "ACR SKU: Basic, Standard, or Premium."
  type        = string
  default     = "Basic"
}

variable "tags" {
  description = "Tags to apply to the ACR."
  type        = map(string)
  default     = {}
}
