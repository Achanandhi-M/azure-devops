variable "cluster_name" {
  description = "Name of the AKS cluster."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group to deploy the AKS cluster into."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for the cluster."
  type        = string
  default     = "1.35"
}

variable "subnet_id" {
  description = "Resource ID of the subnet for the AKS node pool."
  type        = string
}

variable "node_count" {
  description = "Initial number of nodes."
  type        = number
  default     = 2
}

variable "node_vm_size" {
  description = "VM SKU for nodes."
  type        = string
  default     = "Standard_D2s_v3"
}

variable "min_node_count" {
  description = "Minimum nodes for autoscaler."
  type        = number
  default     = 1
}

variable "max_node_count" {
  description = "Maximum nodes for autoscaler."
  type        = number
  default     = 2
}

variable "tags" {
  description = "Tags to apply."
  type        = map(string)
  default     = {}
}
