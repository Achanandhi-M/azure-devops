###############################################################################
# modules/azure-devops/main.tf
# Creates: Azure DevOps project, GitHub service connection,
#          ARM service connection, Docker registry connection, build pipeline
#
# Code is hosted on GitHub — Azure DevOps pulls from GitHub to run the pipeline.
###############################################################################

# ── Project ───────────────────────────────────────────────────────────────────

resource "azuredevops_project" "main" {
  name               = var.project_name
  description        = var.project_description
  visibility         = "private"
  version_control    = "Git"
  work_item_template = "Agile"

  features = {
    "boards"       = "enabled"
    "repositories" = "enabled"
    "pipelines"    = "enabled"
    "artifacts"    = "enabled"
    "testplans"    = "disabled"
  }
}

# ── Service Connection: GitHub ─────────────────────────────────────────────────
# Allows Azure DevOps pipelines to read from your GitHub repo.
resource "azuredevops_serviceendpoint_github" "github" {
  project_id            = azuredevops_project.main.id
  service_endpoint_name = "github-connection"
  description           = "Connection to GitHub repository"

  auth_personal {
    personal_access_token = var.github_pat
  }
}

# ── Service Connection: Azure Resource Manager ──────────────────────────────────
# Allows pipelines to deploy to Azure (AKS, ACR, etc.)
resource "azuredevops_serviceendpoint_azurerm" "azure" {
  project_id                             = azuredevops_project.main.id
  service_endpoint_name                  = "azure-subscription"
  description                            = "Azure RM service connection for deploying to AKS"
  service_endpoint_authentication_scheme = "WorkloadIdentityFederation"

  azurerm_spn_tenantid      = var.azure_tenant_id
  azurerm_subscription_id   = var.azure_subscription_id
  azurerm_subscription_name = var.azure_subscription_name
}

# ── Service Connection: Docker Registry (ACR) ─────────────────────────────────
resource "azuredevops_serviceendpoint_dockerregistry" "acr" {
  project_id            = azuredevops_project.main.id
  service_endpoint_name = "acr-connection"
  description           = "Connection to Azure Container Registry"

  docker_registry = "https://${var.acr_login_server}"
  docker_username = ""
  docker_password = ""
  registry_type   = "Others"
}

# ── Pipeline: Build & Deploy ──────────────────────────────────────────────────
# Reads azure-pipelines.yml from your GitHub repo.
resource "azuredevops_build_definition" "main" {
  project_id = azuredevops_project.main.id
  name       = "sample-web-app-ci-cd"
  path       = "\\Pipelines"

  ci_trigger {
    use_yaml = true # Trigger config comes from azure-pipelines.yml in GitHub
  }

  repository {
    repo_type             = "GitHub"
    repo_id               = replace(replace(var.github_repo_url, "https://github.com/", ""), ".git", "") # "user/repo"
    branch_name           = "refs/heads/main"
    yml_path              = "azure-pipelines.yml"
    service_connection_id = azuredevops_serviceendpoint_github.github.id
  }

  # Pipeline variables — available as $(VAR_NAME) in the YAML
  variable {
    name  = "ACR_LOGIN_SERVER"
    value = var.acr_login_server
  }

  variable {
    name  = "AKS_CLUSTER_NAME"
    value = var.aks_cluster_name
  }

  variable {
    name  = "AKS_RESOURCE_GROUP"
    value = var.aks_resource_group_name
  }

  variable {
    name  = "IMAGE_NAME"
    value = "sample-web-app"
  }
}

# ── Pipeline Authorisation: Allow pipeline to use service connections ──────────
resource "azuredevops_pipeline_authorization" "azure_rm" {
  project_id  = azuredevops_project.main.id
  resource_id = azuredevops_serviceendpoint_azurerm.azure.id
  type        = "endpoint"
  pipeline_id = azuredevops_build_definition.main.id
}

resource "azuredevops_pipeline_authorization" "acr" {
  project_id  = azuredevops_project.main.id
  resource_id = azuredevops_serviceendpoint_dockerregistry.acr.id
  type        = "endpoint"
  pipeline_id = azuredevops_build_definition.main.id
}

resource "azuredevops_pipeline_authorization" "github" {
  project_id  = azuredevops_project.main.id
  resource_id = azuredevops_serviceendpoint_github.github.id
  type        = "endpoint"
  pipeline_id = azuredevops_build_definition.main.id
}

# ── Self-Hosted Agent Pool ────────────────────────────────────────────────────
resource "azuredevops_agent_pool" "vm_pool" {
  name           = "self-hosted-pool"
  auto_provision = false
  auto_update    = true
}

resource "azuredevops_agent_queue" "vm_queue" {
  project_id    = azuredevops_project.main.id
  agent_pool_id = azuredevops_agent_pool.vm_pool.id
}

resource "azuredevops_pipeline_authorization" "vm_queue" {
  project_id  = azuredevops_project.main.id
  resource_id = azuredevops_agent_queue.vm_queue.id
  type        = "queue"
  pipeline_id = azuredevops_build_definition.main.id
}
