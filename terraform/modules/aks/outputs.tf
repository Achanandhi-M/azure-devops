output "cluster_id" {
  description = "Resource ID of the AKS cluster."
  value       = azurerm_kubernetes_cluster.main.id
}

output "cluster_name" {
  description = "Name of the AKS cluster."
  value       = azurerm_kubernetes_cluster.main.name
}

output "kube_config" {
  description = "Raw kube config for the cluster."
  value       = azurerm_kubernetes_cluster.main.kube_config_raw
  sensitive   = true
}

output "kubelet_identity_object_id" {
  description = "Object ID of the kubelet managed identity — used for ACR pull role assignment."
  value       = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
}

output "node_resource_group" {
  description = "The auto-generated resource group where AKS node VMs live."
  value       = azurerm_kubernetes_cluster.main.node_resource_group
}

output "principal_id" {
  description = "Object ID of the cluster system-assigned managed identity."
  value       = azurerm_kubernetes_cluster.main.identity[0].principal_id
}
