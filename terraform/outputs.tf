###############################################################################
# outputs.tf — Root Module Outputs
# These are printed after terraform apply and can be used by scripts/pipelines.
###############################################################################

output "resource_group_name" {
  description = "Name of the Azure Resource Group."
  value       = module.networking.resource_group_name
}

output "aks_cluster_name" {
  description = "Name of the AKS cluster."
  value       = module.aks.cluster_name
}

output "aks_cluster_id" {
  description = "Resource ID of the AKS cluster."
  value       = module.aks.cluster_id
}

output "acr_login_server" {
  description = "ACR login server URL (e.g. myacr.azurecr.io). Used in docker push."
  value       = module.acr.login_server
}

output "acr_name" {
  description = "Name of the Azure Container Registry."
  value       = module.acr.name
}

output "azure_devops_project_name" {
  description = "Name of the created Azure DevOps project."
  value       = module.azure_devops.project_name
}

output "github_service_connection" {
  description = "Name of the GitHub service connection in Azure DevOps."
  value       = module.azure_devops.github_service_connection_name
}

output "get_credentials_command" {
  description = "Command to configure kubectl for this AKS cluster."
  value       = "az aks get-credentials --resource-group ${module.networking.resource_group_name} --name ${module.aks.cluster_name} --overwrite-existing"
}
