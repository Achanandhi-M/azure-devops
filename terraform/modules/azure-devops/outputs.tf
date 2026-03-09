output "project_id" {
  description = "Azure DevOps project ID."
  value       = azuredevops_project.main.id
}

output "project_name" {
  description = "Azure DevOps project name."
  value       = azuredevops_project.main.name
}

output "repo_id" {
  description = "Git repository ID."
  value       = azuredevops_git_repository.main.id
}

output "repo_url" {
  description = "Remote clone URL for the Git repository."
  value       = azuredevops_git_repository.main.remote_url
}

output "pipeline_id" {
  description = "Build pipeline ID."
  value       = azuredevops_build_definition.main.id
}
