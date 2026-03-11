output "project_id" {
  description = "Azure DevOps project ID."
  value       = azuredevops_project.main.id
}

output "project_name" {
  description = "Azure DevOps project name."
  value       = azuredevops_project.main.name
}

output "github_service_connection_id" {
  description = "ID of the GitHub service connection."
  value       = azuredevops_serviceendpoint_github.github.id
}

output "github_service_connection_name" {
  description = "Name of the GitHub service connection."
  value       = azuredevops_serviceendpoint_github.github.service_endpoint_name
}

output "pipeline_id" {
  description = "Build pipeline ID."
  value       = azuredevops_build_definition.main.id
}
